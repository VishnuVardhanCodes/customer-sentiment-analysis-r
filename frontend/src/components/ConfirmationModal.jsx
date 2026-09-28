import React from 'react';
import { AlertTriangle } from 'lucide-react';

const ConfirmationModal = ({ title, message, confirmText = 'Confirm', onConfirm, onCancel }) => {
  return (
    <div className="modal-overlay" onClick={onCancel}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '1rem', color: '#dc2626' }}>
          <div style={{ padding: '0.5rem', borderRadius: '50%', backgroundColor: '#fef2f2' }}>
            <AlertTriangle size={24} />
          </div>
          <h3 style={{ fontSize: '1.2rem', fontWeight: '700', color: '#0f172a' }}>{title}</h3>
        </div>

        <p style={{ fontSize: '0.9rem', color: '#475569', marginBottom: '1.5rem', lineHeight: '1.5' }}>
          {message}
        </p>

        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '0.75rem' }}>
          <button className="btn btn-outline btn-md" onClick={onCancel}>
            Cancel
          </button>
          <button className="btn btn-danger btn-md" onClick={onConfirm}>
            {confirmText}
          </button>
        </div>
      </div>
    </div>
  );
};

export default ConfirmationModal;
