import React from 'react';
import { useAnalysis } from '../context/AnalysisContext';
import { CheckCircle2, AlertCircle, AlertTriangle, X } from 'lucide-react';

const ToastNotification = () => {
  const { toasts, removeToast } = useAnalysis();

  if (toasts.length === 0) return null;

  return (
    <div className="toast-container">
      {toasts.map((toast) => {
        const isSuccess = toast.type === 'success';
        const isError = toast.type === 'error';
        const isWarning = toast.type === 'warning';

        return (
          <div key={toast.id} className={`toast toast-${toast.type}`}>
            {isSuccess && <CheckCircle2 size={18} color="#16a34a" />}
            {isError && <AlertCircle size={18} color="#dc2626" />}
            {isWarning && <AlertTriangle size={18} color="#d97706" />}
            {!isSuccess && !isError && !isWarning && <CheckCircle2 size={18} color="#2563eb" />}

            <span style={{ flex: 1, color: '#0f172a' }}>{toast.message}</span>

            <button
              onClick={() => removeToast(toast.id)}
              style={{ background: 'none', border: 'none', color: '#94a3b8', cursor: 'pointer', padding: '2px' }}
            >
              <X size={14} />
            </button>
          </div>
        );
      })}
    </div>
  );
};

export default ToastNotification;
