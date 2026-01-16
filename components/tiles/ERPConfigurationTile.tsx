'use client'

import { useState, useEffect, useMemo } from 'react'
import * as Icons from 'lucide-react'
import EnhancedProjectsConfigTab from '../EnhancedProjectsConfigTab'

interface ERPConfigItem {
  id: string
  code: string
  name: string
  description?: string
  is_active?: boolean
}

interface MaterialGroup extends ERPConfigItem {
  group_code: string
  group_name: string
}

interface VendorCategory extends ERPConfigItem {
  category_code: string
  category_name: string
}

interface PaymentTerm extends ERPConfigItem {
  term_code: string
  term_name: string
  days: number
}

export default function ERPConfigurationTile() {
  const [activeTab, setActiveTab] = useState('materials')
  const [materialGroups, setMaterialGroups] = useState<MaterialGroup[]>([])
  const [vendorCategories, setVendorCategories] = useState<VendorCategory[]>([])
  const [paymentTerms, setPaymentTerms] = useState<PaymentTerm[]>([])
  const [accountDetermination, setAccountDetermination] = useState<any[]>([]))
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [showCreateForm, setShowCreateForm] = useState(false)
  const [showEditForm, setShowEditForm] = useState(false)
  const [editingItem, setEditingItem] = useState<any>(null)
  const [formData, setFormData] = useState({
    code: '',
    name: '',
    description: '',
    days: 0
  })

  const [isMobile, setIsMobile] = useState(false)

  useEffect(() => {
    const checkMobile = () => setIsMobile(window.innerWidth < 768)
    checkMobile()
    window.addEventListener('resize', checkMobile)
    return () => window.removeEventListener('resize', checkMobile)
  }, [])

  useEffect(() => {
    fetchData()
  }, [activeTab])

  const fetchData = async () => {
    setLoading(true)
    try {
      const response = await fetch('/api/erp-config?category=erp-config')
      const result = await response.json()

      if (result.success) {
        const data = result.data
        console.log('ERP Config Data:', data) // Debug log
        console.log('Account Determination:', data.account_determination) // Debug log
        setMaterialGroups(data.material_groups || [])
        setVendorCategories(data.vendor_categories || [])
        setPaymentTerms(data.payment_terms || [])
        setAccountDetermination(data.account_determination || [])
      }
    } catch (error) {
      console.error('Error fetching ERP config:', error)
    } finally {
      setLoading(false)
    }
  }

  const getCurrentData = () => {
    switch (activeTab) {
      case 'materials': return materialGroups
      case 'procurement': return vendorCategories
      case 'finance': return paymentTerms
      case 'account-determination': return accountDetermination
      default: return []
    }
  }

  const filteredData = useMemo(() => {
    const data = getCurrentData()
    if (!searchTerm) return data
    
    // Skip filtering for account determination since it has different structure
    if (activeTab === 'account-determination') return data
    
    return data.filter(item => {
      const code = item.group_code || item.category_code || item.term_code || ''
      const name = item.group_name || item.category_name || item.term_name || ''
      return code.toLowerCase().includes(searchTerm.toLowerCase()) ||
             name.toLowerCase().includes(searchTerm.toLowerCase())
    })
  }, [activeTab, searchTerm, materialGroups, vendorCategories, paymentTerms, accountDetermination])

  const handleCreate = async () => {
    try {
      const response = await fetch(`/api/erp-config?entity=${getEntityName()}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      })
      
      const result = await response.json()
      if (result.success) {
        setShowCreateForm(false)
        resetForm()
        fetchData()
      } else {
        alert(result.error || 'Failed to create item')
      }
    } catch (error) {
      console.error('Error creating item:', error)
      alert('Failed to create item')
    }
  }

  const handleEdit = (item: any) => {
    setEditingItem(item)
    setFormData({
      code: item.group_code || item.category_code || item.term_code || '',
      name: item.group_name || item.category_name || item.term_name || '',
      description: item.description || '',
      days: item.days || 0
    })
    setShowEditForm(true)
  }

  const handleUpdate = async () => {
    if (!editingItem) return
    
    try {
      const response = await fetch(`/api/erp-config?entity=${getEntityName()}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ...formData, id: editingItem.id })
      })
      
      const result = await response.json()
      if (result.success) {
        setShowEditForm(false)
        setEditingItem(null)
        resetForm()
        fetchData()
      } else {
        alert(result.error || 'Failed to update item')
      }
    } catch (error) {
      console.error('Error updating item:', error)
      alert('Failed to update item')
    }
  }

  const handleDelete = async (item: any) => {
    const code = item.group_code || item.category_code || item.term_code
    if (!confirm(`Are you sure you want to delete ${code}?`)) return
    
    try {
      const response = await fetch(`/api/erp-config?id=${item.id}&entity=${getEntityName()}`, {
        method: 'DELETE'
      })
      
      const result = await response.json()
      if (result.success) {
        fetchData()
      } else {
        alert(result.error || 'Failed to delete item')
      }
    } catch (error) {
      console.error('Error deleting item:', error)
      alert('Failed to delete item')
    }
  }

  const getEntityName = () => {
    switch (activeTab) {
      case 'materials': return 'groups'
      case 'procurement': return 'categories'
      case 'finance': return 'terms'
      default: return 'groups'
    }
  }

  const resetForm = () => {
    setFormData({
      code: '',
      name: '',
      description: '',
      days: 0
    })
  }

  const tabs = [
    { id: 'materials', label: 'Material Groups', icon: Icons.Package, color: 'bg-blue-100' },
    { id: 'procurement', label: 'Vendor Categories', icon: Icons.ShoppingCart, color: 'bg-green-100' },
    { id: 'finance', label: 'Payment Terms', icon: Icons.DollarSign, color: 'bg-orange-100' },
    { id: 'projects', label: 'Projects', icon: Icons.Building, color: 'bg-purple-100' },
    { id: 'account-determination', label: 'Account Determination', icon: Icons.Settings, color: 'bg-gray-100' }
  ]

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading ERP Configuration...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="fixed inset-0 bg-gray-50 z-50 flex flex-col overflow-hidden">
      {/* Header */}
      <div className="bg-white shadow-sm border-b px-4 sm:px-6 lg:px-8 py-4 flex-shrink-0">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <button
              onClick={() => window.history.back()}
              className="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <Icons.ArrowLeft className="w-5 h-5" />
            </button>
            <div>
              <h1 className="text-xl sm:text-2xl font-bold text-gray-900">ERP Configuration</h1>
              <p className="text-sm text-gray-500 mt-1">System configuration and master data management</p>
            </div>
          </div>
          <div className="flex items-center space-x-2">
            <button
              onClick={() => setShowCreateForm(true)}
              className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-sm"
            >
              <Icons.Plus className="w-4 h-4 mr-2" />
              <span className="hidden sm:inline">Create Item</span>
              <span className="sm:hidden">Add</span>
            </button>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="bg-white border-b px-4 sm:px-6 lg:px-8 py-3 flex-shrink-0">
        <div className="flex overflow-x-auto space-x-1 pb-2 sm:pb-0">
          {tabs.map((tab) => {
            const IconComponent = tab.icon
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex items-center px-3 py-2 rounded-lg text-sm font-medium transition-colors whitespace-nowrap ${
                  activeTab === tab.id
                    ? 'bg-blue-600 text-white'
                    : `${tab.color} text-gray-700 hover:bg-opacity-80`
                }`}
              >
                <IconComponent className="w-4 h-4 mr-2" />
                <span className="hidden sm:inline">{tab.label}</span>
                <span className="sm:hidden">{tab.label.split(' ')[0]}</span>
              </button>
            )
          })}
        </div>

        {/* Search */}
        <div className="mt-3 relative max-w-md">
          <Icons.Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
          <input
            type="text"
            placeholder="Search items..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          />
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-auto">
        <div className="p-4 sm:p-6 lg:p-8">
          <div className="bg-white rounded-lg shadow-sm border">
            {activeTab === 'projects' ? (
              <ProjectsConfigurationTab />
            ) : activeTab === 'account-determination' ? (
              <AccountDeterminationTable data={accountDetermination} />
            ) : (
              <div className="divide-y divide-gray-200">
                {filteredData.map((item) => (
                  <ConfigCard 
                    key={item.id} 
                    item={item} 
                    type={activeTab}
                    isMobile={isMobile}
                    onEdit={handleEdit}
                    onDelete={handleDelete}
                  />
                ))}
              </div>
            )}
          </div>

          {filteredData.length === 0 && !loading && activeTab !== 'account-determination' && (
            <div className="text-center py-12">
              <Icons.Search className="w-12 h-12 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">No items found</h3>
              <p className="text-gray-600">Try adjusting your search</p>
            </div>
          )}
        </div>
      </div>
    </div>
      {/* Create/Edit Form Modal */}
      {(showCreateForm || showEditForm) && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl w-full max-w-md max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-semibold text-gray-900">
                  {showCreateForm ? 'Create Item' : 'Edit Item'}
                </h3>
                <button
                  onClick={() => {
                    setShowCreateForm(false)
                    setShowEditForm(false)
                    setEditingItem(null)
                    resetForm()
                  }}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <Icons.X className="w-5 h-5" />
                </button>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Code *
                  </label>
                  <input
                    type="text"
                    value={formData.code}
                    onChange={(e) => setFormData({ ...formData, code: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="Enter code"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Name *
                  </label>
                  <input
                    type="text"
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="Enter name"
                  />
                </div>

                {activeTab === 'finance' && (
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Days
                    </label>
                    <input
                      type="number"
                      value={formData.days}
                      onChange={(e) => setFormData({ ...formData, days: parseInt(e.target.value) || 0 })}
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      placeholder="Payment days"
                    />
                  </div>
                )}

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Description
                  </label>
                  <textarea
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    rows={3}
                    placeholder="Enter description"
                  />
                </div>
              </div>

              <div className="flex flex-col sm:flex-row justify-end space-y-2 sm:space-y-0 sm:space-x-3 mt-6 pt-4 border-t">
                <button
                  onClick={() => {
                    setShowCreateForm(false)
                    setShowEditForm(false)
                    setEditingItem(null)
                    resetForm()
                  }}
                  className="w-full sm:w-auto px-4 py-2 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={showCreateForm ? handleCreate : handleUpdate}
                  className="w-full sm:w-auto px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                >
                  {showCreateForm ? 'Create' : 'Update'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
  )
}

// Account Determination Table Component
function AccountDeterminationTable({ data }: { data: any[] }) {
  if (!data || data.length === 0) {
    return (
      <div className="text-center py-12">
        <Icons.Database className="w-12 h-12 text-gray-400 mx-auto mb-4" />
        <h3 className="text-lg font-medium text-gray-900 mb-2">No account determination entries found</h3>
        <p className="text-gray-600">Please add some mappings.</p>
      </div>
    )
  }

  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Company Code
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Valuation Class
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Account Key
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              GL Account
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Status
            </th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {data.map((item) => (
            <tr key={item.id} className="hover:bg-gray-50">
              <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                {item.company_code}
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {item.valuation_class_id}
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {item.account_key_id}
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {item.gl_account_id}
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                  item.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                }`}>
                  {item.is_active ? 'Active' : 'Inactive'}
                </span>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}

// Projects Configuration Tab Component
function ProjectsConfigurationTab() {
  return (
    <div className="p-0">
      <EnhancedProjectsConfigTab />
    </div>
  )
}

// Project Categories Configuration
function ProjectCategoriesConfig({ categories, onUpdate }: { categories: any[], onUpdate: () => void }) {
  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h3 className="text-lg font-medium">Project Categories</h3>
          <p className="text-sm text-gray-600">Configure project types and posting logic</p>
        </div>
        <button className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">
          <Icons.Plus className="w-4 h-4 mr-2" />
          Add Category
        </button>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full border border-gray-200 rounded-lg">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Code</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Posting Logic</th>
              <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Real-time</th>
              <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {categories.map((category) => (
              <tr key={category.id} className="hover:bg-gray-50">
                <td className="px-4 py-3 text-sm font-mono">{category.category_code}</td>
                <td className="px-4 py-3 text-sm">{category.category_name}</td>
                <td className="px-4 py-3 text-sm">{category.posting_logic}</td>
                <td className="px-4 py-3 text-center">
                  <span className={`px-2 py-1 text-xs rounded-full ${
                    category.real_time_posting ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
                  }`}>
                    {category.real_time_posting ? 'Yes' : 'No'}
                  </span>
                </td>
                <td className="px-4 py-3 text-center">
                  <div className="flex justify-center space-x-2">
                    <button className="p-1 text-blue-600 hover:text-blue-800">
                      <Icons.Edit className="w-4 h-4" />
                    </button>
                    <button className="p-1 text-red-600 hover:text-red-800">
                      <Icons.Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}

// GL Rules Configuration
function GLRulesConfig({ rules, onUpdate }: { rules: any[], onUpdate: () => void }) {
  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h3 className="text-lg font-medium">GL Determination Rules</h3>
          <p className="text-sm text-gray-600">Configure automatic GL account determination</p>
        </div>
        <button className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">
          <Icons.Plus className="w-4 h-4 mr-2" />
          Add Rule
        </button>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full border border-gray-200 rounded-lg">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Category</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Event Type</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">GL Account Type</th>
              <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Dr/Cr</th>
              <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Posting Key</th>
              <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {rules.map((rule) => (
              <tr key={rule.id} className="hover:bg-gray-50">
                <td className="px-4 py-3 text-sm">{rule.project_category}</td>
                <td className="px-4 py-3 text-sm">{rule.event_type}</td>
                <td className="px-4 py-3 text-sm">{rule.gl_account_type}</td>
                <td className="px-4 py-3 text-center">
                  <span className={`px-2 py-1 text-xs rounded-full ${
                    rule.debit_credit === 'D' ? 'bg-red-100 text-red-800' : 'bg-green-100 text-green-800'
                  }`}>
                    {rule.debit_credit}
                  </span>
                </td>
                <td className="px-4 py-3 text-center text-sm font-mono">{rule.posting_key}</td>
                <td className="px-4 py-3 text-center">
                  <div className="flex justify-center space-x-2">
                    <button className="p-1 text-blue-600 hover:text-blue-800">
                      <Icons.Edit className="w-4 h-4" />
                    </button>
                    <button className="p-1 text-red-600 hover:text-red-800">
                      <Icons.Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}

// Project Numbering Configuration
function ProjectNumberingConfig() {
  const [numberingRules] = useState([
    { id: 1, type: 'Project', pattern: 'P{YYYY}{####}', current: 100, description: 'Annual project numbering' },
    { id: 2, type: 'WBS Element', pattern: '{PROJECT}.{##}.{##}', current: 1, description: 'Hierarchical WBS structure' },
    { id: 3, type: 'Activity', pattern: '{WBS}.{###}', current: 1, description: 'Activity numbering within WBS' },
    { id: 4, type: 'Task', pattern: '{ACTIVITY}.{##}', current: 1, description: 'Task numbering within activities' }
  ])

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h3 className="text-lg font-medium">Project Numbering</h3>
          <p className="text-sm text-gray-600">Configure automatic numbering for projects, WBS, activities, and tasks</p>
        </div>
        <button className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">
          <Icons.Plus className="w-4 h-4 mr-2" />
          Add Rule
        </button>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full border border-gray-200 rounded-lg">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Pattern</th>
              <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Current #</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Description</th>
              <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {numberingRules.map((rule) => (
              <tr key={rule.id} className="hover:bg-gray-50">
                <td className="px-4 py-3 text-sm font-medium">{rule.type}</td>
                <td className="px-4 py-3 text-sm font-mono bg-gray-50">{rule.pattern}</td>
                <td className="px-4 py-3 text-center text-sm">{rule.current}</td>
                <td className="px-4 py-3 text-sm text-gray-600">{rule.description}</td>
                <td className="px-4 py-3 text-center">
                  <div className="flex justify-center space-x-2">
                    <button className="p-1 text-blue-600 hover:text-blue-800">
                      <Icons.Edit className="w-4 h-4" />
                    </button>
                    <button className="p-1 text-red-600 hover:text-red-800">
                      <Icons.Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div className="bg-blue-50 p-4 rounded-lg">
        <h4 className="font-medium text-blue-900 mb-2">Pattern Variables</h4>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
          <div><code className="bg-white px-2 py-1 rounded">{'{YYYY}'}</code> - Current year</div>
          <div><code className="bg-white px-2 py-1 rounded">{'{####}'}</code> - Sequential number</div>
          <div><code className="bg-white px-2 py-1 rounded">{'{PROJECT}'}</code> - Project code</div>
          <div><code className="bg-white px-2 py-1 rounded">{'{WBS}'}</code> - WBS element code</div>
        </div>
      </div>
    </div>
  )
}

// Project Workflows Configuration
function ProjectWorkflowsConfig() {
  const [workflows] = useState([
    { id: 1, name: 'Project Creation', steps: 3, status: 'Active', description: 'New project approval workflow' },
    { id: 2, name: 'Budget Change', steps: 4, status: 'Active', description: 'Budget modification approval' },
    { id: 3, name: 'Project Closure', steps: 2, status: 'Active', description: 'Project completion workflow' },
    { id: 4, name: 'WBS Modification', steps: 2, status: 'Draft', description: 'WBS structure changes' }
  ])

  const [workflowTypes] = useState([
    { id: 'creation', name: 'Project Creation', icon: Icons.Plus },
    { id: 'budget', name: 'Budget Changes', icon: Icons.DollarSign },
    { id: 'wbs', name: 'WBS Changes', icon: Icons.GitBranch },
    { id: 'closure', name: 'Project Closure', icon: Icons.CheckCircle2 }
  ])

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h3 className="text-lg font-medium">Project Workflows</h3>
          <p className="text-sm text-gray-600">Configure approval workflows and authorization matrix</p>
        </div>
        <button className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">
          <Icons.Plus className="w-4 h-4 mr-2" />
          Create Workflow
        </button>
      </div>

      {/* Workflow Types */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        {workflowTypes.map((type) => {
          const Icon = type.icon
          return (
            <div key={type.id} className="bg-gray-50 p-4 rounded-lg text-center hover:bg-gray-100 cursor-pointer">
              <Icon className="w-8 h-8 text-blue-600 mx-auto mb-2" />
              <h4 className="font-medium text-sm">{type.name}</h4>
            </div>
          )
        })}
      </div>

      {/* Existing Workflows */}
      <div className="overflow-x-auto">
        <table className="w-full border border-gray-200 rounded-lg">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Workflow Name</th>
              <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Steps</th>
              <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Status</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Description</th>
              <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {workflows.map((workflow) => (
              <tr key={workflow.id} className="hover:bg-gray-50">
                <td className="px-4 py-3 text-sm font-medium">{workflow.name}</td>
                <td className="px-4 py-3 text-center">
                  <span className="bg-blue-100 text-blue-800 px-2 py-1 text-xs rounded-full">
                    {workflow.steps} steps
                  </span>
                </td>
                <td className="px-4 py-3 text-center">
                  <span className={`px-2 py-1 text-xs rounded-full ${
                    workflow.status === 'Active' ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
                  }`}>
                    {workflow.status}
                  </span>
                </td>
                <td className="px-4 py-3 text-sm text-gray-600">{workflow.description}</td>
                <td className="px-4 py-3 text-center">
                  <div className="flex justify-center space-x-2">
                    <button className="p-1 text-blue-600 hover:text-blue-800" title="Configure">
                      <Icons.Settings className="w-4 h-4" />
                    </button>
                    <button className="p-1 text-green-600 hover:text-green-800" title="Test">
                      <Icons.Play className="w-4 h-4" />
                    </button>
                    <button className="p-1 text-red-600 hover:text-red-800" title="Delete">
                      <Icons.Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
function ConfigCard({ item, type, isMobile, onEdit, onDelete }: { 
  item: any; 
  type: string;
  isMobile: boolean;
  onEdit: (item: any) => void;
  onDelete: (item: any) => void;
}) {
  const code = item.group_code || item.category_code || item.term_code || ''
  const name = item.group_name || item.category_name || item.term_name || ''
  
  return (
    <div className="p-4 hover:bg-gray-50 transition-colors">
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <div className="flex items-center space-x-3">
            <div className="font-mono text-sm font-semibold text-blue-600 bg-blue-50 px-2 py-1 rounded">
              {code}
            </div>
            <div className="font-medium text-gray-900">{name}</div>
            {type === 'finance' && item.days && (
              <span className="bg-green-100 text-green-800 text-xs px-2 py-1 rounded-full font-medium">
                {item.days} days
              </span>
            )}
          </div>
          
          {item.description && (
            <div className="mt-2 text-sm text-gray-600">
              {item.description}
            </div>
          )}
        </div>

        <div className="flex items-center space-x-2 ml-4">
          <button 
            onClick={() => onEdit(item)}
            className="p-2 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded transition-colors"
            title="Edit Item"
          >
            <Icons.Edit className="w-4 h-4" />
          </button>
          <button 
            onClick={() => onDelete(item)}
            className="p-2 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded transition-colors"
            title="Delete Item"
          >
            <Icons.Trash2 className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  )
}