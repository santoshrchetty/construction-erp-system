import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'

interface Material {
  material_code: string
  material_name: string
  base_uom: string
  standard_price: number
  category_name?: string
  material_storage_data?: Array<{
    current_stock: number
    reserved_stock: number
    available_stock: number
  }>
}

export function UnifiedMaterialRequest() {
  const [activeTab, setActiveTab] = useState('create')
  const [requests, setRequests] = useState([])
  const [templates, setTemplates] = useState([])
  const [loading, setLoading] = useState(false)
  const [saving, setSaving] = useState(false)

  // Master data dropdowns
  const [companies, setCompanies] = useState<any[]>([])
  const [plants, setPlants] = useState<any[]>([])
  const [storageLocations, setStorageLocations] = useState<any[]>([])
  const [materials, setMaterials] = useState<Material[]>([])
  const [materialSearch, setMaterialSearch] = useState('')
  const [searchingMaterials, setSearchingMaterials] = useState(false)
  const [activeSearchIndex, setActiveSearchIndex] = useState<number | null>(null)
  const [loadingCompanies, setLoadingCompanies] = useState(false)
  const [loadingPlants, setLoadingPlants] = useState(false)
  const [loadingLocations, setLoadingLocations] = useState(false)
  
  // Cost assignment dropdowns
  const [projects, setProjects] = useState<any[]>([])
  const [wbsElements, setWbsElements] = useState<any[]>([])
  const [activities, setActivities] = useState<any[]>([])
  const [costCenters, setCostCenters] = useState<any[]>([])
  const [loadingProjects, setLoadingProjects] = useState(false)
  const [loadingWBS, setLoadingWBS] = useState(false)
  const [loadingActivities, setLoadingActivities] = useState(false)
  const [loadingCostCenters, setLoadingCostCenters] = useState(false)

  const [formData, setFormData] = useState({
    priority: 'MEDIUM',
    required_date: '',
    company_id: '',
    plant_id: '',
    storage_location_id: '',
    
    // Cost assignment
    account_assignment: '',  // 'P' | 'K' | 'M' | 'F'
    project_id: '',
    wbs_element_id: '',
    activity_id: '',
    cost_center_id: '',
    order_number: '',
    
    purpose: '',
    justification: '',
    notes: '',
    items: [{ line_number: 1, material_code: '', material_name: '', requested_quantity: 0, base_uom: 'PCS', available_stock: 0 }]
  })

  const priorities = [
    { code: 'LOW', name: 'Low', color: 'gray' },
    { code: 'MEDIUM', name: 'Medium', color: 'yellow' },
    { code: 'HIGH', name: 'High', color: 'orange' },
    { code: 'URGENT', name: 'Urgent', color: 'red' }
  ]
  
  const accountAssignmentTypes = [
    { code: 'P', name: 'Project', icon: 'Briefcase' },
    { code: 'K', name: 'Cost Center', icon: 'Building' },
    { code: 'M', name: 'Maintenance Order', icon: 'Wrench' },
    { code: 'F', name: 'Production Order', icon: 'Factory' }
  ]

  useEffect(() => {
    loadCompanies()
    loadTemplates()
    if (activeTab === 'list') loadRequests()
  }, [activeTab])

  useEffect(() => {
    if (formData.company_id) {
      loadPlants(formData.company_id)
      loadProjects(formData.company_id)
      loadCostCenters(formData.company_id)
    }
  }, [formData.company_id])

  useEffect(() => {
    if (formData.plant_id) loadStorageLocations(formData.plant_id)
  }, [formData.plant_id])
  
  useEffect(() => {
    if (formData.project_id) loadWBSElements(formData.project_id)
  }, [formData.project_id])
  
  useEffect(() => {
    if (formData.wbs_element_id) loadActivities(formData.wbs_element_id)
  }, [formData.wbs_element_id])

  useEffect(() => {
    const timer = setTimeout(() => {
      if (materialSearch.length >= 2 && formData.plant_id) searchMaterials()
    }, 300)
    return () => clearTimeout(timer)
  }, [materialSearch, formData.plant_id, formData.storage_location_id])

  const loadCompanies = async () => {
    setLoadingCompanies(true)
    try {
      const response = await fetch('/api/erp-config/companies')
      const data = await response.json()
      if (data.success) setCompanies(data.data)
    } catch (error) {
      console.error('Failed to load companies:', error)
    } finally {
      setLoadingCompanies(false)
    }
  }

  const loadPlants = async (companyId: string) => {
    setLoadingPlants(true)
    setPlants([])
    setStorageLocations([])
    try {
      const response = await fetch(`/api/erp-config/plants?companyId=${companyId}`)
      const data = await response.json()
      if (data.success) setPlants(data.data)
    } catch (error) {
      console.error('Failed to load plants:', error)
    } finally {
      setLoadingPlants(false)
    }
  }

  const loadStorageLocations = async (plantId: string) => {
    setLoadingLocations(true)
    setStorageLocations([])
    try {
      const response = await fetch(`/api/erp-config/storage-locations?plantId=${plantId}`)
      const data = await response.json()
      if (data.success) setStorageLocations(data.data)
    } catch (error) {
      console.error('Failed to load storage locations:', error)
    } finally {
      setLoadingLocations(false)
    }
  }

  const searchMaterials = async () => {
    setSearchingMaterials(true)
    try {
      const params = new URLSearchParams({
        search: materialSearch,
        withStock: 'true',
        limit: '20'
      })
      
      // Filter by storage location if selected, otherwise by plant
      if (formData.storage_location_id) {
        params.append('storageLocationId', formData.storage_location_id)
      } else if (formData.plant_id) {
        params.append('plantId', formData.plant_id)
      }
      
      const response = await fetch(`/api/materials?${params}`)
      const data = await response.json()
      if (data.success) setMaterials(data.data)
    } catch (error) {
      console.error('Failed to search materials:', error)
    } finally {
      setSearchingMaterials(false)
    }
  }
  
  const loadProjects = async (companyId: string) => {
    setLoadingProjects(true)
    try {
      const response = await fetch(`/api/projects?companyId=${companyId}`)
      const data = await response.json()
      if (data.success) setProjects(data.data || [])
    } catch (error) {
      console.error('Failed to load projects:', error)
    } finally {
      setLoadingProjects(false)
    }
  }
  
  const loadWBSElements = async (projectId: string) => {
    setLoadingWBS(true)
    setWbsElements([])
    setActivities([])
    try {
      const response = await fetch(`/api/wbs?projectId=${projectId}`)
      const data = await response.json()
      if (data.success) setWbsElements(data.data || [])
    } catch (error) {
      console.error('Failed to load WBS elements:', error)
    } finally {
      setLoadingWBS(false)
    }
  }
  
  const loadActivities = async (wbsId: string) => {
    setLoadingActivities(true)
    setActivities([])
    try {
      const response = await fetch(`/api/activities?wbsId=${wbsId}`)
      const data = await response.json()
      if (data.success) setActivities(data.data || [])
    } catch (error) {
      console.error('Failed to load activities:', error)
    } finally {
      setLoadingActivities(false)
    }
  }
  
  const loadCostCenters = async (companyId: string) => {
    setLoadingCostCenters(true)
    try {
      const response = await fetch(`/api/cost-centers?companyId=${companyId}`)
      const data = await response.json()
      if (data.success) setCostCenters(data.data || [])
    } catch (error) {
      console.error('Failed to load cost centers:', error)
    } finally {
      setLoadingCostCenters(false)
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
          payload: { template_type: 'MATERIAL_REQ' }
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
          payload: { request_type: 'MATERIAL_REQ' }
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
          payload: { ...formData, request_type: 'MATERIAL_REQ' }
        })
      })
      const data = await response.json()
      if (data.success) {
        alert('Material Request created successfully!')
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
        material_name: '',
        requested_quantity: 0,
        base_uom: 'PCS',
        available_stock: 0
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
      priority: 'MEDIUM',
      required_date: '',
      company_id: '',
      plant_id: '',
      storage_location_id: '',
      account_assignment: '',
      project_id: '',
      wbs_element_id: '',
      activity_id: '',
      cost_center_id: '',
      order_number: '',
      purpose: '',
      justification: '',
      notes: '',
      items: [{ line_number: 1, material_code: '', material_name: '', requested_quantity: 0, base_uom: 'PCS', available_stock: 0 }]
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
              <div className="space-y-4">
                <div className="bg-gradient-to-r from-blue-50 to-indigo-50 border border-blue-200 rounded-lg p-4">
                  <h3 className="text-sm font-semibold text-blue-900 mb-3 flex items-center">
                    <Icons.Building2 className="w-4 h-4 mr-2" />
                    Organizational Details
                  </h3>
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Company <span className="text-red-500">*</span>
                      </label>
                      <div className="relative">
                        <select
                          required
                          className="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all"
                          value={formData.company_id}
                          onChange={(e) => setFormData(prev => ({ ...prev, company_id: e.target.value, plant_id: '', storage_location_id: '' }))}
                        >
                          <option value="">Select Company</option>
                          {companies.map(c => (
                            <option key={c.id} value={c.id}>
                              {c.company_code} - {c.company_name}
                            </option>
                          ))}
                        </select>
                        {loadingCompanies && (
                          <Icons.Loader className="w-4 h-4 absolute right-10 top-3 animate-spin text-gray-400" />
                        )}
                      </div>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Plant <span className="text-red-500">*</span>
                        {!formData.company_id && <span className="text-xs text-gray-500 ml-1">(Select company first)</span>}
                      </label>
                      <div className="relative">
                        <select
                          required
                          disabled={!formData.company_id || loadingPlants}
                          className="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-50 disabled:text-gray-500 transition-all"
                          value={formData.plant_id}
                          onChange={(e) => setFormData(prev => ({ ...prev, plant_id: e.target.value, storage_location_id: '' }))}
                        >
                          <option value="">{loadingPlants ? 'Loading...' : 'Select Plant'}</option>
                          {plants.map(p => (
                            <option key={p.id} value={p.id}>
                              {p.plant_code} - {p.plant_name}
                            </option>
                          ))}
                        </select>
                        {loadingPlants && (
                          <Icons.Loader className="w-4 h-4 absolute right-10 top-3 animate-spin text-blue-500" />
                        )}
                      </div>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Storage Location
                        {!formData.plant_id && <span className="text-xs text-gray-500 ml-1">(Select plant first)</span>}
                      </label>
                      <div className="relative">
                        <select
                          disabled={!formData.plant_id || loadingLocations}
                          className="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-50 disabled:text-gray-500 transition-all"
                          value={formData.storage_location_id}
                          onChange={(e) => setFormData(prev => ({ ...prev, storage_location_id: e.target.value }))}
                        >
                          <option value="">{loadingLocations ? 'Loading...' : 'Select Storage Location'}</option>
                          {storageLocations.map(sl => (
                            <option key={sl.id} value={sl.id}>
                              {sl.sloc_code} - {sl.sloc_name}
                            </option>
                          ))}
                        </select>
                        {loadingLocations && (
                          <Icons.Loader className="w-4 h-4 absolute right-10 top-3 animate-spin text-blue-500" />
                        )}
                      </div>
                    </div>
                  </div>
                </div>

                <div className="bg-gradient-to-r from-purple-50 to-pink-50 border border-purple-200 rounded-lg p-4">
                  <h3 className="text-sm font-semibold text-purple-900 mb-3 flex items-center">
                    <Icons.Calendar className="w-4 h-4 mr-2" />
                    Request Details
                  </h3>
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Required Date <span className="text-red-500">*</span>
                      </label>
                      <input
                        type="date"
                        required
                        min={new Date().toISOString().split('T')[0]}
                        className="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition-all"
                        value={formData.required_date}
                        onChange={(e) => setFormData(prev => ({ ...prev, required_date: e.target.value }))}
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Priority <span className="text-red-500">*</span>
                      </label>
                      <select
                        required
                        className="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition-all"
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
                      <label className="block text-sm font-medium text-gray-700 mb-2">Purpose</label>
                      <input
                        type="text"
                        placeholder="Optional"
                        className="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition-all"
                        value={formData.purpose}
                        onChange={(e) => setFormData(prev => ({ ...prev, purpose: e.target.value }))}
                      />
                    </div>
                  </div>
                </div>

                <div className="bg-gradient-to-r from-orange-50 to-red-50 border border-orange-200 rounded-lg p-4">
                  <h3 className="text-sm font-semibold text-orange-900 mb-3 flex items-center">
                    <Icons.Target className="w-4 h-4 mr-2" />
                    Cost Assignment
                  </h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-2">
                        Account Assignment <span className="text-red-500">*</span>
                      </label>
                      <select
                        required
                        className="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:ring-2 focus:ring-orange-500 focus:border-orange-500 transition-all"
                        value={formData.account_assignment}
                        onChange={(e) => setFormData(prev => ({ 
                          ...prev, 
                          account_assignment: e.target.value,
                          project_id: '',
                          wbs_element_id: '',
                          activity_id: '',
                          cost_center_id: '',
                          order_number: ''
                        }))}
                      >
                        <option value="">Select Assignment Type</option>
                        {accountAssignmentTypes.map(type => (
                          <option key={type.code} value={type.code}>
                            {type.name}
                          </option>
                        ))}
                      </select>
                    </div>
                    
                    {formData.account_assignment === 'P' && (
                      <>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-2">
                            Project <span className="text-red-500">*</span>
                          </label>
                          <select
                            required
                            disabled={loadingProjects}
                            className="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:ring-2 focus:ring-orange-500 focus:border-orange-500 disabled:bg-gray-50 transition-all"
                            value={formData.project_id}
                            onChange={(e) => setFormData(prev => ({ ...prev, project_id: e.target.value, wbs_element_id: '', activity_id: '' }))}
                          >
                            <option value="">{loadingProjects ? 'Loading...' : 'Select Project'}</option>
                            {projects.map(p => (
                              <option key={p.id} value={p.id}>
                                {p.code} - {p.name}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-2">
                            WBS Element
                            {!formData.project_id && <span className="text-xs text-gray-500 ml-1">(Select project first)</span>}
                          </label>
                          <select
                            disabled={!formData.project_id || loadingWBS}
                            className="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:ring-2 focus:ring-orange-500 focus:border-orange-500 disabled:bg-gray-50 transition-all"
                            value={formData.wbs_element_id}
                            onChange={(e) => setFormData(prev => ({ ...prev, wbs_element_id: e.target.value, activity_id: '' }))}
                          >
                            <option value="">{loadingWBS ? 'Loading...' : 'Select WBS (Optional)'}</option>
                            {wbsElements.map(w => (
                              <option key={w.id} value={w.id}>
                                {w.code} - {w.name}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-2">
                            Activity
                            {!formData.wbs_element_id && <span className="text-xs text-gray-500 ml-1">(Select WBS first)</span>}
                          </label>
                          <select
                            disabled={!formData.wbs_element_id || loadingActivities}
                            className="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:ring-2 focus:ring-orange-500 focus:border-orange-500 disabled:bg-gray-50 transition-all"
                            value={formData.activity_id}
                            onChange={(e) => setFormData(prev => ({ ...prev, activity_id: e.target.value }))}
                          >
                            <option value="">{loadingActivities ? 'Loading...' : 'Select Activity (Optional)'}</option>
                            {activities.map(a => (
                              <option key={a.id} value={a.id}>
                                {a.code} - {a.name}
                              </option>
                            ))}
                          </select>
                        </div>
                      </>
                    )}
                    
                    {formData.account_assignment === 'K' && (
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                          Cost Center <span className="text-red-500">*</span>
                        </label>
                        <select
                          required
                          disabled={loadingCostCenters}
                          className="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:ring-2 focus:ring-orange-500 focus:border-orange-500 disabled:bg-gray-50 transition-all"
                          value={formData.cost_center_id}
                          onChange={(e) => setFormData(prev => ({ ...prev, cost_center_id: e.target.value }))}
                        >
                          <option value="">{loadingCostCenters ? 'Loading...' : 'Select Cost Center'}</option>
                          {costCenters.map(cc => (
                            <option key={cc.id} value={cc.id}>
                              {cc.cost_center_code} - {cc.cost_center_name}
                            </option>
                          ))}
                        </select>
                      </div>
                    )}
                    
                    {(formData.account_assignment === 'M' || formData.account_assignment === 'F') && (
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                          {formData.account_assignment === 'M' ? 'Maintenance' : 'Production'} Order <span className="text-red-500">*</span>
                        </label>
                        <input
                          type="text"
                          required
                          placeholder="Enter order number"
                          className="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:ring-2 focus:ring-orange-500 focus:border-orange-500 transition-all"
                          value={formData.order_number}
                          onChange={(e) => setFormData(prev => ({ ...prev, order_number: e.target.value }))}
                        />
                      </div>
                    )}
                  </div>
                </div>
              </div>

              {/* Material Items */}
              <div className="bg-gradient-to-r from-green-50 to-emerald-50 border border-green-200 rounded-lg p-4">
                <div className="flex justify-between items-center mb-4">
                  <h3 className="text-sm font-semibold text-green-900 flex items-center">
                    <Icons.Package className="w-4 h-4 mr-2" />
                    Material Items ({formData.items.length})
                  </h3>
                  <button
                    type="button"
                    onClick={addItem}
                    disabled={!formData.plant_id}
                    className="bg-green-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all flex items-center shadow-sm"
                  >
                    <Icons.Plus className="w-4 h-4 mr-1" />
                    Add Item
                  </button>
                </div>
                
                {!formData.plant_id && (
                  <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-3 mb-4 flex items-start">
                    <Icons.AlertCircle className="w-5 h-5 text-yellow-600 mr-2 flex-shrink-0 mt-0.5" />
                    <div className="text-sm text-yellow-800">
                      <p className="font-medium">Plant selection required</p>
                      <p className="text-xs mt-1">Please select a company and plant before adding materials</p>
                    </div>
                  </div>
                )}
                
                <div className="space-y-4">
                  {formData.items.map((item, index) => (
                    <div key={index} className="bg-white border-2 border-gray-200 rounded-lg p-4 space-y-3 hover:border-green-300 transition-all">
                      <div className="flex items-center justify-between mb-2">
                        <span className="text-xs font-semibold text-gray-500 bg-gray-100 px-2 py-1 rounded">Item #{index + 1}</span>
                        <button
                          type="button"
                          onClick={() => removeItem(index)}
                          className="text-red-600 hover:text-red-700 hover:bg-red-50 p-1.5 rounded transition-all"
                          disabled={formData.items.length === 1}
                          title="Remove item"
                        >
                          <Icons.X className="w-4 h-4" />
                        </button>
                      </div>
                      <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
                        <div className="md:col-span-3">
                          <label className="block text-xs font-medium text-gray-700 mb-1.5">
                            Material Search <span className="text-red-500">*</span>
                          </label>
                          <div className="relative">
                            <input
                              type="text"
                              placeholder={item.material_code ? `${item.material_code} - ${item.material_name}` : "Type to search materials..."}
                              className="w-full border-2 border-gray-300 rounded-lg px-3 py-2.5 text-sm pr-10 focus:ring-2 focus:ring-green-500 focus:border-green-500 disabled:bg-gray-50 transition-all"
                              value={activeSearchIndex === index ? materialSearch : ''}
                              onChange={(e) => {
                                setMaterialSearch(e.target.value)
                                setActiveSearchIndex(index)
                              }}
                              onFocus={() => setActiveSearchIndex(index)}
                              disabled={!formData.plant_id}
                            />
                            <div className="absolute right-3 top-2.5">
                              {searchingMaterials && activeSearchIndex === index ? (
                                <Icons.Loader className="w-5 h-5 animate-spin text-green-500" />
                              ) : (
                                <Icons.Search className="w-5 h-5 text-gray-400" />
                              )}
                            </div>
                          </div>
                          {activeSearchIndex === index && materialSearch.length >= 2 && materials.length > 0 && (
                            <div className="absolute z-20 mt-1 w-full md:w-2/3 bg-white border-2 border-green-300 rounded-lg shadow-xl max-h-72 overflow-y-auto">
                              <div className="sticky top-0 bg-green-50 px-3 py-2 border-b border-green-200">
                                <p className="text-xs font-medium text-green-900">{materials.length} materials found</p>
                              </div>
                              {materials.map((mat) => {
                                const stock = mat.material_storage_data?.[0]
                                const stockStatus = stock?.available_stock > 0 ? '🟢' : stock?.current_stock > 0 ? '🟡' : '🔴'
                                const stockLabel = stock?.available_stock > 0 ? 'In Stock' : stock?.current_stock > 0 ? 'Reserved' : 'Out of Stock'
                                return (
                                  <button
                                    key={mat.material_code}
                                    type="button"
                                    className="w-full text-left px-4 py-3 hover:bg-green-50 border-b last:border-b-0 transition-colors"
                                    onClick={() => {
                                      updateItem(index, 'material_code', mat.material_code)
                                      updateItem(index, 'material_name', mat.material_name)
                                      updateItem(index, 'base_uom', mat.base_uom)
                                      updateItem(index, 'available_stock', stock?.available_stock || 0)
                                      setMaterialSearch('')
                                      setMaterials([])
                                      setActiveSearchIndex(null)
                                    }}
                                  >
                                    <div className="flex justify-between items-start gap-3">
                                      <div className="flex-1 min-w-0">
                                        <div className="text-sm font-semibold text-gray-900 truncate">{mat.material_code}</div>
                                        <div className="text-xs text-gray-600 mt-0.5">{mat.material_name}</div>
                                        {mat.category_name && (
                                          <div className="text-xs text-gray-500 mt-0.5 flex items-center">
                                            <Icons.Tag className="w-3 h-3 mr-1" />
                                            {mat.category_name}
                                          </div>
                                        )}
                                      </div>
                                      <div className="text-right flex-shrink-0">
                                        <div className="text-xs font-bold text-gray-900">{stockStatus} {stock?.available_stock || 0} {mat.base_uom}</div>
                                        <div className="text-xs text-gray-500 mt-0.5">{stockLabel}</div>
                                      </div>
                                    </div>
                                  </button>
                                )
                              })}
                            </div>
                          )}
                          {activeSearchIndex === index && materialSearch.length >= 2 && materials.length === 0 && !searchingMaterials && (
                            <div className="absolute z-20 mt-1 w-full md:w-2/3 bg-white border-2 border-gray-300 rounded-lg shadow-lg p-4 text-center">
                              <Icons.Search className="w-8 h-8 text-gray-400 mx-auto mb-2" />
                              <p className="text-sm text-gray-600">No materials found</p>
                              <p className="text-xs text-gray-500 mt-1">Try a different search term</p>
                            </div>
                          )}
                        </div>
                        <div>
                          <label className="block text-xs font-medium text-gray-700 mb-1.5">
                            Quantity <span className="text-red-500">*</span>
                          </label>
                          <input
                            type="number"
                            required
                            min="0.001"
                            step="0.001"
                            placeholder="0.00"
                            className="w-full border-2 border-gray-300 rounded-lg px-3 py-2.5 text-sm focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-all"
                            value={item.requested_quantity || ''}
                            onChange={(e) => updateItem(index, 'requested_quantity', parseFloat(e.target.value) || 0)}
                          />
                        </div>
                      </div>
                      {item.material_code && (
                        <div className="bg-gradient-to-r from-gray-50 to-gray-100 rounded-lg p-3 border border-gray-200">
                          <div className="flex justify-between items-start mb-2">
                            <div className="flex-1">
                              <p className="text-sm font-semibold text-gray-900">{item.material_code}</p>
                              <p className="text-xs text-gray-600 mt-0.5">{item.material_name}</p>
                            </div>
                            <span className="text-xs font-medium text-gray-600 bg-white px-2 py-1 rounded border">{item.base_uom}</span>
                          </div>
                          {item.available_stock !== undefined && (
                            <div className="flex items-center justify-between pt-2 border-t border-gray-300">
                              <div className="flex items-center space-x-2">
                                {item.available_stock >= item.requested_quantity ? (
                                  <>
                                    <div className="flex items-center text-green-700 bg-green-100 px-2 py-1 rounded">
                                      <Icons.CheckCircle className="w-4 h-4 mr-1" />
                                      <span className="text-xs font-medium">Available: {item.available_stock} {item.base_uom}</span>
                                    </div>
                                  </>
                                ) : (
                                  <>
                                    <div className="flex items-center text-red-700 bg-red-100 px-2 py-1 rounded">
                                      <Icons.AlertTriangle className="w-4 h-4 mr-1" />
                                      <span className="text-xs font-medium">Only {item.available_stock} {item.base_uom} available</span>
                                    </div>
                                    <span className="text-xs font-semibold text-red-600">Insufficient stock!</span>
                                  </>
                                )}
                              </div>
                            </div>
                          )}
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              </div>

              {/* Additional Information */}
              <div className="grid grid-cols-1 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-2">Justification</label>
                  <textarea
                    className="w-full border rounded-lg px-3 py-2"
                    rows={3}
                    placeholder="Provide justification for this request..."
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
                  className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50 flex items-center"
                >
                  {saving ? (
                    <>
                      <Icons.Loader className="w-4 h-4 mr-2 animate-spin" />
                      Creating...
                    </>
                  ) : (
                    <>
                      <Icons.Send className="w-4 h-4 mr-2" />
                      Create Material Request
                    </>
                  )}
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