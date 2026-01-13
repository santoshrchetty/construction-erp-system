'use client'

import React, { useState, useEffect } from 'react'
import WBSBuilder from '../../WBSBuilder'

export function WBSBuilder() {
  const [selectedProjectId, setSelectedProjectId] = useState<string>('')
  const [projects, setProjects] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadProjects()
  }, [])

  const loadProjects = async () => {
    try {
      const response = await fetch('/api/wbs?action=projects', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ companyCode: 'C001' })
      })
      
      const result = await response.json()
      if (result.success) {
        setProjects(result.data || [])
        // Auto-select first project if available
        if (result.data && result.data.length > 0) {
          setSelectedProjectId(result.data[0].id)
        }
      }
    } catch (error) {
      console.error('Failed to load projects:', error)
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading projects...</p>
        </div>
      </div>
    )
  }

  if (projects.length === 0) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-6xl mb-4">🏗️</div>
          <h2 className="text-2xl font-bold text-gray-900 mb-2">No Projects Found</h2>
          <p className="text-gray-600">Create a project first to use WBS Management</p>
        </div>
      </div>
    )
  }

  if (!selectedProjectId) {
    return (
      <div className="min-h-screen bg-gray-50 p-6">
        <div className="max-w-2xl mx-auto">
          <h1 className="text-3xl font-bold text-gray-900 mb-6">WBS Management</h1>
          <div className="bg-white rounded-lg shadow-sm border p-6">
            <h2 className="text-xl font-semibold mb-4">Select Project</h2>
            <div className="space-y-3">
              {projects.map((project) => (
                <button
                  key={project.id}
                  onClick={() => setSelectedProjectId(project.id)}
                  className="w-full text-left p-4 border rounded-lg hover:bg-blue-50 hover:border-blue-300 transition-colors"
                >
                  <div className="font-medium">{project.name}</div>
                  <div className="text-sm text-gray-600">{project.code}</div>
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>
    )
  }

  return <WBSBuilder projectId={selectedProjectId} />
}