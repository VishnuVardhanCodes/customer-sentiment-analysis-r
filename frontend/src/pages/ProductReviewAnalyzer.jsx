import React, { useState, useEffect } from 'react';
import { useAnalysis } from '../context/AnalysisContext';
import { api } from '../services/api';
import PageHeader from '../components/PageHeader';
import LoadingState from '../components/LoadingState';
import {
  Sparkles,
  Search,
  RotateCcw,
  Smile,
  Meh,
  Frown,
  Star,
  Tag,
  CheckCircle2,
  AlertTriangle,
  Info,
  Download,
  Sliders,
  BrainCircuit,
  ShoppingBag,
  Layers,
  ArrowRight,
  ExternalLink,
} from 'lucide-react';
import { Link } from 'react-router-dom';

const sampleReviews = [
  {
    label: 'Positive Headphones Review',
    product: 'Sony WH-1000XM5 Wireless Headphones',
    category: 'Audio & Headphones',
    rating: 5,
    text: 'The sound quality is excellent, the battery lasts long, and the product is worth the price.',
  },
  {
    label: 'Negative Headphones Review',
    product: 'Sony WH-1000XM5 Wireless Headphones',
    category: 'Audio & Headphones',
    rating: 1,
    text: 'The battery drains quickly, the sound is poor, and the product stopped working after two days.',
  },
  {
    label: 'Neutral Headphones Review',
    product: 'Sony WH-1000XM5 Wireless Headphones',
    category: 'Audio & Headphones',
    rating: 3,
    text: 'The headphones arrived yesterday. They look fine, but I have not tested the battery yet.',
  },
  {
    label: 'Positive Laptop Review',
    product: 'Apple MacBook Air M2 13-inch',
    category: 'Computers & Laptops',
    rating: 5,
    text: 'Exceptional build quality and outstanding battery performance! Keyboard feels fantastic and display is super sharp.',
  },
  {
    label: 'Skincare Review',
    product: 'CeraVe Hydrating Facial Cleanser',
    category: 'Beauty & Skincare',
    rating: 4,
    text: 'Gentle moisturizing formula that leaves skin feeling clean without any tightness or greasy residue.',
  },
];

const categories = [
  'Audio & Headphones',
  'Smartphones & Mobile Devices',
  'Computers & Laptops',
  'Electronics Accessories',
  'Beauty & Skincare',
  'Fashion & Apparel',
  'Home & Kitchen',
  'Health & Personal Care',
  'General / Other',
];

const ProductReviewAnalyzer = () => {
  const {
    loading,
    setLoading,
    loadingText,
    setLoadingText,
    addToast,
    singleReviewAnalysis,
    setSingleReviewAnalysis,
    modelInfo,
    fetchModelInfo,
  } = useAnalysis();

  const [productName, setProductName] = useState('');
  const [productCategory, setProductCategory] = useState('Audio & Headphones');
  const [reviewText, setReviewText] = useState('');
  const [originalRating, setOriginalRating] = useState('');
  const [modelChoice, setModelChoice] = useState('Auto');

  useEffect(() => {
    fetchModelInfo();
  }, []);

  const handleSelectSample = (sample) => {
    setProductName(sample.product);
    setProductCategory(sample.category);
    setOriginalRating(sample.rating.toString());
    setReviewText(sample.text);
    addToast(`Loaded "${sample.label}"`, 'info');
  };

  const handleClear = () => {
    setProductName('');
    setProductCategory('Audio & Headphones');
    setReviewText('');
    setOriginalRating('');
    setSingleReviewAnalysis(null);
    addToast('Analyzer form cleared.', 'info');
  };

  const handleAnalyze = async () => {
    if (!reviewText.trim()) {
      addToast('Please paste or type a customer review to analyze.', 'error');
      return;
    }

    setLoading(true);
    setLoadingText('Performing text preprocessing and sentiment mining in R Plumber backend...');

    try {
      const payload = {
        product_name: productName.trim() || 'Product',
        product_category: productCategory,
        review_text: reviewText.trim(),
        original_rating: originalRating ? Number(originalRating) : null,
        model_choice: modelChoice,
      };

      const res = await api.analyzeReview(payload);
      if (res.success) {
        setSingleReviewAnalysis(res.data);
        addToast('Review sentiment analyzed successfully!', 'success');
      } else {
        addToast('Analysis failed: ' + res.message, 'error');
      }
    } catch (err) {
      addToast('Backend connection error: ' + (err.response?.data?.message || err.message), 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleDownloadReport = () => {
    if (!singleReviewAnalysis) return;
    const dataStr = 'data:text/json;charset=utf-8,' + encodeURIComponent(JSON.stringify(singleReviewAnalysis, null, 2));
    const downloadAnchor = document.createElement('a');
    downloadAnchor.setAttribute('href', dataStr);
    downloadAnchor.setAttribute('download', `review_analysis_${Date.now()}.json`);
    document.body.appendChild(downloadAnchor);
    downloadAnchor.click();
    downloadAnchor.remove();
    addToast('Analysis report downloaded.', 'success');
  };

  const getSentimentVariant = (sentiment) => {
    if (sentiment === 'Positive') return { color: '#16a34a', bg: '#f0fdf4', border: '#bbf7d0', icon: Smile };
    if (sentiment === 'Negative') return { color: '#dc2626', bg: '#fef2f2', border: '#fecaca', icon: Frown };
    return { color: '#d97706', bg: '#fffbeb', border: '#fef08a', icon: Meh };
  };

  return (
    <div>
      <PageHeader
        title="Product Review Sentiment Analyzer"
        subtitle="Individual Customer Review Evaluation • Grounded Explanations • Potential Buyer Insights"
      >
        <div style={{ display: 'flex', gap: '0.75rem' }}>
          <Link to="/compare" className="btn btn-outline btn-md">
            <Layers size={16} /> Compare Multiple Reviews
          </Link>
          <Link to="/how-it-works" className="btn btn-outline btn-md">
            <BrainCircuit size={16} /> How It Works
          </Link>
        </div>
      </PageHeader>

      {/* QUICK INSTRUCTION ALERT */}
      <div
        style={{
          backgroundColor: '#eff6ff',
          border: '1px solid #bfdbfe',
          borderRadius: 'var(--radius-md)',
          padding: '1rem 1.25rem',
          marginBottom: '1.75rem',
          display: 'flex',
          alignItems: 'flex-start',
          gap: '0.75rem',
        }}
      >
        <Info size={20} color="#2563eb" style={{ flexShrink: 0, marginTop: '2px' }} />
        <div style={{ fontSize: '0.88rem', color: '#1e3a8a', lineHeight: '1.5' }}>
          <strong>For Potential Buyers & Shoppers:</strong> Enter a product name and paste an actual customer review copied
          from an e-commerce platform such as Amazon. The R analytics engine performs text cleaning, stop-word removal,
          keyword extraction, and sentiment prediction to explain what the review communicates before you make a purchasing decision.
        </div>
      </div>

      {/* SAMPLE REVIEWS QUICK INSERTS */}
      <div className="saas-card" style={{ marginBottom: '1.5rem', padding: '1.25rem' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '0.75rem', flexWrap: 'wrap', gap: '0.5rem' }}>
          <span style={{ fontSize: '0.82rem', fontWeight: '700', color: '#475569', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
            Quick-Fill Sample Customer Reviews:
          </span>
          <span style={{ fontSize: '0.78rem', color: '#94a3b8' }}>Click any sample to test instantly</span>
        </div>
        <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
          {sampleReviews.map((sample, idx) => (
            <button
              key={idx}
              type="button"
              className="btn btn-outline btn-sm"
              onClick={() => handleSelectSample(sample)}
              style={{ fontSize: '0.82rem' }}
            >
              <Sparkles size={14} /> {sample.label}
            </button>
          ))}
        </div>
      </div>

      {/* INPUT FORM CONTAINER */}
      <div className="saas-card" style={{ marginBottom: '2rem' }}>
        <h3 style={{ fontSize: '1.1rem', fontWeight: '700', color: '#0f172a', marginBottom: '1.25rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <ShoppingBag size={20} color="#2563eb" /> Review Details & Input
        </h3>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '1.25rem', marginBottom: '1.25rem' }}>
          {/* Product Name */}
          <div>
            <label style={{ display: 'block', fontSize: '0.85rem', fontWeight: '600', color: '#334155', marginBottom: '0.4rem' }}>
              Product Name <span style={{ color: '#94a3b8', fontWeight: '400' }}>(e.g. model or title)</span>
            </label>
            <input
              type="text"
              className="saas-input"
              placeholder="e.g., Sony WH-1000XM5 Wireless Headphones"
              value={productName}
              onChange={(e) => setProductName(e.target.value)}
              style={{ width: '100%', padding: '0.65rem 0.85rem', fontSize: '0.9rem' }}
            />
          </div>

          {/* Product Category */}
          <div>
            <label style={{ display: 'block', fontSize: '0.85rem', fontWeight: '600', color: '#334155', marginBottom: '0.4rem' }}>
              Product Category
            </label>
            <select
              className="saas-input"
              value={productCategory}
              onChange={(e) => setProductCategory(e.target.value)}
              style={{ width: '100%', padding: '0.65rem 0.85rem', fontSize: '0.9rem' }}
            >
              {categories.map((cat, idx) => (
                <option key={idx} value={cat}>
                  {cat}
                </option>
              ))}
            </select>
          </div>

          {/* Optional Original Rating */}
          <div>
            <label style={{ display: 'block', fontSize: '0.85rem', fontWeight: '600', color: '#334155', marginBottom: '0.4rem' }}>
              Original Review Rating <span style={{ color: '#94a3b8', fontWeight: '400' }}>(Optional 1-5 Stars)</span>
            </label>
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              {[1, 2, 3, 4, 5].map((star) => (
                <button
                  key={star}
                  type="button"
                  onClick={() => setOriginalRating(originalRating === star.toString() ? '' : star.toString())}
                  style={{
                    background: 'none',
                    border: 'none',
                    cursor: 'pointer',
                    padding: '0.2rem',
                    color: Number(originalRating) >= star ? '#eab308' : '#cbd5e1',
                    transition: 'color 0.15s ease',
                  }}
                  title={`${star} Star${star > 1 ? 's' : ''}`}
                >
                  <Star size={24} fill={Number(originalRating) >= star ? '#eab308' : 'none'} />
                </button>
              ))}
              <span style={{ fontSize: '0.85rem', color: '#64748b', marginLeft: '0.5rem' }}>
                {originalRating ? `${originalRating} of 5 Stars` : 'None specified'}
              </span>
            </div>
          </div>

          {/* Analysis Algorithm Selector */}
          <div>
            <label style={{ display: 'block', fontSize: '0.85rem', fontWeight: '600', color: '#334155', marginBottom: '0.4rem' }}>
              Sentiment Analysis Method
            </label>
            <select
              className="saas-input"
              value={modelChoice}
              onChange={(e) => setModelChoice(e.target.value)}
              style={{ width: '100%', padding: '0.65rem 0.85rem', fontSize: '0.9rem' }}
            >
              <option value="Auto">Auto (Best Available Engine)</option>
              <option value="Bing Lexicon">Bing Lexicon Polarity (R Syuzhet)</option>
              <option value="SVM" disabled={!modelInfo?.is_trained}>
                Support Vector Machine (SVM) {!modelInfo?.is_trained ? '– [Requires Labeled Model Training]' : ''}
              </option>
              <option value="Naive Bayes" disabled={!modelInfo?.is_trained}>
                Naive Bayes {!modelInfo?.is_trained ? '– [Requires Labeled Model Training]' : ''}
              </option>
              <option value="KNN" disabled={!modelInfo?.is_trained}>
                K-Nearest Neighbors (KNN) {!modelInfo?.is_trained ? '– [Requires Labeled Model Training]' : ''}
              </option>
            </select>
          </div>
        </div>

        {/* Customer Review Textarea */}
        <div style={{ marginBottom: '1.5rem' }}>
          <label style={{ display: 'block', fontSize: '0.85rem', fontWeight: '600', color: '#334155', marginBottom: '0.4rem' }}>
            Customer Review Text <span style={{ color: '#ef4444' }}>*</span>
          </label>
          <textarea
            className="saas-input"
            rows={4}
            placeholder="Paste the customer review text copied from Amazon or another product store..."
            value={reviewText}
            onChange={(e) => setReviewText(e.target.value)}
            style={{ width: '100%', padding: '0.85rem', fontSize: '0.92rem', lineHeight: '1.5' }}
          />
          <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '0.35rem', fontSize: '0.78rem', color: '#94a3b8' }}>
            <span>Real-time text mining and sentiment analysis in R</span>
            <span>{reviewText.trim().split(/\s+/).filter(Boolean).length} words</span>
          </div>
        </div>

        {/* Action Buttons */}
        <div style={{ display: 'flex', gap: '0.75rem', justifyContent: 'flex-end', flexWrap: 'wrap' }}>
          <button type="button" className="btn btn-outline btn-md" onClick={handleClear} disabled={loading}>
            <RotateCcw size={16} /> Reset
          </button>
          <button type="button" className="btn btn-primary btn-md" onClick={handleAnalyze} disabled={loading}>
            {loading ? <span className="spinner-border spinner-border-sm" /> : <Sparkles size={16} />}
            Analyze Review
          </button>
        </div>
      </div>

      {/* ANALYSIS RESULTS SECTION */}
      {singleReviewAnalysis && (
        <div style={{ animation: 'fadeIn 0.3s ease' }}>
          {/* Main Visual Result Card */}
          {(() => {
            const variant = getSentimentVariant(singleReviewAnalysis.predicted_sentiment);
            const SentimentIcon = variant.icon;

            return (
              <div
                style={{
                  backgroundColor: variant.bg,
                  border: `2px solid ${variant.border}`,
                  borderRadius: 'var(--radius-lg)',
                  padding: '1.75rem',
                  marginBottom: '1.75rem',
                  boxShadow: 'var(--shadow-md)',
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '1rem', marginBottom: '1.25rem' }}>
                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '0.4rem' }}>
                      <div
                        style={{
                          backgroundColor: variant.color,
                          color: '#ffffff',
                          padding: '0.5rem',
                          borderRadius: 'var(--radius-md)',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                        }}
                      >
                        <SentimentIcon size={28} />
                      </div>
                      <div>
                        <span style={{ fontSize: '0.8rem', fontWeight: '700', textTransform: 'uppercase', letterSpacing: '0.5px', color: variant.color }}>
                          Predicted Review Sentiment
                        </span>
                        <h2 style={{ fontSize: '1.85rem', fontWeight: '800', color: variant.color, margin: 0, lineHeight: 1.1 }}>
                          {singleReviewAnalysis.predicted_sentiment} Sentiment
                        </h2>
                      </div>
                    </div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', fontSize: '0.88rem', color: '#475569', marginTop: '0.25rem' }}>
                      <span><strong>Product:</strong> {singleReviewAnalysis.product_name}</span>
                      <span>•</span>
                      <span><strong>Category:</strong> {singleReviewAnalysis.product_category}</span>
                      {singleReviewAnalysis.original_rating && (
                        <>
                          <span>•</span>
                          <span style={{ display: 'inline-flex', alignItems: 'center', gap: '0.2rem', color: '#ca8a04', fontWeight: '600' }}>
                            <Star size={15} fill="#ca8a04" /> {singleReviewAnalysis.original_rating} / 5 Stars
                          </span>
                        </>
                      )}
                    </div>
                  </div>

                  <div style={{ textAlign: 'right', display: 'flex', flexDirection: 'column', gap: '0.35rem' }}>
                    <div style={{ backgroundColor: '#ffffff', padding: '0.5rem 1rem', borderRadius: 'var(--radius-md)', border: `1px solid ${variant.border}` }}>
                      <div style={{ fontSize: '0.75rem', color: '#64748b', fontWeight: '600', textTransform: 'uppercase' }}>Confidence / Polarity</div>
                      <div style={{ fontSize: '1.25rem', fontWeight: '700', color: variant.color }}>
                        {singleReviewAnalysis.confidence_score}% Confidence
                      </div>
                      <div style={{ fontSize: '0.75rem', color: '#64748b' }}>
                        Raw Score: {singleReviewAnalysis.sentiment_score > 0 ? `+${singleReviewAnalysis.sentiment_score}` : singleReviewAnalysis.sentiment_score}
                      </div>
                    </div>

                    <button
                      className="btn btn-outline btn-sm"
                      onClick={handleDownloadReport}
                      style={{ fontSize: '0.78rem', justifyContent: 'center' }}
                    >
                      <Download size={14} /> Export Result JSON
                    </button>
                  </div>
                </div>

                {/* POTENTIAL BUYER INSIGHT - HIGHLIGHT BOX */}
                <div
                  style={{
                    backgroundColor: '#ffffff',
                    border: '1px solid var(--surface-border)',
                    borderRadius: 'var(--radius-md)',
                    padding: '1.25rem',
                    marginBottom: '1.25rem',
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.4rem', color: '#0f172a', fontWeight: '700', fontSize: '0.95rem' }}>
                    <CheckCircle2 size={18} color="#2563eb" /> Potential Buyer Insight
                  </div>
                  <p style={{ fontSize: '0.92rem', color: '#1e293b', margin: 0, lineHeight: '1.6' }}>
                    {singleReviewAnalysis.potential_buyer_insight}
                  </p>
                </div>

                {/* REVIEW EXPLANATION */}
                <div
                  style={{
                    backgroundColor: '#ffffff',
                    border: '1px solid var(--surface-border)',
                    borderRadius: 'var(--radius-md)',
                    padding: '1.25rem',
                  }}
                >
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.4rem', color: '#0f172a', fontWeight: '700', fontSize: '0.95rem' }}>
                    <Info size={18} color="#0891b2" /> Grounded Review Explanation
                  </div>
                  <p style={{ fontSize: '0.9rem', color: '#334155', margin: 0, lineHeight: '1.6' }}>
                    {singleReviewAnalysis.explanation}
                  </p>
                </div>
              </div>
            );
          })()}

          {/* TWO COLUMN SUPPORTING DETAILS */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '1.5rem', marginBottom: '1.75rem' }}>
            {/* Left Card: Keyword Mining & Aspects */}
            <div className="saas-card">
              <h4 style={{ fontSize: '1rem', fontWeight: '700', color: '#0f172a', marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <Tag size={18} color="#2563eb" /> Extracted Sentiment Keywords
              </h4>

              {/* Positive Keywords */}
              <div style={{ marginBottom: '1rem' }}>
                <span style={{ fontSize: '0.8rem', fontWeight: '600', color: '#16a34a', display: 'block', marginBottom: '0.4rem' }}>
                  Positive Drivers ({singleReviewAnalysis.positive_keywords?.length || 0}):
                </span>
                <div style={{ display: 'flex', gap: '0.4rem', flexWrap: 'wrap' }}>
                  {singleReviewAnalysis.positive_keywords?.length > 0 ? (
                    singleReviewAnalysis.positive_keywords.map((kw, idx) => (
                      <span
                        key={idx}
                        style={{
                          backgroundColor: '#f0fdf4',
                          border: '1px solid #bbf7d0',
                          color: '#16a34a',
                          padding: '0.25rem 0.6rem',
                          borderRadius: 'var(--radius-full)',
                          fontSize: '0.82rem',
                          fontWeight: '600',
                        }}
                      >
                        +{kw}
                      </span>
                    ))
                  ) : (
                    <span style={{ fontSize: '0.82rem', color: '#94a3b8', fontStyle: 'italic' }}>None detected</span>
                  )}
                </div>
              </div>

              {/* Negative Keywords */}
              <div style={{ marginBottom: '1rem' }}>
                <span style={{ fontSize: '0.8rem', fontWeight: '600', color: '#dc2626', display: 'block', marginBottom: '0.4rem' }}>
                  Negative Drivers ({singleReviewAnalysis.negative_keywords?.length || 0}):
                </span>
                <div style={{ display: 'flex', gap: '0.4rem', flexWrap: 'wrap' }}>
                  {singleReviewAnalysis.negative_keywords?.length > 0 ? (
                    singleReviewAnalysis.negative_keywords.map((kw, idx) => (
                      <span
                        key={idx}
                        style={{
                          backgroundColor: '#fef2f2',
                          border: '1px solid #fecaca',
                          color: '#dc2626',
                          padding: '0.25rem 0.6rem',
                          borderRadius: 'var(--radius-full)',
                          fontSize: '0.82rem',
                          fontWeight: '600',
                        }}
                      >
                        -{kw}
                      </span>
                    ))
                  ) : (
                    <span style={{ fontSize: '0.82rem', color: '#94a3b8', fontStyle: 'italic' }}>None detected</span>
                  )}
                </div>
              </div>

              {/* Product Aspects Mentioned */}
              <div>
                <span style={{ fontSize: '0.8rem', fontWeight: '600', color: '#475569', display: 'block', marginBottom: '0.4rem' }}>
                  Mentioned Product Aspects:
                </span>
                <div style={{ display: 'flex', gap: '0.4rem', flexWrap: 'wrap' }}>
                  {singleReviewAnalysis.mentioned_aspects?.length > 0 ? (
                    singleReviewAnalysis.mentioned_aspects.map((asp, idx) => (
                      <span
                        key={idx}
                        style={{
                          backgroundColor: '#eff6ff',
                          border: '1px solid #bfdbfe',
                          color: '#1d4ed8',
                          padding: '0.25rem 0.6rem',
                          borderRadius: 'var(--radius-full)',
                          fontSize: '0.82rem',
                          fontWeight: '500',
                        }}
                      >
                        {asp}
                      </span>
                    ))
                  ) : (
                    <span style={{ fontSize: '0.82rem', color: '#94a3b8', fontStyle: 'italic' }}>General remarks</span>
                  )}
                </div>
              </div>
            </div>

            {/* Right Card: Text Preprocessing Preview */}
            <div className="saas-card">
              <h4 style={{ fontSize: '1rem', fontWeight: '700', color: '#0f172a', marginBottom: '1rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <Sliders size={18} color="#0891b2" /> Preprocessing Pipeline Preview
              </h4>

              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '0.5rem', marginBottom: '1rem', textAlign: 'center' }}>
                <div style={{ backgroundColor: '#f8fafc', padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid #e2e8f0' }}>
                  <div style={{ fontSize: '0.72rem', color: '#64748b' }}>Raw Words</div>
                  <div style={{ fontSize: '1.1rem', fontWeight: '700', color: '#0f172a' }}>
                    {singleReviewAnalysis.preprocessing_stats?.words_before || 0}
                  </div>
                </div>
                <div style={{ backgroundColor: '#f8fafc', padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid #e2e8f0' }}>
                  <div style={{ fontSize: '0.72rem', color: '#64748b' }}>Cleaned</div>
                  <div style={{ fontSize: '1.1rem', fontWeight: '700', color: '#2563eb' }}>
                    {singleReviewAnalysis.preprocessing_stats?.words_after || 0}
                  </div>
                </div>
                <div style={{ backgroundColor: '#f8fafc', padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid #e2e8f0' }}>
                  <div style={{ fontSize: '0.72rem', color: '#64748b' }}>Filtered Stopwords</div>
                  <div style={{ fontSize: '1.1rem', fontWeight: '700', color: '#d97706' }}>
                    {singleReviewAnalysis.preprocessing_stats?.stopwords_removed || 0}
                  </div>
                </div>
                <div style={{ backgroundColor: '#f8fafc', padding: '0.5rem', borderRadius: 'var(--radius-sm)', border: '1px solid #e2e8f0' }}>
                  <div style={{ fontSize: '0.72rem', color: '#64748b' }}>Clean Tokens</div>
                  <div style={{ fontSize: '1.1rem', fontWeight: '700', color: '#16a34a' }}>
                    {singleReviewAnalysis.preprocessing_stats?.tokens?.length || 0}
                  </div>
                </div>
              </div>

              <div style={{ marginBottom: '0.75rem' }}>
                <span style={{ fontSize: '0.78rem', fontWeight: '600', color: '#64748b' }}>Cleaned & Stemmed Representation:</span>
                <div
                  style={{
                    backgroundColor: '#f8fafc',
                    border: '1px solid #e2e8f0',
                    borderRadius: 'var(--radius-sm)',
                    padding: '0.65rem',
                    fontSize: '0.84rem',
                    fontFamily: 'var(--font-mono)',
                    color: '#334155',
                    marginTop: '0.25rem',
                    wordBreak: 'break-word',
                  }}
                >
                  {singleReviewAnalysis.cleaned_review || '(empty string)'}
                </div>
              </div>

              <div>
                <span style={{ fontSize: '0.78rem', fontWeight: '600', color: '#64748b' }}>Normalized Token Stream:</span>
                <div style={{ display: 'flex', gap: '0.35rem', flexWrap: 'wrap', marginTop: '0.25rem' }}>
                  {singleReviewAnalysis.preprocessing_stats?.tokens?.slice(0, 10).map((tok, idx) => (
                    <span
                      key={idx}
                      style={{
                        backgroundColor: '#f1f5f9',
                        color: '#475569',
                        fontSize: '0.75rem',
                        fontFamily: 'var(--font-mono)',
                        padding: '0.15rem 0.45rem',
                        borderRadius: 'var(--radius-sm)',
                      }}
                    >
                      {tok}
                    </span>
                  ))}
                  {singleReviewAnalysis.preprocessing_stats?.tokens?.length > 10 && (
                    <span style={{ fontSize: '0.75rem', color: '#94a3b8' }}>
                      +{singleReviewAnalysis.preprocessing_stats.tokens.length - 10} more
                    </span>
                  )}
                </div>
              </div>
            </div>
          </div>

          {/* Model Information Card */}
          <div className="saas-card" style={{ marginBottom: '2rem' }}>
            <h4 style={{ fontSize: '1rem', fontWeight: '700', color: '#0f172a', marginBottom: '0.75rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <BrainCircuit size={18} color="#7c3aed" /> Model Architecture & Analysis Information
            </h4>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '1rem', fontSize: '0.85rem' }}>
              <div>
                <span style={{ color: '#64748b' }}>Analysis Method:</span>
                <div style={{ fontWeight: '600', color: '#0f172a' }}>{singleReviewAnalysis.analysis_method}</div>
              </div>
              <div>
                <span style={{ color: '#64748b' }}>Classification Approach:</span>
                <div style={{ fontWeight: '600', color: '#0f172a' }}>{singleReviewAnalysis.analysis_method_type}</div>
              </div>
              <div>
                <span style={{ color: '#64748b' }}>Classes Evaluated:</span>
                <div style={{ fontWeight: '600', color: '#0f172a' }}>3 (Positive, Neutral, Negative)</div>
              </div>
              <div>
                <span style={{ color: '#64748b' }}>Lexicon / Feature Space:</span>
                <div style={{ fontWeight: '600', color: '#0f172a' }}>Bing Polarity Lexicon & TF-IDF Vectorization</div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ProductReviewAnalyzer;
