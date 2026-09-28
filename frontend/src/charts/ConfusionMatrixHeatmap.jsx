import React from 'react';

const ConfusionMatrixHeatmap = ({ cmData, modelName = 'Model' }) => {
  if (!cmData || cmData.length === 0) {
    return (
      <div style={{ textAlign: 'center', padding: '2rem', color: '#64748b' }}>
        No confusion matrix available for {modelName}.
      </div>
    );
  }

  // Extract classes
  const classes = Array.from(
    new Set(cmData.map((d) => d.Actual || d.actual).concat(cmData.map((d) => d.Predicted || d.predicted)))
  );

  const getFreq = (actual, predicted) => {
    const found = cmData.find(
      (d) => (d.Actual || d.actual) === actual && (d.Predicted || d.predicted) === predicted
    );
    return found ? Number(found.Freq || found.freq || found.n || 0) : 0;
  };

  const maxFreq = Math.max(...cmData.map((d) => Number(d.Freq || d.freq || 0)), 1);

  return (
    <div style={{ width: '100%', overflowX: 'auto' }}>
      <h4 style={{ fontSize: '0.95rem', fontWeight: '700', color: '#0f172a', marginBottom: '0.75rem', textAlign: 'center' }}>
        Confusion Matrix — {modelName}
      </h4>
      <div style={{ display: 'grid', gridTemplateColumns: `100px repeat(${classes.length}, 1fr)`, gap: '4px', maxWidth: '420px', margin: '0 auto' }}>
        {/* Header row */}
        <div style={{ padding: '8px', fontSize: '0.75rem', fontWeight: '700', color: '#64748b', textTransform: 'uppercase' }}>
          Actual \ Pred
        </div>
        {classes.map((c) => (
          <div key={`head-${c}`} style={{ padding: '8px', fontSize: '0.8rem', fontWeight: '700', color: '#1e293b', textAlign: 'center', background: '#f8fafc', borderRadius: '4px' }}>
            {c}
          </div>
        ))}

        {/* Matrix rows */}
        {classes.map((actualCls) => (
          <React.Fragment key={`row-${actualCls}`}>
            <div style={{ padding: '8px', fontSize: '0.8rem', fontWeight: '700', color: '#1e293b', display: 'flex', alignItems: 'center', background: '#f8fafc', borderRadius: '4px' }}>
              {actualCls}
            </div>
            {classes.map((predCls) => {
              const freq = getFreq(actualCls, predCls);
              const isMatch = actualCls === predCls;
              const intensity = Math.min(1, freq / maxFreq);
              const bgColor = isMatch
                ? `rgba(22, 163, 74, ${0.15 + intensity * 0.85})`
                : freq > 0
                ? `rgba(220, 38, 38, ${0.15 + intensity * 0.6})`
                : '#f1f5f9';

              const textColor = isMatch && intensity > 0.4 ? '#ffffff' : '#0f172a';

              return (
                <div
                  key={`cell-${actualCls}-${predCls}`}
                  style={{
                    padding: '16px 8px',
                    textAlign: 'center',
                    fontWeight: '800',
                    fontSize: '1.1rem',
                    borderRadius: '6px',
                    backgroundColor: bgColor,
                    color: textColor,
                    boxShadow: isMatch ? '0 2px 4px rgba(0,0,0,0.05)' : 'none',
                  }}
                >
                  {freq}
                </div>
              );
            })}
          </React.Fragment>
        ))}
      </div>
    </div>
  );
};

export default ConfusionMatrixHeatmap;
