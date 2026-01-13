// DEPRECATED: This file is marked for removal - duplicate of ERPConfigurationModuleComplete.tsx
// TODO: Remove after confirming no imports
/*
'use client'

import React, { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase-simple'
import { Plus, Edit2, Trash2, Settings, Database, Key, Calculator, X } from 'lucide-react'

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

export default function ERPConfigurationModule() {
  const [activeTab, setActiveTab] = useState('groups')
  const [materialGroups, setMaterialGroups] = useState<MaterialGroup[]>([])
  const [vendorCategories, setVendorCategories] = useState<VendorCategory[]>([])
  const [paymentTerms, setPaymentTerms] = useState<PaymentTerm[]>([])
  const [uomGroups, setUOMGroups] = useState<UOMGroup[]>([])
  const [materialStatus, setMaterialStatus] = useState<MaterialStatus[]>([])
  const [loading, setLoading] = useState(false)
  const [showModal, setShowModal] = useState(false)
  const [modalType, setModalType] = useState<'add' | 'edit'>('add')
  const [modalEntity, setModalEntity] = useState<'group' | 'category' | 'term' | 'uom' | 'status'>('group')
  const [editingItem, setEditingItem] = useState<any>(null)

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    setLoading(true)
    try {
      const [mgRes, vcRes, ptRes, uomRes, msRes] = await Promise.all([
        supabase.from('material_groups').select('*').order('group_code'),
        supabase.from('vendor_categories').select('*').order('category_code'),
        supabase.from('payment_terms').select('*').order('term_code'),
        supabase.from('uom_groups').select('*').order('base_uom'),
        supabase.from('material_status').select('*').order('status_code')
      ])

      if (mgRes.data) setMaterialGroups(mgRes.data)
      if (vcRes.data) setVendorCategories(vcRes.data)
      if (ptRes.data) setPaymentTerms(ptRes.data)
      if (uomRes.data) setUOMGroups(uomRes.data)
      if (msRes.data) setMaterialStatus(msRes.data)
    } catch (error) {
      console.error('Error loading data:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleAdd = (entity: 'group' | 'category' | 'term' | 'uom' | 'status') => {
    setModalEntity(entity)
    setModalType('add')
    setEditingItem(null)
    setShowModal(true)
  }

  const handleEdit = (item: any, entity: 'group' | 'category' | 'term' | 'uom' | 'status') => {
    setModalEntity(entity)
    setModalType('edit')
    setEditingItem(item)
    setShowModal(true)
  }

  const handleDelete = async (id: string, entity: 'group' | 'category' | 'term' | 'uom' | 'status') => {
    if (!confirm('Are you sure you want to delete this configuration item?')) return
    
    try {
      const tableMap = {
        group: 'material_groups',
        category: 'vendor_categories', 
        term: 'payment_terms',
        uom: 'uom_groups',
        status: 'material_status'
      }
      
      const { error } = await supabase.from(tableMap[entity]).delete().eq('id', id)
      if (error) throw error
      
      loadData()
    } catch (error) {
      console.error('Error deleting:', error)
    }
  }

  const handleSave = async (formData: any) => {
    try {
      const tableMap = {
        group: 'material_groups',
        category: 'vendor_categories',
        term: 'payment_terms', 
        uom: 'uom_groups',
        status: 'material_status'
      }
      
      if (modalType === 'add') {
        const { error } = await supabase.from(tableMap[modalEntity]).insert([formData])
        if (error) throw error
      } else {
        const { error } = await supabase.from(tableMap[modalEntity]).update(formData).eq('id', editingItem.id)
        if (error) throw error
      }
      
      setShowModal(false)
      loadData()
    } catch (error) {
      console.error('Error saving:', error)
    }
  }

  const tabs = [
    { id: 'groups', label: 'Material Groups', icon: Database },
    { id: 'categories', label: 'Vendor Categories', icon: Settings },
    { id: 'terms', label: 'Payment Terms', icon: Calculator },
    { id: 'uom', label: 'Units of Measure', icon: Key }
  ]

  const renderConfigTable = (data: any[], entity: string, columns: string[]) => (
    <div className="bg-white rounded-lg shadow-sm border p-4">
      <div className="flex justify-between items-center mb-4">
        <h3 className="text-lg font-semibold">
          {entity === 'groups' ? 'Material Groups' :
           entity === 'categories' ? 'Vendor Categories' :
           entity === 'terms' ? 'Payment Terms' :
           entity === 'uom' ? 'Units of Measure' : 'Material Status'}
        </h3>
        <button 
          onClick={() => handleAdd(entity as any)}
          className="flex items-center gap-2 px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700"
        >
          <Plus className="w-4 h-4" />
          Add New
        </button>
      </div>
      
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead>
            <tr className="border-b">
              {columns.map(col => (
                <th key={col} className="text-left py-2 px-3 font-medium text-gray-700">
                  {col}
                </th>
              ))}
              <th className="text-right py-2 px-3">Actions</th>
            </tr>
          </thead>
          <tbody>
            {data.map((item) => (
              <tr key={item.id} className="border-b hover:bg-gray-50">
                {columns.map(col => (
                  <td key={col} className="py-2 px-3">
                    {col === 'Status' ? (
                      <span className={`px-2 py-1 rounded text-xs ${
                        item.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                      }`}>
                        {item.is_active ? 'Active' : 'Inactive'}
                      </span>
                    ) : col === 'Terms' ? (
                      <span className="text-sm">
                        {item.net_days} days
                        {item.discount_percent > 0 && ` (${item.discount_percent}% in ${item.discount_days}d)`}
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
                      onClick={() => handleEdit(item, entity as any)}
                      className="p-1 text-blue-600 hover:bg-blue-100 rounded"
                    >
                      <Edit2 className="w-4 h-4" />
                    </button>
                    <button 
                      onClick={() => handleDelete(item.id, entity as any)}
                      className="p-1 text-red-600 hover:bg-red-100 rounded"
                    >
                      <Trash2 className="w-4 h-4" />
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

  const renderModal = () => {
    if (!showModal) return null

    const getModalFields = () => {
      switch (modalEntity) {
        case 'group':
          return (
            <>
              <input name="group_code" placeholder="Group Code" defaultValue={editingItem?.group_code || ''} className="w-full p-2 border rounded mb-3" required />
              <input name="group_name" placeholder="Group Name" defaultValue={editingItem?.group_name || ''} className="w-full p-2 border rounded mb-3" required />
              <input name="description" placeholder="Description" defaultValue={editingItem?.description || ''} className="w-full p-2 border rounded mb-3" />
            </>
          )
        case 'category':
          return (
            <>
              <input name="category_code" placeholder="Category Code" defaultValue={editingItem?.category_code || ''} className="w-full p-2 border rounded mb-3" required />
              <input name="category_name" placeholder="Category Name" defaultValue={editingItem?.category_name || ''} className="w-full p-2 border rounded mb-3" required />
              <input name="description" placeholder="Description" defaultValue={editingItem?.description || ''} className="w-full p-2 border rounded mb-3" />
            </>
          )
        case 'term':
          return (
            <>
              <input name="term_code" placeholder="Term Code" defaultValue={editingItem?.term_code || ''} className="w-full p-2 border rounded mb-3" required />
              <input name="term_name" placeholder="Term Name" defaultValue={editingItem?.term_name || ''} className="w-full p-2 border rounded mb-3" required />
              <input name="net_days" type="number" placeholder="Net Days" defaultValue={editingItem?.net_days || ''} className="w-full p-2 border rounded mb-3" required />
              <input name="discount_days" type="number" placeholder="Discount Days" defaultValue={editingItem?.discount_days || ''} className="w-full p-2 border rounded mb-3" />
              <input name="discount_percent" type="number" step="0.01" placeholder="Discount %" defaultValue={editingItem?.discount_percent || ''} className="w-full p-2 border rounded mb-3" />
            </>
          )
        case 'uom':
          return (
            <>
              <input name="base_uom" placeholder="UoM Code" defaultValue={editingItem?.base_uom || ''} className="w-full p-2 border rounded mb-3" required />
              <input name="uom_name" placeholder="UoM Name" defaultValue={editingItem?.uom_name || ''} className="w-full p-2 border rounded mb-3" required />
              <input name="dimension" placeholder="Dimension" defaultValue={editingItem?.dimension || ''} className="w-full p-2 border rounded mb-3" />
            </>
          )
        case 'status':
          return (
            <>
              <input name="status_code" placeholder="Status Code" defaultValue={editingItem?.status_code || ''} className="w-full p-2 border rounded mb-3" required />
              <input name="status_name" placeholder="Status Name" defaultValue={editingItem?.status_name || ''} className="w-full p-2 border rounded mb-3" required />
              <label className="flex items-center mb-3">
                <input name="allow_procurement" type="checkbox" defaultChecked={editingItem?.allow_procurement} className="mr-2" />
                Allow Procurement
              </label>
              <label className="flex items-center mb-3">
                <input name="allow_consumption" type="checkbox" defaultChecked={editingItem?.allow_consumption} className="mr-2" />
                Allow Consumption
              </label>
            </>
          )
        default:
          return null
      }
    }

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
        <div className="bg-white rounded-lg max-w-md w-full p-6">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-lg font-semibold">
              {modalType === 'add' ? 'Add' : 'Edit'} Configuration
            </h3>
            <button onClick={() => setShowModal(false)} className="text-gray-500 hover:text-gray-700">
              <X className="w-5 h-5" />
            </button>
          </div>
          
          <form onSubmit={(e) => {
            e.preventDefault()
            const formData = new FormData(e.target as HTMLFormElement)
            const data = Object.fromEntries(formData.entries())
            
            // Handle checkboxes
            if (modalEntity === 'status') {
              data.allow_procurement = formData.has('allow_procurement')
              data.allow_consumption = formData.has('allow_consumption')
            }
            
            handleSave(data)
          }}>
            {getModalFields()}
            
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
          <h1 className="text-3xl font-bold text-gray-900 mb-2">ERP Configuration</h1>
          <p className="text-gray-600">System configuration and reference data management</p>
          <div className="mt-2 px-3 py-1 bg-yellow-100 text-yellow-800 rounded-full text-sm inline-block">
            👨‍💼 Consultant Access Only
          </div>
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
              {activeTab === 'groups' && renderConfigTable(materialGroups, 'groups', ['Code', 'Name', 'Description', 'Status'])}
              {activeTab === 'categories' && renderConfigTable(vendorCategories, 'categories', ['Code', 'Name', 'Description', 'Status'])}
              {activeTab === 'terms' && renderConfigTable(paymentTerms, 'terms', ['Code', 'Name', 'Terms', 'Status'])}
              {activeTab === 'uom' && renderConfigTable(uomGroups, 'uom', ['UoM', 'Name', 'Dimension', 'Status'])}
            </>
          )}
        </div>
        
        {renderModal()}
      </div>
    </div>
  )
}
*/