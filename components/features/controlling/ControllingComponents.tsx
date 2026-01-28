import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'

// Enhanced Project Cost Analysis (CJI3 equivalent)
export function ProjectCostAnalysis() {
  const [projects, setProjects] = useState([])
  const [selectedProject, setSelectedProject] = useState('')
  const [selectedWBS, setSelectedWBS] = useState('')
  const [wbsNodes, setWbsNodes] = useState([])
  const [costData, setCostData] = useState([])
  const [loading, setLoading] = useState(false)
  const [viewMode, setViewMode] = useState('summary') // summary, detail, variance
  const [dateRange, setDateRange] = useState('current')

  useEffect(() => {
    loadProjects()
  }, [])

  useEffect(() => {
    if (selectedProject) {
      loadWBSNodes()
      loadCostData()
    }
  }, [selectedProject, selectedWBS, dateRange])

  const loadProjects = async () => {
    try {
      const response = await fetch('/api/projects')
      const result = await response.json()
      if (result.success) {
        setProjects(result.data || [])
      }
    } catch (error) {
      console.error('Error loading projects:', error)
    }
  }

  const loadWBSNodes = async () => {
    if (!selectedProject) return
    
    try {
      const project = projects.find(p => p.code === selectedProject)
      if (project) {
        const response = await fetch(`/api/wbs?projectId=${project.id}`)
        const result = await response.json()
        if (result.success) {
          setWbsNodes(result.data || [])
        }
      }
    } catch (error) {
      console.error('Error loading WBS:', error)
    }
  }

  const loadCostData = async () => {
    if (!selectedProject) return
    
    setLoading(true)
    try {
      // Mock data - replace with API call to project_line_items view
      const mockCostData = [
        {
          cost_element: '400100',
          cost_element_name: 'Raw Materials Consumed',
          cost_category: 'MATERIAL',
          wbs_element: 'WBS-01-01',
          wbs_name: 'Foundation Work',
          plan_cost: 50000,
          actual_cost: 45000,
          commitment_cost: 15000,
          variance: 5000,
          transactions: 12
        },
        {
          cost_element: '600100',
          cost_element_name: 'Direct Labor - Site Workers',
          cost_category: 'LABOR',
          wbs_element: 'WBS-01-01',
          wbs_name: 'Foundation Work',
          plan_cost: 75000,
          actual_cost: 82000,
          commitment_cost: 0,
          variance: -7000,
          transactions: 24
        },
        {
          cost_element: '450100',
          cost_element_name: 'Subcontractor - Civil Work',
          cost_category: 'SUBCONTRACT',
          wbs_element: 'WBS-01-02',
          wbs_name: 'Structural Work',
          plan_cost: 125000,
          actual_cost: 95000,
          commitment_cost: 35000,
          variance: 30000,
          transactions: 8
        }
      ]
      
      const filtered = selectedWBS 
        ? mockCostData.filter(item => item.wbs_element === selectedWBS)
        : mockCostData
      
      setCostData(filtered)
    } catch (error) {
      console.error('Error loading cost data:', error)
    } finally {
      setLoading(false)
    }
  }

  const totalPlan = costData.reduce((sum, item) => sum + item.plan_cost, 0)
  const totalActual = costData.reduce((sum, item) => sum + item.actual_cost, 0)
  const totalCommitment = costData.reduce((sum, item) => sum + item.commitment_cost, 0)
  const totalVariance = costData.reduce((sum, item) => sum + item.variance, 0)
  const totalAtCompletion = totalActual + totalCommitment

  const getCategoryColor = (category) => {
    switch (category) {
      case 'MATERIAL': return 'bg-blue-100 text-blue-800'
      case 'LABOR': return 'bg-green-100 text-green-800'
      case 'EQUIPMENT': return 'bg-purple-100 text-purple-800'
      case 'SUBCONTRACT': return 'bg-orange-100 text-orange-800'
      case 'OVERHEAD': return 'bg-gray-100 text-gray-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const getVarianceColor = (variance) => {
    if (variance > 0) return 'text-green-600' // Under budget
    if (variance < 0) return 'text-red-600'   // Over budget
    return 'text-gray-600'
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm border-b px-4 py-3 sticky top-0 z-10">
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
          <h2 className="text-lg font-semibold text-gray-900 mb-2 sm:mb-0">Project Cost Analysis (CJI3)</h2>
          <div className="flex items-center space-x-2">
            <span className="text-sm text-gray-500">Real-time project costs</span>
          </div>
        </div>
      </div>

      <div className="p-4">
        {/* Selection Controls */}
        <div className="bg-white rounded-lg shadow-sm border p-4 mb-6">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
              <label className="block text-sm font-medium mb-2">Project</label>
              <select 
                className="w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
                value={selectedProject}
                onChange={(e) => setSelectedProject(e.target.value)}
              >
                <option value="">Select Project</option>
                {projects.map(project => (
                  <option key={project.id} value={project.code}>
                    {project.code} - {project.name}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">WBS Element</label>
              <select 
                className="w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
                value={selectedWBS}
                onChange={(e) => setSelectedWBS(e.target.value)}
                disabled={!selectedProject}
              >
                <option value="">All WBS Elements</option>
                {wbsNodes.map(wbs => (
                  <option key={wbs.id} value={wbs.code}>
                    {wbs.code} - {wbs.name}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Period</label>
              <select 
                className="w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
                value={dateRange}
                onChange={(e) => setDateRange(e.target.value)}
              >
                <option value="current">Current Period</option>
                <option value="ytd">Year to Date</option>
                <option value="inception">Project Inception</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">View</label>
              <select 
                className="w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
                value={viewMode}
                onChange={(e) => setViewMode(e.target.value)}
              >
                <option value="summary">Cost Summary</option>
                <option value="detail">Line Items</option>
                <option value="variance">Variance Analysis</option>
              </select>
            </div>
          </div>
        </div>

        {selectedProject ? (
          <>
            {/* Cost Summary Cards */}
            <div className="grid grid-cols-2 lg:grid-cols-5 gap-4 mb-6">
              <div className="bg-white p-4 rounded-lg shadow-sm border">
                <div className="flex items-center">
                  <Icons.Target className="w-8 h-8 text-blue-600 mr-3" />
                  <div>
                    <p className="text-sm text-gray-600">Plan Cost</p>
                    <p className="text-xl font-bold text-blue-900">${totalPlan.toLocaleString()}</p>
                  </div>
                </div>
              </div>
              <div className="bg-white p-4 rounded-lg shadow-sm border">
                <div className="flex items-center">
                  <Icons.DollarSign className="w-8 h-8 text-green-600 mr-3" />
                  <div>
                    <p className="text-sm text-gray-600">Actual Cost</p>
                    <p className="text-xl font-bold text-green-900">${totalActual.toLocaleString()}</p>
                  </div>
                </div>
              </div>
              <div className="bg-white p-4 rounded-lg shadow-sm border">
                <div className="flex items-center">
                  <Icons.Clock className="w-8 h-8 text-orange-600 mr-3" />
                  <div>
                    <p className="text-sm text-gray-600">Commitments</p>
                    <p className="text-xl font-bold text-orange-900">${totalCommitment.toLocaleString()}</p>
                  </div>
                </div>
              </div>
              <div className="bg-white p-4 rounded-lg shadow-sm border">
                <div className="flex items-center">
                  <Icons.TrendingUp className="w-8 h-8 text-purple-600 mr-3" />
                  <div>
                    <p className="text-sm text-gray-600">At Completion</p>
                    <p className="text-xl font-bold text-purple-900">${totalAtCompletion.toLocaleString()}</p>
                  </div>
                </div>
              </div>
              <div className="bg-white p-4 rounded-lg shadow-sm border">
                <div className="flex items-center">
                  <Icons.GitCompare className="w-8 h-8 text-red-600 mr-3" />
                  <div>
                    <p className="text-sm text-gray-600">Variance</p>
                    <p className={`text-xl font-bold ${getVarianceColor(totalVariance)}`}>
                      ${Math.abs(totalVariance).toLocaleString()}
                      <span className="text-sm ml-1">
                        {totalVariance > 0 ? 'Under' : totalVariance < 0 ? 'Over' : 'On'}
                      </span>
                    </p>
                  </div>
                </div>
              </div>
            </div>

            {/* Cost Analysis Table */}
            <div className="bg-white rounded-lg shadow-sm border overflow-hidden">
              {loading ? (
                <div className="p-8 text-center">
                  <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
                  <p className="mt-2 text-gray-500">Loading cost analysis...</p>
                </div>
              ) : costData.length > 0 ? (
                <>
                  {/* Desktop Table */}
                  <div className="hidden lg:block overflow-x-auto">
                    <table className="w-full">
                      <thead className="bg-gray-50">
                        <tr>
                          <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Cost Element</th>
                          <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">WBS Element</th>
                          <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Category</th>
                          <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Plan</th>
                          <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actual</th>
                          <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Commitment</th>
                          <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">At Completion</th>
                          <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Variance</th>
                          <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Transactions</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-gray-200">
                        {costData.map((item, index) => {
                          const atCompletion = item.actual_cost + item.commitment_cost
                          return (
                            <tr key={index} className="hover:bg-gray-50">
                              <td className="px-4 py-3">
                                <div>
                                  <p className="font-mono text-sm font-medium">{item.cost_element}</p>
                                  <p className="text-xs text-gray-500">{item.cost_element_name}</p>
                                </div>
                              </td>
                              <td className="px-4 py-3">
                                <div>
                                  <p className="text-sm font-medium">{item.wbs_element}</p>
                                  <p className="text-xs text-gray-500">{item.wbs_name}</p>
                                </div>
                              </td>
                              <td className="px-4 py-3">
                                <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getCategoryColor(item.cost_category)}`}>
                                  {item.cost_category}
                                </span>
                              </td>
                              <td className="px-4 py-3 text-right text-sm font-medium">${item.plan_cost.toLocaleString()}</td>
                              <td className="px-4 py-3 text-right text-sm font-medium">${item.actual_cost.toLocaleString()}</td>
                              <td className="px-4 py-3 text-right text-sm font-medium">${item.commitment_cost.toLocaleString()}</td>
                              <td className="px-4 py-3 text-right text-sm font-medium">${atCompletion.toLocaleString()}</td>
                              <td className={`px-4 py-3 text-right text-sm font-medium ${getVarianceColor(item.variance)}`}>
                                ${Math.abs(item.variance).toLocaleString()}
                                <span className="text-xs ml-1">
                                  {item.variance > 0 ? '↓' : item.variance < 0 ? '↑' : '='}
                                </span>
                              </td>
                              <td className="px-4 py-3 text-center">
                                <span className="inline-flex items-center px-2 py-1 rounded-full text-xs bg-blue-100 text-blue-800">
                                  {item.transactions}
                                </span>
                              </td>
                            </tr>
                          )
                        })}
                        {/* Totals Row */}
                        <tr className="bg-gray-50 font-medium">
                          <td className="px-4 py-3 text-sm font-bold" colSpan="3">TOTALS</td>
                          <td className="px-4 py-3 text-right text-sm font-bold">${totalPlan.toLocaleString()}</td>
                          <td className="px-4 py-3 text-right text-sm font-bold">${totalActual.toLocaleString()}</td>
                          <td className="px-4 py-3 text-right text-sm font-bold">${totalCommitment.toLocaleString()}</td>
                          <td className="px-4 py-3 text-right text-sm font-bold">${totalAtCompletion.toLocaleString()}</td>
                          <td className={`px-4 py-3 text-right text-sm font-bold ${getVarianceColor(totalVariance)}`}>
                            ${Math.abs(totalVariance).toLocaleString()}
                          </td>
                          <td className="px-4 py-3 text-center text-sm font-bold">
                            {costData.reduce((sum, item) => sum + item.transactions, 0)}
                          </td>
                        </tr>
                      </tbody>
                    </table>
                  </div>

                  {/* Mobile Cards */}
                  <div className="lg:hidden">
                    {costData.map((item, index) => {
                      const atCompletion = item.actual_cost + item.commitment_cost
                      return (
                        <div key={index} className="p-4 border-b border-gray-200 last:border-b-0">
                          <div className="flex justify-between items-start mb-3">
                            <div className="flex-1">
                              <p className="font-mono text-sm font-medium">{item.cost_element}</p>
                              <p className="text-xs text-gray-500 mb-1">{item.cost_element_name}</p>
                              <p className="text-sm font-medium">{item.wbs_element}</p>
                              <p className="text-xs text-gray-500">{item.wbs_name}</p>
                            </div>
                            <div className="flex flex-col items-end">
                              <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getCategoryColor(item.cost_category)} mb-2`}>
                                {item.cost_category}
                              </span>
                              <span className="inline-flex items-center px-2 py-1 rounded-full text-xs bg-blue-100 text-blue-800">
                                {item.transactions} txns
                              </span>
                            </div>
                          </div>
                          <div className="grid grid-cols-2 gap-4 text-sm">
                            <div>
                              <p className="text-gray-500">Plan</p>
                              <p className="font-medium">${item.plan_cost.toLocaleString()}</p>
                            </div>
                            <div>
                              <p className="text-gray-500">Actual</p>
                              <p className="font-medium">${item.actual_cost.toLocaleString()}</p>
                            </div>
                            <div>
                              <p className="text-gray-500">Commitment</p>
                              <p className="font-medium">${item.commitment_cost.toLocaleString()}</p>
                            </div>
                            <div>
                              <p className="text-gray-500">Variance</p>
                              <p className={`font-medium ${getVarianceColor(item.variance)}`}>
                                ${Math.abs(item.variance).toLocaleString()}
                                <span className="text-xs ml-1">
                                  {item.variance > 0 ? 'Under' : item.variance < 0 ? 'Over' : 'On'}
                                </span>
                              </p>
                            </div>
                          </div>
                        </div>
                      )
                    })}
                    
                    {/* Mobile Totals */}
                    <div className="p-4 bg-gray-50 border-t-2 border-gray-300">
                      <div className="grid grid-cols-2 gap-4 text-sm font-bold">
                        <div>
                          <p className="text-gray-700">Total Plan</p>
                          <p>${totalPlan.toLocaleString()}</p>
                        </div>
                        <div>
                          <p className="text-gray-700">Total Actual</p>
                          <p>${totalActual.toLocaleString()}</p>
                        </div>
                        <div>
                          <p className="text-gray-700">At Completion</p>
                          <p>${totalAtCompletion.toLocaleString()}</p>
                        </div>
                        <div>
                          <p className="text-gray-700">Variance</p>
                          <p className={getVarianceColor(totalVariance)}>
                            ${Math.abs(totalVariance).toLocaleString()}
                            <span className="text-xs ml-1">
                              {totalVariance > 0 ? 'Under' : totalVariance < 0 ? 'Over' : 'On'}
                            </span>
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>
                </>
              ) : (
                <div className="p-8 text-center">
                  <Icons.BarChart3 className="w-16 h-16 text-gray-400 mx-auto mb-4" />
                  <p className="text-gray-500">No cost data available for selected criteria</p>
                </div>
              )}
            </div>
          </>
        ) : (
          <div className="bg-white rounded-lg shadow-sm border p-8 text-center">
            <Icons.Target className="w-16 h-16 text-gray-400 mx-auto mb-4" />
            <p className="text-gray-500 text-lg mb-2">Select a project to view cost analysis</p>
            <p className="text-gray-400 text-sm">Choose a project from the dropdown above to see detailed cost breakdown</p>
          </div>
        )}
      </div>
    </div>
  )
}

// Project Budget Component
export function ProjectBudget() {
  const [projects, setProjects] = useState([])
  const [selectedProject, setSelectedProject] = useState('')
  const [budgetData, setBudgetData] = useState([])
  const [loading, setLoading] = useState(false)
  const [editMode, setEditMode] = useState(false)

  useEffect(() => {
    loadProjects()
  }, [])

  const loadProjects = async () => {
    try {
      const response = await fetch('/api/projects')
      const result = await response.json()
      if (result.success) {
        setProjects(result.data || [])
      }
    } catch (error) {
      console.error('Error loading projects:', error)
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm border-b px-4 py-3 sticky top-0 z-10">
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
          <h2 className="text-lg font-semibold text-gray-900 mb-2 sm:mb-0">Project Budget</h2>
          <div className="flex items-center space-x-2">
            <button 
              onClick={() => setEditMode(!editMode)}
              className={`px-3 py-2 rounded-lg text-sm font-medium ${
                editMode 
                  ? 'bg-red-600 text-white hover:bg-red-700' 
                  : 'bg-blue-600 text-white hover:bg-blue-700'
              }`}
            >
              {editMode ? 'Cancel Edit' : 'Edit Budget'}
            </button>
          </div>
        </div>
      </div>

      <div className="p-4">
        <div className="bg-white rounded-lg shadow-sm border p-6 text-center">
          <Icons.DollarSign className="w-16 h-16 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-500 text-lg mb-2">Project Budget Management</p>
          <p className="text-gray-400 text-sm">Budget planning and control functionality coming soon...</p>
        </div>
      </div>
    </div>
  )
}

// Variance Analysis Component
export function VarianceAnalysis() {
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm border-b px-4 py-3 sticky top-0 z-10">
        <h2 className="text-lg font-semibold text-gray-900">Variance Analysis</h2>
      </div>

      <div className="p-4">
        <div className="bg-white rounded-lg shadow-sm border p-6 text-center">
          <Icons.GitCompare className="w-16 h-16 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-500 text-lg mb-2">Plan vs Actual Variance Analysis</p>
          <p className="text-gray-400 text-sm">Detailed variance analysis functionality coming soon...</p>
        </div>
      </div>
    </div>
  )
}