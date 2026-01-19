'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase/client'
import ResourcePlanningManager from './ResourcePlanningManager'

interface Project {
  id: string
  code: string
  name: string
}

export default function ResourcePlanningWithSelector() {
  const [projects, setProjects] = useState<Project[]>([])
  const [selectedProjectId, setSelectedProjectId] = useState<string>('')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchProjects()
  }, [])

  const fetchProjects = async () => {
    const supabase = createClient()
    const { data } = await supabase
      .from('projects')
      .select('id, code, name')
      .order('code')
    
    setProjects(data || [])
    if (data && data.length > 0) {
      setSelectedProjectId(data[0].id)
    }
    setLoading(false)
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  if (projects.length === 0) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <p className="text-gray-600 mb-2">No active projects found</p>
          <p className="text-sm text-gray-500">Create a project first to plan resources</p>
        </div>
      </div>
    )
  }

  return (
    <div className="h-full flex flex-col">
      <div className="bg-white border-b px-4 py-3">
        <select
          value={selectedProjectId}
          onChange={(e) => setSelectedProjectId(e.target.value)}
          className="px-3 py-2 border rounded-lg text-sm w-full max-w-md"
        >
          {projects.map((project) => (
            <option key={project.id} value={project.id}>
              {project.code} - {project.name}
            </option>
          ))}
        </select>
      </div>
      
      <div className="flex-1 overflow-hidden">
        {selectedProjectId && <ResourcePlanningManager projectId={selectedProjectId} />}
      </div>
    </div>
  )
}
