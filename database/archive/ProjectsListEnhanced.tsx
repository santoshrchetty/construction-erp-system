// DEPRECATED: This file is marked for removal - no active dependencies found
// TODO: Remove after confirming no imports
/*
'use client'

import { useState, useEffect } from 'react'
import { repositories } from '@/lib/repositories'

interface Project {
  id: string
  name: string
  code: string
  description?: string
  project_type: string
  status: string
  start_date: string
  planned_end_date: string
  actual_end_date?: string
  budget: number
  location?: string
  created_at: string
}

interface ProjectsListProps {
  onProjectSelect?: (projectId: string, projectName: string) => void
}

export default function ProjectsList({ onProjectSelect }: ProjectsListProps) {
  const [projects, setProjects] = useState<Project[]>([])
  const [filteredProjects, setFilteredProjects] = useState<Project[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')
  const [typeFilter, setTypeFilter] = useState('all')
  const [sortBy, setSortBy] = useState('name')
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('asc')
  const [currentPage, setCurrentPage] = useState(1)
  const [itemsPerPage] = useState(12)
  const [viewMode, setViewMode] = useState<'table' | 'cards'>('cards')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadProjects()
  }, [])

  useEffect(() => {
    filterAndSortProjects()
  }, [projects, searchTerm, statusFilter, typeFilter, sortBy, sortOrder])

  const loadProjects = async () => {
    try {
      const data = await repositories.projects.findAll()
      setProjects(data)
    } catch (error) {
      console.error('Failed to load projects:', error)
    } finally {
      setLoading(false)
    }
  }

  const filterAndSortProjects = () => {
    let filtered = projects

    if (searchTerm) {
      filtered = filtered.filter(project =>
        project.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        project.code.toLowerCase().includes(searchTerm.toLowerCase()) ||
        project.description?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        project.location?.toLowerCase().includes(searchTerm.toLowerCase())
      )
    }

    if (statusFilter !== 'all') {
      filtered = filtered.filter(project => project.status === statusFilter)
    }

    if (typeFilter !== 'all') {
      filtered = filtered.filter(project => project.project_type === typeFilter)
    }

    filtered.sort((a, b) => {
      let aValue: any, bValue: any
      
      switch (sortBy) {
        case 'code':
          aValue = a.code
          bValue = b.code
          break
        case 'status':
          aValue = a.status
          bValue = b.status
          break
        case 'budget':
          aValue = a.budget
          bValue = b.budget
          break
        case 'start_date':
          aValue = new Date(a.start_date)
          bValue = new Date(b.start_date)
          break
        default:
          aValue = a.name
          bValue = b.name
      }

      if (typeof aValue === 'string') {
        return sortOrder === 'asc' ? aValue.localeCompare(bValue) : bValue.localeCompare(aValue)
      }
      return sortOrder === 'asc' ? aValue - bValue : bValue - aValue
    })

    setFilteredProjects(filtered)
    setCurrentPage(1)
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active': return 'bg-green-100 text-green-800'
      case 'planning': return 'bg-blue-100 text-blue-800'
      case 'on_hold': return 'bg-yellow-100 text-yellow-800'
      case 'completed': return 'bg-gray-100 text-gray-800'
      default: return 'bg-red-100 text-red-800'
    }
  }

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0
    }).format(amount)
  }

  const handleSort = (field: string) => {
    if (sortBy === field) {
      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc')
    } else {
      setSortBy(field)
      setSortOrder('asc')
    }
  }

  const totalPages = Math.ceil(filteredProjects.length / itemsPerPage)
  const startIndex = (currentPage - 1) * itemsPerPage
  const paginatedProjects = filteredProjects.slice(startIndex, startIndex + itemsPerPage)

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold">Projects ({filteredProjects.length})</h1>
          <p className="text-gray-600 text-sm">Construction project portfolio</p>
        </div>
        <div className="flex space-x-2">
          <button 
            onClick={() => setViewMode(viewMode === 'table' ? 'cards' : 'table')}
            className="px-3 py-1 bg-gray-200 rounded text-sm hover:bg-gray-300"
          >
            {viewMode === 'table' ? '📋 Cards' : '📊 Table'}
          </button>
          <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 text-sm">
            + New Project
          </button>
        </div>
      </div>

      <div className="flex flex-wrap gap-4 items-center bg-gray-50 p-4 rounded">
        <div className="flex-1 min-w-64">
          <input
            type="text"
            placeholder="Search projects..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full px-3 py-2 border rounded text-sm"
          />
        </div>
        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          className="px-3 py-2 border rounded text-sm"
        >
          <option value="all">All Status</option>
          <option value="planning">Planning</option>
          <option value="active">Active</option>
          <option value="on_hold">On Hold</option>
          <option value="completed">Completed</option>
        </select>
        <select
          value={typeFilter}
          onChange={(e) => setTypeFilter(e.target.value)}
          className="px-3 py-2 border rounded text-sm"
        >
          <option value="all">All Types</option>
          <option value="residential">Residential</option>
          <option value="commercial">Commercial</option>
          <option value="infrastructure">Infrastructure</option>
          <option value="industrial">Industrial</option>
        </select>
        <select
          value={sortBy}
          onChange={(e) => setSortBy(e.target.value)}
          className="px-3 py-2 border rounded text-sm"
        >
          <option value="name">Sort by Name</option>
          <option value="code">Sort by Code</option>
          <option value="status">Sort by Status</option>
          <option value="budget">Sort by Budget</option>
          <option value="start_date">Sort by Start Date</option>
        </select>
      </div>

      {viewMode === 'table' && (
        <div className="bg-white rounded shadow overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-4 py-3 text-left cursor-pointer hover:bg-gray-100" onClick={() => handleSort('code')}>
                    Code {sortBy === 'code' && (sortOrder === 'asc' ? '↑' : '↓')}
                  </th>
                  <th className="px-4 py-3 text-left cursor-pointer hover:bg-gray-100" onClick={() => handleSort('name')}>
                    Name {sortBy === 'name' && (sortOrder === 'asc' ? '↑' : '↓')}
                  </th>
                  <th className="px-4 py-3 text-left">Type</th>
                  <th className="px-4 py-3 text-left cursor-pointer hover:bg-gray-100" onClick={() => handleSort('status')}>
                    Status {sortBy === 'status' && (sortOrder === 'asc' ? '↑' : '↓')}
                  </th>
                  <th className="px-4 py-3 text-left cursor-pointer hover:bg-gray-100" onClick={() => handleSort('budget')}>
                    Budget {sortBy === 'budget' && (sortOrder === 'asc' ? '↑' : '↓')}
                  </th>
                  <th className="px-4 py-3 text-left cursor-pointer hover:bg-gray-100" onClick={() => handleSort('start_date')}>
                    Start Date {sortBy === 'start_date' && (sortOrder === 'asc' ? '↑' : '↓')}
                  </th>
                  <th className="px-4 py-3 text-left">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {paginatedProjects.map((project) => (
                  <tr key={project.id} className="hover:bg-gray-50">
                    <td className="px-4 py-3 font-mono text-xs">{project.code}</td>
                    <td className="px-4 py-3">
                      <div className="font-medium">{project.name}</div>
                      {project.location && (
                        <div className="text-xs text-gray-500">{project.location}</div>
                      )}
                    </td>
                    <td className="px-4 py-3 text-xs capitalize">{project.project_type}</td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-1 rounded text-xs ${getStatusColor(project.status)}`}>
                        {project.status}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-xs">{formatCurrency(project.budget)}</td>
                    <td className="px-4 py-3 text-xs">{new Date(project.start_date).toLocaleDateString()}</td>
                    <td className="px-4 py-3">
                      <div className="flex space-x-1">
                        <button 
                          onClick={() => onProjectSelect?.(project.id, project.name)}
                          className="text-blue-600 hover:text-blue-800 text-xs px-2 py-1 rounded hover:bg-blue-50"
                        >
                          Select
                        </button>
                        <button className="text-green-600 hover:text-green-800 text-xs px-2 py-1 rounded hover:bg-green-50">
                          Edit
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {viewMode === 'cards' && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {paginatedProjects.map((project) => (
            <div key={project.id} className="bg-white rounded shadow p-4 hover:shadow-lg transition-shadow">
              <div className="flex justify-between items-start mb-3">
                <div className="flex-1">
                  <h3 className="font-medium text-sm">{project.name}</h3>
                  <p className="text-xs text-gray-600 mt-1">{project.code}</p>
                  {project.location && (
                    <p className="text-xs text-gray-500 mt-1">📍 {project.location}</p>
                  )}
                </div>
                <span className={`px-2 py-1 rounded text-xs ${getStatusColor(project.status)}`}>
                  {project.status}
                </span>
              </div>
              
              <div className="space-y-2 text-xs text-gray-600">
                <div>Type: <span className="capitalize">{project.project_type}</span></div>
                <div>Budget: {formatCurrency(project.budget)}</div>
                <div>Start: {new Date(project.start_date).toLocaleDateString()}</div>
                <div>End: {new Date(project.planned_end_date).toLocaleDateString()}</div>
              </div>
              
              <div className="flex space-x-2 pt-3 mt-3 border-t">
                <button 
                  onClick={() => onProjectSelect?.(project.id, project.name)}
                  className="flex-1 text-blue-600 hover:text-blue-800 text-xs px-2 py-1 rounded hover:bg-blue-50 border"
                >
                  Select
                </button>
                <button className="flex-1 text-green-600 hover:text-green-800 text-xs px-2 py-1 rounded hover:bg-green-50 border">
                  Edit
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {totalPages > 1 && (
        <div className="flex justify-between items-center bg-white p-4 rounded shadow">
          <div className="text-sm text-gray-600">
            Showing {startIndex + 1}-{Math.min(startIndex + itemsPerPage, filteredProjects.length)} of {filteredProjects.length} projects
          </div>
          <div className="flex space-x-2">
            <button
              onClick={() => setCurrentPage(Math.max(1, currentPage - 1))}
              disabled={currentPage === 1}
              className="px-3 py-1 border rounded text-sm disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50"
            >
              Previous
            </button>
            <span className="px-3 py-1 text-sm">
              Page {currentPage} of {totalPages}
            </span>
            <button
              onClick={() => setCurrentPage(Math.min(totalPages, currentPage + 1))}
              disabled={currentPage === totalPages}
              className="px-3 py-1 border rounded text-sm disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50"
            >
              Next
            </button>
          </div>
        </div>
      )}

      {filteredProjects.length === 0 && (
        <div className="text-center py-12 bg-white rounded shadow">
          <p className="text-gray-500 mb-4">
            {searchTerm || statusFilter !== 'all' || typeFilter !== 'all' ? 'No projects match your filters.' : 'No projects found.'}
          </p>
          <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
            Create First Project
          </button>
        </div>
      )}
    </div>
  )
}
*/