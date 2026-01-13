'use client'

import { useState, useEffect } from 'react'
import { X } from 'lucide-react'
import { repositories } from '@/lib/repositories'

interface DependencyManagerProps {
  activity: {
    id: string
    name: string
    code: string
  }
  projectId: string
  onSuccess: () => void
  onCancel: () => void
}

interface Activity {
  id: string
  code: string
  name: string
}

export default function DependencyManager({ activity, projectId, onSuccess, onCancel }: DependencyManagerProps) {
  const [loading, setLoading] = useState(false)
  const [availableActivities, setAvailableActivities] = useState<Activity[]>([])
  const [selectedPredecessor, setSelectedPredecessor] = useState('')
  const [currentDependencies, setCurrentDependencies] = useState<Activity[]>([])

  useEffect(() => {
    loadActivities()
  }, [])

  const loadActivities = async () => {
    try {
      const data = await repositories.activities.findByProject(projectId)
      const activities = data
        .filter(a => a.id !== activity.id)
        .map(a => ({ id: a.id, code: a.code, name: a.name }))
      setAvailableActivities(activities)
    } catch (error) {
      console.error('Failed to load activities:', error)
    }
  }

  const addDependency = () => {
    if (!selectedPredecessor) return
    
    const predecessor = availableActivities.find(a => a.id === selectedPredecessor)
    if (predecessor && !currentDependencies.find(d => d.id === predecessor.id)) {
      setCurrentDependencies([...currentDependencies, predecessor])
      setSelectedPredecessor('')
    }
  }

  const removeDependency = (dependencyId: string) => {
    setCurrentDependencies(currentDependencies.filter(d => d.id !== dependencyId))
  }

  const handleSave = async () => {
    setLoading(true)
    try {
      const predecessorIds = currentDependencies.map(d => d.id)
      await repositories.activities.update(activity.id, {
        predecessor_activities: predecessorIds
      })
      onSuccess()
    } catch (error) {
      console.error('Failed to update dependencies:', error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-4">
      <div>
        <label className="block text-sm font-medium">Managing dependencies for: {activity.code} - {activity.name}</label>
      </div>

      <div className="space-y-2">
        <label className="block text-sm font-medium">Add Predecessor Activity</label>
        <div className="flex space-x-2">
          <select
            value={selectedPredecessor}
            onChange={(e) => setSelectedPredecessor(e.target.value)}
            className="flex-1 px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="">Select predecessor activity</option>
            {availableActivities
              .filter(a => !currentDependencies.find(d => d.id === a.id))
              .map((act) => (
              <option key={act.id} value={act.id}>
                {act.code} - {act.name}
              </option>
            ))}
          </select>
          <button
            type="button"
            onClick={addDependency}
            disabled={!selectedPredecessor}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
          >
            Add
          </button>
        </div>
      </div>

      <div className="space-y-2">
        <label className="block text-sm font-medium">Current Dependencies</label>
        {currentDependencies.length === 0 ? (
          <p className="text-sm text-gray-500">No dependencies set</p>
        ) : (
          <div className="space-y-2">
            {currentDependencies.map((dep) => (
              <div key={dep.id} className="flex items-center justify-between p-2 border rounded">
                <span className="text-sm">{dep.code} - {dep.name}</span>
                <button
                  onClick={() => removeDependency(dep.id)}
                  className="p-1 text-red-600 hover:bg-red-100 rounded"
                >
                  <X className="h-3 w-3" />
                </button>
              </div>
            ))}
          </div>
        )}
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
          onClick={handleSave}
          disabled={loading}
          className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
        >
          {loading ? 'Saving...' : 'Save Dependencies'}
        </button>
      </div>
    </div>
  )
}