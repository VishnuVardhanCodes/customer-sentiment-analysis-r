import React, { useState } from 'react';
import { useAnalysis } from '../context/AnalysisContext';
import { RefreshCw, Server, AlertTriangle } from 'lucide-react';
import ConfirmationModal from './ConfirmationModal';

const TopNavbar = () => {
  const { apiConnected, checkApiHealth, pipelineStatus, resetAll, datasetMetadata } = useAnalysis();
  const [showResetModal, setShowResetModal] = useState(false);

  const isDatasetLoaded = pipelineStatus.uploaded;

  return (
    <header className="top-navbar">
      <div className="navbar-title">
        <span className="nav-academic-title">LG9 Analytics</span>
        <span className="nav-academic-sub">Customer Sentiment Analysis</span>
      </div>

      <div className="navbar-right">
        {/* API Server Connection Indicator */}
        <div
          className={`api-status-badge ${apiConnected ? 'connected' : 'disconnected'}`}
          title={apiConnected ? 'R Plumber API Active' : 'R API Disconnected'}
        >
          <Server size={14} />
          <span>{apiConnected ? 'R API Active' : 'API Offline'}</span>
          {!apiConnected && (
            <button
              onClick={checkApiHealth}
              style={{ background: 'none', border: 'none', color: 'inherit', cursor: 'pointer', paddingLeft: '4px' }}
              title="Retry connection"
            >
              <RefreshCw size={12} />
            </button>
          )}
        </div>

        {/* Dynamic Dataset Status Pill */}
        <div className={`dataset-status-pill ${isDatasetLoaded ? 'loaded' : 'empty'}`}>
          <span className={`status-dot ${isDatasetLoaded ? 'active' : 'inactive'}`}></span>
          <span>
            {isDatasetLoaded
              ? `● Dataset Loaded (${datasetMetadata?.filename || 'File Active'})`
              : '○ No Dataset'}
          </span>
        </div>

        {/* Reset Analysis Button */}
        <button
          className="btn btn-outline btn-sm"
          onClick={() => setShowResetModal(true)}
          title="Reset current analysis session"
        >
          <RefreshCw size={14} />
          <span>Reset Analysis</span>
        </button>
      </div>

      {showResetModal && (
        <ConfirmationModal
          title="Reset Current Analysis?"
          message="Are you sure you want to reset all dataset upload, preprocessing, sentiment results, machine learning models, and insights?"
          confirmText="Reset Analysis"
          onConfirm={() => {
            resetAll();
            setShowResetModal(false);
          }}
          onCancel={() => setShowResetModal(false)}
        />
      )}
    </header>
  );
};

export default TopNavbar;
