import React from 'react';
import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard,
  Upload,
  CheckCircle2,
  Sliders,
  FileText,
  Smile,
  BrainCircuit,
  BarChart3,
  PieChart,
  Lightbulb,
  Download,
  ChevronLeft,
  ChevronRight,
} from 'lucide-react';

const navItems = [
  { path: '/', label: 'Dashboard', num: '01', icon: LayoutDashboard },
  { path: '/upload', label: 'Upload Data', num: '02', icon: Upload },
  { path: '/validation', label: 'Data Validation', num: '03', icon: CheckCircle2 },
  { path: '/preprocessing', label: 'Preprocessing', num: '04', icon: Sliders },
  { path: '/text-mining', label: 'Text Mining', num: '05', icon: FileText },
  { path: '/sentiment', label: 'Sentiment Analysis', num: '06', icon: Smile },
  { path: '/machine-learning', label: 'Machine Learning', num: '07', icon: BrainCircuit },
  { path: '/evaluation', label: 'Model Evaluation', num: '08', icon: BarChart3 },
  { path: '/visualization', label: 'Visualization', num: '09', icon: PieChart },
  { path: '/insights', label: 'Customer Insights', num: '10', icon: Lightbulb },
  { path: '/results', label: 'Results & Download', num: '11', icon: Download },
];

const Sidebar = ({ collapsed, setCollapsed }) => {
  return (
    <aside className={`app-sidebar ${collapsed ? 'collapsed' : ''}`}>
      <div className="sidebar-header">
        <div className="brand-logo">
          <div className="brand-badge">LG9</div>
          {!collapsed && (
            <div className="brand-title">
              <span className="brand-name">ANALYTICS</span>
              <span className="brand-sub">Customer Intelligence</span>
            </div>
          )}
        </div>
        <button
          className="sidebar-toggle-btn"
          onClick={() => setCollapsed(!collapsed)}
          title={collapsed ? 'Expand Sidebar' : 'Collapse Sidebar'}
        >
          {collapsed ? <ChevronRight size={18} /> : <ChevronLeft size={18} />}
        </button>
      </div>

      <nav className="sidebar-nav">
        {navItems.map((item) => {
          const Icon = item.icon;
          return (
            <NavLink
              key={item.path}
              to={item.path}
              className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}
              title={collapsed ? `${item.num} ${item.label}` : ''}
            >
              <Icon size={19} />
              {!collapsed && (
                <>
                  <span className="nav-item-num">{item.num}</span>
                  <span className="nav-item-label">{item.label}</span>
                </>
              )}
            </NavLink>
          );
        })}
      </nav>

      {!collapsed && (
        <div className="sidebar-footer">
          <div style={{ fontWeight: '600', color: '#e2e8f0' }}>Academic DA Project</div>
          <div>Social Media Text Mining in R</div>
        </div>
      )}
    </aside>
  );
};

export default Sidebar;
