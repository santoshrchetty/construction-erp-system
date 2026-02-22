'use client'

import React, { useState, useEffect } from 'react'
import { Trash2, ChevronDown, ChevronRight } from 'lucide-react'

const MR_TYPE_MAPPINGS: Record<string, string[]> = {
  'PROJECT': ['P'],
  'MAINTENANCE': ['K'],
  'GENERAL': ['K'],
  'ASSET': ['A'],
  'OFFICE': ['K'],
  'SAFETY': ['K'],
  'EQUIPMENT': ['K', 'A'],
  'PRODUCTION': ['OP'],
  'QUALITY': ['OQ']
}

interface MaterialRequestFormV2Props {
  initialData?: any
  isEditMode?: boolean
}

export default function MaterialRequestFormV2({ initialData, isEditMode = false }: MaterialRequestFormV2Props) {
  const [mrType, setMrType] = useState(initialData?.request_type || '')
  const [mrTypes, setMrTypes] = useState([])
  const [companyCode, setCompanyCode] = useState(initialData?.company_code || '')
  const [companies, setCompanies] = useState([])
  const [requestedBy, setRequestedBy] = useState(initialData?.requested_by || '')
  const [selectedRows, setSelectedRows] = useState<number[]>([])
  const [expandedRows, setExpandedRows] = useState<number[]>([])
  const [projectSearch, setProjectSearch] = useState<{[key: number]: string}>({})
  const [showProjectDropdown, setShowProjectDropdown] = useState<{[key: number]: boolean}>({})
  const [wbsSearch, setWbsSearch] = useState<{[key: number]: string}>({})
  const [showWbsDropdown, setShowWbsDropdown] = useState<{[key: number]: boolean}>({})
  const [activitySearch, setActivitySearch] = useState<{[key: number]: string}>({})
  const [showActivityDropdown, setShowActivityDropdown] = useState<{[key: number]: boolean}>({})
  const [materialSearch, setMaterialSearch] = useState<{[key: number]: string}>({})
  const [showMaterialDropdown, setShowMaterialDropdown] = useState<{[key: number]: boolean}>({})
  const [materials, setMaterials] = useState([])
  const [items, setItems] = useState([{
    line_number: 1,
    material_code: '',
    material_name: '',
    requested_quantity: 0,
    base_uom: 'PCS',
    priority: 'MEDIUM',
    required_date: '',
    department_code: '',
    plant_code: '',
    storage_location: '',
    delivery_location: '',
    notes: '',
    account_assignment_code: '',
    cost_center: '',
    project_id: '',
    wbs_element_id: '',
    wbs_element: '',
    activity_code: '',
    asset_number: '',
    order_number: '',
    production_order_number: '',
    operation_number: '',
    quality_order_number: '',
    inspection_lot: '',
    _plants: [],
    _storageLocations: [],
    _projects: [],
    _wbsElements: [],
    _activities: []
  }])

  useEffect(() => {
    loadMRTypes()
    loadCompanies()
    loadMaterials()
    if (initialData?.items) {
      initEditData()
    } else {
      initData()
    }
  }, [])

  useEffect(() => {
    if (companyCode) loadPlantsForAllItems()
  }, [companyCode])

  const loadMRTypes = async () => {
    try {
      const response = await fetch('/api/account-assignments?action=mrTypes')
      const data = await response.json()
      if (data.success) setMrTypes(data.data || [])
    } catch (error) {
      console.error('Failed to load MR types:', error)
    }
  }

  const loadCompanies = async () => {
    try {
      const response = await fetch('/api/erp-config/companies')
      const data = await response.json()
      if (data.success) setCompanies(data.data || [])
    } catch (error) {
      console.error('Failed to load companies:', error)
    }
  }

  const loadMaterials = async () => {
    try {
      const response = await fetch('/api/materials')
      const data = await response.json()
      if (data.success) setMaterials(data.data || [])
    } catch (error) {
      console.error('Failed to load materials:', error)
    }
  }

  const loadProjects = async () => {
    try {
      const response = await fetch('/api/projects')
      const data = await response.json()
      return data.success ? data.data || [] : []
    } catch (error) {
      return []
    }
  }

  const loadWbsElements = async (projectCode: string) => {
    try {
      const response = await fetch(`/api/wbs?projectCode=${projectCode}`)
      const data = await response.json()
      console.log('WBS API response:', data)
      return data.success ? data.data || [] : []
    } catch (error) {
      console.error('Failed to load WBS:', error)
      return []
    }
  }

  const loadActivities = async (wbsId: string, wbsCode: string) => {
    try {
      const response = await fetch(`/api/activities?wbsElement=${wbsCode}`)
      const data = await response.json()
      console.log('Activities API response:', data)
      return data.success ? data.data || [] : []
    } catch (error) {
      console.error('Failed to load activities:', error)
      return []
    }
  }

  const loadPlants = async (companyCode: string) => {
    try {
      const response = await fetch(`/api/erp-config/plants?companyCode=${companyCode}`)
      const data = await response.json()
      return data.success ? data.data || [] : []
    } catch (error) {
      return []
    }
  }

  const loadStorageLocations = async (plantCode: string) => {
    try {
      const response = await fetch(`/api/erp-config/storage-locations?plantCode=${plantCode}&active=true`)
      const data = await response.json()
      return data.success ? data.data || [] : []
    } catch (error) {
      return []
    }
  }

  const loadPlantsForAllItems = async () => {
    if (!companyCode) return
    const plants = await loadPlants(companyCode)
    setItems(prev => prev.map(item => ({ ...item, _plants: plants, plant_code: '', storage_location: '', _storageLocations: [] })))
  }

  const initData = async () => {
    const projects = await loadProjects()
    console.log('Initial projects loaded:', projects)
    setItems(prev => prev.map(item => ({ ...item, _projects: projects })))
  }

  const initEditData = async () => {
    const projects = await loadProjects()
    const plants = companyCode ? await loadPlants(companyCode) : []
    
    const loadedItems = await Promise.all(initialData.items.map(async (item: any, idx: number) => {
      const storageLocations = item.plant_code ? await loadStorageLocations(item.plant_code) : []
      let wbsElements: any[] = []
      let activities: any[] = []
      
      if (item.project_id) {
        const project = projects.find((p: any) => p.id === item.project_id)
        if (project?.project_code) {
          wbsElements = await loadWbsElements(project.project_code)
          
          if (item.wbs_element_id) {
            const wbs = wbsElements.find((w: any) => w.id === item.wbs_element_id)
            if (wbs?.code) {
              activities = await loadActivities(item.wbs_element_id, wbs.code)
            }
          }
        }
        
        setProjectSearch(prev => ({...prev, [idx]: `${project?.project_code} - ${project?.name}`}))
      }
      
      if (item.wbs_element_id) {
        const wbs = wbsElements.find((w: any) => w.id === item.wbs_element_id)
        if (wbs) {
          setWbsSearch(prev => ({...prev, [idx]: `${wbs.code} - ${wbs.name}`}))
        }
      }
      
      if (item.activity_code) {
        const activity = activities.find((a: any) => (a.activity_code || a.code) === item.activity_code)
        if (activity) {
          const code = activity.activity_code || activity.code
          const name = activity.activity_name || activity.name
          setActivitySearch(prev => ({...prev, [idx]: `${code}${name ? ' - ' + name : ''}`}))
        }
      }
      
      if (item.material_code) {
        setMaterialSearch(prev => ({...prev, [idx]: `${item.material_code} - ${item.material_name}`}))
      }
      
      return {
        ...item,
        wbs_element: item.wbs_element || '',
        _plants: plants,
        _storageLocations: storageLocations,
        _projects: projects,
        _wbsElements: wbsElements,
        _activities: activities
      }
    }))
    
    setItems(loadedItems)
  }

  const addItem = async () => {
    const projects = await loadProjects()
    const plants = companyCode ? await loadPlants(companyCode) : []
    setItems([...items, {
      line_number: items.length + 1,
      material_code: '',
      material_name: '',
      requested_quantity: 0,
      base_uom: 'PCS',
      priority: 'MEDIUM',
      required_date: '',
      department_code: '',
      plant_code: '',
      storage_location: '',
      delivery_location: '',
      notes: '',
      account_assignment_code: '',
      cost_center: '',
      project_id: '',
      wbs_element_id: '',
      wbs_element: '',
      activity_code: '',
      asset_number: '',
      order_number: '',
      production_order_number: '',
      operation_number: '',
      quality_order_number: '',
      inspection_lot: '',
      _plants: plants,
      _storageLocations: [],
      _projects: projects,
      _wbsElements: [],
      _activities: []
    }])
  }

  const updateItem = async (index: number, field: string, value: any) => {
    const newItems = [...items]
    newItems[index] = { ...newItems[index], [field]: value }
    
    if (field === 'plant_code' && value) {
      const locations = await loadStorageLocations(value)
      newItems[index]._storageLocations = locations
      newItems[index].storage_location = ''
      setItems(newItems)
    }
    else if (field === 'project_id' && value) {
      console.log('Project ID selected:', value)
      console.log('Available projects:', newItems[index]._projects)
      const project = newItems[index]._projects.find((p: any) => p.id === value)
      console.log('Found project:', project)
      console.log('Project code:', project?.project_code)
      if (project?.project_code) {
        const wbs = await loadWbsElements(project.project_code)
        console.log('Loaded WBS elements:', wbs)
        console.log('WBS count:', wbs?.length)
        newItems[index]._wbsElements = wbs
        newItems[index].wbs_element_id = ''
        newItems[index].activity_code = ''
        newItems[index]._activities = []
        setItems([...newItems])
      } else {
        console.error('Project code not found')
      }
    }
    else if (field === 'wbs_element_id' && value) {
      const wbs = newItems[index]._wbsElements.find((w: any) => w.id === value)
      console.log('Selected WBS:', wbs)
      if (wbs?.code) {
        const activities = await loadActivities(value, wbs.code)
        console.log('Loaded activities:', activities)
        console.log('Activities count:', activities?.length)
        newItems[index]._activities = activities
        newItems[index].activity_code = ''
        setItems([...newItems])
      }
    }
    else {
      setItems(newItems)
    }
  }

  const toggleRowSelection = (index: number) => {
    setSelectedRows(prev => 
      prev.includes(index) ? prev.filter(i => i !== index) : [...prev, index]
    )
  }

  const toggleRowExpansion = (index: number) => {
    setExpandedRows(prev => 
      prev.includes(index) ? prev.filter(i => i !== index) : [...prev, index]
    )
  }

  const deleteSelectedRows = () => {
    setItems(prev => prev.filter((_, idx) => !selectedRows.includes(idx)))
    setSelectedRows([])
  }

  const getAllowedCategories = () => {
    return MR_TYPE_MAPPINGS[mrType] || []
  }

  const getFilteredProjects = (index: number) => {
    const search = projectSearch[index]?.toLowerCase() || ''
    if (!search) return items[index]._projects || []
    return (items[index]._projects || []).filter((p: any) => 
      p.project_code?.toLowerCase().includes(search) ||
      p.name?.toLowerCase().includes(search) ||
      p.status?.toLowerCase().includes(search) ||
      p.category_code?.toLowerCase().includes(search)
    )
  }

  const selectProject = (index: number, project: any) => {
    updateItem(index, 'project_id', project.id)
    setProjectSearch({...projectSearch, [index]: `${project.project_code} - ${project.name}`})
    setShowProjectDropdown({...showProjectDropdown, [index]: false})
  }

  const validateProject = (index: number) => {
    const input = projectSearch[index]?.trim().toUpperCase()
    if (!input || items[index].project_id) return
    
    const match = items[index]._projects.find((p: any) => 
      p.project_code?.toUpperCase() === input
    )
    
    if (match) {
      selectProject(index, match)
    } else {
      setProjectSearch({...projectSearch, [index]: ''})
    }
  }

  const getFilteredWbs = (index: number) => {
    const search = wbsSearch[index]?.toLowerCase() || ''
    if (!search) return items[index]._wbsElements || []
    return (items[index]._wbsElements || []).filter((w: any) => 
      w.code?.toLowerCase().includes(search) ||
      w.name?.toLowerCase().includes(search) ||
      w.description?.toLowerCase().includes(search)
    )
  }

  const selectWbs = async (index: number, wbs: any) => {
    const newItems = [...items]
    newItems[index].wbs_element_id = wbs.id
    newItems[index].wbs_element = wbs.code
    newItems[index].activity_code = ''
    
    // Load activities for this WBS
    if (wbs.code) {
      const activities = await loadActivities(wbs.id, wbs.code)
      console.log('Loaded activities for WBS:', activities)
      newItems[index]._activities = activities
    }
    
    setItems(newItems)
    setWbsSearch({...wbsSearch, [index]: `${wbs.code} - ${wbs.name}`})
    setShowWbsDropdown({...showWbsDropdown, [index]: false})
  }

  const validateWbs = (index: number) => {
    const input = wbsSearch[index]?.trim().toUpperCase()
    if (!input || items[index].wbs_element_id) return
    
    const match = items[index]._wbsElements.find((w: any) => 
      w.code?.toUpperCase() === input
    )
    
    if (match) {
      selectWbs(index, match)
    } else {
      setWbsSearch({...wbsSearch, [index]: ''})
    }
  }

  const getFilteredActivities = (index: number) => {
    const search = activitySearch[index]?.toLowerCase() || ''
    if (!search) return items[index]._activities || []
    return (items[index]._activities || []).filter((a: any) => 
      a.activity_code?.toLowerCase().includes(search) ||
      a.activity_name?.toLowerCase().includes(search) ||
      a.name?.toLowerCase().includes(search) ||
      a.description?.toLowerCase().includes(search)
    )
  }

  const selectActivity = (index: number, activity: any) => {
    const code = activity.activity_code || activity.code
    const name = activity.activity_name || activity.name
    const newItems = [...items]
    newItems[index].activity_code = code
    setItems(newItems)
    setActivitySearch({...activitySearch, [index]: `${code}${name ? ' - ' + name : ''}`})
    setShowActivityDropdown({...showActivityDropdown, [index]: false})
  }

  const validateActivity = (index: number) => {
    const input = activitySearch[index]?.trim().toUpperCase()
    if (!input || items[index].activity_code) return
    
    const match = items[index]._activities.find((a: any) => {
      const code = (a.activity_code || a.code)?.toUpperCase()
      return code === input
    })
    
    if (match) {
      selectActivity(index, match)
    } else {
      setActivitySearch({...activitySearch, [index]: ''})
    }
  }

  const getFilteredMaterials = (index: number) => {
    const search = materialSearch[index]?.toLowerCase() || ''
    if (!search) return materials
    return materials.filter((m: any) => 
      m.material_code?.toLowerCase().includes(search) ||
      m.material_name?.toLowerCase().includes(search) ||
      m.description?.toLowerCase().includes(search) ||
      m.category?.toLowerCase().includes(search)
    )
  }

  const selectMaterial = (index: number, material: any) => {
    const newItems = [...items]
    newItems[index].material_code = material.material_code
    newItems[index].material_name = material.material_name
    newItems[index].base_uom = material.base_uom || material.uom || 'PCS'
    setItems(newItems)
    setMaterialSearch({...materialSearch, [index]: `${material.material_code} - ${material.material_name}`})
    setShowMaterialDropdown({...showMaterialDropdown, [index]: false})
  }

  const validateMaterial = (index: number) => {
    const input = materialSearch[index]?.trim().toUpperCase()
    if (!input || items[index].material_code) return
    
    const match = materials.find((m: any) => 
      m.material_code?.toUpperCase() === input
    )
    
    if (match) {
      selectMaterial(index, match)
    } else {
      setMaterialSearch({...materialSearch, [index]: ''})
    }
  }

  const handleSave = async (submitForApproval: boolean = false) => {
    try {
      const payload = {
        mr_type: mrType,
        company_code: companyCode,
        requested_by: requestedBy,
        submit: submitForApproval,
        items: items.map(item => ({
          line_number: item.line_number,
          material_code: item.material_code,
          material_name: item.material_name,
          requested_quantity: item.requested_quantity,
          base_uom: item.base_uom,
          priority: item.priority,
          required_date: item.required_date,
          department_code: item.department_code,
          plant_code: item.plant_code,
          storage_location: item.storage_location,
          delivery_location: item.delivery_location,
          notes: item.notes,
          account_assignment_code: item.account_assignment_code,
          cost_center: item.cost_center,
          project_id: item.project_id,
          wbs_element_id: item.wbs_element_id,
          wbs_element: item.wbs_element,
          activity_code: item.activity_code,
          asset_number: item.asset_number,
          order_number: item.order_number,
          production_order_number: item.production_order_number,
          operation_number: item.operation_number,
          quality_order_number: item.quality_order_number,
          inspection_lot: item.inspection_lot
        }))
      }
      
      console.log('Saving payload:', JSON.stringify(payload, null, 2))
      
      const url = isEditMode ? `/api/material-requests/${initialData.id}` : '/api/material-requests'
      const method = isEditMode ? 'PUT' : 'POST'
      
      const response = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      })
      
      const data = await response.json()
      if (data.success) {
        const requestNumber = data.data?.request_number || initialData?.request_number || 'Unknown'
        const status = submitForApproval ? 'submitted for approval' : 'saved as draft'
        alert(`Material Request ${isEditMode ? 'updated' : status} successfully!\nRequest Number: ${requestNumber}`)
        window.location.href = '/materials/requests'
      } else {
        alert('Failed to save: ' + (data.error || 'Unknown error'))
      }
    } catch (error) {
      console.error('Save error:', error)
      alert('Failed to save Material Request')
    }
  }

  return (
    <div className="p-4 max-w-full">
      <div className="bg-white border">
        <div className="bg-gray-100 px-4 py-2 border-b flex justify-between items-center">
          <h1 className="text-lg font-semibold">{isEditMode ? 'Edit Material Request' : 'Create Material Request'}</h1>
          <div className="flex gap-2">
            <button className="px-4 py-1 text-sm border bg-white hover:bg-gray-50">Cancel</button>
            <button onClick={() => handleSave(false)} className="px-4 py-1 text-sm border bg-white hover:bg-gray-50">Save as Draft</button>
            <button onClick={() => handleSave(true)} className="px-4 py-1 text-sm bg-blue-600 text-white hover:bg-blue-700">Save &amp; Submit</button>
          </div>
        </div>

        <div className="p-4 space-y-3">
          <div className="grid grid-cols-4 gap-3">
            <div>
              <label className="text-xs font-medium">MR Type <span className="text-red-500">*</span></label>
              <select value={mrType} onChange={(e) => setMrType(e.target.value)} className="w-full text-sm p-1 border">
                <option value="">Select</option>
                {mrTypes.map((t: any) => (
                  <option key={t.code || t.mr_type} value={t.code || t.mr_type}>{t.name || t.mr_type}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="text-xs font-medium">Company Code <span className="text-red-500">*</span></label>
              <select value={companyCode} onChange={(e) => setCompanyCode(e.target.value)} className="w-full text-sm p-1 border">
                <option value="">Select</option>
                {companies.map((c: any) => (
                  <option key={c.company_code} value={c.company_code}>{c.company_code} - {c.company_name}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="text-xs font-medium">Requested By</label>
              <input value={requestedBy} onChange={(e) => setRequestedBy(e.target.value)} className="w-full text-sm p-1 border" placeholder="Enter name" />
            </div>
          </div>

          {mrType && (
            <>
              <div className="flex justify-between items-center pt-2">
                <span className="text-sm font-semibold">Items</span>
                <div className="flex gap-2">
                  {selectedRows.length > 0 && (
                    <button onClick={deleteSelectedRows} className="text-xs px-3 py-1 bg-red-600 text-white hover:bg-red-700 flex items-center gap-1">
                      <Trash2 className="h-3 w-3" /> Delete ({selectedRows.length})
                    </button>
                  )}
                  <button onClick={addItem} className="text-xs px-3 py-1 bg-green-600 text-white hover:bg-green-700">
                    + Add
                  </button>
                </div>
              </div>

              <div className="overflow-x-auto">
                <table className="w-full text-xs border-collapse">
                  <thead>
                    <tr className="bg-gray-50 border-y">
                      <th className="p-1 text-left border-r w-8"></th>
                      <th className="p-1 text-left border-r w-8">
                        <input 
                          type="checkbox" 
                          checked={selectedRows.length === items.length && items.length > 0}
                          onChange={(e) => setSelectedRows(e.target.checked ? items.map((_, i) => i) : [])}
                          className="cursor-pointer"
                        />
                      </th>
                      <th className="p-1 text-left border-r w-24">Acct Cat</th>
                      <th className="p-1 text-left border-r w-32">Material</th>
                      <th className="p-1 text-left border-r w-20">Qty</th>
                      <th className="p-1 text-left border-r w-20">UoM</th>
                      <th className="p-1 text-left border-r w-24">Req Date</th>
                      <th className="p-1 text-left border-r w-24">Plant</th>
                      <th className="p-1 text-left w-24">SLoc</th>
                    </tr>
                  </thead>
                  <tbody>
                    {items.map((item, idx) => (
                      <React.Fragment key={idx}>
                        <tr className="border-b hover:bg-gray-50">
                          <td className="p-1 border-r text-center">
                            <button onClick={() => toggleRowExpansion(idx)} className="p-0">
                              {expandedRows.includes(idx) ? <ChevronDown className="h-3 w-3" /> : <ChevronRight className="h-3 w-3" />}
                            </button>
                          </td>
                          <td className="p-1 border-r text-center">
                            <input 
                              type="checkbox" 
                              checked={selectedRows.includes(idx)}
                              onChange={() => toggleRowSelection(idx)}
                              className="cursor-pointer"
                            />
                          </td>
                          <td className="p-1 border-r">
                            <select value={item.account_assignment_code || ''} onChange={(e) => updateItem(idx, 'account_assignment_code', e.target.value)} className="w-full text-xs p-1 border-0">
                              <option value=""></option>
                              {getAllowedCategories().map((cat) => (
                                <option key={cat} value={cat}>{cat}</option>
                              ))}
                            </select>
                          </td>
                          <td className="p-1 border-r">
                            <input
                              type="text"
                              value={materialSearch[idx] || ''}
                              onChange={(e) => {
                                setMaterialSearch({...materialSearch, [idx]: e.target.value})
                                setShowMaterialDropdown({...showMaterialDropdown, [idx]: true})
                              }}
                              onFocus={() => setShowMaterialDropdown({...showMaterialDropdown, [idx]: true})}
                              onBlur={() => {
                                setTimeout(() => {
                                  validateMaterial(idx)
                                  setShowMaterialDropdown({...showMaterialDropdown, [idx]: false})
                                }, 200)
                              }}
                              placeholder="Search or type material code..."
                              className="w-full text-xs p-1 border-0"
                            />
                            {showMaterialDropdown[idx] && getFilteredMaterials(idx).length > 0 && (
                              <div className="absolute z-50 w-64 mt-1 bg-white border shadow-lg max-h-60 overflow-y-auto">
                                {getFilteredMaterials(idx).slice(0, 20).map((m: any) => (
                                  <div
                                    key={m.material_code || m.id}
                                    onClick={() => selectMaterial(idx, m)}
                                    className="p-2 hover:bg-blue-100 cursor-pointer border-b text-xs"
                                  >
                                    <div className="font-medium">{m.material_code}</div>
                                    <div className="text-gray-600">{m.material_name}</div>
                                    <div className="text-gray-500 text-[10px]">{m.category} • {m.base_uom || m.uom}</div>
                                  </div>
                                ))}
                              </div>
                            )}
                          </td>
                          <td className="p-1 border-r">
                            <input type="number" value={item.requested_quantity || ''} onChange={(e) => updateItem(idx, 'requested_quantity', parseFloat(e.target.value) || 0)} className="w-full text-xs p-1 border-0" />
                          </td>
                          <td className="p-1 border-r">
                            <input value={item.base_uom || ''} onChange={(e) => updateItem(idx, 'base_uom', e.target.value)} className="w-full text-xs p-1 border-0" />
                          </td>
                          <td className="p-1 border-r">
                            <input type="date" value={item.required_date || ''} onChange={(e) => updateItem(idx, 'required_date', e.target.value)} className="w-full text-xs p-1 border-0" />
                          </td>
                          <td className="p-1 border-r">
                            <select value={item.plant_code || ''} onChange={(e) => updateItem(idx, 'plant_code', e.target.value)} className="w-full text-xs p-1 border-0">
                              <option value=""></option>
                              {(item._plants || []).map((p: any) => (
                                <option key={p.plant_code} value={p.plant_code}>{p.plant_code} - {p.plant_name}</option>
                              ))}
                            </select>
                          </td>
                          <td className="p-1">
                            <select value={item.storage_location || ''} onChange={(e) => updateItem(idx, 'storage_location', e.target.value)} disabled={!item.plant_code} className="w-full text-xs p-1 border-0">
                              <option value=""></option>
                              {(item._storageLocations || []).map((l: any) => (
                                <option key={l.sloc_code} value={l.sloc_code}>{l.sloc_code} - {l.sloc_name || l.description}</option>
                              ))}
                            </select>
                          </td>
                        </tr>

                        {expandedRows.includes(idx) && (
                          <tr className="bg-blue-50 border-b">
                            <td colSpan={9} className="p-2">
                              <div className="grid grid-cols-4 gap-2">
                                <div>
                                  <label className="text-xs font-medium">Priority</label>
                                  <select value={item.priority || 'MEDIUM'} onChange={(e) => updateItem(idx, 'priority', e.target.value)} className="w-full text-xs p-1 border">
                                    <option value="LOW">Low</option>
                                    <option value="MEDIUM">Medium</option>
                                    <option value="HIGH">High</option>
                                    <option value="URGENT">Urgent</option>
                                  </select>
                                </div>
                                <div>
                                  <label className="text-xs font-medium">Department</label>
                                  <input value={item.department_code || ''} onChange={(e) => updateItem(idx, 'department_code', e.target.value)} className="w-full text-xs p-1 border" />
                                </div>

                                {item.account_assignment_code === 'P' && (
                                  <>
                                    <div className="relative">
                                      <label className="text-xs font-medium">Project</label>
                                      <input
                                        type="text"
                                        value={projectSearch[idx] || ''}
                                        onChange={(e) => {
                                          setProjectSearch({...projectSearch, [idx]: e.target.value})
                                          setShowProjectDropdown({...showProjectDropdown, [idx]: true})
                                        }}
                                        onFocus={() => setShowProjectDropdown({...showProjectDropdown, [idx]: true})}
                                        onBlur={() => {
                                          setTimeout(() => {
                                            validateProject(idx)
                                            setShowProjectDropdown({...showProjectDropdown, [idx]: false})
                                          }, 200)
                                        }}
                                        placeholder="Search or type project code..."
                                        className="w-full text-xs p-1 border"
                                      />
                                      {showProjectDropdown[idx] && getFilteredProjects(idx).length > 0 && (
                                        <div className="absolute z-50 w-full mt-1 bg-white border shadow-lg max-h-60 overflow-y-auto">
                                          {getFilteredProjects(idx).map((p: any) => (
                                            <div
                                              key={p.id}
                                              onClick={() => selectProject(idx, p)}
                                              className="p-2 hover:bg-blue-100 cursor-pointer border-b text-xs"
                                            >
                                              <div className="font-medium">{p.project_code}</div>
                                              <div className="text-gray-600">{p.name}</div>
                                              <div className="text-gray-500 text-[10px]">{p.status} • {p.category_code}</div>
                                            </div>
                                          ))}
                                        </div>
                                      )}
                                    </div>
                                    <div className="relative">
                                      <label className="text-xs font-medium">WBS</label>
                                      <input
                                        type="text"
                                        value={wbsSearch[idx] || ''}
                                        onChange={(e) => {
                                          setWbsSearch({...wbsSearch, [idx]: e.target.value})
                                          setShowWbsDropdown({...showWbsDropdown, [idx]: true})
                                        }}
                                        onFocus={() => setShowWbsDropdown({...showWbsDropdown, [idx]: true})}
                                        onBlur={() => {
                                          setTimeout(() => {
                                            validateWbs(idx)
                                            setShowWbsDropdown({...showWbsDropdown, [idx]: false})
                                          }, 200)
                                        }}
                                        disabled={!item.project_id}
                                        placeholder="Search or type WBS code..."
                                        className="w-full text-xs p-1 border disabled:bg-gray-50"
                                      />
                                      {showWbsDropdown[idx] && getFilteredWbs(idx).length > 0 && (
                                        <div className="absolute z-50 w-full mt-1 bg-white border shadow-lg max-h-60 overflow-y-auto">
                                          {getFilteredWbs(idx).map((w: any) => (
                                            <div
                                              key={w.id}
                                              onClick={() => selectWbs(idx, w)}
                                              className="p-2 hover:bg-blue-100 cursor-pointer border-b text-xs"
                                            >
                                              <div className="font-medium">{w.code}</div>
                                              <div className="text-gray-600">{w.name}</div>
                                              {w.description && <div className="text-gray-500 text-[10px]">{w.description}</div>}
                                            </div>
                                          ))}
                                        </div>
                                      )}
                                    </div>
                                    <div className="relative">
                                      <label className="text-xs font-medium">Activity</label>
                                      <input
                                        type="text"
                                        value={activitySearch[idx] || ''}
                                        onChange={(e) => {
                                          setActivitySearch({...activitySearch, [idx]: e.target.value})
                                          setShowActivityDropdown({...showActivityDropdown, [idx]: true})
                                        }}
                                        onFocus={() => setShowActivityDropdown({...showActivityDropdown, [idx]: true})}
                                        onBlur={() => {
                                          setTimeout(() => {
                                            validateActivity(idx)
                                            setShowActivityDropdown({...showActivityDropdown, [idx]: false})
                                          }, 200)
                                        }}
                                        disabled={!item.wbs_element_id}
                                        placeholder="Search or type activity code..."
                                        className="w-full text-xs p-1 border disabled:bg-gray-50"
                                      />
                                      {showActivityDropdown[idx] && getFilteredActivities(idx).length > 0 && (
                                        <div className="absolute z-50 w-full mt-1 bg-white border shadow-lg max-h-60 overflow-y-auto">
                                          {getFilteredActivities(idx).map((a: any) => (
                                            <div
                                              key={a.activity_code || a.code || a.id}
                                              onClick={() => selectActivity(idx, a)}
                                              className="p-2 hover:bg-blue-100 cursor-pointer border-b text-xs"
                                            >
                                              <div className="font-medium">{a.activity_code || a.code}</div>
                                              <div className="text-gray-600">{a.activity_name || a.name}</div>
                                              {a.description && <div className="text-gray-500 text-[10px]">{a.description}</div>}
                                            </div>
                                          ))}
                                        </div>
                                      )}
                                    </div>
                                  </>
                                )}

                                {item.account_assignment_code === 'K' && (
                                  <div>
                                    <label className="text-xs font-medium">Cost Center</label>
                                    <input value={item.cost_center || ''} onChange={(e) => updateItem(idx, 'cost_center', e.target.value)} className="w-full text-xs p-1 border" />
                                  </div>
                                )}

                                {item.account_assignment_code === 'A' && (
                                  <div>
                                    <label className="text-xs font-medium">Asset Number</label>
                                    <input value={item.asset_number || ''} onChange={(e) => updateItem(idx, 'asset_number', e.target.value)} className="w-full text-xs p-1 border" />
                                  </div>
                                )}

                                {item.account_assignment_code === 'O' && (
                                  <div>
                                    <label className="text-xs font-medium">Order Number</label>
                                    <input value={item.order_number || ''} onChange={(e) => updateItem(idx, 'order_number', e.target.value)} className="w-full text-xs p-1 border" />
                                  </div>
                                )}

                                {item.account_assignment_code === 'OP' && (
                                  <>
                                    <div>
                                      <label className="text-xs font-medium">Production Order</label>
                                      <input value={item.production_order_number || ''} onChange={(e) => updateItem(idx, 'production_order_number', e.target.value)} className="w-full text-xs p-1 border" />
                                    </div>
                                    <div>
                                      <label className="text-xs font-medium">Operation</label>
                                      <input value={item.operation_number || ''} onChange={(e) => updateItem(idx, 'operation_number', e.target.value)} className="w-full text-xs p-1 border" />
                                    </div>
                                  </>
                                )}

                                {item.account_assignment_code === 'OQ' && (
                                  <>
                                    <div>
                                      <label className="text-xs font-medium">Quality Order</label>
                                      <input value={item.quality_order_number || ''} onChange={(e) => updateItem(idx, 'quality_order_number', e.target.value)} className="w-full text-xs p-1 border" />
                                    </div>
                                    <div>
                                      <label className="text-xs font-medium">Inspection Lot</label>
                                      <input value={item.inspection_lot || ''} onChange={(e) => updateItem(idx, 'inspection_lot', e.target.value)} className="w-full text-xs p-1 border" />
                                    </div>
                                  </>
                                )}

                                <div className="col-span-4">
                                  <label className="text-xs font-medium">Notes</label>
                                  <textarea value={item.notes || ''} onChange={(e) => updateItem(idx, 'notes', e.target.value)} className="w-full text-xs p-1 border" rows={2} />
                                </div>
                              </div>
                            </td>
                          </tr>
                        )}
                      </React.Fragment>
                    ))}
                  </tbody>
                </table>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  )
}
