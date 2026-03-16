import { useState } from 'react'
import RecordTab from './components/RecordTab'
import UploadTab from './components/UploadTab'
import TextTab from './components/TextTab'
import HistoryTab from './components/HistoryTab'

function App() {
  const [activeTab, setActiveTab] = useState('record')
  const [textToLoad, setTextToLoad] = useState('')

  const handleLoadTranscript = (text) => {
    setTextToLoad(text)
    setActiveTab('text')
  }

  return (
    <div className="app">
      <header className="header">
        <h1>🎙️ AI Transcript App</h1>
        <p>Record, upload, or paste text to transcribe and clean with AI</p>
      </header>

      <div className="card">
        <div className="tabs">
          <button
            className={`tab ${activeTab === 'record' ? 'active' : ''}`}
            onClick={() => setActiveTab('record')}
          >
            🎤 Record Audio
          </button>
          <button
            className={`tab ${activeTab === 'upload' ? 'active' : ''}`}
            onClick={() => setActiveTab('upload')}
          >
            📁 Upload File
          </button>
          <button
            className={`tab ${activeTab === 'text' ? 'active' : ''}`}
            onClick={() => setActiveTab('text')}
          >
            ✏️ Paste Text
          </button>
          <button
            className={`tab ${activeTab === 'history' ? 'active' : ''}`}
            onClick={() => setActiveTab('history')}
          >
            📜 History
          </button>
        </div>

        {activeTab === 'record' && <RecordTab />}
        {activeTab === 'upload' && <UploadTab />}
        {activeTab === 'text' && <TextTab initialText={textToLoad} />}
        {activeTab === 'history' && <HistoryTab onLoadTranscript={handleLoadTranscript} />}
      </div>
    </div>
  )
}

export default App

