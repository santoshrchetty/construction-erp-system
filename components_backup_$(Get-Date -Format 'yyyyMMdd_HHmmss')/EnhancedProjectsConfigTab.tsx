'use client'

import { useState, useEffect } from 'react'
import { Plus, Edit2, Trash2, Search, X, Check, AlertCircle, Loader2 } from 'lucide-react'
import { projectConfigService, ProjectCategory, GLDeterminationRule } from '../domains/projects/projectConfigServices'
import { dependentDropdownService } from '../domains/projects/dependentDropdownService'
import { realTimeValidationService } from '../domains/validation/realTimeValidationService'
import HSNSelectionPopup from './HSNSelectionPopup'
import { CONFIG } from '../lib/projectConfig'

interface FormErrors {
  [key: string]: string
}

interface NumberingRule {
  id: string
  entity_type: string
  pattern: string
  current_number: number
  description?: string
  is_active: boolean
  company_code: string
  created_at: string
  updated_at: string
}

interface ProjectType {
  id: string
  type_code: string
  type_name: string
  category_code: string
  gl_posting_variant?: string
  description?: string
  is_active: boolean
  company_code: string
  sort_order: number
  created_at: string
  updated_at: string
}

export default function EnhancedProjectsConfigTab() {
  const [activeSubTab, setActiveSubTab] = useState('categories')
  const [projectCategories, setProjectCategories] = useState<ProjectCategory[]>([])
  const [projectTypes, setProjectTypes] = useState<ProjectType[]>([])
  const [glRules, setGLRules] = useState<GLDeterminationRule[]>([])
  const [numberingRules, setNumberingRules] = useState<NumberingRule[]>([])
  const [loading, setLoading] = useState(false)
  const [showModal, setShowModal] = useState(false)
  const [modalType, setModalType] = useState<'create' | 'edit'>('create')
  const [editingItem, setEditingItem] = useState<any>(null)
  const [searchTerm, setSearchTerm] = useState('')
  const [errors, setErrors] = useState<FormErrors>({})
  const [submitting, setSubmitting] = useState(false)
  const [notification, setNotification] = useState<{ type: 'success' | 'error', message: string } | null>(null)
  const [showHSNPopup, setShowHSNPopup] = useState(false)
  const [hsnOptions, setHsnOptions] = useState<any[]>([])
  const [selectedMaterialGroup, setSelectedMaterialGroup] = useState('')
  const [dependentTypes, setDependentTypes] = useState<ProjectType[]>([])

  const subTabs = [
    { id: 'categories', name: 'Categories', icon: '🏗️' },
    { id: 'types', name: 'Project Types', icon: '📋' },
    { id: 'gl-rules', name: 'GL Rules', icon: '💰' },
    { id: 'numbering', name: 'Numbering', icon: '#️⃣' },
    { id: 'workflows', name: 'Workflows', icon: '🔄' }
  ]

  useEffect(() => {
    loadData()
  }, [activeSubTab])

  const loadData = async () => {
    setLoading(true)
    try {
      switch (activeSubTab) {
        case 'categories':
          const categories = await projectConfigService.getProjectCategories()
          setProjectCategories(categories)
          break
        case 'types':
          const types = await projectConfigService.getProjectTypes()
          setProjectTypes(types)
          break
        case 'gl-rules':
          const rules = await projectConfigService.getGLRules()
          setGLRules(rules)
          break
        case 'numbering':
          const numbering = await projectConfigService.getNumberingRules()
          setNumberingRules(numbering)
          break
        case 'workflows':
          const workflows = await projectConfigService.getWorkflows()
          console.log('Workflows loaded:', workflows)
          break
      }
    } catch (error) {
      showNotification('error', 'Failed to load data')
    } finally {
      setLoading(false)
    }
  }

  const showNotification = (type: 'success' | 'error', message: string) => {
    setNotification({ type, message })
    setTimeout(() => setNotification(null), CONFIG.UI.NOTIFICATION_TIMEOUT_MS)
  }

  const validateForm = (data: any): FormErrors => {
    const errors: FormErrors = {}
    
    if (activeSubTab === 'categories') {
      if (!data.category_code?.trim()) errors.category_code = 'Code is required'
      if (!data.category_name?.trim()) errors.category_name = 'Name is required'
      if (!data.cost_ownership?.trim()) errors.cost_ownership = 'Cost ownership is required'
    }
    
    if (activeSubTab === 'types') {
      if (!data.type_code?.trim()) errors.type_code = 'Type code is required'
      if (!data.type_name?.trim()) errors.type_name = 'Type name is required'
      if (!data.category_code?.trim()) errors.category_code = 'Category code is required'
    }
    
    if (activeSubTab === 'gl-rules') {
      if (!data.project_category?.trim()) errors.project_category = 'Category is required'
      if (!data.event_type?.trim()) errors.event_type = 'Event type is required'
      if (!data.gl_account_type?.trim()) errors.gl_account_type = 'GL account type is required'
      if (!data.debit_credit) errors.debit_credit = 'Debit/Credit is required'
      if (!data.posting_key?.trim()) errors.posting_key = 'Posting key is required'
      
      // Real-time HSN validation
      if (data.hsn_sac_code) {
        const hsnValidation = realTimeValidationService.validateHSNCode(data.hsn_sac_code)
        if (!hsnValidation.isValid) {
          errors.hsn_sac_code = hsnValidation.errors[0]
        }
      }
      
      // Real-time GL account validation
      if (data.gl_account_range) {
        const glValidation = realTimeValidationService.validateGLAccount(data.gl_account_range, data.gl_account_type)
        if (!glValidation.isValid) {
          errors.gl_account_range = glValidation.errors[0]
        }
      }
    }
    
    if (activeSubTab === 'numbering') {
      if (!data.entity_type?.trim()) errors.entity_type = 'Entity type is required'
      if (!data.pattern?.trim()) errors.pattern = 'Pattern is required'
      if (!data.current_number || isNaN(Number(data.current_number))) errors.current_number = 'Valid current number is required'
    }
    
    return errors
  }

  const handleSubmit = async (formData: FormData) => {
    setSubmitting(true)
    setErrors({})
    
    try {
      const data = Object.fromEntries(formData.entries())
      const validationErrors = validateForm(data)
      
      if (Object.keys(validationErrors).length > 0) {
        setErrors(validationErrors)
        return
      }

      if (activeSubTab === 'categories') {
        if (modalType === 'create') {
          await projectConfigService.createProjectCategory(data as any)
          showNotification('success', 'Category created successfully')
        } else {
          await projectConfigService.updateProjectCategory(editingItem.id, data as any)
          showNotification('success', 'Category updated successfully')
        }
      } else if (activeSubTab === 'types') {
        if (modalType === 'create') {
          await projectConfigService.createProjectType(data as any)
          showNotification('success', 'Project type created successfully')
        } else {
          await projectConfigService.updateProjectType(editingItem.id, data as any)
          showNotification('success', 'Project type updated successfully')
        }
      } else if (activeSubTab === 'gl-rules') {
        if (modalType === 'create') {
          await projectConfigService.createGLRule(data as any)
          showNotification('success', 'GL rule created successfully')
        } else {
          await projectConfigService.updateGLRule(editingItem.id, data as any)
          showNotification('success', 'GL rule updated successfully')
        }
      } else if (activeSubTab === 'numbering') {
        if (modalType === 'create') {
          await projectConfigService.createNumberingRule(data as any)
          showNotification('success', 'Numbering rule created successfully')
        } else {
          await projectConfigService.updateNumberingRule(editingItem.id, data as any)
          showNotification('success', 'Numbering rule updated successfully')
        }
      }

      setShowModal(false)
      setEditingItem(null)
      loadData()
    } catch (error) {
      showNotification('error', 'Operation failed')
    } finally {
      setSubmitting(false)
    }
  }

  const handleCategoryChange = async (categoryCode: string) => {
    if (categoryCode && activeSubTab === 'types') {
      try {
        const types = await dependentDropdownService.loadProjectTypes(categoryCode)
        setDependentTypes(types)
      } catch (error) {
        console.error('Failed to load project types:', error)
      }
    }
  }

  const handleHSNSelection = (selectedHSN: any) => {
    console.log('HSN selected:', selectedHSN)
    setShowHSNPopup(false)
  }

  const handleMaterialCodeBlur = async (materialCode: string) => {
    if (materialCode && activeSubTab === 'gl-rules') {
      try {
        const hsnResult = await dependentDropdownService.getHSNOptions(materialCode)
        if (hsnResult.requiresSelection) {
          setHsnOptions(hsnResult.options)
          setSelectedMaterialGroup(hsnResult.materialGroup)
          setShowHSNPopup(true)
        }
      } catch (error) {
        console.error('Failed to get HSN options:', error)
      }
    }
  }

  const handleDelete = async (id: string) => {
    if (!confirm('Are you sure you want to delete this item?')) return
    
    try {
      if (activeSubTab === 'categories') {
        await projectConfigService.deleteProjectCategory(id)
        showNotification('success', 'Category deleted successfully')
      } else if (activeSubTab === 'types') {
        await projectConfigService.deleteProjectType(id)
        showNotification('success', 'Project type deleted successfully')
      } else if (activeSubTab === 'gl-rules') {
        await projectConfigService.deleteGLRule(id)
        showNotification('success', 'GL rule deleted successfully')
      } else if (activeSubTab === 'numbering') {
        await projectConfigService.deleteNumberingRule(id)
        showNotification('success', 'Numbering rule deleted successfully')
      }
      loadData()
    } catch (error) {
      showNotification('error', 'Delete failed')
    }
  }

  const filteredData = () => {
    let data
    switch (activeSubTab) {
      case 'categories': data = projectCategories; break
      case 'types': data = projectTypes; break
      case 'gl-rules': data = glRules; break
      case 'numbering': data = numberingRules; break
      default: data = []
    }
    
    if (!searchTerm) return data
    return data.filter((item: any) => 
      Object.values(item).some(value => 
        String(value).toLowerCase().includes(searchTerm.toLowerCase())
      )
    )
  }

  return (
    <div className="bg-white rounded-lg shadow-sm border">
      {notification && (
        <div className={`fixed top-4 right-4 z-50 p-4 rounded-lg shadow-lg ${
          notification.type === 'success' ? 'bg-green-500' : 'bg-red-500'
        } text-white`}>
          <div className="flex items-center gap-2">
            {notification.type === 'success' ? <Check className="w-4 h-4" /> : <AlertCircle className="w-4 h-4" />}
            {notification.message}
          </div>
        </div>
      )}

      <div className="border-b border-gray-200 p-4">
        <div className="flex overflow-x-auto gap-2 pb-2">
          {subTabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveSubTab(tab.id)}
              className={`flex items-center gap-2 px-4 py-2 rounded-lg whitespace-nowrap text-sm font-medium transition-colors ${
                activeSubTab === tab.id
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              <span>{tab.icon}</span>
              <span className="hidden sm:inline">{tab.name}</span>
            </button>
          ))}
        </div>
      </div>

      <div className="p-4 border-b border-gray-200">
        <div className="flex flex-col sm:flex-row gap-4 justify-between">
          <div className="relative flex-1 max-w-md">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input
              type="text"
              placeholder="Search..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
          <button
            onClick={() => {
              setModalType('create')
              setEditingItem(null)
              setShowModal(true)
              setErrors({})
            }}
            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            <Plus className="w-4 h-4" />
            <span className="hidden sm:inline">Add New</span>
            <span className="sm:hidden">Add</span>
          </button>
        </div>
      </div>

      <div className="p-4">
        {loading ? (
          <div className="flex items-center justify-center h-32">
            <Loader2 className="w-8 h-8 animate-spin text-blue-600" />
          </div>
        ) : (
          <>
            <div className="block sm:hidden space-y-3">
              {filteredData().map((item: any) => (
                <div key={item.id} className="bg-gray-50 rounded-lg p-4">
                  {activeSubTab === 'categories' && (
                    <CategoryCard 
                      item={item} 
                      onEdit={(item) => {
                        setEditingItem(item)
                        setModalType('edit')
                        setShowModal(true)
                      }} 
                      onDelete={handleDelete} 
                    />
                  )}
                  {activeSubTab === 'types' && (
                    <TypeCard 
                      item={item} 
                      onEdit={(item) => {
                        setEditingItem(item)
                        setModalType('edit')
                        setShowModal(true)
                      }} 
                      onDelete={handleDelete} 
                    />
                  )}
                  {activeSubTab === 'gl-rules' && (
                    <GLRuleCard 
                      item={item} 
                      onEdit={(item) => {
                        setEditingItem(item)
                        setModalType('edit')
                        setShowModal(true)
                      }} 
                      onDelete={handleDelete} 
                    />
                  )}
                  {activeSubTab === 'numbering' && (
                    <NumberingCard 
                      item={item} 
                      onEdit={(item) => {
                        setEditingItem(item)
                        setModalType('edit')
                        setShowModal(true)
                      }} 
                      onDelete={handleDelete} 
                    />
                  )}
                </div>
              ))}
            </div>

            <div className="hidden sm:block overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50">
                  <tr>
                    {activeSubTab === 'categories' && <CategoryTableHeaders />}
                    {activeSubTab === 'types' && <TypeTableHeaders />}
                    {activeSubTab === 'gl-rules' && <GLRuleTableHeaders />}
                    {activeSubTab === 'numbering' && <NumberingTableHeaders />}
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {filteredData().map((item: any) => (
                    <tr key={item.id} className="hover:bg-gray-50">
                      {activeSubTab === 'categories' && (
                        <CategoryTableRow 
                          item={item} 
                          onEdit={(item) => {
                            setEditingItem(item)
                            setModalType('edit')
                            setShowModal(true)
                          }} 
                          onDelete={handleDelete} 
                        />
                      )}
                      {activeSubTab === 'types' && (
                        <TypeTableRow 
                          item={item} 
                          onEdit={(item) => {
                            setEditingItem(item)
                            setModalType('edit')
                            setShowModal(true)
                          }} 
                          onDelete={handleDelete} 
                        />
                      )}
                      {activeSubTab === 'gl-rules' && (
                        <GLRuleTableRow 
                          item={item} 
                          onEdit={(item) => {
                            setEditingItem(item)
                            setModalType('edit')
                            setShowModal(true)
                          }} 
                          onDelete={handleDelete} 
                        />
                      )}
                      {activeSubTab === 'numbering' && (
                        <NumberingTableRow 
                          item={item} 
                          onEdit={(item) => {
                            setEditingItem(item)
                            setModalType('edit')
                            setShowModal(true)
                          }} 
                          onDelete={handleDelete} 
                        />
                      )}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </>
        )}
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg max-w-md w-full max-h-[90vh] overflow-y-auto">
            <form onSubmit={(e) => {
              e.preventDefault()
              handleSubmit(new FormData(e.target as HTMLFormElement))
            }}>
              <div className="p-6">
                <div className="flex justify-between items-center mb-4">
                  <h3 className="text-lg font-semibold">
                    {modalType === 'create' ? 'Add' : 'Edit'} {
                      activeSubTab === 'categories' ? 'Category' :
                      activeSubTab === 'gl-rules' ? 'GL Rule' :
                      activeSubTab === 'numbering' ? 'Numbering Rule' :
                      activeSubTab === 'types' ? 'Project Type' : 'Item'
                    }
                  </h3>
                  <button
                    type="button"
                    onClick={() => setShowModal(false)}
                    className="text-gray-400 hover:text-gray-600"
                  >
                    <X className="w-5 h-5" />
                  </button>
                </div>

                <div className="space-y-4">
                  {/* Company Code - Common for all */}
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Company Code *</label>
                    <select
                      name="company_code"
                      defaultValue={editingItem?.company_code || 'C001'}
                      className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 ${
                        errors.company_code ? 'border-red-500' : 'border-gray-300'
                      }`}
                    >
                      <option value="C001">C001 - MyHome Construction</option>
                      <option value="C002">C002 - Branch Office</option>
                    </select>
                    {errors.company_code && <p className="text-red-500 text-xs mt-1">{errors.company_code}</p>}
                  </div>

                  {/* Category Fields */}
                  {activeSubTab === 'categories' && (
                    <>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Category Code *</label>
                        <input
                          name="category_code"
                          defaultValue={editingItem?.category_code || ''}
                          className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 ${
                            errors.category_code ? 'border-red-500' : 'border-gray-300'
                          }`}
                          placeholder="e.g., CIVIL"
                        />
                        {errors.category_code && <p className="text-red-500 text-xs mt-1">{errors.category_code}</p>}
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Category Name *</label>
                        <input
                          name="category_name"
                          defaultValue={editingItem?.category_name || ''}
                          className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 ${
                            errors.category_name ? 'border-red-500' : 'border-gray-300'
                          }`}
                          placeholder="e.g., Civil Construction"
                        />
                        {errors.category_name && <p className="text-red-500 text-xs mt-1">{errors.category_name}</p>}
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Cost Ownership *</label>
                        <select
                          name="cost_ownership"
                          defaultValue={editingItem?.cost_ownership || ''}
                          className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 ${
                            errors.cost_ownership ? 'border-red-500' : 'border-gray-300'
                          }`}
                        >
                          <option value="">Select Cost Ownership</option>
                          <option value="DIRECT">Direct Cost</option>
                          <option value="INDIRECT">Indirect Cost</option>
                          <option value="OVERHEAD">Overhead</option>
                        </select>
                        {errors.cost_ownership && <p className="text-red-500 text-xs mt-1">{errors.cost_ownership}</p>}
                      </div>
                    </>
                  )}

                  {/* GL Rules Fields */}
                  {activeSubTab === 'gl-rules' && (
                    <>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Project Category *</label>
                        <input
                          name="project_category"
                          defaultValue={editingItem?.project_category || ''}
                          className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 ${
                            errors.project_category ? 'border-red-500' : 'border-gray-300'
                          }`}
                          placeholder="e.g., CIVIL"
                        />
                        {errors.project_category && <p className="text-red-500 text-xs mt-1">{errors.project_category}</p>}
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Event Type *</label>
                        <select
                          name="event_type"
                          defaultValue={editingItem?.event_type || ''}
                          className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 ${
                            errors.event_type ? 'border-red-500' : 'border-gray-300'
                          }`}
                        >
                          <option value="">Select Event Type</option>
                          <option value="MATERIAL_RECEIPT">Material Receipt</option>
                          <option value="EQUIPMENT_RENTAL">Equipment Rental</option>
                          <option value="SERVICE_RECEIPT">Service Receipt</option>
                          <option value="CAPITAL_PURCHASE">Capital Purchase</option>
                        </select>
                        {errors.event_type && <p className="text-red-500 text-xs mt-1">{errors.event_type}</p>}
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">GL Account Type *</label>
                        <input
                          name="gl_account_type"
                          defaultValue={editingItem?.gl_account_type || ''}
                          className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 ${
                            errors.gl_account_type ? 'border-red-500' : 'border-gray-300'
                          }`}
                          placeholder="e.g., INVENTORY"
                        />
                        {errors.gl_account_type && <p className="text-red-500 text-xs mt-1">{errors.gl_account_type}</p>}
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Debit/Credit *</label>
                        <select
                          name="debit_credit"
                          defaultValue={editingItem?.debit_credit || ''}
                          className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 ${
                            errors.debit_credit ? 'border-red-500' : 'border-gray-300'
                          }`}
                        >
                          <option value="">Select Debit/Credit</option>
                          <option value="D">Debit</option>
                          <option value="C">Credit</option>
                        </select>
                        {errors.debit_credit && <p className="text-red-500 text-xs mt-1">{errors.debit_credit}</p>}
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Posting Key *</label>
                        <input
                          name="posting_key"
                          defaultValue={editingItem?.posting_key || ''}
                          className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 ${
                            errors.posting_key ? 'border-red-500' : 'border-gray-300'
                          }`}
                          placeholder="e.g., 89"
                        />
                        {errors.posting_key && <p className="text-red-500 text-xs mt-1">{errors.posting_key}</p>}
                      </div>
                      
                      {/* GST Fields */}
                      <div className="border-t pt-4">
                        <h4 className="text-sm font-medium text-gray-900 mb-3">GST Configuration</h4>
                        <div className="grid grid-cols-2 gap-3">
                          <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">HSN/SAC Code</label>
                            <input
                              name="hsn_sac_code"
                              defaultValue={editingItem?.hsn_sac_code || '7214'}
                              onBlur={(e) => handleMaterialCodeBlur(e.target.value)}
                              className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 ${
                                errors.hsn_sac_code ? 'border-red-500' : 'border-gray-300'
                              }`}
                              placeholder="e.g., 7214"
                            />
                            {errors.hsn_sac_code && <p className="text-red-500 text-xs mt-1">{errors.hsn_sac_code}</p>}
                          </div>
                          <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">GST Rate (%)</label>
                            <select
                              name="gst_rate"
                              defaultValue={editingItem?.gst_rate || 18}
                              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                            >
                              <option value="0">0%</option>
                              <option value="5">5%</option>
                              <option value="12">12%</option>
                              <option value="18">18%</option>
                              <option value="28">28%</option>
                            </select>
                          </div>
                        </div>
                        <div className="mt-3">
                          <label className="block text-sm font-medium text-gray-700 mb-1">Supplier Code</label>
                          <input
                            name="supplier_code"
                            defaultValue={editingItem?.supplier_code || ''}
                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                            placeholder="e.g., STEEL_SUPPLIER"
                          />
                        </div>
                        <div className="mt-3">
                          <label className="flex items-center">
                            <input
                              type="checkbox"
                              name="is_capital_goods"
                              defaultChecked={editingItem?.is_capital_goods || false}
                              className="mr-2"
                            />
                            <span className="text-sm text-gray-700">Capital Goods (Phased Input Credit)</span>
                          </label>
                        </div>
                      </div>
                    </>
                  )}

                  {/* Project Types Fields */}
                  {activeSubTab === 'types' && (
                    <>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Type Code *</label>
                        <input
                          name="type_code"
                          defaultValue={editingItem?.type_code || ''}
                          className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 ${
                            errors.type_code ? 'border-red-500' : 'border-gray-300'
                          }`}
                          placeholder="e.g., RESIDENTIAL"
                        />
                        {errors.type_code && <p className="text-red-500 text-xs mt-1">{errors.type_code}</p>}
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Type Name *</label>
                        <input
                          name="type_name"
                          defaultValue={editingItem?.type_name || ''}
                          className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 ${
                            errors.type_name ? 'border-red-500' : 'border-gray-300'
                          }`}
                          placeholder="e.g., Residential Construction"
                        />
                        {errors.type_name && <p className="text-red-500 text-xs mt-1">{errors.type_name}</p>}
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Category Code *</label>
                        <select
                          name="category_code"
                          defaultValue={editingItem?.category_code || ''}
                          onChange={(e) => handleCategoryChange(e.target.value)}
                          className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 ${
                            errors.category_code ? 'border-red-500' : 'border-gray-300'
                          }`}
                        >
                          <option value="">Select Category</option>
                          {projectCategories.map(cat => (
                            <option key={cat.category_code} value={cat.category_code}>{cat.category_name}</option>
                          ))}
                        </select>
                        {errors.category_code && <p className="text-red-500 text-xs mt-1">{errors.category_code}</p>}
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">GL Posting Variant</label>
                        <input
                          name="gl_posting_variant"
                          defaultValue={editingItem?.gl_posting_variant || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                          placeholder="e.g., STANDARD"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                        <input
                          name="description"
                          defaultValue={editingItem?.description || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                        />
                      </div>
                    </>
                  )}

                  {/* Numbering Fields */}
                  {activeSubTab === 'numbering' && (
                    <>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Entity Type *</label>
                        <select
                          name="entity_type"
                          defaultValue={editingItem?.entity_type || ''}
                          className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 ${
                            errors.entity_type ? 'border-red-500' : 'border-gray-300'
                          }`}
                        >
                          <option value="">Select Entity Type</option>
                          <option value="PROJECT">PROJECT</option>
                          <option value="WBS_ELEMENT">WBS_ELEMENT</option>
                          <option value="ACTIVITY">ACTIVITY</option>
                          <option value="TASK">TASK</option>
                        </select>
                        {errors.entity_type && <p className="text-red-500 text-xs mt-1">{errors.entity_type}</p>}
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Pattern *</label>
                        <input
                          name="pattern"
                          defaultValue={editingItem?.pattern || ''}
                          className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 ${
                            errors.pattern ? 'border-red-500' : 'border-gray-300'
                          }`}
                          placeholder="e.g., MH-{####}"
                        />
                        {errors.pattern && <p className="text-red-500 text-xs mt-1">{errors.pattern}</p>}
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Current Number *</label>
                        <input
                          name="current_number"
                          type="number"
                          defaultValue={editingItem?.current_number || 1}
                          className={`w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 ${
                            errors.current_number ? 'border-red-500' : 'border-gray-300'
                          }`}
                        />
                        {errors.current_number && <p className="text-red-500 text-xs mt-1">{errors.current_number}</p>}
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                        <input
                          name="description"
                          defaultValue={editingItem?.description || ''}
                          className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                        />
                      </div>
                    </>
                  )}
                </div>

                <div className="flex justify-end gap-3 mt-6 pt-4 border-t">
                  <button
                    type="button"
                    onClick={() => setShowModal(false)}
                    className="px-4 py-2 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    disabled={submitting}
                    className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 flex items-center gap-2"
                  >
                    {submitting && <Loader2 className="w-4 h-4 animate-spin" />}
                    {modalType === 'create' ? 'Create' : 'Update'}
                  </button>
                </div>
              </div>
            </form>
          </div>
        </div>
      )}

      <HSNSelectionPopup
        isOpen={showHSNPopup}
        onClose={() => setShowHSNPopup(false)}
        onSelect={handleHSNSelection}
        hsnOptions={hsnOptions}
        materialGroup={selectedMaterialGroup}
      />
    </div>
  )
}

function CategoryCard({ item, onEdit, onDelete }: any) {
  return (
    <div>
      <div className="flex justify-between items-start mb-2">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="bg-blue-100 text-blue-800 px-2 py-1 text-xs font-mono rounded">{item.company_code}</span>
            <div className="font-mono text-sm font-semibold text-blue-600">{item.category_code}</div>
          </div>
          <div className="font-medium">{item.category_name}</div>
        </div>
        <div className="flex gap-1">
          <button onClick={() => onEdit(item)} className="p-2 text-blue-600 hover:bg-blue-100 rounded">
            <Edit2 className="w-4 h-4" />
          </button>
          <button onClick={() => onDelete(item.id)} className="p-2 text-red-600 hover:bg-red-100 rounded">
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      </div>
      <div className="text-sm text-gray-600">{item.cost_ownership}</div>
    </div>
  )
}

function TypeCard({ item, onEdit, onDelete }: any) {
  return (
    <div>
      <div className="flex justify-between items-start mb-2">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="bg-blue-100 text-blue-800 px-2 py-1 text-xs font-mono rounded">{item.company_code}</span>
            <div className="font-mono text-sm font-semibold text-green-600">{item.type_code}</div>
          </div>
          <div className="font-medium">{item.type_name}</div>
        </div>
        <div className="flex gap-1">
          <button onClick={() => onEdit(item)} className="p-2 text-blue-600 hover:bg-blue-100 rounded">
            <Edit2 className="w-4 h-4" />
          </button>
          <button onClick={() => onDelete(item.id)} className="p-2 text-red-600 hover:bg-red-100 rounded">
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      </div>
      <div className="text-sm text-gray-600">{item.category_code}</div>
    </div>
  )
}

function GLRuleCard({ item, onEdit, onDelete }: any) {
  return (
    <div>
      <div className="flex justify-between items-start mb-2">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="bg-blue-100 text-blue-800 px-2 py-1 text-xs font-mono rounded">{item.company_code}</span>
            <div className="font-mono text-sm font-semibold text-purple-600">{item.project_category}</div>
          </div>
          <div className="font-medium">{item.event_type}</div>
        </div>
        <div className="flex gap-1">
          <button onClick={() => onEdit(item)} className="p-2 text-blue-600 hover:bg-blue-100 rounded">
            <Edit2 className="w-4 h-4" />
          </button>
          <button onClick={() => onDelete(item.id)} className="p-2 text-red-600 hover:bg-red-100 rounded">
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      </div>
      <div className="text-sm text-gray-600">{item.gl_account_type} - {item.posting_key}</div>
      <div className="flex gap-2 mt-2">
        <span className="bg-purple-100 text-purple-800 px-2 py-1 text-xs rounded">HSN: {item.hsn_sac_code || '7214'}</span>
        <span className="bg-green-100 text-green-800 px-2 py-1 text-xs rounded">GST: {item.gst_rate || 18}%</span>
        {item.is_capital_goods && <span className="bg-orange-100 text-orange-800 px-2 py-1 text-xs rounded">Capital</span>}
      </div>
    </div>
  )
}

function CategoryTableHeaders() {
  return (
    <>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Company</th>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Code</th>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Cost Ownership</th>
      <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Actions</th>
    </>
  )
}

function TypeTableHeaders() {
  return (
    <>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Company</th>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Code</th>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Category</th>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">GL Variant</th>
      <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Actions</th>
    </>
  )
}

function GLRuleTableHeaders() {
  return (
    <>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Company</th>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Category</th>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Event Type</th>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">GL Account</th>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Dr/Cr</th>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Posting Key</th>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">HSN Code</th>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">GST Rate</th>
      <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Actions</th>
    </>
  )
}

function CategoryTableRow({ item, onEdit, onDelete }: any) {
  return (
    <>
      <td className="px-4 py-3 text-sm font-mono font-semibold text-blue-600">{item.company_code}</td>
      <td className="px-4 py-3 text-sm font-mono">{item.category_code}</td>
      <td className="px-4 py-3 text-sm font-medium">{item.category_name}</td>
      <td className="px-4 py-3 text-sm">{item.cost_ownership}</td>
      <td className="px-4 py-3 text-center">
        <div className="flex justify-center gap-2">
          <button onClick={() => onEdit(item)} className="p-1 text-blue-600 hover:text-blue-800">
            <Edit2 className="w-4 h-4" />
          </button>
          <button onClick={() => onDelete(item.id)} className="p-1 text-red-600 hover:text-red-800">
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      </td>
    </>
  )
}

function TypeTableRow({ item, onEdit, onDelete }: any) {
  return (
    <>
      <td className="px-4 py-3 text-sm font-mono font-semibold text-blue-600">{item.company_code}</td>
      <td className="px-4 py-3 text-sm font-mono">{item.type_code}</td>
      <td className="px-4 py-3 text-sm font-medium">{item.type_name}</td>
      <td className="px-4 py-3 text-sm">{item.category_code}</td>
      <td className="px-4 py-3 text-sm">{item.gl_posting_variant}</td>
      <td className="px-4 py-3 text-center">
        <div className="flex justify-center gap-2">
          <button onClick={() => onEdit(item)} className="p-1 text-blue-600 hover:text-blue-800">
            <Edit2 className="w-4 h-4" />
          </button>
          <button onClick={() => onDelete(item.id)} className="p-1 text-red-600 hover:text-red-800">
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      </td>
    </>
  )
}

function GLRuleTableRow({ item, onEdit, onDelete }: any) {
  return (
    <>
      <td className="px-4 py-3 text-sm font-mono font-semibold text-blue-600">{item.company_code}</td>
      <td className="px-4 py-3 text-sm">{item.project_category}</td>
      <td className="px-4 py-3 text-sm">{item.event_type}</td>
      <td className="px-4 py-3 text-sm">{item.gl_account_type}</td>
      <td className="px-4 py-3 text-sm">{item.debit_credit}</td>
      <td className="px-4 py-3 text-sm font-mono">{item.posting_key}</td>
      <td className="px-4 py-3 text-sm font-mono text-purple-600">{item.hsn_sac_code || '7214'}</td>
      <td className="px-4 py-3 text-sm">{item.gst_rate || 18}%</td>
      <td className="px-4 py-3 text-center">
        <div className="flex justify-center gap-2">
          <button onClick={() => onEdit(item)} className="p-1 text-blue-600 hover:text-blue-800">
            <Edit2 className="w-4 h-4" />
          </button>
          <button onClick={() => onDelete(item.id)} className="p-1 text-red-600 hover:text-red-800">
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      </td>
    </>
  )
}

function NumberingCard({ item, onEdit, onDelete }: any) {
  return (
    <div>
      <div className="flex justify-between items-start mb-2">
        <div>
          <div className="font-mono text-sm font-semibold text-green-600">{item.entity_type}</div>
          <div className="font-medium">{item.pattern}</div>
        </div>
        <div className="flex gap-1">
          <button onClick={() => onEdit(item)} className="p-2 text-blue-600 hover:bg-blue-100 rounded">
            <Edit2 className="w-4 h-4" />
          </button>
          <button onClick={() => onDelete(item.id)} className="p-2 text-red-600 hover:bg-red-100 rounded">
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      </div>
      <div className="text-sm text-gray-600">{item.description}</div>
      <div className="mt-2">
        <span className="bg-gray-100 text-gray-800 px-2 py-1 text-xs rounded">Current: {item.current_number}</span>
      </div>
    </div>
  )
}

function NumberingTableHeaders() {
  return (
    <>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Company</th>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Entity Type</th>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Pattern</th>
      <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Current #</th>
      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Description</th>
      <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Actions</th>
    </>
  )
}

function NumberingTableRow({ item, onEdit, onDelete }: any) {
  return (
    <>
      <td className="px-4 py-3 text-sm font-medium">{item.company_code}</td>
      <td className="px-4 py-3 text-sm font-medium">{item.entity_type}</td>
      <td className="px-4 py-3 text-sm font-mono bg-gray-50">{item.pattern}</td>
      <td className="px-4 py-3 text-center text-sm">{item.current_number}</td>
      <td className="px-4 py-3 text-sm text-gray-600">{item.description}</td>
      <td className="px-4 py-3 text-center">
        <div className="flex justify-center gap-2">
          <button onClick={() => onEdit(item)} className="p-1 text-blue-600 hover:text-blue-800">
            <Edit2 className="w-4 h-4" />
          </button>
          <button onClick={() => onDelete(item.id)} className="p-1 text-red-600 hover:text-red-800">
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      </td>
    </>
  )
}