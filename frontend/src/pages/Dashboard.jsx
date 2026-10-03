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
  ShoppingBag,
  Building2,
  GraduationCap,
  Layers,
  Package,
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
    textMiningResults,
    evaluationResults,
    insightsResults,
    productSummaries,
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
          columns: 5,
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
          columns: 4,
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
  const numProducts = productSummaries ? productSummaries.length : 0;

  return (
    <div>
      <PageHeader
        title="Customer Sentiment Analysis"
        subtitle="Social Media & Product Review Mining Using R Data Analytics & Machine Learning"
      />

      {/* APPLICATION OBJECTIVE BANNER */}
      <div
        className="saas-card"
        style={{
          background: 'linear-gradient(135deg, rgba(37,99,235,0.06) 0%, rgba(147,51,234,0.06) 100%)',
          border: '1px solid rgba(59,130,246,0.2)',
          marginBottom: '2rem',
          padding: '1.25rem 1.5rem',
        }}
      >
        <div style={{ display: 'flex', alignItems: 'flex-start', gap: '1rem' }}>
          <div
            style={{
              padding: '0.65rem',
              borderRadius: '10px',
              backgroundColor: '#eff6ff',
              color: '#2563eb',
              display: 'flex',
            }}
          >
            <Sparkles size={24} />
          </div>
          <div style={{ flex: 1 }}>
            <h3 style={{ fontSize: '1.05rem', fontWeight: '700', color: '#0f172a', marginBottom: '0.35rem' }}>
              Dual-Purpose Customer Review Intelligence
            </h3>
            <p style={{ fontSize: '0.88rem', color: '#475569', lineHeight: 1.55, margin: 0 }}>
              This platform bridges text mining and machine learning in R to solve real-world e-commerce evaluation.
              It empowers <strong>potential buyers</strong> to understand existing reviews before purchasing products, and allows <strong>businesses</strong> to monitor customer opinion, product strengths, and recurring complaints.
            </p>
          </div>
        </div>
      </div>

      {/* 3 TARGET USER GROUPS */}
      <div style={{ marginBottom: '2rem' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.85rem' }}>
          <h3 style={{ fontSize: '0.92rem', fontWeight: '700', color: '#0f172a', textTransform: 'uppercase', letterSpacing: '0.5px', margin: 0 }}>
            Intended User Groups
          </h3>
          <button
            onClick={() => navigate('/about')}
            style={{ background: 'none', border: 'none', color: '#2563eb', fontSize: '0.82rem', fontWeight: '600', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '4px' }}
          >
            Read Full Project Context <ArrowRight size={13} />
          </button>
        </div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '1.25rem' }}>
          {/* Card 1: Potential Customers */}
          <div className="saas-card" style={{ borderTop: '4px solid #2563eb' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.65rem', marginBottom: '0.65rem' }}>
              <div style={{ padding: '0.45rem', borderRadius: '8px', backgroundColor: '#eff6ff', color: '#2563eb' }}>
                <ShoppingBag size={18} />
              </div>
              <h4 style={{ fontSize: '0.98rem', fontWeight: '700', color: '#0f172a', margin: 0 }}>Potential Buyers</h4>
            </div>
            <p style={{ fontSize: '0.84rem', color: '#64748b', lineHeight: 1.5, marginBottom: '0.75rem' }}>
              Analyze individual product reviews before purchasing. Uncover key strengths, recurring issues, and evidence-based purchase insights.
            </p>
            <ul style={{ fontSize: '0.8rem', color: '#475569', paddingLeft: '1.1rem', margin: 0, lineHeight: 1.5 }}>
              <li>Paste any copied Amazon/e-commerce review</li>
              <li>Get grounded aspect & keyword breakdowns</li>
              <li>Compare multiple reviews for one product</li>
            </ul>
          </div>

          {/* Card 2: Businesses & Sellers */}
          <div className="saas-card" style={{ borderTop: '4px solid #16a34a' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.65rem', marginBottom: '0.65rem' }}>
              <div style={{ padding: '0.45rem', borderRadius: '8px', backgroundColor: '#f0fdf4', color: '#16a34a' }}>
                <Building2 size={18} />
              </div>
              <h4 style={{ fontSize: '0.98rem', fontWeight: '700', color: '#0f172a', margin: 0 }}>Businesses & Sellers</h4>
            </div>
            <p style={{ fontSize: '0.84rem', color: '#64748b', lineHeight: 1.5, marginBottom: '0.75rem' }}>
              Track customer sentiment at scale across entire product portfolios. Pinpoint negative feedback themes and customer satisfaction drivers.
            </p>
            <ul style={{ fontSize: '0.8rem', color: '#475569', paddingLeft: '1.1rem', margin: 0, lineHeight: 1.5 }}>
              <li>Batch upload product review catalogs</li>
              <li>Product-level & category-level breakdowns</li>
              <li>Export clean sentiment reports for stakeholders</li>
            </ul>
          </div>

          {/* Card 3: Academic Researchers */}
          <div className="saas-card" style={{ borderTop: '4px solid #9333ea' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.65rem', marginBottom: '0.65rem' }}>
              <div style={{ padding: '0.45rem', borderRadius: '8px', backgroundColor: '#faf5ff', color: '#9333ea' }}>
                <GraduationCap size={18} />
              </div>
              <h4 style={{ fontSize: '0.98rem', fontWeight: '700', color: '#0f172a', margin: 0 }}>Academic Researchers</h4>
            </div>
            <p style={{ fontSize: '0.84rem', color: '#64748b', lineHeight: 1.5, marginBottom: '0.75rem' }}>
              Explore applied text mining and compare machine learning classifiers (Naive Bayes, SVM, KNN) on actual text corpora.
            </p>
            <ul style={{ fontSize: '0.8rem', color: '#475569', paddingLeft: '1.1rem', margin: 0, lineHeight: 1.5 }}>
              <li>Inspect step-by-step R text preprocessing</li>
              <li>TF-IDF & Document-Term Matrix extraction</li>
              <li>Confusion matrices, Accuracy, F1-scores</li>
            </ul>
          </div>
        </div>
      </div>

      {/* WORKFLOW ACTION CARDS */}
      <div style={{ marginBottom: '2rem' }}>
        <h3 style={{ fontSize: '0.92rem', fontWeight: '700', color: '#0f172a', marginBottom: '1rem', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
          Select Workflow
        </h3>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: '1.25rem' }}>
          {/* Action 1: Workflow A Single Review Analyzer */}
          <div className="saas-card" style={{ borderLeft: '4px solid #3b82f6', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.5rem' }}>
                <div style={{ padding: '0.5rem', borderRadius: '8px', backgroundColor: '#eff6ff', color: '#2563eb' }}>
                  <MessageSquare size={20} />
                </div>
                <div>
                  <span style={{ fontSize: '0.68rem', fontWeight: 700, color: '#2563eb', textTransform: 'uppercase' }}>Workflow A</span>
                  <h4 style={{ fontSize: '1rem', fontWeight: '700', color: '#0f172a', margin: 0 }}>Review Analyzer</h4>
                </div>
              </div>
              <p style={{ fontSize: '0.84rem', color: '#64748b', marginBottom: '1rem' }}>
                Paste an individual customer review to get instant sentiment classification, keyword extraction, and buyer insight.
              </p>
            </div>
            <button className="btn btn-primary btn-md" onClick={() => navigate('/analyzer')} style={{ width: '100%' }}>
              <MessageSquare size={16} /> Open Review Analyzer
            </button>
          </div>

          {/* Action 2: Multi-Review Comparison */}
          <div className="saas-card" style={{ borderLeft: '4px solid #8b5cf6', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.5rem' }}>
                <div style={{ padding: '0.5rem', borderRadius: '8px', backgroundColor: '#f5f3ff', color: '#8b5cf6' }}>
                  <Layers size={20} />
                </div>
                <div>
                  <span style={{ fontSize: '0.68rem', fontWeight: 700, color: '#8b5cf6', textTransform: 'uppercase' }}>Comparative</span>
                  <h4 style={{ fontSize: '1rem', fontWeight: '700', color: '#0f172a', margin: 0 }}>Compare Reviews</h4>
                </div>
              </div>
              <p style={{ fontSize: '0.84rem', color: '#64748b', marginBottom: '1rem' }}>
                Paste 2 to 5 reviews for the same product to calculate collective consensus, repeated strengths, and complaints.
              </p>
            </div>
            <button className="btn btn-outline btn-md" onClick={() => navigate('/compare')} style={{ width: '100%' }}>
              <Layers size={16} /> Compare Reviews
            </button>
          </div>

          {/* Action 3: Workflow B Bulk Dataset Upload */}
          <div className="saas-card" style={{ borderLeft: '4px solid #10b981', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.5rem' }}>
                <div style={{ padding: '0.5rem', borderRadius: '8px', backgroundColor: '#ecfdf5', color: '#10b981' }}>
                  <Upload size={20} />
                </div>
                <div>
                  <span style={{ fontSize: '0.68rem', fontWeight: 700, color: '#10b981', textTransform: 'uppercase' }}>Workflow B</span>
                  <h4 style={{ fontSize: '1rem', fontWeight: '700', color: '#0f172a', margin: 0 }}>Bulk Dataset Analysis</h4>
                </div>
              </div>
              <p style={{ fontSize: '0.84rem', color: '#64748b', marginBottom: '1rem' }}>
                Upload customer review datasets (CSV/TXT) for batch preprocessing, TF-IDF text mining, and ML model training.
              </p>
            </div>
            <button className="btn btn-secondary btn-md" onClick={() => navigate('/upload')} style={{ width: '100%' }}>
              <Upload size={16} /> Upload Dataset
            </button>
          </div>

          {/* Action 4: Quick Demos */}
          <div className="saas-card" style={{ borderLeft: '4px solid #f59e0b', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.5rem' }}>
                <div style={{ padding: '0.5rem', borderRadius: '8px', backgroundColor: '#fffbeb', color: '#f59e0b' }}>
                  <Sparkles size={20} />
                </div>
                <div>
                  <span style={{ fontSize: '0.68rem', fontWeight: 700, color: '#f59e0b', textTransform: 'uppercase' }}>Demonstration</span>
                  <h4 style={{ fontSize: '1rem', fontWeight: '700', color: '#0f172a', margin: 0 }}>1-Click Demos</h4>
                </div>
              </div>
              <p style={{ fontSize: '0.84rem', color: '#64748b', marginBottom: '1rem' }}>
                Test the complete R backend with pre-loaded product datasets and verified sentiment labels.
              </p>
            </div>
            <div style={{ display: 'flex', gap: '0.5rem' }}>
              <button className="btn btn-primary btn-sm" onClick={handleRunLabeledDemo} style={{ flex: 1 }}>
                Supervised Demo
              </button>
              <button className="btn btn-outline btn-sm" onClick={handleRunUnlabeledDemo} style={{ flex: 1 }}>
                Lexicon Demo
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* PIPELINE STEPPER */}
      <div style={{ marginBottom: '2rem' }}>
        <h3 style={{ fontSize: '0.92rem', fontWeight: '700', color: '#0f172a', marginBottom: '0.75rem', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
          Bulk Pipeline Progress
        </h3>
        <WorkflowStepper />
      </div>

      {/* KPI CARDS GRID */}
      <div style={{ marginBottom: '2rem' }}>
        <h3 style={{ fontSize: '0.92rem', fontWeight: '700', color: '#0f172a', marginBottom: '1rem', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
          Analytics Key Performance Indicators (KPIs)
        </h3>
        <div className="kpi-grid">
          <KpiCard
            label="Total Reviews Analyzed"
            value={isLoaded ? summaryData?.total_reviews || kpis?.Total : '--'}
            icon={MessageSquare}
            variant="primary"
          />
          <KpiCard
            label="Positive Reviews"
            value={isLoaded && kpis ? `${kpis.Pos_Count} (${kpis.Pos_Pct}%)` : '--'}
            icon={Smile}
            variant="pos"
          />
          <KpiCard
            label="Neutral Reviews"
            value={isLoaded && kpis ? `${kpis.Neu_Count} (${kpis.Neu_Pct}%)` : '--'}
            icon={Meh}
            variant="neu"
          />
          <KpiCard
            label="Negative Reviews"
            value={isLoaded && kpis ? `${kpis.Neg_Count} (${kpis.Neg_Pct}%)` : '--'}
            icon={Frown}
            variant="neg"
          />
          <KpiCard
            label="Products Identified"
            value={isLoaded && numProducts > 0 ? numProducts : isLoaded ? '1 Portfolio' : '--'}
            icon={Package}
            variant="primary"
          />
          <KpiCard
            label="Unique Vocabulary Terms"
            value={isLoaded && summaryData?.unique_terms ? summaryData.unique_terms : '--'}
            icon={Hash}
            variant="primary"
          />
          <KpiCard
            label="Best ML Algorithm"
            value={isLabeled && summaryData?.best_model ? summaryData.best_model : isLoaded ? 'Lexicon/AFINN' : '--'}
            icon={Award}
            variant="primary"
          />
          <KpiCard
            label="Best Model Accuracy"
            value={isLabeled && summaryData?.best_accuracy ? summaryData.best_accuracy : '--'}
            icon={Award}
            variant="pos"
          />
        </div>
      </div>

      {/* PRODUCT-WISE SENTIMENT TABLE (When Product Summaries Exist) */}
      {isLoaded && productSummaries && productSummaries.length > 0 && (
        <div className="saas-card" style={{ marginBottom: '2rem' }}>
          <div className="card-header-clean">
            <div>
              <h3 className="card-title-clean">Product-Level Sentiment Breakdown</h3>
              <p className="card-subtitle-clean">Aggregated sentiment, ratings, and common themes per product</p>
            </div>
            <button className="btn btn-outline btn-sm" onClick={() => navigate('/visualization')}>
              View Charts <ArrowRight size={14} />
            </button>
          </div>
          <div style={{ overflowX: 'auto' }}>
            <table className="data-table" style={{ width: '100%', fontSize: '0.85rem' }}>
              <thead>
                <tr>
                  <th>Product Name</th>
                  <th>Category</th>
                  <th>Total Reviews</th>
                  <th>Avg Rating</th>
                  <th>Positive</th>
                  <th>Neutral</th>
                  <th>Negative</th>
                  <th>Satisfaction Ratio</th>
                </tr>
              </thead>
              <tbody>
                {productSummaries.map((p, idx) => {
                  const posPct = p.positive_pct || (p.total > 0 ? Math.round((p.positive / p.total) * 100) : 0);
                  const negPct = p.negative_pct || (p.total > 0 ? Math.round((p.negative / p.total) * 100) : 0);
                  return (
                    <tr key={idx}>
                      <td style={{ fontWeight: '600', color: '#0f172a' }}>{p.product}</td>
                      <td>
                        <span style={{ fontSize: '0.75rem', padding: '2px 8px', borderRadius: '12px', background: '#f1f5f9', color: '#475569' }}>
                          {p.category || 'General'}
                        </span>
                      </td>
                      <td>{p.total}</td>
                      <td>{p.avg_rating > 0 ? `★ ${p.avg_rating}` : 'N/A'}</td>
                      <td style={{ color: '#16a34a', fontWeight: '600' }}>{p.positive} ({posPct}%)</td>
                      <td style={{ color: '#2563eb' }}>{p.neutral}</td>
                      <td style={{ color: '#dc2626', fontWeight: '600' }}>{p.negative} ({negPct}%)</td>
                      <td>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                          <div style={{ flex: 1, height: '6px', borderRadius: '3px', background: '#e2e8f0', overflow: 'hidden' }}>
                            <div style={{ width: `${posPct}%`, height: '100%', background: '#16a34a' }}></div>
                          </div>
                          <span style={{ fontSize: '0.75rem', color: '#475569', minWidth: '32px' }}>{posPct}%</span>
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>
      )}

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

