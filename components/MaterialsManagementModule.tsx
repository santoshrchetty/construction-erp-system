'use client'

import React, { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase-simple'
import { Package, Plus, Edit2, Trash2, Search, ArrowUpDown, Filter } from 'lucide-react'

interface Material {
  id: string
  material_code: string
  material_name: string
  description: string
  material_type: string
  base_uom: string
  standard_price: number
  valuation_class_id: string
  is_active: boolean
  current_stock?: number
  available_stock?: number
}

interface MaterialMovement {
  id: string
  material_code: string
  material_name: string
  movement_type: string
  quantity: number
  unit_price: number
  reference_doc: string
  movement_date: string
  posting_date: string
}

export default function MaterialsManagementModule() {
  const [materials, setMaterials] = useState<Material[]>([])
  const [movements, setMovements] = useState<MaterialMovement[]>([])
  const [loading, setLoading] = useState(false)
  const [activeTab, setActiveTab] = useState('materials')
  const [searchTerm, setSearchTerm] = useState('')
  const [filterType, setFilterType] = useState('ALL')
  const [showModal, setShowModal] = useState(false)
  const [modalType, setModalType] = useState<'add' | 'edit'>('add')
  const [editingMaterial, setEditingMaterial] = useState<Material | null>(null)

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    setLoading(true)
    try {
      // Load materials with stock levels
      const { data: materialsData } = await supabase
        .from('materials')
        .select(`
          *,
          stock_levels(current_stock, available_stock)
        `)
        .order('material_code')

      // Load recent movements
      const { data: movementsData } = await supabase
        .from('material_movements')
        .select(`
          *,
          materials(material_code, material_name)
        `)
        .order('posting_date', { ascending: false })
        .limit(50)

      if (materialsData) {
        const formattedMaterials = materialsData.map(m => ({
          ...m,
          current_stock: m.stock_levels?.[0]?.current_stock || 0,
          available_stock: m.stock_levels?.[0]?.available_stock || 0
        }))
        setMaterials(formattedMaterials)
      }

      if (movementsData) {
        const formattedMovements = movementsData.map(m => ({
          ...m,
          material_code: m.materials?.material_code || '',
          material_name: m.materials?.material_name || ''
        }))
        setMovements(formattedMovements)
      }
    } catch (error) {
      console.error('Error loading data:', error)
    } finally {
      setLoading(false)
    }
  }

  const filteredMaterials = materials.filter(material => {
    const matchesSearch = material.material_code.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         material.material_name.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesFilter = filterType === 'ALL' || material.material_type === filterType
    return matchesSearch && matchesFilter
  })

  const handleAdd = () => {
    setModalType('add')
    setEditingMaterial(null)
    setShowModal(true)
  }

  const handleEdit = (material: Material) => {
    setModalType('edit')
    setEditingMaterial(material)
    setShowModal(true)
  }

  const handleDelete = async (id: string) => {
    if (!confirm('Are you sure you want to delete this material?')) return
    
    try {
      const { error } = await supabase.from('materials').delete().eq('id', id)
      if (error) throw error
      loadData()
    } catch (error) {
      console.error('Error deleting material:', error)
    }
  }

  const handleSave = async (formData: any) => {
    try {
      if (modalType === 'add') {
        const { error } = await supabase.from('materials').insert([formData])
        if (error) throw error
      } else {
        const { error } = await supabase.from('materials').update(formData).eq('id', editingMaterial?.id)
        if (error) throw error
      }
      setShowModal(false)
      loadData()
    } catch (error) {
      console.error('Error saving material:', error)
    }
  }

  const getTypeColor = (type: string) => {
    switch (type) {
      case 'ROH': return 'bg-blue-100 text-blue-800'
      case 'FERT': return 'bg-green-100 text-green-800'
      case 'SERV': return 'bg-purple-100 text-purple-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const getMovementColor = (type: string) => {
    switch (type) {
      case '101': return 'bg-green-100 text-green-800' // Receipt
      case '261': return 'bg-orange-100 text-orange-800' // Issue to Project
      case '201': return 'bg-red-100 text-red-800' // Issue to Cost Center
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const renderModal = () => {
    if (!showModal) return null

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
        <div className="bg-white rounded-lg max-w-md w-full p-6">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-lg font-semibold">
              {modalType === 'add' ? 'Add Material' : 'Edit Material'}
            </h3>
            <button onClick={() => setShowModal(false)} className="text-gray-500 hover:text-gray-700">
              ×
            </button>
          </div>
          
          <form onSubmit={(e) => {
            e.preventDefault()
            const formData = new FormData(e.target as HTMLFormElement)
            const data = Object.fromEntries(formData.entries())
            data.standard_price = parseFloat(data.standard_price as string) || 0
            data.is_active = true
            handleSave(data)
          }}>
            <input name="material_code" placeholder="Material Code" defaultValue={editingMaterial?.material_code || ''} className="w-full p-2 border rounded mb-3" required />
            <input name="material_name" placeholder="Material Name" defaultValue={editingMaterial?.material_name || ''} className="w-full p-2 border rounded mb-3" required />
            <textarea name="description" placeholder="Description" defaultValue={editingMaterial?.description || ''} className="w-full p-2 border rounded mb-3" rows={2} />
            
            <select name="material_type" className="w-full p-2 border rounded mb-3" defaultValue={editingMaterial?.material_type || 'ROH'}>
              <option value="ROH">ROH - Raw Materials</option>
              <option value="FERT">FERT - Finished Goods</option>
              <option value="SERV">SERV - Services</option>
            </select>
            
            <input name="base_uom" placeholder="Base UoM" defaultValue={editingMaterial?.base_uom || ''} className="w-full p-2 border rounded mb-3" required />
            <input name="standard_price" type="number" step="0.01" placeholder="Standard Price" defaultValue={editingMaterial?.standard_price || ''} className="w-full p-2 border rounded mb-3" />
            
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
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-4">
      <div className="max-w-7xl mx-auto">
        <div className="mb-6">
          <h1 className="text-3xl font-bold text-gray-900 flex items-center gap-3">
            <Package className="w-8 h-8 text-indigo-600" />
            Materials Management
          </h1>
          <p className="text-gray-600 mt-2">Manage construction materials, inventory, and movements</p>
        </div>

        {/* Tab Navigation */}
        <div className="bg-white rounded-lg shadow-sm border mb-6">
          <div className="flex">
            <button
              onClick={() => setActiveTab('materials')}
              className={`px-6 py-3 border-b-2 transition-colors ${
                activeTab === 'materials'
                  ? 'border-indigo-500 text-indigo-600 bg-indigo-50'
                  : 'border-transparent text-gray-600 hover:text-gray-900'
              }`}
            >
              Material Master
            </button>
            <button
              onClick={() => setActiveTab('movements')}
              className={`px-6 py-3 border-b-2 transition-colors ${
                activeTab === 'movements'
                  ? 'border-indigo-500 text-indigo-600 bg-indigo-50'
                  : 'border-transparent text-gray-600 hover:text-gray-900'
              }`}
            >
              Material Movements
            </button>
          </div>
        </div>

        {loading ? (
          <div className="bg-white rounded-lg shadow-sm border p-8 text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600 mx-auto"></div>
            <p className="mt-2 text-gray-600">Loading materials...</p>
          </div>
        ) : (
          <>
            {activeTab === 'materials' && (
              <div className="bg-white rounded-lg shadow-sm border">
                <div className="p-4 border-b">
                  <div className="flex flex-col sm:flex-row gap-4 justify-between items-start sm:items-center">
                    <div className="flex gap-4 flex-1">
                      <div className="relative">
                        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
                        <input
                          type="text"
                          placeholder="Search materials..."
                          value={searchTerm}
                          onChange={(e) => setSearchTerm(e.target.value)}
                          className="pl-10 pr-4 py-2 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
                        />
                      </div>
                      <select
                        value={filterType}
                        onChange={(e) => setFilterType(e.target.value)}
                        className="px-3 py-2 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500"
                      >
                        <option value="ALL">All Types</option>
                        <option value="ROH">Raw Materials</option>
                        <option value="FERT">Finished Goods</option>
                        <option value="SERV">Services</option>
                      </select>
                    </div>
                    <button
                      onClick={handleAdd}
                      className="flex items-center gap-2 px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700"
                    >
                      <Plus className="w-4 h-4" />
                      Add Material
                    </button>
                  </div>
                </div>

                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead className="bg-gray-50">
                      <tr>
                        <th className="text-left py-3 px-4 font-medium text-gray-700">Code</th>
                        <th className="text-left py-3 px-4 font-medium text-gray-700">Name</th>
                        <th className="text-left py-3 px-4 font-medium text-gray-700">Type</th>
                        <th className="text-left py-3 px-4 font-medium text-gray-700">UoM</th>
                        <th className="text-right py-3 px-4 font-medium text-gray-700">Price</th>
                        <th className="text-right py-3 px-4 font-medium text-gray-700">Stock</th>
                        <th className="text-right py-3 px-4 font-medium text-gray-700">Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {filteredMaterials.map((material) => (
                        <tr key={material.id} className="border-b hover:bg-gray-50">
                          <td className="py-3 px-4 font-mono text-sm">{material.material_code}</td>
                          <td className="py-3 px-4">
                            <div>
                              <div className="font-medium">{material.material_name}</div>
                              <div className="text-sm text-gray-500">{material.description}</div>
                            </div>
                          </td>
                          <td className="py-3 px-4">
                            <span className={`px-2 py-1 rounded text-xs ${getTypeColor(material.material_type)}`}>
                              {material.material_type}
                            </span>
                          </td>
                          <td className="py-3 px-4 text-sm">{material.base_uom}</td>
                          <td className="py-3 px-4 text-right font-mono">${material.standard_price.toFixed(2)}</td>
                          <td className="py-3 px-4 text-right">
                            <div className="text-sm">
                              <div>{material.current_stock?.toFixed(2) || '0.00'}</div>
                              <div className="text-gray-500">Available: {material.available_stock?.toFixed(2) || '0.00'}</div>
                            </div>
                          </td>
                          <td className="py-3 px-4 text-right">
                            <div className="flex justify-end gap-1">
                              <button
                                onClick={() => handleEdit(material)}
                                className="p-1 text-blue-600 hover:bg-blue-100 rounded"
                              >
                                <Edit2 className="w-4 h-4" />
                              </button>
                              <button
                                onClick={() => handleDelete(material.id)}
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
            )}

            {activeTab === 'movements' && (
              <div className="bg-white rounded-lg shadow-sm border">
                <div className="p-4 border-b">
                  <h3 className="text-lg font-semibold">Recent Material Movements</h3>
                  <p className="text-sm text-gray-600">Latest inventory transactions and postings</p>
                </div>

                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead className="bg-gray-50">
                      <tr>
                        <th className="text-left py-3 px-4 font-medium text-gray-700">Date</th>
                        <th className="text-left py-3 px-4 font-medium text-gray-700">Material</th>
                        <th className="text-left py-3 px-4 font-medium text-gray-700">Movement</th>
                        <th className="text-right py-3 px-4 font-medium text-gray-700">Quantity</th>
                        <th className="text-right py-3 px-4 font-medium text-gray-700">Value</th>
                        <th className="text-left py-3 px-4 font-medium text-gray-700">Reference</th>
                      </tr>
                    </thead>
                    <tbody>
                      {movements.map((movement) => (
                        <tr key={movement.id} className="border-b hover:bg-gray-50">
                          <td className="py-3 px-4 text-sm">{new Date(movement.posting_date).toLocaleDateString()}</td>
                          <td className="py-3 px-4">
                            <div>
                              <div className="font-mono text-sm">{movement.material_code}</div>
                              <div className="text-sm text-gray-600">{movement.material_name}</div>
                            </div>
                          </td>
                          <td className="py-3 px-4">
                            <span className={`px-2 py-1 rounded text-xs ${getMovementColor(movement.movement_type)}`}>
                              {movement.movement_type}
                            </span>
                          </td>
                          <td className="py-3 px-4 text-right font-mono">{movement.quantity.toFixed(2)}</td>
                          <td className="py-3 px-4 text-right font-mono">${(movement.quantity * movement.unit_price).toFixed(2)}</td>
                          <td className="py-3 px-4 text-sm">{movement.reference_doc}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}
          </>
        )}

        {renderModal()}
      </div>
    </div>
  )
}