'use client'

import React, { useState, useEffect } from 'react'
import { DollarSign, TrendingUp, RefreshCw, Filter } from 'lucide-react'

interface ProjectCost {
  project_code: string
  wbs_element: string
  gl_account: string
  account_name: string
  account_type: string
  debit_amount: number
  credit_amount: number
  net_amount: number
  cost_center: string
}

export function ProjectCostManagement() {
  const [costs, setCosts] = useState<ProjectCost[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedProject, setSelectedProject] = useState('')
  const [projects, setProjects] = useState<string[]>(['P100'])

  // Get project from URL params or localStorage
  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search)
    const projectFromUrl = urlParams.get('project')
    const projectFromStorage = localStorage.getItem('selectedProject')
    
    if (projectFromUrl) {
      setSelectedProject(projectFromUrl)
    } else if (projectFromStorage) {
      setSelectedProject(projectFromStorage)
    } else {
      setSelectedProject('P100') // Default
    }
  }, [])

  const loadProjectCosts = async () => {
    setLoading(true)
    try {
      const response = await fetch('/api/projects?action=costs', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
          projectCode: selectedProject,
          companyCode: 'C001' 
        })
      })
      
      const result = await response.json()
      
      if (result.success) {
        setCosts(result.data)
      }
    } catch (error) {
      console.error('Failed to load project costs:', error)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadProjectCosts()
  }, [selectedProject])

  const totalCosts = costs.reduce((sum, cost) => sum + cost.debit_amount, 0)
  const totalRevenue = costs.reduce((sum, cost) => sum + cost.credit_amount, 0)
  const netAmount = totalCosts - totalRevenue

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm border-b px-4 py-3">
        <div className="flex justify-between items-center">
          <h2 className="text-lg font-semibold text-gray-900">Project Cost Management</h2>
          <div className="flex items-center space-x-2">
            <select
              value={selectedProject}
              onChange={(e) => {
                setSelectedProject(e.target.value)
                localStorage.setItem('selectedProject', e.target.value)
              }}
              className="border rounded-lg px-3 py-2"
            >
              <option value="">All Projects</option>
              <option value="P100">Project P100</option>
            </select>
            <button
              onClick={loadProjectCosts}
              disabled={loading}
              className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center"
            >
              <RefreshCw className={`w-4 h-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
              Refresh
            </button>
          </div>
        </div>
      </div>

      <div className="p-4">
        {/* Summary Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          <div className="bg-white p-6 rounded-lg shadow-sm border">
            <div className="flex items-center">
              <DollarSign className="w-8 h-8 text-red-600 mr-3" />
              <div>
                <p className="text-sm text-gray-600">Total Costs</p>
                <p className="text-2xl font-bold text-red-900">${totalCosts.toLocaleString()}</p>
              </div>
            </div>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-sm border">
            <div className="flex items-center">
              <TrendingUp className="w-8 h-8 text-green-600 mr-3" />
              <div>
                <p className="text-sm text-gray-600">Total Revenue</p>
                <p className="text-2xl font-bold text-green-900">${totalRevenue.toLocaleString()}</p>
              </div>
            </div>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-sm border">
            <div className="flex items-center">
              <Filter className="w-8 h-8 text-purple-600 mr-3" />
              <div>
                <p className="text-sm text-gray-600">Net Amount</p>
                <p className={`text-2xl font-bold ${netAmount >= 0 ? 'text-green-900' : 'text-red-900'}`}>
                  ${netAmount.toLocaleString()}
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Cost Details Table */}
        <div className="bg-white rounded-lg shadow-sm border overflow-hidden">
          <div className="px-4 py-3 border-b">
            <h3 className="text-lg font-medium">Cost Details</h3>
            <p className="text-sm text-gray-600">Real-time from Universal Journal</p>
          </div>

          {loading ? (
            <div className="p-8 text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
              <p className="mt-2 text-gray-500">Loading cost data...</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Project</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">WBS</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Account</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Description</th>
                    <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Debit</th>
                    <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Credit</th>
                    <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Net</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {costs.map((cost, index) => (
                    <tr key={index} className="hover:bg-gray-50">
                      <td className="px-4 py-3 font-medium">{cost.project_code}</td>
                      <td className="px-4 py-3">{cost.wbs_element || '-'}</td>
                      <td className="px-4 py-3 font-mono">{cost.gl_account}</td>
                      <td className="px-4 py-3">{cost.account_name}</td>
                      <td className="px-4 py-3 text-right">
                        {cost.debit_amount > 0 ? `$${cost.debit_amount.toLocaleString()}` : '-'}
                      </td>
                      <td className="px-4 py-3 text-right">
                        {cost.credit_amount > 0 ? `$${cost.credit_amount.toLocaleString()}` : '-'}
                      </td>
                      <td className={`px-4 py-3 text-right font-medium ${
                        cost.net_amount >= 0 ? 'text-green-600' : 'text-red-600'
                      }`}>
                        ${cost.net_amount.toLocaleString()}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}