import { useState, useEffect } from 'react'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'

function HistoryTab({ onLoadTranscript }) {
  const [history, setHistory] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [searchQuery, setSearchQuery] = useState('')

  useEffect(() => {
    fetchHistory()
  }, [])

  const fetchHistory = async () => {
    setLoading(true)
    setError(null)
    try {
      const response = await fetch(`${API_URL}/home/history`)
      if (!response.ok) throw new Error('Failed to fetch history')
      const data = await response.json()

      const transcripts = data.hits.hits.map(hit => ({
        id: hit._id,
        title: hit.fields?.title?.[0] || 'Untitled',
        timestamp: hit.fields?.['@timestamp']?.[0] || new Date().toISOString()
      }))

      setHistory(transcripts)
      setSearchQuery('')
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const handleSearch = async () => {
    if (!searchQuery.trim()) {
      fetchHistory()
      return
    }

    setLoading(true)
    setError(null)
    try {
      const response = await fetch(`${API_URL}/home/search?query=${encodeURIComponent(searchQuery)}`, {
        method: 'POST'
      })
      if (!response.ok) throw new Error('Search failed')
      const data = await response.json()

      const transcripts = data.hits.hits.map(hit => ({
        id: hit._id,
        title: hit._source?.title || 'Untitled',
        timestamp: hit._source?.['@timestamp'] || new Date().toISOString()
      }))

      setHistory(transcripts)
    } catch (err) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  const handleLoadTranscript = async (id) => {
    try {
      const response = await fetch(`${API_URL}/home/get_transcript/${id}`)
      if (!response.ok) throw new Error('Failed to load transcript')
      const data = await response.json()

      const cleanedText = data._source?.cleaned_transcript || data._source?.raw_transcript || ''
      onLoadTranscript(cleanedText)
    } catch (err) {
      alert(`Error loading transcript: ${err.message}`)
    }
  }

  return (
    <div className="tab-content">
      <h2>📜 Transcript History</h2>
      <p>Click on any transcript to load it into the Text tab</p>

      <div style={{ display: 'flex', gap: '10px', marginBottom: '20px' }}>
        <input
          type="text"
          placeholder="🔍 Search transcripts..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && handleSearch()}
          style={{ flex: 1 }}
        />
        <button onClick={handleSearch} disabled={loading}>
          {loading ? '⏳' : '🔍 Search'}
        </button>
        <button onClick={fetchHistory} disabled={loading}>
          📜 All
        </button>
      </div>

      {loading && <p>Loading...</p>}
      {error && <p style={{ color: 'red' }}>Error: {error}</p>}

      {!loading && !error && history.length === 0 && (
        <p>No transcripts yet. Start by recording, uploading, or pasting text!</p>
      )}

      {!loading && history.length > 0 && (
        <div className="history-list">
          {history.map(item => (
            <div 
              key={item.id} 
              className="history-item"
              onClick={() => handleLoadTranscript(item.id)}
            >
              <div className="history-title">{item.title}</div>
              <div className="history-timestamp">
                {new Date(item.timestamp).toLocaleString()}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

export default HistoryTab

