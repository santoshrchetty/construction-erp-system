'use client'

import React, { useState, useEffect } from 'react'
import { Building, Plus, Edit, Trash2, FolderOpen, FileText, RefreshCw } from 'lucide-react'

interface Project {
  id: string
  code: string
  name: string
  status: string
}

interface WBSElement {
  wbs_element: string
  wbs_description?: string
  total_debits: number
  total_credits: number
  net_amount: number
  transaction_count: number
  last_posting_date: string
}

export function WBSManagement() {
  const [projects, setProjects] = useState<Project[]>([])
  const [selectedProject, setSelectedProject] = useState<string>('')
  const [wbsElements, setWbsElements] = useState<WBSElement[]>([])
  const [loading, setLoading] = useState(false)
  const [projectsLoading, setProjectsLoading] = useState(true)

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
      }
    } catch (error) {
      console.error('Failed to load projects:', error)
    } finally {
      setProjectsLoading(false)
    }
  }

  const loadWBSElements = async (projectCode: string) => {
    if (!projectCode) return

    setLoading(true)
    try {
      const response = await fetch('/api/wbs?action=elements', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ projectCode, companyCode: 'C001' })
      })

      const result = await response.json()
      if (result.success) {
        setWbsElements(result.data || [])
      }
    } catch (error) {
      console.error('Failed to load WBS elements:', error)
      setWbsElements([])
    } finally {
      setLoading(false)
    }
  }

  const handleProjectChange = (projectCode: string) => {
    setSelectedProject(projectCode)
    if (projectCode) {
      loadWBSElements(projectCode)
    } else {
      setWbsElements([])
    }
  }

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0
    }).format(amount)
  }

  return (
    <div className="p-6">

        {/* Project Selection */}
        <div className="bg-white rounded-lg shadow-sm border p-6 mb-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <Building className="w-6 h-6 text-blue-600" />
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Select Project
                </label>
                <select
                  value={selectedProject}
                  onChange={(e) => handleProjectChange(e.target.value)}
                  disabled={projectsLoading}
                  className="w-64 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                >
                  <option value="">Choose a project...</option>
                  {projects.map((project) => (
                    <option key={project.id} value={project.code}>
                      {project.code} - {project.name}
                    </option>
                  ))}
                </select>
              </div>
            </div>
            
            {selectedProject && (
              <button
                onClick={() => loadWBSElements(selectedProject)}
                disabled={loading}
                className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
              >
                <RefreshCw className={`w-4 h-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
                Refresh WBS
              </button>
            )}
          </div>
        </div>

        {/* WBS Elements */}
        {selectedProject && (
          <div className="bg-white rounded-lg shadow-sm border overflow-hidden">
            <div className="px-6 py-4 border-b">
              <div className="flex justify-between items-center">
                <div>
                  <h3 className="text-lg font-medium">WBS Elements - {selectedProject}</h3>
                  <p className="text-sm text-gray-600">Work Breakdown Structure with financial data</p>
                </div>
                <button className="flex items-center px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700">
                  <Plus className="w-4 h-4 mr-2" />
                  Add WBS Element
                </button>
              </div>
            </div>

            {loading ? (
              <div className="p-8 text-center">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
                <p className="mt-2 text-gray-500">Loading WBS elements...</p>
              </div>
            ) : wbsElements.length === 0 ? (
              <div className="p-8 text-center">
                <FolderOpen className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                <p className="text-gray-500">No WBS elements found for this project</p>
                <p className="text-sm text-gray-400 mt-2">Create WBS elements to organize project work</p>
                <button className="mt-4 px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">
                  Create First WBS Element
                </button>
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">WBS Element</th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Description</th>
                      <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Costs</th>
                      <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Revenue</th>
                      <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Net Amount</th>
                      <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Transactions</th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Last Activity</th>
                      <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-200">
                    {wbsElements.map((wbs) => (
                      <tr key={wbs.wbs_element} className="hover:bg-gray-50">
                        <td className="px-6 py-4 font-medium text-blue-600">
                          <div className="flex items-center">
                            <FileText className="w-4 h-4 mr-2 text-gray-400" />
                            {wbs.wbs_element}
                          </div>
                        </td>
                        <td className="px-6 py-4 text-sm text-gray-900">
                          {wbs.wbs_description || 'No description'}
                        </td>
                        <td className="px-6 py-4 text-right text-sm">
                          {formatCurrency(wbs.total_debits)}
                        </td>
                        <td className="px-6 py-4 text-right text-sm">
                          {formatCurrency(wbs.total_credits)}
                        </td>
                        <td className={`px-6 py-4 text-right text-sm font-medium ${
                          wbs.net_amount >= 0 ? 'text-green-600' : 'text-red-600'
                        }`}>
                          {formatCurrency(wbs.net_amount)}
                        </td>
                        <td className="px-6 py-4 text-right text-sm">
                          {wbs.transaction_count}
                        </td>
                        <td className="px-6 py-4 text-sm text-gray-600">
                          {new Date(wbs.last_posting_date).toLocaleDateString()}
                        </td>
                        <td className="px-6 py-4 text-center">
                          <div className="flex items-center justify-center space-x-2">
                            <button className="p-1 text-blue-600 hover:text-blue-800">
                              <Edit className="w-4 h-4" />
                            </button>
                            <button className="p-1 text-red-600 hover:text-red-800">
                              <Trash2 className="w-4 h-4" />
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        )}

        {!selectedProject && (
          <div className="bg-white rounded-lg shadow-sm border p-12 text-center">
            <Building className="w-16 h-16 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">Select a Project</h3>
            <p className="text-gray-600">Choose a project from the dropdown above to view and manage its WBS elements</p>
          </div>
        )}
    </div>
  )
}