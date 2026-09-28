import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { AnalysisProvider } from './context/AnalysisContext';
import MainLayout from './layouts/MainLayout';
import Dashboard from './pages/Dashboard';
import UploadData from './pages/UploadData';
import DataValidation from './pages/DataValidation';
import Preprocessing from './pages/Preprocessing';
import TextMining from './pages/TextMining';
import SentimentAnalysis from './pages/SentimentAnalysis';
import MachineLearning from './pages/MachineLearning';
import ModelEvaluation from './pages/ModelEvaluation';
import Visualization from './pages/Visualization';
import CustomerInsights from './pages/CustomerInsights';
import ResultsDownload from './pages/ResultsDownload';

function App() {
  return (
    <AnalysisProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<MainLayout />}>
            <Route index element={<Dashboard />} />
            <Route path="upload" element={<UploadData />} />
            <Route path="validation" element={<DataValidation />} />
            <Route path="preprocessing" element={<Preprocessing />} />
            <Route path="text-mining" element={<TextMining />} />
            <Route path="sentiment" element={<SentimentAnalysis />} />
            <Route path="machine-learning" element={<MachineLearning />} />
            <Route path="evaluation" element={<ModelEvaluation />} />
            <Route path="visualization" element={<Visualization />} />
            <Route path="insights" element={<CustomerInsights />} />
            <Route path="results" element={<ResultsDownload />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </AnalysisProvider>
  );
}

export default App;
