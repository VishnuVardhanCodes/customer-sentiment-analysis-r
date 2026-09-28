import React from 'react';
import { Loader2 } from 'lucide-react';

const LoadingState = ({ message = 'Processing analysis in R...' }) => {
  return (
    <div
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '3rem 2rem',
        textAlign: 'center',
        backgroundColor: '#ffffff',
        borderRadius: '16px',
        border: '1px solid #e2e8f0',
        margin: '1.5rem 0',
      }}
    >
      <Loader2 size={36} color="#2563eb" className="spin-animation" style={{ animation: 'spin 1s linear infinite' }} />
      <style>{`
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      `}</style>
      <h3 style={{ fontSize: '1.05rem', fontWeight: '700', color: '#0f172a', marginTop: '1rem', marginBottom: '0.25rem' }}>
        {message}
      </h3>
      <p style={{ fontSize: '0.82rem', color: '#64748b' }}>
        Executing R text mining algorithms & statistical routines.
      </p>
    </div>
  );
};

export default LoadingState;
