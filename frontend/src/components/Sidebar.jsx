import React from 'react';
import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard,
  MessageSquare,
  Layers,
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
  HelpCircle,
  Info,
  ChevronLeft,
  ChevronRight,
} from 'lucide-react';

const navSections = [
  {
    title: 'Customer Workflows',
    items: [
      { path: '/', label: 'Overview Dashboard', icon: LayoutDashboard },
      { path: '/analyzer', label: 'Review Analyzer', icon: MessageSquare, badge: 'Workflow A' },
      { path: '/compare', label: 'Compare Reviews', icon: Layers },
    ],
  },
  {
    title: 'Bulk Dataset Pipeline (Workflow B)',
    items: [
      { path: '/upload', label: '01 Upload Data', icon: Upload },
      { path: '/validation', label: '02 Data Validation', icon: CheckCircle2 },
      { path: '/preprocessing', label: '03 Preprocessing', icon: Sliders },
      { path: '/text-mining', label: '04 Text Mining', icon: FileText },
      { path: '/sentiment', label: '05 Sentiment Analysis', icon: Smile },
      { path: '/machine-learning', label: '06 Machine Learning', icon: BrainCircuit },
      { path: '/evaluation', label: '07 Model Evaluation', icon: BarChart3 },
      { path: '/visualization', label: '08 Visualization', icon: PieChart },
      { path: '/insights', label: '09 Customer Insights', icon: Lightbulb },
      { path: '/results', label: '10 Results & Export', icon: Download },
    ],
  },
  {
    title: 'Project Info & Architecture',
    items: [
      { path: '/how-it-works', label: 'How It Works (ML)', icon: HelpCircle },
      { path: '/about', label: 'About Project', icon: Info },
    ],
  },
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
        {navSections.map((section, sIdx) => (
          <div key={sIdx} className="sidebar-section" style={{ marginBottom: collapsed ? '8px' : '14px' }}>
            {!collapsed && (
              <div
                style={{
                  padding: '6px 14px 4px',
                  fontSize: '0.68rem',
                  fontWeight: 700,
                  textTransform: 'uppercase',
                  letterSpacing: '0.07em',
                  color: 'var(--text-muted, #94a3b8)',
                }}
              >
                {section.title}
              </div>
            )}
            {section.items.map((item) => {
              const Icon = item.icon;
              return (
                <NavLink
                  key={item.path}
                  to={item.path}
                  className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}
                  title={collapsed ? item.label : ''}
                >
                  <Icon size={18} />
                  {!collapsed && (
                    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', width: '100%' }}>
                      <span className="nav-item-label">{item.label}</span>
                      {item.badge && (
                        <span
                          style={{
                            fontSize: '0.62rem',
                            fontWeight: 700,
                            padding: '1px 6px',
                            borderRadius: '10px',
                            background: 'rgba(59, 130, 246, 0.15)',
                            color: '#3b82f6',
                            border: '1px solid rgba(59, 130, 246, 0.3)',
                          }}
                        >
                          {item.badge}
                        </span>
                      )}
                    </div>
                  )}
                </NavLink>
              );
            })}
          </div>
        ))}
      </nav>

      {!collapsed && (
        <div className="sidebar-footer">
          <div style={{ fontWeight: '600', color: '#e2e8f0' }}>Academic DA Project</div>
          <div style={{ fontSize: '0.75rem', color: '#94a3b8' }}>R Plumber + React Text Mining</div>
        </div>
      )}
    </aside>
  );
};

export default Sidebar;

