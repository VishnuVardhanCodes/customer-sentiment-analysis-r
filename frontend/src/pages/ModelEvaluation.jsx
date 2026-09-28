import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAnalysis } from '../context/AnalysisContext';
import { api } from '../services/api';
import PageHeader from '../components/PageHeader';
import ChartCard from '../components/ChartCard';
import ModelComparisonChart from '../charts/ModelComparisonChart';
import ConfusionMatrixHeatmap from '../charts/ConfusionMatrixHeatmap';
import EmptyState from '../components/EmptyState';
import LoadingState from '../components/LoadingState';
import { BarChart3, Award, ArrowRight, CheckCircle2 } from 'lucide-react';

const ModelEvaluation = () => {
  const navigate = useNavigate();
  const {
    loading,
    setLoading,
    loadingText,
    setLoadingText,
    pipelineStatus,
    evaluationResults,
    setEvaluationResults,
  } = useAnalysis();

  const [selectedModel, setSelectedModel] = useState('SVM');

  useEffect(() => {
    if (pipelineStatus.is_labeled && !evaluationResults) {
      fetchEvaluation();
    }
  }, [pipelineStatus.is_labeled, evaluationResults]);

  const fetchEvaluation = async () => {
    setLoading(true);
    setLoadingText('Retrieving model evaluation comparison & confusion matrices...');
    try {
      const res = await api.evaluateModels();
      if (res.success) {
        setEvaluationResults(res.data);
        if (res.data.best_model) setSelectedModel(res.data.best_model);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <LoadingState message={loadingText} />;
  }

  if (!pipelineStatus.is_labeled) {
    return (
      <div>
        <PageHeader title="Model Evaluation" subtitle="Comparative classification evaluation & confusion matrices." />
        <EmptyState
          title="Supervised Machine Learning Evaluation Unavailable"
          description="Model evaluation metrics (Accuracy, Precision, Recall, F1, Confusion Matrix) require a labeled dataset with ground-truth sentiment targets."
          actionText="Go to Dashboard"
          onAction={() => navigate('/')}
        />
      </div>
    );
  }

  if (!evaluationResults || !evaluationResults.comparison_table) {
    return (
      <div>
        <PageHeader title="Model Evaluation" subtitle="Comparative evaluation across Naive Bayes, SVM, and KNN." />
        <EmptyState
          title="No Evaluation Data Available"
          description="Run machine learning model training first to generate comparison metrics and confusion matrices."
          actionText="Run Machine Learning"
          onAction={() => navigate('/machine-learning')}
        />
      </div>
    );
  }

  const compTable = evaluationResults.comparison_table || [];
  const bestModel = evaluationResults.best_model || '--';
  const bestAccuracy = evaluationResults.best_accuracy ? `${(evaluationResults.best_accuracy * 100).toFixed(1)}%` : '--';
  const bestF1 = evaluationResults.best_f1 ? `${(evaluationResults.best_f1 * 100).toFixed(1)}%` : '--';
  const confusionMatrices = evaluationResults.confusion_matrices || {};

  const currentCmData = confusionMatrices[selectedModel] || [];

  return (
    <div>
      <PageHeader
        title="Model Evaluation & Performance Metrics"
        subtitle="Standard statistical evaluation metrics: Accuracy, Precision, Recall, Macro F1-Score, and Confusion Matrix Heatmaps."
      >
        <button className="btn btn-primary btn-md" onClick={() => navigate('/visualization')}>
          Proceed to Visualization <ArrowRight size={16} />
        </button>
      </PageHeader>

      {/* BEST MODEL HIGHLIGHT CARD */}
      <div
        className="saas-card"
        style={{
          backgroundColor: '#f0fdf4',
          border: '1px solid #bbf7d0',
          marginBottom: '1.75rem',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          flexWrap: 'wrap',
          gap: '1rem',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
          <div style={{ width: '48px', height: '48px', borderRadius: '50%', backgroundColor: '#dcfce7', color: '#16a34a', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Award size={26} />
          </div>
          <div>
            <div style={{ fontSize: '0.8rem', fontWeight: '700', color: '#15803d', textTransform: 'uppercase' }}>
              HIGHEST PERFORMING ALGORITHM
            </div>
            <h3 style={{ fontSize: '1.35rem', fontWeight: '800', color: '#0f172a' }}>{bestModel}</h3>
          </div>
        </div>

        <div style={{ display: 'flex', gap: '2rem' }}>
          <div>
            <div style={{ fontSize: '0.75rem', fontWeight: '600', color: '#15803d' }}>ACCURACY</div>
            <div style={{ fontSize: '1.4rem', fontWeight: '800', color: '#0f172a' }}>{bestAccuracy}</div>
          </div>
          <div>
            <div style={{ fontSize: '0.75rem', fontWeight: '600', color: '#15803d' }}>MACRO F1 SCORE</div>
            <div style={{ fontSize: '1.4rem', fontWeight: '800', color: '#2563eb' }}>{bestF1}</div>
          </div>
        </div>
      </div>

      {/* COMPARISON TABLE */}
      <div className="saas-card" style={{ marginBottom: '1.75rem' }}>
        <h3 className="card-title-clean" style={{ marginBottom: '1rem' }}>
          <BarChart3 color="#2563eb" size={20} /> Model Performance Metrics Comparison
        </h3>
        <div className="table-responsive">
          <table className="saas-table">
            <thead>
              <tr>
                <th>Model / Algorithm</th>
                <th>Accuracy</th>
                <th>Precision</th>
                <th>Recall</th>
                <th>Macro F1-Score</th>
                <th>Rank</th>
              </tr>
            </thead>
            <tbody>
              {compTable.map((row, idx) => (
                <tr key={`comp-${idx}`} style={{ backgroundColor: row.Model === bestModel ? '#f0fdf4' : 'transparent' }}>
                  <td style={{ fontWeight: '700', color: '#0f172a', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                    {row.Model === bestModel && <CheckCircle2 size={16} color="#16a34a" />}
                    {row.Model}
                  </td>
                  <td style={{ fontWeight: '700' }}>{(row.Accuracy * 100).toFixed(2)}%</td>
                  <td>{(row.Precision * 100).toFixed(2)}%</td>
                  <td>{(row.Recall * 100).toFixed(2)}%</td>
                  <td style={{ fontWeight: '800', color: '#2563eb', fontFamily: 'var(--font-mono)' }}>
                    {(row.F1_Score * 100).toFixed(2)}%
                  </td>
                  <td>
                    <span style={{ fontWeight: '700', fontSize: '0.8rem', padding: '0.2rem 0.5rem', borderRadius: '4px', backgroundColor: idx === 0 ? '#dcfce7' : '#f1f5f9', color: idx === 0 ? '#15803d' : '#64748b' }}>
                      #{idx + 1}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* COMPARISON CHART & CONFUSION MATRIX GRID */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(420px, 1fr))', gap: '1.5rem' }}>
        <ChartCard title="Algorithms Comparison Bar Chart" subtitle="Visual comparison across Accuracy, Precision, Recall, and F1 Score">
          <ModelComparisonChart data={compTable} />
        </ChartCard>

        <ChartCard
          title="Confusion Matrix Heatmap"
          subtitle="Evaluation of actual vs predicted class distributions"
          action={
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.4rem' }}>
              <span style={{ fontSize: '0.82rem', color: '#64748b' }}>Select Model:</span>
              <select
                value={String(selectedModel || '')}
                onChange={(e) => setSelectedModel(e.target.value)}
                style={{
                  padding: '0.35rem 0.65rem',
                  borderRadius: '6px',
                  border: '1px solid #cbd5e1',
                  fontSize: '0.85rem',
                  fontWeight: '600',
                }}
              >
                {compTable.map((m) => (
                  <option key={`opt-${m.Model}`} value={m.Model}>
                    {m.Model}
                  </option>
                ))}
              </select>
            </div>
          }
        >
          <ConfusionMatrixHeatmap cmData={currentCmData} modelName={selectedModel} />
        </ChartCard>
      </div>
    </div>
  );
};

export default ModelEvaluation;
