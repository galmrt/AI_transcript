from elasticsearch import Elasticsearch
import json
from datetime import datetime
from pathlib import Path

MAPPINGS_FILE = Path(__file__).parent / "es_mappings.json"

class ESService:
    def __init__(self, es_url: str):
        self.url = es_url
        print(f"🔍 Connecting to Elasticsearch at: {es_url}")
        self.client = Elasticsearch(hosts=[es_url])
        self.index = "transcripts"

        # Test connection
        try:
            info = self.client.info()
            print(f"✅ Connected to Elasticsearch {info['version']['number']}")
        except Exception as e:
            print(f"❌ Failed to connect to Elasticsearch: {e}")
            raise

        self.create_index()
        
    
    def create_index(self):
        try:
            print(f"🔍 Checking if index '{self.index}' exists...")
            exists = self.client.indices.exists(index=self.index)

            if not exists:
                print(f"📝 Creating index '{self.index}'...")
                with open(MAPPINGS_FILE) as f:
                    mappings = json.load(f)
                self.client.indices.create(index=self.index, mappings=mappings)
                print(f"✅ Created index {self.index}")
            else:
                print(f"✅ Index {self.index} already exists")
        except Exception as e:
            print(f"❌ Error in create_index: {type(e).__name__}: {e}")
            raise
            
    def save_transcript(self, transcript_raw: str, audio_url: str, transcript_clean: str, input_type: str = "text"):
        words = transcript_clean.split()[:5]
        title = " ".join(words) + ("..." if len(transcript_clean.split()) > 5 else "")

        doc = {
            "raw_transcript": transcript_raw,
            "title": title,
            "audio_url": audio_url,
            "cleaned_transcript": transcript_clean,
            "cleaned_transcript_vector": transcript_clean,
            "input_type": input_type,
            "@timestamp": datetime.now().isoformat()
        }
        response = self.client.index(index=self.index, document=doc)
        print(f"✅ Saved transcript with ID: {response['_id']}")
        return response['_id']
        
    def search(self, query:str):
        query = {
            "query": {
                "match": {
                    "cleaned_transcript": query
                }
                
            }
        }
        response = self.client.search(index=self.index, body=query)
        print("Search results: ", response)
        return response
    
    def get_transcript(self, id: str):
        response = self.client.get(index=self.index, id=id)
        print(f"✅ Retrieved transcript: {id}")
        return response
    
    def get_history(self, limit: int = 50):
        response = self.client.search(
            index=self.index,
            _source=False,
            fields=["title", "@timestamp"],
            size=limit,
            sort=[{"@timestamp": {"order": "desc"}}]
        )
        print(f"✅ Retrieved {len(response['hits']['hits'])} transcripts from history")
        return response
    
    