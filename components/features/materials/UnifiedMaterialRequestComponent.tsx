import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'
import { MaterialRequestFormData, MaterialRequestItem, validateMaterialRequestData } from '@/types/forms'
import { MaterialRequest } from '@/types/database'

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

export default function UnifiedMaterialRequest() {
  const [activeTab, setActiveTab] = useState('create')
  const [saving, setSaving] = useState(false)
  
  // Form state management
  const [formState, setFormState] = useState({
    status: 'DRAFT' as 'DRAFT' | 'SUBMITTED' | 'APPROVED' | 'REJECTED',
    isSubmitted: false,
    submittedAt: null as string | null,
    isReadOnly: false
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
  const [loadingWbsElements, setLoadingWbsElements] = useState(false)
  const [loadingActivities, setLoadingActivities] = useState(false)
  
  // Cost assignment dropdowns
  const [projects, setProjects] = useState<any[]>([])
  const [wbsElements, setWbsElements] = useState<any[]>([])
  const [activities, setActivities] = useState<any[]>([])
  const [costCenters, setCostCenters] = useState<any[]>([])

  const [formData, setFormData] = useState<MaterialRequestFormData>({
    request_number: '', // Will be generated after submission
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
    items: [{ 
      line_number: 1, 
      material_code: '', 
      material_name: '', 
      requested_quantity: 0, 
      base_uom: 'PCS', 
      available_stock: 0,
      priority: 'MEDIUM',
      required_date: ''
    }]
  })

  const priorities = [
    { code: 'LOW', name: 'Low', color: 'bg-gray-100 text-gray-800' },
    { code: 'MEDIUM', name: 'Medium', color: 'bg-yellow-100 text-yellow-800' },
    { code: 'HIGH', name: 'High', color: 'bg-orange-100 text-orange-800' },
    { code: 'URGENT', name: 'Urgent', color: 'bg-red-100 text-red-800' }
  ]
  
  const accountAssignmentTypes = [
    { code: 'P', name: 'Project', icon: Icons.Briefcase },
    { code: 'K', name: 'Others', icon: Icons.Building },
    { code: 'M', name: 'Maintenance Order', icon: Icons.Wrench },
    { code: 'F', name: 'Production Order', icon: Icons.Factory }
  ]

  useEffect(() => {
    loadProjectsOnDemand()
  }, [])

  useEffect(() => {
    if (formData.project_code) {
      // Load WBS elements for the selected project (WBS elements contain company codes)
      loadWbsElementsOnDemand(formData.project_code)
      // Reset dependent fields since company code comes from WBS selection
      setFormData(prev => ({ 
        ...prev, 
        plant_code: '', 
        storage_location: '', 
        wbs_element: '', 
        activity_code: '' 
      }))
      setPlants([])
      setStorageLocations([])
      setActivities([])
    } else {
      setWbsElements([])
      setActivities([])
    }
  }, [formData.project_code, projects])

  useEffect(() => {
    if (formData.company_code) {
      loadPlantsOnDemand(formData.company_code)
      loadCostCentersOnDemand(formData.company_code)
    } else {
      setPlants([])
      setStorageLocations([])
    }
  }, [formData.company_code])

  useEffect(() => {
    if (formData.wbs_element) {
      // Find selected WBS element and auto-populate company code
      const selectedWbs = wbsElements.find(w => w.id === formData.wbs_element)
      if (selectedWbs && selectedWbs.company_code && selectedWbs.company_code !== formData.company_code) {
        setFormData(prev => ({ 
          ...prev, 
          company_code: selectedWbs.company_code,
          plant_code: '',
          storage_location: ''
        }))
        setPlants([])
        setStorageLocations([])
      }
      
      // Load activities for the selected WBS element
      loadActivitiesOnDemand(formData.project_code, formData.wbs_element)
    } else {
      setActivities([])
      // Clear company code if no WBS selected
      if (formData.company_code) {
        setFormData(prev => ({ 
          ...prev, 
          company_code: '',
          plant_code: '',
          storage_location: ''
        }))
        setPlants([])
        setStorageLocations([])
      }
    }
  }, [formData.wbs_element, wbsElements, formData.project_code])

  useEffect(() => {
    const timer = setTimeout(() => {
      if (materialSearch.length >= 2 && formData.plant_code) searchMaterials()
    }, 300)
    return () => clearTimeout(timer)
  }, [materialSearch, formData.plant_code])

  const loadWbsElementsOnDemand = async (projectCode: string) => {
    console.log('Loading WBS elements for project:', projectCode)
    setLoadingWbsElements(true)
    try {
      const response = await fetch(`/api/wbs?projectCode=${projectCode}`)
      console.log('WBS API response status:', response.status)
      if (!response.ok) {
        console.warn('WBS elements API not available')
        setWbsElements([])
        return
      }
      const data = await response.json()
      console.log('WBS API response data:', data)
      if (data.success) {
        setWbsElements(data.data || [])
        console.log('WBS elements loaded:', data.data?.length || 0)
      }
    } catch (error) {
      console.error('Failed to load WBS elements:', error)
      setWbsElements([])
    } finally {
      setLoadingWbsElements(false)
    }
  }

  const loadActivitiesOnDemand = async (projectCode: string, wbsElementId: string) => {
    setLoadingActivities(true)
    try {
      // Find the WBS element to get its code
      const selectedWbs = wbsElements.find(w => w.id === wbsElementId)
      if (!selectedWbs) {
        console.warn('WBS element not found for activities')
        setActivities([])
        return
      }
      
      const response = await fetch(`/api/activities?projectCode=${projectCode}&wbsElement=${selectedWbs.code}`)
      if (!response.ok) {
        console.warn('Activities API not available')
        setActivities([])
        return
      }
      const data = await response.json()
      if (data.success) {
        setActivities(data.data || [])
      }
    } catch (error) {
      console.error('Failed to load activities:', error)
      setActivities([])
    } finally {
      setLoadingActivities(false)
    }
  }

  const loadCompaniesOnDemand = async () => {
    setLoadingCompanies(true)
    try {
      const response = await fetch('/api/erp-config/companies')
      if (!response.ok) {
        console.warn('Companies API not available')
        setCompanies([])
        return
      }
      const data = await response.json()
      if (data.success) {
        setCompanies(data.data)
      }
    } catch (error) {
      console.error('Failed to load companies:', error)
      setCompanies([])
    } finally {
      setLoadingCompanies(false)
    }
  }

  const loadPlantsOnDemand = async (companyCode: string) => {
    setLoadingPlants(true)
    try {
      const response = await fetch(`/api/erp-config/plants?companyCode=${companyCode}`)
      if (!response.ok) {
        console.warn('Plants API not available')
        setPlants([])
        return
      }
      const data = await response.json()
      if (data.success) {
        setPlants(data.data)
      }
    } catch (error) {
      console.error('Failed to load plants:', error)
      setPlants([])
    } finally {
      setLoadingPlants(false)
    }
  }

  const loadStorageLocationsOnDemand = async (plantCode: string) => {
    setLoadingLocations(true)
    try {
      const response = await fetch(`/api/erp-config/storage-locations?plantCode=${plantCode}&active=true`)
      if (!response.ok) {
        console.warn('Storage locations API not available')
        setStorageLocations([])
        return
      }
      const data = await response.json()
      if (data.success) {
        setStorageLocations(data.data)
      }
    } catch (error) {
      console.error('Failed to load storage locations:', error)
      setStorageLocations([])
    } finally {
      setLoadingLocations(false)
    }
  }

  const loadProjectsOnDemand = async () => {
    setLoadingProjects(true)
    try {
      const response = await fetch('/api/projects')
      if (!response.ok) {
        console.warn('Projects API not available')
        setProjects([])
        return
      }
      const data = await response.json()
      if (data.success) {
        setProjects(data.data || [])
      }
    } catch (error) {
      console.error('Failed to load projects:', error)
      setProjects([])
    } finally {
      setLoadingProjects(false)
    }
  }

  const loadCostCentersOnDemand = async (companyCode: string) => {
    try {
      const response = await fetch(`/api/cost-centers?companyCode=${companyCode}`)
      if (!response.ok) {
        console.warn('Cost centers API not available')
        setCostCenters([])
        return
      }
      const data = await response.json()
      if (data.success) {
        setCostCenters(data.data || [])
      }
    } catch (error) {
      console.error('Failed to load cost centers:', error)
      setCostCenters([])
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
      
      if (formData.storage_location) {
        params.append('storageLocation', formData.storage_location)
      } else if (formData.plant_code) {
        params.append('plantCode', formData.plant_code)
      }
      
      const response = await fetch(`/api/materials?${params}`)
      if (!response.ok) {
        console.warn('Materials API not available')
        setMaterials([])
        return
      }
      const data = await response.json()
      if (data.success) setMaterials(data.data)
    } catch (error) {
      console.error('Failed to search materials:', error)
      setMaterials([])
    } finally {
      setSearchingMaterials(false)
    }
  }

  const handleFormChange = (field: string, value: any) => {
    setFormData(prev => ({ ...prev, [field]: value }))
    
    if (field === 'plant_code') {
      setFormData(prev => ({ ...prev, storage_location: '' }))
      setStorageLocations([])
      if (value) loadStorageLocationsOnDemand(value)
    }
    
    if (field === 'wbs_element') {
      setFormData(prev => ({ ...prev, activity_code: '' }))
      setActivities([])
      // Company code will be set by useEffect when WBS element changes
    }
  }

  const addMaterialItem = () => {
    const newItem: MaterialRequestItem = {
      line_number: formData.items.length + 1,
      material_code: '',
      material_name: '',
      requested_quantity: 0,
      base_uom: 'PCS',
      available_stock: 0,
      priority: 'MEDIUM',
      required_date: ''
    }
    setFormData(prev => ({ ...prev, items: [...prev.items, newItem] }))
  }

  const removeMaterialItem = (index: number) => {
    if (formData.items.length > 1) {
      setFormData(prev => ({
        ...prev,
        items: prev.items.filter((_, i) => i !== index)
      }))
    }
  }

  const updateMaterialItem = (index: number, field: string, value: any) => {
    setFormData(prev => ({
      ...prev,
      items: prev.items.map((item, i) => 
        i === index ? { ...item, [field]: value } : item
      )
    }))
  }

  const selectMaterial = (index: number, material: Material) => {
    const stockData = material.material_storage_data?.[0]
    updateMaterialItem(index, 'material_code', material.material_code)
    updateMaterialItem(index, 'material_name', material.material_name)
    updateMaterialItem(index, 'base_uom', material.base_uom)
    updateMaterialItem(index, 'available_stock', stockData?.available_stock || 0)
    setActiveSearchIndex(null)
    setMaterialSearch('')
  }

  const handleSaveDraft = async () => {
    setSaving(true)
    try {
      const response = await fetch('/api/material-requests', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ...formData, status: 'draft' })
      })
      
      const data = await response.json()
      if (data.success) {
        alert('Draft saved successfully!')
      } else {
        alert('Failed to save draft: ' + data.message)
      }
    } catch (error) {
      console.error('Save draft error:', error)
      alert('Failed to save draft')
    } finally {
      setSaving(false)
    }
  }

  const handlePreview = () => {
    const validation = validateMaterialRequestData(formData)
    if (!validation.isValid) {
      alert('Please fix validation errors before preview: ' + (validation.errors?.join(', ') || 'Unknown validation errors'))
      return
    }
    
    // Open preview in new window
    const previewWindow = window.open('', '_blank', 'width=800,height=600')
    if (previewWindow) {
      previewWindow.document.write(`
        <!DOCTYPE html>
        <html>
          <head>
            <title>Material Request Preview</title>
            <style>
              body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
              .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
              .header { text-align: center; border-bottom: 2px solid #2563eb; padding-bottom: 20px; margin-bottom: 30px; }
              .title { font-size: 24px; font-weight: bold; color: #1e40af; margin-bottom: 10px; }
              .subtitle { color: #64748b; font-size: 14px; }
              .section { margin-bottom: 25px; }
              .section-title { font-size: 16px; font-weight: bold; color: #374151; margin-bottom: 15px; padding-bottom: 5px; border-bottom: 1px solid #e5e7eb; }
              .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 20px; }
              .info-item { display: flex; }
              .info-label { font-weight: bold; color: #4b5563; min-width: 140px; }
              .info-value { color: #111827; }
              .items-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
              .items-table th, .items-table td { padding: 12px; text-align: left; border-bottom: 1px solid #e5e7eb; }
              .items-table th { background-color: #f8fafc; font-weight: bold; color: #374151; }
              .items-table tr:hover { background-color: #f8fafc; }
              .priority { padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; }
              .priority-low { background: #f3f4f6; color: #6b7280; }
              .priority-medium { background: #fef3c7; color: #d97706; }
              .priority-high { background: #fed7aa; color: #ea580c; }
              .priority-urgent { background: #fecaca; color: #dc2626; }
              .print-btn { background: #2563eb; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; margin-top: 20px; }
              .print-btn:hover { background: #1d4ed8; }
              @media print { .print-btn { display: none; } }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">
                <div class="title">Material Request Preview</div>
                <div class="subtitle">${formData.request_number ? `MR Number: ${formData.request_number} | ` : ''}Generated on ${new Date().toLocaleDateString()}</div>
              </div>
              
              <div class="section">
                <div class="section-title">Request Information</div>
                <div class="info-grid">
                  <div class="info-item">
                    <span class="info-label">Project:</span>
                    <span class="info-value">${formData.project_code || 'Not specified'}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Account Assignment:</span>
                    <span class="info-value">${formData.account_assignment || 'Not specified'}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">WBS Element:</span>
                    <span class="info-value">${formData.wbs_element || 'Not specified'}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Activity Code:</span>
                    <span class="info-value">${formData.activity_code || 'Not specified'}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Company Code:</span>
                    <span class="info-value">${formData.company_code || 'Not specified'}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Plant Code:</span>
                    <span class="info-value">${formData.plant_code || 'Not specified'}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Receiving Location:</span>
                    <span class="info-value">${formData.storage_location || 'Not specified'}</span>
                  </div>
                  <div class="info-item">
                    <span class="info-label">Cost Center:</span>
                    <span class="info-value">${formData.cost_center || 'Not specified'}</span>
                  </div>
                </div>
              </div>
              
              ${formData.purpose || formData.justification || formData.notes ? `
              <div class="section">
                <div class="section-title">Additional Information</div>
                ${formData.purpose ? `<div class="info-item"><span class="info-label">Purpose:</span><span class="info-value">${formData.purpose}</span></div>` : ''}
                ${formData.justification ? `<div class="info-item"><span class="info-label">Justification:</span><span class="info-value">${formData.justification}</span></div>` : ''}
                ${formData.notes ? `<div class="info-item"><span class="info-label">Notes:</span><span class="info-value">${formData.notes}</span></div>` : ''}
              </div>
              ` : ''}
              
              <div class="section">
                <div class="section-title">Material Items (${formData.items.length})</div>
                <table class="items-table">
                  <thead>
                    <tr>
                      <th>#</th>
                      <th>Material Code</th>
                      <th>Material Name</th>
                      <th>Quantity</th>
                      <th>Unit</th>
                      <th>Priority</th>
                      <th>Required Date</th>
                      <th>Available Stock</th>
                    </tr>
                  </thead>
                  <tbody>
                    ${formData.items.map((item, i) => `
                      <tr>
                        <td>${i + 1}</td>
                        <td>${item.material_code || 'Not specified'}</td>
                        <td>${item.material_name || 'Not specified'}</td>
                        <td>${item.requested_quantity || 0}</td>
                        <td>${item.base_uom || 'PCS'}</td>
                        <td><span class="priority priority-${item.priority?.toLowerCase() || 'medium'}">${item.priority || 'MEDIUM'}</span></td>
                        <td>${item.required_date || 'Not specified'}</td>
                        <td>${item.available_stock || 0} ${item.base_uom || 'PCS'}</td>
                      </tr>
                    `).join('')}
                  </tbody>
                </table>
              </div>
              
              <button class="print-btn" onclick="window.print()">Print Preview</button>
            </div>
          </body>
        </html>
      `)
      previewWindow.document.close()
    }
  }

  const createNewRequest = () => {
    // Reset form to initial state
    setFormData({
      request_number: '',
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
      items: [{ 
        line_number: 1, 
        material_code: '', 
        material_name: '', 
        requested_quantity: 0, 
        base_uom: 'PCS', 
        available_stock: 0,
        priority: 'MEDIUM',
        required_date: ''
      }]
    })
    
    // Reset form state
    setFormState({
      status: 'DRAFT',
      isSubmitted: false,
      submittedAt: null,
      isReadOnly: false
    })
    
    // Clear dependent dropdowns
    setWbsElements([])
    setActivities([])
    setPlants([])
    setStorageLocations([])
  }

  const handleSubmit = async () => {
    const validation = validateMaterialRequestData(formData)
    if (!validation.isValid) {
      alert('Please fix validation errors: ' + (validation.errors?.join(', ') || 'Unknown validation errors'))
      return
    }

    setSaving(true)
    try {
      const response = await fetch('/api/material-requests', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      })
      
      const data = await response.json()
      if (data.success) {
        // Update form data with the generated MR number
        if (data.data?.request_number) {
          setFormData(prev => ({ ...prev, request_number: data.data.request_number }))
        }
        
        // Update form state to submitted
        setFormState({
          status: 'SUBMITTED',
          isSubmitted: true,
          submittedAt: new Date().toISOString(),
          isReadOnly: true
        })
        
        alert('Material request submitted successfully! MR Number: ' + (data.data?.request_number || 'Generated'))
      } else {
        alert('Failed to submit request: ' + data.message)
      }
    } catch (error) {
      console.error('Submit error:', error)
      alert('Failed to submit request')
    } finally {
      setSaving(false)
    }
  }

  const getLocationIcon = (category: string) => {
    const icons = {
      'WAREHOUSE': '🏭',
      'SITE': '🏗️',
      'OFFICE': '🏢',
      'YARD': '🏞️',
      'VEHICLE': '🚛',
      'TEMPORARY': '⛺'
    }
    return icons[category as keyof typeof icons] || '📍'
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Main Card */}
        <div className="bg-white rounded-lg shadow-lg border-0 overflow-hidden">
          <div className="p-8 space-y-8">
            {/* Requested for */}
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-2 text-lg font-semibold text-slate-800">
                  <Icons.Target className="h-5 w-5 text-blue-600" />
                  <span>Requested for</span>
                </div>
                <div className="flex items-center space-x-3">
                  {formData.request_number && (
                    <div className="text-sm text-slate-600">
                      <span className="font-medium">MR Number:</span> {formData.request_number}
                    </div>
                  )}
                  <div className={`px-3 py-1 rounded-full text-xs font-medium ${
                    formState.status === 'DRAFT' ? 'bg-gray-100 text-gray-800' :
                    formState.status === 'SUBMITTED' ? 'bg-blue-100 text-blue-800' :
                    formState.status === 'APPROVED' ? 'bg-green-100 text-green-800' :
                    'bg-red-100 text-red-800'
                  }`}>
                    {formState.status}
                  </div>
                </div>
              </div>
              
              <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                {accountAssignmentTypes.map(type => {
                  const IconComponent = type.icon
                  return (
                    <button
                      key={type.code}
                      type="button"
                      className={`h-16 flex flex-col items-center justify-center space-y-1 border rounded-md transition-colors ${
                        formData.account_assignment === type.code 
                          ? 'bg-blue-600 text-white border-blue-600' 
                          : 'bg-white text-slate-700 border-slate-300 hover:bg-slate-50'
                      } ${formState.isReadOnly ? 'opacity-50 cursor-not-allowed' : ''}`}
                      onClick={() => !formState.isReadOnly && handleFormChange('account_assignment', type.code)}
                      disabled={formState.isReadOnly}
                    >
                      <IconComponent className="h-5 w-5" />
                      <span className="text-xs">{type.name}</span>
                    </button>
                  )
                })}
              </div>



              {/* Cost Center Assignment */}
              {formData.account_assignment === 'K' && (
                <div className="p-4 bg-blue-50 rounded-lg border border-blue-200">
                  <div className="space-y-2">
                    <label className="block text-sm font-medium text-slate-700">
                      Cost Center <span className="text-red-500">*</span>
                    </label>
                    <select 
                      value={formData.cost_center} 
                      onChange={(e) => handleFormChange('cost_center', e.target.value)}
                      className="w-full h-11 px-3 border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    >
                      <option value="">Select cost center</option>
                      {costCenters.map(costCenter => (
                        <option key={costCenter.cost_center_code} value={costCenter.cost_center_code}>
                          {costCenter.cost_center_code} - {costCenter.cost_center_name}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
              )}
            </div>

            <div className="border-t border-slate-200 my-8"></div>

            {/* Basic Information */}
            <div className="space-y-4">
              <div className="flex items-center space-x-2 text-lg font-semibold text-slate-800">
                <Icons.Info className="h-5 w-5 text-blue-600" />
                <span>Basic Information</span>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <div className="space-y-2">
                  <label className="block text-sm font-medium text-slate-700">
                    Project <span className="text-red-500">*</span>
                  </label>
                  <select 
                    value={formData.project_code} 
                    onChange={(e) => handleFormChange('project_code', e.target.value)}
                    disabled={formState.isReadOnly}
                    className="w-full h-11 px-3 border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-slate-50 disabled:cursor-not-allowed"
                  >
                    <option value="">Select project</option>
                    {projects.map(project => (
                      <option key={project.project_code} value={project.project_code}>
                        {project.project_code} - {project.name}
                      </option>
                    ))}
                  </select>
                </div>
                
                {formData.account_assignment === 'P' && formData.project_code && (
                  <div className="space-y-2">
                    <label className="block text-sm font-medium text-slate-700">
                      WBS Element <span className="text-red-500">*</span>
                    </label>
                    <select 
                      value={formData.wbs_element} 
                      onChange={(e) => handleFormChange('wbs_element', e.target.value)}
                      disabled={loadingWbsElements || formState.isReadOnly}
                      className="w-full h-11 px-3 border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-slate-50 disabled:cursor-not-allowed"
                    >
                      <option value="">Select WBS element</option>
                      {wbsElements.map(wbs => (
                        <option key={wbs.id} value={wbs.id}>
                          {wbs.code} - {wbs.name}
                        </option>
                      ))}
                    </select>
                  </div>
                )}
                
                {formData.company_code && (
                  <div className="space-y-2">
                    <label className="block text-sm font-medium text-slate-700">
                      Company Code
                    </label>
                    <input
                      value={formData.company_code}
                      readOnly
                      placeholder="Auto-populated from WBS element"
                      className="w-full h-11 px-3 border border-slate-300 rounded-md bg-slate-50 text-slate-600"
                    />
                  </div>
                )}
                
                <div className="space-y-2">
                  <label className="block text-sm font-medium text-slate-700">
                    Plant Code <span className="text-red-500">*</span>
                  </label>
                  <select 
                    value={formData.plant_code} 
                    onChange={(e) => handleFormChange('plant_code', e.target.value)}
                    disabled={!formData.company_code}
                    className="w-full h-11 px-3 border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-slate-50"
                  >
                    <option value="">Select plant</option>
                    {plants.map(plant => (
                      <option key={plant.plant_code} value={plant.plant_code}>
                        {plant.plant_code} - {plant.plant_name}
                      </option>
                    ))}
                  </select>
                </div>
                
                <div className="space-y-2">
                  <label className="block text-sm font-medium text-slate-700">
                    Receiving Location <span className="text-red-500">*</span>
                  </label>
                  <select 
                    value={formData.storage_location} 
                    onChange={(e) => handleFormChange('storage_location', e.target.value)}
                    disabled={!formData.plant_code}
                    className="w-full h-11 px-3 border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-slate-50"
                  >
                    <option value="">Select location</option>
                    {storageLocations.map(location => (
                      <option key={location.sloc_code} value={location.sloc_code}>
                        📍 {location.sloc_code} - {location.sloc_name}
                      </option>
                    ))}
                  </select>
                </div>
                
                {formData.account_assignment === 'P' && formData.wbs_element && (
                  <div className="space-y-2">
                    <label className="block text-sm font-medium text-slate-700">
                      Activity Code
                    </label>
                    <select 
                      value={formData.activity_code} 
                      onChange={(e) => handleFormChange('activity_code', e.target.value)}
                      disabled={loadingActivities}
                      className="w-full h-11 px-3 border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-slate-50"
                    >
                      <option value="">Select activity (optional)</option>
                      {activities.map(activity => (
                        <option key={activity.id} value={activity.code}>
                          {activity.code} - {activity.name}
                        </option>
                      ))}
                    </select>
                  </div>
                )}
              </div>
            </div>

            <div className="border-t border-slate-200 my-8"></div>

            {/* Material Items */}
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center space-x-2 text-lg font-semibold text-slate-800">
                  <Icons.Package className="h-5 w-5 text-blue-600" />
                  <span>Material Items</span>
                </div>
                <button 
                  type="button" 
                  onClick={addMaterialItem}
                  className="flex items-center space-x-2 px-4 py-2 text-sm border border-slate-300 rounded-md hover:bg-slate-50"
                >
                  <Icons.Plus className="h-4 w-4" />
                  <span>Add Item</span>
                </button>
              </div>

              <div className="border border-blue-200 bg-blue-50 rounded-lg p-4 flex items-start space-x-3">
                <Icons.Info className="h-5 w-5 text-blue-600 mt-0.5 flex-shrink-0" />
                <p className="text-blue-800 text-sm">
                  Material availability and pricing are checked in real-time. Stock levels shown are current.
                </p>
              </div>

              <div className="space-y-4">
                {formData.items.map((item, index) => (
                  <div key={index} className="border border-slate-200 rounded-lg p-4 hover:border-blue-300 transition-colors">
                    <div className="grid grid-cols-1 md:grid-cols-8 gap-4 items-end">
                      <div className="md:col-span-2 space-y-2">
                        <label className="block text-sm font-medium text-slate-700">Material</label>
                        <div className="relative">
                          <input
                            value={activeSearchIndex === index ? materialSearch : item.material_name || item.material_code}
                            onChange={(e) => {
                              setMaterialSearch(e.target.value)
                              setActiveSearchIndex(index)
                            }}
                            onFocus={() => setActiveSearchIndex(index)}
                            placeholder="Search materials..."
                            className="w-full h-11 px-3 border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                          />
                          
                          {/* Material Search Results */}
                          {activeSearchIndex === index && materials.length > 0 && materialSearch.length >= 2 && (
                            <div className="absolute z-10 w-full mt-1 bg-white border border-slate-200 rounded-md shadow-lg max-h-60 overflow-auto">
                              {materials.map((material) => {
                                const stockData = material.material_storage_data?.[0]
                                return (
                                  <div
                                    key={material.material_code}
                                    className="p-3 hover:bg-slate-50 cursor-pointer border-b border-slate-100 last:border-b-0"
                                    onClick={() => selectMaterial(index, material)}
                                  >
                                    <div className="flex justify-between items-start">
                                      <div>
                                        <p className="font-medium text-slate-900">{material.material_name}</p>
                                        <p className="text-sm text-slate-500">{material.material_code}</p>
                                      </div>
                                      <div className="text-right">
                                        <p className="text-sm font-medium">£{material.standard_price?.toFixed(2)}</p>
                                        {stockData && (
                                          <span className={`inline-block px-2 py-1 text-xs rounded-full ${
                                            stockData.available_stock > 0 
                                              ? 'bg-green-100 text-green-800' 
                                              : 'bg-red-100 text-red-800'
                                          }`}>
                                            {stockData.available_stock} {material.base_uom}
                                          </span>
                                        )}
                                      </div>
                                    </div>
                                  </div>
                                )
                              })}
                            </div>
                          )}
                        </div>
                      </div>
                      
                      <div className="space-y-2">
                        <label className="block text-sm font-medium text-slate-700">Quantity</label>
                        <input
                          type="number"
                          value={item.requested_quantity}
                          onChange={(e) => updateMaterialItem(index, 'requested_quantity', parseFloat(e.target.value) || 0)}
                          min="0"
                          step="0.01"
                          className="w-full h-11 px-3 border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        />
                      </div>
                      
                      <div className="space-y-2">
                        <label className="block text-sm font-medium text-slate-700">Unit</label>
                        <input
                          value={item.base_uom}
                          readOnly
                          className="w-full h-11 px-3 border border-slate-300 rounded-md bg-slate-50 text-slate-600"
                        />
                      </div>
                      
                      <div className="space-y-2">
                        <label className="block text-sm font-medium text-slate-700">Priority</label>
                        <select 
                          value={item.priority} 
                          onChange={(e) => updateMaterialItem(index, 'priority', e.target.value)}
                          className="w-full h-11 px-3 border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        >
                          {priorities.map(priority => (
                            <option key={priority.code} value={priority.code}>
                              {priority.name}
                            </option>
                          ))}
                        </select>
                      </div>
                      
                      <div className="space-y-2">
                        <label className="block text-sm font-medium text-slate-700">Required Date</label>
                        <input
                          type="date"
                          value={item.required_date}
                          onChange={(e) => updateMaterialItem(index, 'required_date', e.target.value)}
                          className="w-full h-11 px-3 border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                        />
                      </div>
                      
                      <div className="space-y-2">
                        <label className="block text-sm font-medium text-slate-700">Available Stock</label>
                        <div className="flex items-center space-x-2 h-11">
                          <span className={`px-3 py-1 rounded-full text-sm font-medium ${
                            item.available_stock > 0 
                              ? 'bg-green-100 text-green-800' 
                              : 'bg-red-100 text-red-800'
                          }`}>
                            {item.available_stock} {item.base_uom}
                          </span>
                          {item.available_stock < item.requested_quantity && (
                            <Icons.AlertTriangle className="h-4 w-4 text-orange-500" title="Insufficient stock" />
                          )}
                        </div>
                      </div>
                      
                      <div className="flex justify-end">
                        <button
                          type="button"
                          onClick={() => removeMaterialItem(index)}
                          disabled={formData.items.length === 1}
                          className="h-11 w-11 flex items-center justify-center border border-slate-300 rounded-md hover:bg-slate-50 disabled:opacity-50"
                        >
                          <Icons.Trash2 className="h-4 w-4" />
                        </button>
                      </div>
                    </div>
                  </div>
                ))}
              </div>


            </div>
          </div>
          
          {/* Action Buttons */}
          <div className="bg-slate-50 px-8 py-6 border-t border-slate-200 flex justify-end space-x-4">
            {formState.isSubmitted ? (
              <>
                <button 
                  type="button"
                  onClick={handlePreview}
                  className="px-6 py-2 border border-slate-300 rounded-md text-slate-700 hover:bg-slate-100 flex items-center space-x-2"
                >
                  <Icons.Eye className="h-4 w-4" />
                  <span>View Request</span>
                </button>
                <button 
                  type="button"
                  onClick={createNewRequest}
                  className="px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 flex items-center space-x-2"
                >
                  <Icons.Plus className="h-4 w-4" />
                  <span>Create New Request</span>
                </button>
              </>
            ) : (
              <>
                <button 
                  type="button"
                  onClick={handleSaveDraft}
                  disabled={saving}
                  className="px-6 py-2 border border-slate-300 rounded-md text-slate-700 hover:bg-slate-100 flex items-center space-x-2 disabled:opacity-50"
                >
                  <Icons.Save className="h-4 w-4" />
                  <span>Save Draft</span>
                </button>
                <button 
                  type="button"
                  onClick={handlePreview}
                  className="px-6 py-2 border border-slate-300 rounded-md text-slate-700 hover:bg-slate-100 flex items-center space-x-2"
                >
                  <Icons.Eye className="h-4 w-4" />
                  <span>Preview</span>
                </button>
                <button 
                  onClick={handleSubmit} 
                  disabled={saving}
                  className="px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50 flex items-center space-x-2"
                >
                  {saving ? (
                    <Icons.Loader2 className="h-4 w-4 animate-spin" />
                  ) : (
                    <Icons.Send className="h-4 w-4" />
                  )}
                  <span>Submit for Approval</span>
                </button>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}