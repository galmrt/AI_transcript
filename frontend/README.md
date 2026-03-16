# AI Transcript Frontend

Simple React frontend for the AI Transcript application.

## Features

- 🎤 **Record Audio** - Record directly from your microphone using MediaRecorder API
- 📁 **Upload Files** - Upload audio files (wav, mp3, webm, m4a, etc.)
- ✏️ **Paste Text** - Directly input text for cleaning

## Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Start the development server:**
   ```bash
   npm run dev
   ```

3. **Open in browser:**
   ```
   http://localhost:3000
   ```

## Requirements

- Node.js 18+ 
- Backend API running on `http://localhost:8000`

## Usage

### Record Audio
1. Click "Record Audio" tab
2. Click "Start Recording" and allow microphone access
3. Speak into your microphone
4. Click "Stop Recording"
5. Click "Transcribe & Clean" to process

### Upload File
1. Click "Upload File" tab
2. Click "Choose Audio File"
3. Select an audio file from your computer
4. Click "Transcribe & Clean" to process

### Paste Text
1. Click "Paste Text" tab
2. Type or paste text into the textarea
3. Click "Clean Text" to remove filler words and fix grammar

## Tech Stack

- React 18
- Vite (build tool)
- Vanilla CSS (no frameworks)
- MediaRecorder API (for recording)
- Fetch API (for backend communication)

