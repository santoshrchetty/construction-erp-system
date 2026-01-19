'use client'

import { useState, useEffect } from 'react'
import { Plus, Trash2 } from 'lucide-react'
import { Select, SelectItem } from '@/components/ui/select'

interface ActivitySubcontractor {
  id?: string
  subcontractor_id?: string
  vendor_code?: string
  vendor_name?: string
  trade: string
  scope_of_work: string
  crew_size: number
  contract_value: number
  priority_level: string
  actual_cost?: number
}

interface ActivitySubcontractorsFormProps {
  activityId: string
}

export function ActivitySubcontractorsForm({ activityId }: ActivitySubcontractorsFormProps) {
  const [subcontractors, setSubcontractors] = useState<ActivitySubcontractor[]>([])
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    fetchSubcontractors()
  }, [activityId])

  const fetchSubcontractors = async () => {
    const res = await fetch(`/api/activities?action=subcontractors&activityId=${activityId}`)
    const data = await res.json()
    setSubcontractors(Array.isArray(data) ? data : [])
  }

  const addSubcontractor = () => {
    setSubcontractors([...subcontractors, {
      trade: '',
      scope_of_work: '',
      crew_size: 1,
      contract_value: 0,
      priority_level: 'normal'
    }])
  }

  const removeSubcontractor = (index: number) => {
    setSubcontractors(subcontractors.filter((_, i) => i !== index))
  }

  const updateSubcontractor = (index: number, field: keyof ActivitySubcontractor, value: any) => {
    const updated = [...subcontractors]
    updated[index] = { ...updated[index], [field]: value }
    setSubcontractors(updated)
  }

  const handleSave = async () => {
    setLoading(true)
    try {
      await fetch('/api/activities?action=attach-subcontractors', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ activityId, subcontractors })
      })
      alert('Subcontractors saved successfully!')
      fetchSubcontractors()
    } catch (error) {
      alert('Failed to save subcontractors')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold">Activity Subcontractors</h3>
        <button
          onClick={addSubcontractor}
          className="flex items-center gap-2 px-3 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          <Plus size={16} />
          Add Subcontractor
        </button>
      </div>

      <div className="space-y-3">
        {subcontractors.map((item, index) => {
          const plannedTotal = item.contract_value
          const actualTotal = item.actual_cost || 0
          
          return (
          <div key={index} className="border rounded-lg">
            {/* Desktop View */}
            <div className="hidden md:flex gap-3 items-start p-3">
              <div className="flex-1 grid grid-cols-7 gap-3">
                <div className="px-3 py-2 border rounded-lg bg-gray-50">
                  {item.vendor_code ? `${item.vendor_code} - ${item.vendor_name}` : 'Vendor'}
                </div>

                <div className="px-3 py-2 border rounded-lg bg-gray-50">
                  {item.trade || 'Trade'}
                </div>

                <input
                  type="text"
                  placeholder="Scope of Work"
                  value={item.scope_of_work}
                  onChange={(e) => updateSubcontractor(index, 'scope_of_work', e.target.value)}
                  className="px-3 py-2 border rounded-lg"
                />

                <input
                  type="number"
                  placeholder="Crew Size"
                  value={item.crew_size}
                  onChange={(e) => updateSubcontractor(index, 'crew_size', parseInt(e.target.value))}
                  className="px-3 py-2 border rounded-lg"
                />

                <input
                  type="number"
                  placeholder="Contract Value"
                  value={item.contract_value}
                  onChange={(e) => updateSubcontractor(index, 'contract_value', parseFloat(e.target.value))}
                  className="px-3 py-2 border rounded-lg"
                />

                <div className="px-3 py-2 bg-blue-50 border border-blue-200 rounded-lg font-semibold text-right text-blue-700">
                  ${plannedTotal.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                </div>

                <div className="px-3 py-2 bg-purple-50 border border-purple-200 rounded-lg font-semibold text-right text-purple-700">
                  ${actualTotal.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                </div>
              </div>

              <button
                onClick={() => removeSubcontractor(index)}
                className="p-2 text-red-600 hover:bg-red-50 rounded-lg"
              >
                <Trash2 size={16} />
              </button>
            </div>

            {/* Mobile View */}
            <div className="md:hidden p-3 space-y-2">
              <div className="flex justify-between items-start">
                <div className="font-semibold text-sm">{item.vendor_code ? `${item.vendor_code} - ${item.vendor_name}` : 'Vendor'}</div>
                <button
                  onClick={() => removeSubcontractor(index)}
                  className="p-1 text-red-600 hover:bg-red-50 rounded"
                >
                  <Trash2 size={16} />
                </button>
              </div>
              <div className="text-xs text-gray-600 mb-2">{item.trade}</div>
              <div className="space-y-2 text-xs">
                <div>
                  <label className="text-gray-600">Scope of Work</label>
                  <input
                    type="text"
                    value={item.scope_of_work}
                    onChange={(e) => updateSubcontractor(index, 'scope_of_work', e.target.value)}
                    className="w-full px-2 py-1.5 border rounded mt-1"
                  />
                </div>
                <div className="grid grid-cols-2 gap-2">
                  <div>
                    <label className="text-gray-600">Crew Size</label>
                    <input
                      type="number"
                      value={item.crew_size}
                      onChange={(e) => updateSubcontractor(index, 'crew_size', parseInt(e.target.value))}
                      className="w-full px-2 py-1.5 border rounded mt-1"
                    />
                  </div>
                  <div>
                    <label className="text-gray-600">Contract Value</label>
                    <input
                      type="number"
                      value={item.contract_value}
                      onChange={(e) => updateSubcontractor(index, 'contract_value', parseFloat(e.target.value))}
                      className="w-full px-2 py-1.5 border rounded mt-1"
                    />
                  </div>
                </div>
              </div>
              <div className="flex justify-between pt-2 border-t">
                <div>
                  <div className="text-xs text-gray-600">Planned</div>
                  <div className="font-semibold text-blue-700">${plannedTotal.toLocaleString('en-US', { minimumFractionDigits: 2 })}</div>
                </div>
                <div className="text-right">
                  <div className="text-xs text-gray-600">Actual</div>
                  <div className="font-semibold text-purple-700">${actualTotal.toLocaleString('en-US', { minimumFractionDigits: 2 })}</div>
                </div>
              </div>
            </div>
          </div>
        )})}
      </div>

      {subcontractors.length > 0 && (
        <div className="flex justify-end">
          <button
            onClick={handleSave}
            disabled={loading}
            className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50"
          >
            {loading ? 'Saving...' : 'Save Subcontractors'}
          </button>
        </div>
      )}
    </div>
  )
}
