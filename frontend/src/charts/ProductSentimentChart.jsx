import React from 'react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

const ProductSentimentChart = ({ data, keyName = 'product', height = 320 }) => {
  if (!data || data.length === 0) {
    return (
      <div style={{ textAlign: 'center', padding: '2rem', color: '#64748b' }}>
        No product/category breakdown data available. Ensure your dataset includes a product or category column.
      </div>
    );
  }

  const chartData = data.slice(0, 10).map((item) => ({
    name: (item[keyName] || item.product || item.category || 'Unknown').substring(0, 18),
    fullName: item[keyName] || item.product || item.category || 'Unknown',
    Positive: item.positive || item.pos || 0,
    Neutral: item.neutral || item.neu || 0,
    Negative: item.negative || item.neg || 0,
    total: item.total || 0,
    avgRating: item.avg_rating || null,
  }));

  return (
    <div style={{ width: '100%', height: height, position: 'relative' }}>
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={chartData} margin={{ top: 20, right: 25, left: 10, bottom: 40 }}>
          <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e2e8f0" />
          <XAxis
            dataKey="name"
            stroke="#64748b"
            tick={{ fontSize: 11 }}
            angle={-25}
            textAnchor="end"
            interval={0}
          />
          <YAxis stroke="#64748b" allowDecimals={false} />
          <Tooltip
            content={({ active, payload, label }) => {
              if (active && payload && payload.length) {
                const item = chartData.find((d) => d.name === label);
                return (
                  <div
                    style={{
                      backgroundColor: '#ffffff',
                      borderRadius: '8px',
                      border: '1px solid #cbd5e1',
                      padding: '10px 14px',
                      boxShadow: '0 4px 6px -1px rgba(0,0,0,0.1)',
                      fontSize: '0.84rem',
                    }}
                  >
                    <div style={{ fontWeight: 700, color: '#0f172a', marginBottom: '6px' }}>
                      {item?.fullName || label}
                    </div>
                    {item?.avgRating && (
                      <div style={{ color: '#d97706', marginBottom: '4px', fontWeight: 600 }}>
                        ★ Avg Rating: {item.avgRating} / 5
                      </div>
                    )}
                    <div style={{ color: '#16a34a' }}>Positive: {payload[0]?.value}</div>
                    <div style={{ color: '#2563eb' }}>Neutral: {payload[1]?.value}</div>
                    <div style={{ color: '#dc2626' }}>Negative: {payload[2]?.value}</div>
                    <div style={{ marginTop: '4px', paddingTop: '4px', borderTop: '1px solid #f1f5f9', color: '#64748b', fontSize: '0.75rem' }}>
                      Total Reviews: {item?.total}
                    </div>
                  </div>
                );
              }
              return null;
            }}
          />
          <Legend wrapperStyle={{ paddingTop: 10, fontSize: '0.85rem' }} />
          <Bar dataKey="Positive" fill="#16a34a" radius={[3, 3, 0, 0]} />
          <Bar dataKey="Neutral" fill="#2563eb" radius={[3, 3, 0, 0]} />
          <Bar dataKey="Negative" fill="#dc2626" radius={[3, 3, 0, 0]} />
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
};

export default ProductSentimentChart;
