# Common Issues & Solutions

## 🔧 Backend Issues

### Issue: "ModuleNotFoundError: No module named 'transformers'"
**Solution:**
```bash
cd backend
uv add transformers torch
uv sync
```

### Issue: Whisper model download is very slow
**Solution:**
- Models are downloaded to `~/.cache/huggingface/`
- First download takes time (150MB-3GB depending on model)
- Subsequent runs use cached model
- Use smaller model for testing: `whisper-tiny` or `whisper-base`

### Issue: "RuntimeError: CUDA out of memory"
**Solution:**
```python
# Force CPU usage instead of GPU
import torch
device = "cpu"  # Instead of "cuda"
pipe = pipeline("automatic-speech-recognition", model=model_name, device=device)
```

### Issue: FastAPI CORS errors
**Solution:**
```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # Add your frontend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Issue: "Connection refused" when calling Ollama
**Solution:**
```bash
# Check if Ollama is running
curl http://localhost:11434/api/tags

# If not running, start Ollama
ollama serve

# Pull the model if not downloaded
ollama pull llama3.1:8b
```

### Issue: LLM responses are very slow
**Solutions:**
1. Use smaller model: `llama3.1:3b` instead of `8b`
2. Increase Docker CPU/RAM allocation
3. Switch to cloud API (OpenAI GPT-4o-mini)
4. Add timeout to prevent hanging:
```python
response = client.chat.completions.create(
    model=model,
    messages=messages,
    timeout=30  # 30 second timeout
)
```

### Issue: File upload fails with large audio files
**Solution:**
```python
# Increase max file size in FastAPI
from fastapi import FastAPI, UploadFile, File

@app.post("/transcribe")
async def transcribe(file: UploadFile = File(..., max_length=50*1024*1024)):  # 50MB
    pass
```

---

## 🎨 Frontend Issues

### Issue: "navigator.mediaDevices is undefined"
**Solution:**
- MediaRecorder API requires HTTPS or localhost
- Make sure you're accessing via `http://localhost:3000` not `http://127.0.0.1:3000`
- Check browser compatibility (Chrome/Firefox recommended)

### Issue: Microphone permission denied
**Solution:**
```typescript
const startRecording = async () => {
  try {
    const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
    // ... rest of code
  } catch (error) {
    if (error.name === 'NotAllowedError') {
      alert('Please allow microphone access in browser settings');
    } else if (error.name === 'NotFoundError') {
      alert('No microphone found. Please connect a microphone.');
    }
  }
};
```

### Issue: Audio recording is silent/empty
**Solution:**
```typescript
// Check if audio track is active
const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
const audioTrack = stream.getAudioTracks()[0];
console.log('Audio track enabled:', audioTrack.enabled);
console.log('Audio track muted:', audioTrack.muted);

// Ensure correct MIME type
const mediaRecorder = new MediaRecorder(stream, {
  mimeType: 'audio/webm;codecs=opus'  // Widely supported
});
```

### Issue: CORS error when calling backend
**Solution:**
```typescript
// vite.config.ts
export default defineConfig({
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
  }
})

// Then use relative URLs in fetch
fetch('/api/transcribe', { ... })
```

### Issue: TypeScript errors with MediaRecorder
**Solution:**
```typescript
// Add type declarations
declare global {
  interface Window {
    MediaRecorder: typeof MediaRecorder;
  }
}

// Or install types
npm install --save-dev @types/dom-mediacapture-record
```

### Issue: Copy to clipboard doesn't work
**Solution:**
```typescript
const copyToClipboard = async (text: string) => {
  try {
    await navigator.clipboard.writeText(text);
    alert('Copied to clipboard!');
  } catch (error) {
    // Fallback for older browsers
    const textarea = document.createElement('textarea');
    textarea.value = text;
    document.body.appendChild(textarea);
    textarea.select();
    document.execCommand('copy');
    document.body.removeChild(textarea);
    alert('Copied to clipboard!');
  }
};
```

---

## 🐳 Docker Issues

### Issue: Docker build fails with "no space left on device"
**Solution:**
```bash
# Clean up Docker
docker system prune -a
docker volume prune

# Check disk space
df -h
```

### Issue: Container can't connect to host services
**Solution:**
```yaml
# docker-compose.yml
services:
  backend:
    network_mode: "host"  # Use host network
    # OR
    extra_hosts:
      - "host.docker.internal:host-gateway"
```

### Issue: Changes not reflected in container
**Solution:**
```yaml
# Ensure volumes are mounted correctly
services:
  backend:
    volumes:
      - ./backend:/app  # Mount source code
      - /app/.venv      # Exclude virtual env
```

### Issue: Ollama not accessible from backend container
**Solution:**
```yaml
# docker-compose.yml
services:
  backend:
    environment:
      - LLM_BASE_URL=http://ollama:11434/v1  # Use service name, not localhost
    depends_on:
      - ollama
  
  ollama:
    image: ollama/ollama:latest
    ports:
      - "11434:11434"
```

---

## 🚀 Deployment Issues

### Issue: Vercel deployment fails for backend
**Solution:**
- Vercel is for frontend only (static sites/serverless)
- Deploy backend separately on Railway, Render, or Fly.io
- Update frontend API URL to point to deployed backend

### Issue: Environment variables not working in production
**Solution:**
```bash
# For Vercel (frontend)
vercel env add LLM_BASE_URL

# For Railway (backend)
# Add in Railway dashboard under Variables tab

# For Render (backend)
# Add in Render dashboard under Environment section
```

### Issue: Cold starts are very slow
**Solution:**
- Free tier services (Render, Railway) spin down after inactivity
- First request after spin-down takes 30-60 seconds
- Solutions:
  1. Upgrade to paid tier (keeps service running)
  2. Use cron job to ping service every 10 minutes
  3. Add loading message: "Waking up server, please wait..."

### Issue: Whisper model download fails in production
**Solution:**
```python
# Pre-download model in Dockerfile
FROM python:3.12

# Install dependencies
RUN pip install transformers torch

# Pre-download model during build
RUN python -c "from transformers import pipeline; pipeline('automatic-speech-recognition', model='openai/whisper-base')"

# Rest of Dockerfile...
```

---

## 🎯 Performance Issues

### Issue: Transcription takes too long
**Solutions:**
1. Use smaller Whisper model (`tiny` or `base`)
2. Use GPU if available
3. Limit audio length (max 5 minutes)
4. Add progress indicator so users know it's working
5. Consider cloud API for production (AssemblyAI, Deepgram)

### Issue: High memory usage
**Solutions:**
```python
# Clear cache after transcription
import gc
import torch

def transcribe_and_cleanup(audio_path):
    result = pipe(audio_path)
    
    # Clear GPU cache if using CUDA
    if torch.cuda.is_available():
        torch.cuda.empty_cache()
    
    # Force garbage collection
    gc.collect()
    
    return result
```

### Issue: Frontend bundle size too large
**Solutions:**
```bash
# Analyze bundle
npm run build
npx vite-bundle-visualizer

# Use code splitting
const HeavyComponent = lazy(() => import('./HeavyComponent'));

# Remove unused dependencies
npm uninstall <unused-package>
```

---

## 🔍 Debugging Tips

### Enable verbose logging
```python
# Backend
import logging
logging.basicConfig(level=logging.DEBUG)

# FastAPI
uvicorn app:app --log-level debug
```

### Test API endpoints with curl
```bash
# Test health endpoint
curl http://localhost:8000/health

# Test transcription with file
curl -X POST http://localhost:8000/transcribe \
  -F "file=@test_audio.wav"
```

### Check browser console
```javascript
// Frontend - add detailed logging
console.log('Recording started');
console.log('Audio blob size:', audioBlob.size);
console.log('API response:', response);
```

### Monitor Docker logs
```bash
# View all logs
docker-compose logs -f

# View specific service
docker-compose logs -f backend

# View last 100 lines
docker-compose logs --tail=100 backend
```

---

## 📞 Getting Help

If you're still stuck:

1. **Check the reference repo**: [local-ai-transcript-app](https://github.com/AI-Engineer-Skool/local-ai-transcript-app)
2. **Search GitHub Issues**: Someone may have had the same problem
3. **Stack Overflow**: Tag with `fastapi`, `whisper`, `react`, etc.
4. **Discord/Slack communities**: FastAPI, React, AI/ML communities
5. **AI assistants**: ChatGPT, Claude, GitHub Copilot can help debug
6. **Create GitHub Issue**: In your repo, document the problem clearly

---

## ✅ Prevention Checklist

Before asking for help, verify:
- [ ] All dependencies installed (`uv sync`, `npm install`)
- [ ] Environment variables set correctly (`.env` file)
- [ ] Services running (backend, frontend, Ollama)
- [ ] Correct ports (3000 for frontend, 8000 for backend)
- [ ] Browser console shows no errors
- [ ] Backend logs show no errors
- [ ] Docker containers running (`docker ps`)
- [ ] Firewall not blocking ports
- [ ] Using supported browser (Chrome/Firefox)
- [ ] Microphone permissions granted

Good luck! 🚀
