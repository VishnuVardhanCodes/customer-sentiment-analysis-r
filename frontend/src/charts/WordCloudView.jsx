import React from 'react';

const WordCloudView = ({ data, limit = 40 }) => {
  if (!data || data.length === 0) {
    return (
      <div style={{ textAlign: 'center', padding: '2rem', color: '#64748b' }}>
        No word cloud data available.
      </div>
    );
  }

  const terms = [...data].slice(0, limit);
  const maxFreq = Math.max(...terms.map((t) => Number(t.Frequency || t.n || 1)), 1);
  const minFreq = Math.min(...terms.map((t) => Number(t.Frequency || t.n || 1)), 1);

  const colors = ['#2563eb', '#0d9488', '#16a34a', '#8b5cf6', '#d97706', '#0284c7', '#4f46e5'];

  return (
    <div
      style={{
        display: 'flex',
        flexWrap: 'wrap',
        alignItems: 'center',
        justifyContent: 'center',
        gap: '0.75rem 1.25rem',
        padding: '1.5rem',
        minHeight: '260px',
        backgroundColor: '#fafafa',
        borderRadius: '12px',
        border: '1px dashed #cbd5e1',
      }}
    >
      {terms.map((t, i) => {
        const word = t.Word || t.word || t.Term;
        const freq = Number(t.Frequency || t.n || 1);
        const ratio = maxFreq > minFreq ? (freq - minFreq) / (maxFreq - minFreq) : 0.5;
        const fontSize = 13 + ratio * 24; // 13px to 37px font size scale
        const color = colors[i % colors.length];

        return (
          <span
            key={`wc-${word}-${i}`}
            title={`Term: ${word} (Frequency: ${freq})`}
            style={{
              fontSize: `${fontSize}px`,
              fontWeight: ratio > 0.4 ? '800' : '600',
              color: color,
              cursor: 'pointer',
              transition: 'transform 0.2s ease',
              display: 'inline-block',
            }}
            onMouseEnter={(e) => (e.currentTarget.style.transform = 'scale(1.15)')}
            onMouseLeave={(e) => (e.currentTarget.style.transform = 'scale(1)')}
          >
            {word}
          </span>
        );
      })}
    </div>
  );
};

export default WordCloudView;
