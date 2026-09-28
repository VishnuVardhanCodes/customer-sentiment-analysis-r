import React, { useEffect, useState } from 'react';
import { useAnalysis } from '../context/AnalysisContext';
import { api } from '../services/api';
import PageHeader from '../components/PageHeader';
import DownloadCard from '../components/DownloadCard';
import LoadingState from '../components/LoadingState';
import { Download, FileSpreadsheet, FileText, CheckCircle2 } from 'lucide-react';

const ResultsDownload = () => {
  const { pipelineStatus, loading, setLoading, loadingText } = useAnalysis();
  const [downloadFlags, setDownloadFlags] = useState({
    processed: false,
    sentiment: false,
    models: false,
    insights: false,
    complete: false,
  });

  useEffect(() => {
    fetchResults();
  }, [pipelineStatus]);

  const fetchResults = async () => {
    try {
      const res = await api.getResults();
      if (res.success && res.data.available_downloads) {
        setDownloadFlags(res.data.available_downloads);
      }
    } catch (err) {
      console.error(err);
    }
  };

  if (loading) {
    return <LoadingState message={loadingText} />;
  }

  return (
    <div>
      <PageHeader
        title="Results & Data Export Center"
        subtitle="Export clean preprocessed datasets, lexicon sentiment scores, model comparison benchmarks, and text reports."
      />

      {/* DOWNLOAD CARDS GRID */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '1.5rem', marginBottom: '2rem' }}>
        {/* Card 1: Processed Dataset */}
        <DownloadCard
          title="Preprocessed Dataset"
          description="Cleaned customer reviews with URLs, stopwords, and punctuation removed, plus stemmed terms."
          format="CSV"
          endpoint="processed"
          available={downloadFlags.processed || pipelineStatus.preprocessed}
        />

        {/* Card 2: Sentiment Results */}
        <DownloadCard
          title="Sentiment Analysis Results"
          description="Dataset augmented with Bing lexicon numerical sentiment scores and Positive/Neutral/Negative labels."
          format="CSV"
          endpoint="sentiment"
          available={downloadFlags.sentiment || pipelineStatus.sentiment_analyzed}
        />

        {/* Card 3: Model Performance */}
        <DownloadCard
          title="Machine Learning Metrics"
          description="Comparative accuracy, precision, recall, and F1-score evaluation metrics across NB, SVM, and KNN."
          format="CSV"
          endpoint="models"
          available={downloadFlags.models || pipelineStatus.evaluated}
        />

        {/* Card 4: Customer Insights */}
        <DownloadCard
          title="Customer Insights Report"
          description="Executive summary document detailing positive themes, complaint drivers, and strategic recommendations."
          format="TXT"
          endpoint="insights"
          available={downloadFlags.insights || pipelineStatus.insights_generated}
        />

        {/* Card 5: Complete Analysis Package */}
        <DownloadCard
          title="Complete Combined Analysis"
          description="Full dataset export combining original reviews, preprocessed text, sentiment scores, and model classifications."
          format="CSV"
          endpoint="complete"
          available={downloadFlags.complete || pipelineStatus.sentiment_analyzed}
        />
      </div>

      {/* SUMMARY CHECKS */}
      <div className="saas-card">
        <h3 className="card-title-clean" style={{ marginBottom: '1rem' }}>
          <CheckCircle2 color="#16a34a" size={20} /> Academic Methodology Compliance Verification
        </h3>
        <div style={{ fontSize: '0.88rem', color: '#475569', lineHeight: '1.6' }}>
          <p style={{ marginBottom: '0.5rem' }}>
            <strong>Project Title:</strong> LG9 – Customer Sentiment Analysis from Social Media using Text Mining in R
          </p>
          <p style={{ marginBottom: '0.5rem' }}>
            <strong>Backend Architecture:</strong> RESTful API powered by R Plumber server delivering statistical analytics.
          </p>
          <p style={{ marginBottom: '0.5rem' }}>
            <strong>Algorithms Implemented:</strong> Syuzhet Bing Lexicon Scoring, Document-Term Matrix (DTM), TF-IDF Feature Extraction, Naive Bayes, Support Vector Machine (SVM), and K-Nearest Neighbors (KNN).
          </p>
        </div>
      </div>
    </div>
  );
};

export default ResultsDownload;
