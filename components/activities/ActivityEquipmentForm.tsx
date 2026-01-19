'use client'

import { useState, useEffect } from 'react'
import { Plus, Trash2 } from 'lucide-react'

interface Equipment {
  id: string
  code: string
  name: string
  hourly_rate: number
}

interface ActivityEquipment {
  equipment_id: string
  equipment_code?: string
  equipment_name?: string
  required_hours: number
  hourly_rate: number
  priority_level?: string
  notes?: string
  actual_cost?: number
}

interface ActivityEquipmentFormProps {
  activityId: string
}

export default function ActivityEquipmentForm({ activityId }: ActivityEquipmentFormProps) {
  const [equipment, setEquipment] = useState<Equipment[]>([])
  const [selectedEquipment, setSelectedEquipment] = useState<ActivityEquipment[]>([])
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    fetchEquipment()
    fetchActivityEquipment()
  }, [activityId])

  const fetchEquipment = async () => {
    // TODO: Implement equipment master API
    setEquipment([])
  }

  const fetchActivityEquipment = async () => {
    const res = await fetch(`/api/activities?action=equipment&activityId=${activityId}`)
    const data = await res.json()
    setSelectedEquipment(Array.isArray(data) ? data : [])
  }

  const addEquipment = () => {
    setSelectedEquipment([...selectedEquipment, {
      equipment_id: '',
      required_hours: 0,
      hourly_rate: 0,
      priority_level: 'normal'
    }])
  }

  const removeEquipment = (index: number) => {
    setSelectedEquipment(selectedEquipment.filter((_, i) => i !== index))
  }

  const updateEquipment = (index: number, field: keyof ActivityEquipment, value: any) => {
    const updated = [...selectedEquipment]
    updated[index] = { ...updated[index], [field]: value }
    setSelectedEquipment(updated)
  }

  const handleSave = async () => {
    setLoading(true)
    try {
      await fetch('/api/activities?action=attach-equipment', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ activityId, equipment: selectedEquipment })
      })
      alert('Equipment saved successfully!')
    } catch (error) {
      alert('Failed to save equipment')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold">Activity Equipment</h3>
        <button
          onClick={addEquipment}
          className="flex items-center gap-2 px-3 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          <Plus size={16} />
          Add Equipment
        </button>
      </div>

      <div className="space-y-3">
        {selectedEquipment.map((item, index) => {
          const plannedTotal = item.required_hours * item.hourly_rate
          const actualTotal = item.actual_cost || 0
          
          return (
          <div key={index} className="border rounded-lg">
            {/* Desktop View */}
            <div className="hidden md:flex gap-3 items-start p-3">
              <div className="flex-1 grid grid-cols-6 gap-3">
                <div className="px-3 py-2 border rounded-lg bg-gray-50">
                  {item.equipment_name || 'Equipment'}
                </div>
                <input
                  type="number"
                  placeholder="Hours"
                  value={item.required_hours}
                  onChange={(e) => updateEquipment(index, 'required_hours', parseFloat(e.target.value))}
                  className="px-3 py-2 border rounded-lg"
                />
                <input
                  type="number"
                  placeholder="Hourly Rate"
                  value={item.hourly_rate}
                  onChange={(e) => updateEquipment(index, 'hourly_rate', parseFloat(e.target.value))}
                  className="px-3 py-2 border rounded-lg"
                />
                <div className="px-3 py-2 bg-blue-50 border border-blue-200 rounded-lg font-semibold text-right text-blue-700">
                  ${plannedTotal.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                </div>
                <div className="px-3 py-2 bg-purple-50 border border-purple-200 rounded-lg font-semibold text-right text-purple-700">
                  ${actualTotal.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                </div>
                <select
                  value={item.priority_level}
                  onChange={(e) => updateEquipment(index, 'priority_level', e.target.value)}
                  className="px-3 py-2 border rounded-lg text-sm"
                >
                  <option value="normal">Normal</option>
                  <option value="high">High</option>
                  <option value="critical">Critical</option>
                </select>
              </div>
              <button
                onClick={() => removeEquipment(index)}
                className="p-2 text-red-600 hover:bg-red-50 rounded-lg"
              >
                <Trash2 size={16} />
              </button>
            </div>

            {/* Mobile View */}
            <div className="md:hidden p-3 space-y-2">
              <div className="flex justify-between items-start">
                <div className="font-semibold text-sm">{item.equipment_name || 'Equipment'}</div>
                <button
                  onClick={() => removeEquipment(index)}
                  className="p-1 text-red-600 hover:bg-red-50 rounded"
                >
                  <Trash2 size={16} />
                </button>
              </div>
              <div className="grid grid-cols-2 gap-2 text-xs">
                <div>
                  <label className="text-gray-600">Hours</label>
                  <input
                    type="number"
                    value={item.required_hours}
                    onChange={(e) => updateEquipment(index, 'required_hours', parseFloat(e.target.value))}
                    className="w-full px-2 py-1.5 border rounded mt-1"
                  />
                </div>
                <div>
                  <label className="text-gray-600">Hourly Rate</label>
                  <input
                    type="number"
                    value={item.hourly_rate}
                    onChange={(e) => updateEquipment(index, 'hourly_rate', parseFloat(e.target.value))}
                    className="w-full px-2 py-1.5 border rounded mt-1"
                  />
                </div>
                <div className="col-span-2">
                  <label className="text-gray-600">Priority</label>
                  <select
                    value={item.priority_level}
                    onChange={(e) => updateEquipment(index, 'priority_level', e.target.value)}
                    className="w-full px-2 py-1.5 border rounded mt-1"
                  >
                    <option value="normal">Normal</option>
                    <option value="high">High</option>
                    <option value="critical">Critical</option>
                  </select>
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

      {selectedEquipment.length > 0 && (
        <div className="flex justify-end">
          <button
            onClick={handleSave}
            disabled={loading}
            className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50"
          >
            {loading ? 'Saving...' : 'Save Equipment'}
          </button>
        </div>
      )}
    </div>
  )
}
