'use client'

import { useState } from 'react'
import { createProject, getProjects } from '../actions/projects/actions'

export default function TestPage() {
  const [result, setResult] = useState<any>(null)
  const [loading, setLoading] = useState(false)

  const testConnection = async () => {
    setLoading(true)
    try {
      const projects = await getProjects()
      setResult(projects)
    } catch (error) {
      setResult({ success: false, error: 'Connection failed' })
    }
    setLoading(false)
  }

  const testCreateProject = async () => {
    setLoading(true)
    const formData = new FormData()
    formData.append('name', 'Test Project')
    formData.append('code', 'TEST-001')
    formData.append('project_type', 'commercial')
    formData.append('start_date', '2024-01-01')
    formData.append('planned_end_date', '2024-12-31')
    formData.append('budget', '1000000')
    
    try {
      const result = await createProject(formData)
      setResult(result)
    } catch (error) {
      setResult({ success: false, error: 'Create failed' })
    }
    setLoading(false)
  }

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-6">Construction Management SaaS - Test</h1>
      
      <div className="space-y-4">
        <button
          onClick={testConnection}
          disabled={loading}
          className="bg-blue-500 text-white px-4 py-2 rounded disabled:opacity-50"
        >
          {loading ? 'Testing...' : 'Test Database Connection'}
        </button>
        
        <button
          onClick={testCreateProject}
          disabled={loading}
          className="bg-green-500 text-white px-4 py-2 rounded disabled:opacity-50 ml-4"
        >
          {loading ? 'Creating...' : 'Test Create Project'}
        </button>
      </div>

      {result && (
        <div className="mt-6 p-4 bg-gray-100 rounded">
          <h2 className="font-bold mb-2">Result:</h2>
          <pre className="text-sm overflow-auto">
            {JSON.stringify(result, null, 2)}
          </pre>
        </div>
      )}
    </div>
  )
}