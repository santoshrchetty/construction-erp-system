// DEPRECATED: This file is marked for removal - no active dependencies found
// TODO: Remove after confirming no imports
/*
'use client'

import React, { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase-simple'
import { Plus, Edit2, Trash2, Package, ShoppingCart, Warehouse, X } from 'lucide-react'

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

interface Material {
  id: string
  material_code: string
  material_name: string
  description: string
  base_uom: string
  standard_price: number
  is_active: boolean
}

interface Vendor {
  id: string
  vendor_code: string
  vendor_name: string
  contact_person: string
  phone: string
  email: string
  is_active: boolean
}

interface StockLevel {
  id: string
  material_code: string
  material_name: string
  current_stock: number
  available_stock: number
  base_uom: string
}

export default function MaterialManagementModule() {
  const [activeTab, setActiveTab] = useState('materials')
  const [materialGroups, setMaterialGroups] = useState<MaterialGroup[]>([])
  const [vendorCategories, setVendorCategories] = useState<VendorCategory[]>([])
  const [paymentTerms, setPaymentTerms] = useState<PaymentTerm[]>([])
  const [uomGroups, setUOMGroups] = useState<UOMGroup[]>([])
  const [materialStatus, setMaterialStatus] = useState<MaterialStatus[]>([])
  const [materials, setMaterials] = useState<Material[]>([])
  const [vendors, setVendors] = useState<Vendor[]>([])
  const [stockLevels, setStockLevels] = useState<StockLevel[]>([])
  const [loading, setLoading] = useState(false)
  const [showModal, setShowModal] = useState(false)
  const [modalType, setModalType] = useState<'add' | 'edit'>('add')
  const [modalEntity, setModalEntity] = useState<'material' | 'vendor' | 'group'>('material')
  const [editingItem, setEditingItem] = useState<any>(null)

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    setLoading(true)
    try {
      const [mgRes, vcRes, ptRes, uomRes, msRes, matRes, venRes, stockRes] = await Promise.all([
        supabase.from('material_groups').select('*').order('group_code'),
        supabase.from('vendor_categories').select('*').order('category_code'),
        supabase.from('payment_terms').select('*').order('term_code'),
        supabase.from('uom_groups').select('*').order('base_uom'),
        supabase.from('material_status').select('*').order('status_code'),
        supabase.from('materials').select('*').order('material_code'),
        supabase.from('vendors').select('*').order('vendor_code'),
        supabase.from('stock_levels').select(`
          id, current_stock, available_stock,
          materials(material_code, material_name, base_uom)
        `).order('materials(material_code)')
      ])

      if (mgRes.data) setMaterialGroups(mgRes.data)
      if (vcRes.data) setVendorCategories(vcRes.data)
      if (ptRes.data) setPaymentTerms(ptRes.data)
      if (uomRes.data) setUOMGroups(uomRes.data)
      if (msRes.data) setMaterialStatus(msRes.data)
      if (matRes.data) setMaterials(matRes.data)
      if (venRes.data) setVendors(venRes.data)
      if (stockRes.data) {
        const stockData = stockRes.data.map((item: any) => ({
          id: item.id,
          material_code: item.materials?.material_code || '',
          material_name: item.materials?.material_name || '',
          current_stock: item.current_stock,
          available_stock: item.available_stock,
          base_uom: item.materials?.base_uom || ''
        }))
        setStockLevels(stockData)
      }
    } catch (error) {
      console.error('Error loading data:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleAdd = (entity: 'material' | 'vendor' | 'group') => {
    setModalEntity(entity)
    setModalType('add')
    setEditingItem(null)
    setShowModal(true)
  }

  const handleEdit = (item: any, entity: 'material' | 'vendor' | 'group') => {
    setModalEntity(entity)
    setModalType('edit')
    setEditingItem(item)
    setShowModal(true)
  }

  const handleDelete = async (id: string, entity: 'material' | 'vendor' | 'group') => {
    if (!confirm('Are you sure you want to delete this item?')) return
    
    try {
      const table = entity === 'material' ? 'materials' : 
                   entity === 'vendor' ? 'vendors' : 'material_groups'
      
      const { error } = await supabase.from(table).delete().eq('id', id)
      if (error) throw error
      
      loadData()
    } catch (error) {
      console.error('Error deleting:', error)
    }
  }

  const handleSave = async (formData: any) => {
    try {
      const table = modalEntity === 'material' ? 'materials' : 
                   modalEntity === 'vendor' ? 'vendors' : 'material_groups'
      
      if (modalType === 'add') {
        const { error } = await supabase.from(table).insert([formData])
        if (error) throw error
      } else {
        const { error } = await supabase.from(table).update(formData).eq('id', editingItem.id)
        if (error) throw error
      }
      
      setShowModal(false)
      loadData()
    } catch (error) {
      console.error('Error saving:', error)
    }
  }

  const tabs = [
    { id: 'materials', label: 'Materials', icon: Package },
    { id: 'purchasing', label: 'Purchasing', icon: ShoppingCart },
    { id: 'inventory', label: 'Inventory', icon: Warehouse }
  ]

  const renderMaterialsTab = () => (
    <div className="space-y-6">
      <div className="bg-white rounded-lg shadow-sm border p-4">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-lg font-semibold flex items-center gap-2">
            <Package className="w-5 h-5" />
            Materials Master
          </h3>
          <button 
            onClick={() => handleAdd('material')}
            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
          >
            <Plus className="w-4 h-4" />
            Add Material
          </button>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b">
                <th className="text-left py-2 px-3">Code</th>
                <th className="text-left py-2 px-3">Name</th>
                <th className="text-left py-2 px-3 hidden sm:table-cell">UoM</th>
                <th className="text-left py-2 px-3 hidden sm:table-cell">Price</th>
                <th className="text-right py-2 px-3">Actions</th>
              </tr>
            </thead>
            <tbody>
              {materials.map((material) => (
                <tr key={material.id} className="border-b hover:bg-gray-50">
                  <td className="py-2 px-3 font-medium">{material.material_code}</td>
                  <td className="py-2 px-3">{material.material_name}</td>
                  <td className="py-2 px-3 hidden sm:table-cell">{material.base_uom}</td>
                  <td className="py-2 px-3 hidden sm:table-cell">${material.standard_price}</td>
                  <td className="py-2 px-3 text-right">
                    <div className="flex justify-end gap-1">
                      <button 
                        onClick={() => handleEdit(material, 'material')}
                        className="p-1 text-blue-600 hover:bg-blue-100 rounded"
                      >
                        <Edit2 className="w-4 h-4" />
                      </button>
                      <button 
                        onClick={() => handleDelete(material.id, 'material')}
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
    </div>
  )

  const renderPurchasingTab = () => (
    <div className="space-y-6">
      <div className="bg-white rounded-lg shadow-sm border p-4">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-lg font-semibold flex items-center gap-2">
            <ShoppingCart className="w-5 h-5" />
            Vendors Master
          </h3>
          <button 
            onClick={() => handleAdd('vendor')}
            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
          >
            <Plus className="w-4 h-4" />
            Add Vendor
          </button>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b">
                <th className="text-left py-2 px-3">Code</th>
                <th className="text-left py-2 px-3">Name</th>
                <th className="text-left py-2 px-3 hidden sm:table-cell">Contact</th>
                <th className="text-left py-2 px-3 hidden sm:table-cell">Phone</th>
                <th className="text-right py-2 px-3">Actions</th>
              </tr>
            </thead>
            <tbody>
              {vendors.map((vendor) => (
                <tr key={vendor.id} className="border-b hover:bg-gray-50">
                  <td className="py-2 px-3 font-medium">{vendor.vendor_code}</td>
                  <td className="py-2 px-3">{vendor.vendor_name}</td>
                  <td className="py-2 px-3 hidden sm:table-cell">{vendor.contact_person}</td>
                  <td className="py-2 px-3 hidden sm:table-cell">{vendor.phone}</td>
                  <td className="py-2 px-3 text-right">
                    <div className="flex justify-end gap-1">
                      <button 
                        onClick={() => handleEdit(vendor, 'vendor')}
                        className="p-1 text-blue-600 hover:bg-blue-100 rounded"
                      >
                        <Edit2 className="w-4 h-4" />
                      </button>
                      <button 
                        onClick={() => handleDelete(vendor.id, 'vendor')}
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
    </div>
  )

  const renderInventoryTab = () => (
    <div className="bg-white rounded-lg shadow-sm border p-4">
      <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
        <Warehouse className="w-5 h-5" />
        Stock Levels
      </h3>
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead>
            <tr className="border-b">
              <th className="text-left py-2 px-3">Material Code</th>
              <th className="text-left py-2 px-3">Material Name</th>
              <th className="text-right py-2 px-3">Current Stock</th>
              <th className="text-right py-2 px-3">Available</th>
              <th className="text-left py-2 px-3">UoM</th>
            </tr>
          </thead>
          <tbody>
            {stockLevels.map((stock) => (
              <tr key={stock.id} className="border-b hover:bg-gray-50">
                <td className="py-2 px-3 font-medium">{stock.material_code}</td>
                <td className="py-2 px-3">{stock.material_name}</td>
                <td className="py-2 px-3 text-right">{stock.current_stock}</td>
                <td className="py-2 px-3 text-right">{stock.available_stock}</td>
                <td className="py-2 px-3">{stock.base_uom}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )

  const renderModal = () => {
    if (!showModal) return null

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
        <div className="bg-white rounded-lg max-w-md w-full p-6">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-lg font-semibold">
              {modalType === 'add' ? 'Add' : 'Edit'} {modalEntity === 'material' ? 'Material' : modalEntity === 'vendor' ? 'Vendor' : 'Group'}
            </h3>
            <button onClick={() => setShowModal(false)} className="text-gray-500 hover:text-gray-700">
              <X className="w-5 h-5" />
            </button>
          </div>
          
          <form onSubmit={(e) => {
            e.preventDefault()
            const formData = new FormData(e.target as HTMLFormElement)
            const data = Object.fromEntries(formData.entries())
            handleSave(data)
          }}>
            {modalEntity === 'material' && (
              <>
                <input name="material_code" placeholder="Material Code" defaultValue={editingItem?.material_code || ''} className="w-full p-2 border rounded mb-3" required />
                <input name="material_name" placeholder="Material Name" defaultValue={editingItem?.material_name || ''} className="w-full p-2 border rounded mb-3" required />
                <input name="description" placeholder="Description" defaultValue={editingItem?.description || ''} className="w-full p-2 border rounded mb-3" />
                <input name="base_uom" placeholder="Base UoM" defaultValue={editingItem?.base_uom || ''} className="w-full p-2 border rounded mb-3" required />
                <input name="standard_price" type="number" step="0.01" placeholder="Standard Price" defaultValue={editingItem?.standard_price || ''} className="w-full p-2 border rounded mb-3" />
              </>
            )}
            {modalEntity === 'vendor' && (
              <>
                <input name="vendor_code" placeholder="Vendor Code" defaultValue={editingItem?.vendor_code || ''} className="w-full p-2 border rounded mb-3" required />
                <input name="vendor_name" placeholder="Vendor Name" defaultValue={editingItem?.vendor_name || ''} className="w-full p-2 border rounded mb-3" required />
                <input name="contact_person" placeholder="Contact Person" defaultValue={editingItem?.contact_person || ''} className="w-full p-2 border rounded mb-3" />
                <input name="phone" placeholder="Phone" defaultValue={editingItem?.phone || ''} className="w-full p-2 border rounded mb-3" />
                <input name="email" placeholder="Email" defaultValue={editingItem?.email || ''} className="w-full p-2 border rounded mb-3" />
              </>
            )}
            {modalEntity === 'group' && (
              <>
                <input name="group_code" placeholder="Group Code" defaultValue={editingItem?.group_code || ''} className="w-full p-2 border rounded mb-3" required />
                <input name="group_name" placeholder="Group Name" defaultValue={editingItem?.group_name || ''} className="w-full p-2 border rounded mb-3" required />
                <input name="description" placeholder="Description" defaultValue={editingItem?.description || ''} className="w-full p-2 border rounded mb-3" />
              </>
            )}
            
            <div className="flex gap-2 justify-end">
              <button type="button" onClick={() => setShowModal(false)} className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50">
                Cancel
              </button>
              <button type="submit" className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">
                {modalType === 'add' ? 'Add' : 'Update'}
              </button>
            </div>
          </form>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-4">
      <div className="max-w-7xl mx-auto">
        <div className="mb-6">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Material Management</h1>
          <p className="text-gray-600">Manage materials, vendors, purchasing, and inventory operations</p>
          <div className="mt-2 px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm inline-block">
            👥 Business User Access
          </div>
        </div>

        {/* Mobile-first tab navigation */}
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
                      ? 'border-blue-500 text-blue-600 bg-blue-50'
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
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
              <p className="mt-2 text-gray-600">Loading...</p>
            </div>
          ) : (
            <>
              {activeTab === 'materials' && renderMaterialsTab()}
              {activeTab === 'purchasing' && renderPurchasingTab()}
              {activeTab === 'inventory' && renderInventoryTab()}
            </>
          )}
        </div>
        
        {renderModal()}
      </div>
    </div>
  )
}
*/