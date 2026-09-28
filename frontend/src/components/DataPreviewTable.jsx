import React, { useState } from 'react';
import { Search, ChevronLeft, ChevronRight } from 'lucide-react';

const DataPreviewTable = ({ data, pageSize = 10 }) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [currentPage, setCurrentPage] = useState(1);

  if (!data || data.length === 0) {
    return (
      <div style={{ textAlign: 'center', padding: '2rem', color: '#64748b' }}>
        No dataset rows to preview.
      </div>
    );
  }

  const columns = Object.keys(data[0]);

  const filteredData = data.filter((row) =>
    columns.some((col) =>
      String(row[col] || '')
        .toLowerCase()
        .includes(searchTerm.toLowerCase())
    )
  );

  const totalPages = Math.ceil(filteredData.length / pageSize) || 1;
  const startIndex = (currentPage - 1) * pageSize;
  const paginatedRows = filteredData.slice(startIndex, startIndex + pageSize);

  return (
    <div>
      {/* Search Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem', flexWrap: 'wrap', gap: '0.75rem' }}>
        <div style={{ position: 'relative', width: '280px' }}>
          <Search size={16} style={{ position: 'absolute', left: '10px', top: '10px', color: '#94a3b8' }} />
          <input
            type="text"
            placeholder="Search dataset records..."
            value={searchTerm}
            onChange={(e) => {
              setSearchTerm(e.target.value);
              setCurrentPage(1);
            }}
            style={{
              width: '100%',
              padding: '0.5rem 0.75rem 0.5rem 2.2rem',
              borderRadius: '8px',
              border: '1px solid #cbd5e1',
              fontSize: '0.85rem',
            }}
          />
        </div>
        <div style={{ fontSize: '0.82rem', color: '#64748b' }}>
          Showing {filteredData.length === 0 ? 0 : startIndex + 1} - {Math.min(startIndex + pageSize, filteredData.length)} of {filteredData.length} entries
        </div>
      </div>

      {/* Table */}
      <div className="table-responsive">
        <table className="saas-table">
          <thead>
            <tr>
              {columns.map((col) => (
                <th key={`head-${col}`}>{col}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {paginatedRows.length > 0 ? (
              paginatedRows.map((row, rIdx) => (
                <tr key={`row-${rIdx}`}>
                  {columns.map((col) => (
                    <td key={`cell-${rIdx}-${col}`}>
                      <div
                        style={{
                          maxWidth: '350px',
                          overflow: 'hidden',
                          textOverflow: 'ellipsis',
                          whiteSpace: 'nowrap',
                        }}
                        title={String(row[col] || '')}
                      >
                        {String(row[col] !== undefined && row[col] !== null ? row[col] : '')}
                      </div>
                    </td>
                  ))}
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan={columns.length} style={{ textAlign: 'center', padding: '2rem', color: '#94a3b8' }}>
                  No matching records found.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination Controls */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '1rem' }}>
        <div style={{ fontSize: '0.82rem', color: '#64748b' }}>
          Page {currentPage} of {totalPages}
        </div>
        <div style={{ display: 'flex', gap: '0.5rem' }}>
          <button
            className="btn btn-outline btn-sm"
            onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
            disabled={currentPage === 1}
          >
            <ChevronLeft size={16} /> Prev
          </button>
          <button
            className="btn btn-outline btn-sm"
            onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
            disabled={currentPage === totalPages}
          >
            Next <ChevronRight size={16} />
          </button>
        </div>
      </div>
    </div>
  );
};

export default DataPreviewTable;
