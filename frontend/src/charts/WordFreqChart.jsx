import React from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

const WordFreqChart = ({ data, limit = 15 }) => {
  if (!data || data.length === 0) {
    return (
      <div style={{ textAlign: 'center', padding: '2rem', color: '#64748b' }}>
        No word frequency data available.
      </div>
    );
  }

  const chartData = [...data]
    .slice(0, limit)
    .map((d) => ({
      word: d.Word || d.word || d.Term,
      frequency: d.Frequency || d.n || d.count || 0,
    }))
    .reverse();

  return (
    <div style={{ width: '100%', height: 320, position: 'relative' }}>
      <ResponsiveContainer width="100%" height="100%">
        <BarChart layout="vertical" data={chartData} margin={{ top: 10, right: 30, left: 40, bottom: 5 }}>
          <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="#e2e8f0" />
          <XAxis type="number" stroke="#64748b" />
          <YAxis dataKey="word" type="category" stroke="#64748b" width={90} tick={{ fontSize: 12 }} />
          <Tooltip
            formatter={(val) => [`${val} occurrences`, 'Frequency']}
            contentStyle={{ backgroundColor: '#ffffff', borderRadius: '8px', border: '1px solid #e2e8f0' }}
          />
          <Bar dataKey="frequency" fill="#0d9488" radius={[0, 4, 4, 0]} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
};

export default WordFreqChart;
