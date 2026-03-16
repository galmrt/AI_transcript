import { useState } from 'react'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'

function UploadTab() {
  const [file, setFile] = useState(null)
  const [transcript, setTranscript] = useState('')
  const [cleanedText, setCleanedText] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const handleFileChange = (e) => {
    const selectedFile = e.target.files[0]
    if (selectedFile) {
      setFile(selectedFile)
      setTranscript('')
      setCleanedText('')
      setError('')
    }
  }

  const transcribeFile = async () => {
    if (!file) return

    setLoading(true)
    setError('')
    
    const formData = new FormData()
    formData.append('audio', file)

    try {
      const response = await fetch(`${API_URL}/home/transcribe_audio`, {
        method: 'POST',
        body: formData,
      })

      if (!response.ok) throw new Error('Transcription failed')

      const data = await response.json()
      setTranscript(data.transcript)
      await cleanTranscript(data.transcript, file.name, 'upload')
    } catch (err) {
      setError('Failed to transcribe audio: ' + err.message)
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  const cleanTranscript = async (text, audioFilename = null, inputType = 'upload') => {
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
        <input
          type="file"
          id="audio-file"
          className="file-input"
          accept="audio/*"
          onChange={handleFileChange}
        />
        <label htmlFor="audio-file" className="file-label">
          📁 Choose Audio File
        </label>
        
        {file && (
          <div style={{ marginTop: '15px' }}>
            <p style={{ marginBottom: '10px' }}>
              Selected: <strong>{file.name}</strong> ({(file.size / 1024 / 1024).toFixed(2)} MB)
            </p>
            <button 
              className="button button-primary" 
              onClick={transcribeFile}
              disabled={loading}
            >
              {loading ? '⏳ Processing...' : '🚀 Transcribe & Clean'}
            </button>
            <button 
              className="button" 
              onClick={() => { setFile(null); setTranscript(''); setCleanedText(''); }}
              style={{ marginLeft: '10px', background: '#6b7280', color: 'white' }}
            >
              🔄 Choose Another File
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

export default UploadTab

