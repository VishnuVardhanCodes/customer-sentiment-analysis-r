import React from 'react';
import StatusBadge from './StatusBadge';

const ValidationTable = ({ checks }) => {
  if (!checks || checks.length === 0) {
    return (
      <div style={{ textAlign: 'center', padding: '1.5rem', color: '#64748b' }}>
        No validation check records available.
      </div>
    );
  }

  return (
    <div className="table-responsive">
      <table className="saas-table">
        <thead>
          <tr>
            <th style={{ width: '30%' }}>Validation Check</th>
            <th style={{ width: '55%' }}>Verification Result & Findings</th>
            <th style={{ width: '15%', textAlign: 'center' }}>Status</th>
          </tr>
        </thead>
        <tbody>
          {checks.map((c, i) => (
            <tr key={`chk-${i}`}>
              <td style={{ fontWeight: '600' }}>{c.Check}</td>
              <td style={{ color: '#334155' }}>{c.Result}</td>
              <td style={{ textAlign: 'center' }}>
                <StatusBadge status={c.Status} />
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default ValidationTable;
