import React, { useState } from 'react';
import PageHeader from '../components/PageHeader';
import {
  BrainCircuit,
  Sliders,
  CheckCircle2,
  FileText,
  BarChart3,
  PieChart,
  Lightbulb,
  ArrowDown,
  Layers,
  Sparkles,
  ShieldCheck,
  Code,
  BookOpen,
  HelpCircle,
} from 'lucide-react';
import { Link } from 'react-router-dom';

const pipelineStages = [
  {
    step: '01',
    title: 'Input & Data Validation',
    file: 'backend/R/validation.R',
    description:
      'Receives customer review text or bulk CSV datasets. Validates non-empty content, identifies text columns, optional product names, categories, ratings, and ground-truth sentiment labels.',
    badge: 'Input Verification',
    color: '#2563eb',
  },
  {
    step: '02',
    title: 'Text Preprocessing & Cleaning',
    file: 'backend/R/preprocessing.R',
    description:
      'Converts text to lowercase, removes URLs, emails, @mentions, punctuation, and non-ASCII artifacts. Crucially preserves sentiment negation terms (e.g. "not", "no", "never") to maintain accurate polarity.',
    badge: 'Text Normalization',
    color: '#0891b2',
  },
  {
    step: '03',
    title: 'Tokenization & Stop-Word Removal',
    file: 'backend/R/preprocessing.R',
    description:
      'Tokenizes sentences into individual word vectors, filters uninformative English stop words, and applies Porter stemming via the SnowballC package in R to reduce words to root morphological stems.',
    badge: 'Morphological Reduction',
    color: '#0d9488',
  },
  {
    step: '04',
    title: 'TF-IDF & Feature Extraction (DTM)',
    file: 'backend/R/text_mining.R',
    description:
      'Constructs the Document-Term Matrix (DTM) and calculates Term Frequency - Inverse Document Frequency (TF-IDF) weights, converting textual reviews into numerical vector spaces suitable for machine learning algorithms.',
    badge: 'Vector Space Representation',
    color: '#7c3aed',
  },
  {
    step: '05',
    title: 'Supervised ML Training & Lexicon Scoring',
    file: 'backend/R/machine_learning.R & sentiment_analysis.R',
    description:
      'Trains supervised classification algorithms (Linear SVM, Naive Bayes, K-Nearest Neighbors) on labeled datasets using an 80/20 train/test split. When unlabeled, utilizes Syuzhet Bing lexicon scoring.',
    badge: 'Core ML & Analytics',
    color: '#16a34a',
  },
  {
    step: '06',
    title: 'Sentiment Prediction & Classification',
    file: 'backend/R/machine_learning.R',
    description:
      'Maps input feature vectors onto trained decision hyperplanes (SVM) or conditional probabilities (Naive Bayes) to classify reviews into Positive, Neutral, or Negative classes with calibrated confidence scores.',
    badge: 'Inference Engine',
    color: '#d97706',
  },
  {
    step: '07',
    title: 'Rigorous Model Evaluation',
    file: 'backend/R/evaluation.R',
    description:
      'Evaluates model performance on held-out test data using Accuracy, Macro-Precision, Macro-Recall, and F1-Score metrics, constructing full Confusion Matrices to assess misclassifications.',
    badge: 'Quality Assessment',
    color: '#dc2626',
  },
  {
    step: '08',
    title: 'Visualization & Evidence-Based Buyer Insights',
    file: 'backend/R/insights.R & visualization.R',
    description:
      'Extracts keyword drivers, creates interactive visual charts, and synthesizes grounded explanations and potential buyer purchase considerations without making unsupported purchasing decrees.',
    badge: 'Decision Support',
    color: '#2563eb',
  },
];

const algorithms = [
  {
    name: 'Support Vector Machine (SVM)',
    type: 'Supervised Learning',
    kernel: 'Linear Kernel (e1071 in R)',
    strengths: 'Excels in high-dimensional sparse TF-IDF text spaces; robust against overfitting.',
    useCase: 'Primary supervised classifier for customer reviews when labeled data is present.',
  },
  {
    name: 'Naive Bayes (NB)',
    type: 'Supervised Learning',
    kernel: 'Multinomial / Gaussian (e1071 in R)',
    strengths: 'Fast probabilistic classifier based on Bayes theorem with conditional independence assumption.',
    useCase: 'Benchmarking word conditional probabilities across positive and negative sentiment classes.',
  },
  {
    name: 'K-Nearest Neighbors (KNN)',
    type: 'Supervised Learning',
    kernel: 'Euclidean Distance (k=5, class in R)',
    strengths: 'Non-parametric instance-based learning; clusters similar review feature vectors.',
    useCase: 'Comparing geometric proximity of review embeddings.',
  },
  {
    name: 'Bing Lexicon Scoring',
    type: 'Lexicon-Based (Unsupervised)',
    kernel: 'Dictionary Polarity (Syuzhet & Tidytext in R)',
    strengths: 'Requires no prior training labels; scores polarity directly based on verified sentiment words.',
    useCase: 'Individual review analysis fallback and exploratory analysis of unlabeled customer datasets.',
  },
];

const HowItWorks = () => {
  const [selectedStage, setSelectedStage] = useState(0);

  return (
    <div>
      <PageHeader
        title="How the Sentiment Analysis Works"
        subtitle="End-to-End Machine Learning Pipeline • Mathematical Formulations • Backend Architecture"
      >
        <Link to="/analyzer" className="btn btn-primary btn-md">
          <Sparkles size={16} /> Try Live Review Analyzer
        </Link>
      </PageHeader>

      {/* CORE FACULTY HIGHLIGHT */}
      <div
        style={{
          backgroundColor: '#f8fafc',
          border: '1px solid #cbd5e1',
          borderLeft: '5px solid #2563eb',
          borderRadius: 'var(--radius-md)',
          padding: '1.25rem 1.5rem',
          marginBottom: '2rem',
        }}
      >
        <h3 style={{ fontSize: '1.05rem', fontWeight: '800', color: '#0f172a', marginBottom: '0.4rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <ShieldCheck size={20} color="#2563eb" /> Where Exactly is Machine Learning Implemented?
        </h3>
        <p style={{ fontSize: '0.9rem', color: '#334155', lineHeight: '1.6', margin: 0 }}>
          Machine learning is implemented natively in <strong>R</strong> via the <strong>R Plumber REST API</strong>.
          Feature extraction transforms preprocessed text into a <strong>TF-IDF Document-Term Matrix</strong> in{' '}
          <code>backend/R/text_mining.R</code>. Supervised model training and test predictions are executed in{' '}
          <code>backend/R/machine_learning.R</code> using algorithms from <code>e1071</code> (SVM and Naive Bayes) and{' '}
          <code>class</code> (KNN). Evaluation metrics (Accuracy, Precision, Recall, F1, Confusion Matrix) are computed in{' '}
          <code>backend/R/evaluation.R</code>.
        </p>
      </div>

      {/* STEP-BY-STEP VISUAL PIPELINE */}
      <div className="saas-card" style={{ marginBottom: '2.5rem' }}>
        <h3 style={{ fontSize: '1.15rem', fontWeight: '800', color: '#0f172a', marginBottom: '1.5rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <Layers size={20} color="#2563eb" /> 8-Stage Architecture Pipeline
        </h3>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '1rem', marginBottom: '2rem' }}>
          {pipelineStages.map((stage, idx) => (
            <div
              key={idx}
              onClick={() => setSelectedStage(idx)}
              style={{
                backgroundColor: selectedStage === idx ? '#eff6ff' : '#ffffff',
                border: `2px solid ${selectedStage === idx ? stage.color : '#e2e8f0'}`,
                borderRadius: 'var(--radius-md)',
                padding: '1rem',
                cursor: 'pointer',
                transition: 'all 0.2s ease',
                position: 'relative',
              }}
            >
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.5rem' }}>
                <span
                  style={{
                    backgroundColor: stage.color,
                    color: '#ffffff',
                    fontSize: '0.75rem',
                    fontWeight: '800',
                    padding: '0.15rem 0.5rem',
                    borderRadius: 'var(--radius-full)',
                  }}
                >
                  STAGE {stage.step}
                </span>
                <span style={{ fontSize: '0.72rem', color: '#64748b', fontWeight: '600' }}>
                  {stage.badge}
                </span>
              </div>
              <h4 style={{ fontSize: '0.95rem', fontWeight: '700', color: '#0f172a', marginBottom: '0.4rem' }}>
                {stage.title}
              </h4>
              <p style={{ fontSize: '0.8rem', color: '#64748b', lineHeight: '1.4', margin: 0 }}>
                {stage.description}
              </p>
            </div>
          ))}
        </div>

        {/* SELECTED STAGE DEEP-DIVE */}
        <div
          style={{
            backgroundColor: '#f8fafc',
            border: '1px solid #e2e8f0',
            borderRadius: 'var(--radius-md)',
            padding: '1.5rem',
          }}
        >
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.75rem', flexWrap: 'wrap', gap: '0.5rem' }}>
            <span style={{ fontSize: '0.85rem', fontWeight: '700', color: pipelineStages[selectedStage].color }}>
              STAGE {pipelineStages[selectedStage].step} DEEP-DIVE
            </span>
            <span style={{ fontSize: '0.8rem', fontFamily: 'var(--font-mono)', color: '#475569', backgroundColor: '#e2e8f0', padding: '0.2rem 0.5rem', borderRadius: '4px' }}>
              File: {pipelineStages[selectedStage].file}
            </span>
          </div>

          <h3 style={{ fontSize: '1.25rem', fontWeight: '800', color: '#0f172a', marginBottom: '0.6rem' }}>
            {pipelineStages[selectedStage].title}
          </h3>

          <p style={{ fontSize: '0.92rem', color: '#334155', lineHeight: '1.6', marginBottom: '1rem' }}>
            {pipelineStages[selectedStage].description}
          </p>

          <div style={{ fontSize: '0.84rem', color: '#64748b' }}>
            <strong>Operational Role:</strong> Ensures that all data passing through the R Plumber analytics server is
            clean, mathematically represented without information leakage, and verifiable for faculty demonstration.
          </div>
        </div>
      </div>

      {/* CLARIFYING OPERATIONAL DISTINCTIONS */}
      <div className="saas-card" style={{ marginBottom: '2.5rem' }}>
        <h3 style={{ fontSize: '1.15rem', fontWeight: '800', color: '#0f172a', marginBottom: '1.25rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <HelpCircle size={20} color="#0891b2" /> Important Technical Distinctions
        </h3>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: '1.25rem' }}>
          <div style={{ backgroundColor: '#ffffff', border: '1px solid #e2e8f0', borderRadius: 'var(--radius-md)', padding: '1.25rem' }}>
            <div style={{ fontWeight: '700', color: '#2563eb', marginBottom: '0.4rem', fontSize: '0.95rem' }}>
              1. Model Training
            </div>
            <p style={{ fontSize: '0.85rem', color: '#475569', lineHeight: '1.5', margin: 0 }}>
              Conducted strictly on labeled datasets. Splits records into 80% train and 20% test sets, learns hyperplane weights (SVM)
              or prior/likelihood tables (NB), and preserves the fitted models in server memory.
            </p>
          </div>

          <div style={{ backgroundColor: '#ffffff', border: '1px solid #e2e8f0', borderRadius: 'var(--radius-md)', padding: '1.25rem' }}>
            <div style={{ fontWeight: '700', color: '#16a34a', marginBottom: '0.4rem', fontSize: '0.95rem' }}>
              2. Model Evaluation
            </div>
            <p style={{ fontSize: '0.85rem', color: '#475569', lineHeight: '1.5', margin: 0 }}>
              Generates predictions for the unseen 20% test set. Compares predicted labels against ground truth to compute Accuracy,
              Macro Precision, Recall, and F1-Score with Confusion Matrices.
            </p>
          </div>

          <div style={{ backgroundColor: '#ffffff', border: '1px solid #e2e8f0', borderRadius: 'var(--radius-md)', padding: '1.25rem' }}>
            <div style={{ fontWeight: '700', color: '#d97706', marginBottom: '0.4rem', fontSize: '0.95rem' }}>
              3. Single Review Prediction
            </div>
            <p style={{ fontSize: '0.85rem', color: '#475569', lineHeight: '1.5', margin: 0 }}>
              Transforms one customer review into the trained vocabulary vector space to predict sentiment using the fitted model,
              or applies Bing lexicon polarity scoring if supervised models are untrained.
            </p>
          </div>

          <div style={{ backgroundColor: '#ffffff', border: '1px solid #e2e8f0', borderRadius: 'var(--radius-md)', padding: '1.25rem' }}>
            <div style={{ fontWeight: '700', color: '#7c3aed', marginBottom: '0.4rem', fontSize: '0.95rem' }}>
              4. Dataset Sentiment Analysis
            </div>
            <p style={{ fontSize: '0.85rem', color: '#475569', lineHeight: '1.5', margin: 0 }}>
              Batch scores every review in an uploaded dataset, aggregating sentiment counts, dominant polarities, product-wise
              summaries, and category-level distributions.
            </p>
          </div>
        </div>
      </div>

      {/* ALGORITHM COMPARISON TABLE */}
      <div className="saas-card" style={{ marginBottom: '2rem' }}>
        <h3 style={{ fontSize: '1.15rem', fontWeight: '800', color: '#0f172a', marginBottom: '1.25rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <BrainCircuit size={20} color="#2563eb" /> Comparison of Machine Learning Algorithms in R
        </h3>

        <div style={{ overflowX: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '0.88rem' }}>
            <thead>
              <tr style={{ backgroundColor: '#f8fafc', borderBottom: '2px solid #e2e8f0', textAlign: 'left' }}>
                <th style={{ padding: '0.75rem', fontWeight: '700', color: '#334155' }}>Algorithm</th>
                <th style={{ padding: '0.75rem', fontWeight: '700', color: '#334155' }}>Learning Paradigm</th>
                <th style={{ padding: '0.75rem', fontWeight: '700', color: '#334155' }}>R Implementation</th>
                <th style={{ padding: '0.75rem', fontWeight: '700', color: '#334155' }}>Core Strengths</th>
                <th style={{ padding: '0.75rem', fontWeight: '700', color: '#334155' }}>Primary Role</th>
              </tr>
            </thead>
            <tbody>
              {algorithms.map((algo, idx) => (
                <tr key={idx} style={{ borderBottom: '1px solid #e2e8f0' }}>
                  <td style={{ padding: '0.85rem', fontWeight: '700', color: '#0f172a' }}>{algo.name}</td>
                  <td style={{ padding: '0.85rem', color: '#475569' }}>
                    <span
                      style={{
                        backgroundColor: algo.type.includes('Supervised') ? '#eff6ff' : '#f0fdf4',
                        color: algo.type.includes('Supervised') ? '#2563eb' : '#16a34a',
                        padding: '0.2rem 0.5rem',
                        borderRadius: 'var(--radius-full)',
                        fontSize: '0.78rem',
                        fontWeight: '600',
                      }}
                    >
                      {algo.type}
                    </span>
                  </td>
                  <td style={{ padding: '0.85rem', fontFamily: 'var(--font-mono)', fontSize: '0.82rem', color: '#334155' }}>
                    {algo.kernel}
                  </td>
                  <td style={{ padding: '0.85rem', color: '#475569', fontSize: '0.82rem' }}>{algo.strengths}</td>
                  <td style={{ padding: '0.85rem', color: '#0f172a', fontWeight: '500', fontSize: '0.82rem' }}>{algo.useCase}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default HowItWorks;
