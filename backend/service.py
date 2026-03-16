import os
from openai import OpenAI
from faster_whisper import WhisperModel
from pathlib import Path

PROMPT_FILE = Path(__file__).parent/"prompts/clean_transcript.txt"
SYSTEM_PROMPT = PROMPT_FILE.read_text().strip()

class TranscriptionService:
    def __init__(self, whisper_model: str, llm_base_url: str, llm_api_key: str, llm_model : str):
        self.whisper = WhisperModel(whisper_model, device="auto", compute_type="int8")
        self.llm_client = OpenAI(base_url=llm_base_url, api_key=llm_api_key)
        self.llm_model = llm_model

        print("Transcription service initialized")

        try:
            self.llm_client.models.list()
            print("✅ LLM connection successful")
        except Exception as e:
            print(f"⚠️  Warning: Could not connect to LLM at {llm_base_url}")
            print(f"   Error: {e}")
            print("   Make sure Ollama is running: ollama serve")
            print("   Transcription will work, but cleaning will fail.")

    def transcribe(self, audio_path: str) -> str:
        if not os.path.exists(audio_path):
            raise FileNotFoundError(f"Audio file not found at {audio_path}")
        
        print("Transcribing audio...")
        segments, _ = self.whisper.transcribe(audio_path, language="en")
        text = ''.join(segment.text for segment in segments)
        print(f"Transcription complete: {text}")
    
        return text
        
    def clean_transcript(self, text:str, prompt: str=None):
        # Use default prompt if none provided or if it's just "string"
        if not prompt or prompt == "string":
            prompt = SYSTEM_PROMPT

        print(f"🧹 Cleaning transcript with LLM model: {self.llm_model}")
        print(f"   Text length: {len(text)} characters")

        try:
            response = self.llm_client.chat.completions.create(
                        model=self.llm_model,
                        messages= [{
                            "role": "system",
                            "content": prompt
                        },
                        {
                            "role": "user",
                            "content": text
                        }],
                        temperature=0.5)
            cleaned = response.choices[0].message.content.strip()
            print(f"✅ Cleaned transcript: {cleaned}")
            return cleaned
        except Exception as e:
            print(f"❌ Error cleaning transcript: {type(e).__name__}: {str(e)}")
            raise e
        
        
