import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';

const client = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 60000,
});

export const api = {
  getHealth: async () => {
    const res = await client.get('/health');
    return res.data;
  },

  // Workflow A: Individual Product Review Analyzer
  analyzeReview: async (reviewData) => {
    const res = await client.post('/analyze-review', reviewData);
    return res.data;
  },

  // Compare Multiple Reviews for a Product
  analyzeReviews: async (multiData) => {
    const res = await client.post('/analyze-reviews', multiData);
    return res.data;
  },

  // Machine Learning Model Status & Capabilities
  getModelInfo: async () => {
    const res = await client.get('/model-info');
    return res.data;
  },

  // Product-Level & Category-Level Dataset Summaries
  getProductSummary: async () => {
    const res = await client.get('/product-summary');
    return res.data;
  },

  uploadDataset: async (fileContent, filename) => {
    const res = await client.post('/upload', {
      filename: filename,
      file_content: fileContent,
    });
    return res.data;
  },

  validateDataset: async (textColumn, labelColumn, productColumn, categoryColumn, ratingColumn) => {
    const res = await client.post('/validate', {
      text_column: textColumn,
      label_column: labelColumn,
      product_column: productColumn,
      category_column: categoryColumn,
      rating_column: ratingColumn,
    });
    return res.data;
  },

  preprocessData: async (removeStopwords = true, performStemming = true) => {
    const res = await client.post('/preprocess', {
      remove_stopwords: removeStopwords,
      perform_stemming: performStemming,
    });
    return res.data;
  },

  runTextMining: async (topN = 50) => {
    const res = await client.post('/text-mining', { top_n: topN });
    return res.data;
  },

  runSentiment: async () => {
    const res = await client.post('/sentiment', {});
    return res.data;
  },

  runNaiveBayes: async () => {
    const res = await client.post('/train/naive-bayes', {});
    return res.data;
  },

  runSVM: async () => {
    const res = await client.post('/train/svm', {});
    return res.data;
  },

  runKNN: async (k = 5) => {
    const res = await client.post('/train/knn', { k });
    return res.data;
  },

  runAllModels: async () => {
    const res = await client.post('/train/all', {});
    return res.data;
  },

  evaluateModels: async () => {
    const res = await client.get('/evaluate');
    return res.data;
  },

  getVisualizationData: async () => {
    const res = await client.get('/visualization-data');
    return res.data;
  },

  getInsights: async () => {
    const res = await client.get('/insights');
    return res.data;
  },

  getResults: async () => {
    const res = await client.get('/results');
    return res.data;
  },

  resetAnalysis: async () => {
    const res = await client.post('/reset', {});
    return res.data;
  },

  runLabeledDemo: async () => {
    const res = await client.post('/demo/labeled', {});
    return res.data;
  },

  runUnlabeledDemo: async () => {
    const res = await client.post('/demo/unlabeled', {});
    return res.data;
  },

  getDownloadUrl: (endpoint) => `${API_BASE_URL}/download/${endpoint}`
};
