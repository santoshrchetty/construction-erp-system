import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'

// Extend Material to Plant Component
export function ExtendMaterialToPlant() {
  const [formData, setFormData] = useState({
    material_code: '',
    plant_code: '',
    procurement_type: 'E',
    mrp_type: 'PD',
    reorder_point: 0,
    safety_stock: 0,
    minimum_lot_size: 1,
    planned_delivery_time: 0
  })
  const [materials, setMaterials] = useState([])
  const [plants, setPlants] = useState([])
  const [loading, setLoading] = useState(false)
  const [extending, setExtending] = useState(false)

  const procurementTypes = [
    { code: 'E', name: 'External Procurement (Purchase)' },
    { code: 'F', name: 'In-house Production' },
    { code: 'X', name: 'Both External and In-house' }
  ]

  const mrpTypes = [
    { code: 'PD', name: 'MRP (Material Requirements Planning)' },
    { code: 'VV', name: 'Forecast-based Planning' },
    { code: 'ND', name: 'No Planning' }
  ]

  useEffect(() => {
    loadMaterials()
    loadPlants()
  }, [])

  const loadMaterials = async () => {
    try {
      const response = await fetch('/api/tiles?category=materials&action=material-master')
      const data = await response.json()
      if (data.success) {
        setMaterials(data.data.materials || [])
      }
    } catch (error) {
      console.error('Failed to load materials:', error)
    }
  }

  const loadPlants = async () => {
    try {
      const response = await fetch('/api/sap-config?object_type=plants')
      const data = await response.json()
      if (data.success) {
        setPlants(data.data || [])
      }
    } catch (error) {
      console.error('Failed to load plants:', error)
    }
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setExtending(true)
    try {
      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          category: 'materials',
          action: 'extend-to-plant',
          payload: formData
        })
      })
      const data = await response.json()
      if (data.success) {
        alert(`Material ${formData.material_code} successfully extended to plant ${formData.plant_code}!`)
        setFormData({
          material_code: '',
          plant_code: '',
          procurement_type: 'E',
          mrp_type: 'PD',
          reorder_point: 0,
          safety_stock: 0,
          minimum_lot_size: 1,
          planned_delivery_time: 0
        })
      } else {
        alert('Error: ' + data.error)
      }
    } catch (error) {
      alert('Error: ' + error.message)
    } finally {
      setExtending(false)
    }
  }

  return (
    <div className="p-6">
      <div className="bg-white rounded-lg shadow p-6">
        <div className="mb-4 p-4 bg-green-50 border border-green-200 rounded-lg">
          <div className="flex items-center">
            <Icons.GitBranch className="w-5 h-5 text-green-600 mr-2" />
            <div>
              <p className="text-sm text-green-600">Make a global material available in a specific plant with plant-specific parameters.</p>
            </div>
          </div>
        </div>
        
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium mb-2">Material *</label>
              <select
                required
                className="w-full border rounded-lg px-3 py-2"
                value={formData.material_code}
                onChange={(e) => setFormData(prev => ({ ...prev, material_code: e.target.value }))}
              >
                <option value="">Select Material</option>
                {materials.map(material => (
                  <option key={material.material_code} value={material.material_code}>
                    {material.material_code} - {material.material_name}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Plant *</label>
              <select
                required
                className="w-full border rounded-lg px-3 py-2"
                value={formData.plant_code}
                onChange={(e) => setFormData(prev => ({ ...prev, plant_code: e.target.value }))}
              >
                <option value="">Select Plant</option>
                {plants.map(plant => (
                  <option key={plant.plant_code} value={plant.plant_code}>
                    {plant.plant_code} - {plant.plant_name}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Procurement Type *</label>
              <select
                required
                className="w-full border rounded-lg px-3 py-2"
                value={formData.procurement_type}
                onChange={(e) => setFormData(prev => ({ ...prev, procurement_type: e.target.value }))}
              >
                {procurementTypes.map(type => (
                  <option key={type.code} value={type.code}>
                    {type.code} - {type.name}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">MRP Type *</label>
              <select
                required
                className="w-full border rounded-lg px-3 py-2"
                value={formData.mrp_type}
                onChange={(e) => setFormData(prev => ({ ...prev, mrp_type: e.target.value }))}
              >
                {mrpTypes.map(type => (
                  <option key={type.code} value={type.code}>
                    {type.code} - {type.name}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Reorder Point</label>
              <input
                type="number"
                min="0"
                step="0.001"
                className="w-full border rounded-lg px-3 py-2"
                value={formData.reorder_point}
                onChange={(e) => setFormData(prev => ({ ...prev, reorder_point: parseFloat(e.target.value) || 0 }))}
              />
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Safety Stock</label>
              <input
                type="number"
                min="0"
                step="0.001"
                className="w-full border rounded-lg px-3 py-2"
                value={formData.safety_stock}
                onChange={(e) => setFormData(prev => ({ ...prev, safety_stock: parseFloat(e.target.value) || 0 }))}
              />
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Minimum Lot Size</label>
              <input
                type="number"
                min="1"
                step="0.001"
                className="w-full border rounded-lg px-3 py-2"
                value={formData.minimum_lot_size}
                onChange={(e) => setFormData(prev => ({ ...prev, minimum_lot_size: parseFloat(e.target.value) || 1 }))}
              />
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Planned Delivery Time (days)</label>
              <input
                type="number"
                min="0"
                className="w-full border rounded-lg px-3 py-2"
                value={formData.planned_delivery_time}
                onChange={(e) => setFormData(prev => ({ ...prev, planned_delivery_time: parseInt(e.target.value) || 0 }))}
              />
            </div>
          </div>
          <div className="flex space-x-4 pt-4">
            <button
              type="submit"
              disabled={extending}
              className="bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700 disabled:opacity-50"
            >
              {extending ? 'Extending...' : 'Extend to Plant'}
            </button>
            <button
              type="button"
              onClick={() => setFormData({
                material_code: '',
                plant_code: '',
                procurement_type: 'E',
                mrp_type: 'PD',
                reorder_point: 0,
                safety_stock: 0,
                minimum_lot_size: 1,
                planned_delivery_time: 0
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

// Material Plant Parameters Component
export function MaterialPlantParameters() {
  const [searchData, setSearchData] = useState({
    material_code: '',
    plant_code: ''
  })
  const [plantData, setPlantData] = useState([])
  const [materials, setMaterials] = useState([])
  const [plants, setPlants] = useState([])
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    loadMaterials()
    loadPlants()
  }, [])

  const loadMaterials = async () => {
    try {
      const response = await fetch('/api/tiles?category=materials&action=material-master')
      const data = await response.json()
      if (data.success) {
        setMaterials(data.data.materials || [])
      }
    } catch (error) {
      console.error('Failed to load materials:', error)
    }
  }

  const loadPlants = async () => {
    try {
      const response = await fetch('/api/sap-config?object_type=plants')
      const data = await response.json()
      if (data.success) {
        setPlants(data.data || [])
      }
    } catch (error) {
      console.error('Failed to load plants:', error)
    }
  }

  const searchPlantData = async () => {
    if (!searchData.material_code) return
    setLoading(true)
    try {
      const params = new URLSearchParams({
        category: 'materials',
        action: 'plant-parameters',
        material_code: searchData.material_code
      })
      if (searchData.plant_code) {
        params.append('plant_code', searchData.plant_code)
      }
      
      const response = await fetch(`/api/tiles?${params.toString()}`)
      const data = await response.json()
      if (data.success) {
        setPlantData(data.data || [])
      } else {
        alert('Error: ' + data.error)
      }
    } catch (error) {
      alert('Search error: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="p-6">
      <div className="bg-white rounded-lg shadow p-6">
        <div className="mb-4 p-4 bg-purple-50 border border-purple-200 rounded-lg">
          <div className="flex items-center">
            <Icons.Settings className="w-5 h-5 text-purple-600 mr-2" />
            <div>
              <p className="text-sm text-purple-600">View and manage plant-specific material parameters and settings.</p>
            </div>
          </div>
        </div>
        
        {/* Search Section */}
        <div className="mb-6 p-4 bg-gray-50 rounded-lg">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium mb-2">Material *</label>
              <select
                required
                className="w-full border rounded-lg px-3 py-2"
                value={searchData.material_code}
                onChange={(e) => setSearchData(prev => ({ ...prev, material_code: e.target.value }))}
              >
                <option value="">Select Material</option>
                {materials.map(material => (
                  <option key={material.material_code} value={material.material_code}>
                    {material.material_code} - {material.material_name}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">Plant (Optional)</label>
              <select
                className="w-full border rounded-lg px-3 py-2"
                value={searchData.plant_code}
                onChange={(e) => setSearchData(prev => ({ ...prev, plant_code: e.target.value }))}
              >
                <option value="">All Plants</option>
                {plants.map(plant => (
                  <option key={plant.plant_code} value={plant.plant_code}>
                    {plant.plant_code} - {plant.plant_name}
                  </option>
                ))}
              </select>
            </div>
            <div className="flex items-end">
              <button
                onClick={searchPlantData}
                disabled={loading || !searchData.material_code}
                className="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50"
              >
                {loading ? 'Loading...' : 'Search'}
              </button>
            </div>
          </div>
        </div>

        {/* Results Table */}
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Plant</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Procurement</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">MRP Type</th>
                <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Reorder Point</th>
                <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Safety Stock</th>
                <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Delivery Time</th>
                <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Status</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {plantData.map((item, index) => (
                <tr key={index} className="hover:bg-gray-50">
                  <td className="px-4 py-4 text-sm font-medium text-gray-900">
                    {item.plant_code}
                  </td>
                  <td className="px-4 py-4 text-sm text-gray-900">{item.procurement_type}</td>
                  <td className="px-4 py-4 text-sm text-gray-900">{item.mrp_type}</td>
                  <td className="px-4 py-4 text-sm text-gray-900 text-right">{item.reorder_point}</td>
                  <td className="px-4 py-4 text-sm text-gray-900 text-right">{item.safety_stock}</td>
                  <td className="px-4 py-4 text-sm text-gray-900 text-right">{item.planned_delivery_time} days</td>
                  <td className="px-4 py-4 text-center">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                      item.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                    }`}>
                      {item.is_active ? 'Active' : 'Inactive'}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          
          {plantData.length === 0 && !loading && (
            <div className="text-center py-8 text-gray-500">
              No plant parameters found. Select a material and click Search.
            </div>
          )}
        </div>
      </div>
    </div>
  )
}