import React from 'react';
import { useAnalysis } from '../context/AnalysisContext';
import { Check, Clock, Minus } from 'lucide-react';

const steps = [
  { key: 'uploaded', label: '01 Upload' },
  { key: 'validated', label: '02 Validate' },
  { key: 'preprocessed', label: '03 Preprocess' },
  { key: 'text_mined', label: '04 Text Mining' },
  { key: 'sentiment_analyzed', label: '05 Sentiment' },
  { key: 'ml_trained', label: '06 Machine Learning' },
  { key: 'evaluated', label: '07 Evaluation' },
  { key: 'insights_generated', label: '08 Insights' },
];

const WorkflowStepper = () => {
  const { pipelineStatus } = useAnalysis();

  return (
    <div className="stepper-container">
      {steps.map((step, idx) => {
        const isCompleted = pipelineStatus[step.key];
        const isCurrent = !isCompleted && (idx === 0 || pipelineStatus[steps[idx - 1].key]);

        let stateClass = 'not-started';
        if (isCompleted) stateClass = 'completed';
        else if (isCurrent && pipelineStatus.uploaded) stateClass = 'running';

        return (
          <React.Fragment key={step.key}>
            <div className={`stepper-step ${stateClass}`}>
              <div className="stepper-bubble">
                {isCompleted ? <Check size={16} /> : isCurrent ? idx + 1 : <Minus size={14} />}
              </div>
              <span className="stepper-title">{step.label}</span>
            </div>
            {idx < steps.length - 1 && (
              <div
                style={{
                  flex: 1,
                  height: '2px',
                  backgroundColor: isCompleted ? '#16a34a' : '#e2e8f0',
                  minWidth: '20px',
                  transition: 'all 0.3s ease',
                }}
              />
            )}
          </React.Fragment>
        );
      })}
    </div>
  );
};

export default WorkflowStepper;
