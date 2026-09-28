import React from 'react';
import { FileSpreadsheet, Database, AlignLeft, Tag } from 'lucide-react';

const DatasetInfoCard = ({
  metadata,
  textColumn,
  setTextColumn,
  labelColumn,
  setLabelColumn,
  onValidate,
  onReplace,
  onRemove,
  loading,
}) => {
  if (!metadata) return null;

  const formatBytes = (bytes) => {
    if (!bytes) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  const columns = metadata.column_names || [];

  return (
    <div className="saas-card" style={{ marginTop: '1.5rem' }}>
      <div className="card-header-clean">
        <div className="card-title-clean">
          <FileSpreadsheet color="#2563eb" size={20} />
          Loaded Dataset Metadata
        </div>
        <div style={{ display: 'flex', gap: '0.5rem' }}>
          <button className="btn btn-outline btn-sm" onClick={onReplace} disabled={loading}>
            Replace Dataset
          </button>
          <button className="btn btn-danger btn-sm" onClick={onRemove} disabled={loading}>
            Remove
          </button>
        </div>
      </div>

      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(160px, 1fr))',
          gap: '1rem',
          padding: '1rem',
          backgroundColor: '#f8fafc',
          borderRadius: '10px',
          marginBottom: '1.5rem',
          border: '1px solid #e2e8f0',
        }}
      >
        <div>
          <div style={{ fontSize: '0.75rem', color: '#64748b', fontWeight: '600' }}>FILENAME</div>
          <div style={{ fontSize: '0.95rem', fontWeight: '700', color: '#0f172a' }}>{metadata.filename}</div>
        </div>
        <div>
          <div style={{ fontSize: '0.75rem', color: '#64748b', fontWeight: '600' }}>FILE SIZE</div>
          <div style={{ fontSize: '0.95rem', fontWeight: '700', color: '#0f172a' }}>{formatBytes(metadata.file_size)}</div>
        </div>
        <div>
          <div style={{ fontSize: '0.75rem', color: '#64748b', fontWeight: '600' }}>TOTAL ROWS</div>
          <div style={{ fontSize: '0.95rem', fontWeight: '700', color: '#0f172a' }}>{metadata.rows}</div>
        </div>
        <div>
          <div style={{ fontSize: '0.75rem', color: '#64748b', fontWeight: '600' }}>COLUMNS</div>
          <div style={{ fontSize: '0.95rem', fontWeight: '700', color: '#0f172a' }}>{metadata.columns}</div>
        </div>
      </div>

      {/* Target Column Selection Forms */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1.25rem', marginBottom: '1.5rem' }}>
        <div>
          <label style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', fontSize: '0.85rem', fontWeight: '700', color: '#1e293b', marginBottom: '0.5rem' }}>
            <AlignLeft size={16} color="#2563eb" />
            Customer Text Column (Required):
          </label>
          <select
            value={String(textColumn || '')}
            onChange={(e) => setTextColumn(e.target.value)}
            style={{
              width: '100%',
              padding: '0.65rem 0.85rem',
              borderRadius: '8px',
              border: '1px solid #cbd5e1',
              fontSize: '0.9rem',
              backgroundColor: '#ffffff',
            }}
          >
            {columns.map((col) => (
              <option key={`text-${col}`} value={String(col)}>
                {String(col)}
              </option>
            ))}
          </select>
        </div>

        <div>
          <label style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', fontSize: '0.85rem', fontWeight: '700', color: '#1e293b', marginBottom: '0.5rem' }}>
            <Tag size={16} color="#0d9488" />
            Sentiment Ground-Truth Label (Optional):
          </label>
          <select
            value={String(labelColumn || 'none')}
            onChange={(e) => setLabelColumn(e.target.value === 'none' ? '' : e.target.value)}
            style={{
              width: '100%',
              padding: '0.65rem 0.85rem',
              borderRadius: '8px',
              border: '1px solid #cbd5e1',
              fontSize: '0.9rem',
              backgroundColor: '#ffffff',
            }}
          >
            <option value="none">-- None (Unlabeled Dataset) --</option>
            {columns.map((col) => (
              <option key={`label-${col}`} value={String(col)}>
                {String(col)}
              </option>
            ))}
          </select>
        </div>
      </div>

      <button className="btn btn-primary btn-md" onClick={onValidate} disabled={loading} style={{ width: '100%' }}>
        Validate Dataset & Target Columns
      </button>
    </div>
  );
};

export default DatasetInfoCard;
