import React from 'react';

const PageHeader = ({ title, subtitle, children }) => {
  return (
    <div className="page-header">
      <div className="page-header-top">
        <div>
          <h1 className="page-title">{title}</h1>
          {subtitle && <p className="page-subtitle">{subtitle}</p>}
        </div>
        {children && <div style={{ display: 'flex', gap: '0.75rem', alignItems: 'center' }}>{children}</div>}
      </div>
    </div>
  );
};

export default PageHeader;
