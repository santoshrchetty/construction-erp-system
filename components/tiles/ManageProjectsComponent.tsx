import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'

export function ManageProjectsComponent() {
  const [activeTab, setActiveTab] = useState('list')
  const [projects, setProjects] = useState([])
  const [loading, setLoading] = useState(false)
  const [saving, setSaving] = useState(false)
  const [showForm, setShowForm] = useState(false)
  const [editingProject, setEditingProject] = useState(null)
  const [companies, setCompanies] = useState([])

  const [formData, setFormData] = useState({
    code: '',
    name: '',
    description: '',
    project_type: 'commercial',
    status: 'planning',
    start_date: '',
    planned_end_date: '',
    budget: 0,
    location: '',
    company_code: ''
  })

  useEffect(() => {
    loadCompanies()
    if (activeTab === 'list') loadProjects()
  }, [activeTab])

  const loadCompanies = async () => {
    try {
      const response = await fetch('/api/erp-config/companies')
      const data = await response.json()
      if (data.success) setCompanies(data.data)
    } catch (error) {
      console.error('Failed to load companies:', error)
    }
  }

  const loadProjects = async () => {
    setLoading(true)
    try {
      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          category: 'projects',
          action: 'list'
        })
      })
      const data = await response.json()
      if (data.success) setProjects(data.data || [])
    } catch (error) {
      console.error('Failed to load projects:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setSaving(true)
    try {
      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          category: 'projects',
          action: editingProject ? 'update' : 'create',
          payload: editingProject ? { ...formData, id: editingProject.id } : formData
        })
      })
      const data = await response.json()
      if (data.success) {
        alert(`Project ${editingProject ? 'updated' : 'created'} successfully!`)
        resetForm()
        setActiveTab('list')
      } else {
        alert('Error: ' + data.error)
      }
    } catch (error) {
      alert('Error: ' + error.message)
    } finally {
      setSaving(false)
    }
  }

  const deleteProject = async (id) => {
    if (!confirm('Delete this project?')) return
    
    try {
      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          category: 'projects',
          action: 'delete',
          payload: { id }
        })
      })
      const data = await response.json()
      if (data.success) {
        loadProjects()
      } else {
        alert('Error: ' + data.error)
      }
    } catch (error) {
      alert('Error: ' + error.message)
    }
  }

  const editProject = (project) => {
    setEditingProject(project)
    setFormData({
      code: project.code,
      name: project.name,
      description: project.description || '',
      project_type: project.project_type,
      status: project.status,
      start_date: project.start_date,
      planned_end_date: project.planned_end_date,
      budget: project.budget,
      location: project.location || '',
      company_code: project.company?.company_code || ''
    })
    setShowForm(true)
    setActiveTab('create')
  }

  const resetForm = () => {
    setShowForm(false)
    setEditingProject(null)
    setFormData({
      code: '',
      name: '',
      description: '',
      project_type: 'commercial',
      status: 'planning',
      start_date: '',
      planned_end_date: '',
      budget: 0,
      location: '',
      company_code: ''
    })
  }

  const getStatusColor = (status) => {
    const colors = {
      'planning': 'bg-gray-100 text-gray-800',
      'active': 'bg-green-100 text-green-800',
      'completed': 'bg-blue-100 text-blue-800',
      'on_hold': 'bg-yellow-100 text-yellow-800',
      'cancelled': 'bg-red-100 text-red-800'
    }
    return colors[status] || 'bg-gray-100 text-gray-800'
  }

  return (
    <div className="p-6">
      <div className="bg-white rounded-lg shadow">
        <div className="border-b border-gray-200">
          <nav className="flex space-x-8 px-6">
            <button
              onClick={() => setActiveTab('list')}
              className={`py-4 px-1 border-b-2 font-medium text-sm ${
                activeTab === 'list'
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
            >
              <Icons.List className="w-4 h-4 inline mr-2" />
              Projects List
            </button>
            <button
              onClick={() => { setActiveTab('create'); setShowForm(true); }}
              className={`py-4 px-1 border-b-2 font-medium text-sm ${
                activeTab === 'create'
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
            >
              <Icons.Plus className="w-4 h-4 inline mr-2" />
              {editingProject ? 'Edit Project' : 'Create Project'}
            </button>
          </nav>
        </div>

        <div className="p-6">
          {activeTab === 'list' && (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Project Code</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Company Code</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Budget</th>
                    <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Actions</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {projects.map((project) => (
                    <tr key={project.id} className="hover:bg-gray-50">
                      <td className="px-4 py-4 text-sm font-mono">{project.code}</td>
                      <td className="px-4 py-4 text-sm font-mono">{project.company?.company_code || '-'}</td>
                      <td className="px-4 py-4 text-sm font-medium">{project.name}</td>
                      <td className="px-4 py-4 text-sm capitalize">{project.project_type}</td>
                      <td className="px-4 py-4 text-sm">
                        <span className={`px-2 py-1 rounded text-xs ${getStatusColor(project.status)}`}>
                          {project.status.replace('_', ' ')}
                        </span>
                      </td>
                      <td className="px-4 py-4 text-sm">${project.budget?.toLocaleString()}</td>
                      <td className="px-4 py-4 text-center space-x-2">
                        <button
                          onClick={() => editProject(project)}
                          className="text-blue-600 hover:text-blue-800"
                        >
                          <Icons.Edit className="w-4 h-4 inline" />
                        </button>
                        <button
                          onClick={() => deleteProject(project.id)}
                          className="text-red-600 hover:text-red-800"
                        >
                          <Icons.Trash2 className="w-4 h-4 inline" />
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}

          {activeTab === 'create' && showForm && (
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Project Code *</label>
                  <input
                    type="text"
                    required
                    value={formData.code}
                    onChange={(e) => setFormData({...formData, code: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Company Code *</label>
                  <select
                    required
                    value={formData.company_code}
                    onChange={(e) => setFormData({...formData, company_code: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  >
                    <option value="">Select Company Code</option>
                    {companies.map((c) => (
                      <option key={c.id} value={c.company_code}>
                        {c.company_code} - {c.company_name}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Project Name *</label>
                <input
                  type="text"
                  required
                  value={formData.name}
                  onChange={(e) => setFormData({...formData, name: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Type</label>
                  <select
                    value={formData.project_type}
                    onChange={(e) => setFormData({...formData, project_type: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  >
                    <option value="residential">Residential</option>
                    <option value="commercial">Commercial</option>
                    <option value="infrastructure">Infrastructure</option>
                    <option value="industrial">Industrial</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Status</label>
                  <select
                    value={formData.status}
                    onChange={(e) => setFormData({...formData, status: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  >
                    <option value="planning">Planning</option>
                    <option value="active">Active</option>
                    <option value="on_hold">On Hold</option>
                    <option value="completed">Completed</option>
                    <option value="cancelled">Cancelled</option>
                  </select>
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Start Date *</label>
                  <input
                    type="date"
                    required
                    value={formData.start_date}
                    onChange={(e) => setFormData({...formData, start_date: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">End Date *</label>
                  <input
                    type="date"
                    required
                    value={formData.planned_end_date}
                    onChange={(e) => setFormData({...formData, planned_end_date: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Budget *</label>
                <input
                  type="number"
                  required
                  min="0"
                  step="0.01"
                  value={formData.budget}
                  onChange={(e) => setFormData({...formData, budget: parseFloat(e.target.value) || 0})}
                  className="w-full border rounded px-3 py-2"
                />
              </div>
              <div className="flex space-x-3">
                <button
                  type="submit"
                  disabled={saving}
                  className="bg-blue-600 text-white px-6 py-2 rounded hover:bg-blue-700 disabled:opacity-50"
                >
                  {saving ? 'Saving...' : editingProject ? 'Update' : 'Create'}
                </button>
                <button
                  type="button"
                  onClick={resetForm}
                  className="bg-gray-500 text-white px-6 py-2 rounded hover:bg-gray-600"
                >
                  Cancel
                </button>
              </div>
            </form>
          )}
        </div>
      </div>
    </div>
  )
}
