import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAnalysis } from '../context/AnalysisContext';
import { api } from '../services/api';
import PageHeader from '../components/PageHeader';
import ModelCard from '../components/ModelCard';
import EmptyState from '../components/EmptyState';
import LoadingState from '../components/LoadingState';
import { Brain, PlayCircle, ArrowRight, AlertTriangle, ShieldAlert } from 'lucide-react';

const MachineLearning = () => {
  const navigate = useNavigate();
  const {
    loading,
    setLoading,
    loadingText,
    setLoadingText,
    addToast,
    pipelineStatus,
    setPipelineStatus,
    evaluationResults,
    setEvaluationResults,
  } = useAnalysis();

  const [modelStatus, setModelStatus] = useState({
    nb: 'Not Run',
    svm: 'Not Run',
    knn: 'Not Run',
  });

  const [modelMetrics, setModelMetrics] = useState({
    nb: null,
    svm: null,
    knn: null,
  });

  const handleRunNB = async () => {
    setLoading(true);
    setLoadingText('Training Naive Bayes classifier on TF-IDF features in R...');
    setModelStatus((prev) => ({ ...prev, nb: 'Training' }));
    try {
      const res = await api.runNaiveBayes();
      if (res.success) {
        setModelMetrics((prev) => ({ ...prev, nb: res.data.metrics }));
        setModelStatus((prev) => ({ ...prev, nb: 'Completed' }));
        addToast('Naive Bayes training completed!', 'success');
      }
    } catch (err) {
      setModelStatus((prev) => ({ ...prev, nb: 'Error' }));
      addToast('Naive Bayes error: ' + (err.response?.data?.message || err.message), 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleRunSVM = async () => {
    setLoading(true);
    setLoadingText('Training Linear Support Vector Machine (SVM) model in R...');
    setModelStatus((prev) => ({ ...prev, svm: 'Training' }));
    try {
      const res = await api.runSVM();
      if (res.success) {
        setModelMetrics((prev) => ({ ...prev, svm: res.data.metrics }));
        setModelStatus((prev) => ({ ...prev, svm: 'Completed' }));
        addToast('SVM training completed!', 'success');
      }
    } catch (err) {
      setModelStatus((prev) => ({ ...prev, svm: 'Error' }));
      addToast('SVM error: ' + (err.response?.data?.message || err.message), 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleRunKNN = async () => {
    setLoading(true);
    setLoadingText('Training K-Nearest Neighbors (KNN, k=5) classifier in R...');
    setModelStatus((prev) => ({ ...prev, knn: 'Training' }));
    try {
      const res = await api.runKNN(5);
      if (res.success) {
        setModelMetrics((prev) => ({ ...prev, knn: res.data.metrics }));
        setModelStatus((prev) => ({ ...prev, knn: 'Completed' }));
        addToast('KNN training completed!', 'success');
      }
    } catch (err) {
      setModelStatus((prev) => ({ ...prev, knn: 'Error' }));
      addToast('KNN error: ' + (err.response?.data?.message || err.message), 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleRunAll = async () => {
    setLoading(true);
    setLoadingText('Executing Naive Bayes, SVM, and KNN training and comparative evaluation in R...');
    setModelStatus({ nb: 'Training', svm: 'Training', knn: 'Training' });
    try {
      const res = await api.runAllModels();
      if (res.success) {
        setEvaluationResults(res.data);
        setPipelineStatus((prev) => ({
          ...prev,
          ml_trained: true,
          evaluated: true,
        }));
        setModelStatus({ nb: 'Completed', svm: 'Completed', knn: 'Completed' });

        // Update metrics per model
        const compTable = res.data.comparison_table || [];
        const nbM = compTable.find((m) => m.Model === 'Naive Bayes');
        const svmM = compTable.find((m) => m.Model === 'SVM');
        const knnM = compTable.find((m) => m.Model === 'KNN');

        setModelMetrics({
          nb: nbM || null,
          svm: svmM || null,
          knn: knnM || null,
        });

        addToast('All supervised machine-learning models trained successfully!', 'success');
        navigate('/evaluation');
      }
    } catch (err) {
      setModelStatus({ nb: 'Error', svm: 'Error', knn: 'Error' });
      addToast('ML training error: ' + (err.response?.data?.message || err.message), 'error');
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
        <PageHeader title="Supervised Machine Learning" subtitle="Classification using Naive Bayes, SVM, and KNN algorithms." />
        <EmptyState
          title="Upload Dataset First"
          description="Please upload a dataset before running supervised machine learning algorithms."
          actionText="Upload Dataset"
          onAction={() => navigate('/upload')}
        />
      </div>
    );
  }

  const isLabeled = pipelineStatus.is_labeled;

  return (
    <div>
      <PageHeader
        title="Supervised Machine Learning"
        subtitle="Supervised classification models: Naive Bayes, Support Vector Machine (SVM), and K-Nearest Neighbors (KNN)."
      >
        {isLabeled && (
          <button className="btn btn-primary btn-md" onClick={handleRunAll} disabled={loading}>
            <PlayCircle size={16} /> Run All Models
          </button>
        )}
      </PageHeader>

      {/* IF UNLABELED DATASET: SHOW WARNING BANNER */}
      {!isLabeled ? (
        <div className="saas-card" style={{ borderLeft: '4px solid #d97706', backgroundColor: '#fffbeb', marginBottom: '2rem' }}>
          <div style={{ display: 'flex', alignItems: 'flex-start', gap: '1rem' }}>
            <div style={{ padding: '0.5rem', borderRadius: '50%', backgroundColor: '#fef3c7', color: '#d97706' }}>
              <ShieldAlert size={28} />
            </div>
            <div>
              <h3 style={{ fontSize: '1.15rem', fontWeight: '800', color: '#92400e', marginBottom: '0.4rem' }}>
                SUPERVISED ML UNAVAILABLE
              </h3>
              <p style={{ fontSize: '0.9rem', color: '#78350f', lineHeight: '1.5', maxWidth: '680px' }}>
                Supervised machine-learning algorithms (Naive Bayes, SVM, KNN) require genuine sentiment ground-truth labels for training and testing.
              </p>
              <div style={{ fontSize: '0.82rem', color: '#b45309', marginTop: '0.5rem', fontWeight: '600' }}>
                Academic Integrity Principle: Unlabeled datasets utilize unsupervised Syuzhet Bing lexicon analysis. No artificial labels are fabricated.
              </div>
              <button className="btn btn-primary btn-sm" onClick={() => navigate('/sentiment')} style={{ marginTop: '1rem' }}>
                View Lexicon Sentiment Results <ArrowRight size={14} />
              </button>
            </div>
          </div>
        </div>
      ) : (
        /* MODEL CARDS GRID */
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '1.5rem', marginBottom: '2rem' }}>
          <ModelCard
            title="Naive Bayes"
            algorithm="e1071::naiveBayes"
            description="Probabilistic classifier based on Bayes' theorem assuming independence between TF-IDF feature terms."
            onRun={handleRunNB}
            status={modelStatus.nb}
            metrics={modelMetrics.nb}
            loading={loading}
          />

          <ModelCard
            title="Support Vector Machine"
            algorithm="e1071::svm (Linear Kernel)"
            description="Constructs optimal hyperplanes in high-dimensional TF-IDF space to maximize margin between classes."
            onRun={handleRunSVM}
            status={modelStatus.svm}
            metrics={modelMetrics.svm}
            loading={loading}
          />

          <ModelCard
            title="K-Nearest Neighbors"
            algorithm="class::knn (k = 5)"
            description="Non-parametric instance-based classifier assigning labels based on majority vote of nearest neighbor vectors."
            onRun={handleRunKNN}
            status={modelStatus.knn}
            metrics={modelMetrics.knn}
            loading={loading}
          />
        </div>
      )}
    </div>
  );
};

export default MachineLearning;
