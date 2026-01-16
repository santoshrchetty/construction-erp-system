'use client'

import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'

interface CostCenter {
  id: string
  cost_center_code: string
  cost_center_name: string
  description: string
  cost_center_type: 'PROJECT' | 'DEPARTMENT' | 'ACTIVITY' | 'OVERHEAD'
  parent_cost_center_id?: string
  responsible_person: string
  company_code: string
  profit_center_code?: string
  budget_amount: number
  actual_costs: number
  committed_costs: number
  available_budget: number
  is_active: boolean
  hierarchy_level: number
  created_at: string
}

interface CostCenterHierarchy {
  [key: string]: CostCenter[]
}

interface BudgetAllocation {
  cost_type: string
  budgeted: number
  actual: number
  committed: number
  variance: number
  variance_percent: number
}

export default function CostCenterAccounting() {
  const [costCenters, setCostCenters] = useState<CostCenter[]>([])
  const [hierarchyData, setHierarchyData] = useState<CostCenterHierarchy>({})
  const [budgetAllocations, setBudgetAllocations] = useState<BudgetAllocation[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedCostCenter, setSelectedCostCenter] = useState<CostCenter | null>(null)
  const [viewMode, setViewMode] = useState<'hierarchy' | 'list' | 'budget'>('hierarchy')
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedType, setSelectedType] = useState<string>('ALL')
  const [showCreateForm, setShowCreateForm] = useState(false)
  const [showBudgetForm, setShowBudgetForm] = useState(false)
  const [formData, setFormData] = useState({
    cost_center_code: '',
    cost_center_name: '',
    description: '',
    cost_center_type: 'PROJECT' as CostCenter['cost_center_type'],
    parent_cost_center_id: '',
    responsible_person: '',
    profit_center_code: '',
    budget_amount: 0
  })

  useEffect(() => {
    fetchCostCenters()
  }, [searchTerm, selectedType])

  const fetchCostCenters = async () => {
    setLoading(true)
    try {
      const params = new URLSearchParams({
        category: 'controlling',
        action: 'cost_centers',
        company_code: 'C001',
        ...(searchTerm && { search: searchTerm }),
        ...(selectedType !== 'ALL' && { type: selectedType })
      })

      const response = await fetch(`/api/tiles?${params}`)
      const result = await response.json()

      if (result.success) {
        setCostCenters(result.data?.cost_centers || [])
        setHierarchyData(result.data?.hierarchy || {})
        setBudgetAllocations(result.data?.budget_allocations || [])
      }
    } catch (error) {
      console.error('Error fetching cost centers:', error)
    } finally {
      setLoading(false)
    }
  }

  const fetchCostCenterDetails = async (costCenterId: string) => {
    try {
      const params = new URLSearchParams({
        category: 'controlling',
        action: 'cost_center_details',
        cost_center_id: costCenterId
      })

      const response = await fetch(`/api/tiles?${params}`)
      const result = await response.json()

      if (result.success) {
        setSelectedCostCenter(result.data.cost_center)
        setBudgetAllocations(result.data.budget_allocations || [])
      }
    } catch (error) {
      console.error('Error fetching cost center details:', error)
    }
  }

  const handleCreateCostCenter = async () => {
    try {
      const params = new URLSearchParams({
        category: 'controlling',
        action: 'cost_centers'
      })
      
      const response = await fetch(`/api/tiles?${params}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      })
      
      const result = await response.json()
      if (result.success) {
        setShowCreateForm(false)
        resetForm()
        fetchCostCenters()
      } else {
        alert(result.error || 'Failed to create cost center')
      }
    } catch (error) {
      console.error('Error creating cost center:', error)
      alert('Failed to create cost center')
    }
  }

  const handleBudgetUpdate = async (costCenterId: string, budgetData: any) => {
    try {
      const params = new URLSearchParams({
        category: 'controlling',
        action: 'update_budget',
        cost_center_id: costCenterId
      })
      
      const response = await fetch(`/api/tiles?${params}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(budgetData)
      })
      
      const result = await response.json()
      if (result.success) {
        fetchCostCenters()
        if (selectedCostCenter) {
          fetchCostCenterDetails(selectedCostCenter.id)
        }
      } else {
        alert(result.error || 'Failed to update budget')
      }
    } catch (error) {
      console.error('Error updating budget:', error)
      alert('Failed to update budget')
    }
  }

  const resetForm = () => {
    setFormData({
      cost_center_code: '',
      cost_center_name: '',
      description: '',
      cost_center_type: 'PROJECT',
      parent_cost_center_id: '',
      responsible_person: '',
      profit_center_code: '',
      budget_amount: 0
    })
  }

  const costCenterTypes = [
    { value: 'ALL', label: 'All Types', icon: Icons.List, color: 'bg-gray-100' },
    { value: 'PROJECT', label: 'Project', icon: Icons.Building, color: 'bg-blue-100' },
    { value: 'DEPARTMENT', label: 'Department', icon: Icons.Users, color: 'bg-green-100' },
    { value: 'ACTIVITY', label: 'Activity', icon: Icons.Activity, color: 'bg-purple-100' },
    { value: 'OVERHEAD', label: 'Overhead', icon: Icons.Settings, color: 'bg-orange-100' }
  ]

  const getVarianceColor = (variance: number) => {
    if (variance > 10) return 'text-red-600 bg-red-50'
    if (variance > 5) return 'text-yellow-600 bg-yellow-50'
    return 'text-green-600 bg-green-50'
  }

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(amount)
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading Cost Centers...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b px-4 py-4">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-600">Company: C001 - Construction Corp Ltd</p>
          </div>
          <div className="flex items-center space-x-2">
            <button
              onClick={() => setShowCreateForm(true)}
              className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center text-sm"
            >
              <Icons.Plus className="w-4 h-4 mr-2" />
              Create Cost Center
            </button>
          </div>
        </div>
      </div>

      {/* Controls */}
      <div className="bg-white border-b px-4 py-3">
        <div className="flex flex-col space-y-3 md:flex-row md:space-y-0 md:space-x-4 md:items-center">
          {/* Search */}
          <div className="flex-1 relative">
            <Icons.Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input
              type="text"
              placeholder="Search cost centers..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>

          {/* View Mode Toggle */}
          <div className="flex bg-gray-100 rounded-lg p-1">
            {[
              { key: 'hierarchy', label: 'Hierarchy', icon: Icons.GitBranch },
              { key: 'list', label: 'List', icon: Icons.List },
              { key: 'budget', label: 'Budget', icon: Icons.DollarSign }
            ].map((mode) => (
              <button
                key={mode.key}
                onClick={() => setViewMode(mode.key as any)}
                className={`px-3 py-1 rounded text-sm font-medium transition-colors flex items-center ${
                  viewMode === mode.key 
                    ? 'bg-white text-gray-900 shadow-sm' 
                    : 'text-gray-600 hover:text-gray-900'
                }`}
              >
                <mode.icon className="w-4 h-4 mr-1" />
                {mode.label}
              </button>
            ))}
          </div>
        </div>

        {/* Type Filters */}
        <div className="mt-3 flex flex-wrap gap-2">
          {costCenterTypes.map((type) => {
            const IconComponent = type.icon
            return (
              <button
                key={type.value}
                onClick={() => setSelectedType(type.value)}
                className={`flex items-center px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                  selectedType === type.value
                    ? 'bg-blue-600 text-white'
                    : `${type.color} text-gray-700 hover:bg-opacity-80`
                }`}
              >
                <IconComponent className="w-4 h-4 mr-2" />
                {type.label}
              </button>
            )
          })}
        </div>
      </div>

      {/* Content */}
      <div className="p-4">
        {viewMode === 'hierarchy' && (
          <div className="space-y-4">
            {Object.entries(hierarchyData || {}).map(([level, centers]) => (
              <div key={level} className="bg-white rounded-lg shadow-sm border">
                <div className="bg-gray-50 px-4 py-3 border-b">
                  <h3 className="font-semibold text-gray-900">Level {level}</h3>
                </div>
                <div className="divide-y divide-gray-200">
                  {centers.map((center) => (
                    <CostCenterCard 
                      key={center.id} 
                      costCenter={center}
                      onClick={() => fetchCostCenterDetails(center.id)}
                      formatCurrency={formatCurrency}
                    />
                  ))}
                </div>
              </div>
            ))}
          </div>
        )}

        {viewMode === 'list' && (
          <div className="bg-white rounded-lg shadow-sm border">
            <div className="divide-y divide-gray-200">
              {costCenters.map((center) => (
                <CostCenterCard 
                  key={center.id} 
                  costCenter={center}
                  onClick={() => fetchCostCenterDetails(center.id)}
                  formatCurrency={formatCurrency}
                />
              ))}
            </div>
          </div>
        )}

        {viewMode === 'budget' && (
          <div className="space-y-6">
            {/* Budget Summary */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              {[
                { label: 'Total Budget', value: costCenters.reduce((sum, cc) => sum + cc.budget_amount, 0), color: 'blue' },
                { label: 'Actual Costs', value: costCenters.reduce((sum, cc) => sum + cc.actual_costs, 0), color: 'red' },
                { label: 'Committed', value: costCenters.reduce((sum, cc) => sum + cc.committed_costs, 0), color: 'yellow' },
                { label: 'Available', value: costCenters.reduce((sum, cc) => sum + cc.available_budget, 0), color: 'green' }
              ].map((item) => (
                <div key={item.label} className="bg-white rounded-lg shadow-sm border p-4">
                  <div className="flex items-center">
                    <div className={`p-2 bg-${item.color}-100 rounded-lg`}>
                      <Icons.DollarSign className={`w-5 h-5 text-${item.color}-600`} />
                    </div>
                    <div className="ml-3">
                      <p className="text-sm font-medium text-gray-600">{item.label}</p>
                      <p className="text-2xl font-bold text-gray-900">{formatCurrency(item.value)}</p>
                    </div>
                  </div>
                </div>
              ))}
            </div>

            {/* Budget Allocations */}
            {budgetAllocations.length > 0 && (
              <div className="bg-white rounded-lg shadow-sm border">
                <div className="px-4 py-3 border-b">
                  <h3 className="text-lg font-medium text-gray-900">Budget vs Actual Analysis</h3>
                </div>
                <div className="overflow-x-auto">
                  <table className="min-w-full divide-y divide-gray-200">
                    <thead className="bg-gray-50">
                      <tr>
                        <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Cost Type</th>
                        <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Budgeted</th>
                        <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Actual</th>
                        <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Committed</th>
                        <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Variance</th>
                        <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Variance %</th>
                      </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                      {budgetAllocations.map((allocation, index) => (
                        <tr key={index} className="hover:bg-gray-50">
                          <td className="px-4 py-4 text-sm font-medium text-gray-900">{allocation.cost_type}</td>
                          <td className="px-4 py-4 text-sm text-gray-900 text-right">{formatCurrency(allocation.budgeted)}</td>
                          <td className="px-4 py-4 text-sm text-gray-900 text-right">{formatCurrency(allocation.actual)}</td>
                          <td className="px-4 py-4 text-sm text-gray-900 text-right">{formatCurrency(allocation.committed)}</td>
                          <td className="px-4 py-4 text-sm text-right">
                            <span className={`px-2 py-1 rounded-full text-xs font-medium ${getVarianceColor(Math.abs(allocation.variance_percent))}`}>
                              {formatCurrency(allocation.variance)}
                            </span>
                          </td>
                          <td className="px-4 py-4 text-sm text-right">
                            <span className={`px-2 py-1 rounded-full text-xs font-medium ${getVarianceColor(Math.abs(allocation.variance_percent))}`}>
                              {allocation.variance_percent.toFixed(1)}%
                            </span>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Create Form Modal */}
      {showCreateForm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-md w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-semibold text-gray-900">Create Cost Center</h3>
                <button
                  onClick={() => {
                    setShowCreateForm(false)
                    resetForm()
                  }}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <Icons.X className="w-5 h-5" />
                </button>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Cost Center Code *</label>
                  <input
                    type="text"
                    value={formData.cost_center_code}
                    onChange={(e) => setFormData({ ...formData, cost_center_code: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="e.g., CC-001"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Cost Center Name *</label>
                  <input
                    type="text"
                    value={formData.cost_center_name}
                    onChange={(e) => setFormData({ ...formData, cost_center_name: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="e.g., Project Alpha"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Type *</label>
                  <select
                    value={formData.cost_center_type}
                    onChange={(e) => setFormData({ ...formData, cost_center_type: e.target.value as CostCenter['cost_center_type'] })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  >
                    <option value="PROJECT">Project</option>
                    <option value="DEPARTMENT">Department</option>
                    <option value="ACTIVITY">Activity</option>
                    <option value="OVERHEAD">Overhead</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Responsible Person *</label>
                  <input
                    type="text"
                    value={formData.responsible_person}
                    onChange={(e) => setFormData({ ...formData, responsible_person: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="e.g., John Smith"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Budget Amount</label>
                  <input
                    type="number"
                    value={formData.budget_amount}
                    onChange={(e) => setFormData({ ...formData, budget_amount: parseFloat(e.target.value) || 0 })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="0"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                  <textarea
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    rows={3}
                    placeholder="Cost center description..."
                  />
                </div>
              </div>

              <div className="flex justify-end space-x-3 mt-6 pt-4 border-t">
                <button
                  onClick={() => {
                    setShowCreateForm(false)
                    resetForm()
                  }}
                  className="px-4 py-2 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={handleCreateCostCenter}
                  className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                >
                  Create
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

// Cost Center Card Component
function CostCenterCard({ 
  costCenter, 
  onClick, 
  formatCurrency 
}: { 
  costCenter: CostCenter
  onClick: () => void
  formatCurrency: (amount: number) => string
}) {
  const utilizationPercent = costCenter.budget_amount > 0 
    ? ((costCenter.actual_costs + costCenter.committed_costs) / costCenter.budget_amount) * 100 
    : 0

  const getUtilizationColor = (percent: number) => {
    if (percent > 90) return 'bg-red-500'
    if (percent > 75) return 'bg-yellow-500'
    return 'bg-green-500'
  }

  return (
    <div 
      className="p-4 hover:bg-gray-50 transition-colors cursor-pointer"
      onClick={onClick}
    >
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <div className="flex items-center space-x-3">
            <div className="font-mono text-sm font-semibold text-blue-600 bg-blue-50 px-2 py-1 rounded">
              {costCenter.cost_center_code}
            </div>
            <div className="font-medium text-gray-900">{costCenter.cost_center_name}</div>
            <span className={`text-xs px-2 py-1 rounded-full font-medium ${
              costCenter.cost_center_type === 'PROJECT' ? 'bg-blue-100 text-blue-800' :
              costCenter.cost_center_type === 'DEPARTMENT' ? 'bg-green-100 text-green-800' :
              costCenter.cost_center_type === 'ACTIVITY' ? 'bg-purple-100 text-purple-800' :
              'bg-orange-100 text-orange-800'
            }`}>
              {costCenter.cost_center_type}
            </span>
          </div>
          
          <div className="mt-2 text-sm text-gray-600">
            <div>Responsible: {costCenter.responsible_person}</div>
            {costCenter.description && (
              <div className="mt-1 text-xs text-gray-500">{costCenter.description}</div>
            )}
          </div>

          {/* Budget Progress */}
          <div className="mt-3">
            <div className="flex justify-between text-xs text-gray-600 mb-1">
              <span>Budget Utilization</span>
              <span>{utilizationPercent.toFixed(1)}%</span>
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div 
                className={`h-2 rounded-full ${getUtilizationColor(utilizationPercent)}`}
                style={{ width: `${Math.min(utilizationPercent, 100)}%` }}
              ></div>
            </div>
          </div>
        </div>

        <div className="ml-4 text-right">
          <div className="text-sm font-medium text-gray-900">
            Budget: {formatCurrency(costCenter.budget_amount)}
          </div>
          <div className="text-xs text-gray-600 mt-1">
            Actual: {formatCurrency(costCenter.actual_costs)}
          </div>
          <div className="text-xs text-gray-600">
            Available: {formatCurrency(costCenter.available_budget)}
          </div>
        </div>
      </div>
    </div>
  )
}