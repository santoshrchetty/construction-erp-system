'use client'

import { useState } from 'react'
import { repositories } from '@/lib/repositories'

interface ActivityFormProps {
  projectId: string
  wbsNodes: Array<{ id: string; code: string; name: string }>
  onSuccess: () => void
  onCancel: () => void
}

export default function ActivityForm({ projectId, wbsNodes, onSuccess, onCancel }: ActivityFormProps) {
  const [loading, setLoading] = useState(false)
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    wbs_node_id: '',
    planned_start_date: '',
    planned_end_date: '',
    duration_days: 1,
    planned_hours: 0,
    budget_amount: 0
  })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)

    try {
      await repositories.activities.create({
        project_id: projectId,
        wbs_node_id: formData.wbs_node_id,
        code: `ACT-${Date.now()}`,
        name: formData.name,
        description: formData.description,
        planned_start_date: formData.planned_start_date,
        planned_end_date: formData.planned_end_date,
        duration_days: formData.duration_days,
        planned_hours: formData.planned_hours,
        budget_amount: formData.budget_amount
      })
      onSuccess()
    } catch (error) {
      console.error('Failed to create activity:', error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label className="block text-sm font-medium mb-1">Activity Name</label>
        <input
          type="text"
          value={formData.name}
          onChange={(e) => setFormData({ ...formData, name: e.target.value })}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          required
        />
      </div>

      <div>
        <label className="block text-sm font-medium mb-1">WBS Node</label>
        <select
          value={formData.wbs_node_id}
          onChange={(e) => setFormData({ ...formData, wbs_node_id: e.target.value })}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
        >
          <option value="">Select WBS Node</option>
          {wbsNodes.map((node) => (
            <option key={node.id} value={node.id}>
              {node.code} - {node.name}
            </option>
          ))}
        </select>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium mb-1">Start Date</label>
          <input
            type="date"
            value={formData.planned_start_date}
            onChange={(e) => setFormData({ ...formData, planned_start_date: e.target.value })}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">End Date</label>
          <input
            type="date"
            value={formData.planned_end_date}
            onChange={(e) => setFormData({ ...formData, planned_end_date: e.target.value })}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
      </div>

      <div className="grid grid-cols-3 gap-4">
        <div>
          <label className="block text-sm font-medium mb-1">Duration (days)</label>
          <input
            type="number"
            value={formData.duration_days}
            onChange={(e) => setFormData({ ...formData, duration_days: parseInt(e.target.value) })}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Planned Hours</label>
          <input
            type="number"
            value={formData.planned_hours}
            onChange={(e) => setFormData({ ...formData, planned_hours: parseFloat(e.target.value) })}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Budget</label>
          <input
            type="number"
            value={formData.budget_amount}
            onChange={(e) => setFormData({ ...formData, budget_amount: parseFloat(e.target.value) })}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium mb-1">Description</label>
        <textarea
          value={formData.description}
          onChange={(e) => setFormData({ ...formData, description: e.target.value })}
          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          rows={3}
        />
      </div>

      <div className="flex justify-end space-x-2">
        <button
          type="button"
          onClick={onCancel}
          className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
        >
          Cancel
        </button>
        <button
          type="submit"
          disabled={loading}
          className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
        >
          {loading ? 'Creating...' : 'Create Activity'}
        </button>
      </div>
    </form>
  )
}