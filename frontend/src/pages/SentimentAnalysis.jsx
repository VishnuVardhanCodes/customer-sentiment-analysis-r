import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAnalysis } from '../context/AnalysisContext';
import { api } from '../services/api';
import PageHeader from '../components/PageHeader';
import KpiCard from '../components/KpiCard';
import ChartCard from '../components/ChartCard';
import SentimentDonutChart from '../charts/SentimentDonutChart';
import StatusBadge from '../components/StatusBadge';
import EmptyState from '../components/EmptyState';
import LoadingState from '../components/LoadingState';
import { Smile, Meh, Frown, Play, ArrowRight, Search, Filter } from 'lucide-react';

const SentimentAnalysis = () => {
  const navigate = useNavigate();
  const {
    loading,
    setLoading,
    loadingText,
    setLoadingText,
    addToast,
    pipelineStatus,
    setPipelineStatus,
    sentimentResults,
    setSentimentResults,
  } = useAnalysis();

  const [filterCategory, setFilterCategory] = useState('All');
  const [searchQuery, setSearchQuery] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const pageSize = 10;

  useEffect(() => {
    if (pipelineStatus.preprocessed && !sentimentResults) {
      handleRunSentiment();
    }
  }, [pipelineStatus.preprocessed, sentimentResults]);

  const handleRunSentiment = async () => {
    setLoading(true);
    setLoadingText('Calculating Syuzhet Bing lexicon sentiment scores in R...');
    try {
      const res = await api.runSentiment();
      if (res.success) {
        setSentimentResults(res.data);
        setPipelineStatus((prev) => ({ ...prev, sentiment_analyzed: true }));
        addToast('Sentiment analysis completed!', 'success');
      }
    } catch (err) {
      addToast('Sentiment analysis error: ' + (err.response?.data?.message || err.message), 'error');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <LoadingState message={loadingText} />;
  }

  if (!pipelineStatus.preprocessed) {
    return (
      <div>
        <PageHeader title="Sentiment Analysis" subtitle="Lexicon-based sentiment scoring and polarity classification." />
        <EmptyState
          title="Preprocess Dataset First"
          description="Please preprocess your dataset before running lexicon sentiment analysis."
          actionText="Go to Preprocessing"
          onAction={() => navigate('/preprocessing')}
        />
      </div>
    );
  }

  const kpis = sentimentResults?.kpis || {};
  const reviews = sentimentResults?.reviews || [];
  const isLabeled = pipelineStatus.is_labeled;

  // Filter reviews
  const filteredReviews = reviews.filter((r) => {
    const matchesCategory = filterCategory === 'All' || r.Sentiment === filterCategory;
    const textToMatch = String(r.review_text || r.Original_Review || '').toLowerCase();
    const matchesSearch = textToMatch.includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  const totalPages = Math.ceil(filteredReviews.length / pageSize) || 1;
  const startIndex = (currentPage - 1) * pageSize;
  const paginatedReviews = filteredReviews.slice(startIndex, startIndex + pageSize);

  return (
    <div>
      <PageHeader
        title="Lexicon Sentiment Analysis"
        subtitle="Unsupervised Bing Lexicon scoring via R Syuzhet package."
      >
        <button className="btn btn-outline btn-md" onClick={handleRunSentiment} disabled={loading}>
          <Play size={16} /> Re-run Sentiment
        </button>
        {isLabeled ? (
          <button className="btn btn-primary btn-md" onClick={() => navigate('/machine-learning')}>
            Proceed to Machine Learning <ArrowRight size={16} />
          </button>
        ) : (
          <button className="btn btn-primary btn-md" onClick={() => navigate('/visualization')}>
            Proceed to Visualization <ArrowRight size={16} />
          </button>
        )}
      </PageHeader>

      {/* KPI CARDS */}
      <div className="kpi-grid">
        <KpiCard
          label="Positive Sentiment"
          value={kpis.Pos_Count !== undefined ? `${kpis.Pos_Count} (${kpis.Pos_Pct}%)` : '--'}
          icon={Smile}
          variant="pos"
        />
        <KpiCard
          label="Neutral Sentiment"
          value={kpis.Neu_Count !== undefined ? `${kpis.Neu_Count} (${kpis.Neu_Pct}%)` : '--'}
          icon={Meh}
          variant="neu"
        />
        <KpiCard
          label="Negative Sentiment"
          value={kpis.Neg_Count !== undefined ? `${kpis.Neg_Count} (${kpis.Neg_Pct}%)` : '--'}
          icon={Frown}
          variant="neg"
        />
      </div>

      {/* SENTIMENT OVERVIEW DONUT CHART */}
      <div style={{ marginBottom: '2rem' }}>
        <ChartCard title="Overall Sentiment Distribution" subtitle="Proportion of Positive, Neutral, and Negative customer feedback">
          <SentimentDonutChart data={kpis.Total ? [
            { name: 'Positive', value: kpis.Pos_Count, percentage: kpis.Pos_Pct },
            { name: 'Neutral', value: kpis.Neu_Count, percentage: kpis.Neu_Pct },
            { name: 'Negative', value: kpis.Neg_Count, percentage: kpis.Neg_Pct },
          ] : []} />
        </ChartCard>
      </div>

      {/* REVIEWS TABLE WITH SEARCH AND FILTER */}
      <div className="saas-card">
        <div className="card-header-clean" style={{ flexWrap: 'wrap', gap: '1rem' }}>
          <h3 className="card-title-clean">Detailed Review Sentiment Scoring Table</h3>

          <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', flexWrap: 'wrap' }}>
            {/* Category Filter */}
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.4rem' }}>
              <Filter size={16} color="#64748b" />
              {['All', 'Positive', 'Neutral', 'Negative'].map((cat) => (
                <button
                  key={cat}
                  className={`btn btn-sm ${filterCategory === cat ? 'btn-primary' : 'btn-outline'}`}
                  onClick={() => {
                    setFilterCategory(cat);
                    setCurrentPage(1);
                  }}
                >
                  {cat}
                </button>
              ))}
            </div>

            {/* Search Input */}
            <div style={{ position: 'relative', width: '220px' }}>
              <Search size={15} style={{ position: 'absolute', left: '10px', top: '9px', color: '#94a3b8' }} />
              <input
                type="text"
                placeholder="Search reviews..."
                value={searchQuery}
                onChange={(e) => {
                  setSearchQuery(e.target.value);
                  setCurrentPage(1);
                }}
                style={{
                  width: '100%',
                  padding: '0.4rem 0.6rem 0.4rem 2rem',
                  borderRadius: '6px',
                  border: '1px solid #cbd5e1',
                  fontSize: '0.85rem',
                }}
              />
            </div>
          </div>
        </div>

        <div className="table-responsive">
          <table className="saas-table">
            <thead>
              <tr>
                <th style={{ width: '8%' }}>ID</th>
                <th style={{ width: '45%' }}>Customer Review Text</th>
                {isLabeled && <th style={{ width: '15%' }}>Ground Truth</th>}
                <th style={{ width: '15%' }}>Sentiment Score</th>
                <th style={{ width: '17%' }}>Lexicon Category</th>
              </tr>
            </thead>
            <tbody>
              {paginatedReviews.length > 0 ? (
                paginatedReviews.map((r, i) => (
                  <tr key={`rev-${i}`}>
                    <td style={{ fontFamily: 'var(--font-mono)', fontSize: '0.8rem', color: '#64748b' }}>
                      #{r.Row_ID || i + 1}
                    </td>
                    <td style={{ color: '#0f172a' }}>{r.review_text || r.Original_Review}</td>
                    {isLabeled && (
                      <td>
                        <StatusBadge status={r.sentiment || r.Sentiment_Label} />
                      </td>
                    )}
                    <td style={{ fontWeight: '800', fontFamily: 'var(--font-mono)', color: r.Sentiment_Score > 0 ? '#16a34a' : r.Sentiment_Score < 0 ? '#dc2626' : '#d97706' }}>
                      {r.Sentiment_Score > 0 ? `+${r.Sentiment_Score}` : r.Sentiment_Score}
                    </td>
                    <td>
                      <StatusBadge status={r.Sentiment} />
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={isLabeled ? 5 : 4} style={{ textAlign: 'center', padding: '2rem', color: '#94a3b8' }}>
                    No reviews match the selected filter query.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '1rem' }}>
          <div style={{ fontSize: '0.82rem', color: '#64748b' }}>
            Showing {filteredReviews.length === 0 ? 0 : startIndex + 1} to {Math.min(startIndex + pageSize, filteredReviews.length)} of {filteredReviews.length} records
          </div>
          <div style={{ display: 'flex', gap: '0.5rem' }}>
            <button
              className="btn btn-outline btn-sm"
              onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
              disabled={currentPage === 1}
            >
              Previous
            </button>
            <button
              className="btn btn-outline btn-sm"
              onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
              disabled={currentPage === totalPages}
            >
              Next
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SentimentAnalysis;
