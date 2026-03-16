import { useState, useRef } from 'react'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'

function RecordTab() {
  const [isRecording, setIsRecording] = useState(false)
  const [audioBlob, setAudioBlob] = useState(null)
  const [transcript, setTranscript] = useState('')
  const [cleanedText, setCleanedText] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const mediaRecorderRef = useRef(null)
  const chunksRef = useRef([])

  const startRecording = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      const mediaRecorder = new MediaRecorder(stream)
      mediaRecorderRef.current = mediaRecorder
      chunksRef.current = []

      mediaRecorder.ondataavailable = (e) => {
        if (e.data.size > 0) {
          chunksRef.current.push(e.data)
        }
      }

      mediaRecorder.onstop = () => {
        const blob = new Blob(chunksRef.current, { type: 'audio/webm' })
        setAudioBlob(blob)
        stream.getTracks().forEach(track => track.stop())
      }

      mediaRecorder.start()
      setIsRecording(true)
      setError('')
    } catch (err) {
      setError('Failed to access microphone. Please allow microphone access.')
      console.error(err)
    }
  }

  const stopRecording = () => {
    if (mediaRecorderRef.current && isRecording) {
      mediaRecorderRef.current.stop()
      setIsRecording(false)
    }
  }

  const transcribeAudio = async () => {
    if (!audioBlob) return

    setLoading(true)
    setError('')
    
    const formData = new FormData()
    formData.append('audio', audioBlob, 'recording.webm')

    try {
      const response = await fetch(`${API_URL}/home/transcribe_audio`, {
        method: 'POST',
        body: formData,
      })

      if (!response.ok) throw new Error('Transcription failed')

      const data = await response.json()
      setTranscript(data.transcript)
      await cleanTranscript(data.transcript, 'recording.webm', 'record')
    } catch (err) {
      setError('Failed to transcribe audio: ' + err.message)
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  const cleanTranscript = async (text, audioFilename = null, inputType = 'record') => {
    try {
      const response = await fetch(`${API_URL}/home/clean_transcript`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          text,
          audio_filename: audioFilename,
          input_type: inputType
        }),
      })

      if (!response.ok) throw new Error('Cleaning failed')

      const data = await response.json()
      setCleanedText(data.cleaned_text)
    } catch (err) {
      setError('Failed to clean transcript: ' + err.message)
      console.error(err)
    }
  }

  return (
    <div>
      <div style={{ marginBottom: '20px' }}>
        {!isRecording && !audioBlob && (
          <button className="button button-primary" onClick={startRecording}>
            🎤 Start Recording
          </button>
        )}
        
        {isRecording && (
          <button className="button button-danger" onClick={stopRecording}>
            ⏹️ Stop Recording
          </button>
        )}
        
        {audioBlob && !isRecording && (
          <div>
            <p style={{ marginBottom: '15px', color: '#666' }}>
              ✅ Recording complete! Ready to transcribe.
            </p>
            <button
              className="button button-primary"
              onClick={transcribeAudio}
              disabled={loading}
            >
              {loading ? '⏳ Processing...' : '🚀 Transcribe & Clean'}
            </button>
            <button
              className="button"
              onClick={() => { setAudioBlob(null); setTranscript(''); setCleanedText(''); }}
              style={{ marginLeft: '10px', background: '#6b7280', color: 'white' }}
            >
              🔄 Record Again
            </button>
          </div>
        )}
      </div>

      {error && <div className="error">{error}</div>}

      {transcript && (
        <div className="result">
          <h3>📝 Raw Transcript:</h3>
          <p>{transcript}</p>
        </div>
      )}

      {cleanedText && (
        <div className="result">
          <h3>✨ Cleaned Transcript:</h3>
          <p>{cleanedText}</p>
        </div>
      )}
    </div>
  )
}

export default RecordTab

