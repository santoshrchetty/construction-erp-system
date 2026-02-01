import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'
import { MaterialRequestFormData, MaterialRequestItem, validateMaterialRequestData } from '@/types/forms'
import { MaterialRequest } from '@/types/database'
import ProductionMaterialRequestForm from './ProductionMaterialRequestForm'

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
  const [viewingRequest, setViewingRequest] = useState(null)
  const [editingRequest, setEditingRequest] = useState(null)
  const [showProductionForm, setShowProductionForm] = useState(false)
  const [productionFormMode, setProductionFormMode] = useState<'create' | 'view' | 'edit'>('create')
  const [selectedRequestId, setSelectedRequestId] = useState<string | undefined>()
  
  // Filter state
  const [filters, setFilters] = useState({
    entryDateFrom: '',
    entryDateTo: '',
    requiredDate: '',
    material: '',
    priority: '',
    status: ''
  })

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
  const [loadingProjects, setLoadingProjects] = useState(false)
  const [loadingWBS, setLoadingWBS] = useState(false)
  const [loadingActivities, setLoadingActivities] = useState(false)
  const [loadingCostCenters, setLoadingCostCenters] = useState(false)
  
  // Cost assignment dropdowns
  const [projects, setProjects] = useState<any[]>([])
  const [wbsElements, setWbsElements] = useState<any[]>([])
  const [activities, setActivities] = useState<any[]>([])
  const [costCenters, setCostCenters] = useState<any[]>([])
  // Lazy loading states
  const [dropdownStates, setDropdownStates] = useState({
    companiesLoaded: false,
    plantsLoaded: false,
    storageLocationsLoaded: false,
    projectsLoaded: false,
    wbsElementsLoaded: false,
    activitiesLoaded: false,
    costCentersLoaded: false
  })

  const [formData, setFormData] = useState<MaterialRequestFormData>({
    priority: 'MEDIUM',
    required_date: '',
    company_code: '',
    plant_code: '',
    storage_location: '',
    
    // Cost assignment
    account_assignment: '',  // 'P' | 'K' | 'M' | 'F'
    project_code: '',
    wbs_element: '',
    activity_code: '',
    cost_center: '',
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
    loadTemplates()
    // Only load companies for new requests
    if (activeTab === 'create' && !editingRequest) {
      loadCompaniesOnDemand()
    }
    if (activeTab === 'list') loadRequests()
  }, [activeTab])

  // Remove automatic loading useEffects for edit mode
  useEffect(() => {
    // Only auto-load for new requests, not edit mode
    if (formData.company_code && !editingRequest) {
      loadPlantsOnDemand(formData.company_code)
      loadProjectsOnDemand(formData.company_code)
      loadCostCentersOnDemand(formData.company_code)
    }
  }, [formData.company_code, editingRequest])

  useEffect(() => {
    const timer = setTimeout(() => {
      if (materialSearch.length >= 2 && formData.plant_code) searchMaterials()
    }, 300)
    return () => clearTimeout(timer)
  }, [materialSearch, formData.plant_code, formData.storage_location])

  // Load WBS when project changes
  useEffect(() => {
    if (formData.project_code) {
      loadWBSElements(formData.project_code)
    } else {
      setWbsElements([])
      setActivities([])
    }
  }, [formData.project_code])

  // Load Activities when WBS changes
  useEffect(() => {
    if (formData.wbs_element) {
      loadActivities(formData.wbs_element)
    } else {
      setActivities([])
    }
  }, [formData.wbs_element])

  const loadCompaniesOnDemand = async () => {
    if (dropdownStates.companiesLoaded) return
    setLoadingCompanies(true)
    try {
      const response = await fetch('/api/erp-config/companies')
      const data = await response.json()
      if (data.success) {
        setCompanies(data.data)
        setDropdownStates(prev => ({ ...prev, companiesLoaded: true }))
      }
    } catch (error) {
      console.error('Failed to load companies:', error)
    } finally {
      setLoadingCompanies(false)
    }
  }

  const loadPlantsOnDemand = async (companyCode: string) => {
    if (dropdownStates.plantsLoaded) return
    setLoadingPlants(true)
    try {
      const response = await fetch(`/api/erp-config/plants?companyCode=${companyCode}`)
      const data = await response.json()
      if (data.success) {
        setPlants(data.data)
        setDropdownStates(prev => ({ ...prev, plantsLoaded: true }))
      }
    } catch (error) {
      console.error('Failed to load plants:', error)
    } finally {
      setLoadingPlants(false)
    }
  }

  const loadStorageLocationsOnDemand = async (plantCode: string) => {
    if (dropdownStates.storageLocationsLoaded) return
    setLoadingLocations(true)
    try {
      const response = await fetch(`/api/erp-config/storage-locations?plantCode=${plantCode}`)
      const data = await response.json()
      if (data.success) {
        setStorageLocations(data.data)
        setDropdownStates(prev => ({ ...prev, storageLocationsLoaded: true }))
      }
    } catch (error) {
      console.error('Failed to load storage locations:', error)
    } finally {
      setLoadingLocations(false)
    }
  }

  const loadProjectsOnDemand = async (companyCode: string) => {
    if (dropdownStates.projectsLoaded) return
    setLoadingProjects(true)
    try {
      const response = await fetch(`/api/projects?companyCode=${companyCode}`)
      const data = await response.json()
      if (data.success) {
        setProjects(data.data || [])
        setDropdownStates(prev => ({ ...prev, projectsLoaded: true }))
      }
    } catch (error) {
      console.error('Failed to load projects:', error)
    } finally {
      setLoadingProjects(false)
    }
  }
  
  const loadCostCentersOnDemand = async (companyCode: string) => {
    if (dropdownStates.costCentersLoaded) return
    setLoadingCostCenters(true)
    try {
      const response = await fetch(`/api/cost-centers?companyCode=${companyCode}`)
      const data = await response.json()
      if (data.success) {
        setCostCenters(Array.isArray(data.data) ? data.data : [])
        setDropdownStates(prev => ({ ...prev, costCentersLoaded: true }))
      }
    } catch (error) {
      console.error('Failed to load cost centers:', error)
    } finally {
      setLoadingCostCenters(false)
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
      if (formData.storage_location) {
        params.append('storageLocation', formData.storage_location)
      } else if (formData.plant_code) {
        params.append('plantCode', formData.plant_code)
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
  
  const loadProjects = async (companyCode: string) => {
    setLoadingProjects(true)
    try {
      const response = await fetch(`/api/projects?companyCode=${companyCode}`)
      const data = await response.json()
      if (data.success) setProjects(data.data || [])
    } catch (error) {
      console.error('Failed to load projects:', error)
    } finally {
      setLoadingProjects(false)
    }
  }
  
  const loadWBSElements = async (projectCode: string) => {
    setLoadingWBS(true)
    setWbsElements([])
    setActivities([])
    try {
      const response = await fetch(`/api/wbs?projectCode=${projectCode}`)
      const data = await response.json()
      if (data.success) setWbsElements(Array.isArray(data.data) ? data.data : [])
    } catch (error) {
      console.error('Failed to load WBS elements:', error)
    } finally {
      setLoadingWBS(false)
    }
  }
  
  const loadActivities = async (wbsCode: string) => {
    setLoadingActivities(true)
    setActivities([])
    try {
      const response = await fetch(`/api/activities?wbsCode=${wbsCode}`)
      const data = await response.json()
      if (data.success) setActivities(Array.isArray(data.data) ? data.data : [])
    } catch (error) {
      console.error('Failed to load activities:', error)
    } finally {
      setLoadingActivities(false)
    }
  }
  
  const loadCostCenters = async (companyCode: string) => {
    setLoadingCostCenters(true)
    try {
      const response = await fetch(`/api/cost-centers?companyCode=${companyCode}`)
      const data = await response.json()
      if (data.success) setCostCenters(Array.isArray(data.data) ? data.data : [])
    } catch (error) {
      console.error('Failed to load cost centers:', error)
    } finally {
      setLoadingCostCenters(false)
    }
  }

  const loadTemplates = async () => {
    try {
      // Get tenant ID from localStorage
      const tenantId = localStorage.getItem('selectedTenant')
      if (!tenantId) {
        console.error('No tenant ID found for templates')
        return
      }

      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'x-tenant-id': tenantId
        },
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
      // Get tenant ID from localStorage
      const tenantId = localStorage.getItem('selectedTenant')
      if (!tenantId) {
        console.error('No tenant ID found')
        setRequests([])
        return
      }

      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'x-tenant-id': tenantId
        },
        body: JSON.stringify({
          category: 'materials',
          action: 'material-request-list',
          payload: { 
            request_type: 'MATERIAL_REQ',
            ...(filters.priority && { priority: filters.priority }),
            ...(filters.status && { status: filters.status })
          }
        })
      })
      const data = await response.json()
      if (data.success) {
        let filteredRequests = data.data || []
        
        // Client-side filtering
        if (filters.entryDateFrom) {
          filteredRequests = filteredRequests.filter(r => 
            new Date(r.created_at) >= new Date(filters.entryDateFrom)
          )
        }
        if (filters.entryDateTo) {
          filteredRequests = filteredRequests.filter(r => 
            new Date(r.created_at) <= new Date(filters.entryDateTo)
          )
        }
        if (filters.requiredDate) {
          filteredRequests = filteredRequests.filter(r => 
            r.required_date === filters.requiredDate
          )
        }
        if (filters.material) {
          filteredRequests = filteredRequests.filter(r => 
            r.request_number?.toLowerCase().includes(filters.material.toLowerCase())
          )
        }
        
        setRequests(filteredRequests)
      }
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
      // Get tenant ID from localStorage
      const tenantId = localStorage.getItem('selectedTenant')
      if (!tenantId) {
        alert('No tenant selected. Please log out and log back in.')
        return
      }

      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'x-tenant-id': tenantId
        },
        body: JSON.stringify({
          category: 'materials',
          action: 'unified-material-request',
          payload: {
            request_type: 'MATERIAL_REQ',
            priority: formData.priority,
            required_date: formData.required_date,
            company_code: formData.company_code,
            plant_code: formData.plant_code,
            storage_location: formData.storage_location,
            project_code: formData.project_code,
            wbs_element: formData.wbs_element,
            activity_code: formData.activity_code,
            cost_center: formData.cost_center,
            order_number: formData.order_number,
            purpose: formData.purpose,
            justification: formData.justification,
            notes: formData.notes,
            items: formData.items
          }
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
      company_code: '',
      plant_code: '',
      storage_location: '',
      account_assignment: '',
      project_code: '',
      wbs_element: '',
      activity_code: '',
      cost_center: '',
      order_number: '',
      purpose: '',
      justification: '',
      notes: '',
      items: [{ line_number: 1, material_code: '', material_name: '', requested_quantity: 0, base_uom: 'PCS', available_stock: 0 }]
    })
    setEditingRequest(null)
    // Reset dropdown states
    setDropdownStates({
      companiesLoaded: false,
      plantsLoaded: false,
      storageLocationsLoaded: false,
      projectsLoaded: false,
      wbsElementsLoaded: false,
      activitiesLoaded: false,
      costCentersLoaded: false
    })
  }

  const handleView = async (request) => {
    try {
      setLoading(true)
      // Get tenant ID from localStorage
      const tenantId = localStorage.getItem('selectedTenant')
      if (!tenantId) {
        alert('No tenant selected. Please log out and log back in.')
        return
      }

      // Fetch full request details including line items, WBS, etc.
      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'x-tenant-id': tenantId
        },
        body: JSON.stringify({
          category: 'materials',
          action: 'get-material-request',
          payload: { id: request.id }
        })
      })
      const data = await response.json()
      
      // Debug: Log the response
      console.log('Material Request API Response:', {
        success: data.success,
        hasData: !!data.data,
        requestData: data.data ? {
          id: data.data.id,
          request_number: data.data.request_number,
          company_code: data.data.company_code,
          plant_code: data.data.plant_code,
          project_code: data.data.project_code,
          cost_center: data.data.cost_center,
          wbs_element: data.data.wbs_element,
          storage_location: data.data.storage_location,
          activity_code: data.data.activity_code,
          company_display: data.data.company_display,
          plant_display: data.data.plant_display,
          project_display: data.data.project_display,
          cost_center_display: data.data.cost_center_display,
          wbs_display: data.data.wbs_display,
          storage_location_display: data.data.storage_location_display,
          activity_display: data.data.activity_display,
          itemsCount: data.data.items?.length || 0
        } : null,
        error: data.error
      })
      
      if (data.success) {
        setViewingRequest(data.data)
      } else {
        alert('Error loading request details: ' + data.error)
      }
    } catch (error) {
      console.error('Error fetching request details:', error)
      alert('Error loading request details: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const handleEdit = async (request) => {
    setSelectedRequestId(request.id)
    setProductionFormMode('edit')
    setShowProductionForm(true)
  }

  const handleDelete = async (requestId) => {
    if (!confirm('Are you sure you want to delete this request?')) return
    
    try {
      // Get tenant ID from localStorage
      const tenantId = localStorage.getItem('selectedTenant')
      if (!tenantId) {
        alert('No tenant selected. Please log out and log back in.')
        return
      }

      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'x-tenant-id': tenantId
        },
        body: JSON.stringify({
          category: 'materials',
          action: 'delete-material-request',
          payload: { id: requestId }
        })
      })
      const data = await response.json()
      if (data.success) {
        alert('Request deleted successfully')
        loadRequests()
      } else {
        alert('Error: ' + data.error)
      }
    } catch (error) {
      alert('Error: ' + error.message)
    }
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
      {/* Production Form Modal */}
      {showProductionForm && (
        <ProductionMaterialRequestForm
          mode={productionFormMode}
          requestId={selectedRequestId}
          projectCode={formData.project_code || 'HW-0001'}
          onClose={() => {
            setShowProductionForm(false)
            setSelectedRequestId(undefined)
          }}
          onSave={(request) => {
            console.log('Request saved:', request)
            setShowProductionForm(false)
            setSelectedRequestId(undefined)
            if (activeTab === 'list') {
              loadRequests()
            }
          }}
        />
      )}
      
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
                          value={formData.company_code}
                          onFocus={() => loadCompaniesOnDemand()}
                          onChange={(e) => {
                            setFormData(prev => ({ ...prev, company_code: e.target.value, plant_code: '', storage_location: '' }))
                            // Reset dependent dropdowns when company changes
                            setDropdownStates(prev => ({ ...prev, plantsLoaded: false, storageLocationsLoaded: false, projectsLoaded: false, costCentersLoaded: false }))
                            // Clear dependent data
                            setPlants([])
                            setStorageLocations([])
                            setProjects([])
                            setCostCenters([])
                          }}
                        >
                          <option value="">Select Company</option>
                          {companies.map(c => (
                            <option key={c.id} value={c.company_code}>
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
                        {!formData.company_code && <span className="text-xs text-gray-500 ml-1">(Select company first)</span>}
                      </label>
                      <div className="relative">
                        <select
                          required
                          disabled={!formData.company_code || loadingPlants}
                          className="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-50 disabled:text-gray-500 transition-all"
                          value={formData.plant_code}
                          onFocus={() => formData.company_code && loadPlantsOnDemand(formData.company_code)}
                          onChange={(e) => {
                            setFormData(prev => ({ ...prev, plant_code: e.target.value, storage_location: '' }))
                            setDropdownStates(prev => ({ ...prev, storageLocationsLoaded: false }))
                          }}
                        >
                          <option value="">{loadingPlants ? 'Loading...' : 'Select Plant'}</option>
                          {plants.map(p => (
                            <option key={p.id} value={p.plant_code}>
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
                        {!formData.plant_code && <span className="text-xs text-gray-500 ml-1">(Select plant first)</span>}
                      </label>
                      <div className="relative">
                        <select
                          disabled={!formData.plant_code || loadingLocations}
                          className="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-50 disabled:text-gray-500 transition-all"
                          value={formData.storage_location}
                          onFocus={() => formData.plant_code && loadStorageLocationsOnDemand(formData.plant_code)}
                          onChange={(e) => setFormData(prev => ({ ...prev, storage_location: e.target.value }))}
                        >
                          <option value="">{loadingLocations ? 'Loading...' : 'Select Storage Location'}</option>
                          {storageLocations.map(sl => (
                            <option key={sl.id} value={sl.sloc_code}>
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
                          project_code: '',
                          wbs_element: '',
                          activity_code: '',
                          cost_center: '',
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
                            value={formData.project_code}
                            onFocus={() => formData.company_code && loadProjectsOnDemand(formData.company_code)}
                            onChange={(e) => setFormData(prev => ({ ...prev, project_code: e.target.value, wbs_element: '', activity_code: '' }))}
                          >
                            <option value="">{loadingProjects ? 'Loading...' : 'Select Project'}</option>
                            {projects.map(p => (
                              <option key={p.id} value={p.project_code}>
                                {p.project_code} - {p.name}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-2">
                            WBS Element
                            {!formData.project_code && <span className="text-xs text-gray-500 ml-1">(Select project first)</span>}
                          </label>
                          <select
                            disabled={!formData.project_code || loadingWBS}
                            className="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:ring-2 focus:ring-orange-500 focus:border-orange-500 disabled:bg-gray-50 transition-all"
                            value={formData.wbs_element}
                            onChange={(e) => setFormData(prev => ({ ...prev, wbs_element: e.target.value, activity_code: '' }))}
                          >
                            <option value="">{loadingWBS ? 'Loading...' : 'Select WBS (Optional)'}</option>
                            {Array.isArray(wbsElements) && wbsElements.map(w => (
                              <option key={w.id} value={w.code}>
                                {w.code} - {w.name}
                              </option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-gray-700 mb-2">
                            Activity
                            {!formData.wbs_element && <span className="text-xs text-gray-500 ml-1">(Select WBS first)</span>}
                          </label>
                          <select
                            disabled={!formData.wbs_element || loadingActivities}
                            className="w-full border border-gray-300 rounded-lg px-3 py-2.5 focus:ring-2 focus:ring-orange-500 focus:border-orange-500 disabled:bg-gray-50 transition-all"
                            value={formData.activity_code}
                            onChange={(e) => setFormData(prev => ({ ...prev, activity_code: e.target.value }))}
                          >
                            <option value="">{loadingActivities ? 'Loading...' : 'Select Activity (Optional)'}</option>
                            {Array.isArray(activities) && activities.map(a => (
                              <option key={a.id} value={a.code}>
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
                          value={formData.cost_center}
                          onFocus={() => formData.company_code && loadCostCentersOnDemand(formData.company_code)}
                          onChange={(e) => setFormData(prev => ({ ...prev, cost_center: e.target.value }))}
                        >
                          <option value="">{loadingCostCenters ? 'Loading...' : 'Select Cost Center'}</option>
                          {costCenters.map(cc => (
                            <option key={cc.id} value={cc.cost_center_code}>
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
                    disabled={!formData.plant_code}
                    className="bg-green-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all flex items-center shadow-sm"
                  >
                    <Icons.Plus className="w-4 h-4 mr-1" />
                    Add Item
                  </button>
                </div>
                
                {!formData.plant_code && (
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
                              disabled={!formData.plant_code}
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

          {/* View Modal */}
          {viewingRequest && (
            <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
              <div className="bg-white rounded-lg shadow-xl max-w-4xl w-full max-h-[90vh] overflow-y-auto m-4">
                <div className="sticky top-0 bg-white border-b px-6 py-4 flex justify-between items-center">
                  <h2 className="text-xl font-semibold">Request Details - {viewingRequest.request_number}</h2>
                  <button onClick={() => setViewingRequest(null)} className="text-gray-500 hover:text-gray-700">
                    <Icons.X className="w-6 h-6" />
                  </button>
                </div>
                <div className="p-6 space-y-6">
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="text-sm font-medium text-gray-500">Request Number</label>
                      <p className="mt-1 text-sm font-semibold">{viewingRequest.request_number}</p>
                    </div>
                    <div>
                      <label className="text-sm font-medium text-gray-500">Request Type</label>
                      <p className="mt-1 text-sm">{viewingRequest.request_type}</p>
                    </div>
                    <div>
                      <label className="text-sm font-medium text-gray-500">Status</label>
                      <p className="mt-1">
                        <span className={`inline-flex px-3 py-1 text-sm font-semibold rounded-full ${getStatusColor(viewingRequest.status)}`}>
                          {viewingRequest.status}
                        </span>
                      </p>
                    </div>
                    <div>
                      <label className="text-sm font-medium text-gray-500">Priority</label>
                      <p className="mt-1">
                        <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-${priorities.find(p => p.code === viewingRequest.priority)?.color}-100 text-${priorities.find(p => p.code === viewingRequest.priority)?.color}-800`}>
                          {viewingRequest.priority}
                        </span>
                      </p>
                    </div>
                    <div>
                      <label className="text-sm font-medium text-gray-500">Entry Date</label>
                      <p className="mt-1 text-sm">{new Date(viewingRequest.created_at).toLocaleDateString()}</p>
                    </div>
                    <div>
                      <label className="text-sm font-medium text-gray-500">Required Date</label>
                      <p className="mt-1 text-sm">{viewingRequest.required_date}</p>
                    </div>
                    <div>
                      <label className="text-sm font-medium text-gray-500">Company</label>
                      <p className="mt-1 text-sm">{viewingRequest.company_display || '-'}</p>
                    </div>
                    <div>
                      <label className="text-sm font-medium text-gray-500">Plant</label>
                      <p className="mt-1 text-sm">{viewingRequest.plant_display || '-'}</p>
                    </div>
                    <div>
                      <label className="text-sm font-medium text-gray-500">Storage Location</label>
                      <p className="mt-1 text-sm">{viewingRequest.storage_location_display || '-'}</p>
                    </div>
                    <div>
                      <label className="text-sm font-medium text-gray-500">Project</label>
                      <p className="mt-1 text-sm">{viewingRequest.project_display || '-'}</p>
                    </div>
                    <div>
                      <label className="text-sm font-medium text-gray-500">Cost Center</label>
                      <p className="mt-1 text-sm">{viewingRequest.cost_center_display || '-'}</p>
                    </div>
                    <div>
                      <label className="text-sm font-medium text-gray-500">WBS Element</label>
                      <p className="mt-1 text-sm">{viewingRequest.wbs_display || '-'}</p>
                    </div>
                    <div>
                      <label className="text-sm font-medium text-gray-500">Activity</label>
                      <p className="mt-1 text-sm">{viewingRequest.activity_display || '-'}</p>
                    </div>
                    <div>
                      <label className="text-sm font-medium text-gray-500">Requested By</label>
                      <p className="mt-1 text-sm">{viewingRequest.requested_by_display || '-'}</p>
                    </div>
                    <div className="col-span-2">
                      <label className="text-sm font-medium text-gray-500">Purpose</label>
                      <p className="mt-1 text-sm">{viewingRequest.purpose || '-'}</p>
                    </div>
                    <div className="col-span-2">
                      <label className="text-sm font-medium text-gray-500">Justification</label>
                      <p className="mt-1 text-sm">{viewingRequest.justification || '-'}</p>
                    </div>
                    <div className="col-span-2">
                      <label className="text-sm font-medium text-gray-500">Notes</label>
                      <p className="mt-1 text-sm">{viewingRequest.notes || '-'}</p>
                    </div>
                  </div>
                  <div>
                    <h3 className="font-semibold text-lg mb-3 flex items-center">
                      <Icons.Package className="w-5 h-5 mr-2" />
                      Material Items ({(viewingRequest.items || []).length})
                    </h3>
                    <div className="border rounded-lg overflow-hidden">
                      <table className="min-w-full divide-y divide-gray-200">
                        <thead className="bg-gray-50">
                          <tr>
                            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">#</th>
                            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Material Code</th>
                            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Material Name</th>
                            <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Quantity</th>
                            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">UOM</th>
                          </tr>
                        </thead>
                        <tbody className="bg-white divide-y divide-gray-200">
                          {(viewingRequest.items || []).length === 0 ? (
                            <tr>
                              <td colSpan={5} className="px-4 py-8 text-center text-sm text-gray-500">
                                No items found
                              </td>
                            </tr>
                          ) : (
                            (viewingRequest.items || []).map((item, idx) => (
                              <tr key={idx} className="hover:bg-gray-50">
                                <td className="px-4 py-3 text-sm text-gray-500">{item.line_number || idx + 1}</td>
                                <td className="px-4 py-3 text-sm font-medium text-gray-900">{item.material_code}</td>
                                <td className="px-4 py-3 text-sm text-gray-600">{item.material_name || '-'}</td>
                                <td className="px-4 py-3 text-sm text-right font-semibold text-gray-900">{item.requested_quantity}</td>
                                <td className="px-4 py-3 text-sm text-gray-600">{item.base_uom}</td>
                              </tr>
                            ))
                          )}
                        </tbody>
                      </table>
                    </div>
                  </div>
                </div>
                <div className="border-t px-6 py-4 flex justify-end">
                  <button 
                    onClick={() => setViewingRequest(null)}
                    className="bg-gray-500 text-white px-4 py-2 rounded hover:bg-gray-600"
                  >
                    Close
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* List Tab */}
          {activeTab === 'list' && (
            <div className="space-y-4">
              {/* Filters */}
              <div className="bg-gray-50 border border-gray-200 rounded-lg p-4">
                <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                  <div>
                    <label className="block text-xs font-medium text-gray-700 mb-1">Entry Date From</label>
                    <input 
                      type="date" 
                      className="w-full border rounded px-3 py-2 text-sm"
                      value={filters.entryDateFrom}
                      onChange={(e) => setFilters({...filters, entryDateFrom: e.target.value})}
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-gray-700 mb-1">Entry Date To</label>
                    <input 
                      type="date" 
                      className="w-full border rounded px-3 py-2 text-sm"
                      value={filters.entryDateTo}
                      onChange={(e) => setFilters({...filters, entryDateTo: e.target.value})}
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-gray-700 mb-1">Required Date</label>
                    <input 
                      type="date" 
                      className="w-full border rounded px-3 py-2 text-sm"
                      value={filters.requiredDate}
                      onChange={(e) => setFilters({...filters, requiredDate: e.target.value})}
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-gray-700 mb-1">Material</label>
                    <input 
                      type="text" 
                      placeholder="Search material..." 
                      className="w-full border rounded px-3 py-2 text-sm"
                      value={filters.material}
                      onChange={(e) => setFilters({...filters, material: e.target.value})}
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-gray-700 mb-1">Priority</label>
                    <select 
                      className="w-full border rounded px-3 py-2 text-sm"
                      value={filters.priority}
                      onChange={(e) => setFilters({...filters, priority: e.target.value})}
                    >
                      <option value="">All Priorities</option>
                      {priorities.map(p => (
                        <option key={p.code} value={p.code}>{p.name}</option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-gray-700 mb-1">Status</label>
                    <select 
                      className="w-full border rounded px-3 py-2 text-sm"
                      value={filters.status}
                      onChange={(e) => setFilters({...filters, status: e.target.value})}
                    >
                      <option value="">All Statuses</option>
                      <option value="DRAFT">Draft</option>
                      <option value="SUBMITTED">Submitted</option>
                      <option value="APPROVED">Approved</option>
                      <option value="REJECTED">Rejected</option>
                      <option value="FULFILLED">Fulfilled</option>
                    </select>
                  </div>
                  <div className="flex items-end gap-2">
                    <button 
                      onClick={loadRequests}
                      className="bg-blue-600 text-white px-4 py-2 rounded text-sm hover:bg-blue-700"
                    >
                      <Icons.Search className="w-4 h-4 inline mr-1" />
                      Filter
                    </button>
                    <button 
                      onClick={() => {
                        setFilters({
                          entryDateFrom: '',
                          entryDateTo: '',
                          requiredDate: '',
                          material: '',
                          priority: '',
                          status: ''
                        })
                        loadRequests()
                      }}
                      className="bg-gray-500 text-white px-4 py-2 rounded text-sm hover:bg-gray-600"
                    >
                      Clear
                    </button>
                  </div>
                </div>
              </div>
              
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Request #</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Entry Date</th>
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
                        <td className="px-4 py-4 text-sm text-gray-900">{new Date(request.created_at).toLocaleDateString()}</td>
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
                          <div className="flex justify-center gap-2">
                            <button 
                              onClick={() => handleView(request)}
                              className="bg-blue-100 text-blue-700 px-2 py-1 rounded text-xs hover:bg-blue-200"
                            >
                              View
                            </button>
                            {(request.status === 'DRAFT' || request.status === 'SUBMITTED') && (
                              <>
                                <button 
                                  onClick={() => handleEdit(request)}
                                  className="bg-green-100 text-green-700 px-2 py-1 rounded text-xs hover:bg-green-200"
                                >
                                  Change
                                </button>
                                <button 
                                  onClick={() => handleDelete(request.id)}
                                  className="bg-red-100 text-red-700 px-2 py-1 rounded text-xs hover:bg-red-200"
                                >
                                  Delete
                                </button>
                              </>
                            )}
                          </div>
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