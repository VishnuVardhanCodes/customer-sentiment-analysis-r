import React from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

const ModelComparisonChart = ({ data }) => {
  if (!data || data.length === 0) {
    return (
      <div style={{ textAlign: 'center', padding: '2rem', color: '#64748b' }}>
        No model evaluation metrics available.
      </div>
    );
  }

  const chartData = data.map((item) => ({
    model: item.Model,
    Accuracy: Number((item.Accuracy * 100).toFixed(1)),
    Precision: Number((item.Precision * 100).toFixed(1)),
    Recall: Number((item.Recall * 100).toFixed(1)),
    F1_Score: Number((item.F1_Score * 100).toFixed(1)),
  }));

  return (
    <ResponsiveContainer width="100%" height={340}>
      <BarChart data={chartData} margin={{ top: 15, right: 30, left: 10, bottom: 5 }}>
        <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e2e8f0" />
        <XAxis dataKey="model" stroke="#475569" fontWeight={600} />
        <YAxis domain={[0, 100]} stroke="#64748b" tickFormatter={(v) => `${v}%`} />
        <Tooltip
          formatter={(val) => [`${val}%`]}
          contentStyle={{ backgroundColor: '#ffffff', borderRadius: '8px', border: '1px solid #e2e8f0' }}
        />
        <Legend />
        <Bar dataKey="Accuracy" fill="#2563eb" radius={[4, 4, 0, 0]} />
        <Bar dataKey="Precision" fill="#0d9488" radius={[4, 4, 0, 0]} />
        <Bar dataKey="Recall" fill="#d97706" radius={[4, 4, 0, 0]} />
        <Bar dataKey="F1_Score" fill="#8b5cf6" radius={[4, 4, 0, 0]} />
      </BarChart>
    </ResponsiveContainer>
  );
};

export default ModelComparisonChart;
