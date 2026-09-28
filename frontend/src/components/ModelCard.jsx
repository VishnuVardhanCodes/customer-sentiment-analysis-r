import React from 'react';
import { Brain, Play, CheckCircle2, Loader2, AlertCircle } from 'lucide-react';
import StatusBadge from './StatusBadge';

const ModelCard = ({ title, description, algorithm, onRun, status = 'Not Run', metrics, loading, disabled }) => {
  return (
    <div className="saas-card" style={{ height: '100%', display: 'flex', flexDirection: 'column', justify: 'space-between' }}>
      <div>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
            <div style={{ width: '38px', height: '38px', borderRadius: '8px', backgroundColor: '#eff6ff', color: '#2563eb', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Brain size={20} />
            </div>
            <div>
              <h3 style={{ fontSize: '1.05rem', fontWeight: '700', color: '#0f172a' }}>{title}</h3>
              <span style={{ fontSize: '0.75rem', color: '#64748b', fontFamily: 'var(--font-mono)' }}>{algorithm}</span>
            </div>
          </div>
          <StatusBadge status={status} />
        </div>

        <p style={{ fontSize: '0.88rem', color: '#475569', marginBottom: '1.25rem', lineHeight: '1.5' }}>
          {description}
        </p>

        {metrics && (
          <div
            style={{
              display: 'grid',
              gridTemplateColumns: '1fr 1fr',
              gap: '0.6rem',
              padding: '0.85rem',
              backgroundColor: '#f8fafc',
              borderRadius: '8px',
              border: '1px solid #e2e8f0',
              marginBottom: '1.25rem',
            }}
          >
            <div>
              <div style={{ fontSize: '0.7rem', color: '#64748b', fontWeight: '600' }}>ACCURACY</div>
              <div style={{ fontSize: '1.1rem', fontWeight: '800', color: '#16a34a' }}>
                {(metrics.Accuracy * 100).toFixed(1)}%
              </div>
            </div>
            <div>
              <div style={{ fontSize: '0.7rem', color: '#64748b', fontWeight: '600' }}>F1 SCORE</div>
              <div style={{ fontSize: '1.1rem', fontWeight: '800', color: '#2563eb' }}>
                {(metrics.F1_Score * 100).toFixed(1)}%
              </div>
            </div>
            <div>
              <div style={{ fontSize: '0.7rem', color: '#64748b', fontWeight: '600' }}>PRECISION</div>
              <div style={{ fontSize: '0.9rem', fontWeight: '700', color: '#334155' }}>
                {(metrics.Precision * 100).toFixed(1)}%
              </div>
            </div>
            <div>
              <div style={{ fontSize: '0.7rem', color: '#64748b', fontWeight: '600' }}>RECALL</div>
              <div style={{ fontSize: '0.9rem', fontWeight: '700', color: '#334155' }}>
                {(metrics.Recall * 100).toFixed(1)}%
              </div>
            </div>
          </div>
        )}
      </div>

      <button
        className="btn btn-primary btn-md"
        onClick={onRun}
        disabled={loading || disabled}
        style={{ width: '100%', marginTop: '1rem' }}
      >
        {loading ? (
          <>
            <Loader2 size={16} className="spin-animation" style={{ animation: 'spin 1s linear infinite' }} />
            Training Model...
          </>
        ) : (
          <>
            <Play size={16} /> Run {title}
          </>
        )}
      </button>
    </div>
  );
};

export default ModelCard;
