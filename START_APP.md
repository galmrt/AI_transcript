# 🚀 How to Start the Transcript App

This guide walks you through starting the application from scratch.

---

## 📋 Prerequisites

Make sure you have these installed:

- **Python 3.12+** - `python3 --version`
- **Node.js 18+** - `node --version`
- **Docker Desktop** - For Elasticsearch
- **Ollama** - For LLM (llama3.2)

---

## 🔧 Step-by-Step Startup

### **1. Start Elasticsearch (Docker)**

```bash
# Navigate to backend directory
cd backend

# Start Elasticsearch and Kibana
docker-compose up -d

# Verify it's running
curl http://localhost:9200
# Should return: {"name":"...", "version":{"number":"8.11.0"}}

# Optional: Check Kibana at http://localhost:5601
```

**Wait ~30 seconds** for Elasticsearch to fully start.

---

### **2. Start Ollama & Pull Model**

```bash
# Start Ollama service (if not already running)
ollama serve

# In a new terminal, pull the model
ollama pull llama3.2:latest

# Verify it's running
curl http://localhost:11434/v1/models
```

---

### **3. Start Backend (FastAPI)**

```bash
# Navigate to backend directory (if not already there)
cd backend

# Create virtual environment (first time only)
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate  # macOS/Linux
# OR
venv\Scripts\activate     # Windows

# Install dependencies (first time only)
pip install -r requirements.txt

# Copy environment file (first time only)
cp .env.example .env
# Edit .env if needed (default values should work)

# Start the backend server
uvicorn app:app --reload

# You should see:
# Starting up...
# Transcription service initialized
# ✅ LLM connection successful
# ✅ Connected to Elasticsearch 8.11.0
# ✅ Index transcripts already exists
```

Backend runs at: **http://localhost:8000**

---

### **4. Start Frontend (React)**

```bash
# Open a NEW terminal
cd frontend

# Install dependencies (first time only)
npm install

# Copy environment file (first time only)
cp .env.example .env
# Edit .env if needed (default values should work)

# Start the development server
npm run dev

# You should see:
# VITE v5.x.x  ready in xxx ms
# ➜  Local:   http://localhost:5173/
```

Frontend runs at: **http://localhost:5173**

---

## ✅ Verify Everything is Running

Open these URLs in your browser:

1. **Frontend**: http://localhost:5173 - Main app
2. **Backend**: http://localhost:8000/docs - API documentation
3. **Elasticsearch**: http://localhost:9200 - ES info
4. **Kibana** (optional): http://localhost:5601 - ES dashboard

---

## 🛑 How to Stop Everything

### **Stop Frontend:**
```bash
# In the frontend terminal
Ctrl + C
```

### **Stop Backend:**
```bash
# In the backend terminal
Ctrl + C

# Deactivate virtual environment
deactivate
```

### **Stop Elasticsearch:**
```bash
cd backend
docker-compose down

# To also remove data (fresh start):
docker-compose down -v
```

### **Stop Ollama:**
```bash
# In the Ollama terminal
Ctrl + C
```

---

## 🔄 Quick Restart (After First Setup)

```bash
# Terminal 1: Elasticsearch
cd backend && docker-compose up -d

# Terminal 2: Ollama (if not running as service)
ollama serve

# Terminal 3: Backend
cd backend && source venv/bin/activate && uvicorn app:app --reload

# Terminal 4: Frontend
cd frontend && npm run dev
```

---

## 🐛 Troubleshooting

### **Elasticsearch won't start:**
```bash
# Check if port 9200 is already in use
lsof -i :9200

# Remove old containers
docker-compose down -v
docker-compose up -d
```

### **Backend can't connect to Elasticsearch:**
```bash
# Wait 30 seconds after starting docker-compose
# Check ES is ready:
curl http://localhost:9200/_cluster/health
```

### **Ollama model not found:**
```bash
# Pull the model again
ollama pull llama3.2:latest

# List installed models
ollama list
```

### **Frontend can't connect to backend:**
```bash
# Check backend is running at http://localhost:8000
# Check frontend/.env has correct VITE_API_URL
```

---

## 📝 Development Workflow

```bash
# Day-to-day development:
1. docker-compose up -d          # Start ES (once)
2. ollama serve                  # Start Ollama (if needed)
3. uvicorn app:app --reload      # Backend (auto-reloads on changes)
4. npm run dev                   # Frontend (auto-reloads on changes)

# Make changes to code → See updates instantly!
```

---

## 🎯 First Time Using the App

1. Go to http://localhost:5173
2. Try the **📁 Upload File** tab
3. Upload an audio file (mp3, wav, webm)
4. Wait for transcription + cleaning
5. Check **📜 History** tab to see saved transcripts
6. Click any transcript to load it into **✏️ Paste Text** tab

---

## 💡 Tips

- **Backend logs** show all API calls and ES operations
- **Frontend** auto-reloads when you edit React components
- **Elasticsearch data** persists in Docker volume (survives restarts)
- **Use Kibana** to inspect/debug Elasticsearch data
- **Ollama** can run as a background service (no need for separate terminal)

---

## 🆘 Need Help?

Check these files:
- `QUICK_START_CHECKLIST.md` - Quick reference
- `COMMON_ISSUES.md` - Known issues and fixes
- `TECHNOLOGY_CHOICES.md` - Why we chose each technology

