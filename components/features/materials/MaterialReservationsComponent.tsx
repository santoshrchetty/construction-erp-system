import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'

// Material Reservations Component - Industry Grade CRUD Operations
export function MaterialReservations() {
  const [activeTab, setActiveTab] = useState('create')
  const [reservations, setReservations] = useState([])
  const [materials, setMaterials] = useState([])
  const [projects, setProjects] = useState([])
  const [companies, setCompanies] = useState([])
  const [plants, setPlants] = useState([])
  const [storageLocations, setStorageLocations] = useState([])
  const [loading, setLoading] = useState(false)
  const [saving, setSaving] = useState(false)
  const [selectedReservation, setSelectedReservation] = useState(null)
  const [showReservationModal, setShowReservationModal] = useState(false)

  // Form state for creating/editing reservations
  const [formData, setFormData] = useState({
    reservation_number: '',
    material_code: '',
    project_code: '',
    company_code: '',
    plant_code: '',
    storage_location: '',
    reserved_quantity: 0,
    required_date: '',
    priority: 'MEDIUM',
    purpose: '',
    cost_center: '',
    wbs_element: '',
    notes: ''
  })

  // Search and filter state
  const [searchFilters, setSearchFilters] = useState({
    reservation_number: '',
    material_code: '',
    project_code: '',
    status: '',
    date_from: '',
    date_to: ''
  })

  const priorities = [
    { code: 'LOW', name: 'Low Priority', color: 'bg-gray-100 text-gray-800' },
    { code: 'MEDIUM', name: 'Medium Priority', color: 'bg-yellow-100 text-yellow-800' },
    { code: 'HIGH', name: 'High Priority', color: 'bg-orange-100 text-orange-800' },
    { code: 'URGENT', name: 'Urgent', color: 'bg-red-100 text-red-800' }
  ]

  const statuses = [
    { code: 'OPEN', name: 'Open', color: 'bg-blue-100 text-blue-800' },
    { code: 'PARTIAL', name: 'Partially Fulfilled', color: 'bg-yellow-100 text-yellow-800' },
    { code: 'FULFILLED', name: 'Fulfilled', color: 'bg-green-100 text-green-800' },
    { code: 'CANCELLED', name: 'Cancelled', color: 'bg-red-100 text-red-800' }
  ]

  useEffect(() => {
    loadMasterData()
    if (activeTab === 'list') {
      loadReservations()
    }
  }, [activeTab])

  useEffect(() => {
    if (formData.company_code) {
      loadPlants(formData.company_code)
    } else {
      setPlants([])
      setStorageLocations([])
    }
  }, [formData.company_code])

  useEffect(() => {
    if (formData.plant_code) {
      loadStorageLocations(formData.plant_code)
    } else {
      setStorageLocations([])
    }
  }, [formData.plant_code])

  const loadMasterData = async () => {
    try {
      const [materialsRes, projectsRes, companiesRes] = await Promise.all([
        fetch('/api/materials/master-data?type=materials'),
        fetch('/api/projects/master-data'),
        fetch('/api/sap-config?type=companies')
      ])

      const [materialsData, projectsData, companiesData] = await Promise.all([
        materialsRes.json(),
        projectsRes.json(),
        companiesRes.json()
      ])

      if (materialsData.success) setMaterials(materialsData.data || [])
      if (projectsData.success) setProjects(projectsData.data || [])
      if (companiesData.success) setCompanies(companiesData.data || [])
    } catch (error) {
      console.error('Failed to load master data:', error)
    }
  }

  const loadPlants = async (companyCode) => {
    try {
      const response = await fetch(`/api/sap-config?type=plants&company=${companyCode}`)
      const data = await response.json()
      if (data.success) {
        setPlants(data.data || [])
      }
    } catch (error) {
      console.error('Failed to load plants:', error)
    }
  }

  const loadStorageLocations = async (plantCode) => {
    try {
      const response = await fetch(`/api/sap-config?type=storage-locations&plant=${plantCode}`)
      const data = await response.json()
      if (data.success) {
        setStorageLocations(data.data || [])
      }
    } catch (error) {
      console.error('Failed to load storage locations:', error)
    }
  }

  const loadReservations = async () => {
    setLoading(true)
    try {
      const params = new URLSearchParams({
        category: 'materials',
        action: 'material-reservations',
        ...searchFilters
      })
      
      const response = await fetch(`/api/tiles?${params.toString()}`)
      const data = await response.json()
      
      if (data.success) {
        setReservations(data.data.reservations || [])
      } else {
        alert('Failed to load reservations: ' + data.error)
      }
    } catch (error) {
      alert('Error loading reservations: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const generateReservationNumber = () => {
    const timestamp = Date.now().toString().slice(-6)
    const random = Math.floor(Math.random() * 100).toString().padStart(2, '0')
    return `RES-${timestamp}-${random}`
  }

  const handleCreateReservation = async (e) => {
    e.preventDefault()
    setSaving(true)
    
    try {
      const reservationData = {
        ...formData,
        reservation_number: formData.reservation_number || generateReservationNumber(),
        status: 'OPEN',
        created_date: new Date().toISOString().split('T')[0]
      }

      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          category: 'materials',
          action: 'create-reservation',
          payload: reservationData
        })
      })

      const data = await response.json()
      if (data.success) {
        alert(`Reservation ${reservationData.reservation_number} created successfully!`)
        clearForm()
        setActiveTab('list')
      } else {
        alert('Error creating reservation: ' + data.error)
      }
    } catch (error) {
      alert('Error: ' + error.message)
    } finally {
      setSaving(false)
    }
  }

  const handleUpdateReservation = async () => {
    if (!selectedReservation) return
    setSaving(true)
    
    try {
      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          category: 'materials',
          action: 'update-reservation',
          payload: {
            reservation_id: selectedReservation.id,
            ...formData
          }
        })
      })

      const data = await response.json()
      if (data.success) {
        alert('Reservation updated successfully!')
        setShowReservationModal(false)
        setSelectedReservation(null)
        loadReservations()
      } else {
        alert('Error updating reservation: ' + data.error)
      }
    } catch (error) {
      alert('Error: ' + error.message)
    } finally {
      setSaving(false)
    }
  }

  const handleCancelReservation = async (reservationId) => {
    if (!confirm('Are you sure you want to cancel this reservation?')) return
    
    try {
      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          category: 'materials',
          action: 'cancel-reservation',
          payload: { reservation_id: reservationId }
        })
      })

      const data = await response.json()
      if (data.success) {
        alert('Reservation cancelled successfully!')
        loadReservations()
      } else {
        alert('Error cancelling reservation: ' + data.error)
      }
    } catch (error) {
      alert('Error: ' + error.message)
    }
  }

  const editReservation = (reservation) => {
    setSelectedReservation(reservation)
    setFormData({
      reservation_number: reservation.reservation_number,
      material_code: reservation.material_code,
      project_code: reservation.project_code,
      company_code: reservation.company_code,
      plant_code: reservation.plant_code,
      storage_location: reservation.storage_location,
      reserved_quantity: reservation.reserved_quantity,
      required_date: reservation.required_date,
      priority: reservation.priority,
      purpose: reservation.purpose,
      cost_center: reservation.cost_center,
      wbs_element: reservation.wbs_element,
      notes: reservation.notes
    })
    setShowReservationModal(true)
  }

  const clearForm = () => {
    setFormData({
      reservation_number: '',
      material_code: '',
      project_code: '',
      company_code: '',
      plant_code: '',
      storage_location: '',
      reserved_quantity: 0,
      required_date: '',
      priority: 'MEDIUM',
      purpose: '',
      cost_center: '',
      wbs_element: '',
      notes: ''
    })
    setSelectedReservation(null)
  }

  const getStatusColor = (status) => {
    const statusObj = statuses.find(s => s.code === status)
    return statusObj ? statusObj.color : 'bg-gray-100 text-gray-800'
  }

  const getPriorityColor = (priority) => {
    const priorityObj = priorities.find(p => p.code === priority)
    return priorityObj ? priorityObj.color : 'bg-gray-100 text-gray-800'
  }

  return (
    <div className="p-6">
      <div className="bg-white rounded-lg shadow">
        {/* Header */}
        <div className="border-b border-gray-200 p-6">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-xl font-semibold text-gray-900">Material Reservations</h2>
              <p className="text-sm text-gray-600 mt-1">Reserve materials for projects and track fulfillment</p>
            </div>
            <div className="flex items-center space-x-2">
              <Icons.Bookmark className="w-5 h-5 text-blue-600" />
              <span className="text-sm text-gray-500">ERP Standard Reservations</span>
            </div>
          </div>
        </div>

        {/* Tab Navigation */}
        <div className="border-b border-gray-200">
          <nav className="flex space-x-8 px-6">
            <button
              onClick={() => setActiveTab('create')}
              className={`py-4 px-1 border-b-2 font-medium text-sm ${
                activeTab === 'create'
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              <Icons.Plus className="w-4 h-4 inline mr-2" />
              Create Reservation
            </button>
            <button
              onClick={() => setActiveTab('list')}
              className={`py-4 px-1 border-b-2 font-medium text-sm ${
                activeTab === 'list'
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              <Icons.List className="w-4 h-4 inline mr-2" />
              Manage Reservations
            </button>
            <button
              onClick={() => setActiveTab('reports')}
              className={`py-4 px-1 border-b-2 font-medium text-sm ${
                activeTab === 'reports'
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              <Icons.BarChart3 className="w-4 h-4 inline mr-2" />
              Reports & Analytics
            </button>
          </nav>
        </div>

        {/* Tab Content */}
        <div className="p-6">
          {/* Create Reservation Tab */}
          {activeTab === 'create' && (
            <form onSubmit={handleCreateReservation} className="space-y-6">
              {/* Header Information */}
              <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                <div className="flex items-center">
                  <Icons.Info className="w-5 h-5 text-blue-600 mr-2" />
                  <div>
                    <p className="text-sm text-blue-600">Create material reservations for projects to ensure material availability and proper planning.</p>
                  </div>
                </div>
              </div>

              {/* Basic Information */}
              <div className="border-b pb-6">
                <h3 className="text-lg font-medium text-gray-900 mb-4">Basic Information</h3>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">Reservation Number</label>
                    <input
                      type="text"
                      className="w-full border rounded-lg px-3 py-2 bg-gray-50"
                      value={formData.reservation_number}
                      onChange={(e) => setFormData(prev => ({ ...prev, reservation_number: e.target.value }))}
                      placeholder="Auto-generated if empty"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2">Required Date *</label>
                    <input
                      type="date"
                      required
                      className="w-full border rounded-lg px-3 py-2"
                      value={formData.required_date}
                      onChange={(e) => setFormData(prev => ({ ...prev, required_date: e.target.value }))}
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2">Priority *</label>
                    <select
                      required
                      className="w-full border rounded-lg px-3 py-2"
                      value={formData.priority}
                      onChange={(e) => setFormData(prev => ({ ...prev, priority: e.target.value }))}
                    >
                      {priorities.map(priority => (
                        <option key={priority.code} value={priority.code}>
                          {priority.name}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
              </div>

              {/* Material and Quantity */}
              <div className="border-b pb-6">
                <h3 className="text-lg font-medium text-gray-900 mb-4">Material Details</h3>
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
                    <label className="block text-sm font-medium mb-2">Reserved Quantity *</label>
                    <input
                      type="number"
                      required
                      min="0"
                      step="0.001"
                      className="w-full border rounded-lg px-3 py-2"
                      value={formData.reserved_quantity}
                      onChange={(e) => setFormData(prev => ({ ...prev, reserved_quantity: parseFloat(e.target.value) || 0 }))}
                    />
                  </div>
                </div>
              </div>

              {/* Organizational Assignment */}
              <div className="border-b pb-6">
                <h3 className="text-lg font-medium text-gray-900 mb-4">Organizational Assignment</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">Company *</label>
                    <select
                      required
                      className="w-full border rounded-lg px-3 py-2"
                      value={formData.company_code}
                      onChange={(e) => setFormData(prev => ({ ...prev, company_code: e.target.value, plant_code: '', storage_location: '' }))}
                    >
                      <option value="">Select Company</option>
                      {companies.map(company => (
                        <option key={company.company_code} value={company.company_code}>
                          {company.company_code} - {company.company_name}
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
                      onChange={(e) => setFormData(prev => ({ ...prev, plant_code: e.target.value, storage_location: '' }))}
                      disabled={!formData.company_code}
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
                    <label className="block text-sm font-medium mb-2">Storage Location</label>
                    <select
                      className="w-full border rounded-lg px-3 py-2"
                      value={formData.storage_location}
                      onChange={(e) => setFormData(prev => ({ ...prev, storage_location: e.target.value }))}
                      disabled={!formData.plant_code}
                    >
                      <option value="">Select Storage Location</option>
                      {storageLocations.map(sloc => (
                        <option key={sloc.sloc_code} value={sloc.sloc_code}>
                          {sloc.sloc_code} - {sloc.sloc_name}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2">Project</label>
                    <select
                      className="w-full border rounded-lg px-3 py-2"
                      value={formData.project_code}
                      onChange={(e) => setFormData(prev => ({ ...prev, project_code: e.target.value }))}
                    >
                      <option value="">Select Project</option>
                      {projects.map(project => (
                        <option key={project.project_code} value={project.project_code}>
                          {project.project_code} - {project.project_name}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
              </div>

              {/* Additional Information */}
              <div className="border-b pb-6">
                <h3 className="text-lg font-medium text-gray-900 mb-4">Additional Information</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">Cost Center</label>
                    <input
                      type="text"
                      className="w-full border rounded-lg px-3 py-2"
                      value={formData.cost_center}
                      onChange={(e) => setFormData(prev => ({ ...prev, cost_center: e.target.value }))}
                      placeholder="e.g., CC-CONST-001"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2">WBS Element</label>
                    <input
                      type="text"
                      className="w-full border rounded-lg px-3 py-2"
                      value={formData.wbs_element}
                      onChange={(e) => setFormData(prev => ({ ...prev, wbs_element: e.target.value }))}
                      placeholder="e.g., WBS-001.001"
                    />
                  </div>
                  <div className="md:col-span-2">
                    <label className="block text-sm font-medium mb-2">Purpose</label>
                    <input
                      type="text"
                      className="w-full border rounded-lg px-3 py-2"
                      value={formData.purpose}
                      onChange={(e) => setFormData(prev => ({ ...prev, purpose: e.target.value }))}
                      placeholder="Purpose of reservation..."
                    />
                  </div>
                  <div className="md:col-span-2">
                    <label className="block text-sm font-medium mb-2">Notes</label>
                    <textarea
                      className="w-full border rounded-lg px-3 py-2"
                      rows={3}
                      value={formData.notes}
                      onChange={(e) => setFormData(prev => ({ ...prev, notes: e.target.value }))}
                      placeholder="Additional notes or requirements..."
                    />
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex space-x-4">
                <button
                  type="submit"
                  disabled={saving}
                  className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50"
                >
                  {saving ? 'Creating...' : 'Create Reservation'}
                </button>
                <button
                  type="button"
                  onClick={clearForm}
                  className="bg-gray-500 text-white px-6 py-2 rounded-lg hover:bg-gray-600"
                >
                  Clear Form
                </button>
              </div>
            </form>
          )}

          {/* Manage Reservations Tab */}
          {activeTab === 'list' && (
            <div className="space-y-6">
              {/* Search and Filter */}
              <div className="bg-gray-50 rounded-lg p-4">
                <h3 className="text-md font-medium text-gray-900 mb-4">Search & Filter Reservations</h3>
                <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-6 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Reservation Number</label>
                    <input
                      type="text"
                      className="w-full border rounded px-3 py-2 text-sm"
                      value={searchFilters.reservation_number}
                      onChange={(e) => setSearchFilters(prev => ({ ...prev, reservation_number: e.target.value }))}
                      placeholder="RES-..."
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Material Code</label>
                    <input
                      type="text"
                      className="w-full border rounded px-3 py-2 text-sm"
                      value={searchFilters.material_code}
                      onChange={(e) => setSearchFilters(prev => ({ ...prev, material_code: e.target.value }))}
                      placeholder="Material..."
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Project</label>
                    <input
                      type="text"
                      className="w-full border rounded px-3 py-2 text-sm"
                      value={searchFilters.project_code}
                      onChange={(e) => setSearchFilters(prev => ({ ...prev, project_code: e.target.value }))}
                      placeholder="Project..."
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
                    <select
                      className="w-full border rounded px-3 py-2 text-sm"
                      value={searchFilters.status}
                      onChange={(e) => setSearchFilters(prev => ({ ...prev, status: e.target.value }))}
                    >
                      <option value="">All Status</option>
                      {statuses.map(status => (
                        <option key={status.code} value={status.code}>
                          {status.name}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Date From</label>
                    <input
                      type="date"
                      className="w-full border rounded px-3 py-2 text-sm"
                      value={searchFilters.date_from}
                      onChange={(e) => setSearchFilters(prev => ({ ...prev, date_from: e.target.value }))}
                    />
                  </div>
                  <div className="flex items-end">
                    <button
                      onClick={loadReservations}
                      disabled={loading}
                      className="w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700 disabled:opacity-50 text-sm"
                    >
                      {loading ? 'Loading...' : 'Search'}
                    </button>
                  </div>
                </div>
              </div>

              {/* Reservations Table */}
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Reservation #</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Material</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Quantity</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Required Date</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Priority</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                      <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {reservations.map((reservation, index) => (
                      <tr key={index} className="hover:bg-gray-50">
                        <td className="px-4 py-4 text-sm font-medium text-gray-900">{reservation.reservation_number}</td>
                        <td className="px-4 py-4 text-sm text-gray-900">
                          <div>
                            <div className="font-medium">{reservation.material_code}</div>
                            <div className="text-gray-500 text-xs">{reservation.material_name}</div>
                          </div>
                        </td>
                        <td className="px-4 py-4 text-sm text-gray-900">{reservation.reserved_quantity} {reservation.uom}</td>
                        <td className="px-4 py-4 text-sm text-gray-900">{reservation.required_date}</td>
                        <td className="px-4 py-4 text-sm">
                          <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getPriorityColor(reservation.priority)}`}>
                            {reservation.priority}
                          </span>
                        </td>
                        <td className="px-4 py-4 text-sm">
                          <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(reservation.status)}`}>
                            {reservation.status}
                          </span>
                        </td>
                        <td className="px-4 py-4 text-center">
                          <div className="flex justify-center space-x-2">
                            <button
                              onClick={() => editReservation(reservation)}
                              className="bg-blue-100 text-blue-700 px-2 py-1 rounded text-xs hover:bg-blue-200"
                              disabled={reservation.status === 'CANCELLED'}
                            >
                              Edit
                            </button>
                            <button
                              onClick={() => handleCancelReservation(reservation.id)}
                              className="bg-red-100 text-red-700 px-2 py-1 rounded text-xs hover:bg-red-200"
                              disabled={reservation.status === 'CANCELLED' || reservation.status === 'FULFILLED'}
                            >
                              Cancel
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
                
                {reservations.length === 0 && !loading && (
                  <div className="text-center py-12 bg-blue-50 rounded-lg border-2 border-dashed border-blue-200">
                    <Icons.Bookmark className="w-12 h-12 text-blue-400 mx-auto mb-4" />
                    <h3 className="text-lg font-medium text-blue-900 mb-2">No Reservations Found</h3>
                    <p className="text-blue-600 mb-4">No material reservations match your search criteria.</p>
                    <button
                      onClick={() => setActiveTab('create')}
                      className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
                    >
                      Create First Reservation
                    </button>
                  </div>
                )}
              </div>
            </div>
          )}

          {/* Reports Tab */}
          {activeTab === 'reports' && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                  <div className="flex items-center">
                    <Icons.FileText className="w-8 h-8 text-blue-600 mr-3" />
                    <div>
                      <p className="text-sm font-medium text-blue-900">Open Reservations</p>
                      <p className="text-2xl font-bold text-blue-600">
                        {reservations.filter(r => r.status === 'OPEN').length}
                      </p>
                    </div>
                  </div>
                </div>
                <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
                  <div className="flex items-center">
                    <Icons.Clock className="w-8 h-8 text-yellow-600 mr-3" />
                    <div>
                      <p className="text-sm font-medium text-yellow-900">Partial Fulfillment</p>
                      <p className="text-2xl font-bold text-yellow-600">
                        {reservations.filter(r => r.status === 'PARTIAL').length}
                      </p>
                    </div>
                  </div>
                </div>
                <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                  <div className="flex items-center">
                    <Icons.CheckCircle className="w-8 h-8 text-green-600 mr-3" />
                    <div>
                      <p className="text-sm font-medium text-green-900">Fulfilled</p>
                      <p className="text-2xl font-bold text-green-600">
                        {reservations.filter(r => r.status === 'FULFILLED').length}
                      </p>
                    </div>
                  </div>
                </div>
                <div className="bg-red-50 border border-red-200 rounded-lg p-4">
                  <div className="flex items-center">
                    <Icons.XCircle className="w-8 h-8 text-red-600 mr-3" />
                    <div>
                      <p className="text-sm font-medium text-red-900">Cancelled</p>
                      <p className="text-2xl font-bold text-red-600">
                        {reservations.filter(r => r.status === 'CANCELLED').length}
                      </p>
                    </div>
                  </div>
                </div>
              </div>
              
              <div className="text-center py-12 bg-gray-50 rounded-lg">
                <Icons.BarChart3 className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">Advanced Reports</h3>
                <p className="text-gray-600 mb-4">Detailed analytics and reporting features coming soon.</p>
                <p className="text-sm text-gray-500">Export capabilities, trend analysis, and performance metrics.</p>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Edit Reservation Modal */}
      {showReservationModal && selectedReservation && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 max-w-4xl w-full mx-4 max-h-[80vh] overflow-y-auto">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-semibold">Edit Reservation - {selectedReservation.reservation_number}</h3>
              <button
                onClick={() => {
                  setShowReservationModal(false)
                  setSelectedReservation(null)
                  clearForm()
                }}
                className="text-gray-500 hover:text-gray-700"
              >
                ✕
              </button>
            </div>
            
            <form onSubmit={(e) => { e.preventDefault(); handleUpdateReservation(); }} className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-2">Reserved Quantity *</label>
                  <input
                    type="number"
                    required
                    min="0"
                    step="0.001"
                    className="w-full border rounded-lg px-3 py-2"
                    value={formData.reserved_quantity}
                    onChange={(e) => setFormData(prev => ({ ...prev, reserved_quantity: parseFloat(e.target.value) || 0 }))}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-2">Required Date *</label>
                  <input
                    type="date"
                    required
                    className="w-full border rounded-lg px-3 py-2"
                    value={formData.required_date}
                    onChange={(e) => setFormData(prev => ({ ...prev, required_date: e.target.value }))}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-2">Priority *</label>
                  <select
                    required
                    className="w-full border rounded-lg px-3 py-2"
                    value={formData.priority}
                    onChange={(e) => setFormData(prev => ({ ...prev, priority: e.target.value }))}
                  >
                    {priorities.map(priority => (
                      <option key={priority.code} value={priority.code}>
                        {priority.name}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-2">Purpose</label>
                  <input
                    type="text"
                    className="w-full border rounded-lg px-3 py-2"
                    value={formData.purpose}
                    onChange={(e) => setFormData(prev => ({ ...prev, purpose: e.target.value }))}
                  />
                </div>
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium mb-2">Notes</label>
                  <textarea
                    className="w-full border rounded-lg px-3 py-2"
                    rows={3}
                    value={formData.notes}
                    onChange={(e) => setFormData(prev => ({ ...prev, notes: e.target.value }))}
                  />
                </div>
              </div>
              
              <div className="flex space-x-4 pt-4">
                <button
                  type="submit"
                  disabled={saving}
                  className="bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700 disabled:opacity-50"
                >
                  {saving ? 'Updating...' : 'Update Reservation'}
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setShowReservationModal(false)
                    setSelectedReservation(null)
                    clearForm()
                  }}
                  className="bg-gray-500 text-white px-6 py-2 rounded-lg hover:bg-gray-600"
                >
                  Cancel
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}