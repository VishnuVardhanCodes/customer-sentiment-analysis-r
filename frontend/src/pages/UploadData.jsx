import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAnalysis } from '../context/AnalysisContext';
import { api } from '../services/api';
import PageHeader from '../components/PageHeader';
import UploadZone from '../components/UploadZone';
import DatasetInfoCard from '../components/DatasetInfoCard';
import LoadingState from '../components/LoadingState';
import { Upload } from 'lucide-react';

const UploadData = () => {
  const navigate = useNavigate();
  const {
    loading,
    setLoading,
    loadingText,
    setLoadingText,
    addToast,
    datasetMetadata,
    setDatasetMetadata,
    textColumn,
    setTextColumn,
    labelColumn,
    setLabelColumn,
    setValidationResults,
    setPipelineStatus,
    resetAll,
  } = useAnalysis();

  const handleFileUpload = async (fileContent, filename) => {
    setLoading(true);
    setLoadingText(`Uploading and parsing ${filename}...`);
    try {
      const res = await api.uploadDataset(fileContent, filename);
      if (res.success) {
        const d = res.data;
        setDatasetMetadata({
          filename: d.filename,
          file_size: d.file_size,
          rows: d.rows,
          columns: d.columns,
          column_names: d.column_names,
        });
        setTextColumn(d.text_column || '');
        setLabelColumn(d.label_column || '');
        
        setPipelineStatus((prev) => ({
          ...prev,
          uploaded: true,
          is_labeled: d.is_labeled,
        }));
        
        addToast(`Dataset '${filename}' uploaded successfully!`, 'success');
      }
    } catch (err) {
      addToast('Upload failed: ' + (err.response?.data?.message || err.message), 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleValidate = async () => {
    if (!textColumn) {
      addToast('Please select a valid customer text column.', 'warning');
      return;
    }

    setLoading(true);
    setLoadingText('Validating dataset quality and column selections...');
    try {
      const res = await api.validateDataset(textColumn, labelColumn);
      if (res.success) {
        setValidationResults(res.data);
        setPipelineStatus((prev) => ({
          ...prev,
          validated: true,
          is_labeled: res.data.summary?.is_labeled || false,
        }));
        addToast('Data validation completed cleanly!', 'success');
        navigate('/validation');
      }
    } catch (err) {
      addToast('Validation error: ' + (err.response?.data?.message || err.message), 'error');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <LoadingState message={loadingText} />;
  }

  return (
    <div>
      <PageHeader
        title="Upload Customer Feedback"
        subtitle="Import CSV or TXT files containing customer reviews, comments or social-media feedback."
      />

      {!datasetMetadata ? (
        <UploadZone onFileSelected={handleFileUpload} loading={loading} />
      ) : (
        <DatasetInfoCard
          metadata={datasetMetadata}
          textColumn={textColumn}
          setTextColumn={setTextColumn}
          labelColumn={labelColumn}
          setLabelColumn={setLabelColumn}
          onValidate={handleValidate}
          onReplace={() => setDatasetMetadata(null)}
          onRemove={resetAll}
          loading={loading}
        />
      )}
    </div>
  );
};

export default UploadData;
