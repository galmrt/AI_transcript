from fastapi import FastAPI, UploadFile, File, HTTPException
from dotenv import load_dotenv
from pydantic import BaseModel
from service import TranscriptionService
import os 
from typing import Annotated
import tempfile
from fastapi.middleware.cors import CORSMiddleware
from es_service import ESService

load_dotenv()

class CleanRequest(BaseModel):
    text: str
    system_prompt: str = None  # Optional: uses default if not provided
    audio_filename: str = None  # Optional: for tracking audio source
    input_type: str = "text"  # "text", "upload", or "record"

class TranscriptResponse(BaseModel):
    transcript: str

class CleanResponse(BaseModel):
    cleaned_text: str
    
    
service = None
es = None

async def lifespan(app: FastAPI):
    global service
    global es
    print("Starting up...")
    service = TranscriptionService(whisper_model=os.getenv("WHISPER_MODEL"), 
                                   llm_base_url=os.getenv("LLM_BASE_URL"), 
                                   llm_api_key=os.getenv("LLM_API_KEY"), 
                                   llm_model=os.getenv("LLM_MODEL"))
    es = ESService(es_url=os.getenv("ES_URL"))
    yield

app = FastAPI(title="Transcript API", lifespan=lifespan)

# CORS configuration for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/home")
async def home():
    return {"message": "Transcription API is running!"}


@app.post("/home/transcribe_audio", response_model=TranscriptResponse)
async def transcribe_audio(audio: Annotated[UploadFile, File(description="Audio file to transcribe")]):
    """
    Transcribe an audio file to text using Whisper.

    Accepts: wav, mp3, webm, m4a, ogg, flac
    Max size: 25MB (recommended)
    """
    suffix = os.path.splitext(audio.filename)[1] or ".webm"

    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as temp_file:
        temp_file.write(await audio.read())
        temp_file_path = temp_file.name

    try:
        transcript = service.transcribe(temp_file_path)
        # Don't save here - will be saved when cleaned
        return {"transcript": transcript}
    except Exception as e:
        print(f"❌ Error during transcription: {type(e).__name__}: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Transcription failed: {str(e)}")
    finally:
        os.remove(temp_file_path)
        
@app.post("/home/clean_transcript", response_model=CleanResponse)
async def clean_transcript(request: CleanRequest):
    """
    Clean a transcript using LLM (removes filler words, fixes grammar).

    Requires Ollama to be running with llama3.1:8b model.
    """
    if not service:
        raise HTTPException(status_code=500, detail="Service not initialized")

    try:
        cleaned_text = service.clean_transcript(request.text, request.system_prompt)
        # Save to Elasticsearch with proper metadata
        es.save_transcript(
            request.text,
            request.audio_filename,
            cleaned_text,
            input_type=request.input_type
        )
        return {"cleaned_text": cleaned_text}
    except Exception as e:
        print(f"❌ Error during cleaning: {type(e).__name__}: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Cleaning failed: {str(e)}")
    
@app.post("/home/search")
async def search(query: str):
    """
    Search for a query in the Elasticsearch index.
    """
    if not es:
        raise HTTPException(status_code=500, detail="ES service not initialized")

    try:
        response = es.search(query)
        return response
    except Exception as e:
        print(f"❌ Error during search: {type(e).__name__}: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Search failed: {str(e)}")

@app.get("/home/get_transcript/{id}")
async def get_transcript(id: str):
    """
    Get a transcript from the Elasticsearch index.
    """
    if not service:
        raise HTTPException(status_code=500, detail="Service not initialized")
    
    try: 
        print("Getting transcript: ", id)
        response = es.get_transcript(id)
        return response
    except Exception as e:
        print(f"❌ Error during get_transcript: {type(e).__name__}: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Get transcript failed: {str(e)}")
    
@app.get("/home/history")
async def get_history():
    """
    Get search history from the Elasticsearch index.
    """
    if not service:
        raise HTTPException(status_code=500, detail="Service not initialized")
    
    try:
        response = es.get_history()
        return response
    except Exception as e:
        print(f"❌ Error during get_history: {type(e).__name__}: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Get history failed: {str(e)}")
    