import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAnalysis } from '../context/AnalysisContext';
import { api } from '../services/api';
import PageHeader from '../components/PageHeader';
import ChartCard from '../components/ChartCard';
import WordFreqChart from '../charts/WordFreqChart';
import TfidfChart from '../charts/TfidfChart';
import WordCloudView from '../charts/WordCloudView';
import EmptyState from '../components/EmptyState';
import LoadingState from '../components/LoadingState';
import { FileText, ArrowRight, Hash, Sparkles } from 'lucide-react';

const TextMining = () => {
  const navigate = useNavigate();
  const {
    loading,
    setLoading,
    loadingText,
    setLoadingText,
    addToast,
    pipelineStatus,
    setPipelineStatus,
    textMiningResults,
    setTextMiningResults,
  } = useAnalysis();

  const [activeTab, setActiveTab] = useState('frequency');
  const [topN, setTopN] = useState(20);

  useEffect(() => {
    if (pipelineStatus.preprocessed && !textMiningResults) {
      handleRunTextMining();
    }
  }, [pipelineStatus.preprocessed, textMiningResults]);

  const handleRunTextMining = async () => {
    setLoading(true);
    setLoadingText('Calculating word frequencies, DTM, and TF-IDF weights in R...');
    try {
      const res = await api.runTextMining(50);
      if (res.success) {
        setTextMiningResults(res.data);
        setPipelineStatus((prev) => ({ ...prev, text_mined: true }));
        addToast('Text mining analysis completed!', 'success');
      }
    } catch (err) {
      addToast('Text mining error: ' + (err.response?.data?.message || err.message), 'error');
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
        <PageHeader title="Text Mining" subtitle="Term frequency, Document-Term Matrix (DTM), and TF-IDF analysis." />
        <EmptyState
          title="Run Preprocessing First"
          description="Please preprocess your customer feedback dataset before performing text mining."
          actionText="Go to Preprocessing"
          onAction={() => navigate('/preprocessing')}
        />
      </div>
    );
  }

  const frequencies = textMiningResults?.frequencies || [];
  const tfidf = textMiningResults?.tfidf || [];
  const keywords = textMiningResults?.keywords || [];

  return (
    <div>
      <PageHeader
        title="Text Mining & Feature Extraction"
        subtitle="Term Frequency (TF), Inverse Document Frequency (IDF), TF-IDF weighting, and keyword extraction."
      >
        <button className="btn btn-primary btn-md" onClick={() => navigate('/sentiment')}>
          Proceed to Sentiment Analysis <ArrowRight size={16} />
        </button>
      </PageHeader>

      {/* TABS NAVIGATION */}
      <div
        style={{
          display: 'flex',
          gap: '0.5rem',
          borderBottom: '2px solid #e2e8f0',
          marginBottom: '1.75rem',
          overflowX: 'auto',
        }}
      >
        {[
          { id: 'frequency', label: 'Word Frequency' },
          { id: 'tfidf', label: 'TF-IDF Weights' },
          { id: 'wordcloud', label: 'Word Cloud' },
          { id: 'keywords', label: 'Keywords' },
        ].map((tab) => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            style={{
              padding: '0.75rem 1.25rem',
              fontWeight: '700',
              fontSize: '0.9rem',
              color: activeTab === tab.id ? '#2563eb' : '#64748b',
              borderBottom: activeTab === tab.id ? '3px solid #2563eb' : '3px solid transparent',
              background: 'none',
              border: 'none',
              cursor: 'pointer',
              whiteSpace: 'nowrap',
            }}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* TAB 1: WORD FREQUENCY */}
      {activeTab === 'frequency' && (
        <ChartCard
          title="Most Frequent Terms"
          subtitle="Frequency count of occurrence across preprocessed customer reviews"
          action={
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <span style={{ fontSize: '0.82rem', color: '#64748b' }}>Top terms:</span>
              {[10, 20, 30, 50].map((n) => (
                <button
                  key={n}
                  className={`btn btn-sm ${topN === n ? 'btn-primary' : 'btn-outline'}`}
                  onClick={() => setTopN(n)}
                >
                  Top {n}
                </button>
              ))}
            </div>
          }
        >
          <WordFreqChart data={frequencies} limit={topN} />
        </ChartCard>
      )}

      {/* TAB 2: TF-IDF */}
      {activeTab === 'tfidf' && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1.75rem' }}>
          <ChartCard title="TF-IDF Term Importance Chart" subtitle="Term Frequency - Inverse Document Frequency scores">
            <TfidfChart data={tfidf} limit={20} />
          </ChartCard>

          <div className="saas-card">
            <h3 className="card-title-clean" style={{ marginBottom: '1rem' }}>
              Detailed TF-IDF Numerical Score Table
            </h3>
            <div className="table-responsive">
              <table className="saas-table">
                <thead>
                  <tr>
                    <th>Term</th>
                    <th>Mean TF (Term Freq)</th>
                    <th>IDF (Inverse Doc Freq)</th>
                    <th>TF-IDF Score</th>
                  </tr>
                </thead>
                <tbody>
                  {tfidf.slice(0, 30).map((row, idx) => (
                    <tr key={`tfidf-${idx}`}>
                      <td style={{ fontWeight: '700', color: '#0f172a' }}>{row.Term}</td>
                      <td>{row.TF}</td>
                      <td>{row.IDF}</td>
                      <td style={{ fontWeight: '800', color: '#8b5cf6', fontFamily: 'var(--font-mono)' }}>
                        {row.TF_IDF_Score}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* TAB 3: WORD CLOUD */}
      {activeTab === 'wordcloud' && (
        <ChartCard title="Customer Opinion Word Cloud" subtitle="Visual size corresponds to term frequency in dataset">
          <WordCloudView data={frequencies} limit={50} />
        </ChartCard>
      )}

      {/* TAB 4: RANKED KEYWORDS */}
      {activeTab === 'keywords' && (
        <div className="saas-card">
          <h3 className="card-title-clean" style={{ marginBottom: '1.25rem' }}>
            <Sparkles color="#8b5cf6" size={20} /> Top Extracted Keywords by Importance
          </h3>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))', gap: '1rem' }}>
            {keywords.map((kw, i) => (
              <div
                key={`kw-${i}`}
                style={{
                  padding: '1rem',
                  backgroundColor: '#f8fafc',
                  borderRadius: '10px',
                  border: '1px solid #e2e8f0',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.85rem',
                }}
              >
                <div
                  style={{
                    fontFamily: 'var(--font-mono)',
                    fontWeight: '800',
                    fontSize: '0.9rem',
                    color: '#2563eb',
                    padding: '0.3rem 0.5rem',
                    backgroundColor: '#eff6ff',
                    borderRadius: '6px',
                  }}
                >
                  {String(i + 1).padStart(2, '0')}
                </div>
                <div>
                  <div style={{ fontWeight: '700', fontSize: '1rem', color: '#0f172a' }}>{kw.Keyword}</div>
                  <div style={{ fontSize: '0.75rem', color: '#64748b' }}>
                    TF-IDF: {kw.TF_IDF_Score}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default TextMining;
