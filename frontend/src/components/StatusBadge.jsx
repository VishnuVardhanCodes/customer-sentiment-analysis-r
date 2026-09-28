import React from 'react';
import { CheckCircle2, AlertTriangle, XCircle, HelpCircle } from 'lucide-react';

const StatusBadge = ({ status }) => {
  const normalized = (status || '').toUpperCase();

  if (normalized === 'PASS' || normalized === 'COMPLETED' || normalized === 'ACTIVE') {
    return (
      <span className="badge badge-pass">
        <CheckCircle2 size={12} /> PASS
      </span>
    );
  }

  if (normalized === 'WARNING' || normalized === 'RUNNING' || normalized === 'TRAINING') {
    return (
      <span className="badge badge-warning">
        <AlertTriangle size={12} /> {normalized}
      </span>
    );
  }

  if (normalized === 'ERROR' || normalized === 'FAILED') {
    return (
      <span className="badge badge-error">
        <XCircle size={12} /> {normalized}
      </span>
    );
  }

  if (normalized === 'UNLABELED' || normalized === 'UNAVAILABLE' || normalized === 'NOT STARTED') {
    return (
      <span className="badge badge-unlabeled">
        <HelpCircle size={12} /> {normalized}
      </span>
    );
  }

  return <span className="badge badge-unlabeled">{status || '--'}</span>;
};

export default StatusBadge;
