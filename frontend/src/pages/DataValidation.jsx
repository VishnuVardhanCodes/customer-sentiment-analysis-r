import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAnalysis } from '../context/AnalysisContext';
import { api } from '../services/api';
import PageHeader from '../components/PageHeader';
import KpiCard from '../components/KpiCard';
import ValidationTable from '../components/ValidationTable';
import DataPreviewTable from '../components/DataPreviewTable';
import EmptyState from '../components/EmptyState';
import LoadingState from '../components/LoadingState';
import { CheckCircle2, Layers, AlertTriangle, Copy, ArrowRight } from 'lucide-react';

const DataValidation = () => {
  const navigate = useNavigate();
  const {
    loading,
    setLoading,
    loadingText,
    setLoadingText,
    validationResults,
    setValidationResults,
    pipelineStatus,
    textColumn,
    labelColumn,
  } = useAnalysis();

  useEffect(() => {
    if (pipelineStatus.uploaded && !validationResults && textColumn) {
      const runValidation = async () => {
        setLoading(true);
        setLoadingText('Executing R data validation suite...');
        try {
          const res = await api.validateDataset(textColumn, labelColumn);
          if (res.success) setValidationResults(res.data);
        } catch (err) {
          console.error(err);
        } finally {
          setLoading(false);
        }
      };
      runValidation();
    }
  }, [pipelineStatus.uploaded, validationResults, textColumn, labelColumn]);

  if (loading) {
    return <LoadingState message={loadingText} />;
  }

  if (!pipelineStatus.uploaded || !validationResults) {
    return (
      <div>
        <PageHeader title="Data Validation" subtitle="Data quality verification and dataset structure checks." />
        <EmptyState
          title="No Dataset Validated Yet"
          description="Please upload a customer dataset to run data quality checks."
          actionText="Upload Dataset"
          onAction={() => navigate('/upload')}
        />
      </div>
    );
  }

  const summary = validationResults.summary || {};
  const checks = validationResults.checks || [];
  const preview = validationResults.preview || [];

  return (
    <div>
      <PageHeader
        title="Data Validation Dashboard"
        subtitle="Verification of dataset integrity, missing values, empty strings, and sentiment ground-truth."
      >
        <button className="btn btn-primary btn-md" onClick={() => navigate('/preprocessing')}>
          Proceed to Preprocessing <ArrowRight size={16} />
        </button>
      </PageHeader>

      {/* KPI CARDS */}
      <div className="kpi-grid">
        <KpiCard label="Total Rows" value={summary.rows} icon={Layers} variant="primary" />
        <KpiCard label="Total Columns" value={summary.columns} icon={Layers} variant="primary" />
        <KpiCard
          label="Missing Values"
          value={summary.missing_values}
          icon={AlertTriangle}
          variant={summary.missing_values > 0 ? 'neg' : 'pos'}
        />
        <KpiCard
          label="Duplicate Reviews"
          value={summary.duplicates}
          icon={Copy}
          variant={summary.duplicates > 0 ? 'neu' : 'pos'}
        />
      </div>

      {/* VALIDATION CHECKS TABLE */}
      <div className="saas-card" style={{ marginBottom: '1.75rem' }}>
        <h3 className="card-title-clean" style={{ marginBottom: '1rem' }}>
          <CheckCircle2 color="#16a34a" size={20} /> Data Quality Verification Checks
        </h3>
        <ValidationTable checks={checks} />
      </div>

      {/* INTERACTIVE DATASET PREVIEW */}
      <div className="saas-card">
        <h3 className="card-title-clean" style={{ marginBottom: '1rem' }}>
          Dataset Records Preview
        </h3>
        <DataPreviewTable data={preview} pageSize={10} />
      </div>
    </div>
  );
};

export default DataValidation;
