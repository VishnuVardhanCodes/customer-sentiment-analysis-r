import React from 'react';
import { Download, FileSpreadsheet, FileText, Lock } from 'lucide-react';
import { api } from '../services/api';

const DownloadCard = ({ title, description, format = 'CSV', endpoint, available }) => {
  const handleDownload = () => {
    if (!available) return;
    const url = api.getDownloadUrl(endpoint);
    window.open(url, '_blank');
  };

  return (
    <div className="saas-card" style={{ display: 'flex', flexDirection: 'column', justifyContent: 'space-between', height: '100%' }}>
      <div>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '0.75rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            {format === 'CSV' ? <FileSpreadsheet color="#2563eb" size={20} /> : <FileText color="#0d9488" size={20} />}
            <h4 style={{ fontSize: '1.05rem', fontWeight: '700', color: '#0f172a' }}>{title}</h4>
          </div>
          <span style={{ fontSize: '0.72rem', fontWeight: '700', padding: '0.2rem 0.5rem', borderRadius: '4px', backgroundColor: format === 'CSV' ? '#eff6ff' : '#f0fdf4', color: format === 'CSV' ? '#2563eb' : '#0d9488', fontFamily: 'var(--font-mono)' }}>
            .{format}
          </span>
        </div>
        <p style={{ fontSize: '0.85rem', color: '#64748b', marginBottom: '1.25rem', lineHeight: '1.4' }}>
          {description}
        </p>
      </div>

      <div>
        <button
          className={`btn ${available ? 'btn-primary' : 'btn-outline'} btn-md`}
          onClick={handleDownload}
          disabled={!available}
          style={{ width: '100%' }}
        >
          {available ? (
            <>
              <Download size={16} /> Download {format}
            </>
          ) : (
            <>
              <Lock size={14} /> Run this analysis first
            </>
          )}
        </button>
      </div>
    </div>
  );
};

export default DownloadCard;
