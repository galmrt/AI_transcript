# 🎙️ AI Transcript Application

> A local-first AI-powered transcription app with Whisper, Ollama, and Elasticsearch

## 🎯 Features

- 🎤 **Record Audio** - Browser-based recording
- 📁 **Upload Files** - Support for mp3, wav, webm, m4a
- ✏️ **Paste Text** - Clean any text directly
- 🧹 **AI Cleaning** - Remove filler words, fix grammar
- 📜 **History** - Search and browse past transcripts
- 🔍 **Full-Text Search** - Powered by Elasticsearch
- 🏠 **100% Local** - All AI runs on your machine

## 🛠️ Tech Stack

**Frontend:**
- React 18 with Vite
- MediaRecorder API for audio

**Backend:**
- FastAPI (Python 3.12)
- faster-whisper (speech-to-text)
- Ollama + llama3.2 (LLM cleaning)
- Elasticsearch 8.11 (search & storage)

**Infrastructure:**
- Docker (Elasticsearch only)
- Native AI models (better performance)

## 🚀 Quick Start

### Prerequisites

- **Python 3.12+**
- **Node.js 18+**
- **Docker Desktop**
- **Ollama** ([ollama.ai](https://ollama.ai))

### Installation

```bash
# 1. Install Ollama and pull the model
ollama pull llama3.2:latest

# 2. Setup backend
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env

# 3. Setup frontend
cd frontend
npm install
cp .env.example .env

# 4. Start Elasticsearch
cd backend
docker-compose up -d
```

### Running the App

```bash
# Start Elasticsearch (if not running)
./start.sh

# Terminal 1 - Backend
cd backend
source venv/bin/activate
uvicorn app:app --reload

# Terminal 2 - Frontend
cd frontend
npm run dev
```

Open [http://localhost:5173](http://localhost:5173)

**📖 Detailed Instructions:** See [START_APP.md](./START_APP.md)
** Project is inspired by https://github.com/AI-Engineer-Skool/local-ai-transcript-app/tree/main ** 

## �️ Architecture

```
Browser (React) → FastAPI → Whisper + Ollama + Elasticsearch
```

**Frontend:** React with MediaRecorder API
**Backend:** FastAPI with async endpoints
**AI Models:** faster-whisper (transcription) + llama3.2 (cleaning)
**Storage:** Elasticsearch for full-text search
**Infrastructure:** Docker (ES only), native AI models

## 📄 License

MIT License - Feel free to use this project however you'd like.
