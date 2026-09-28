import React from 'react';
import { Database, ArrowRight } from 'lucide-react';

const EmptyState = ({ title, description, actionText, onAction, icon: Icon = Database }) => {
  return (
    <div
      style={{
        padding: '3rem 2rem',
        textAlign: 'center',
        backgroundColor: '#ffffff',
        border: '1px dashed #cbd5e1',
        borderRadius: '16px',
        margin: '1.5rem 0',
      }}
    >
      <div
        style={{
          width: '56px',
          height: '56px',
          borderRadius: '50%',
          backgroundColor: '#f1f5f9',
          color: '#64748b',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          margin: '0 auto 1.25rem',
        }}
      >
        <Icon size={28} />
      </div>
      <h3 style={{ fontSize: '1.15rem', fontWeight: '700', color: '#0f172a', marginBottom: '0.4rem' }}>{title}</h3>
      <p style={{ fontSize: '0.88rem', color: '#64748b', maxWidth: '420px', margin: '0 auto 1.5rem' }}>
        {description}
      </p>
      {actionText && onAction && (
        <button className="btn btn-primary btn-md" onClick={onAction}>
          {actionText} <ArrowRight size={16} />
        </button>
      )}
    </div>
  );
};

export default EmptyState;
