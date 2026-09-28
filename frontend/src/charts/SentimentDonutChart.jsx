import React from 'react';
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip, Legend } from 'recharts';

const COLORS = {
  Positive: '#16a34a',
  Neutral: '#d97706',
  Negative: '#dc2626',
};

const SentimentDonutChart = ({ data }) => {
  if (!data || data.length === 0) {
    return (
      <div style={{ textAlign: 'center', padding: '2rem', color: '#64748b' }}>
        No sentiment distribution data available.
      </div>
    );
  }

  const chartData = data.map((item) => ({
    name: item.Sentiment || item.name,
    value: item.n || item.count || item.value || 0,
    percentage: item.Percentage || item.percentage || 0,
  }));

  return (
    <ResponsiveContainer width="100%" height={300}>
      <PieChart>
        <Pie
          data={chartData}
          cx="50%"
          cy="50%"
          innerRadius={65}
          outerRadius={95}
          paddingAngle={4}
          dataKey="value"
        >
          {chartData.map((entry, index) => (
            <Cell key={`cell-${index}`} fill={COLORS[entry.name] || '#2563eb'} />
          ))}
        </Pie>
        <Tooltip
          formatter={(value, name, props) => [
            `${value} reviews (${props.payload.percentage}%)`,
            name,
          ]}
          contentStyle={{ backgroundColor: '#ffffff', borderRadius: '8px', border: '1px solid #e2e8f0' }}
        />
        <Legend verticalAlign="bottom" height={36} />
      </PieChart>
    </ResponsiveContainer>
  );
};

export default SentimentDonutChart;
