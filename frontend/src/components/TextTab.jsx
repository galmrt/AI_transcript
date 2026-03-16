import { useState, useEffect } from 'react'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'

function TextTab({ initialText = '' }) {
  const [text, setText] = useState('')
  const [cleanedText, setCleanedText] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  useEffect(() => {
    if (initialText) {
      setText(initialText)
      setCleanedText('')
    }
  }, [initialText])

  const cleanText = async () => {
    if (!text.trim()) {
      setError('Please enter some text to clean')
      return
    }

    setLoading(true)
    setError('')

    try {
      const response = await fetch(`${API_URL}/home/clean_transcript`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text }),
      })

      if (!response.ok) throw new Error('Cleaning failed')

      const data = await response.json()
      setCleanedText(data.cleaned_text)
    } catch (err) {
      setError('Failed to clean text: ' + err.message)
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div>
      <textarea
        placeholder="Paste or type your text here... (e.g., 'Um, like, you know, this is a test')"
        value={text}
        onChange={(e) => setText(e.target.value)}
        rows={6}
      />

      <button 
        className="button button-primary" 
        onClick={cleanText}
        disabled={loading || !text.trim()}
      >
        {loading ? '⏳ Cleaning...' : '✨ Clean Text'}
      </button>

      {error && <div className="error">{error}</div>}

      {cleanedText && (
        <div className="result">
          <h3>✨ Cleaned Text:</h3>
          <p>{cleanedText}</p>
        </div>
      )}
    </div>
  )
}

export default TextTab

