'use client'

import { useEffect, useState } from 'react'

export default function TestAccountAssignment() {
  const [mrTypes, setMrTypes] = useState([])
  const [selectedType, setSelectedType] = useState('')
  const [allowedAssignments, setAllowedAssignments] = useState([])

  useEffect(() => {
    fetch('/api/account-assignments?action=mrTypes')
      .then(r => r.json())
      .then(d => setMrTypes(d.data || []))
  }, [])

  useEffect(() => {
    if (selectedType) {
      fetch(`/api/account-assignments?mrType=${selectedType}`)
        .then(r => r.json())
        .then(d => setAllowedAssignments(d.data || []))
    }
  }, [selectedType])

  return (
    <div className="p-8 max-w-4xl mx-auto">
      <h1 className="text-2xl font-bold mb-6">Account Assignment Test</h1>
      
      <div className="space-y-4">
        <div>
          <label className="block text-sm font-medium mb-2">Select MR Type:</label>
          <select 
            value={selectedType}
            onChange={(e) => setSelectedType(e.target.value)}
            className="w-full p-2 border rounded"
          >
            <option value="">Select...</option>
            {mrTypes.map((t: any) => (
              <option key={t.code} value={t.code}>{t.name}</option>
            ))}
          </select>
        </div>

        {allowedAssignments.length > 0 && (
          <div className="mt-6">
            <h2 className="text-lg font-semibold mb-3">Allowed Account Assignments:</h2>
            <div className="space-y-2">
              {allowedAssignments.map((a: any) => (
                <div key={a.code} className="p-3 border rounded bg-gray-50">
                  <div className="font-medium">{a.name} ({a.code})</div>
                  <div className="text-sm text-gray-600">{a.description}</div>
                  {a.is_default && <span className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded ml-2">Default</span>}
                  <div className="text-xs mt-2 text-gray-500">
                    Required: {[
                      a.requires_cost_center && 'Cost Center',
                      a.requires_wbs_element && 'WBS Element',
                      a.requires_activity_code && 'Activity',
                      a.requires_asset_number && 'Asset Number',
                      a.requires_order_number && 'Order Number'
                    ].filter(Boolean).join(', ') || 'None'}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
