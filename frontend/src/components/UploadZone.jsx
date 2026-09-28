import React, { useRef, useState } from 'react';
import { Upload, FileText, CheckCircle2 } from 'lucide-react';

const UploadZone = ({ onFileSelected, loading }) => {
  const fileInputRef = useRef(null);
  const [isDragOver, setIsDragOver] = useState(false);

  const handleFileChange = (e) => {
    const file = e.target.files[0];
    if (file) processFile(file);
  };

  const handleDrop = (e) => {
    e.preventDefault();
    setIsDragOver(false);
    const file = e.dataTransfer.files[0];
    if (file) processFile(file);
  };

  const processFile = (file) => {
    const ext = file.name.split('.').pop().toLowerCase();
    if (ext !== 'csv' && ext !== 'txt') {
      alert('Unsupported file format. Please upload a CSV or TXT file.');
      return;
    }

    const reader = new FileReader();
    reader.onload = (event) => {
      onFileSelected(event.target.result, file.name);
    };
    reader.readAsText(file);
  };

  return (
    <div
      onDragOver={(e) => {
        e.preventDefault();
        setIsDragOver(true);
      }}
      onDragLeave={() => setIsDragOver(false)}
      onDrop={handleDrop}
      style={{
        border: `2px dashed ${isDragOver ? '#2563eb' : '#cbd5e1'}`,
        backgroundColor: isDragOver ? '#eff6ff' : '#f8fafc',
        borderRadius: '16px',
        padding: '3rem 2rem',
        textAlign: 'center',
        cursor: 'pointer',
        transition: 'all 0.2s ease',
      }}
      onClick={() => fileInputRef.current?.click()}
    >
      <input
        type="file"
        ref={fileInputRef}
        onChange={handleFileChange}
        accept=".csv,.txt"
        style={{ display: 'none' }}
      />
      <div
        style={{
          width: '64px',
          height: '64px',
          borderRadius: '50%',
          backgroundColor: '#dbeafe',
          color: '#2563eb',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          margin: '0 auto 1.25rem',
        }}
      >
        <Upload size={32} />
      </div>
      <h3 style={{ fontSize: '1.2rem', fontWeight: '700', color: '#0f172a', marginBottom: '0.5rem' }}>
        Drag & Drop Customer Dataset
      </h3>
      <p style={{ fontSize: '0.9rem', color: '#64748b', marginBottom: '1.25rem' }}>
        Import CSV or TXT files containing customer feedback, social media comments or reviews.
      </p>
      <button className="btn btn-primary btn-md" disabled={loading}>
        <FileText size={16} />
        {loading ? 'Processing Upload...' : 'Browse Files'}
      </button>
      <div style={{ marginTop: '1rem', fontSize: '0.78rem', color: '#94a3b8' }}>
        Supported formats: .CSV, .TXT (UTF-8 encoded)
      </div>
    </div>
  );
};

export default UploadZone;
