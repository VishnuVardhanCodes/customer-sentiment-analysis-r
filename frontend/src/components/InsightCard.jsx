import React from 'react';
import { Lightbulb, CheckCircle, AlertTriangle, ArrowRight } from 'lucide-react';

const InsightCard = ({ title, evidence, recommendation, type = 'general' }) => {
  const getBadgeStyle = () => {
    switch (type) {
      case 'praise':
        return { bg: '#f0fdf4', border: '#bbf7d0', color: '#16a34a', icon: CheckCircle };
      case 'complaint':
        return { bg: '#fef2f2', border: '#fecaca', color: '#dc2626', icon: AlertTriangle };
      default:
        return { bg: '#f0f9ff', border: '#bae6fd', color: '#0284c7', icon: Lightbulb };
    }
  };

  const style = getBadgeStyle();
  const Icon = style.icon;

  return (
    <div className="saas-card" style={{ marginBottom: '1.25rem', borderLeft: `4px solid ${style.color}` }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem', marginBottom: '0.75rem' }}>
        <div style={{ padding: '0.4rem', borderRadius: '6px', backgroundColor: style.bg, color: style.color }}>
          <Icon size={18} />
        </div>
        <h4 style={{ fontSize: '1rem', fontWeight: '700', color: '#0f172a' }}>{title}</h4>
      </div>

      {evidence && (
        <div style={{ marginBottom: '0.85rem' }}>
          <div style={{ fontSize: '0.75rem', fontWeight: '700', color: '#64748b', textTransform: 'uppercase', marginBottom: '0.2rem' }}>
            EVIDENCE & EXTRACTED TERMS
          </div>
          <div style={{ fontSize: '0.88rem', color: '#334155', fontStyle: 'italic', backgroundColor: '#f8fafc', padding: '0.6rem 0.85rem', borderRadius: '6px' }}>
            {Array.isArray(evidence) ? evidence.join(', ') : evidence}
          </div>
        </div>
      )}

      {recommendation && (
        <div>
          <div style={{ fontSize: '0.75rem', fontWeight: '700', color: '#64748b', textTransform: 'uppercase', marginBottom: '0.2rem', display: 'flex', alignItems: 'center', gap: '0.3rem' }}>
            <ArrowRight size={12} color={style.color} /> STRATEGIC RECOMMENDATION
          </div>
          <div style={{ fontSize: '0.9rem', fontWeight: '600', color: '#0f172a', lineHeight: '1.5' }}>
            {recommendation}
          </div>
        </div>
      )}
    </div>
  );
};

export default InsightCard;
