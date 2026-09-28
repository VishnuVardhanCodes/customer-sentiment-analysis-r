import React, { useState } from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from '../components/Sidebar';
import TopNavbar from '../components/TopNavbar';
import ToastNotification from '../components/ToastNotification';
import { useAnalysis } from '../context/AnalysisContext';
import { AlertCircle, RefreshCw } from 'lucide-react';

const MainLayout = () => {
  const [collapsed, setCollapsed] = useState(false);
  const { apiConnected, checkApiHealth } = useAnalysis();

  return (
    <div className="app-layout">
      <Sidebar collapsed={collapsed} setCollapsed={setCollapsed} />
      
      <div className="app-main">
        <TopNavbar />

        {!apiConnected && (
          <div
            style={{
              backgroundColor: '#fef2f2',
              borderBottom: '1px solid #fecaca',
              color: '#991b1b',
              padding: '0.75rem 1.75rem',
              fontSize: '0.88rem',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontWeight: '600' }}>
              <AlertCircle size={18} color="#dc2626" />
              <span>R analytics backend API is currently unavailable. Please start the backend R server on port 8000.</span>
            </div>
            <button
              className="btn btn-outline btn-sm"
              onClick={checkApiHealth}
              style={{ borderColor: '#fecaca', color: '#991b1b' }}
            >
              <RefreshCw size={14} /> Retry Connection
            </button>
          </div>
        )}

        <main className="page-container">
          <Outlet />
        </main>
      </div>

      <ToastNotification />
    </div>
  );
};

export default MainLayout;
