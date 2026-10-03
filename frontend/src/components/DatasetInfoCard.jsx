import React from 'react';
import { FileSpreadsheet, AlignLeft, Tag, Package, Folder, Star } from 'lucide-react';

const DatasetInfoCard = ({
  metadata,
  textColumn,
  setTextColumn,
  labelColumn,
  setLabelColumn,
  productColumn,
  setProductColumn,
  categoryColumn,
  setCategoryColumn,
  ratingColumn,
  setRatingColumn,
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
          Loaded Dataset Metadata & Column Mapping
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
      <div style={{ marginBottom: '1.5rem' }}>
        <h4 style={{ fontSize: '0.92rem', fontWeight: '700', color: '#0f172a', marginBottom: '0.85rem' }}>
          Configure Column Roles for Text Mining & Analytics:
        </h4>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '1rem' }}>
          {/* Required Text Column */}
          <div>
            <label style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', fontSize: '0.84rem', fontWeight: '700', color: '#1e293b', marginBottom: '0.4rem' }}>
              <AlignLeft size={15} color="#2563eb" />
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
                fontSize: '0.88rem',
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

          {/* Optional Label Column */}
          <div>
            <label style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', fontSize: '0.84rem', fontWeight: '700', color: '#1e293b', marginBottom: '0.4rem' }}>
              <Tag size={15} color="#0d9488" />
              Sentiment Label (Optional - for ML):
            </label>
            <select
              value={String(labelColumn || 'none')}
              onChange={(e) => setLabelColumn(e.target.value === 'none' ? '' : e.target.value)}
              style={{
                width: '100%',
                padding: '0.65rem 0.85rem',
                borderRadius: '8px',
                border: '1px solid #cbd5e1',
                fontSize: '0.88rem',
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

          {/* Optional Product Name Column */}
          <div>
            <label style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', fontSize: '0.84rem', fontWeight: '700', color: '#1e293b', marginBottom: '0.4rem' }}>
              <Package size={15} color="#8b5cf6" />
              Product Name (Optional):
            </label>
            <select
              value={String(productColumn || 'none')}
              onChange={(e) => setProductColumn(e.target.value === 'none' ? '' : e.target.value)}
              style={{
                width: '100%',
                padding: '0.65rem 0.85rem',
                borderRadius: '8px',
                border: '1px solid #cbd5e1',
                fontSize: '0.88rem',
                backgroundColor: '#ffffff',
              }}
            >
              <option value="none">-- None (Generic Reviews) --</option>
              {columns.map((col) => (
                <option key={`product-${col}`} value={String(col)}>
                  {String(col)}
                </option>
              ))}
            </select>
          </div>

          {/* Optional Category Column */}
          <div>
            <label style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', fontSize: '0.84rem', fontWeight: '700', color: '#1e293b', marginBottom: '0.4rem' }}>
              <Folder size={15} color="#f59e0b" />
              Product Category (Optional):
            </label>
            <select
              value={String(categoryColumn || 'none')}
              onChange={(e) => setCategoryColumn(e.target.value === 'none' ? '' : e.target.value)}
              style={{
                width: '100%',
                padding: '0.65rem 0.85rem',
                borderRadius: '8px',
                border: '1px solid #cbd5e1',
                fontSize: '0.88rem',
                backgroundColor: '#ffffff',
              }}
            >
              <option value="none">-- None (Uncategorized) --</option>
              {columns.map((col) => (
                <option key={`category-${col}`} value={String(col)}>
                  {String(col)}
                </option>
              ))}
            </select>
          </div>

          {/* Optional Rating Column */}
          <div>
            <label style={{ display: 'flex', alignItems: 'center', gap: '0.4rem', fontSize: '0.84rem', fontWeight: '700', color: '#1e293b', marginBottom: '0.4rem' }}>
              <Star size={15} color="#eab308" />
              Customer Rating (Optional):
            </label>
            <select
              value={String(ratingColumn || 'none')}
              onChange={(e) => setRatingColumn(e.target.value === 'none' ? '' : e.target.value)}
              style={{
                width: '100%',
                padding: '0.65rem 0.85rem',
                borderRadius: '8px',
                border: '1px solid #cbd5e1',
                fontSize: '0.88rem',
                backgroundColor: '#ffffff',
              }}
            >
              <option value="none">-- None (No Numeric Rating) --</option>
              {columns.map((col) => (
                <option key={`rating-${col}`} value={String(col)}>
                  {String(col)}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>

      <button className="btn btn-primary btn-md" onClick={onValidate} disabled={loading} style={{ width: '100%' }}>
        Validate Dataset & Target Columns
      </button>
    </div>
  );
};

export default DatasetInfoCard;

