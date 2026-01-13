import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'

export function UnifiedMaterialRequest() {
  const [activeTab, setActiveTab] = useState('create')
  const [requestType, setRequestType] = useState('MATERIAL_REQ')
  const [requests, setRequests] = useState([])
  const [templates, setTemplates] = useState([])
  const [smartDefaults, setSmartDefaults] = useState(null)
  const [loading, setLoading] = useState(false)
  const [saving, setSaving] = useState(false)

  const [formData, setFormData] = useState({
    request_type: 'MATERIAL_REQ',
    priority: 'MEDIUM',
    required_date: '',
    company_code: '',
    plant_code: '',
    cost_center: '',
    project_code: '',
    purpose: '',
    justification: '',
    notes: '',
    items: [{ line_number: 1, material_code: '', requested_quantity: 0, base_uom: 'PCS' }]
  })

  const requestTypes = [
    { code: 'MATERIAL_REQ', name: 'Material Request', icon: 'FileText', color: 'blue' },
    { code: 'RESERVATION', name: 'Material Reservation', icon: 'Bookmark', color: 'green' },
    { code: 'PURCHASE_REQ', name: 'Purchase Requisition', icon: 'ShoppingCart', color: 'purple' }
  ]

  const priorities = [
    { code: 'LOW', name: 'Low', color: 'gray' },
    { code: 'MEDIUM', name: 'Medium', color: 'yellow' },
    { code: 'HIGH', name: 'High', color: 'orange' },
    { code: 'URGENT', name: 'Urgent', color: 'red' }
  ]

  useEffect(() => {
    loadSmartDefaults()
    loadTemplates()
    if (activeTab === 'list') loadRequests()
  }, [activeTab, requestType])

  const loadSmartDefaults = async () => {
    try {
      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          category: 'materials',
          action: 'get-smart-defaults'
        })
      })
      const data = await response.json()
      if (data.success) {
        setSmartDefaults(data.data)
        // Apply defaults to form
        if (data.data.organizational) {
          setFormData(prev => ({
            ...prev,
            company_code: data.data.organizational.default_company_code || '',
            plant_code: data.data.organizational.default_plant_code || '',
            cost_center: data.data.organizational.default_cost_center || ''
          }))
        }
      }
    } catch (error) {
      console.error('Failed to load smart defaults:', error)
    }
  }

  const loadTemplates = async () => {
    try {
      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          category: 'materials',
          action: 'get-templates',
          payload: { template_type: requestType }
        })
      })
      const data = await response.json()
      if (data.success) setTemplates(data.data || [])
    } catch (error) {
      console.error('Failed to load templates:', error)
    }
  }

  const loadRequests = async () => {
    setLoading(true)
    try {
      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          category: 'materials',
          action: 'material-request-list',
          payload: { request_type: requestType }
        })
      })
      const data = await response.json()
      if (data.success) setRequests(data.data || [])
    } catch (error) {
      console.error('Failed to load requests:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setSaving(true)
    try {
      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          category: 'materials',
          action: 'unified-material-request',
          payload: { ...formData, request_type: requestType }
        })
      })
      const data = await response.json()
      if (data.success) {
        alert(`${requestTypes.find(t => t.code === requestType)?.name} created successfully!`)
        clearForm()
        setActiveTab('list')
      } else {
        alert('Error: ' + data.error)
      }
    } catch (error) {
      alert('Error: ' + error.message)
    } finally {
      setSaving(false)
    }
  }

  const applyTemplate = (template) => {
    setFormData(prev => ({
      ...prev,
      priority: template.default_priority,
      purpose: template.default_purpose || '',
      items: template.template_items.map((item, index) => ({
        line_number: index + 1,
        material_code: item.material_code,
        requested_quantity: item.quantity,
        base_uom: item.uom
      }))
    }))
  }

  const addItem = () => {
    setFormData(prev => ({
      ...prev,
      items: [...prev.items, {
        line_number: prev.items.length + 1,
        material_code: '',
        requested_quantity: 0,
        base_uom: 'PCS'
      }]
    }))
  }

  const removeItem = (index) => {
    setFormData(prev => ({
      ...prev,
      items: prev.items.filter((_, i) => i !== index)
    }))
  }

  const updateItem = (index, field, value) => {
    setFormData(prev => ({
      ...prev,
      items: prev.items.map((item, i) => 
        i === index ? { ...item, [field]: value } : item
      )
    }))
  }

  const clearForm = () => {
    setFormData({
      request_type: requestType,
      priority: 'MEDIUM',
      required_date: '',
      company_code: smartDefaults?.organizational?.default_company_code || '',
      plant_code: smartDefaults?.organizational?.default_plant_code || '',
      cost_center: smartDefaults?.organizational?.default_cost_center || '',
      project_code: '',
      purpose: '',
      justification: '',
      notes: '',
      items: [{ line_number: 1, material_code: '', requested_quantity: 0, base_uom: 'PCS' }]
    })
  }

  const getStatusColor = (status) => {
    const colors = {
      'DRAFT': 'bg-gray-100 text-gray-800',
      'SUBMITTED': 'bg-blue-100 text-blue-800',
      'APPROVED': 'bg-green-100 text-green-800',
      'REJECTED': 'bg-red-100 text-red-800',
      'FULFILLED': 'bg-purple-100 text-purple-800'
    }
    return colors[status] || 'bg-gray-100 text-gray-800'
  }

  return (
    <div className="p-6">
      <div className="bg-white rounded-lg shadow">
        {/* Header */}
        <div className="border-b border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-xl font-semibold text-gray-900">Material Requests</h2>
              <p className="text-sm text-gray-600 mt-1">Unified system for reservations, PRs, and material requests</p>
            </div>
            <div className="flex items-center space-x-4">
              {/* Request Type Selector */}
              <div className="flex bg-gray-100 rounded-lg p-1">
                {requestTypes.map(type => (
                  <button
                    key={type.code}
                    onClick={() => setRequestType(type.code)}
                    className={`px-3 py-1 rounded text-sm font-medium transition-colors ${
                      requestType === type.code
                        ? `bg-${type.color}-600 text-white`
                        : 'text-gray-600 hover:text-gray-800'
                    }`}
                  >
                    {type.name}
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* Tab Navigation */}
        <div className="border-b border-gray-200">
          <nav className="flex space-x-8 px-6">
            <button
              onClick={() => setActiveTab('create')}
              className={`py-4 px-1 border-b-2 font-medium text-sm ${
                activeTab === 'create'
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
            >
              <Icons.Plus className="w-4 h-4 inline mr-2" />
              Create Request
            </button>
            <button
              onClick={() => setActiveTab('list')}
              className={`py-4 px-1 border-b-2 font-medium text-sm ${
                activeTab === 'list'
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
            >
              <Icons.List className="w-4 h-4 inline mr-2" />
              My Requests
            </button>
            <button
              onClick={() => setActiveTab('templates')}
              className={`py-4 px-1 border-b-2 font-medium text-sm ${
                activeTab === 'templates'
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
            >
              <Icons.FileText className="w-4 h-4 inline mr-2" />
              Templates
            </button>
          </nav>
        </div>

        {/* Tab Content */}
        <div className="p-6">
          {/* Create Request Tab */}
          {activeTab === 'create' && (
            <form onSubmit={handleSubmit} className="space-y-6">
              {/* Quick Templates */}
              {templates.length > 0 && (
                <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                  <h3 className="text-sm font-medium text-blue-900 mb-2">Quick Start Templates</h3>
                  <div className="flex flex-wrap gap-2">
                    {templates.slice(0, 3).map(template => (
                      <button
                        key={template.id}
                        type="button"
                        onClick={() => applyTemplate(template)}
                        className="bg-blue-100 text-blue-700 px-3 py-1 rounded text-sm hover:bg-blue-200"
                      >
                        {template.template_name}
                      </button>
                    ))}
                  </div>
                </div>
              )}

              {/* Basic Information */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-2">Required Date *</label>
                  <input
                    type="date"
                    required
                    className="w-full border rounded-lg px-3 py-2"
                    value={formData.required_date}
                    onChange={(e) => setFormData(prev => ({ ...prev, required_date: e.target.value }))}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-2">Priority *</label>
                  <select
                    required
                    className="w-full border rounded-lg px-3 py-2"
                    value={formData.priority}
                    onChange={(e) => setFormData(prev => ({ ...prev, priority: e.target.value }))}
                  >
                    {priorities.map(priority => (
                      <option key={priority.code} value={priority.code}>
                        {priority.name}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-2">Company Code *</label>
                  <input
                    type="text"
                    required
                    className="w-full border rounded-lg px-3 py-2"
                    value={formData.company_code}
                    onChange={(e) => setFormData(prev => ({ ...prev, company_code: e.target.value }))}
                  />
                </div>
              </div>

              {/* Material Items */}
              <div>
                <div className="flex justify-between items-center mb-4">
                  <h3 className="text-lg font-medium">Material Items</h3>
                  <button
                    type="button"
                    onClick={addItem}
                    className="bg-green-600 text-white px-3 py-1 rounded text-sm hover:bg-green-700"
                  >
                    <Icons.Plus className="w-4 h-4 inline mr-1" />
                    Add Item
                  </button>
                </div>
                
                <div className="space-y-3">
                  {formData.items.map((item, index) => (
                    <div key={index} className="grid grid-cols-1 md:grid-cols-5 gap-3 p-3 border rounded-lg">
                      <div>
                        <label className="block text-xs font-medium mb-1">Material Code *</label>
                        <input
                          type="text"
                          required
                          className="w-full border rounded px-2 py-1 text-sm"
                          value={item.material_code}
                          onChange={(e) => updateItem(index, 'material_code', e.target.value)}
                        />
                      </div>
                      <div>
                        <label className="block text-xs font-medium mb-1">Quantity *</label>
                        <input
                          type="number"
                          required
                          min="0"
                          step="0.001"
                          className="w-full border rounded px-2 py-1 text-sm"
                          value={item.requested_quantity}
                          onChange={(e) => updateItem(index, 'requested_quantity', parseFloat(e.target.value) || 0)}
                        />
                      </div>
                      <div>
                        <label className="block text-xs font-medium mb-1">UOM *</label>
                        <select
                          required
                          className="w-full border rounded px-2 py-1 text-sm"
                          value={item.base_uom}
                          onChange={(e) => updateItem(index, 'base_uom', e.target.value)}
                        >
                          <option value="PCS">PCS</option>
                          <option value="BAG">BAG</option>
                          <option value="TON">TON</option>
                          <option value="KG">KG</option>
                          <option value="LTR">LTR</option>
                        </select>
                      </div>
                      <div>
                        <label className="block text-xs font-medium mb-1">Est. Price</label>
                        <input
                          type="number"
                          min="0"
                          step="0.01"
                          className="w-full border rounded px-2 py-1 text-sm"
                          value={item.estimated_price || ''}
                          onChange={(e) => updateItem(index, 'estimated_price', parseFloat(e.target.value) || 0)}
                        />
                      </div>
                      <div className="flex items-end">
                        <button
                          type="button"
                          onClick={() => removeItem(index)}
                          className="bg-red-100 text-red-700 px-2 py-1 rounded text-sm hover:bg-red-200"
                          disabled={formData.items.length === 1}
                        >
                          <Icons.Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Additional Information */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-2">Purpose</label>
                  <input
                    type="text"
                    className="w-full border rounded-lg px-3 py-2"
                    value={formData.purpose}
                    onChange={(e) => setFormData(prev => ({ ...prev, purpose: e.target.value }))}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-2">Project Code</label>
                  <input
                    type="text"
                    className="w-full border rounded-lg px-3 py-2"
                    value={formData.project_code}
                    onChange={(e) => setFormData(prev => ({ ...prev, project_code: e.target.value }))}
                  />
                </div>
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium mb-2">Justification</label>
                  <textarea
                    className="w-full border rounded-lg px-3 py-2"
                    rows={3}
                    value={formData.justification}
                    onChange={(e) => setFormData(prev => ({ ...prev, justification: e.target.value }))}
                  />
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex space-x-4">
                <button
                  type="submit"
                  disabled={saving}
                  className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50"
                >
                  {saving ? 'Creating...' : `Create ${requestTypes.find(t => t.code === requestType)?.name}`}
                </button>
                <button
                  type="button"
                  onClick={clearForm}
                  className="bg-gray-500 text-white px-6 py-2 rounded-lg hover:bg-gray-600"
                >
                  Clear
                </button>
              </div>
            </form>
          )}

          {/* List Tab */}
          {activeTab === 'list' && (
            <div className="space-y-4">
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Request #</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Priority</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Required Date</th>
                      <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {requests.map((request, index) => (
                      <tr key={index} className="hover:bg-gray-50">
                        <td className="px-4 py-4 text-sm font-medium text-gray-900">{request.request_number}</td>
                        <td className="px-4 py-4 text-sm text-gray-900">{request.request_type}</td>
                        <td className="px-4 py-4 text-sm">
                          <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-${priorities.find(p => p.code === request.priority)?.color}-100 text-${priorities.find(p => p.code === request.priority)?.color}-800`}>
                            {request.priority}
                          </span>
                        </td>
                        <td className="px-4 py-4 text-sm">
                          <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(request.status)}`}>
                            {request.status}
                          </span>
                        </td>
                        <td className="px-4 py-4 text-sm text-gray-900">{request.required_date}</td>
                        <td className="px-4 py-4 text-center">
                          <button className="bg-blue-100 text-blue-700 px-2 py-1 rounded text-xs hover:bg-blue-200">
                            View
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* Templates Tab */}
          {activeTab === 'templates' && (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {templates.map(template => (
                <div key={template.id} className="border rounded-lg p-4 hover:shadow-md">
                  <h3 className="font-medium text-gray-900 mb-2">{template.template_name}</h3>
                  <p className="text-sm text-gray-600 mb-3">{template.default_purpose}</p>
                  <div className="flex justify-between items-center">
                    <span className="text-xs text-gray-500">{template.template_items.length} items</span>
                    <button
                      onClick={() => {
                        applyTemplate(template)
                        setActiveTab('create')
                      }}
                      className="bg-blue-600 text-white px-3 py-1 rounded text-sm hover:bg-blue-700"
                    >
                      Use Template
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}