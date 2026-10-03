import React, { useState } from 'react';
import { useAnalysis } from '../context/AnalysisContext';
import { api } from '../services/api';
import PageHeader from '../components/PageHeader';
import {
  Layers,
  PlusCircle,
  Trash2,
  Sparkles,
  RotateCcw,
  Smile,
  Meh,
  Frown,
  Star,
  CheckCircle2,
  AlertTriangle,
  Info,
  ArrowRight,
  TrendingUp,
} from 'lucide-react';
import { Link } from 'react-router-dom';

const sampleComparisonReviews = [
  {
    text: 'The sound quality is outstanding and battery easily lasts 30+ hours on single charge. Highly recommend!',
    rating: 5,
  },
  {
    text: 'Comfortable to wear for long flights, noise cancellation works as expected. Packaging was standard.',
    rating: 3,
  },
  {
    text: 'The ear cups started peeling after two months and the microphone picks up too much background noise.',
    rating: 2,
  },
];

const CompareReviews = () => {
  const { loading, setLoading, loadingText, setLoadingText, addToast } = useAnalysis();

  const [productName, setProductName] = useState('Sony WH-1000XM5 Wireless Headphones');
  const [productCategory, setProductCategory] = useState('Audio & Headphones');
  const [reviewsList, setReviewsList] = useState([
    { text: '', rating: '' },
    { text: '', rating: '' },
  ]);
  const [comparisonResult, setComparisonResult] = useState(null);

  const handleAddReviewField = () => {
    if (reviewsList.length >= 6) {
      addToast('Maximum 6 reviews can be compared at once.', 'info');
      return;
    }
    setReviewsList([...reviewsList, { text: '', rating: '' }]);
  };

  const handleRemoveReviewField = (index) => {
    if (reviewsList.length <= 2) {
      addToast('Minimum 2 reviews required for comparison.', 'info');
      return;
    }
    const updated = reviewsList.filter((_, idx) => idx !== index);
    setReviewsList(updated);
  };

  const handleReviewChange = (index, field, value) => {
    const updated = [...reviewsList];
    updated[index][field] = value;
    setReviewsList(updated);
  };

  const handleLoadSample = () => {
    setProductName('Sony WH-1000XM5 Wireless Headphones');
    setProductCategory('Audio & Headphones');
    setReviewsList(sampleComparisonReviews);
    addToast('Sample comparison reviews loaded.', 'info');
  };

  const handleClear = () => {
    setProductName('');
    setProductCategory('Audio & Headphones');
    setReviewsList([
      { text: '', rating: '' },
      { text: '', rating: '' },
    ]);
    setComparisonResult(null);
    addToast('Comparison cleared.', 'info');
  };

  const handleAnalyzeAll = async () => {
    const validReviews = reviewsList.filter((r) => r.text && r.text.trim().length > 0);
    if (validReviews.length < 2) {
      addToast('Please provide at least 2 customer reviews to compare.', 'error');
      return;
    }

    setLoading(true);
    setLoadingText('Analyzing multiple customer reviews in R and calculating product consensus...');

    try {
      const payload = {
        product_name: productName.trim() || 'Product',
        product_category: productCategory,
        reviews: validReviews.map((r) => ({
          text: r.text.trim(),
          rating: r.rating ? Number(r.rating) : null,
        })),
        model_choice: 'Auto',
      };

      const res = await api.analyzeReviews(payload);
      if (res.success) {
        setComparisonResult(res.data);
        addToast('Multi-review consensus analysis completed!', 'success');
      } else {
        addToast('Comparison failed: ' + res.message, 'error');
      }
    } catch (err) {
      addToast('Backend error: ' + (err.response?.data?.message || err.message), 'error');
    } finally {
      setLoading(false);
    }
  };

  const getVariant = (sentiment) => {
    if (sentiment === 'Positive') return { color: '#16a34a', bg: '#f0fdf4', border: '#bbf7d0', icon: Smile };
    if (sentiment === 'Negative') return { color: '#dc2626', bg: '#fef2f2', border: '#fecaca', icon: Frown };
    return { color: '#d97706', bg: '#fffbeb', border: '#fef08a', icon: Meh };
  };

  return (
    <div>
      <PageHeader
        title="Compare Product Reviews"
        subtitle="Cross-Review Synthesis • Repeated Strengths & Deficiencies • Evidence-Based Buying Considerations"
      >
        <Link to="/analyzer" className="btn btn-outline btn-md">
          Single Review Analyzer <ArrowRight size={16} />
        </Link>
      </PageHeader>

      {/* INSTRUCTION CARD */}
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
          <strong>Cross-Review Consensus:</strong> Evaluating multiple customer reviews for the same product provides a
          balanced view. Paste 2 or more reviews below to examine overall agreement, common complaints, repeated positive aspects,
          and consolidated buyer guidance.
        </div>
      </div>

      {/* PRODUCT METADATA INPUT */}
      <div className="saas-card" style={{ marginBottom: '1.5rem' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.25rem', flexWrap: 'wrap', gap: '0.5rem' }}>
          <h3 style={{ fontSize: '1.05rem', fontWeight: '700', color: '#0f172a', display: 'flex', alignItems: 'center', gap: '0.5rem', margin: 0 }}>
            <Layers size={18} color="#2563eb" /> Product Information
          </h3>
          <button type="button" className="btn btn-outline btn-sm" onClick={handleLoadSample}>
            <Sparkles size={14} /> Quick-Load Sample Reviews
          </button>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '1.25rem' }}>
          <div>
            <label style={{ display: 'block', fontSize: '0.85rem', fontWeight: '600', color: '#334155', marginBottom: '0.4rem' }}>
              Product Name
            </label>
            <input
              type="text"
              className="saas-input"
              value={productName}
              onChange={(e) => setProductName(e.target.value)}
              placeholder="e.g., Sony WH-1000XM5 Wireless Headphones"
              style={{ width: '100%', padding: '0.65rem 0.85rem', fontSize: '0.9rem' }}
            />
          </div>
          <div>
            <label style={{ display: 'block', fontSize: '0.85rem', fontWeight: '600', color: '#334155', marginBottom: '0.4rem' }}>
              Product Category
            </label>
            <input
              type="text"
              className="saas-input"
              value={productCategory}
              onChange={(e) => setProductCategory(e.target.value)}
              placeholder="e.g., Audio & Headphones"
              style={{ width: '100%', padding: '0.65rem 0.85rem', fontSize: '0.9rem' }}
            />
          </div>
        </div>
      </div>

      {/* REVIEWS INPUT LIST */}
      <div className="saas-card" style={{ marginBottom: '2rem' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem', flexWrap: 'wrap', gap: '0.5rem' }}>
          <h4 style={{ fontSize: '1rem', fontWeight: '700', color: '#0f172a', margin: 0 }}>
            Customer Reviews ({reviewsList.length})
          </h4>
          <button type="button" className="btn btn-outline btn-sm" onClick={handleAddReviewField}>
            <PlusCircle size={14} /> Add Another Review
          </button>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
          {reviewsList.map((rev, idx) => (
            <div
              key={idx}
              style={{
                backgroundColor: '#f8fafc',
                border: '1px solid #e2e8f0',
                borderRadius: 'var(--radius-md)',
                padding: '1rem',
              }}
            >
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.5rem' }}>
                <span style={{ fontSize: '0.85rem', fontWeight: '700', color: '#475569' }}>
                  Review #{idx + 1}
                </span>

                <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                  {/* Rating Selector */}
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                    <span style={{ fontSize: '0.78rem', color: '#64748b' }}>Rating:</span>
                    {[1, 2, 3, 4, 5].map((star) => (
                      <button
                        key={star}
                        type="button"
                        onClick={() => handleReviewChange(idx, 'rating', rev.rating === star ? '' : star)}
                        style={{
                          background: 'none',
                          border: 'none',
                          cursor: 'pointer',
                          padding: '0.1rem',
                          color: Number(rev.rating) >= star ? '#eab308' : '#cbd5e1',
                        }}
                      >
                        <Star size={16} fill={Number(rev.rating) >= star ? '#eab308' : 'none'} />
                      </button>
                    ))}
                  </div>

                  {reviewsList.length > 2 && (
                    <button
                      type="button"
                      onClick={() => handleRemoveReviewField(idx)}
                      style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#ef4444' }}
                      title="Remove review"
                    >
                      <Trash2 size={16} />
                    </button>
                  )}
                </div>
              </div>

              <textarea
                className="saas-input"
                rows={3}
                placeholder={`Paste customer review #${idx + 1} text here...`}
                value={rev.text}
                onChange={(e) => handleReviewChange(idx, 'text', e.target.value)}
                style={{ width: '100%', padding: '0.65rem 0.85rem', fontSize: '0.88rem' }}
              />
            </div>
          ))}
        </div>

        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '0.75rem', marginTop: '1.25rem' }}>
          <button type="button" className="btn btn-outline btn-md" onClick={handleClear} disabled={loading}>
            <RotateCcw size={16} /> Clear All
          </button>
          <button type="button" className="btn btn-primary btn-md" onClick={handleAnalyzeAll} disabled={loading}>
            <Sparkles size={16} /> Analyze All Reviews
          </button>
        </div>
      </div>

      {/* COMPARISON RESULTS */}
      {comparisonResult && (
        <div style={{ animation: 'fadeIn 0.3s ease' }}>
          {(() => {
            const consensusVariant = getVariant(comparisonResult.dominant_sentiment);
            const ConsensusIcon = consensusVariant.icon;

            return (
              <div
                style={{
                  backgroundColor: consensusVariant.bg,
                  border: `2px solid ${consensusVariant.border}`,
                  borderRadius: 'var(--radius-lg)',
                  padding: '1.75rem',
                  marginBottom: '1.75rem',
                  boxShadow: 'var(--shadow-md)',
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '1rem', marginBottom: '1.25rem' }}>
                  <div>
                    <span style={{ fontSize: '0.8rem', fontWeight: '700', textTransform: 'uppercase', letterSpacing: '0.5px', color: consensusVariant.color }}>
                      Product Consensus Sentiment ({comparisonResult.total_reviews} Reviews Analyzed)
                    </span>
                    <h2 style={{ fontSize: '1.85rem', fontWeight: '800', color: consensusVariant.color, margin: '0.25rem 0', display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
                      <ConsensusIcon size={30} /> {comparisonResult.dominant_sentiment} Consensus
                    </h2>
                    <div style={{ fontSize: '0.9rem', color: '#475569' }}>
                      <strong>{comparisonResult.product_name}</strong> • {comparisonResult.product_category}
                      {comparisonResult.average_rating && (
                        <span> • Avg Rating: {comparisonResult.average_rating} / 5 Stars</span>
                      )}
                    </div>
                  </div>

                  {/* Sentiment Percentage Pills */}
                  <div style={{ display: 'flex', gap: '0.75rem' }}>
                    <div style={{ backgroundColor: '#ffffff', padding: '0.5rem 0.85rem', borderRadius: 'var(--radius-md)', textAlign: 'center', border: '1px solid #bbf7d0' }}>
                      <div style={{ fontSize: '0.72rem', color: '#16a34a', fontWeight: '700' }}>POSITIVE</div>
                      <div style={{ fontSize: '1.15rem', fontWeight: '800', color: '#16a34a' }}>{comparisonResult.pos_pct}%</div>
                      <div style={{ fontSize: '0.7rem', color: '#64748b' }}>{comparisonResult.pos_count} reviews</div>
                    </div>
                    <div style={{ backgroundColor: '#ffffff', padding: '0.5rem 0.85rem', borderRadius: 'var(--radius-md)', textAlign: 'center', border: '1px solid #fef08a' }}>
                      <div style={{ fontSize: '0.72rem', color: '#d97706', fontWeight: '700' }}>NEUTRAL</div>
                      <div style={{ fontSize: '1.15rem', fontWeight: '800', color: '#d97706' }}>{comparisonResult.neu_pct}%</div>
                      <div style={{ fontSize: '0.7rem', color: '#64748b' }}>{comparisonResult.neu_count} reviews</div>
                    </div>
                    <div style={{ backgroundColor: '#ffffff', padding: '0.5rem 0.85rem', borderRadius: 'var(--radius-md)', textAlign: 'center', border: '1px solid #fecaca' }}>
                      <div style={{ fontSize: '0.72rem', color: '#dc2626', fontWeight: '700' }}>NEGATIVE</div>
                      <div style={{ fontSize: '1.15rem', fontWeight: '800', color: '#dc2626' }}>{comparisonResult.neg_pct}%</div>
                      <div style={{ fontSize: '0.7rem', color: '#64748b' }}>{comparisonResult.neg_count} reviews</div>
                    </div>
                  </div>
                </div>

                {/* Synthesis Box */}
                <div style={{ backgroundColor: '#ffffff', padding: '1.25rem', borderRadius: 'var(--radius-md)', border: '1px solid var(--surface-border)' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.4rem', fontWeight: '700', color: '#0f172a' }}>
                    <CheckCircle2 size={18} color="#2563eb" /> Potential Buyer Purchase Considerations
                  </div>
                  <p style={{ fontSize: '0.92rem', color: '#1e293b', margin: 0, lineHeight: '1.6' }}>
                    {comparisonResult.buyer_synthesis}
                  </p>
                </div>
              </div>
            );
          })()}

          {/* STRENGTHS VS COMPLAINTS */}
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '1.5rem', marginBottom: '2rem' }}>
            <div className="saas-card" style={{ borderLeft: '4px solid #16a34a' }}>
              <h4 style={{ fontSize: '1rem', fontWeight: '700', color: '#16a34a', marginBottom: '0.75rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <TrendingUp size={18} /> Commonly Mentioned Strengths
              </h4>
              {comparisonResult.top_positive_aspects?.length > 0 ? (
                <div style={{ display: 'flex', gap: '0.4rem', flexWrap: 'wrap' }}>
                  {comparisonResult.top_positive_aspects.map((term, idx) => (
                    <span
                      key={idx}
                      style={{
                        backgroundColor: '#f0fdf4',
                        border: '1px solid #bbf7d0',
                        color: '#16a34a',
                        padding: '0.25rem 0.65rem',
                        borderRadius: 'var(--radius-full)',
                        fontSize: '0.85rem',
                        fontWeight: '600',
                      }}
                    >
                      +{term}
                    </span>
                  ))}
                </div>
              ) : (
                <span style={{ fontSize: '0.85rem', color: '#94a3b8' }}>No recurring positive terms found.</span>
              )}
            </div>

            <div className="saas-card" style={{ borderLeft: '4px solid #dc2626' }}>
              <h4 style={{ fontSize: '1rem', fontWeight: '700', color: '#dc2626', marginBottom: '0.75rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                <AlertTriangle size={18} /> Commonly Mentioned Issues & Complaints
              </h4>
              {comparisonResult.top_negative_aspects?.length > 0 ? (
                <div style={{ display: 'flex', gap: '0.4rem', flexWrap: 'wrap' }}>
                  {comparisonResult.top_negative_aspects.map((term, idx) => (
                    <span
                      key={idx}
                      style={{
                        backgroundColor: '#fef2f2',
                        border: '1px solid #fecaca',
                        color: '#dc2626',
                        padding: '0.25rem 0.65rem',
                        borderRadius: 'var(--radius-full)',
                        fontSize: '0.85rem',
                        fontWeight: '600',
                      }}
                    >
                      -{term}
                    </span>
                  ))}
                </div>
              ) : (
                <span style={{ fontSize: '0.85rem', color: '#94a3b8' }}>No recurring complaints identified.</span>
              )}
            </div>
          </div>

          {/* INDIVIDUAL REVIEWS BREAKDOWN */}
          <div className="saas-card">
            <h4 style={{ fontSize: '1.05rem', fontWeight: '700', color: '#0f172a', marginBottom: '1.25rem' }}>
              Individual Analyzed Reviews Breakdown
            </h4>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
              {comparisonResult.reviews?.map((r, idx) => {
                const varItem = getVariant(r.predicted_sentiment);
                const ItemIcon = varItem.icon;

                return (
                  <div
                    key={idx}
                    style={{
                      border: '1px solid #e2e8f0',
                      borderRadius: 'var(--radius-md)',
                      padding: '1rem',
                      backgroundColor: '#ffffff',
                    }}
                  >
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.5rem' }}>
                      <span style={{ fontSize: '0.85rem', fontWeight: '700', color: '#334155' }}>
                        Review #{idx + 1}
                      </span>
                      <span
                        style={{
                          backgroundColor: varItem.bg,
                          color: varItem.color,
                          border: `1px solid ${varItem.border}`,
                          padding: '0.2rem 0.6rem',
                          borderRadius: 'var(--radius-full)',
                          fontSize: '0.78rem',
                          fontWeight: '700',
                          display: 'inline-flex',
                          alignItems: 'center',
                          gap: '0.3rem',
                        }}
                      >
                        <ItemIcon size={14} /> {r.predicted_sentiment} ({r.confidence_score}%)
                      </span>
                    </div>

                    <p style={{ fontSize: '0.88rem', color: '#1e293b', marginBottom: '0.5rem', fontStyle: 'italic' }}>
                      "{r.original_review}"
                    </p>

                    <div style={{ fontSize: '0.82rem', color: '#64748b', lineHeight: '1.5' }}>
                      <strong>Insight:</strong> {r.potential_buyer_insight}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default CompareReviews;
