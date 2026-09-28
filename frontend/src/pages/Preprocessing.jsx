import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAnalysis } from '../context/AnalysisContext';
import { api } from '../services/api';
import PageHeader from '../components/PageHeader';
import KpiCard from '../components/KpiCard';
import EmptyState from '../components/EmptyState';
import LoadingState from '../components/LoadingState';
import { Sliders, Play, ArrowRight, FileText, CheckCircle2 } from 'lucide-react';

const pipelineSteps = [
  'RAW TEXT',
  'LOWERCASE',
  'REMOVE URLS',
  'REMOVE EMAILS',
  'REMOVE MENTIONS',
  'REMOVE HASHTAGS',
  'REMOVE PUNCTUATION',
  'REMOVE NUMBERS',
  'REMOVE STOPWORDS',
  'STEMMING',
  'CLEAN TEXT',
];

const Preprocessing = () => {
  const navigate = useNavigate();
  const {
    loading,
    setLoading,
    loadingText,
    setLoadingText,
    addToast,
    pipelineStatus,
    setPipelineStatus,
    preprocessingResults,
    setPreprocessingResults,
  } = useAnalysis();

  const [removeStopwords, setRemoveStopwords] = useState(true);
  const [performStemming, setPerformStemming] = useState(true);

  const handleRunPreprocessing = async () => {
    setLoading(true);
    setLoadingText('Executing R text preprocessing algorithms...');
    try {
      const res = await api.preprocessData(removeStopwords, performStemming);
      if (res.success) {
        setPreprocessingResults(res.data);
        setPipelineStatus((prev) => ({ ...prev, preprocessed: true }));
        addToast('Text preprocessing completed successfully!', 'success');
      }
    } catch (err) {
      addToast('Preprocessing error: ' + (err.response?.data?.message || err.message), 'error');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <LoadingState message={loadingText} />;
  }

  if (!pipelineStatus.uploaded) {
    return (
      <div>
        <PageHeader title="Text Preprocessing" subtitle="Text cleaning, noise removal, stopword filtering, and Porter stemming." />
        <EmptyState
          title="Upload Dataset First"
          description="You must upload a dataset before running text preprocessing."
          actionText="Upload Dataset"
          onAction={() => navigate('/upload')}
        />
      </div>
    );
  }

  const stats = preprocessingResults?.stats || {};
  const preview = preprocessingResults?.preview || [];

  return (
    <div>
      <PageHeader
        title="Text Preprocessing Pipeline"
        subtitle="Text normalization, noise reduction, stopword removal, and stemming using R tm & SnowballC."
      >
        {pipelineStatus.preprocessed && (
          <button className="btn btn-primary btn-md" onClick={() => navigate('/text-mining')}>
            Proceed to Text Mining <ArrowRight size={16} />
          </button>
        )}
      </PageHeader>

      {/* PIPELINE FLOW DIAGRAM */}
      <div className="saas-card" style={{ marginBottom: '1.75rem' }}>
        <h3 className="card-title-clean" style={{ marginBottom: '1rem' }}>
          Preprocessing Flow Architecture
        </h3>
        <div
          style={{
            display: 'flex',
            flexWrap: 'wrap',
            alignItems: 'center',
            gap: '0.4rem',
            padding: '1rem',
            backgroundColor: '#f8fafc',
            borderRadius: '12px',
            border: '1px solid #e2e8f0',
          }}
        >
          {pipelineSteps.map((step, idx) => (
            <React.Fragment key={step}>
              <div
                style={{
                  padding: '0.45rem 0.75rem',
                  fontSize: '0.72rem',
                  fontWeight: '700',
                  borderRadius: '6px',
                  backgroundColor: idx === 0 || idx === pipelineSteps.length - 1 ? '#2563eb' : '#ffffff',
                  color: idx === 0 || idx === pipelineSteps.length - 1 ? '#ffffff' : '#334155',
                  border: '1px solid #cbd5e1',
                  fontFamily: 'var(--font-mono)',
                }}
              >
                {step}
              </div>
              {idx < pipelineSteps.length - 1 && <span style={{ color: '#94a3b8', fontWeight: 'bold' }}>↓</span>}
            </React.Fragment>
          ))}
        </div>
      </div>

      {/* CONTROLS & TOGGLES */}
      <div className="saas-card" style={{ marginBottom: '1.75rem' }}>
        <div className="card-header-clean">
          <h3 className="card-title-clean">
            <Sliders color="#2563eb" size={20} /> Pipeline Execution Controls
          </h3>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '1.25rem', marginBottom: '1.5rem' }}>
          <label style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', cursor: 'pointer', padding: '0.85rem', backgroundColor: '#f8fafc', borderRadius: '8px', border: '1px solid #e2e8f0' }}>
            <input
              type="checkbox"
              checked={removeStopwords}
              onChange={(e) => setRemoveStopwords(e.target.checked)}
              style={{ width: '18px', height: '18px', accentColor: '#2563eb' }}
            />
            <div>
              <div style={{ fontWeight: '700', fontSize: '0.9rem', color: '#0f172a' }}>Remove Stop Words</div>
              <div style={{ fontSize: '0.78rem', color: '#64748b' }}>Filter English stop words (the, is, at, etc.)</div>
            </div>
          </label>

          <label style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', cursor: 'pointer', padding: '0.85rem', backgroundColor: '#f8fafc', borderRadius: '8px', border: '1px solid #e2e8f0' }}>
            <input
              type="checkbox"
              checked={performStemming}
              onChange={(e) => setPerformStemming(e.target.checked)}
              style={{ width: '18px', height: '18px', accentColor: '#2563eb' }}
            />
            <div>
              <div style={{ fontWeight: '700', fontSize: '0.9rem', color: '#0f172a' }}>Apply Porter Stemming</div>
              <div style={{ fontSize: '0.78rem', color: '#64748b' }}>Stem words to root forms (shipping → ship)</div>
            </div>
          </label>
        </div>

        <button className="btn btn-primary btn-lg" onClick={handleRunPreprocessing} style={{ width: '100%' }}>
          <Play size={18} /> Run Text Preprocessing
        </button>
      </div>

      {/* STATS SUMMARY (If Executed) */}
      {pipelineStatus.preprocessed && stats.records_processed && (
        <>
          <div className="kpi-grid">
            <KpiCard label="Records Processed" value={stats.records_processed} icon={CheckCircle2} variant="pos" />
            <KpiCard label="Words Before" value={stats.words_before} icon={FileText} variant="primary" />
            <KpiCard label="Words After" value={stats.words_after} icon={FileText} variant="primary" />
            <KpiCard label="Stopwords Removed" value={stats.stopwords_removed} icon={Sliders} variant="neu" />
          </div>

          {/* BEFORE / AFTER COMPARISON TABLE */}
          <div className="saas-card">
            <h3 className="card-title-clean" style={{ marginBottom: '1rem' }}>
              Before & After Preprocessing Comparison
            </h3>
            <div className="table-responsive">
              <table className="saas-table">
                <thead>
                  <tr>
                    <th style={{ width: '50%' }}>Original Review</th>
                    <th style={{ width: '50%' }}>Cleaned & Preprocessed Review</th>
                  </tr>
                </thead>
                <tbody>
                  {preview.map((row, idx) => (
                    <tr key={`prev-${idx}`}>
                      <td style={{ color: '#475569' }}>{row.Original_Review}</td>
                      <td style={{ fontWeight: '600', color: '#0f172a', fontFamily: 'var(--font-mono)', fontSize: '0.82rem' }}>
                        {row.Processed_Review || '<EMPTY>'}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </>
      )}
    </div>
  );
};

export default Preprocessing;
