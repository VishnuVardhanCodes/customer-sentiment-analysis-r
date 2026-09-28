import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAnalysis } from '../context/AnalysisContext';
import { api } from '../services/api';
import PageHeader from '../components/PageHeader';
import KpiCard from '../components/KpiCard';
import WorkflowStepper from '../components/WorkflowStepper';
import ChartCard from '../components/ChartCard';
import SentimentDonutChart from '../charts/SentimentDonutChart';
import WordFreqChart from '../charts/WordFreqChart';
import ModelComparisonChart from '../charts/ModelComparisonChart';
import LoadingState from '../components/LoadingState';
import {
  Upload,
  PlayCircle,
  HelpCircle,
  MessageSquare,
  Smile,
  Meh,
  Frown,
  Hash,
  Activity,
  Award,
  ArrowRight,
  Sparkles,
} from 'lucide-react';

const Dashboard = () => {
  const navigate = useNavigate();
  const {
    loading,
    setLoading,
    loadingText,
    setLoadingText,
    addToast,
    pipelineStatus,
    updateFromStatePayload,
    datasetMetadata,
    setDatasetMetadata,
    sentimentResults,
    setSentimentResults,
    textMiningResults,
    setTextMiningResults,
    evaluationResults,
    setEvaluationResults,
    insightsResults,
    setInsightsResults,
  } = useAnalysis();

  const [summaryData, setSummaryData] = useState(null);

  const fetchDashboardSummary = async () => {
    try {
      const res = await api.getResults();
      if (res.success) {
        setSummaryData(res.data);
      }
    } catch (err) {
      console.error(err);
    }
  };

  useEffect(() => {
    fetchDashboardSummary();
  }, [pipelineStatus]);

  const handleRunLabeledDemo = async () => {
    setLoading(true);
    setLoadingText('Running complete supervised machine-learning demo workflow...');
    try {
      const res = await api.runLabeledDemo();
      if (res.success) {
        updateFromStatePayload(res.data);
        setDatasetMetadata({
          filename: 'sample_reviews.csv',
          rows: 100,
          columns: 3,
        });
        addToast('Labeled demo workflow executed successfully!', 'success');
        fetchDashboardSummary();
      }
    } catch (err) {
      addToast('Demo execution failed: ' + (err.response?.data?.message || err.message), 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleRunUnlabeledDemo = async () => {
    setLoading(true);
    setLoadingText('Running unlabeled lexicon sentiment analysis demo workflow...');
    try {
      const res = await api.runUnlabeledDemo();
      if (res.success) {
        updateFromStatePayload(res.data);
        setDatasetMetadata({
          filename: 'sample_unlabeled.csv',
          rows: 50,
          columns: 2,
        });
        addToast('Unlabeled demo workflow executed successfully!', 'success');
        fetchDashboardSummary();
      }
    } catch (err) {
      addToast('Demo execution failed: ' + (err.response?.data?.message || err.message), 'error');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <LoadingState message={loadingText} />;
  }

  const kpis = sentimentResults?.kpis || summaryData?.kpis;
  const isLoaded = pipelineStatus.uploaded;
  const isLabeled = pipelineStatus.is_labeled;

  return (
    <div>
      <PageHeader
        title="LG9 – Customer Sentiment Analysis"
        subtitle="Social Media • Text Mining • R Data Analytics Platform"
      />

      <p style={{ fontSize: '0.92rem', color: '#475569', marginBottom: '1.75rem', marginTop: '-1rem' }}>
        Analyze customer feedback using text mining, sentiment analysis, machine learning and interactive data visualization.
      </p>

      {/* QUICK ACTIONS SECTION */}
      <div style={{ marginBottom: '2rem' }}>
        <h3 style={{ fontSize: '1rem', fontWeight: '700', color: '#0f172a', marginBottom: '1rem', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
          QUICK START ACTIONS
        </h3>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '1.25rem' }}>
          {/* Action Card 1: Upload Dataset */}
          <div className="saas-card" style={{ borderLeft: '4px solid #2563eb' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.75rem' }}>
              <div style={{ padding: '0.5rem', borderRadius: '8px', backgroundColor: '#eff6ff', color: '#2563eb' }}>
                <Upload size={20} />
              </div>
              <h4 style={{ fontSize: '1.05rem', fontWeight: '700', color: '#0f172a' }}>UPLOAD DATASET</h4>
            </div>
            <p style={{ fontSize: '0.85rem', color: '#64748b', marginBottom: '1.25rem' }}>
              Import CSV or TXT files containing raw customer reviews and feedback.
            </p>
            <button className="btn btn-primary btn-md" onClick={() => navigate('/upload')} style={{ width: '100%' }}>
              <Upload size={16} /> Upload Dataset
            </button>
          </div>

          {/* Action Card 2: Labeled Demo */}
          <div className="saas-card" style={{ borderLeft: '4px solid #16a34a' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.75rem' }}>
              <div style={{ padding: '0.5rem', borderRadius: '8px', backgroundColor: '#f0fdf4', color: '#16a34a' }}>
                <PlayCircle size={20} />
              </div>
              <h4 style={{ fontSize: '1.05rem', fontWeight: '700', color: '#0f172a' }}>LABELED DEMO</h4>
            </div>
            <p style={{ fontSize: '0.85rem', color: '#64748b', marginBottom: '1.25rem' }}>
              Test complete supervised ML analytics pipeline on 100 sample reviews.
            </p>
            <button className="btn btn-secondary btn-md" onClick={handleRunLabeledDemo} style={{ width: '100%' }}>
              <Sparkles size={16} /> Run Labeled Demo
            </button>
          </div>

          {/* Action Card 3: Unlabeled Demo */}
          <div className="saas-card" style={{ borderLeft: '4px solid #d97706' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.75rem' }}>
              <div style={{ padding: '0.5rem', borderRadius: '8px', backgroundColor: '#fffbeb', color: '#d97706' }}>
                <HelpCircle size={20} />
              </div>
              <h4 style={{ fontSize: '1.05rem', fontWeight: '700', color: '#0f172a' }}>UNLABELED DEMO</h4>
            </div>
            <p style={{ fontSize: '0.85rem', color: '#64748b', marginBottom: '1.25rem' }}>
              Run lexicon-based sentiment analysis on unlabeled feedback.
            </p>
            <button className="btn btn-outline btn-md" onClick={handleRunUnlabeledDemo} style={{ width: '100%' }}>
              <PlayCircle size={16} /> Run Unlabeled Demo
            </button>
          </div>
        </div>
      </div>

      {/* PIPELINE STEPPER */}
      <div style={{ marginBottom: '2rem' }}>
        <h3 style={{ fontSize: '1rem', fontWeight: '700', color: '#0f172a', marginBottom: '0.75rem', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
          ANALYTICS PIPELINE PROGRESS
        </h3>
        <WorkflowStepper />
      </div>

      {/* KPI CARDS GRID */}
      <div style={{ marginBottom: '2rem' }}>
        <h3 style={{ fontSize: '1rem', fontWeight: '700', color: '#0f172a', marginBottom: '1rem', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
          KEY PERFORMANCE INDICATORS (KPIs)
        </h3>
        <div className="kpi-grid">
          <KpiCard
            label="Total Reviews"
            value={isLoaded ? summaryData?.total_reviews || kpis?.Total : '--'}
            icon={MessageSquare}
            variant="primary"
          />
          <KpiCard
            label="Positive Sentiment"
            value={isLoaded && kpis ? `${kpis.Pos_Count} (${kpis.Pos_Pct}%)` : '--'}
            icon={Smile}
            variant="pos"
          />
          <KpiCard
            label="Neutral Sentiment"
            value={isLoaded && kpis ? `${kpis.Neu_Count} (${kpis.Neu_Pct}%)` : '--'}
            icon={Meh}
            variant="neu"
          />
          <KpiCard
            label="Negative Sentiment"
            value={isLoaded && kpis ? `${kpis.Neg_Count} (${kpis.Neg_Pct}%)` : '--'}
            icon={Frown}
            variant="neg"
          />
          <KpiCard
            label="Unique Terms"
            value={isLoaded && summaryData?.unique_terms ? summaryData.unique_terms : '--'}
            icon={Hash}
            variant="primary"
          />
          <KpiCard
            label="Avg Sentiment Score"
            value={isLoaded && summaryData?.avg_sentiment ? summaryData.avg_sentiment : '--'}
            icon={Activity}
            variant="primary"
          />
          <KpiCard
            label="Best Model"
            value={isLabeled && summaryData?.best_model ? summaryData.best_model : isLoaded ? 'Lexicon Only' : '--'}
            icon={Award}
            variant="primary"
          />
          <KpiCard
            label="Model Accuracy"
            value={isLabeled && summaryData?.best_accuracy ? summaryData.best_accuracy : '--'}
            icon={Award}
            variant="pos"
          />
        </div>
      </div>

      {/* CHARTS GRID */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(400px, 1fr))', gap: '1.5rem', marginBottom: '2rem' }}>
        <ChartCard title="Sentiment Distribution Overview" subtitle="Categorized into Positive, Neutral, and Negative classes">
          <SentimentDonutChart data={summaryData?.kpis ? [
            { name: 'Positive', value: summaryData.kpis.Pos_Count, percentage: summaryData.kpis.Pos_Pct },
            { name: 'Neutral', value: summaryData.kpis.Neu_Count, percentage: summaryData.kpis.Neu_Pct },
            { name: 'Negative', value: summaryData.kpis.Neg_Count, percentage: summaryData.kpis.Neg_Pct },
          ] : []} />
        </ChartCard>

        <ChartCard title="Top Frequent Keywords" subtitle="Most prominent terms extracted from preprocessed text">
          <WordFreqChart data={textMiningResults?.frequencies || []} />
        </ChartCard>
      </div>

      {/* MODEL PERFORMANCE COMPARISON (If Labeled) */}
      {isLabeled && evaluationResults?.comparison_table && (
        <div style={{ marginBottom: '2rem' }}>
          <ChartCard title="Supervised Machine Learning Performance" subtitle="Evaluation across Naive Bayes, SVM, and KNN">
            <ModelComparisonChart data={evaluationResults.comparison_table} />
          </ChartCard>
        </div>
      )}

      {/* CUSTOMER INSIGHTS PREVIEW */}
      {insightsResults && (
        <div className="saas-card" style={{ marginBottom: '2rem' }}>
          <div className="card-header-clean">
            <div>
              <h3 className="card-title-clean">Executive Customer Insights</h3>
              <p className="card-subtitle-clean">Automated opinion mining and strategic recommendations</p>
            </div>
            <button className="btn btn-outline btn-sm" onClick={() => navigate('/insights')}>
              View All Insights <ArrowRight size={14} />
            </button>
          </div>
          <div style={{ backgroundColor: '#f0f9ff', padding: '1rem 1.25rem', borderRadius: '10px', borderLeft: '4px solid #0284c7', fontSize: '0.92rem', color: '#0369a1', fontWeight: '600', marginBottom: '1rem' }}>
            {insightsResults.Executive_Summary}
          </div>
          {insightsResults.Recommendations && insightsResults.Recommendations.length > 0 && (
            <div style={{ fontSize: '0.88rem', color: '#334155' }}>
              <strong>Top Recommendation:</strong> {insightsResults.Recommendations[0]}
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default Dashboard;
