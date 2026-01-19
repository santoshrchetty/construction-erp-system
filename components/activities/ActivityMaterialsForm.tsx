'use client'

import { useState, useEffect } from 'react'
import { Plus, Trash2 } from 'lucide-react'

interface Material {
  id: string
  material_code: string
  material_name: string
  base_uom: string
  standard_price: number
}

interface ActivityMaterial {
  material_id: string
  material_code?: string
  material_name?: string
  required_quantity: number
  unit_of_measure: string
  unit_cost: number
  priority_level?: string
  notes?: string
  actual_cost?: number
}

interface ActivityMaterialsFormProps {
  activityId: string
}

export default function ActivityMaterialsForm({ activityId }: ActivityMaterialsFormProps) {
  const [materials, setMaterials] = useState<Material[]>([])
  const [selectedMaterials, setSelectedMaterials] = useState<ActivityMaterial[]>([])
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    fetchMaterials()
    fetchActivityMaterials()
  }, [activityId])

  const fetchMaterials = async () => {
    try {
      const res = await fetch('/api/materials')
      const json = await res.json()
      setMaterials(json.data || [])
    } catch (error) {
      console.error('Failed to fetch materials:', error)
      setMaterials([])
    }
  }

  const fetchActivityMaterials = async () => {
    const res = await fetch(`/api/activities?action=materials&activityId=${activityId}`)
    const data = await res.json()
    setSelectedMaterials(Array.isArray(data) ? data : [])
  }

  const addMaterial = () => {
    setSelectedMaterials([...selectedMaterials, {
      material_id: '',
      required_quantity: 0,
      unit_of_measure: '',
      unit_cost: 0,
      priority_level: 'normal'
    }])
  }

  const removeMaterial = (index: number) => {
    setSelectedMaterials(selectedMaterials.filter((_, i) => i !== index))
  }

  const updateMaterial = (index: number, field: keyof ActivityMaterial, value: any) => {
    const updated = [...selectedMaterials]
    updated[index] = { ...updated[index], [field]: value }
    
    if (field === 'material_id') {
      const material = materials.find(m => m.id === value)
      if (material) {
        updated[index].unit_of_measure = material.base_uom
        updated[index].unit_cost = material.standard_price
      }
    }
    
    setSelectedMaterials(updated)
  }

  const handleSave = async () => {
    setLoading(true)
    try {
      await fetch('/api/activities?action=attach-materials', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ activityId, materials: selectedMaterials })
      })
      alert('Materials saved successfully!')
    } catch (error) {
      alert('Failed to save materials')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold">Activity Materials</h3>
        <button
          onClick={addMaterial}
          className="flex items-center gap-2 px-3 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          <Plus size={16} />
          Add Material
        </button>
      </div>

      <div className="space-y-3">
        {selectedMaterials.map((item, index) => {
          const material = materials.find(m => m.id === item.material_id)
          const plannedTotal = item.required_quantity * item.unit_cost
          const actualTotal = item.actual_cost || 0
          
          return (
          <div key={index} className="border rounded-lg">
            {/* Desktop View */}
            <div className="hidden md:flex gap-3 items-start p-3">
              <div className="flex-1 grid grid-cols-7 gap-3">
                <div className="px-3 py-2 border rounded-lg bg-gray-50">
                  {item.material_code ? `${item.material_code} - ${item.material_name}` : 'Material'}
                </div>

                <input
                  type="number"
                  placeholder="Quantity"
                  value={item.required_quantity}
                  onChange={(e) => updateMaterial(index, 'required_quantity', parseFloat(e.target.value))}
                  className="px-3 py-2 border rounded-lg"
                />

                <input
                  type="text"
                  placeholder="Unit"
                  value={item.unit_of_measure}
                  onChange={(e) => updateMaterial(index, 'unit_of_measure', e.target.value)}
                  className="px-3 py-2 border rounded-lg"
                />

                <input
                  type="number"
                  placeholder="Unit Cost"
                  value={item.unit_cost}
                  onChange={(e) => updateMaterial(index, 'unit_cost', parseFloat(e.target.value))}
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
                  onChange={(e) => updateMaterial(index, 'priority_level', e.target.value)}
                  className="px-3 py-2 border rounded-lg text-sm"
                >
                  <option value="normal">Normal</option>
                  <option value="high">High</option>
                  <option value="critical">Critical</option>
                  <option value="low">Low</option>
                </select>
              </div>

              <button
                onClick={() => removeMaterial(index)}
                className="p-2 text-red-600 hover:bg-red-50 rounded-lg"
              >
                <Trash2 size={16} />
              </button>
            </div>

            {/* Mobile View */}
            <div className="md:hidden p-3 space-y-2">
              <div className="flex justify-between items-start">
                <div className="font-semibold text-sm">{item.material_code ? `${item.material_code} - ${item.material_name}` : 'Material'}</div>
                <button
                  onClick={() => removeMaterial(index)}
                  className="p-1 text-red-600 hover:bg-red-50 rounded"
                >
                  <Trash2 size={16} />
                </button>
              </div>
              <div className="grid grid-cols-2 gap-2 text-xs">
                <div>
                  <label className="text-gray-600">Quantity</label>
                  <input
                    type="number"
                    value={item.required_quantity}
                    onChange={(e) => updateMaterial(index, 'required_quantity', parseFloat(e.target.value))}
                    className="w-full px-2 py-1.5 border rounded mt-1"
                  />
                </div>
                <div>
                  <label className="text-gray-600">Unit</label>
                  <input
                    type="text"
                    value={item.unit_of_measure}
                    onChange={(e) => updateMaterial(index, 'unit_of_measure', e.target.value)}
                    className="w-full px-2 py-1.5 border rounded mt-1"
                  />
                </div>
                <div>
                  <label className="text-gray-600">Unit Cost</label>
                  <input
                    type="number"
                    value={item.unit_cost}
                    onChange={(e) => updateMaterial(index, 'unit_cost', parseFloat(e.target.value))}
                    className="w-full px-2 py-1.5 border rounded mt-1"
                  />
                </div>
                <div>
                  <label className="text-gray-600">Priority</label>
                  <select
                    value={item.priority_level}
                    onChange={(e) => updateMaterial(index, 'priority_level', e.target.value)}
                    className="w-full px-2 py-1.5 border rounded mt-1"
                  >
                    <option value="normal">Normal</option>
                    <option value="high">High</option>
                    <option value="critical">Critical</option>
                    <option value="low">Low</option>
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

      {selectedMaterials.length > 0 && (
        <div className="flex justify-end">
          <button
            onClick={handleSave}
            disabled={loading}
            className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50"
          >
            {loading ? 'Saving...' : 'Save Materials'}
          </button>
        </div>
      )}
    </div>
  )
}
