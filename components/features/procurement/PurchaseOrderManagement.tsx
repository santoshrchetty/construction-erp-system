'use client'

import React, { useState, useEffect } from 'react'
import { Plus, Search, Eye, Edit, Check, X, FileText, Calendar, User, Package } from 'lucide-react'

interface PurchaseOrder {
  id: string
  po_number: string
  po_date: string
  status: string
  approval_status: string
  total_amount: number
  vendors: { vendor_name: string; vendor_code: string }
  projects?: { name: string; code: string }
}

interface POItem {
  id?: string
  line_number: number
  material_code: string
  material_description: string
  ordered_quantity: number
  unit_of_measure: string
  unit_price: number
  line_amount: number
  delivery_date?: string
}

export function PurchaseOrderManagement() {
  const [purchaseOrders, setPurchaseOrders] = useState<PurchaseOrder[]>([])
  const [selectedPO, setSelectedPO] = useState<any>(null)
  const [showCreateForm, setShowCreateForm] = useState(false)
  const [showItemForm, setShowItemForm] = useState(false)
  const [loading, setLoading] = useState(true)
  const [statusFilter, setStatusFilter] = useState('')
  const [searchTerm, setSearchTerm] = useState('')

  // Form states
  const [poForm, setPOForm] = useState({
    supplierId: '',
    projectId: '',
    deliveryDate: '',
    paymentTerms: 'NET30',
    remarks: ''
  })

  const [itemForm, setItemForm] = useState({
    materialCode: '',
    materialDescription: '',
    orderedQuantity: 1,
    unitOfMeasure: 'NOS',
    unitPrice: 0,
    deliveryDate: ''
  })

  const [suppliers, setSuppliers] = useState([])
  const [materials, setMaterials] = useState([])

  useEffect(() => {
    loadPurchaseOrders()
    loadSuppliers()
  }, [statusFilter])

  const loadPurchaseOrders = async () => {
    try {
      const params = new URLSearchParams({ action: 'list' })
      if (statusFilter) params.append('status', statusFilter)

      const response = await fetch(`/api/purchase?${params}`)
      const result = await response.json()
      
      if (result.success) {
        setPurchaseOrders(result.data || [])
      }
    } catch (error) {
      console.error('Failed to load purchase orders:', error)
    } finally {
      setLoading(false)
    }
  }

  const loadSuppliers = async () => {
    try {
      const response = await fetch('/api/purchase?action=suppliers')
      const result = await response.json()
      
      if (result.success) {
        setSuppliers(result.data || [])
      }
    } catch (error) {
      console.error('Failed to load suppliers:', error)
    }
  }

  const searchMaterials = async (term: string) => {
    if (term.length < 2) return
    
    try {
      const response = await fetch(`/api/purchase?action=materials&search=${term}`)
      const result = await response.json()
      
      if (result.success) {
        setMaterials(result.data || [])
      }
    } catch (error) {
      console.error('Failed to search materials:', error)
    }
  }

  const createPurchaseOrder = async () => {
    try {
      const response = await fetch('/api/purchase?action=create', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          companyCode: 'C001',
          ...poForm,
          createdBy: 'current-user-id' // Replace with actual user ID
        })
      })

      const result = await response.json()
      
      if (result.success) {
        setShowCreateForm(false)
        setPOForm({
          supplierId: '',
          projectId: '',
          deliveryDate: '',
          paymentTerms: 'NET30',
          remarks: ''
        })
        loadPurchaseOrders()
      }
    } catch (error) {
      console.error('Failed to create purchase order:', error)
    }
  }

  const viewPODetails = async (poId: string) => {
    try {
      const response = await fetch(`/api/purchase?action=details&id=${poId}`)
      const result = await response.json()
      
      if (result.success) {
        setSelectedPO(result.data)
      }
    } catch (error) {
      console.error('Failed to load PO details:', error)
    }
  }

  const addPOItem = async () => {
    if (!selectedPO) return

    try {
      const response = await fetch('/api/purchase?action=add-item', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          poId: selectedPO.id,
          item: itemForm
        })
      })

      const result = await response.json()
      
      if (result.success) {
        setShowItemForm(false)
        setItemForm({
          materialCode: '',
          materialDescription: '',
          orderedQuantity: 1,
          unitOfMeasure: 'NOS',
          unitPrice: 0,
          deliveryDate: ''
        })
        viewPODetails(selectedPO.id) // Refresh PO details
      }
    } catch (error) {
      console.error('Failed to add PO item:', error)
    }
  }

  const approvePO = async (poId: string) => {
    try {
      const response = await fetch('/api/purchase?action=approve', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          poId: poId,
          approverId: 'current-user-id', // Replace with actual user ID
          comments: 'Approved via web interface'
        })
      })

      const result = await response.json()
      
      if (result.success) {
        loadPurchaseOrders()
        if (selectedPO?.id === poId) {
          viewPODetails(poId)
        }
      }
    } catch (error) {
      console.error('Failed to approve PO:', error)
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'DRAFT': return 'bg-gray-100 text-gray-800'
      case 'APPROVED': return 'bg-green-100 text-green-800'
      case 'REJECTED': return 'bg-red-100 text-red-800'
      case 'CLOSED': return 'bg-blue-100 text-blue-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const filteredPOs = purchaseOrders.filter(po =>
    po.po_number.toLowerCase().includes(searchTerm.toLowerCase()) ||
    po.vendors.vendor_name.toLowerCase().includes(searchTerm.toLowerCase())
  )

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading purchase orders...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="p-6">
        {/* Header */}
        <div className="mb-6">
          <h1 className="text-3xl font-bold text-gray-900">Purchase Order Management</h1>
          <p className="text-gray-600 mt-2">Create and manage purchase orders</p>
        </div>

        {/* Filters and Actions */}
        <div className="bg-white rounded-lg shadow-sm border p-4 mb-6">
          <div className="flex flex-wrap items-center justify-between gap-4">
            <div className="flex items-center space-x-4">
              <div className="relative">
                <Search className="w-5 h-5 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
                <input
                  type="text"
                  placeholder="Search POs..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10 pr-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">All Status</option>
                <option value="DRAFT">Draft</option>
                <option value="APPROVED">Approved</option>
                <option value="REJECTED">Rejected</option>
                <option value="CLOSED">Closed</option>
              </select>
            </div>

            <button
              onClick={() => setShowCreateForm(true)}
              className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
            >
              <Plus className="w-4 h-4 mr-2" />
              Create PO
            </button>
          </div>
        </div>

        {/* Purchase Orders List */}
        <div className="bg-white rounded-lg shadow-sm border overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">PO Number</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Supplier</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Date</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Amount</th>
                  <th className="px-6 py-3 text-center text-xs font-medium text-gray-500 uppercase">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {filteredPOs.map((po) => (
                  <tr key={po.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 font-medium text-blue-600">
                      <div className="flex items-center">
                        <FileText className="w-4 h-4 mr-2 text-gray-400" />
                        {po.po_number}
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div>
                        <div className="font-medium">{po.vendors.vendor_name}</div>
                        <div className="text-sm text-gray-500">{po.vendors.vendor_code}</div>
                      </div>
                    </td>
                    <td className="px-6 py-4 text-sm">
                      {new Date(po.po_date).toLocaleDateString()}
                    </td>
                    <td className="px-6 py-4">
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(po.status)}`}>
                        {po.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right font-medium">
                      ₹{po.total_amount.toLocaleString()}
                    </td>
                    <td className="px-6 py-4 text-center">
                      <div className="flex items-center justify-center space-x-2">
                        <button
                          onClick={() => viewPODetails(po.id)}
                          className="p-1 text-blue-600 hover:text-blue-800"
                          title="View Details"
                        >
                          <Eye className="w-4 h-4" />
                        </button>
                        {po.status === 'DRAFT' && (
                          <button
                            onClick={() => approvePO(po.id)}
                            className="p-1 text-green-600 hover:text-green-800"
                            title="Approve"
                          >
                            <Check className="w-4 h-4" />
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Create PO Modal */}
        {showCreateForm && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg p-6 w-full max-w-md">
              <h3 className="text-lg font-bold mb-4">Create Purchase Order</h3>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Supplier</label>
                  <select
                    value={poForm.supplierId}
                    onChange={(e) => setPOForm({...poForm, supplierId: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                    required
                  >
                    <option value="">Select Supplier</option>
                    {suppliers.map((supplier: any) => (
                      <option key={supplier.id} value={supplier.id}>
                        {supplier.code} - {supplier.name}
                      </option>
                    ))}
                  </select>
                </div>
                
                <div>
                  <label className="block text-sm font-medium mb-1">Delivery Date</label>
                  <input
                    type="date"
                    value={poForm.deliveryDate}
                    onChange={(e) => setPOForm({...poForm, deliveryDate: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium mb-1">Payment Terms</label>
                  <select
                    value={poForm.paymentTerms}
                    onChange={(e) => setPOForm({...poForm, paymentTerms: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  >
                    <option value="NET30">NET 30</option>
                    <option value="NET15">NET 15</option>
                    <option value="ADVANCE">Advance Payment</option>
                    <option value="COD">Cash on Delivery</option>
                  </select>
                </div>
                
                <div>
                  <label className="block text-sm font-medium mb-1">Remarks</label>
                  <textarea
                    value={poForm.remarks}
                    onChange={(e) => setPOForm({...poForm, remarks: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                    rows={3}
                  />
                </div>
              </div>
              
              <div className="flex justify-end space-x-3 mt-6">
                <button
                  onClick={() => setShowCreateForm(false)}
                  className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  onClick={createPurchaseOrder}
                  className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
                >
                  Create PO
                </button>
              </div>
            </div>
          </div>
        )}

        {/* PO Details Modal */}
        {selectedPO && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg p-6 w-full max-w-4xl max-h-[90vh] overflow-y-auto">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-bold">PO Details - {selectedPO.po_number}</h3>
                <button
                  onClick={() => setSelectedPO(null)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <X className="w-6 h-6" />
                </button>
              </div>
              
              {/* PO Header Info */}
              <div className="grid grid-cols-2 gap-4 mb-6 p-4 bg-gray-50 rounded">
                <div>
                  <label className="text-sm font-medium text-gray-600">Supplier</label>
                  <p className="font-medium">{selectedPO.vendors?.vendor_name}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-600">PO Date</label>
                  <p className="font-medium">{new Date(selectedPO.po_date).toLocaleDateString()}</p>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-600">Status</label>
                  <span className={`px-2 py-1 rounded text-xs font-medium ${getStatusColor(selectedPO.status)}`}>
                    {selectedPO.status}
                  </span>
                </div>
                <div>
                  <label className="text-sm font-medium text-gray-600">Total Amount</label>
                  <p className="font-medium text-green-600">₹{selectedPO.total_amount?.toLocaleString()}</p>
                </div>
              </div>

              {/* PO Items */}
              <div className="mb-4">
                <div className="flex justify-between items-center mb-2">
                  <h4 className="font-medium">Items</h4>
                  {selectedPO.status === 'DRAFT' && (
                    <button
                      onClick={() => setShowItemForm(true)}
                      className="flex items-center px-3 py-1 bg-green-600 text-white rounded text-sm hover:bg-green-700"
                    >
                      <Plus className="w-4 h-4 mr-1" />
                      Add Item
                    </button>
                  )}
                </div>
                
                <div className="overflow-x-auto">
                  <table className="w-full border">
                    <thead className="bg-gray-50">
                      <tr>
                        <th className="px-3 py-2 text-left text-xs font-medium text-gray-500">Material</th>
                        <th className="px-3 py-2 text-right text-xs font-medium text-gray-500">Qty</th>
                        <th className="px-3 py-2 text-right text-xs font-medium text-gray-500">Price</th>
                        <th className="px-3 py-2 text-right text-xs font-medium text-gray-500">Amount</th>
                      </tr>
                    </thead>
                    <tbody>
                      {selectedPO.items?.map((item: POItem) => (
                        <tr key={item.id} className="border-t">
                          <td className="px-3 py-2">
                            <div>
                              <div className="font-medium">{item.material_code}</div>
                              <div className="text-sm text-gray-500">{item.material_description}</div>
                            </div>
                          </td>
                          <td className="px-3 py-2 text-right">{item.ordered_quantity} {item.unit_of_measure}</td>
                          <td className="px-3 py-2 text-right">₹{item.unit_price.toLocaleString()}</td>
                          <td className="px-3 py-2 text-right font-medium">₹{item.line_amount.toLocaleString()}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Add Item Modal */}
        {showItemForm && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg p-6 w-full max-w-md">
              <h3 className="text-lg font-bold mb-4">Add Item</h3>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Material Code</label>
                  <input
                    type="text"
                    value={itemForm.materialCode}
                    onChange={(e) => {
                      setItemForm({...itemForm, materialCode: e.target.value})
                      searchMaterials(e.target.value)
                    }}
                    className="w-full border rounded px-3 py-2"
                    placeholder="Search material..."
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium mb-1">Description</label>
                  <input
                    type="text"
                    value={itemForm.materialDescription}
                    onChange={(e) => setItemForm({...itemForm, materialDescription: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  />
                </div>
                
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-1">Quantity</label>
                    <input
                      type="number"
                      value={itemForm.orderedQuantity}
                      onChange={(e) => setItemForm({...itemForm, orderedQuantity: parseFloat(e.target.value) || 0})}
                      className="w-full border rounded px-3 py-2"
                      min="0"
                      step="0.001"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-1">UOM</label>
                    <select
                      value={itemForm.unitOfMeasure}
                      onChange={(e) => setItemForm({...itemForm, unitOfMeasure: e.target.value})}
                      className="w-full border rounded px-3 py-2"
                    >
                      <option value="NOS">NOS</option>
                      <option value="KG">KG</option>
                      <option value="MT">MT</option>
                      <option value="LTR">LTR</option>
                      <option value="SQM">SQM</option>
                    </select>
                  </div>
                </div>
                
                <div>
                  <label className="block text-sm font-medium mb-1">Unit Price</label>
                  <input
                    type="number"
                    value={itemForm.unitPrice}
                    onChange={(e) => setItemForm({...itemForm, unitPrice: parseFloat(e.target.value) || 0})}
                    className="w-full border rounded px-3 py-2"
                    min="0"
                    step="0.01"
                  />
                </div>
              </div>
              
              <div className="flex justify-end space-x-3 mt-6">
                <button
                  onClick={() => setShowItemForm(false)}
                  className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  onClick={addPOItem}
                  className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700"
                >
                  Add Item
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}