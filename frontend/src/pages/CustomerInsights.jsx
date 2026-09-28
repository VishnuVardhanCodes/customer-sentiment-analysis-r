import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAnalysis } from '../context/AnalysisContext';
import { api } from '../services/api';
import PageHeader from '../components/PageHeader';
import InsightCard from '../components/InsightCard';
import EmptyState from '../components/EmptyState';
import LoadingState from '../components/LoadingState';
import { Lightbulb, ArrowRight, CheckCircle, AlertTriangle, Sparkles, MessageSquare } from 'lucide-react';

const CustomerInsights = () => {
  const navigate = useNavigate();
  const {
    loading,
    setLoading,
    loadingText,
    setLoadingText,
    pipelineStatus,
    insightsResults,
    setInsightsResults,
  } = useAnalysis();

  useEffect(() => {
    if (pipelineStatus.sentiment_analyzed && !insightsResults) {
      fetchInsights();
    }
  }, [pipelineStatus.sentiment_analyzed, insightsResults]);

  const fetchInsights = async () => {
    setLoading(true);
    setLoadingText('Generating automated executive insights & recommendations in R...');
    try {
      const res = await api.getInsights();
      if (res.success) setInsightsResults(res.data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <LoadingState message={loadingText} />;
  }

  if (!pipelineStatus.sentiment_analyzed) {
    return (
      <div>
        <PageHeader title="Customer Insights" subtitle="Executive opinion summary, complaint themes, and strategic recommendations." />
        <EmptyState
          title="Perform Sentiment Analysis First"
          description="Insights are automatically derived from preprocessed text and sentiment distribution."
          actionText="Run Sentiment Analysis"
          onAction={() => navigate('/sentiment')}
          icon={Lightbulb}
        />
      </div>
    );
  }

  const ins = insightsResults || {};

  return (
    <div>
      <PageHeader
        title="Executive Customer Insights"
        subtitle="Automated opinion extraction, key drivers of praise/dissatisfaction, and actionable strategic recommendations."
      >
        <button className="btn btn-primary btn-md" onClick={() => navigate('/results')}>
          View Results & Downloads <ArrowRight size={16} />
        </button>
      </PageHeader>

      {/* OVERALL SENTIMENT EXECUTIVE SUMMARY */}
      <div
        className="saas-card"
        style={{
          backgroundColor: '#f0f9ff',
          border: '1px solid #bae6fd',
          borderLeft: '4px solid #0284c7',
          marginBottom: '1.75rem',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.5rem' }}>
          <MessageSquare color="#0284c7" size={22} />
          <h3 style={{ fontSize: '1.1rem', fontWeight: '800', color: '#0369a1' }}>
            OVERALL SENTIMENT EXECUTIVE SUMMARY
          </h3>
        </div>
        <p style={{ fontSize: '1rem', color: '#0c4a6e', fontWeight: '600', lineHeight: '1.6' }}>
          {ins.Executive_Summary || 'Analysis complete.'}
        </p>
      </div>

      {/* ML EVALUATION INSIGHT (If Available) */}
      {ins.ML_Insight && (
        <div
          className="saas-card"
          style={{
            backgroundColor: '#f5f3ff',
            border: '1px solid #ddd6fe',
            borderLeft: '4px solid #8b5cf6',
            marginBottom: '1.75rem',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.4rem' }}>
            <Sparkles color="#8b5cf6" size={20} />
            <h4 style={{ fontSize: '1rem', fontWeight: '700', color: '#6d28d9' }}>
              MACHINE LEARNING BENCHMARK INSIGHT
            </h4>
          </div>
          <p style={{ fontSize: '0.92rem', color: '#5b21b6', fontWeight: '600' }}>
            {ins.ML_Insight}
          </p>
        </div>
      )}

      {/* TWO COLUMN GRID FOR PRAISE VS COMPLAINTS */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(340px, 1fr))', gap: '1.5rem', marginBottom: '1.75rem' }}>
        {/* CUSTOMER PRAISE */}
        <div className="saas-card" style={{ borderTop: '4px solid #16a34a' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem', marginBottom: '1rem' }}>
            <CheckCircle color="#16a34a" size={20} />
            <h3 style={{ fontSize: '1.05rem', fontWeight: '700', color: '#0f172a' }}>CUSTOMER PRAISE DRIVERS</h3>
          </div>
          <p style={{ fontSize: '0.85rem', color: '#64748b', marginBottom: '1rem' }}>
            Top terms associated with positive customer reviews:
          </p>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '0.5rem' }}>
            {ins.Positive_Themes && ins.Positive_Themes.length > 0 ? (
              ins.Positive_Themes.map((term, i) => (
                <span
                  key={`pos-t-${i}`}
                  style={{
                    padding: '0.4rem 0.75rem',
                    backgroundColor: '#f0fdf4',
                    color: '#16a34a',
                    border: '1px solid #bbf7d0',
                    borderRadius: '20px',
                    fontWeight: '700',
                    fontSize: '0.85rem',
                  }}
                >
                  +{term}
                </span>
              ))
            ) : (
              <span style={{ color: '#94a3b8' }}>No positive themes extracted.</span>
            )}
          </div>
        </div>

        {/* CUSTOMER COMPLAINTS */}
        <div className="saas-card" style={{ borderTop: '4px solid #dc2626' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem', marginBottom: '1rem' }}>
            <AlertTriangle color="#dc2626" size={20} />
            <h3 style={{ fontSize: '1.05rem', fontWeight: '700', color: '#0f172a' }}>CUSTOMER COMPLAINT THEMES</h3>
          </div>
          <p style={{ fontSize: '0.85rem', color: '#64748b', marginBottom: '1rem' }}>
            Top terms associated with negative customer friction points:
          </p>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '0.5rem' }}>
            {ins.Negative_Themes && ins.Negative_Themes.length > 0 ? (
              ins.Negative_Themes.map((term, i) => (
                <span
                  key={`neg-t-${i}`}
                  style={{
                    padding: '0.4rem 0.75rem',
                    backgroundColor: '#fef2f2',
                    color: '#dc2626',
                    border: '1px solid #fecaca',
                    borderRadius: '20px',
                    fontWeight: '700',
                    fontSize: '0.85rem',
                  }}
                >
                  -{term}
                </span>
              ))
            ) : (
              <span style={{ color: '#94a3b8' }}>No negative complaint themes found.</span>
            )}
          </div>
        </div>
      </div>

      {/* STRATEGIC RECOMMENDATIONS SECTION */}
      <div className="saas-card">
        <h3 className="card-title-clean" style={{ marginBottom: '1.25rem' }}>
          <Lightbulb color="#d97706" size={20} /> Actionable Strategic Recommendations
        </h3>

        {ins.Recommendations && ins.Recommendations.length > 0 ? (
          ins.Recommendations.map((rec, i) => (
            <InsightCard
              key={`rec-${i}`}
              title={`Strategic Action #${i + 1}`}
              evidence={ins.Negative_Themes || ins.Positive_Themes}
              recommendation={rec}
              type={i % 2 === 0 ? 'complaint' : 'general'}
            />
          ))
        ) : (
          <p style={{ color: '#64748b' }}>No recommendations generated yet.</p>
        )}
      </div>
    </div>
  );
};

export default CustomerInsights;
