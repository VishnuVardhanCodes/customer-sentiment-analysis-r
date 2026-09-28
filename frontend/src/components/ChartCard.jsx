import React from 'react';

const ChartCard = ({ title, subtitle, children, action }) => {
  return (
    <div className="saas-card" style={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      <div className="card-header-clean">
        <div>
          <h3 className="card-title-clean">{title}</h3>
          {subtitle && <p className="card-subtitle-clean">{subtitle}</p>}
        </div>
        {action && <div>{action}</div>}
      </div>
      <div style={{ flex: 1, minHeight: '260px', display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
        {children}
      </div>
    </div>
  );
};

export default ChartCard;
