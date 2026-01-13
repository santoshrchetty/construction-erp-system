// DEPRECATED: This file is marked for removal - duplicate of ERPConfigurationModuleComplete.tsx
// TODO: Remove after confirming no imports
/*
'use client';

import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase-simple';

export default function ERPConfigSimple() {
  const [materialTypes, setMaterialTypes] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchMaterialTypes();
  }, []);

  const fetchMaterialTypes = async () => {
    try {
      console.log('Fetching material types...');
      const { data, error } = await supabase
        .from('material_types')
        .select('*')
        .order('material_type_code');
      
      if (error) {
        console.error('Supabase error:', error);
        setError(error.message);
      } else {
        console.log('Material types data:', data);
        setMaterialTypes(data || []);
      }
    } catch (err) {
      console.error('Fetch error:', err);
      setError('Failed to fetch data');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="p-6">Loading ERP Configuration...</div>;
  }

  if (error) {
    return (
      <div className="p-6">
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded">
          <strong>Error:</strong> {error}
        </div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">ERP Configuration (Simple)</h1>
      <div className="bg-white rounded-lg shadow p-4">
        <h3 className="text-lg font-semibold mb-3">Material Types ({materialTypes.length})</h3>
        {materialTypes.length > 0 ? (
          <div className="space-y-2">
            {materialTypes.map((type) => (
              <div key={type.id} className="border-b pb-2">
                <span className="font-mono font-bold">{type.material_type_code}</span> - {type.material_type_name}
              </div>
            ))}
          </div>
        ) : (
          <p className="text-gray-500">No material types found</p>
        )}
      </div>
    </div>
  );
}
*/