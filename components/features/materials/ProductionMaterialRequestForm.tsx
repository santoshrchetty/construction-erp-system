'use client'

import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'

interface MaterialRequestItem {
  id?: string
  line_number: number
  material_code?: string
  description: string
  specification?: string
  quantity: number
  unit: string
  estimated_unit_cost?: number
  estimated_total_cost?: number
  urgency_level: number
  preferred_vendor_id?: string
}

interface MaterialRequest {
  id?: string
  request_number?: string
  company_code: string
  plant_code: string
  project_code: string
  cost_center?: string
  wbs_element?: string
  requested_by?: string
  request_date: string
  required_date: string
  status: string
  priority: number
  justification?: string
  total_estimated_cost: number
  items: MaterialRequestItem[]
}

type FormMode = 'create' | 'view' | 'edit'

interface MaterialRequestFormProps {
  mode: FormMode
  requestId?: string
  projectCode: string
  onClose: () => void
  onSave: (request: Partial<MaterialRequest>) => void
}

export default function ProductionMaterialRequestForm({
  mode,
  requestId,
  projectCode,
  onClose,
  onSave
}: MaterialRequestFormProps) {
  const [request, setRequest] = useState<Partial<MaterialRequest>>({
    project_code: projectCode,
    company_code: 'C001',
    plant_code: 'P001',
    request_date: new Date().toISOString().split('T')[0],
    required_date: '',
    status: 'draft',
    priority: 3,
    total_estimated_cost: 0,
    items: []
  })
  const [loading, setLoading] = useState(false)
  const [saving, setSaving] = useState(false)
  const [isEditing, setIsEditing] = useState(mode === 'create' || mode === 'edit')
  const [companies, setCompanies] = useState([])
  const [plants, setPlants] = useState([])
  const [projects, setProjects] = useState([])
  const [costCenters, setCostCenters] = useState([])
  const [wbsElements, setWbsElements] = useState([])

  useEffect(() => {
    loadDropdownData()
    if (mode !== 'create' && requestId) {
      loadRequest()
    }
  }, [mode, requestId])

  const loadDropdownData = async () => {
    try {
      const [companiesRes, plantsRes, projectsRes, costCentersRes, wbsRes] = await Promise.all([
        fetch('/api/erp-config/companies'),
        fetch('/api/erp-config/plants?companyCode=C001'),
        fetch('/api/projects?companyCode=C001'),
        fetch('/api/cost-centers?companyCode=C001'),
        fetch(`/api/wbs?projectCode=${projectCode}`)
      ])

      const [companiesData, plantsData, projectsData, costCentersData, wbsData] = await Promise.all([
        companiesRes.json(),
        plantsRes.json(),
        projectsRes.json(),
        costCentersRes.json(),
        wbsRes.json()
      ])

      setCompanies(companiesData.data || [])
      setPlants(plantsData.data || [])
      setProjects(projectsData.data || [])
      setCostCenters(costCentersData.data || [])
      setWbsElements(wbsData.data || [])
    } catch (error) {
      console.error('Failed to load dropdown data:', error)
    }
  }

  const loadRequest = async () => {
    setLoading(true)
    try {
      const response = await fetch(`/api/material-requests?id=${requestId}`)
      const data = await response.json()
      if (data.success) {
        setRequest(data.data)
      }
    } catch (error) {
      console.error('Failed to load request:', error)
    } finally {
      setLoading(false)
    }
  }

  const addItem = () => {
    const newItem: MaterialRequestItem = {
      line_number: (request.items?.length || 0) + 1,
      description: '',
      quantity: 1,
      unit: 'EA',
      urgency_level: 3,
      estimated_unit_cost: 0,
      estimated_total_cost: 0
    }
    setRequest(prev => ({
      ...prev,
      items: [...(prev.items || []), newItem]
    }))
  }

  const updateItem = (index: number, field: keyof MaterialRequestItem, value: any) => {
    const updatedItems = [...(request.items || [])]
    updatedItems[index] = { ...updatedItems[index], [field]: value }
    
    // Calculate total cost for item
    if (field === 'quantity' || field === 'estimated_unit_cost') {
      const quantity = field === 'quantity' ? value : updatedItems[index].quantity
      const unitCost = field === 'estimated_unit_cost' ? value : updatedItems[index].estimated_unit_cost
      updatedItems[index].estimated_total_cost = quantity * (unitCost || 0)
    }

    // Calculate total request cost
    const totalCost = updatedItems.reduce((sum, item) => sum + (item.estimated_total_cost || 0), 0)

    setRequest(prev => ({
      ...prev,
      items: updatedItems,
      total_estimated_cost: totalCost
    }))
  }

  const removeItem = (index: number) => {
    const updatedItems = request.items?.filter((_, i) => i !== index) || []
    const totalCost = updatedItems.reduce((sum, item) => sum + (item.estimated_total_cost || 0), 0)
    
    setRequest(prev => ({
      ...prev,
      items: updatedItems,
      total_estimated_cost: totalCost
    }))
  }

  const handleSave = async () => {
    setSaving(true)
    try {
      const method = mode === 'create' ? 'POST' : 'PUT'
      const url = mode === 'create' ? '/api/material-requests' : `/api/material-requests?id=${requestId}`
      
      const response = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(request)
      })
      
      const data = await response.json()
      if (data.success) {
        onSave(request)
        if (mode === 'edit') {
          setIsEditing(false)
        }
      } else {
        alert('Save failed: ' + data.error)
      }
    } catch (error) {
      alert('Save error: ' + (error as Error).message)
    } finally {
      setSaving(false)
    }
  }

  const getTitle = () => {
    switch (mode) {
      case 'create': return 'Create Material Request'
      case 'view': return 'Material Request Details'
      case 'edit': return isEditing ? 'Edit Material Request' : 'Material Request Details'
      default: return 'Material Request'
    }
  }

  const canEdit = mode === 'create' || (mode === 'edit' && isEditing)

  if (loading) {
    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg p-6">
          <div className="flex items-center">
            <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600 mr-3"></div>
            Loading request...
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-xl max-w-6xl w-full mx-4 max-h-[95vh] overflow-y-auto">
        {/* Header */}
        <div className="flex justify-between items-center p-6 border-b">
          <div>
            <h2 className="text-xl font-semibold text-gray-900">{getTitle()}</h2>
            <p className="text-sm text-gray-600 mt-1">
              {request.request_number && `${request.request_number} • `}
              {request.project_code}
            </p>
          </div>
          <div className="flex items-center space-x-2">
            {mode === 'view' && (
              <button
                onClick={() => setIsEditing(true)}
                className="px-3 py-1.5 bg-blue-600 text-white rounded hover:bg-blue-700 text-sm"
              >
                <Icons.Edit className="w-4 h-4 inline mr-1" />
                Edit
              </button>
            )}
            <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded">
              <Icons.X className="w-5 h-5" />
            </button>
          </div>
        </div>

        {/* Form Content */}
        <div className="p-6 space-y-6">
          {/* Header Information */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Company *
              </label>
              {canEdit ? (
                <select
                  value={request.company_code || ''}
                  onChange={(e) => setRequest(prev => ({ ...prev, company_code: e.target.value }))}
                  className="w-full border rounded-lg px-3 py-2"
                >
                  <option value="">Select Company</option>
                  {companies.map((company: any, index: number) => (
                    <option key={company.id || company.company_code || `company-${index}`} value={company.company_code}>
                      {company.company_name}
                    </option>
                  ))}
                </select>
              ) : (
                <div className="w-full border rounded-lg px-3 py-2 bg-gray-50">
                  {companies.find((c: any) => c.company_code === request.company_code)?.company_name || request.company_code}
                </div>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Plant *
              </label>
              {canEdit ? (
                <select
                  value={request.plant_code || ''}
                  onChange={(e) => setRequest(prev => ({ ...prev, plant_code: e.target.value }))}
                  className="w-full border rounded-lg px-3 py-2"
                >
                  <option value="">Select Plant</option>
                  {plants.map((plant: any, index: number) => (
                    <option key={plant.id || plant.plant_code || `plant-${index}`} value={plant.plant_code}>
                      {plant.plant_name}
                    </option>
                  ))}
                </select>
              ) : (
                <div className="w-full border rounded-lg px-3 py-2 bg-gray-50">
                  {plants.find((p: any) => p.plant_code === request.plant_code)?.plant_name || request.plant_code}
                </div>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Project *
              </label>
              {canEdit ? (
                <select
                  value={request.project_code || ''}
                  onChange={(e) => setRequest(prev => ({ ...prev, project_code: e.target.value }))}
                  className="w-full border rounded-lg px-3 py-2"
                >
                  <option value="">Select Project</option>
                  {projects.map((project: any) => (
                    <option key={project.code} value={project.code}>
                      {project.name}
                    </option>
                  ))}
                </select>
              ) : (
                <div className="w-full border rounded-lg px-3 py-2 bg-gray-50">
                  {projects.find((p: any) => p.code === request.project_code)?.name || request.project_code}
                </div>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Cost Center
              </label>
              {canEdit ? (
                <select
                  value={request.cost_center || ''}
                  onChange={(e) => setRequest(prev => ({ ...prev, cost_center: e.target.value }))}
                  className="w-full border rounded-lg px-3 py-2"
                >
                  <option value="">Select Cost Center</option>
                  {costCenters.map((cc: any, index: number) => (
                    <option key={cc.id || cc.cost_center_code || `costcenter-${index}`} value={cc.cost_center_code}>
                      {cc.cost_center_name}
                    </option>
                  ))}
                </select>
              ) : (
                <div className="w-full border rounded-lg px-3 py-2 bg-gray-50">
                  {costCenters.find((cc: any) => cc.cost_center_code === request.cost_center)?.cost_center_name || request.cost_center || 'N/A'}
                </div>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                WBS Element
              </label>
              {canEdit ? (
                <select
                  value={request.wbs_element || ''}
                  onChange={(e) => setRequest(prev => ({ ...prev, wbs_element: e.target.value }))}
                  className="w-full border rounded-lg px-3 py-2"
                >
                  <option value="">Select WBS</option>
                  {wbsElements.map((wbs: any, index: number) => (
                    <option key={wbs.id || wbs.wbs_element || `wbs-${index}`} value={wbs.wbs_element}>
                      {wbs.wbs_description}
                    </option>
                  ))}
                </select>
              ) : (
                <div className="w-full border rounded-lg px-3 py-2 bg-gray-50">
                  {wbsElements.find((wbs: any) => wbs.wbs_element === request.wbs_element)?.wbs_description || request.wbs_element || 'N/A'}
                </div>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Required Date *
              </label>
              {canEdit ? (
                <input
                  type="date"
                  value={request.required_date || ''}
                  onChange={(e) => setRequest(prev => ({ ...prev, required_date: e.target.value }))}
                  className="w-full border rounded-lg px-3 py-2"
                />
              ) : (
                <div className="w-full border rounded-lg px-3 py-2 bg-gray-50">
                  {request.required_date || 'Not set'}
                </div>
              )}
            </div>
          </div>

          {/* Status and Priority */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Status
              </label>
              <div className="w-full border rounded-lg px-3 py-2 bg-gray-50">
                <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                  request.status === 'approved' ? 'bg-green-100 text-green-800' :
                  request.status === 'rejected' ? 'bg-red-100 text-red-800' :
                  request.status === 'submitted' ? 'bg-blue-100 text-blue-800' :
                  'bg-gray-100 text-gray-800'
                }`}>
                  {request.status || 'Draft'}
                </span>
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Priority
              </label>
              {canEdit ? (
                <select
                  value={request.priority || 3}
                  onChange={(e) => setRequest(prev => ({ ...prev, priority: parseInt(e.target.value) }))}
                  className="w-full border rounded-lg px-3 py-2"
                >
                  <option value={1}>1 - Critical</option>
                  <option value={2}>2 - High</option>
                  <option value={3}>3 - Medium</option>
                  <option value={4}>4 - Low</option>
                </select>
              ) : (
                <div className="w-full border rounded-lg px-3 py-2 bg-gray-50">
                  {request.priority === 1 ? '1 - Critical' :
                   request.priority === 2 ? '2 - High' :
                   request.priority === 4 ? '4 - Low' : '3 - Medium'}
                </div>
              )}
            </div>
          </div>

          {/* Justification */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Justification
            </label>
            {canEdit ? (
              <textarea
                value={request.justification || ''}
                onChange={(e) => setRequest(prev => ({ ...prev, justification: e.target.value }))}
                className="w-full border rounded-lg px-3 py-2"
                rows={3}
                placeholder="Reason for this material request..."
              />
            ) : (
              <div className="w-full border rounded-lg px-3 py-2 bg-gray-50 min-h-[80px]">
                {request.justification || 'No justification provided'}
              </div>
            )}
          </div>

          {/* Items Section */}
          <div>
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-medium text-gray-900">Request Items</h3>
              {canEdit && (
                <button
                  onClick={addItem}
                  className="px-3 py-1.5 bg-green-600 text-white rounded hover:bg-green-700 text-sm"
                >
                  <Icons.Plus className="w-4 h-4 inline mr-1" />
                  Add Item
                </button>
              )}
            </div>

            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase">Line</th>
                    <th className="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase">Description</th>
                    <th className="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase">Qty</th>
                    <th className="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase">Unit</th>
                    <th className="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase">Unit Cost</th>
                    <th className="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase">Total</th>
                    <th className="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase">Urgency</th>
                    {canEdit && <th className="px-3 py-3 text-center text-xs font-medium text-gray-500 uppercase">Action</th>}
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {request.items?.map((item: any, index: number) => (
                    <tr key={item.id || `item-${item.line_number || index}`}>
                      <td className="px-3 py-4 text-sm">{item.line_number}</td>
                      <td className="px-3 py-4">
                        {canEdit ? (
                          <input
                            type="text"
                            value={item.description}
                            onChange={(e) => updateItem(index, 'description', e.target.value)}
                            className="w-full border rounded px-2 py-1 text-sm"
                            placeholder="Item description"
                          />
                        ) : (
                          <div className="text-sm">{item.description}</div>
                        )}
                      </td>
                      <td className="px-3 py-4">
                        {canEdit ? (
                          <input
                            type="number"
                            value={item.quantity}
                            onChange={(e) => updateItem(index, 'quantity', parseFloat(e.target.value) || 0)}
                            className="w-20 border rounded px-2 py-1 text-sm"
                            min="0"
                          />
                        ) : (
                          <div className="text-sm">{item.quantity}</div>
                        )}
                      </td>
                      <td className="px-3 py-4">
                        {canEdit ? (
                          <select
                            value={item.unit}
                            onChange={(e) => updateItem(index, 'unit', e.target.value)}
                            className="w-20 border rounded px-2 py-1 text-sm"
                          >
                            <option value="EA">EA</option>
                            <option value="KG">KG</option>
                            <option value="TON">TON</option>
                            <option value="BAG">BAG</option>
                            <option value="CUM">CUM</option>
                            <option value="MTR">MTR</option>
                          </select>
                        ) : (
                          <div className="text-sm">{item.unit}</div>
                        )}
                      </td>
                      <td className="px-3 py-4">
                        {canEdit ? (
                          <input
                            type="number"
                            value={item.estimated_unit_cost || ''}
                            onChange={(e) => updateItem(index, 'estimated_unit_cost', parseFloat(e.target.value) || 0)}
                            className="w-24 border rounded px-2 py-1 text-sm"
                            min="0"
                            step="0.01"
                          />
                        ) : (
                          <div className="text-sm">${(item.estimated_unit_cost || 0).toFixed(2)}</div>
                        )}
                      </td>
                      <td className="px-3 py-4 text-sm font-medium">
                        ${(item.estimated_total_cost || 0).toFixed(2)}
                      </td>
                      <td className="px-3 py-4">
                        {canEdit ? (
                          <select
                            value={item.urgency_level}
                            onChange={(e) => updateItem(index, 'urgency_level', parseInt(e.target.value))}
                            className="w-16 border rounded px-2 py-1 text-sm"
                          >
                            <option value={1}>1</option>
                            <option value={2}>2</option>
                            <option value={3}>3</option>
                            <option value={4}>4</option>
                          </select>
                        ) : (
                          <div className="text-sm">{item.urgency_level}</div>
                        )}
                      </td>
                      {canEdit && (
                        <td className="px-3 py-4 text-center">
                          <button
                            onClick={() => removeItem(index)}
                            className="text-red-600 hover:text-red-800"
                          >
                            <Icons.Trash2 className="w-4 h-4" />
                          </button>
                        </td>
                      )}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Total */}
            <div className="mt-4 flex justify-end">
              <div className="bg-gray-50 px-4 py-3 rounded-lg">
                <div className="text-sm text-gray-600">Total Estimated Cost</div>
                <div className="text-lg font-semibold">${(request.total_estimated_cost || 0).toFixed(2)}</div>
              </div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="flex justify-end space-x-3 p-6 border-t bg-gray-50">
          <button
            onClick={onClose}
            className="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50"
          >
            {mode === 'view' && !isEditing ? 'Close' : 'Cancel'}
          </button>
          
          {canEdit && (
            <button
              onClick={handleSave}
              disabled={saving || !request.required_date || (request.items?.length || 0) === 0}
              className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
            >
              {saving ? 'Saving...' : mode === 'create' ? 'Create Request' : 'Save Changes'}
            </button>
          )}
        </div>
      </div>
    </div>
  )
}