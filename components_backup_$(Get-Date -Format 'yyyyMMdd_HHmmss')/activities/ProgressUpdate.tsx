'use client'

import { useState } from 'react'
import { repositories } from '@/lib/repositories'

interface ProgressUpdateProps {
  activity: {
    id: string
    name: string
    progress_percentage: number
    status: string
  }
  onSuccess: () => void
  onCancel: () => void
}

export default function ProgressUpdate({ activity, onSuccess, onCancel }: ProgressUpdateProps) {
  const [loading, setLoading] = useState(false)
  const [progress, setProgress] = useState(activity.progress_percentage)
  const [status, setStatus] = useState(activity.status)
  const [actualStartDate, setActualStartDate] = useState('')
  const [actualEndDate, setActualEndDate] = useState('')

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)

    try {
      await repositories.activities.updateProgress(
        activity.id,
        progress,
        actualStartDate || undefined,
        actualEndDate || undefined
      )
      onSuccess()
    } catch (error) {
      console.error('Failed to update progress:', error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label className="block text-sm font-medium">Activity: {activity.name}</label>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium mb-1">Progress (%)</label>
          <input
            type="number"
            min="0"
            max="100"
            value={progress}
            onChange={(e) => setProgress(parseFloat(e.target.value))}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Status</label>
          <select
            value={status}
            onChange={(e) => setStatus(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="not_started">Not Started</option>
            <option value="in_progress">In Progress</option>
            <option value="completed">Completed</option>
            <option value="on_hold">On Hold</option>
          </select>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium mb-1">Actual Start Date</label>
          <input
            type="date"
            value={actualStartDate}
            onChange={(e) => setActualStartDate(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Actual End Date</label>
          <input
            type="date"
            value={actualEndDate}
            onChange={(e) => setActualEndDate(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
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
          {loading ? 'Updating...' : 'Update Progress'}
        </button>
      </div>
    </form>
  )
}