import React from 'react';
import PageHeader from '../components/PageHeader';
import {
  BookOpen,
  Users,
  Building,
  GraduationCap,
  Layers,
  ShieldCheck,
  CheckCircle2,
  Cpu,
  Server,
  Code2,
  FileCheck,
} from 'lucide-react';
import { Link } from 'react-router-dom';

const AboutProject = () => {
  return (
    <div>
      <PageHeader
        title="About the Project"
        subtitle="Customer Sentiment Analysis from Social Media and Product Reviews Using Text Mining in R"
      />

      {/* PROJECT PURPOSE BANNER */}
      <div
        style={{
          background: 'linear-gradient(135deg, #1e3a8a 0%, #3b82f6 100%)',
          borderRadius: 'var(--radius-lg)',
          padding: '2rem',
          color: '#ffffff',
          marginBottom: '2rem',
          boxShadow: 'var(--shadow-md)',
        }}
      >
        <div style={{ display: 'inline-block', backgroundColor: 'rgba(255,255,255,0.2)', padding: '0.25rem 0.75rem', borderRadius: 'var(--radius-full)', fontSize: '0.78rem', fontWeight: '700', marginBottom: '0.75rem', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
          Final Year B.Tech Academic Data Analytics Project
        </div>
        <h2 style={{ fontSize: '1.65rem', fontWeight: '800', marginBottom: '0.75rem', color: '#ffffff' }}>
          Customer Sentiment Analysis from Social Media and Product Reviews Using Text Mining in R
        </h2>
        <p style={{ fontSize: '0.98rem', opacity: 0.95, lineHeight: '1.6', maxWidth: '900px', margin: 0 }}>
          Customer Sentiment Analysis is an interactive application that analyzes customer reviews using text mining and machine learning.
          It helps potential buyers understand the opinions expressed in existing customer reviews before purchasing, while enabling
          businesses to identify product strengths, common complaints, and customer feedback patterns. Users can analyze individual reviews
          or upload datasets to explore sentiment distribution, keywords, and model performance.
        </p>
      </div>

      {/* THREE TARGET USER GROUPS */}
      <div style={{ marginBottom: '2.5rem' }}>
        <h3 style={{ fontSize: '1.15rem', fontWeight: '800', color: '#0f172a', marginBottom: '1.25rem' }}>
          Target Users & Core Stakeholders
        </h3>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '1.5rem' }}>
          {/* Card 1: Potential Customers */}
          <div className="saas-card" style={{ borderTop: '4px solid #2563eb' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.75rem' }}>
              <div style={{ padding: '0.5rem', borderRadius: '8px', backgroundColor: '#eff6ff', color: '#2563eb' }}>
                <Users size={22} />
              </div>
              <div>
                <span style={{ fontSize: '0.75rem', fontWeight: '700', color: '#2563eb', textTransform: 'uppercase' }}>Primary Users</span>
                <h4 style={{ fontSize: '1.1rem', fontWeight: '700', color: '#0f172a', margin: 0 }}>Potential Customers</h4>
              </div>
            </div>
            <p style={{ fontSize: '0.85rem', color: '#64748b', marginBottom: '1rem', lineHeight: '1.5' }}>
              Shoppers who want to evaluate existing reviews before purchasing products from e-commerce platforms like Amazon.
            </p>
            <ul style={{ paddingLeft: '1.25rem', fontSize: '0.84rem', color: '#334155', lineHeight: '1.7', margin: 0 }}>
              <li>Analyze individual customer reviews in real time.</li>
              <li>Understand positive, negative, and neutral opinions.</li>
              <li>Extract important product-related keywords and themes.</li>
              <li>Compare feedback from multiple reviews simultaneously.</li>
              <li>Make more informed purchasing decisions based on actual evidence.</li>
            </ul>
          </div>

          {/* Card 2: Businesses and Sellers */}
          <div className="saas-card" style={{ borderTop: '4px solid #16a34a' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.75rem' }}>
              <div style={{ padding: '0.5rem', borderRadius: '8px', backgroundColor: '#f0fdf4', color: '#16a34a' }}>
                <Building size={22} />
              </div>
              <div>
                <span style={{ fontSize: '0.75rem', fontWeight: '700', color: '#16a34a', textTransform: 'uppercase' }}>Secondary Users</span>
                <h4 style={{ fontSize: '1.1rem', fontWeight: '700', color: '#0f172a', margin: 0 }}>Businesses & Sellers</h4>
              </div>
            </div>
            <p style={{ fontSize: '0.85rem', color: '#64748b', marginBottom: '1rem', lineHeight: '1.5' }}>
              Product managers, retailers, and customer experience teams monitoring customer satisfaction trends.
            </p>
            <ul style={{ paddingLeft: '1.25rem', fontSize: '0.84rem', color: '#334155', lineHeight: '1.7', margin: 0 }}>
              <li>Identify recurring customer complaints and defect reports.</li>
              <li>Understand product strengths and high-satisfaction features.</li>
              <li>Monitor customer sentiment distributions across product catalogs.</li>
              <li>Detect feedback patterns across categories and price points.</li>
              <li>Improve product quality control and customer service workflows.</li>
            </ul>
          </div>

          {/* Card 3: Academic and Research Users */}
          <div className="saas-card" style={{ borderTop: '4px solid #7c3aed' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.75rem' }}>
              <div style={{ padding: '0.5rem', borderRadius: '8px', backgroundColor: '#f5f3ff', color: '#7c3aed' }}>
                <GraduationCap size={22} />
              </div>
              <div>
                <span style={{ fontSize: '0.75rem', fontWeight: '700', color: '#7c3aed', textTransform: 'uppercase' }}>Academic Audience</span>
                <h4 style={{ fontSize: '1.1rem', fontWeight: '700', color: '#0f172a', margin: 0 }}>Students & Researchers</h4>
              </div>
            </div>
            <p style={{ fontSize: '0.85rem', color: '#64748b', marginBottom: '1rem', lineHeight: '1.5' }}>
              Data analytics students and NLP researchers studying text mining and supervised machine learning pipelines.
            </p>
            <ul style={{ paddingLeft: '1.25rem', fontSize: '0.84rem', color: '#334155', lineHeight: '1.7', margin: 0 }}>
              <li>Study text preprocessing, stemming, and negation handling.</li>
              <li>Explore TF-IDF weighting and Document-Term Matrix formation.</li>
              <li>Compare classification algorithms (Naive Bayes, SVM, KNN).</li>
              <li>Evaluate machine learning models with Accuracy, Precision, Recall, F1.</li>
              <li>Analyze confusion matrices and model misclassifications.</li>
            </ul>
          </div>
        </div>
      </div>

      {/* SYSTEM ARCHITECTURE & TECH STACK */}
      <div className="saas-card" style={{ marginBottom: '2.5rem' }}>
        <h3 style={{ fontSize: '1.15rem', fontWeight: '800', color: '#0f172a', marginBottom: '1.25rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <Cpu size={20} color="#2563eb" /> System Architecture & Technology Stack
        </h3>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '1.5rem' }}>
          <div style={{ backgroundColor: '#f8fafc', padding: '1.25rem', borderRadius: 'var(--radius-md)', border: '1px solid #e2e8f0' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontWeight: '700', color: '#2563eb', marginBottom: '0.5rem' }}>
              <Server size={18} /> Backend Analytics (R & R Plumber)
            </div>
            <ul style={{ paddingLeft: '1.25rem', fontSize: '0.84rem', color: '#334155', lineHeight: '1.7', margin: 0 }}>
              <li><strong>R Plumber API:</strong> High-performance RESTful API endpoints on port 8000.</li>
              <li><strong>Text Preprocessing:</strong> <code>tm</code>, <code>SnowballC</code>, <code>stringr</code>, custom negation preservation.</li>
              <li><strong>Text Mining:</strong> <code>tidytext</code>, <code>Matrix</code>, TF-IDF calculation, Document-Term Matrix.</li>
              <li><strong>Lexicon Polarity:</strong> <code>syuzhet</code> (Bing Lexicon polarity scoring).</li>
              <li><strong>Machine Learning:</strong> <code>e1071</code> (SVM with Linear Kernel, Naive Bayes), <code>class</code> (KNN).</li>
              <li><strong>Evaluation:</strong> Custom multi-class accuracy, precision, recall, F1, and confusion matrix calculation.</li>
            </ul>
          </div>

          <div style={{ backgroundColor: '#f8fafc', padding: '1.25rem', borderRadius: 'var(--radius-md)', border: '1px solid #e2e8f0' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontWeight: '700', color: '#0891b2', marginBottom: '0.5rem' }}>
              <Code2 size={18} /> Frontend Application (React)
            </div>
            <ul style={{ paddingLeft: '1.25rem', fontSize: '0.84rem', color: '#334155', lineHeight: '1.7', margin: 0 }}>
              <li><strong>React 18 Single Page App:</strong> Responsive, accessible, professional interface.</li>
              <li><strong>React Router v6:</strong> Declarative client-side routing between workflows.</li>
              <li><strong>Data Visualizations:</strong> <code>Recharts</code> interactive bar, pie, and donut charts.</li>
              <li><strong>Iconography:</strong> <code>lucide-react</code> crisp vector icons.</li>
              <li><strong>Styling Architecture:</strong> Clean Vanilla CSS design tokens with full CSS variable support.</li>
              <li><strong>State Management:</strong> React Context API with persistent session updates.</li>
            </ul>
          </div>
        </div>
      </div>

      {/* IMPORTANT DISCLAIMER & ETHICAL USAGE */}
      <div
        style={{
          backgroundColor: '#fffbeb',
          border: '1px solid #fef08a',
          borderRadius: 'var(--radius-md)',
          padding: '1.25rem 1.5rem',
          marginBottom: '2rem',
        }}
      >
        <h4 style={{ fontSize: '0.95rem', fontWeight: '800', color: '#92400e', marginBottom: '0.35rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <ShieldCheck size={18} color="#d97706" /> Academic Project Scope & Decision Support Disclaimer
        </h4>
        <p style={{ fontSize: '0.86rem', color: '#78350f', lineHeight: '1.6', margin: 0 }}>
          This application is designed as an analytical decision-support tool. A positive review does not guarantee that a product is universally suitable,
          and a negative review does not automatically mean a customer should avoid it. Sentiment analysis helps users understand feedback patterns,
          but purchasing decisions should always be made by comparing multiple reviews and evaluating personal requirements.
          The application does not claim direct, verified live API connectivity to e-commerce platforms.
        </p>
      </div>
    </div>
  );
};

export default AboutProject;
