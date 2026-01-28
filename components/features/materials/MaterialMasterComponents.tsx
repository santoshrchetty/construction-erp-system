import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'
import { ImportExportButton } from '@/components/shared/ImportExportButton'
import { BulkOperationsService } from '@/lib/services/BulkOperationsService'

// Create Material Master Component (ERP Standard - No Plant Dependency)
export function CreateMaterialMaster() {
  const [formData, setFormData] = useState({
    material_code: '',
    material_name: '',
    description: '',
    category: '',
    material_group: '',
    base_uom: '',
    material_type: '',
    weight_unit: '',
    gross_weight: 0,
    net_weight: 0,
    volume_unit: '',
    volume: 0
  })
  const [categories, setCategories] = useState([])
  const [groups, setGroups] = useState([])
  const [materialTypes, setMaterialTypes] = useState([])
  const [loading, setLoading] = useState(false)

  const uoms = ['BAG', 'TON', 'CUM', 'KG', 'LTR', 'PCS', 'MTR', 'EA']

  useEffect(() => {
    loadCategories()
    loadMaterialTypes()
  }, [])

  useEffect(() => {
    if (formData.category) {
      loadGroups(formData.category)
    } else {
      setGroups([])
    }
  }, [formData.category])

  const loadCategories = async () => {
    try {
      const response = await fetch('/api/materials/master-data?type=categories')
      const data = await response.json()
      if (data.success) {
        setCategories(data.data || [])
      }
    } catch (error) {
      console.error('Failed to load categories:', error)
    }
  }

  const loadGroups = async (categoryCode) => {
    try {
      const response = await fetch(`/api/materials/master-data?type=groups&category=${categoryCode}`)
      const data = await response.json()
      if (data.success) {
        setGroups(data.data || [])
      }
    } catch (error) {
      console.error('Failed to load groups:', error)
    }
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setLoading(true)
    try {
      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          category: 'materials',
          action: 'create-material',
          payload: formData
        })
      })
      const data = await response.json()
      if (data.success) {
        alert(`Material ${formData.material_code} created successfully! Use "Extend Material to Plant" to make it available in specific plants.`)
        setFormData({
          material_code: '',
          material_name: '',
          description: '',
          category: '',
          material_group: '',
          base_uom: '',
          material_type: '',
          weight_unit: '',
          gross_weight: 0,
          net_weight: 0,
          volume_unit: '',
          volume: 0
        })
      } else {
        alert('Error: ' + data.error)
      }
    } catch (error) {
      alert('Error: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const loadMaterialTypes = async () => {
    try {
      const response = await fetch('/api/materials/master-data?type=material-types')
      const data = await response.json()
      if (data.success && data.data) {
        setMaterialTypes(data.data)
      }
    } catch (error) {
      console.error('Failed to load material types:', error)
    }
  }

  return (
    <div className="p-6">
      <div className="bg-white rounded-lg shadow p-6">
        <div className="mb-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <div className="flex items-center">
            <Icons.Info className="w-5 h-5 text-blue-600 mr-2" />
            <div>
              <p className="text-sm text-blue-600">Create global material master data. Use "Extend Material to Plant" afterward to make materials available in specific plants.</p>
            </div>
          </div>
        </div>
        
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium mb-2">Material Code *</label>
              <input
                type="text"
                required
                maxLength={31}
                className="w-full border rounded-lg px-3 py-2"
                value={formData.material_code}
                onChange={(e) => setFormData(prev => ({ ...prev, material_code: e.target.value.toUpperCase() }))}
                placeholder="e.g., CEM-OPC-001"
              />
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Material Name *</label>
              <input
                type="text"
                required
                maxLength={240}
                className="w-full border rounded-lg px-3 py-2"
                value={formData.material_name}
                onChange={(e) => setFormData(prev => ({ ...prev, material_name: e.target.value }))}
                placeholder="e.g., Ordinary Portland Cement 42.5"
              />
            </div>
            <div className="md:col-span-2">
              <label className="block text-sm font-medium mb-2">Description</label>
              <textarea
                className="w-full border rounded-lg px-3 py-2"
                rows={3}
                value={formData.description}
                onChange={(e) => setFormData(prev => ({ ...prev, description: e.target.value }))}
                placeholder="Detailed material description..."
              />
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Category *</label>
              <select
                required
                className="w-full border rounded-lg px-3 py-2"
                value={formData.category}
                onChange={(e) => setFormData(prev => ({ ...prev, category: e.target.value, material_group: '' }))}
              >
                <option value="">Select Category</option>
                {categories.map(cat => (
                  <option key={cat.category_code} value={cat.category_code}>
                    {cat.category_name}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Material Group</label>
              <select
                className="w-full border rounded-lg px-3 py-2"
                value={formData.material_group}
                onChange={(e) => setFormData(prev => ({ ...prev, material_group: e.target.value }))}
                disabled={!formData.category}
              >
                <option value="">Select Group</option>
                {groups.map(group => (
                  <option key={group.group_code} value={group.group_code}>
                    {group.group_name}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Base UOM *</label>
              <select
                required
                className="w-full border rounded-lg px-3 py-2"
                value={formData.base_uom}
                onChange={(e) => setFormData(prev => ({ ...prev, base_uom: e.target.value }))}
              >
                <option value="">Select UOM</option>
                {uoms.map(uom => <option key={uom} value={uom}>{uom}</option>)}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Material Type *</label>
              <select
                required
                className="w-full border rounded-lg px-3 py-2"
                value={formData.material_type}
                onChange={(e) => setFormData(prev => ({ ...prev, material_type: e.target.value }))}
              >
                <option value="">Select Material Type</option>
                {materialTypes.map(type => (
                  <option key={type.material_type_code} value={type.material_type_code}>
                    {type.material_type_code} - {type.material_type_name}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Weight Unit</label>
              <select
                className="w-full border rounded-lg px-3 py-2"
                value={formData.weight_unit}
                onChange={(e) => setFormData(prev => ({ ...prev, weight_unit: e.target.value }))}
              >
                <option value="">Select Weight Unit</option>
                <option value="KG">KG</option>
                <option value="TON">TON</option>
                <option value="G">G</option>
                <option value="LB">LB</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Volume Unit</label>
              <select
                className="w-full border rounded-lg px-3 py-2"
                value={formData.volume_unit}
                onChange={(e) => setFormData(prev => ({ ...prev, volume_unit: e.target.value }))}
              >
                <option value="">Select Volume Unit</option>
                <option value="CUM">CUM</option>
                <option value="LTR">LTR</option>
                <option value="ML">ML</option>
                <option value="GAL">GAL</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Gross Weight</label>
              <input
                type="number"
                min="0"
                step="0.001"
                className="w-full border rounded-lg px-3 py-2"
                value={formData.gross_weight}
                onChange={(e) => setFormData(prev => ({ ...prev, gross_weight: parseFloat(e.target.value) || 0 }))}
              />
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Net Weight</label>
              <input
                type="number"
                min="0"
                step="0.001"
                className="w-full border rounded-lg px-3 py-2"
                value={formData.net_weight}
                onChange={(e) => setFormData(prev => ({ ...prev, net_weight: parseFloat(e.target.value) || 0 }))}
              />
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Volume</label>
              <input
                type="number"
                min="0"
                step="0.001"
                className="w-full border rounded-lg px-3 py-2"
                value={formData.volume}
                onChange={(e) => setFormData(prev => ({ ...prev, volume: parseFloat(e.target.value) || 0 }))}
              />
            </div>
          </div>
          <div className="flex space-x-4 pt-4">
            <button
              type="submit"
              disabled={loading}
              className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50"
            >
              {loading ? 'Creating...' : 'Create Material Master'}
            </button>
            <button
              type="button"
              onClick={() => setFormData({
                material_code: '',
                material_name: '',
                description: '',
                category: '',
                material_group: '',
                base_uom: '',
                material_type: 'FERT'
              })}
              className="bg-gray-500 text-white px-6 py-2 rounded-lg hover:bg-gray-600"
            >
              Clear
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}

// Maintain Material Master Component (ERP Standard - Global Data Only)
export function MaintainMaterialMaster() {
  const [searchCode, setSearchCode] = useState('')
  const [searchParams, setSearchParams] = useState({
    material_name: '',
    category: '',
    material_type: ''
  })
  const [searchResults, setSearchResults] = useState([])
  const [showSearchResults, setShowSearchResults] = useState(false)
  const [material, setMaterial] = useState(null)
  const [categories, setCategories] = useState([])
  const [groups, setGroups] = useState([])
  const [materialTypes, setMaterialTypes] = useState([])
  const [loading, setLoading] = useState(false)
  const [searching, setSearching] = useState(false)
  const [saving, setSaving] = useState(false)
  const [formData, setFormData] = useState({
    material_name: '',
    description: '',
    category: '',
    material_group: '',
    base_uom: '',
    material_type: '',
    weight_unit: '',
    gross_weight: 0,
    net_weight: 0,
    volume_unit: '',
    volume: 0
  })

  const uoms = ['BAG', 'TON', 'CUM', 'KG', 'LTR', 'PCS', 'MTR', 'EA']
  const weightUnits = ['KG', 'TON', 'G', 'LB']
  const volumeUnits = ['CUM', 'LTR', 'ML', 'GAL']

  useEffect(() => {
    loadCategories()
    loadMaterialTypes()
  }, [])

  useEffect(() => {
    if (formData.category) {
      loadGroups(formData.category)
    }
  }, [formData.category])

  const loadCategories = async () => {
    try {
      const response = await fetch('/api/materials/master-data?type=categories')
      const data = await response.json()
      if (data.success) {
        setCategories(data.data || [])
      }
    } catch (error) {
      console.error('Failed to load categories:', error)
    }
  }

  const loadMaterialTypes = async () => {
    try {
      const response = await fetch('/api/materials/master-data?type=material-types')
      const data = await response.json()
      if (data.success && data.data) {
        setMaterialTypes(data.data)
      }
    } catch (error) {
      console.error('Failed to load material types:', error)
    }
  }

  const loadGroups = async (categoryCode) => {
    try {
      const response = await fetch(`/api/materials/master-data?type=groups&category=${categoryCode}`)
      const data = await response.json()
      if (data.success) {
        setGroups(data.data || [])
      }
    } catch (error) {
      console.error('Failed to load groups:', error)
    }
  }

  const searchByParameters = async () => {
    if (!searchParams.material_name && !searchParams.category && !searchParams.material_type) {
      alert('Please enter at least one search parameter')
      return
    }
    
    setSearching(true)
    try {
      const params = new URLSearchParams({
        category: 'materials',
        action: 'material-master'
      })
      
      if (searchParams.material_name) params.append('search', searchParams.material_name)
      if (searchParams.category) params.append('material_category', searchParams.category)
      if (searchParams.material_type) params.append('material_type', searchParams.material_type)
      
      const response = await fetch(`/api/tiles?${params.toString()}`)
      const data = await response.json()
      
      if (data.success) {
        setSearchResults(data.data.materials || [])
        setShowSearchResults(true)
      } else {
        alert('Search failed: ' + data.error)
      }
    } catch (error) {
      alert('Search error: ' + error.message)
    } finally {
      setSearching(false)
    }
  }

  const selectMaterial = async (materialCode) => {
    setSearchCode(materialCode)
    setShowSearchResults(false)
    await searchMaterial(materialCode)
  }
  const searchMaterial = async (codeToSearch = null) => {
    const code = codeToSearch || searchCode
    if (!code) return
    setLoading(true)
    try {
      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          category: 'materials',
          action: 'maintain-material',
          payload: { material_id: code }
        })
      })
      const data = await response.json()
      if (data.success && data.data.material) {
        const mat = data.data.material
        setMaterial(mat)
        
        // Load groups first if category exists, then populate form
        if (mat.category) {
          await loadGroups(mat.category)
        }
        
        // Then populate form data
        setFormData({
          material_name: mat.material_name || '',
          description: mat.description || '',
          category: mat.category || '',
          material_group: mat.material_group || '',
          base_uom: mat.base_uom || '',
          material_type: mat.material_type || '',
          weight_unit: mat.weight_unit || '',
          gross_weight: mat.gross_weight || 0,
          net_weight: mat.net_weight || 0,
          volume_unit: mat.volume_unit || '',
          volume: mat.volume || 0
        })
      } else {
        alert('Material not found')
        setMaterial(null)
        clearForm()
      }
    } catch (error) {
      alert('Search error: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const updateMaterial = async () => {
    if (!material) return
    setSaving(true)
    try {
      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          category: 'materials',
          action: 'maintain-material',
          payload: { 
            material_id: material.material_code,
            ...formData
          }
        })
      })
      const data = await response.json()
      if (data.success) {
        alert('Material updated successfully!')
        // Refresh material data
        await searchMaterial()
      } else {
        alert('Update failed: ' + data.error)
      }
    } catch (error) {
      alert('Update error: ' + error.message)
    } finally {
      setSaving(false)
    }
  }

  const clearForm = () => {
    setMaterial(null)
    setSearchCode('')
    setSearchParams({
      material_name: '',
      category: '',
      material_type: ''
    })
    setSearchResults([])
    setShowSearchResults(false)
    setFormData({
      material_name: '',
      description: '',
      category: '',
      material_group: '',
      base_uom: '',
      material_type: '',
      weight_unit: '',
      gross_weight: 0,
      net_weight: 0,
      volume_unit: '',
      volume: 0
    })
  }

  return (
    <div className="p-6">
      <div className="bg-white rounded-lg shadow p-6">
        <div className="mb-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <div className="flex items-center">
            <Icons.Edit className="w-5 h-5 text-blue-600 mr-2" />
            <div>
              <p className="text-sm text-blue-600">Maintain global material master data. Use "Material Plant Parameters" to manage plant-specific settings.</p>
            </div>
          </div>
        </div>
        
        {/* Search Section */}
        <div className="mb-6 p-4 bg-gray-50 rounded-lg">
          <h3 className="text-md font-medium text-gray-900 mb-4">Search Material</h3>
          
          {/* Direct Code Search */}
          <div className="mb-4 p-3 bg-white rounded border">
            <label className="block text-sm font-medium text-gray-700 mb-2">Direct Material Code Search</label>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <input
                  type="text"
                  placeholder="Enter Material Code"
                  className="w-full border rounded-lg px-3 py-2"
                  value={searchCode}
                  onChange={(e) => setSearchCode(e.target.value.toUpperCase())}
                  onKeyPress={(e) => e.key === 'Enter' && searchMaterial()}
                />
              </div>
              <div className="flex items-end">
                <button
                  onClick={() => searchMaterial()}
                  disabled={loading || !searchCode}
                  className="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50"
                >
                  {loading ? 'Loading...' : 'Search & Load'}
                </button>
              </div>
              <div className="flex items-end">
                <button
                  onClick={clearForm}
                  className="w-full bg-gray-500 text-white py-2 rounded-lg hover:bg-gray-600"
                >
                  Clear Form
                </button>
              </div>
            </div>
          </div>

          {/* Parameter-based Search */}
          <div className="p-3 bg-white rounded border">
            <label className="block text-sm font-medium text-gray-700 mb-2">Search by Parameters</label>
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">Material Name</label>
                <input
                  type="text"
                  placeholder="Enter material name..."
                  className="w-full border rounded px-3 py-2 text-sm"
                  value={searchParams.material_name}
                  onChange={(e) => setSearchParams(prev => ({ ...prev, material_name: e.target.value }))}
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">Category</label>
                <select
                  className="w-full border rounded px-3 py-2 text-sm"
                  value={searchParams.category}
                  onChange={(e) => setSearchParams(prev => ({ ...prev, category: e.target.value }))}
                >
                  <option value="">All Categories</option>
                  {categories.map(cat => (
                    <option key={cat.category_code} value={cat.category_code}>
                      {cat.category_name}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">Material Type</label>
                <select
                  className="w-full border rounded px-3 py-2 text-sm"
                  value={searchParams.material_type}
                  onChange={(e) => setSearchParams(prev => ({ ...prev, material_type: e.target.value }))}
                >
                  <option value="">All Types</option>
                  {materialTypes.map(type => (
                    <option key={type.material_type_code} value={type.material_type_code}>
                      {type.material_type_code} - {type.material_type_name}
                    </option>
                  ))}
                </select>
              </div>
              <div className="flex items-end">
                <button
                  onClick={searchByParameters}
                  disabled={searching}
                  className="w-full bg-green-600 text-white py-2 rounded-lg hover:bg-green-700 disabled:opacity-50 text-sm"
                >
                  {searching ? 'Searching...' : 'Find Materials'}
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Search Results Modal */}
        {showSearchResults && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg p-6 max-w-6xl w-full mx-4 max-h-[80vh] overflow-y-auto">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-semibold">Search Results ({searchResults.length} materials found)</h3>
                <button
                  onClick={() => setShowSearchResults(false)}
                  className="text-gray-500 hover:text-gray-700"
                >
                  ✕
                </button>
              </div>
              
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Code</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Category</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
                      <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Action</th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {searchResults.map((mat, index) => (
                      <tr key={index} className="hover:bg-gray-50">
                        <td className="px-4 py-4 text-sm font-medium text-gray-900">{mat.material_code}</td>
                        <td className="px-4 py-4 text-sm text-gray-900">{mat.material_name}</td>
                        <td className="px-4 py-4 text-sm text-gray-500">{mat.category}</td>
                        <td className="px-4 py-4 text-sm text-gray-500">{mat.material_type}</td>
                        <td className="px-4 py-4 text-center">
                          <button
                            onClick={() => selectMaterial(mat.material_code)}
                            className="bg-blue-100 text-blue-700 px-3 py-1 rounded text-sm hover:bg-blue-200"
                          >
                            Select
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
                
                {searchResults.length === 0 && (
                  <div className="text-center py-8 text-gray-500">
                    No materials found matching the search criteria.
                  </div>
                )}
              </div>
            </div>
          </div>
        )}

        {/* Material Form */}
        {material && (
          <form onSubmit={(e) => { e.preventDefault(); updateMaterial(); }} className="space-y-6">
            {/* Basic Information */}
            <div className="border-b pb-4">
              <h3 className="text-lg font-medium text-gray-900 mb-4">Basic Information</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-2">Material Code</label>
                  <input
                    type="text"
                    disabled
                    className="w-full border rounded-lg px-3 py-2 bg-gray-100"
                    value={material.material_code}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-2">Material Name *</label>
                  <input
                    type="text"
                    required
                    maxLength={240}
                    className="w-full border rounded-lg px-3 py-2"
                    value={formData.material_name}
                    onChange={(e) => setFormData(prev => ({ ...prev, material_name: e.target.value }))}
                  />
                </div>
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium mb-2">Description</label>
                  <textarea
                    className="w-full border rounded-lg px-3 py-2"
                    rows={3}
                    value={formData.description}
                    onChange={(e) => setFormData(prev => ({ ...prev, description: e.target.value }))}
                    placeholder="Detailed material description..."
                  />
                </div>
              </div>
            </div>

            {/* Classification */}
            <div className="border-b pb-4">
              <h3 className="text-lg font-medium text-gray-900 mb-4">Classification</h3>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-2">Category *</label>
                  <select
                    required
                    className="w-full border rounded-lg px-3 py-2"
                    value={formData.category}
                    onChange={(e) => {
                      const newCategory = e.target.value
                      setFormData(prev => ({ ...prev, category: newCategory, material_group: '' }))
                      if (newCategory) {
                        loadGroups(newCategory)
                      } else {
                        setGroups([])
                      }
                    }}
                  >
                    <option value="">Select Category</option>
                    {categories.map(cat => (
                      <option key={cat.category_code} value={cat.category_code}>
                        {cat.category_name}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-2">Material Group</label>
                  <select
                    className="w-full border rounded-lg px-3 py-2"
                    value={formData.material_group}
                    onChange={(e) => setFormData(prev => ({ ...prev, material_group: e.target.value }))}
                    disabled={!formData.category}
                  >
                    <option value="">Select Group</option>
                    {groups.map(group => (
                      <option key={group.group_code} value={group.group_code}>
                        {group.group_name}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-2">Material Type *</label>
                  <select
                    required
                    className="w-full border rounded-lg px-3 py-2"
                    value={formData.material_type}
                    onChange={(e) => setFormData(prev => ({ ...prev, material_type: e.target.value }))}
                  >
                    <option value="">Select Type</option>
                    {materialTypes.map(type => (
                      <option key={type.material_type_code} value={type.material_type_code}>
                        {type.material_type_code} - {type.material_type_name}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
            </div>

            {/* Units of Measure */}
            <div className="border-b pb-4">
              <h3 className="text-lg font-medium text-gray-900 mb-4">Units of Measure</h3>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-2">Base UOM *</label>
                  <select
                    required
                    className="w-full border rounded-lg px-3 py-2"
                    value={formData.base_uom}
                    onChange={(e) => setFormData(prev => ({ ...prev, base_uom: e.target.value }))}
                  >
                    <option value="">Select UOM</option>
                    {uoms.map(uom => <option key={uom} value={uom}>{uom}</option>)}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-2">Weight Unit</label>
                  <select
                    className="w-full border rounded-lg px-3 py-2"
                    value={formData.weight_unit}
                    onChange={(e) => setFormData(prev => ({ ...prev, weight_unit: e.target.value }))}
                  >
                    <option value="">Select Weight Unit</option>
                    {weightUnits.map(unit => <option key={unit} value={unit}>{unit}</option>)}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-2">Volume Unit</label>
                  <select
                    className="w-full border rounded-lg px-3 py-2"
                    value={formData.volume_unit}
                    onChange={(e) => setFormData(prev => ({ ...prev, volume_unit: e.target.value }))}
                  >
                    <option value="">Select Volume Unit</option>
                    {volumeUnits.map(unit => <option key={unit} value={unit}>{unit}</option>)}
                  </select>
                </div>
              </div>
            </div>

            {/* Physical Properties */}
            <div className="border-b pb-4">
              <h3 className="text-lg font-medium text-gray-900 mb-4">Physical Properties</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-2">Gross Weight</label>
                  <input
                    type="number"
                    min="0"
                    step="0.001"
                    className="w-full border rounded-lg px-3 py-2"
                    value={formData.gross_weight}
                    onChange={(e) => setFormData(prev => ({ ...prev, gross_weight: parseFloat(e.target.value) || 0 }))}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-2">Net Weight</label>
                  <input
                    type="number"
                    min="0"
                    step="0.001"
                    className="w-full border rounded-lg px-3 py-2"
                    value={formData.net_weight}
                    onChange={(e) => setFormData(prev => ({ ...prev, net_weight: parseFloat(e.target.value) || 0 }))}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-2">Volume</label>
                  <input
                    type="number"
                    min="0"
                    step="0.001"
                    className="w-full border rounded-lg px-3 py-2"
                    value={formData.volume}
                    onChange={(e) => setFormData(prev => ({ ...prev, volume: parseFloat(e.target.value) || 0 }))}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-2">Plant Extensions</label>
                  <div className="text-sm text-gray-600 mt-2">
                    {material.plant_count || 0} plants configured
                  </div>
                </div>
              </div>
            </div>

            {/* Action Buttons */}
            <div className="flex space-x-4 pt-4">
              <button
                type="submit"
                disabled={saving}
                className="bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700 disabled:opacity-50"
              >
                {saving ? 'Updating...' : 'Update Material'}
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

        {!material && (
          <div className="text-center py-12 bg-blue-50 rounded-lg border-2 border-dashed border-blue-200">
            <Icons.Search className="w-12 h-12 text-blue-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-blue-900 mb-2">Material Maintenance</h3>
            <p className="text-blue-600 mb-4">Enter a material code and click "Search & Load" to begin maintenance.</p>
            <p className="text-sm text-blue-500">Similar to SAP MM02 - all fields will be populated automatically based on the material master data.</p>
          </div>
        )}
      </div>
    </div>
  )
}

// Display Material Master Component
export function DisplayMaterialMaster() {
  const [materials, setMaterials] = useState([])
  const [searchParams, setSearchParams] = useState({
    material_name: '',
    category: '',
    material_type: ''
  })
  const [categories, setCategories] = useState([])
  const [materialTypes, setMaterialTypes] = useState([])
  const [loading, setLoading] = useState(false)
  const [selectedMaterial, setSelectedMaterial] = useState(null)

  useEffect(() => {
    loadCategories()
    loadMaterialTypes()
  }, [])

  const loadCategories = async () => {
    try {
      const response = await fetch('/api/materials/master-data?type=categories')
      const data = await response.json()
      if (data.success) {
        setCategories(data.data || [])
      }
    } catch (error) {
      console.error('Failed to load categories:', error)
    }
  }

  const loadMaterialTypes = async () => {
    try {
      const response = await fetch('/api/materials/master-data?type=material-types')
      const data = await response.json()
      if (data.success && data.data) {
        setMaterialTypes(data.data)
      }
    } catch (error) {
      console.error('Failed to load material types:', error)
    }
  }

  const searchMaterials = async () => {
    if (!searchParams.material_name && !searchParams.category && !searchParams.material_type) {
      alert('Please enter at least one search parameter')
      return
    }
    
    setLoading(true)
    try {
      const params = new URLSearchParams({
        category: 'materials',
        action: 'material-master'
      })
      
      if (searchParams.material_name) params.append('search', searchParams.material_name)
      if (searchParams.category) params.append('material_category', searchParams.category)
      if (searchParams.material_type) params.append('material_type', searchParams.material_type)
      
      const response = await fetch(`/api/tiles?${params.toString()}`)
      const data = await response.json()
      
      if (data.success) {
        setMaterials(data.data.materials || [])
      } else {
        alert('Search failed: ' + data.error)
      }
    } catch (error) {
      alert('Search error: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const downloadTemplate = async () => {
    const result = await BulkOperationsService.downloadMaterialTemplate()
    
    if (!result.success) {
      alert('Failed to download template: ' + result.error)
    }
  }

  const handleExportMaterials = async () => {
    const result = await BulkOperationsService.exportMaterials({
      category: searchParams.category,
      material_type: searchParams.material_type
    })
    
    if (result.success) {
      alert(`Exported ${result.count} materials successfully!`)
    } else {
      alert('Export failed: ' + result.error)
    }
  }

  const handleImportMaterials = async (file: File) => {
    const result = await BulkOperationsService.importMaterials(file)
    
    if (result.success) {
      alert(`Import completed: ${result.data.successful} successful, ${result.data.failed} failed`)
      searchMaterials() // Refresh the list
    } else {
      alert('Import failed: ' + result.error)
    }
  }

  const viewMaterial = (material) => {
    setSelectedMaterial(material)
  }

  return (
    <div className="p-6">
      <div className="bg-white rounded-lg shadow p-6">
        <div className="mb-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <div className="flex items-center">
            <Icons.FileText className="w-5 h-5 text-blue-600 mr-2" />
            <div>
              <p className="text-sm text-blue-600">Display and search global material master data with comprehensive filtering options.</p>
            </div>
          </div>
        </div>
        
        {/* Search Section */}
        <div className="mb-6 p-4 bg-gray-50 rounded-lg">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-md font-medium text-gray-900">Search Materials</h3>
            <div className="flex gap-2">
              <button
                onClick={downloadTemplate}
                className="px-3 py-1.5 bg-gray-600 text-white rounded-lg hover:bg-gray-700 text-sm"
              >
                <Icons.Download className="w-4 h-4 inline mr-1" />
                Template
              </button>
              <ImportExportButton
                onExport={handleExportMaterials}
                onImport={handleImportMaterials}
                count={materials.length}
                acceptedFileTypes=".xlsx,.xls,.csv"
              />
            </div>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Material Name</label>
              <input
                type="text"
                placeholder="Enter material name..."
                className="w-full border rounded-lg px-3 py-2"
                value={searchParams.material_name}
                onChange={(e) => setSearchParams(prev => ({ ...prev, material_name: e.target.value }))}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Category</label>
              <select
                className="w-full border rounded-lg px-3 py-2"
                value={searchParams.category}
                onChange={(e) => setSearchParams(prev => ({ ...prev, category: e.target.value }))}
              >
                <option value="">All Categories</option>
                {categories.map(cat => (
                  <option key={cat.category_code} value={cat.category_code}>
                    {cat.category_name}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Material Type</label>
              <select
                className="w-full border rounded-lg px-3 py-2"
                value={searchParams.material_type}
                onChange={(e) => setSearchParams(prev => ({ ...prev, material_type: e.target.value }))}
              >
                <option value="">All Types</option>
                {materialTypes.map(type => (
                  <option key={type.material_type_code} value={type.material_type_code}>
                    {type.material_type_code} - {type.material_type_name}
                  </option>
                ))}
              </select>
            </div>
            <div className="flex items-end">
              <button
                onClick={searchMaterials}
                disabled={loading}
                className="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50"
              >
                {loading ? 'Searching...' : 'Search Materials'}
              </button>
            </div>
          </div>
        </div>

        {/* Materials Table */}
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Code</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Category</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">UOM</th>
                <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Actions</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {materials.map((material, index) => (
                <tr key={index} className="hover:bg-gray-50">
                  <td className="px-4 py-4 text-sm font-medium text-gray-900">{material.material_code}</td>
                  <td className="px-4 py-4 text-sm text-gray-900">{material.material_name}</td>
                  <td className="px-4 py-4 text-sm text-gray-500">{material.category}</td>
                  <td className="px-4 py-4 text-sm text-gray-500">{material.material_type}</td>
                  <td className="px-4 py-4 text-sm text-gray-500">{material.base_uom}</td>
                  <td className="px-4 py-4 text-center">
                    <button
                      onClick={() => viewMaterial(material)}
                      className="bg-blue-100 text-blue-700 px-3 py-1 rounded text-sm hover:bg-blue-200"
                    >
                      View Details
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          
          {materials.length === 0 && !loading && (
            <div className="text-center py-12 bg-blue-50 rounded-lg border-2 border-dashed border-blue-200">
              <Icons.Search className="w-12 h-12 text-blue-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-blue-900 mb-2">Material Display</h3>
              <p className="text-blue-600 mb-4">Enter search criteria and click "Search Materials" to display materials.</p>
              <p className="text-sm text-blue-500">Use filters to narrow down results by name, category, or type.</p>
            </div>
          )}
        </div>

        {/* Material Detail Modal */}
        {selectedMaterial && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg p-6 max-w-4xl w-full mx-4 max-h-[80vh] overflow-y-auto">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-semibold">Material Details - {selectedMaterial.material_code}</h3>
                <button
                  onClick={() => setSelectedMaterial(null)}
                  className="text-gray-500 hover:text-gray-700"
                >
                  ✕
                </button>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">Material Code</label>
                  <p className="mt-1 text-sm text-gray-900 font-mono">{selectedMaterial.material_code}</p>
                </div>
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-gray-700">Material Name</label>
                  <p className="mt-1 text-sm text-gray-900">{selectedMaterial.material_name}</p>
                </div>
                <div className="md:col-span-3">
                  <label className="block text-sm font-medium text-gray-700">Description</label>
                  <p className="mt-1 text-sm text-gray-900">{selectedMaterial.description || 'No description available'}</p>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Category</label>
                  <p className="mt-1 text-sm text-gray-900">{selectedMaterial.category}</p>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Material Type</label>
                  <p className="mt-1 text-sm text-gray-900">{selectedMaterial.material_type}</p>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Base UOM</label>
                  <p className="mt-1 text-sm text-gray-900">{selectedMaterial.base_uom}</p>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Material Group</label>
                  <p className="mt-1 text-sm text-gray-900">{selectedMaterial.material_group || 'Not assigned'}</p>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Weight Unit</label>
                  <p className="mt-1 text-sm text-gray-900">{selectedMaterial.weight_unit || 'Not specified'}</p>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Volume Unit</label>
                  <p className="mt-1 text-sm text-gray-900">{selectedMaterial.volume_unit || 'Not specified'}</p>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Gross Weight</label>
                  <p className="mt-1 text-sm text-gray-900">{selectedMaterial.gross_weight || 0}</p>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Net Weight</label>
                  <p className="mt-1 text-sm text-gray-900">{selectedMaterial.net_weight || 0}</p>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700">Status</label>
                  <p className="mt-1 text-sm text-gray-900">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                      selectedMaterial.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                    }`}>
                      {selectedMaterial.is_active ? 'Active' : 'Inactive'}
                    </span>
                  </p>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}