import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { api } from '../services/api';

const AnalysisContext = createContext();

export const AnalysisProvider = ({ children }) => {
  // Global State
  const [apiConnected, setApiConnected] = useState(false);
  const [loading, setLoading] = useState(false);
  const [loadingText, setLoadingText] = useState('');
  const [toasts, setToasts] = useState([]);
  
  // Dataset & Metadata
  const [datasetMetadata, setDatasetMetadata] = useState(null);
  const [textColumn, setTextColumn] = useState('');
  const [labelColumn, setLabelColumn] = useState('');
  const [productColumn, setProductColumn] = useState('');
  const [categoryColumn, setCategoryColumn] = useState('');
  const [ratingColumn, setRatingColumn] = useState('');
  
  // Pipeline Step Results
  const [validationResults, setValidationResults] = useState(null);
  const [preprocessingResults, setPreprocessingResults] = useState(null);
  const [textMiningResults, setTextMiningResults] = useState(null);
  const [sentimentResults, setSentimentResults] = useState(null);
  const [modelResults, setModelResults] = useState(null);
  const [evaluationResults, setEvaluationResults] = useState(null);
  const [visualizationResults, setVisualizationResults] = useState(null);
  const [insightsResults, setInsightsResults] = useState(null);
  const [productSummaries, setProductSummaries] = useState(null);
  const [modelInfo, setModelInfo] = useState(null);

  // Workflow A & Comparison States
  const [singleReviewAnalysis, setSingleReviewAnalysis] = useState(null);
  const [multiReviewAnalysis, setMultiReviewAnalysis] = useState(null);
  
  // Status Flags
  const [pipelineStatus, setPipelineStatus] = useState({
    uploaded: false,
    validated: false,
    preprocessed: false,
    text_mined: false,
    sentiment_analyzed: false,
    ml_trained: false,
    evaluated: false,
    insights_generated: false,
    is_labeled: false,
    is_demo: false,
  });

  const addToast = useCallback((message, type = 'info') => {
    const id = Date.now() + Math.random();
    setToasts((prev) => [...prev, { id, message, type }]);
    setTimeout(() => {
      setToasts((prev) => prev.filter((t) => t.id !== id));
    }, 4500);
  }, []);

  const removeToast = useCallback((id) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  }, []);

  const checkApiHealth = useCallback(async () => {
    try {
      const res = await api.getHealth();
      if (res.success) {
        setApiConnected(true);
        if (res.status) setPipelineStatus(res.status);
      } else {
        setApiConnected(false);
      }
    } catch (err) {
      setApiConnected(false);
    }
  }, []);

  useEffect(() => {
    checkApiHealth();
    const interval = setInterval(checkApiHealth, 15000);
    return () => clearInterval(interval);
  }, [checkApiHealth]);

  const updateFromStatePayload = (data) => {
    if (data.status) setPipelineStatus(data.status);
    if (data.validation) setValidationResults(data.validation);
    if (data.stats) setPreprocessingResults(data);
    if (data.text_mining) setTextMiningResults(data.text_mining);
    if (data.sentiment) setSentimentResults(data.sentiment);
    if (data.ml_evaluation) setEvaluationResults(data.ml_evaluation);
    if (data.insights) setInsightsResults(data.insights);
    if (data.sentiment?.product_summaries) setProductSummaries(data.sentiment.product_summaries);
  };

  const fetchModelInfo = async () => {
    try {
      const res = await api.getModelInfo();
      if (res.success) {
        setModelInfo(res.data);
      }
    } catch (err) {
      console.error('Error fetching model info:', err);
    }
  };

  const resetAll = async () => {
    setLoading(true);
    setLoadingText('Resetting analysis session...');
    try {
      await api.resetAnalysis();
      setDatasetMetadata(null);
      setTextColumn('');
      setLabelColumn('');
      setProductColumn('');
      setCategoryColumn('');
      setRatingColumn('');
      setValidationResults(null);
      setPreprocessingResults(null);
      setTextMiningResults(null);
      setSentimentResults(null);
      setModelResults(null);
      setEvaluationResults(null);
      setVisualizationResults(null);
      setInsightsResults(null);
      setProductSummaries(null);
      setModelInfo(null);
      setSingleReviewAnalysis(null);
      setMultiReviewAnalysis(null);
      setPipelineStatus({
        uploaded: false,
        validated: false,
        preprocessed: false,
        text_mined: false,
        sentiment_analyzed: false,
        ml_trained: false,
        evaluated: false,
        insights_generated: false,
        is_labeled: false,
        is_demo: false,
      });
      addToast('Analysis reset successfully.', 'success');
    } catch (err) {
      addToast('Failed to reset analysis: ' + (err.response?.data?.message || err.message), 'error');
    } finally {
      setLoading(false);
    }
  };

  return (
    <AnalysisContext.Provider
      value={{
        apiConnected,
        checkApiHealth,
        loading,
        setLoading,
        loadingText,
        setLoadingText,
        toasts,
        addToast,
        removeToast,
        datasetMetadata,
        setDatasetMetadata,
        textColumn,
        setTextColumn,
        labelColumn,
        setLabelColumn,
        productColumn,
        setProductColumn,
        categoryColumn,
        setCategoryColumn,
        ratingColumn,
        setRatingColumn,
        validationResults,
        setValidationResults,
        preprocessingResults,
        setPreprocessingResults,
        textMiningResults,
        setTextMiningResults,
        sentimentResults,
        setSentimentResults,
        productSummaries,
        setProductSummaries,
        modelInfo,
        setModelInfo,
        fetchModelInfo,
        singleReviewAnalysis,
        setSingleReviewAnalysis,
        multiReviewAnalysis,
        setMultiReviewAnalysis,
        modelResults,
        setModelResults,
        evaluationResults,
        setEvaluationResults,
        visualizationResults,
        setVisualizationResults,
        insightsResults,
        setInsightsResults,
        pipelineStatus,
        setPipelineStatus,
        updateFromStatePayload,
        resetAll,
      }}
    >
      {children}
    </AnalysisContext.Provider>
  );
};

export const useAnalysis = () => useContext(AnalysisContext);
