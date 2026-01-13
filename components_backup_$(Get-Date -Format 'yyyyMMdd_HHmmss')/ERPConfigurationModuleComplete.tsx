'use client'

import React, { useState, useEffect, useMemo } from 'react'
import { supabase } from '../lib/supabase-simple'
import { Plus, Edit2, Trash2, Settings, Database, Key, Calculator, X, Package, DollarSign, ShoppingCart, FolderTree, Users, Building, Search, Hash, GitBranch, CheckCircle2, Play } from 'lucide-react'
import EnhancedProjectsConfigTab from './EnhancedProjectsConfigTab'

interface MaterialGroup {
  id: string
  group_code: string
  group_name: string
  description: string
  is_active: boolean
}

interface VendorCategory {
  id: string
  category_code: string
  category_name: string
  description: string
  is_active: boolean
}

interface PaymentTerm {
  id: string
  term_code: string
  term_name: string
  net_days: number
  discount_days: number
  discount_percent: number
  is_active: boolean
}

interface UOMGroup {
  id: string
  base_uom: string
  uom_name: string
  dimension: string
  is_active: boolean
}

interface MaterialStatus {
  id: string
  status_code: string
  status_name: string
  allow_procurement: boolean
  allow_consumption: boolean
  is_active: boolean
}

interface GLAccount {
  id: string
  account_code: string
  account_name: string
  account_type: string
  is_active: boolean
}

interface ValuationClass {
  id: string
  class_code: string
  class_name: string
  description: string
  is_active: boolean
}

interface MovementType {
  id: string
  movement_type: string
  movement_name: string
  movement_indicator: string
  description: string
  is_active: boolean
}

interface AccountDetermination {
  id: string
  company_code_id: string
  valuation_class_id: string
  account_key_id: string
  gl_account_id: string
  is_active: boolean
}

interface CompanyCode {
  id: string
  company_code: string
  company_name: string
  currency: string
  country: string
  is_active: boolean
}

interface Plant {
  id: string
  plant_code: string
  plant_name: string
  company_code: string
  plant_type: string
  is_active: boolean
}

interface StorageLocation {
  id: string
  sloc_code: string
  sloc_name: string
  plant_id: string
  location_type: string
  is_active: boolean
}

export default function ERPConfigurationModuleComplete() {
  const [activeTab, setActiveTab] = useState('materials')
  const [materialGroups, setMaterialGroups] = useState<MaterialGroup[]>([])
  const [vendorCategories, setVendorCategories] = useState<VendorCategory[]>([])
  const [paymentTerms, setPaymentTerms] = useState<PaymentTerm[]>([])
  const [uomGroups, setUOMGroups] = useState<UOMGroup[]>([])
  const [materialStatus, setMaterialStatus] = useState<MaterialStatus[]>([])
  const [glAccounts, setGLAccounts] = useState<GLAccount[]>([])
  const [valuationClasses, setValuationClasses] = useState<ValuationClass[]>([])
  const [movementTypes, setMovementTypes] = useState<MovementType[]>([])
  const [companyCodes, setCompanyCodes] = useState<CompanyCode[]>([])
  const [plants, setPlants] = useState<Plant[]>([])
  const [storageLocations, setStorageLocations] = useState<StorageLocation[]>([])
  const [accountKeys, setAccountKeys] = useState<any[]>([])
  const [accountDetermination, setAccountDetermination] = useState<AccountDetermination[]>([])
  const [loading, setLoading] = useState(false)
  const [showModal, setShowModal] = useState(false)
  const [modalType, setModalType] = useState<'add' | 'edit'>('add')
  const [modalEntity, setModalEntity] = useState<string>('group')
  const [editingItem, setEditingItem] = useState<MaterialGroup | VendorCategory | PaymentTerm | UOMGroup | MaterialStatus | GLAccount | ValuationClass | MovementType | CompanyCode | Plant | StorageLocation | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [glSearchTerm, setGlSearchTerm] = useState('')
  const [valuationSearchTerm, setValuationSearchTerm] = useState('')
  const [movementSearchTerm, setMovementSearchTerm] = useState('')
  const [materialGroupSearchTerm, setMaterialGroupSearchTerm] = useState('')
  const [vendorCategorySearchTerm, setVendorCategorySearchTerm] = useState('')
  const [paymentTermSearchTerm, setPaymentTermSearchTerm] = useState('')
  const [uomSearchTerm, setUomSearchTerm] = useState('')
  const [materialStatusSearchTerm, setMaterialStatusSearchTerm] = useState('')
  const [expandedCompanies, setExpandedCompanies] = useState<Set<string>>(new Set())

  // Memoized filtering for performance
  const plantsByCompany = useMemo(() => {
    const map = new Map<string, Plant[]>()
    plants.forEach(plant => {
      const companyId = plant.company_code_id
      if (!map.has(companyId)) map.set(companyId, [])
      map.get(companyId)!.push(plant)
    })
    return map
  }, [plants])

  const storagesByPlant = useMemo(() => {
    const map = new Map<string, StorageLocation[]>()
    storageLocations.forEach(storage => {
      const plantId = storage.plant_id
      if (!map.has(plantId)) map.set(plantId, [])
      map.get(plantId)!.push(storage)
    })
    return map
  }, [storageLocations])

  useEffect(() => {
    let mounted = true
    const load = async () => {
      if (!mounted) return
      await loadData()
    }
    load()
    return () => { mounted = false }
  }, [])

  const loadData = async () => {
    setLoading(true)
    try {
      console.log('Loading ERP configuration data...')
      const response = await fetch('/api/erp-config?category=erp-config')
      console.log('API Response status:', response.status)
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const result = await response.json()
      console.log('API Result:', result)
      
      if (result.success) {
        const data = result.data
        console.log('Setting data:', data)
        if (data.material_groups) setMaterialGroups(data.material_groups)
        if (data.vendor_categories) setVendorCategories(data.vendor_categories)
        if (data.payment_terms) setPaymentTerms(data.payment_terms)
        if (data.uom_groups) setUOMGroups(data.uom_groups)
        if (data.material_status) setMaterialStatus(data.material_status)
        if (data.valuation_classes) setValuationClasses(data.valuation_classes)
        if (data.movement_types) setMovementTypes(data.movement_types)
        
        // Set additional data from API response
        if (data.chart_of_accounts) {
          const formattedGL = data.chart_of_accounts.map((account: any) => ({
            id: account.id,
            account_code: account.account_code,
            account_name: account.account_name,
            account_type: account.account_type,
            is_active: account.is_active || true
          }))
          setGLAccounts(formattedGL)
        }
        if (data.company_codes) setCompanyCodes(data.company_codes)
        if (data.plants) setPlants(data.plants)
        if (data.storage_locations) setStorageLocations(data.storage_locations)
        if (data.account_keys) setAccountKeys(data.account_keys)
        
        setAccountDetermination(data.account_determination || [])
        console.log('Account Determination data:', data.account_determination)
      } else {
        console.error('API Error:', result.error)
        setError('Failed to load configuration data. Please try again.')
      }
    } catch (error) {
      console.error('Error loading data:', error)
      setError('Failed to load configuration data. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  const handleAdd = (entity: string) => {
    setModalEntity(entity)
    setModalType('add')
    setEditingItem(null)
    setShowModal(true)
  }

  const handleEdit = (item: any, entity: string) => {
    setModalEntity(entity)
    setModalType('edit')
    setEditingItem(item)
    setShowModal(true)
  }

  const handleDelete = async (id: string, entity: string) => {
    if (!confirm('Are you sure you want to delete this configuration item?')) return
    
    try {
      const response = await fetch(`/api/erp-config?id=${id}&entity=${entity}`, {
        method: 'DELETE'
      })
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const result = await response.json()
      if (!result.success) {
        throw new Error(result.error)
      }
      
      loadData()
    } catch (error) {
      console.error('Error deleting:', error)
      setError('Failed to delete item. Please try again.')
    }
  }

  const handleSave = async (formData: any) => {
    try {
      const method = modalType === 'add' ? 'POST' : 'PUT'
      const body = modalType === 'edit' ? { ...formData, id: editingItem?.id } : formData
      
      const response = await fetch(`/api/erp-config?entity=${modalEntity}`, {
        method,
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(body)
      })
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      
      const result = await response.json()
      if (!result.success) {
        throw new Error(result.error)
      }
      
      setShowModal(false)
      loadData()
    } catch (error) {
      console.error('Error saving:', error)
      setError('Failed to save item. Please try again.')
    }
  }

  const tabs = [
    { id: 'materials', label: 'Materials', icon: Package },
    { id: 'finance', label: 'Finance', icon: DollarSign },
    { id: 'procurement', label: 'Procurement', icon: ShoppingCart },
    { id: 'organization', label: 'Organization', icon: Building },
    { id: 'projects', label: 'Projects', icon: FolderTree },
    { id: 'hr', label: 'HR', icon: Users },
    { id: 'system', label: 'System', icon: Settings }
  ]

  const filteredGLAccounts = useMemo(() => {
    if (!glSearchTerm) return glAccounts
    return glAccounts.filter(account => 
      account.account_code.toLowerCase().includes(glSearchTerm.toLowerCase()) ||
      account.account_name.toLowerCase().includes(glSearchTerm.toLowerCase()) ||
      account.account_type.toLowerCase().includes(glSearchTerm.toLowerCase())
    )
  }, [glAccounts, glSearchTerm])

  const filteredValuationClasses = useMemo(() => {
    if (!valuationSearchTerm) return valuationClasses
    return valuationClasses.filter(item => 
      item.class_code.toLowerCase().includes(valuationSearchTerm.toLowerCase()) ||
      item.class_name.toLowerCase().includes(valuationSearchTerm.toLowerCase())
    )
  }, [valuationClasses, valuationSearchTerm])

  const filteredMovementTypes = useMemo(() => {
    if (!movementSearchTerm) return movementTypes
    return movementTypes.filter(item => 
      item.movement_type.toLowerCase().includes(movementSearchTerm.toLowerCase()) ||
      item.movement_name.toLowerCase().includes(movementSearchTerm.toLowerCase())
    )
  }, [movementTypes, movementSearchTerm])

  const filteredMaterialGroups = useMemo(() => {
    if (!materialGroupSearchTerm) return materialGroups
    return materialGroups.filter(item => 
      item.group_code.toLowerCase().includes(materialGroupSearchTerm.toLowerCase()) ||
      item.group_name.toLowerCase().includes(materialGroupSearchTerm.toLowerCase())
    )
  }, [materialGroups, materialGroupSearchTerm])

  const filteredVendorCategories = useMemo(() => {
    if (!vendorCategorySearchTerm) return vendorCategories
    return vendorCategories.filter(item => 
      item.category_code.toLowerCase().includes(vendorCategorySearchTerm.toLowerCase()) ||
      item.category_name.toLowerCase().includes(vendorCategorySearchTerm.toLowerCase())
    )
  }, [vendorCategories, vendorCategorySearchTerm])

  const filteredPaymentTerms = useMemo(() => {
    if (!paymentTermSearchTerm) return paymentTerms
    return paymentTerms.filter(item => 
      item.term_code.toLowerCase().includes(paymentTermSearchTerm.toLowerCase()) ||
      item.term_name.toLowerCase().includes(paymentTermSearchTerm.toLowerCase())
    )
  }, [paymentTerms, paymentTermSearchTerm])

  const filteredUOMGroups = useMemo(() => {
    if (!uomSearchTerm) return uomGroups
    return uomGroups.filter(item => 
      item.base_uom.toLowerCase().includes(uomSearchTerm.toLowerCase()) ||
      item.uom_name.toLowerCase().includes(uomSearchTerm.toLowerCase())
    )
  }, [uomGroups, uomSearchTerm])

  const filteredMaterialStatus = useMemo(() => {
    if (!materialStatusSearchTerm) return materialStatus
    return materialStatus.filter(item => 
      item.status_code.toLowerCase().includes(materialStatusSearchTerm.toLowerCase()) ||
      item.status_name.toLowerCase().includes(materialStatusSearchTerm.toLowerCase())
    )
  }, [materialStatus, materialStatusSearchTerm])

  const renderConfigTable = (data: any[], entity: string, columns: string[], searchTerm?: string, setSearchTerm?: (term: string) => void) => (
    <div className="bg-white rounded-lg shadow-sm border p-4">
      <div className="flex justify-between items-center mb-4">
        <h3 className="text-lg font-semibold">
          {entity === 'groups' ? 'Material Groups' :
           entity === 'categories' ? 'Vendor Categories' :
           entity === 'terms' ? 'Payment Terms' :
           entity === 'uom' ? 'Units of Measure' :
           entity === 'status' ? 'Material Status' :
           entity === 'gl' ? 'GL Accounts' :
           entity === 'valuation' ? 'Valuation Classes' :
           entity === 'movements' ? 'Movement Types' :
           entity === 'companies' ? 'Company Codes' :
           entity === 'plants' ? 'Plants' :
           entity === 'locations' ? 'Storage Locations' : 'Configuration'}
        </h3>
        <button 
          onClick={() => handleAdd(entity)}
          className="flex items-center gap-2 px-3 py-1 bg-indigo-600 text-white rounded hover:bg-indigo-700 text-sm"
        >
          <Plus className="w-3 h-3" />
          Add
        </button>
      </div>
      
      {(entity === 'gl' || entity === 'valuation' || entity === 'movements' || entity === 'groups' || entity === 'categories' || entity === 'terms' || entity === 'uom' || entity === 'status') && searchTerm !== undefined && setSearchTerm && (
        <div className="mb-3 relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
          <input
            type="text"
            placeholder={`Search ${entity === 'gl' ? 'GL accounts' : entity === 'valuation' ? 'valuation classes' : entity === 'movements' ? 'movement types' : entity === 'groups' ? 'material groups' : entity === 'categories' ? 'vendor categories' : entity === 'terms' ? 'payment terms' : entity === 'uom' ? 'UoM groups' : 'material status'}...`}
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
          />
        </div>
      )}
      
      <div className={`overflow-x-auto ${(entity === 'gl' || entity === 'valuation' || entity === 'movements' || entity === 'groups' || entity === 'categories' || entity === 'terms' || entity === 'uom' || entity === 'status') ? 'max-h-96 overflow-y-auto' : ''}`}>
        <table className="w-full">
          <thead className={(entity === 'gl' || entity === 'valuation' || entity === 'movements' || entity === 'groups' || entity === 'categories' || entity === 'terms' || entity === 'uom' || entity === 'status') ? 'sticky top-0 bg-white' : ''}>
            <tr className="border-b">
              {columns.map(col => (
                <th key={col} className="text-left py-2 px-3 font-medium text-gray-700 text-sm">
                  {col}
                </th>
              ))}
              <th className="text-right py-2 px-3 text-sm">Actions</th>
            </tr>
          </thead>
          <tbody>
            {((entity === 'gl' || entity === 'valuation' || entity === 'movements' || entity === 'groups' || entity === 'categories' || entity === 'terms' || entity === 'uom' || entity === 'status') ? data : data.slice(0, 5)).map((item) => (
              <tr key={item.id} className="border-b hover:bg-gray-50">
                {columns.map(col => (
                  <td key={col} className="py-2 px-3 text-sm">
                    {col === 'Status' ? (
                      <span className={`px-2 py-1 rounded text-xs ${
                        item.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                      }`}>
                        {item.is_active ? 'Active' : 'Inactive'}
                      </span>
                    ) : col === 'Terms' ? (
                      <span className="text-xs">
                        {item.net_days} days
                        {item.discount_percent > 0 && ` (${item.discount_percent}%)`}
                      </span>
                    ) : col === 'Procurement' ? (
                      <span className={`px-1 py-0.5 rounded text-xs ${
                        item.allow_procurement ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                      }`}>
                        {item.allow_procurement ? 'Yes' : 'No'}
                      </span>
                    ) : col === 'Consumption' ? (
                      <span className={`px-1 py-0.5 rounded text-xs ${
                        item.allow_consumption ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                      }`}>
                        {item.allow_consumption ? 'Yes' : 'No'}
                      </span>
                    ) : col === 'Indicator' ? (
                      <span className="font-mono text-xs">{item.movement_indicator}</span>
                    ) : col === 'Type' && entity === 'gl' ? (
                      <span className={`px-2 py-1 rounded text-xs ${
                        item.account_type === 'ASSET' ? 'bg-blue-100 text-blue-800' :
                        item.account_type === 'LIABILITY' ? 'bg-red-100 text-red-800' :
                        item.account_type === 'REVENUE' ? 'bg-green-100 text-green-800' :
                        item.account_type === 'EXPENSE' ? 'bg-orange-100 text-orange-800' :
                        item.account_type === 'WIP' ? 'bg-purple-100 text-purple-800' :
                        item.account_type === 'COGS' ? 'bg-yellow-100 text-yellow-800' :
                        'bg-gray-100 text-gray-800'
                      }`}>
                        {item.account_type}
                      </span>
                    ) : (
                      item[col.toLowerCase().replace(' ', '_')] || 
                      item[col.toLowerCase().replace(' ', '')] ||
                      item[Object.keys(item).find(k => k.includes(col.toLowerCase().split(' ')[0])) || '']
                    )}
                  </td>
                ))}
                <td className="py-2 px-3 text-right">
                  <div className="flex justify-end gap-1">
                    <button 
                      onClick={() => handleEdit(item, entity)}
                      className="p-1 text-blue-600 hover:bg-blue-100 rounded"
                    >
                      <Edit2 className="w-3 h-3" />
                    </button>
                    <button 
                      onClick={() => handleDelete(item.id, entity)}
                      className="p-1 text-red-600 hover:bg-red-100 rounded"
                    >
                      <Trash2 className="w-3 h-3" />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {entity !== 'gl' && entity !== 'valuation' && entity !== 'movements' && entity !== 'groups' && entity !== 'categories' && entity !== 'terms' && entity !== 'uom' && entity !== 'status' && data.length > 5 && (
          <div className="text-center py-2 text-sm text-gray-500">
            ... and {data.length - 5} more items
          </div>
        )}
        {(entity === 'gl' || entity === 'valuation' || entity === 'movements' || entity === 'groups' || entity === 'categories' || entity === 'terms' || entity === 'uom' || entity === 'status') && (
          <div className="text-center py-2 text-sm text-gray-500">
            Showing {data.length} items
          </div>
        )}
      </div>
    </div>
  )

  const renderModal = () => {
    if (!showModal) return null

    const renderFormFields = () => {
      if (modalEntity === 'companies') {
        return (
          <>
            <input name="company_code" placeholder="Company Code" defaultValue={editingItem?.company_code || ''} className="w-full p-2 border rounded mb-3" required />
            <input name="company_name" placeholder="Company Name" defaultValue={editingItem?.company_name || ''} className="w-full p-2 border rounded mb-3" required />
            <input name="currency" placeholder="Currency" defaultValue={editingItem?.currency || ''} className="w-full p-2 border rounded mb-3" required />
            <input name="country" placeholder="Country" defaultValue={editingItem?.country || ''} className="w-full p-2 border rounded mb-3" required />
          </>
        )
      } else if (modalEntity === 'plants') {
        return (
          <>
            <input name="plant_code" placeholder="Plant Code" defaultValue={editingItem?.plant_code || ''} className="w-full p-2 border rounded mb-3" required />
            <input name="plant_name" placeholder="Plant Name" defaultValue={editingItem?.plant_name || ''} className="w-full p-2 border rounded mb-3" required />
            <select name="company_code_id" className="w-full p-2 border rounded mb-3" required defaultValue={editingItem?.company_code_id || ''}>
              <option value="">Select Company</option>
              {companyCodes.map(cc => (
                <option key={cc.id} value={cc.id}>{cc.company_code} - {cc.company_name}</option>
              ))}
            </select>
            <select name="plant_type" className="w-full p-2 border rounded mb-3" defaultValue={editingItem?.plant_type || 'PROJECT'}>
              <option value="PROJECT">Project Site</option>
              <option value="WAREHOUSE">Warehouse</option>
              <option value="OFFICE">Office</option>
            </select>
          </>
        )
      } else if (modalEntity === 'locations') {
        return (
          <>
            <input name="sloc_code" placeholder="Storage Location Code" defaultValue={editingItem?.sloc_code || ''} className="w-full p-2 border rounded mb-3" required />
            <input name="sloc_name" placeholder="Location Name" defaultValue={editingItem?.sloc_name || ''} className="w-full p-2 border rounded mb-3" required />
            <select name="plant_id" className="w-full p-2 border rounded mb-3" required defaultValue={editingItem?.plant_id || ''}>
              <option value="">Select Plant</option>
              {plants.map(p => (
                <option key={p.id} value={p.id}>{p.plant_code} - {p.plant_name}</option>
              ))}
            </select>
            <select name="location_type" className="w-full p-2 border rounded mb-3" defaultValue={editingItem?.location_type || 'WAREHOUSE'}>
              <option value="WAREHOUSE">Warehouse</option>
              <option value="YARD">Yard</option>
              <option value="OFFICE">Office</option>
              <option value="STAGING">Staging Area</option>
            </select>
          </>
        )
      } else if (modalEntity === 'categories') {
        return (
          <>
            <input name="category_code" placeholder="Category Code" defaultValue={editingItem?.category_code || ''} className="w-full p-2 border rounded mb-3" required />
            <input name="category_name" placeholder="Category Name" defaultValue={editingItem?.category_name || ''} className="w-full p-2 border rounded mb-3" required />
            <input name="description" placeholder="Description" defaultValue={editingItem?.description || ''} className="w-full p-2 border rounded mb-3" />
          </>
        )
      } else if (modalEntity === 'gl') {
        return (
          <>
            <input name="account_code" placeholder="Account Code" defaultValue={editingItem?.account_code || ''} className="w-full p-2 border rounded mb-3" required />
            <input name="account_name" placeholder="Account Name" defaultValue={editingItem?.account_name || ''} className="w-full p-2 border rounded mb-3" required />
            <select name="account_type" className="w-full p-2 border rounded mb-3" required defaultValue={editingItem?.account_type || ''}>
              <option value="">Select Account Type</option>
              <option value="ASSET">Asset</option>
              <option value="LIABILITY">Liability</option>
              <option value="REVENUE">Revenue</option>
              <option value="EXPENSE">Expense</option>
              <option value="WIP">Work in Progress</option>
              <option value="COGS">Cost of Goods Sold</option>
            </select>
            <textarea name="description" placeholder="Description" defaultValue={editingItem?.description || ''} className="w-full p-2 border rounded mb-3" rows={3} />
          </>
        )
      } else if (modalEntity === 'valuation') {
        return (
          <>
            <input name="class_code" placeholder="Class Code" defaultValue={editingItem?.class_code || ''} className="w-full p-2 border rounded mb-3" required />
            <input name="class_name" placeholder="Class Name" defaultValue={editingItem?.class_name || ''} className="w-full p-2 border rounded mb-3" required />
            <textarea name="description" placeholder="Description" defaultValue={editingItem?.description || ''} className="w-full p-2 border rounded mb-3" rows={3} />
          </>
        )
      } else if (modalEntity === 'movements') {
        return (
          <>
            <input name="movement_type" placeholder="Movement Type" defaultValue={editingItem?.movement_type || ''} className="w-full p-2 border rounded mb-3" required />
            <input name="movement_name" placeholder="Movement Name" defaultValue={editingItem?.movement_name || ''} className="w-full p-2 border rounded mb-3" required />
            <select name="movement_indicator" className="w-full p-2 border rounded mb-3" required defaultValue={editingItem?.movement_indicator || ''}>
              <option value="">Select Indicator</option>
              <option value="+">+ (Goods Receipt)</option>
              <option value="-">- (Goods Issue)</option>
              <option value="=">=  (Transfer)</option>
            </select>
            <textarea name="description" placeholder="Description" defaultValue={editingItem?.description || ''} className="w-full p-2 border rounded mb-3" rows={3} />
          </>
        )
      } else if (modalEntity === 'terms') {
        return (
          <>
            <input name="term_code" placeholder="Term Code" defaultValue={editingItem?.term_code || ''} className="w-full p-2 border rounded mb-3" required />
            <input name="term_name" placeholder="Term Name" defaultValue={editingItem?.term_name || ''} className="w-full p-2 border rounded mb-3" required />
            <input name="net_days" type="number" placeholder="Net Days" defaultValue={editingItem?.net_days || ''} className="w-full p-2 border rounded mb-3" required />
            <input name="discount_days" type="number" placeholder="Discount Days" defaultValue={editingItem?.discount_days || 0} className="w-full p-2 border rounded mb-3" />
            <input name="discount_percent" type="number" step="0.01" placeholder="Discount %" defaultValue={editingItem?.discount_percent || 0} className="w-full p-2 border rounded mb-3" />
          </>
        )
      } else if (modalEntity === 'status') {
        return (
          <>
            <input name="status_code" placeholder="Status Code" defaultValue={editingItem?.status_code || ''} className="w-full p-2 border rounded mb-3" required />
            <input name="status_name" placeholder="Status Name" defaultValue={editingItem?.status_name || ''} className="w-full p-2 border rounded mb-3" required />
            <div className="flex gap-4 mb-3">
              <label className="flex items-center">
                <input name="allow_procurement" type="checkbox" defaultChecked={editingItem?.allow_procurement || false} className="mr-2" />
                Allow Procurement
              </label>
              <label className="flex items-center">
                <input name="allow_consumption" type="checkbox" defaultChecked={editingItem?.allow_consumption || false} className="mr-2" />
                Allow Consumption
              </label>
            </div>
          </>
        )
      } else if (modalEntity === 'uom') {
        return (
          <>
            <input name="base_uom" placeholder="Base UoM" defaultValue={editingItem?.base_uom || ''} className="w-full p-2 border rounded mb-3" required />
            <input name="uom_name" placeholder="UoM Name" defaultValue={editingItem?.uom_name || ''} className="w-full p-2 border rounded mb-3" required />
            <select name="dimension" className="w-full p-2 border rounded mb-3" defaultValue={editingItem?.dimension || ''}>
              <option value="">Select Dimension</option>
              <option value="LENGTH">Length</option>
              <option value="WEIGHT">Weight</option>
              <option value="VOLUME">Volume</option>
              <option value="AREA">Area</option>
              <option value="TIME">Time</option>
              <option value="QUANTITY">Quantity</option>
            </select>
          </>
        )
      } else {
        return (
          <>
            <input name="group_code" placeholder="Group Code" defaultValue={editingItem?.group_code || ''} className="w-full p-2 border rounded mb-3" required />
            <input name="group_name" placeholder="Group Name" defaultValue={editingItem?.group_name || ''} className="w-full p-2 border rounded mb-3" required />
            <input name="description" placeholder="Description" defaultValue={editingItem?.description || ''} className="w-full p-2 border rounded mb-3" />
          </>
        )
      }
    }

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
        <div className="bg-white rounded-lg max-w-md w-full p-6">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-lg font-semibold">
              {modalType === 'add' ? 'Add' : 'Edit'} {
                modalEntity === 'companies' ? 'Company Code' :
                modalEntity === 'plants' ? 'Plant' :
                modalEntity === 'locations' ? 'Storage Location' :
                modalEntity === 'groups' ? 'Material Group' :
                modalEntity === 'categories' ? 'Vendor Category' :
                modalEntity === 'terms' ? 'Payment Term' :
                modalEntity === 'uom' ? 'Unit of Measure' :
                modalEntity === 'status' ? 'Material Status' :
                modalEntity === 'gl' ? 'GL Account' :
                modalEntity === 'valuation' ? 'Valuation Class' :
                modalEntity === 'movements' ? 'Movement Type' :
                'Configuration'
              }
            </h3>
            <button onClick={() => setShowModal(false)} className="text-gray-500 hover:text-gray-700">
              <X className="w-5 h-5" />
            </button>
          </div>
          
          <form onSubmit={(e) => {
            e.preventDefault()
            const formData = new FormData(e.target as HTMLFormElement)
            const data = Object.fromEntries(formData.entries())
            
            // Handle checkboxes for material status
            if (modalEntity === 'status') {
              data.allow_procurement = formData.has('allow_procurement')
              data.allow_consumption = formData.has('allow_consumption')
            }
            
            // Convert numeric fields
            if (modalEntity === 'terms') {
              data.net_days = parseInt(data.net_days as string)
              data.discount_days = parseInt(data.discount_days as string) || 0
              data.discount_percent = parseFloat(data.discount_percent as string) || 0
            }
            
            data.is_active = true
            handleSave(data)
          }}>
            {renderFormFields()}
            
            <div className="flex gap-2 justify-end">
              <button type="button" onClick={() => setShowModal(false)} className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50">
                Cancel
              </button>
              <button type="submit" className="px-4 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700">
                {modalType === 'add' ? 'Add' : 'Update'}
              </button>
            </div>
          </form>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-50 to-purple-100 p-4">
      <div className="max-w-7xl mx-auto">
        <div className="mb-6">
        </div>

        {/* Tab navigation */}
        <div className="bg-white rounded-lg shadow-sm border mb-6">
          <div className="flex overflow-x-auto">
            {tabs.map((tab) => {
              const Icon = tab.icon
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`flex items-center gap-2 px-4 py-3 whitespace-nowrap border-b-2 transition-colors ${
                    activeTab === tab.id
                      ? 'border-indigo-500 text-indigo-600 bg-indigo-50'
                      : 'border-transparent text-gray-600 hover:text-gray-900 hover:bg-gray-50'
                  }`}
                >
                  <Icon className="w-4 h-4" />
                  <span className="hidden sm:inline">{tab.label}</span>
                </button>
              )
            })}
          </div>
        </div>

        {/* Tab content */}
        <div className="transition-all duration-200">
          {loading ? (
            <div className="bg-white rounded-lg shadow-sm border p-8 text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600 mx-auto"></div>
              <p className="mt-2 text-gray-600">Loading configuration...</p>
            </div>
          ) : (
            <>
              {activeTab === 'materials' && (
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                  {renderConfigTable(filteredMaterialGroups, 'groups', ['Code', 'Name', 'Description', 'Status'], materialGroupSearchTerm, setMaterialGroupSearchTerm)}
                  {renderConfigTable(filteredMaterialStatus, 'status', ['Code', 'Name', 'Procurement', 'Consumption'], materialStatusSearchTerm, setMaterialStatusSearchTerm)}
                  {renderConfigTable(filteredUOMGroups, 'uom', ['UoM', 'Name', 'Dimension', 'Status'], uomSearchTerm, setUomSearchTerm)}
                  {renderConfigTable(filteredMovementTypes, 'movements', ['Type', 'Name', 'Indicator', 'Status'], movementSearchTerm, setMovementSearchTerm)}
                </div>
              )}
              {activeTab === 'finance' && (
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                  {renderConfigTable(filteredGLAccounts, 'gl', ['Code', 'Name', 'Type', 'Status'], glSearchTerm, setGlSearchTerm)}
                  {renderConfigTable(filteredValuationClasses, 'valuation', ['Code', 'Name', 'Description', 'Status'], valuationSearchTerm, setValuationSearchTerm)}
                  
                  {/* Account Determination */}
                  <div className="lg:col-span-2">
                    <div className="bg-white rounded-lg shadow-sm border p-4">
                      <div className="flex justify-between items-center mb-4">
                        <h3 className="text-lg font-semibold">Account Determination</h3>
                        <span className="text-sm text-gray-500">Company + Valuation Class + Account Key → GL Account</span>
                      </div>
                      
                      <div className="overflow-x-auto">
                        <table className="w-full">
                          <thead className="bg-gray-50">
                            <tr>
                              <th className="text-left py-2 px-3 font-medium text-gray-700 text-sm">Company</th>
                              <th className="text-left py-2 px-3 font-medium text-gray-700 text-sm">Valuation Class</th>
                              <th className="text-left py-2 px-3 font-medium text-gray-700 text-sm">Account Key</th>
                              <th className="text-left py-2 px-3 font-medium text-gray-700 text-sm">GL Account</th>
                              <th className="text-left py-2 px-3 font-medium text-gray-700 text-sm">Status</th>
                            </tr>
                          </thead>
                          <tbody>
                        {accountDetermination.length === 0 ? (
                          <tr>
                            <td colSpan={5} className="py-4 px-3 text-center text-gray-500 text-sm">
                              No account determination entries found. Please add some mappings.
                            </td>
                          </tr>
                        ) : (
                          accountDetermination.slice(0, 10).map((item) => {
                            const company = companyCodes.find(c => c.id === item.company_code_id)
                            const valuationClass = valuationClasses.find(v => v.id === item.valuation_class_id)
                            const accountKey = accountKeys.find(a => a.id === item.account_key_id)
                            const glAccount = glAccounts.find(g => g.id === item.gl_account_id)
                            
                            return (
                              <tr key={item.id} className="border-b hover:bg-gray-50">
                                <td className="py-2 px-3 text-sm font-mono">
                                  {company?.company_code || 'N/A'}
                                </td>
                                <td className="py-2 px-3 text-sm">
                                  <span className="px-2 py-1 bg-blue-100 text-blue-800 rounded text-xs">
                                    {valuationClass?.class_code || 'N/A'}
                                  </span>
                                </td>
                                <td className="py-2 px-3 text-sm">
                                  <span className="px-2 py-1 bg-green-100 text-green-800 rounded text-xs">
                                    {accountKey?.account_key_code || 'N/A'}
                                  </span>
                                </td>
                                <td className="py-2 px-3 text-sm font-mono">
                                  {glAccount?.account_code || 'N/A'}
                                </td>
                                <td className="py-2 px-3 text-sm">
                                  <span className={`px-2 py-1 rounded text-xs ${
                                    item.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                                  }`}>
                                    {item.is_active ? 'Active' : 'Inactive'}
                                  </span>
                                </td>
                              </tr>
                            )
                          })
                        )}
                          </tbody>
                        </table>
                        {accountDetermination.length > 10 && (
                          <div className="text-center py-2 text-sm text-gray-500">
                            ... and {accountDetermination.length - 10} more entries
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                </div>
              )}
              {activeTab === 'procurement' && (
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                  {renderConfigTable(filteredVendorCategories, 'categories', ['Code', 'Name', 'Description', 'Status'], vendorCategorySearchTerm, setVendorCategorySearchTerm)}
                  {renderConfigTable(filteredPaymentTerms, 'terms', ['Code', 'Name', 'Terms', 'Status'], paymentTermSearchTerm, setPaymentTermSearchTerm)}
                </div>
              )}
              {activeTab === 'organization' && (
                <div className="bg-white rounded-lg shadow-sm border p-4">
                  <div className="flex justify-between items-center mb-4">
                    <h3 className="text-lg font-semibold flex items-center gap-2">
                      <Building className="w-5 h-5" />
                      Organizational Structure
                    </h3>
                    <div className="flex gap-2">
                      <button 
                        onClick={() => handleAdd('companies')}
                        className="flex items-center gap-2 px-3 py-1 bg-blue-600 text-white rounded hover:bg-blue-700 text-sm"
                      >
                        <Plus className="w-3 h-3" />
                        Add Company
                      </button>
                      <button 
                        onClick={() => handleAdd('plants')}
                        className="flex items-center gap-2 px-3 py-1 bg-green-600 text-white rounded hover:bg-green-700 text-sm"
                      >
                        <Plus className="w-3 h-3" />
                        Add Plant
                      </button>
                    </div>
                  </div>
                  
                  <div className="space-y-2 max-h-96 overflow-y-auto">
                    {error && (
                      <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded mb-4">
                        {error}
                        <button onClick={() => setError(null)} className="ml-2 text-red-500 hover:text-red-700">×</button>
                      </div>
                    )}
                    {companyCodes.map((company) => {
                      const companyPlants = plantsByCompany.get(company.id) || []
                      const isExpanded = expandedCompanies.has(company.id)
                      
                      return (
                        <div key={company.id} className="border rounded-lg">
                          <div 
                            className="flex items-center justify-between p-3 hover:bg-gray-50 cursor-pointer"
                            onClick={() => {
                              const newExpanded = new Set(expandedCompanies)
                              if (newExpanded.has(company.id)) {
                                newExpanded.delete(company.id)
                              } else {
                                newExpanded.add(company.id)
                              }
                              setExpandedCompanies(newExpanded)
                            }}
                          >
                            <div className="flex items-center gap-3">
                              <span className="text-sm">{isExpanded ? '▼' : '▶'}</span>
                              <span className="text-lg">🏢</span>
                              <div>
                                <span className="font-medium text-sm">{company.company_code}</span>
                                <span className="text-gray-600 ml-2 text-sm">{company.company_name}</span>
                              </div>
                            </div>
                            <div className="flex items-center gap-1">
                              <button 
                                onClick={(e) => { e.stopPropagation(); handleEdit(company, 'companies'); }}
                                className="p-1 text-blue-600 hover:bg-blue-100 rounded"
                              >
                                <Edit2 className="w-3 h-3" />
                              </button>
                              <button 
                                onClick={(e) => { e.stopPropagation(); handleDelete(company.id, 'companies'); }}
                                className="p-1 text-red-600 hover:bg-red-100 rounded"
                              >
                                <Trash2 className="w-3 h-3" />
                              </button>
                            </div>
                          </div>
                          
                          {isExpanded && (
                            <div className="pl-8 pb-3">
                              <div className="flex justify-between items-center mb-2">
                                <span className="text-sm font-medium text-gray-700">Plants</span>
                                <button 
                                  onClick={() => handleAdd('plants')}
                                  className="text-xs px-2 py-1 bg-green-600 text-white rounded hover:bg-green-700"
                                >
                                  + Plant
                                </button>
                              </div>
                              {companyPlants.map((plant) => {
                                const plantStorages = storagesByPlant.get(plant.id) || []
                                
                                return (
                                  <div key={plant.id} className="ml-4 mb-2">
                                    <div className="flex items-center justify-between p-2 bg-gray-50 rounded">
                                      <div className="flex items-center gap-2">
                                        <span className="text-lg">🏭</span>
                                        <span className="font-medium text-sm">{plant.plant_code}</span>
                                        <span className="text-gray-600 text-sm">{plant.plant_name}</span>
                                      </div>
                                      <div className="flex items-center gap-1">
                                        <button 
                                          onClick={() => handleAdd('locations')}
                                          className="text-xs px-1 py-0.5 bg-orange-600 text-white rounded hover:bg-orange-700"
                                        >
                                          + Storage
                                        </button>
                                        <button 
                                          onClick={() => handleEdit(plant, 'plants')}
                                          className="p-1 text-blue-600 hover:bg-blue-100 rounded"
                                        >
                                          <Edit2 className="w-3 h-3" />
                                        </button>
                                        <button 
                                          onClick={() => handleDelete(plant.id, 'plants')}
                                          className="p-1 text-red-600 hover:bg-red-100 rounded"
                                        >
                                          <Trash2 className="w-3 h-3" />
                                        </button>
                                      </div>
                                    </div>
                                    
                                    {plantStorages.length > 0 && (
                                      <div className="ml-6 mt-1 space-y-1">
                                        {plantStorages.map((storage) => (
                                          <div key={storage.id} className="flex items-center justify-between p-1 text-sm">
                                            <div className="flex items-center gap-2">
                                              <span>📦</span>
                                              <span className="font-medium">{storage.sloc_code}</span>
                                              <span className="text-gray-600">{storage.sloc_name}</span>
                                            </div>
                                            <div className="flex items-center gap-1">
                                              <button 
                                                onClick={() => handleEdit(storage, 'locations')}
                                                className="p-1 text-blue-600 hover:bg-blue-100 rounded"
                                              >
                                                <Edit2 className="w-2 h-2" />
                                              </button>
                                              <button 
                                                onClick={() => handleDelete(storage.id, 'locations')}
                                                className="p-1 text-red-600 hover:bg-red-100 rounded"
                                              >
                                                <Trash2 className="w-2 h-2" />
                                              </button>
                                            </div>
                                          </div>
                                        ))}
                                      </div>
                                    )}
                                  </div>
                                )
                              })}
                            </div>
                          )}
                        </div>
                      )
                    })}
                  </div>
                </div>
              )}
              {activeTab === 'projects' && (
                <EnhancedProjectsConfigTab />
              )}
              {activeTab === 'hr' && (
                <div className="bg-white rounded-lg shadow-sm border p-8 text-center">
                  <Users className="w-12 h-12 mx-auto mb-4 opacity-50" />
                  <p className="text-gray-500">HR configuration coming soon...</p>
                  <p className="text-sm text-gray-400">Employee groups, Pay scales, Leave types</p>
                </div>
              )}
              {activeTab === 'system' && (
                <div className="bg-white rounded-lg shadow-sm border p-8 text-center">
                  <Settings className="w-12 h-12 mx-auto mb-4 opacity-50" />
                  <p className="text-gray-500">System configuration coming soon...</p>
                  <p className="text-sm text-gray-400">User roles, Number ranges, Document types</p>
                </div>
              )}
            </>
          )}
        </div>
        
        {renderModal()}
      </div>
    </div>
  )
}