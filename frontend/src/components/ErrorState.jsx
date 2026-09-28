import React from 'react';
import { AlertCircle, RefreshCw } from 'lucide-react';

const ErrorState = ({ title = 'Analysis Error', message, onRetry }) => {
  return (
    <div
      style={{
        padding: '1.25rem 1.5rem',
        backgroundColor: '#fef2f2',
        border: '1px solid #fecaca',
        borderRadius: '12px',
        color: '#991b1b',
        display: 'flex',
        alignItems: 'flex-start',
        gap: '1rem',
        margin: '1.25rem 0',
      }}
    >
      <AlertCircle size={24} style={{ flexShrink: 0, marginTop: '2px', color: '#dc2626' }} />
      <div style={{ flex: 1 }}>
        <h4 style={{ fontWeight: '700', fontSize: '0.98rem', marginBottom: '0.25rem', color: '#991b1b' }}>{title}</h4>
        <p style={{ fontSize: '0.88rem', color: '#7f1d1d' }}>{message}</p>
      </div>
      {onRetry && (
        <button className="btn btn-outline btn-sm" onClick={onRetry} style={{ borderColor: '#fecaca', color: '#991b1b' }}>
          <RefreshCw size={14} /> Retry
        </button>
      )}
    </div>
  );
};

export default ErrorState;
