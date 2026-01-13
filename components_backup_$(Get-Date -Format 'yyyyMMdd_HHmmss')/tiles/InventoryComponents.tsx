import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'

// API service functions following 4-layer architecture
const getProjects = async () => {
  const response = await fetch('/api/projects?action=project-overview')
  return await response.json()
}

const getWBSTree = async (projectId: string) => {
  const response = await fetch(`/api/projects?action=wbs-management&project_id=${projectId}`)
  return await response.json()
}

// Project/WBS Selector Component
function ProjectWBSSelector({ onSelect, required = false, className = "" }) {
  const [projects, setProjects] = useState([])
  const [wbsNodes, setWbsNodes] = useState([])
  const [selectedProject, setSelectedProject] = useState('')
  const [selectedWBS, setSelectedWBS] = useState('')
  const [loading, setLoading] = useState(false)
  const [loadingProjects, setLoadingProjects] = useState(true)

  useEffect(() => {
    const fetchProjects = async () => {
      try {
        const result = await getProjects()
        if (result.success) {
          setProjects(result.data || [])
        }
      } catch (error) {
        console.error('Error loading projects:', error)
      } finally {
        setLoadingProjects(false)
      }
    }
    fetchProjects()
  }, [])

  const handleProjectChange = async (projectCode) => {
    setSelectedProject(projectCode)
    setSelectedWBS('')
    if (projectCode) {
      setLoading(true)
      try {
        // Find project ID from code
        const project = projects.find(p => p.code === projectCode)
        if (project) {
          const result = await getWBSTree(project.id)
          if (result.success) {
            setWbsNodes(result.data || [])
          }
        }
      } catch (error) {
        console.error('Error loading WBS:', error)
      } finally {
        setLoading(false)
      }
    } else {
      setWbsNodes([])
    }
    onSelect({ project_code: projectCode, wbs_element: '' })
  }

  const handleWBSChange = (wbsElement) => {
    setSelectedWBS(wbsElement)
    onSelect({ project_code: selectedProject, wbs_element: wbsElement })
  }

  return (
    <div className={`grid grid-cols-1 md:grid-cols-2 gap-4 ${className}`}>
      <div>
        <label className="block text-sm font-medium mb-2">
          Project Code {required && '*'}
        </label>
        <select
          className="w-full border rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500"
          value={selectedProject}
          onChange={(e) => handleProjectChange(e.target.value)}
          required={required}
          disabled={loadingProjects}
        >
          <option value="">{loadingProjects ? 'Loading projects...' : 'Select Project'}</option>
          {projects.map(project => (
            <option key={project.id} value={project.code}>
              {project.code} - {project.name}
            </option>
          ))}
        </select>
      </div>
      <div>
        <label className="block text-sm font-medium mb-2">
          WBS Element {required && '*'}
        </label>
        <select
          className="w-full border rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500"
          value={selectedWBS}
          onChange={(e) => handleWBSChange(e.target.value)}
          disabled={!selectedProject || loading}
          required={required}
        >
          <option value="">Select WBS Element</option>
          {wbsNodes.map(wbs => (
            <option key={wbs.id} value={wbs.code}>
              {wbs.code} - {wbs.name}
            </option>
          ))}
        </select>
        {loading && (
          <p className="text-xs text-gray-500 mt-1">Loading WBS elements...</p>
        )}
      </div>
    </div>
  )
}

// Account Assignment Selector
function AccountAssignmentSelector({ value, onChange, className = "" }) {
  return (
    <div className={className}>
      <label className="block text-sm font-medium mb-2">Account Assignment *</label>
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-2">
        {[
          { key: 'W', label: 'Warehouse', icon: Icons.Warehouse, color: 'blue' },
          { key: 'P', label: 'Project', icon: Icons.Building, color: 'green' },
          { key: 'C', label: 'Cost Center', icon: Icons.Target, color: 'orange' }
        ].map(option => (
          <button
            key={option.key}
            type="button"
            onClick={() => onChange(option.key)}
            className={`flex items-center justify-center p-3 rounded-lg border-2 transition-all ${
              value === option.key
                ? `border-${option.color}-500 bg-${option.color}-50 text-${option.color}-700`
                : 'border-gray-200 hover:border-gray-300 text-gray-600'
            }`}
          >
            <option.icon className="w-4 h-4 mr-2" />
            <span className="text-sm font-medium">{option.label}</span>
          </button>
        ))}
      </div>
    </div>
  )
}

// Goods Receipt Component
export function GoodsReceipt() {
  const [activeTab, setActiveTab] = useState('po-based')
  const [formData, setFormData] = useState({
    po_number: '',
    vendor_code: '',
    delivery_note: '',
    receipt_date: new Date().toISOString().split('T')[0],
    account_assignment: 'W',
    project_code: '',
    wbs_element: '',
    cost_center: '',
    items: []
  })
  const [loading, setLoading] = useState(false)

  const handleAccountAssignmentChange = (assignment) => {
    setFormData(prev => ({
      ...prev,
      account_assignment: assignment,
      project_code: '',
      wbs_element: '',
      cost_center: ''
    }))
  }

  const handleProjectWBSSelect = ({ project_code, wbs_element }) => {
    setFormData(prev => ({ ...prev, project_code, wbs_element }))
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm border-b px-4 py-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <span className={`px-2 py-1 rounded text-xs font-medium ${
              formData.account_assignment === 'P' 
                ? 'bg-green-100 text-green-800' 
                : formData.account_assignment === 'C'
                ? 'bg-orange-100 text-orange-800'
                : 'bg-blue-100 text-blue-800'
            }`}>
              {formData.account_assignment === 'P' ? 'Project Stock' : 
               formData.account_assignment === 'C' ? 'Cost Center' : 'Warehouse'}
            </span>
          </div>
        </div>
      </div>

      <div className="p-4">
        {/* Tab Navigation */}
        <div className="bg-white rounded-lg shadow-sm border mb-6">
          <div className="flex border-b overflow-x-auto">
            {[
              { key: 'po-based', label: 'PO Based', icon: Icons.FileText },
              { key: 'direct', label: 'Direct Receipt', icon: Icons.Package },
              { key: 'return', label: 'Return Delivery', icon: Icons.RotateCcw }
            ].map(tab => (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                className={`flex items-center px-4 py-3 text-sm font-medium whitespace-nowrap ${
                  activeTab === tab.key
                    ? 'border-b-2 border-blue-500 text-blue-600'
                    : 'text-gray-500 hover:text-gray-700'
                }`}
              >
                <tab.icon className="w-4 h-4 mr-2" />
                {tab.label}
              </button>
            ))}
          </div>

          <div className="p-4 md:p-6">
            {/* Account Assignment */}
            <AccountAssignmentSelector
              value={formData.account_assignment}
              onChange={handleAccountAssignmentChange}
              className="mb-6"
            />

            {/* Project/WBS Selection for Project Stock */}
            {formData.account_assignment === 'P' && (
              <div className="mb-6 p-4 bg-green-50 rounded-lg border border-green-200">
                <div className="flex items-center mb-3">
                  <Icons.Building className="w-5 h-5 text-green-600 mr-2" />
                  <h3 className="font-medium text-green-800">Project Assignment</h3>
                </div>
                <ProjectWBSSelector
                  onSelect={handleProjectWBSSelect}
                  required={true}
                />
              </div>
            )}

            {/* Cost Center for Cost Center Assignment */}
            {formData.account_assignment === 'C' && (
              <div className="mb-6 p-4 bg-orange-50 rounded-lg border border-orange-200">
                <div className="flex items-center mb-3">
                  <Icons.Target className="w-5 h-5 text-orange-600 mr-2" />
                  <h3 className="font-medium text-orange-800">Cost Center Assignment</h3>
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">Cost Center *</label>
                    <div className="flex">
                      <input
                        type="text"
                        className="flex-1 border rounded-l-lg px-3 py-2"
                        placeholder="Enter Cost Center"
                        value={formData.cost_center}
                        onChange={(e) => setFormData(prev => ({ ...prev, cost_center: e.target.value }))}
                      />
                      <button className="bg-orange-600 text-white px-4 py-2 rounded-r-lg hover:bg-orange-700">
                        <Icons.Search className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {activeTab === 'po-based' && (
              <div className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">Purchase Order *</label>
                    <div className="flex">
                      <input
                        type="text"
                        className="flex-1 border rounded-l-lg px-3 py-2"
                        placeholder="Enter PO Number"
                        value={formData.po_number}
                        onChange={(e) => setFormData(prev => ({ ...prev, po_number: e.target.value }))}
                      />
                      <button className="bg-blue-600 text-white px-4 py-2 rounded-r-lg hover:bg-blue-700">
                        <Icons.Search className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2">Delivery Note</label>
                    <input
                      type="text"
                      className="w-full border rounded-lg px-3 py-2"
                      placeholder="Vendor delivery note"
                      value={formData.delivery_note}
                      onChange={(e) => setFormData(prev => ({ ...prev, delivery_note: e.target.value }))}
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2">Receipt Date *</label>
                    <input
                      type="date"
                      className="w-full border rounded-lg px-3 py-2"
                      value={formData.receipt_date}
                      onChange={(e) => setFormData(prev => ({ ...prev, receipt_date: e.target.value }))}
                    />
                  </div>
                </div>

                <div className="bg-gray-50 rounded-lg p-4">
                  <h3 className="font-medium mb-4">PO Items</h3>
                  <div className="text-center text-gray-500 py-8">
                    <Icons.Package className="w-12 h-12 mx-auto mb-2 text-gray-400" />
                    <p>Enter PO number to load items</p>
                  </div>
                </div>

                <div className="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-4">
                  <button
                    disabled={loading}
                    className="bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700 disabled:opacity-50 flex items-center justify-center"
                  >
                    <Icons.Check className="w-4 h-4 mr-2" />
                    {loading ? 'Processing...' : 'Post Receipt'}
                  </button>
                  <button className="bg-gray-500 text-white px-6 py-2 rounded-lg hover:bg-gray-600 flex items-center justify-center">
                    <Icons.X className="w-4 h-4 mr-2" />
                    Clear
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

// Goods Issue Component
export function GoodsIssue() {
  const [activeTab, setActiveTab] = useState('project')
  const [formData, setFormData] = useState({
    account_assignment: 'P',
    project_code: '',
    wbs_element: '',
    cost_center: '',
    issue_date: new Date().toISOString().split('T')[0],
    items: []
  })

  const handleAccountAssignmentChange = (assignment) => {
    setFormData(prev => ({
      ...prev,
      account_assignment: assignment,
      project_code: '',
      wbs_element: '',
      cost_center: ''
    }))
    setActiveTab(assignment === 'P' ? 'project' : assignment === 'C' ? 'cost-center' : 'scrap')
  }

  const handleProjectWBSSelect = ({ project_code, wbs_element }) => {
    setFormData(prev => ({ ...prev, project_code, wbs_element }))
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm border-b px-4 py-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <span className={`px-2 py-1 rounded text-xs font-medium ${
              formData.account_assignment === 'P' 
                ? 'bg-green-100 text-green-800' 
                : formData.account_assignment === 'C'
                ? 'bg-orange-100 text-orange-800'
                : 'bg-red-100 text-red-800'
            }`}>
              {formData.account_assignment === 'P' ? 'Project Issue' : 
               formData.account_assignment === 'C' ? 'Cost Center' : 'Scrapping'}
            </span>
          </div>
        </div>
      </div>

      <div className="p-4">
        <div className="bg-white rounded-lg shadow-sm border mb-6">
          <div className="flex border-b overflow-x-auto">
            {[
              { key: 'project', label: 'Project Issue', icon: Icons.Building, assignment: 'P' },
              { key: 'cost-center', label: 'Cost Center', icon: Icons.Target, assignment: 'C' },
              { key: 'scrap', label: 'Scrapping', icon: Icons.Trash2, assignment: 'S' }
            ].map(tab => (
              <button
                key={tab.key}
                onClick={() => {
                  setActiveTab(tab.key)
                  handleAccountAssignmentChange(tab.assignment)
                }}
                className={`flex items-center px-4 py-3 text-sm font-medium whitespace-nowrap ${
                  activeTab === tab.key
                    ? 'border-b-2 border-blue-500 text-blue-600'
                    : 'text-gray-500 hover:text-gray-700'
                }`}
              >
                <tab.icon className="w-4 h-4 mr-2" />
                {tab.label}
              </button>
            ))}
          </div>

          <div className="p-4 md:p-6">
            {/* Project Assignment */}
            {formData.account_assignment === 'P' && (
              <div className="mb-6 p-4 bg-green-50 rounded-lg border border-green-200">
                <div className="flex items-center mb-3">
                  <Icons.Building className="w-5 h-5 text-green-600 mr-2" />
                  <h3 className="font-medium text-green-800">Project Consumption</h3>
                </div>
                <ProjectWBSSelector
                  onSelect={handleProjectWBSSelect}
                  required={true}
                />
                <div className="mt-4 p-3 bg-green-100 rounded border border-green-300">
                  <div className="flex items-center text-sm text-green-700">
                    <Icons.Info className="w-4 h-4 mr-2" />
                    <span>Materials will be consumed from project stock and charged to WBS element</span>
                  </div>
                </div>
              </div>
            )}

            {/* Cost Center Assignment */}
            {formData.account_assignment === 'C' && (
              <div className="mb-6 p-4 bg-orange-50 rounded-lg border border-orange-200">
                <div className="flex items-center mb-3">
                  <Icons.Target className="w-5 h-5 text-orange-600 mr-2" />
                  <h3 className="font-medium text-orange-800">Cost Center Issue</h3>
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">Cost Center *</label>
                    <div className="flex">
                      <input
                        type="text"
                        className="flex-1 border rounded-l-lg px-3 py-2"
                        placeholder="Enter Cost Center"
                        value={formData.cost_center}
                        onChange={(e) => setFormData(prev => ({ ...prev, cost_center: e.target.value }))}
                      />
                      <button className="bg-orange-600 text-white px-4 py-2 rounded-r-lg hover:bg-orange-700">
                        <Icons.Search className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* Scrapping */}
            {formData.account_assignment === 'S' && (
              <div className="mb-6 p-4 bg-red-50 rounded-lg border border-red-200">
                <div className="flex items-center mb-3">
                  <Icons.AlertTriangle className="w-5 h-5 text-red-600 mr-2" />
                  <h3 className="font-medium text-red-800">Material Scrapping</h3>
                </div>
                <div className="p-3 bg-red-100 rounded border border-red-300">
                  <div className="flex items-center text-sm text-red-700">
                    <Icons.AlertTriangle className="w-4 h-4 mr-2" />
                    <span>Materials will be removed from stock without cost assignment</span>
                  </div>
                </div>
              </div>
            )}

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
              <div>
                <label className="block text-sm font-medium mb-2">Issue Date *</label>
                <input
                  type="date"
                  className="w-full border rounded-lg px-3 py-2"
                  value={formData.issue_date}
                  onChange={(e) => setFormData(prev => ({ ...prev, issue_date: e.target.value }))}
                />
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 mb-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="font-medium">Materials to Issue</h3>
                <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center">
                  <Icons.Plus className="w-4 h-4 mr-2" />
                  Add Material
                </button>
              </div>
              <div className="text-center text-gray-500 py-8">
                <Icons.Package className="w-12 h-12 mx-auto mb-2 text-gray-400" />
                <p>No materials added yet</p>
              </div>
            </div>

            <div className="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-4">
              <button className="bg-red-600 text-white px-6 py-2 rounded-lg hover:bg-red-700 flex items-center justify-center">
                <Icons.ArrowDown className="w-4 h-4 mr-2" />
                Post Issue
              </button>
              <button className="bg-gray-500 text-white px-6 py-2 rounded-lg hover:bg-gray-600 flex items-center justify-center">
                <Icons.X className="w-4 h-4 mr-2" />
                Clear
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

// Goods Transfer Component
export function GoodsTransfer() {
  const [transferType, setTransferType] = useState('storage-location')
  const [formData, setFormData] = useState({
    from_plant: '',
    to_plant: '',
    from_storage: '',
    to_storage: '',
    transfer_date: new Date().toISOString().split('T')[0],
    items: []
  })

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm border-b px-4 py-3">
      </div>

      <div className="p-4">
        <div className="bg-white rounded-lg shadow-sm border mb-6">
          <div className="flex border-b overflow-x-auto">
            {[
              { key: 'storage-location', label: 'Storage Transfer', icon: Icons.ArrowRightLeft },
              { key: 'plant', label: 'Plant Transfer', icon: Icons.Building2 },
              { key: 'project', label: 'Project Transfer', icon: Icons.FolderOpen }
            ].map(tab => (
              <button
                key={tab.key}
                onClick={() => setTransferType(tab.key)}
                className={`flex items-center px-4 py-3 text-sm font-medium whitespace-nowrap ${
                  transferType === tab.key
                    ? 'border-b-2 border-blue-500 text-blue-600'
                    : 'text-gray-500 hover:text-gray-700'
                }`}
              >
                <tab.icon className="w-4 h-4 mr-2" />
                {tab.label}
              </button>
            ))}
          </div>

          <div className="p-6">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-6">
              {transferType === 'plant' && (
                <>
                  <div>
                    <label className="block text-sm font-medium mb-2">From Plant *</label>
                    <select className="w-full border rounded-lg px-3 py-2">
                      <option value="">Select Plant</option>
                      <option value="P001">P001 - Main Plant</option>
                      <option value="P002">P002 - Berlin Plant</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2">To Plant *</label>
                    <select className="w-full border rounded-lg px-3 py-2">
                      <option value="">Select Plant</option>
                      <option value="P001">P001 - Main Plant</option>
                      <option value="P002">P002 - Berlin Plant</option>
                    </select>
                  </div>
                </>
              )}
              <div>
                <label className="block text-sm font-medium mb-2">From Storage *</label>
                <select className="w-full border rounded-lg px-3 py-2">
                  <option value="">Select Storage</option>
                  <option value="0001">0001 - Main Warehouse</option>
                  <option value="0002">0002 - Raw Materials</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">To Storage *</label>
                <select className="w-full border rounded-lg px-3 py-2">
                  <option value="">Select Storage</option>
                  <option value="0001">0001 - Main Warehouse</option>
                  <option value="0002">0002 - Raw Materials</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Transfer Date *</label>
                <input
                  type="date"
                  className="w-full border rounded-lg px-3 py-2"
                  value={formData.transfer_date}
                />
              </div>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 mb-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="font-medium">Materials to Transfer</h3>
                <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center">
                  <Icons.Plus className="w-4 h-4 mr-2" />
                  Add Material
                </button>
              </div>
              <div className="text-center text-gray-500 py-8">
                <Icons.ArrowRightLeft className="w-12 h-12 mx-auto mb-2 text-gray-400" />
                <p>No materials added for transfer</p>
              </div>
            </div>

            <div className="flex space-x-4">
              <button className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700">
                Post Transfer
              </button>
              <button className="bg-gray-500 text-white px-6 py-2 rounded-lg hover:bg-gray-600">
                Clear
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

// Physical Inventory Component
export function PhysicalInventory() {
  const [activeTab, setActiveTab] = useState('count')
  const [countData, setCountData] = useState({
    plant_code: '',
    storage_location: '',
    count_date: new Date().toISOString().split('T')[0],
    counter_name: '',
    items: []
  })

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm border-b px-4 py-3">
      </div>

      <div className="p-4">
        <div className="bg-white rounded-lg shadow-sm border mb-6">
          <div className="flex border-b overflow-x-auto">
            {[
              { key: 'count', label: 'Stock Count', icon: Icons.ClipboardCheck },
              { key: 'variance', label: 'Variance Analysis', icon: Icons.TrendingUp },
              { key: 'adjustment', label: 'Adjustments', icon: Icons.Settings }
            ].map(tab => (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                className={`flex items-center px-4 py-3 text-sm font-medium whitespace-nowrap ${
                  activeTab === tab.key
                    ? 'border-b-2 border-blue-500 text-blue-600'
                    : 'text-gray-500 hover:text-gray-700'
                }`}
              >
                <tab.icon className="w-4 h-4 mr-2" />
                {tab.label}
              </button>
            ))}
          </div>

          <div className="p-6">
            {activeTab === 'count' && (
              <div className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-2">Plant *</label>
                    <select className="w-full border rounded-lg px-3 py-2">
                      <option value="">Select Plant</option>
                      <option value="P001">P001 - Main Plant</option>
                      <option value="P002">P002 - Berlin Plant</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2">Storage Location *</label>
                    <select className="w-full border rounded-lg px-3 py-2">
                      <option value="">Select Storage</option>
                      <option value="0001">0001 - Main Warehouse</option>
                      <option value="0002">0002 - Raw Materials</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2">Count Date *</label>
                    <input
                      type="date"
                      className="w-full border rounded-lg px-3 py-2"
                      value={countData.count_date}
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2">Counter Name *</label>
                    <input
                      type="text"
                      className="w-full border rounded-lg px-3 py-2"
                      placeholder="Enter counter name"
                    />
                  </div>
                </div>

                <div className="bg-blue-50 rounded-lg p-4">
                  <div className="flex items-center justify-between mb-4">
                    <h3 className="font-medium text-blue-800">Stock Count Sheet</h3>
                    <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center">
                      <Icons.Download className="w-4 h-4 mr-2" />
                      Generate Count Sheet
                    </button>
                  </div>
                  <p className="text-sm text-blue-700">
                    Generate count sheets for selected storage location to perform physical counting
                  </p>
                </div>

                <div className="flex space-x-4">
                  <button className="bg-green-600 text-white px-6 py-2 rounded-lg hover:bg-green-700">
                    Start Count
                  </button>
                  <button className="bg-gray-500 text-white px-6 py-2 rounded-lg hover:bg-gray-600">
                    Clear
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

// Inventory Adjustments Component
export function InventoryAdjustments() {
  const [adjustmentType, setAdjustmentType] = useState('quantity')
  const [formData, setFormData] = useState({
    plant_code: '',
    storage_location: '',
    adjustment_date: new Date().toISOString().split('T')[0],
    reason_code: '',
    items: []
  })

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm border-b px-4 py-3">
      </div>

      <div className="p-4">
        <div className="bg-white rounded-lg shadow-sm border mb-6">
          <div className="flex border-b overflow-x-auto">
            {[
              { key: 'quantity', label: 'Quantity Adjustment', icon: Icons.Hash },
              { key: 'value', label: 'Value Adjustment', icon: Icons.DollarSign },
              { key: 'revaluation', label: 'Revaluation', icon: Icons.TrendingUp }
            ].map(tab => (
              <button
                key={tab.key}
                onClick={() => setAdjustmentType(tab.key)}
                className={`flex items-center px-4 py-3 text-sm font-medium whitespace-nowrap ${
                  adjustmentType === tab.key
                    ? 'border-b-2 border-blue-500 text-blue-600'
                    : 'text-gray-500 hover:text-gray-700'
                }`}
              >
                <tab.icon className="w-4 h-4 mr-2" />
                {tab.label}
              </button>
            ))}
          </div>

          <div className="p-6">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
              <div>
                <label className="block text-sm font-medium mb-2">Plant *</label>
                <select className="w-full border rounded-lg px-3 py-2">
                  <option value="">Select Plant</option>
                  <option value="P001">P001 - Main Plant</option>
                  <option value="P002">P002 - Berlin Plant</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Storage Location</label>
                <select className="w-full border rounded-lg px-3 py-2">
                  <option value="">Select Storage</option>
                  <option value="0001">0001 - Main Warehouse</option>
                  <option value="0002">0002 - Raw Materials</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Adjustment Date *</label>
                <input
                  type="date"
                  className="w-full border rounded-lg px-3 py-2"
                  value={formData.adjustment_date}
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Reason Code *</label>
                <select className="w-full border rounded-lg px-3 py-2">
                  <option value="">Select Reason</option>
                  <option value="DAMAGE">Damage</option>
                  <option value="LOSS">Loss</option>
                  <option value="COUNT">Count Difference</option>
                  <option value="OTHER">Other</option>
                </select>
              </div>
            </div>

            <div className="bg-yellow-50 rounded-lg p-4 mb-6">
              <div className="flex items-center mb-2">
                <Icons.AlertTriangle className="w-5 h-5 text-yellow-600 mr-2" />
                <h3 className="font-medium text-yellow-800">Adjustment Warning</h3>
              </div>
              <p className="text-sm text-yellow-700">
                Inventory adjustments affect stock levels and valuations. Ensure proper authorization before posting.
              </p>
            </div>

            <div className="bg-gray-50 rounded-lg p-4 mb-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="font-medium">Materials to Adjust</h3>
                <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center">
                  <Icons.Plus className="w-4 h-4 mr-2" />
                  Add Material
                </button>
              </div>
              <div className="text-center text-gray-500 py-8">
                <Icons.Settings className="w-12 h-12 mx-auto mb-2 text-gray-400" />
                <p>No materials added for adjustment</p>
              </div>
            </div>

            <div className="flex space-x-4">
              <button className="bg-orange-600 text-white px-6 py-2 rounded-lg hover:bg-orange-700">
                Post Adjustment
              </button>
              <button className="bg-gray-500 text-white px-6 py-2 rounded-lg hover:bg-gray-600">
                Clear
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}