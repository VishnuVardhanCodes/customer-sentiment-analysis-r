import React from 'react';

const KpiCard = ({ label, value, icon: Icon, variant = 'primary', subtext }) => {
  const displayVal = value !== undefined && value !== null && value !== '' ? value : '--';

  return (
    <div className={`kpi-card kpi-${variant}`}>
      <div>
        <div className="kpi-label">{label}</div>
        <div className="kpi-val">{displayVal}</div>
        {subtext && <div style={{ fontSize: '0.78rem', color: '#64748b', marginTop: '0.25rem' }}>{subtext}</div>}
      </div>
      {Icon && (
        <div className="kpi-icon-wrapper">
          <Icon size={22} />
        </div>
      )}
    </div>
  );
};

export default KpiCard;
