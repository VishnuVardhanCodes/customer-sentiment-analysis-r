import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAnalysis } from '../context/AnalysisContext';
import { api } from '../services/api';
import PageHeader from '../components/PageHeader';
import ChartCard from '../components/ChartCard';
import SentimentDonutChart from '../charts/SentimentDonutChart';
import WordFreqChart from '../charts/WordFreqChart';
import TfidfChart from '../charts/TfidfChart';
import WordCloudView from '../charts/WordCloudView';
import ModelComparisonChart from '../charts/ModelComparisonChart';
import ConfusionMatrixHeatmap from '../charts/ConfusionMatrixHeatmap';
import ProductSentimentChart from '../charts/ProductSentimentChart';
import EmptyState from '../components/EmptyState';
import LoadingState from '../components/LoadingState';
import { PieChart, ArrowRight } from 'lucide-react';

const Visualization = () => {
  const navigate = useNavigate();
  const {
    loading,
    setLoading,
    loadingText,
    setLoadingText,
    pipelineStatus,
    visualizationResults,
    setVisualizationResults,
    productSummaries,
    categorySummaries,
  } = useAnalysis();

  useEffect(() => {
    if (pipelineStatus.sentiment_analyzed && !visualizationResults) {
      fetchVizData();
    }
  }, [pipelineStatus.sentiment_analyzed, visualizationResults]);

  const fetchVizData = async () => {
    setLoading(true);
    setLoadingText('Loading visualization chart datasets...');
    try {
      const res = await api.getVisualizationData();
      if (res.success) setVisualizationResults(res.data);
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
        <PageHeader title="Analytics Visualizations" subtitle="Interactive charts, word clouds, and comparative model heatmaps." />
        <EmptyState
          title="No Sentiment Results Yet"
          description="Please run sentiment analysis on your dataset to populate the visualization grid."
          actionText="Run Sentiment Analysis"
          onAction={() => navigate('/sentiment')}
          icon={PieChart}
        />
      </div>
    );
  }

  const viz = visualizationResults || {};
  const isLabeled = pipelineStatus.is_labeled;
  const prodData = viz.product_summaries || productSummaries || [];
  const catData = viz.category_summaries || categorySummaries || [];

  return (
    <div>
      <PageHeader
        title="Analytics & Visualization Grid"
        subtitle="Comprehensive visual overview of sentiment distribution, term frequencies, TF-IDF weights, word clouds, product breakdowns, and model metrics."
      >
        <button className="btn btn-primary btn-md" onClick={() => navigate('/insights')}>
          Proceed to Customer Insights <ArrowRight size={16} />
        </button>
      </PageHeader>

      {/* PRODUCT & CATEGORY LEVEL COMPARISON (When Present) */}
      {(prodData.length > 0 || catData.length > 0) && (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(420px, 1fr))', gap: '1.5rem', marginBottom: '2rem' }}>
          {prodData.length > 0 && (
            <ChartCard title="Product-Wise Sentiment Comparison" subtitle="Positive, Neutral, and Negative review counts per product">
              <ProductSentimentChart data={prodData} keyName="product" />
            </ChartCard>
          )}

          {catData.length > 0 && (
            <ChartCard title="Category-Wise Sentiment Comparison" subtitle="Sentiment distribution aggregated by product category">
              <ProductSentimentChart data={catData} keyName="category" />
            </ChartCard>
          )}
        </div>
      )}

      {/* CORE 6-CARD RESPONSIVE GRID */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(420px, 1fr))', gap: '1.5rem', marginBottom: '2rem' }}>
        {/* Card 1: Sentiment Distribution */}
        <ChartCard title="1. Overall Sentiment Distribution" subtitle="Positive, Neutral, and Negative proportions">
          <SentimentDonutChart data={viz.sentiment_distribution || []} />
        </ChartCard>

        {/* Card 2: Top Frequent Words */}
        <ChartCard title="2. Top Frequent Words" subtitle="Highest occurring terms across customer feedback">
          <WordFreqChart data={viz.word_frequencies || []} limit={15} />
        </ChartCard>

        {/* Card 3: TF-IDF Terms */}
        <ChartCard title="3. Top TF-IDF Terms" subtitle="Statistical term importance and discriminative weights">
          <TfidfChart data={viz.tfidf_terms || []} limit={15} />
        </ChartCard>

        {/* Card 4: Word Cloud */}
        <ChartCard title="4. Term Word Cloud" subtitle="Interactive keyword density visualization">
          <WordCloudView data={viz.word_cloud || viz.word_frequencies || []} limit={45} />
        </ChartCard>

        {/* Card 5: Model Comparison (If Labeled) */}
        {isLabeled && viz.model_comparison ? (
          <ChartCard title="5. Machine Learning Comparison" subtitle="Naive Bayes vs SVM vs KNN performance">
            <ModelComparisonChart data={viz.model_comparison} />
          </ChartCard>
        ) : (
          <ChartCard title="5. Model Comparison (N/A)" subtitle="Supervised ML requires ground-truth labels">
            <div style={{ textAlign: 'center', color: '#94a3b8', padding: '2rem' }}>
              Supervised model comparison unavailable for unlabeled datasets.
            </div>
          </ChartCard>
        )}

        {/* Card 6: Confusion Matrix (If Labeled) */}
        {isLabeled && viz.confusion_matrices && viz.confusion_matrices['SVM'] ? (
          <ChartCard title="6. Best Model Confusion Matrix" subtitle="SVM classifier confusion matrix heatmap">
            <ConfusionMatrixHeatmap cmData={viz.confusion_matrices['SVM']} modelName="SVM (Best Model)" />
          </ChartCard>
        ) : (
          <ChartCard title="6. Confusion Matrix (N/A)" subtitle="Classification error matrix">
            <div style={{ textAlign: 'center', color: '#94a3b8', padding: '2rem' }}>
              Confusion matrix heatmap unavailable for unlabeled datasets.
            </div>
          </ChartCard>
        )}
      </div>
    </div>
  );
};

export default Visualization;

