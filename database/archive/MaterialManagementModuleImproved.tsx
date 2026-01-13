// DEPRECATED: This file is marked for removal - no active dependencies found
// TODO: Remove after confirming no imports
/*
'use client'

import React, { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase-simple'
import { Plus, Edit2, Trash2, Package, ShoppingCart, Warehouse, FileText, Truck, X, Search } from 'lucide-react'

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

interface PurchaseRequisition {
  id: string
  pr_number: string
  pr_date: string
  department: string
  priority: string
  status: string
  total_amount: number
}

interface PurchaseOrder {
  id: string
  po_number: string
  vendor_name: string
  po_date: string
  delivery_date: string
  total_amount: number
  status: string
}

interface StockLevel {
  id: string
  material_code: string
  material_name: string
  current_stock: number
  available_stock: number
  base_uom: string
}

interface GoodsReceipt {
  id: string
  gr_number: string
  po_number: string
  gr_date: string
  delivery_note: string
  total_amount: number
  status: string
}

export default function MaterialManagementModuleImproved() {
  const [activeTab, setActiveTab] = useState('materials')
  const [materials, setMaterials] = useState<Material[]>([])
  const [vendors, setVendors] = useState<Vendor[]>([])
  const [purchaseRequisitions, setPurchaseRequisitions] = useState<PurchaseRequisition[]>([])
  const [purchaseOrders, setPurchaseOrders] = useState<PurchaseOrder[]>([])
  const [stockLevels, setStockLevels] = useState<StockLevel[]>([])
  const [goodsReceipts, setGoodsReceipts] = useState<GoodsReceipt[]>([])
  const [loading, setLoading] = useState(false)
  const [showModal, setShowModal] = useState(false)
  const [modalType, setModalType] = useState<'add' | 'edit'>('add')
  const [modalEntity, setModalEntity] = useState<'material' | 'vendor' | 'pr' | 'po' | 'gr'>('material')
  const [editingItem, setEditingItem] = useState<any>(null)
  const [searchTerm, setSearchTerm] = useState('')

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    setLoading(true)
    try {
      const [matRes, venRes, prRes, poRes, stockRes, grRes] = await Promise.all([
        supabase.from('materials').select('*').order('material_code'),
        supabase.from('vendors').select('*').order('vendor_code'),
        supabase.from('purchase_requisitions').select('*').order('pr_number'),
        supabase.from('purchase_orders').select(`
          *, vendors(vendor_name)
        `).order('po_number'),
        supabase.from('stock_levels').select(`
          id, current_stock, available_stock,
          materials(material_code, material_name, base_uom)
        `),
        supabase.from('goods_receipts').select(`
          *, purchase_orders(po_number)
        `).order('gr_number')
      ])

      if (matRes.data) setMaterials(matRes.data)
      if (venRes.data) setVendors(venRes.data)
      if (prRes.data) setPurchaseRequisitions(prRes.data)
      if (poRes.data) {
        const poData = poRes.data.map((po: any) => ({
          ...po,
          vendor_name: po.vendors?.vendor_name || 'Unknown'
        }))
        setPurchaseOrders(poData)
      }
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
      if (grRes.data) {
        const grData = grRes.data.map((gr: any) => ({
          ...gr,
          po_number: gr.purchase_orders?.po_number || 'N/A'
        }))
        setGoodsReceipts(grData)
      }
    } catch (error) {
      console.error('Error loading data:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleAdd = (entity: 'material' | 'vendor' | 'pr' | 'po' | 'gr') => {
    setModalEntity(entity)
    setModalType('add')
    setEditingItem(null)
    setShowModal(true)
  }

  const handleEdit = (item: any, entity: 'material' | 'vendor' | 'pr' | 'po' | 'gr') => {
    setModalEntity(entity)
    setModalType('edit')
    setEditingItem(item)
    setShowModal(true)
  }

  const handleDelete = async (id: string, entity: 'material' | 'vendor' | 'pr' | 'po' | 'gr') => {
    if (!confirm('Are you sure you want to delete this item?')) return
    
    try {
      const tableMap = {
        material: 'materials',
        vendor: 'vendors',
        pr: 'purchase_requisitions',
        po: 'purchase_orders',
        gr: 'goods_receipts'
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
        material: 'materials',
        vendor: 'vendors',
        pr: 'purchase_requisitions',
        po: 'purchase_orders',
        gr: 'goods_receipts'
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
    { id: 'materials', label: 'Materials', icon: Package },
    { id: 'procurement', label: 'Procurement', icon: ShoppingCart },
    { id: 'inventory', label: 'Inventory', icon: Warehouse },
    { id: 'transactions', label: 'Transactions', icon: FileText }
  ]

  const filterData = (data: any[], searchFields: string[]) => {
    if (!searchTerm) return data
    return data.filter(item =>
      searchFields.some(field =>
        item[field]?.toString().toLowerCase().includes(searchTerm.toLowerCase())
      )
    )
  }

  const renderMaterialsTab = () => (
    <div className="space-y-4">
      <div className="bg-white rounded-lg shadow-sm border p-4">
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-4">
          <h3 className="text-lg font-semibold flex items-center gap-2">
            <Package className="w-5 h-5" />
            Materials Master
          </h3>
          <div className="flex flex-col sm:flex-row gap-2 w-full sm:w-auto">
            <div className="relative">
              <Search className="w-4 h-4 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                placeholder="Search materials..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 pr-4 py-2 border rounded-lg w-full sm:w-64"
              />
            </div>
            <button 
              onClick={() => handleAdd('material')}
              className="flex items-center justify-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 whitespace-nowrap"
            >
              <Plus className="w-4 h-4" />
              <span className="hidden sm:inline">Add Material</span>
              <span className="sm:hidden">Add</span>
            </button>
          </div>
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b">
                <th className="text-left py-2 px-3 font-medium">Code</th>
                <th className="text-left py-2 px-3 font-medium">Name</th>
                <th className="text-left py-2 px-3 font-medium hidden sm:table-cell">UoM</th>
                <th className="text-right py-2 px-3 font-medium hidden sm:table-cell">Price</th>
                <th className="text-right py-2 px-3 font-medium">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filterData(materials, ['material_code', 'material_name']).map((material) => (
                <tr key={material.id} className="border-b hover:bg-gray-50">
                  <td className="py-2 px-3 font-medium text-sm">{material.material_code}</td>
                  <td className="py-2 px-3 text-sm">{material.material_name}</td>
                  <td className="py-2 px-3 text-sm hidden sm:table-cell">{material.base_uom}</td>
                  <td className="py-2 px-3 text-sm text-right hidden sm:table-cell">${material.standard_price}</td>
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

      <div className="bg-white rounded-lg shadow-sm border p-4">
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-4">
          <h3 className="text-lg font-semibold">Vendors Master</h3>
          <button 
            onClick={() => handleAdd('vendor')}
            className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
          >
            <Plus className="w-4 h-4" />
            <span className="hidden sm:inline">Add Vendor</span>
            <span className="sm:hidden">Add</span>
          </button>
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b">
                <th className="text-left py-2 px-3 font-medium">Code</th>
                <th className="text-left py-2 px-3 font-medium">Name</th>
                <th className="text-left py-2 px-3 font-medium hidden md:table-cell">Contact</th>
                <th className="text-left py-2 px-3 font-medium hidden lg:table-cell">Phone</th>
                <th className="text-right py-2 px-3 font-medium">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filterData(vendors, ['vendor_code', 'vendor_name']).map((vendor) => (
                <tr key={vendor.id} className="border-b hover:bg-gray-50">
                  <td className="py-2 px-3 font-medium text-sm">{vendor.vendor_code}</td>
                  <td className="py-2 px-3 text-sm">{vendor.vendor_name}</td>
                  <td className="py-2 px-3 text-sm hidden md:table-cell">{vendor.contact_person}</td>
                  <td className="py-2 px-3 text-sm hidden lg:table-cell">{vendor.phone}</td>
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

  const renderProcurementTab = () => (
    <div className="space-y-4">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div className="bg-white rounded-lg shadow-sm border p-4">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-lg font-semibold flex items-center gap-2">
              <FileText className="w-5 h-5" />
              Purchase Requisitions
            </h3>
            <button 
              onClick={() => handleAdd('pr')}
              className="flex items-center gap-2 px-3 py-1 bg-orange-600 text-white rounded hover:bg-orange-700 text-sm"
            >
              <Plus className="w-3 h-3" />
              Add PR
            </button>
          </div>
          <div className="space-y-2 max-h-64 overflow-y-auto">
            {purchaseRequisitions.map((pr) => (
              <div key={pr.id} className="p-3 bg-gray-50 rounded">
                <div className="flex justify-between items-start">
                  <div>
                    <span className="font-medium text-sm">{pr.pr_number}</span>
                    <div className="text-xs text-gray-600">{pr.department} - {pr.priority}</div>
                    <div className="text-xs text-gray-500">${pr.total_amount}</div>
                  </div>
                  <span className={`px-2 py-1 rounded text-xs ${
                    pr.status === 'APPROVED' ? 'bg-green-100 text-green-800' :
                    pr.status === 'OPEN' ? 'bg-yellow-100 text-yellow-800' :
                    'bg-gray-100 text-gray-800'
                  }`}>
                    {pr.status}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm border p-4">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-lg font-semibold flex items-center gap-2">
              <ShoppingCart className="w-5 h-5" />
              Purchase Orders
            </h3>
            <button 
              onClick={() => handleAdd('po')}
              className="flex items-center gap-2 px-3 py-1 bg-blue-600 text-white rounded hover:bg-blue-700 text-sm"
            >
              <Plus className="w-3 h-3" />
              Add PO
            </button>
          </div>
          <div className="space-y-2 max-h-64 overflow-y-auto">
            {purchaseOrders.map((po) => (
              <div key={po.id} className="p-3 bg-gray-50 rounded">
                <div className="flex justify-between items-start">
                  <div>
                    <span className="font-medium text-sm">{po.po_number}</span>
                    <div className="text-xs text-gray-600">{po.vendor_name}</div>
                    <div className="text-xs text-gray-500">${po.total_amount}</div>
                  </div>
                  <span className={`px-2 py-1 rounded text-xs ${
                    po.status === 'OPEN' ? 'bg-blue-100 text-blue-800' :
                    po.status === 'CLOSED' ? 'bg-gray-100 text-gray-800' :
                    'bg-green-100 text-green-800'
                  }`}>
                    {po.status}
                  </span>
                </div>
              </div>
            ))}
          </div>
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
              <th className="text-left py-2 px-3 font-medium">Material</th>
              <th className="text-left py-2 px-3 font-medium hidden sm:table-cell">Name</th>
              <th className="text-right py-2 px-3 font-medium">Stock</th>
              <th className="text-right py-2 px-3 font-medium hidden sm:table-cell">Available</th>
              <th className="text-left py-2 px-3 font-medium hidden sm:table-cell">UoM</th>
            </tr>
          </thead>
          <tbody>
            {stockLevels.map((stock) => (
              <tr key={stock.id} className="border-b hover:bg-gray-50">
                <td className="py-2 px-3 font-medium text-sm">{stock.material_code}</td>
                <td className="py-2 px-3 text-sm hidden sm:table-cell">{stock.material_name}</td>
                <td className="py-2 px-3 text-sm text-right">{stock.current_stock}</td>
                <td className="py-2 px-3 text-sm text-right hidden sm:table-cell">{stock.available_stock}</td>
                <td className="py-2 px-3 text-sm hidden sm:table-cell">{stock.base_uom}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )

  const renderTransactionsTab = () => (
    <div className="bg-white rounded-lg shadow-sm border p-4">
      <div className="flex justify-between items-center mb-4">
        <h3 className="text-lg font-semibold flex items-center gap-2">
          <Truck className="w-5 h-5" />
          Goods Receipts
        </h3>
        <button 
          onClick={() => handleAdd('gr')}
          className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
        >
          <Plus className="w-4 h-4" />
          <span className="hidden sm:inline">Add GR</span>
          <span className="sm:hidden">Add</span>
        </button>
      </div>
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead>
            <tr className="border-b">
              <th className="text-left py-2 px-3 font-medium">GR Number</th>
              <th className="text-left py-2 px-3 font-medium hidden sm:table-cell">PO Number</th>
              <th className="text-left py-2 px-3 font-medium hidden md:table-cell">Date</th>
              <th className="text-right py-2 px-3 font-medium hidden sm:table-cell">Amount</th>
              <th className="text-left py-2 px-3 font-medium">Status</th>
            </tr>
          </thead>
          <tbody>
            {goodsReceipts.map((gr) => (
              <tr key={gr.id} className="border-b hover:bg-gray-50">
                <td className="py-2 px-3 font-medium text-sm">{gr.gr_number}</td>
                <td className="py-2 px-3 text-sm hidden sm:table-cell">{gr.po_number}</td>
                <td className="py-2 px-3 text-sm hidden md:table-cell">{gr.gr_date}</td>
                <td className="py-2 px-3 text-sm text-right hidden sm:table-cell">${gr.total_amount}</td>
                <td className="py-2 px-3">
                  <span className="px-2 py-1 bg-green-100 text-green-800 rounded text-xs">
                    {gr.status}
                  </span>
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

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
        <div className="bg-white rounded-lg max-w-md w-full p-6 max-h-[90vh] overflow-y-auto">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-lg font-semibold">
              {modalType === 'add' ? 'Add' : 'Edit'} {
                modalEntity === 'material' ? 'Material' :
                modalEntity === 'vendor' ? 'Vendor' :
                modalEntity === 'pr' ? 'Purchase Requisition' :
                modalEntity === 'po' ? 'Purchase Order' :
                'Goods Receipt'
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
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-2 sm:p-4">
      <div className="max-w-7xl mx-auto">
        <div className="mb-4 sm:mb-6">
          <h1 className="text-2xl sm:text-3xl font-bold text-gray-900 mb-2">Material Management</h1>
          <p className="text-gray-600 text-sm sm:text-base">Complete procurement and inventory management</p>
          <div className="mt-2 px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-xs sm:text-sm inline-block">
            👥 Business User Access
          </div>
        </div>

        {/* Mobile-first tab navigation */}
        <div className="bg-white rounded-lg shadow-sm border mb-4 sm:mb-6">
          <div className="flex overflow-x-auto">
            {tabs.map((tab) => {
              const Icon = tab.icon
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`flex items-center gap-2 px-3 sm:px-4 py-3 whitespace-nowrap border-b-2 transition-colors text-sm ${
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
              {activeTab === 'procurement' && renderProcurementTab()}
              {activeTab === 'inventory' && renderInventoryTab()}
              {activeTab === 'transactions' && renderTransactionsTab()}
            </>
          )}
        </div>
        
        {renderModal()}
      </div>
    </div>
  )
}
*/