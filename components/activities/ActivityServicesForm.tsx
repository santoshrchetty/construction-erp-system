'use client'

import { useState, useEffect } from 'react'
import { Plus, Trash2 } from 'lucide-react'
import { Select, SelectItem } from '@/components/ui/select'

interface ActivityService {
  id?: string
  service_type: string
  service_description: string
  scheduled_date: string
  duration_hours: number
  unit_cost: number
  priority_level: string
  actual_cost?: number
}

interface ActivityServicesFormProps {
  activityId: string
}

export function ActivityServicesForm({ activityId }: ActivityServicesFormProps) {
  const [services, setServices] = useState<ActivityService[]>([])
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    fetchServices()
  }, [activityId])

  const fetchServices = async () => {
    const res = await fetch(`/api/activities?action=services&activityId=${activityId}`)
    const data = await res.json()
    setServices(Array.isArray(data) ? data : [])
  }

  const addService = () => {
    setServices([...services, {
      service_type: 'testing',
      service_description: '',
      scheduled_date: '',
      duration_hours: 1,
      unit_cost: 0,
      priority_level: 'normal'
    }])
  }

  const removeService = (index: number) => {
    setServices(services.filter((_, i) => i !== index))
  }

  const updateService = (index: number, field: keyof ActivityService, value: any) => {
    const updated = [...services]
    updated[index] = { ...updated[index], [field]: value }
    setServices(updated)
  }

  const handleSave = async () => {
    setLoading(true)
    try {
      await fetch('/api/activities?action=attach-services', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ activityId, services })
      })
      alert('Services saved successfully!')
      fetchServices()
    } catch (error) {
      alert('Failed to save services')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold">Activity Services</h3>
        <button
          onClick={addService}
          className="flex items-center gap-2 px-3 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          <Plus size={16} />
          Add Service
        </button>
      </div>

      <div className="space-y-3">
        {services.map((item, index) => {
          const plannedTotal = item.duration_hours * item.unit_cost
          const actualTotal = item.actual_cost || 0
          
          return (
          <div key={index} className="border rounded-lg">
            {/* Desktop View */}
            <div className="hidden md:flex gap-3 items-start p-3">
              <div className="flex-1 grid grid-cols-7 gap-3">
                <Select value={item.service_type} onValueChange={(value) => updateService(index, 'service_type', value)}>
                  <SelectItem value="testing">Testing</SelectItem>
                  <SelectItem value="inspection">Inspection</SelectItem>
                  <SelectItem value="certification">Certification</SelectItem>
                  <SelectItem value="survey">Survey</SelectItem>
                  <SelectItem value="commissioning">Commissioning</SelectItem>
                  <SelectItem value="other">Other</SelectItem>
                </Select>

                <input
                  type="text"
                  placeholder="Description"
                  value={item.service_description}
                  onChange={(e) => updateService(index, 'service_description', e.target.value)}
                  className="px-3 py-2 border rounded-lg"
                />

                <input
                  type="date"
                  value={item.scheduled_date}
                  onChange={(e) => updateService(index, 'scheduled_date', e.target.value)}
                  className="px-3 py-2 border rounded-lg"
                />

                <input
                  type="number"
                  placeholder="Hours"
                  value={item.duration_hours}
                  onChange={(e) => updateService(index, 'duration_hours', parseFloat(e.target.value))}
                  className="px-3 py-2 border rounded-lg"
                />

                <input
                  type="number"
                  placeholder="Unit Cost"
                  value={item.unit_cost}
                  onChange={(e) => updateService(index, 'unit_cost', parseFloat(e.target.value))}
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
                onClick={() => removeService(index)}
                className="p-2 text-red-600 hover:bg-red-50 rounded-lg"
              >
                <Trash2 size={16} />
              </button>
            </div>

            {/* Mobile View */}
            <div className="md:hidden p-3 space-y-2">
              <div className="flex justify-between items-start">
                <div className="font-semibold text-sm capitalize">{item.service_type}</div>
                <button
                  onClick={() => removeService(index)}
                  className="p-1 text-red-600 hover:bg-red-50 rounded"
                >
                  <Trash2 size={16} />
                </button>
              </div>
              <div className="space-y-2 text-xs">
                <div>
                  <label className="text-gray-600">Type</label>
                  <Select value={item.service_type} onValueChange={(value) => updateService(index, 'service_type', value)}>
                    <SelectItem value="testing">Testing</SelectItem>
                    <SelectItem value="inspection">Inspection</SelectItem>
                    <SelectItem value="certification">Certification</SelectItem>
                    <SelectItem value="survey">Survey</SelectItem>
                    <SelectItem value="commissioning">Commissioning</SelectItem>
                    <SelectItem value="other">Other</SelectItem>
                  </Select>
                </div>
                <div>
                  <label className="text-gray-600">Description</label>
                  <input
                    type="text"
                    value={item.service_description}
                    onChange={(e) => updateService(index, 'service_description', e.target.value)}
                    className="w-full px-2 py-1.5 border rounded mt-1"
                  />
                </div>
                <div className="grid grid-cols-2 gap-2">
                  <div>
                    <label className="text-gray-600">Date</label>
                    <input
                      type="date"
                      value={item.scheduled_date}
                      onChange={(e) => updateService(index, 'scheduled_date', e.target.value)}
                      className="w-full px-2 py-1.5 border rounded mt-1"
                    />
                  </div>
                  <div>
                    <label className="text-gray-600">Hours</label>
                    <input
                      type="number"
                      value={item.duration_hours}
                      onChange={(e) => updateService(index, 'duration_hours', parseFloat(e.target.value))}
                      className="w-full px-2 py-1.5 border rounded mt-1"
                    />
                  </div>
                  <div className="col-span-2">
                    <label className="text-gray-600">Unit Cost</label>
                    <input
                      type="number"
                      value={item.unit_cost}
                      onChange={(e) => updateService(index, 'unit_cost', parseFloat(e.target.value))}
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

      {services.length > 0 && (
        <div className="flex justify-end">
          <button
            onClick={handleSave}
            disabled={loading}
            className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50"
          >
            {loading ? 'Saving...' : 'Save Services'}
          </button>
        </div>
      )}
    </div>
  )
}
