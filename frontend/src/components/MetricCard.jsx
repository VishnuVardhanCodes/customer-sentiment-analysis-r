import React from 'react';

const MetricCard = ({ title, value, subtitle, highlight = false }) => {
  return (
    <div
      style={{
        padding: '1.25rem',
        backgroundColor: highlight ? '#f0fdf4' : '#f8fafc',
        border: `1px solid ${highlight ? '#bbf7d0' : '#e2e8f0'}`,
        borderRadius: '12px',
        textAlign: 'center',
      }}
    >
      <div style={{ fontSize: '0.78rem', fontWeight: '700', color: '#64748b', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
        {title}
      </div>
      <div style={{ fontSize: '1.8rem', fontWeight: '800', color: highlight ? '#16a34a' : '#0f172a', margin: '0.3rem 0' }}>
        {value !== undefined && value !== null ? value : '--'}
      </div>
      {subtitle && <div style={{ fontSize: '0.78rem', color: '#64748b' }}>{subtitle}</div>}
    </div>
  );
};

export default MetricCard;
