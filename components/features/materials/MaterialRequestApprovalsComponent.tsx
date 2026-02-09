'use client'
import { useState, useEffect } from 'react'
import { useAuth } from '@/lib/contexts/AuthContext'
import { Search, Filter, Download, Settings, Eye, Check, X, Loader, CheckCircle } from 'lucide-react'

interface ApprovalItem {
  id: string
  workflow_instance_id: string
  step_sequence: number
  assigned_agent_name: string
  assigned_agent_role: string
  status: string
  timeout_at: string
  material_request: {
    id: string
    request_number: string
    request_type: string
    status: string
    priority: string
    project_code: string
    wbs_element: string
    company_code: string
    plant_code: string
    cost_center: string
    purpose: string
    justification: string
    total_amount: number
    currency_code: string
    created_at: string
    required_date: string
    material_request_items: any[]
  }
}

const ALL_COLUMNS = [
  { key: 'request_number', label: 'MR Number', default: true },
  { key: 'request_type', label: 'Type', default: true },
  { key: 'priority', label: 'Priority', default: true },
  { key: 'project_code', label: 'Project', default: true },
  { key: 'wbs_element', label: 'WBS', default: true },
  { key: 'company_code', label: 'Company', default: false },
  { key: 'plant_code', label: 'Plant', default: true },
  { key: 'cost_center', label: 'Cost Center', default: false },
  { key: 'purpose', label: 'Purpose', default: true },
  { key: 'total_amount', label: 'Total Amount', default: true },
  { key: 'currency_code', label: 'Currency', default: false },
  { key: 'created_at', label: 'Entry Date', default: true },
  { key: 'required_date', label: 'Required Date', default: true },
  { key: 'assigned_agent_role', label: 'Approval Step', default: true },
  { key: 'timeout_at', label: 'Due Date', default: false }
]

export function MaterialRequestApprovalsComponent() {
  const { user } = useAuth()
  const [approvals, setApprovals] = useState<ApprovalItem[]>([])
  const [loading, setLoading] = useState(false)
  const [selectedApproval, setSelectedApproval] = useState<ApprovalItem | null>(null)
  const [showModal, setShowModal] = useState(false)
  const [comments, setComments] = useState('')
  const [processing, setProcessing] = useState(false)
  const [showColumnSettings, setShowColumnSettings] = useState(false)
  const [visibleColumns, setVisibleColumns] = useState<string[]>(
    ALL_COLUMNS.filter(col => col.default).map(col => col.key)
  )
  const [filters, setFilters] = useState({
    request_number: '',
    priority: '',
    project_code: '',
    date_from: '',
    date_to: ''
  })

  useEffect(() => {
    if (user) {
      loadPendingApprovals()
    }
  }, [user])

  const loadPendingApprovals = async () => {
    setLoading(true)
    try {
      const response = await fetch('/api/material-requests/approvals', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'get_pending_approvals',
          payload: { agent_id: user?.id }
        })
      })
      const data = await response.json()
      if (data.success) {
        let filtered = data.data || []
        
        // Apply filters
        if (filters.request_number) {
          filtered = filtered.filter((a: ApprovalItem) => 
            a.material_request?.request_number?.includes(filters.request_number)
          )
        }
        if (filters.priority) {
          filtered = filtered.filter((a: ApprovalItem) => 
            a.material_request?.priority === filters.priority
          )
        }
        if (filters.project_code) {
          filtered = filtered.filter((a: ApprovalItem) => 
            a.material_request?.project_code?.includes(filters.project_code)
          )
        }
        if (filters.date_from) {
          filtered = filtered.filter((a: ApprovalItem) => 
            new Date(a.material_request?.created_at) >= new Date(filters.date_from)
          )
        }
        if (filters.date_to) {
          filtered = filtered.filter((a: ApprovalItem) => 
            new Date(a.material_request?.created_at) <= new Date(filters.date_to)
          )
        }
        
        setApprovals(filtered)
      }
    } catch (error) {
      console.error('Failed to load approvals:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleApprove = async () => {
    if (!selectedApproval) return
    
    setProcessing(true)
    try {
      const response = await fetch('/api/material-requests/approvals', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'process_approval',
          payload: {
            step_instance_id: selectedApproval.id,
            action: 'APPROVE',
            comments,
            request_id: selectedApproval.material_request?.id
          }
        })
      })
      const data = await response.json()
      if (data.success) {
        setShowModal(false)
        setComments('')
        loadPendingApprovals()
      }
    } catch (error) {
      console.error('Approval error:', error)
    } finally {
      setProcessing(false)
    }
  }

  const handleReject = async () => {
    if (!selectedApproval) return
    if (!comments.trim()) return
    
    setProcessing(true)
    try {
      const response = await fetch('/api/material-requests/approvals', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'process_approval',
          payload: {
            step_instance_id: selectedApproval.id,
            action: 'REJECT',
            comments,
            request_id: selectedApproval.material_request?.id
          }
        })
      })
      const data = await response.json()
      if (data.success) {
        setShowModal(false)
        setComments('')
        loadPendingApprovals()
      }
    } catch (error) {
      console.error('Rejection error:', error)
    } finally {
      setProcessing(false)
    }
  }

  const handleFilterChange = (key: string, value: string) => {
    setFilters(prev => ({ ...prev, [key]: value }))
  }

  const applyFilters = () => {
    loadPendingApprovals()
  }

  const clearFilters = () => {
    setFilters({
      request_number: '',
      priority: '',
      project_code: '',
      date_from: '',
      date_to: ''
    })
    setTimeout(loadPendingApprovals, 100)
  }

  const toggleColumn = (key: string) => {
    setVisibleColumns(prev => 
      prev.includes(key) ? prev.filter(k => k !== key) : [...prev, key]
    )
  }

  const exportToExcel = () => {
    const visibleData = approvals.map(approval => {
      const row: any = {}
      ALL_COLUMNS.filter(col => visibleColumns.includes(col.key)).forEach(col => {
        const value = col.key.startsWith('assigned_') 
          ? approval[col.key as keyof ApprovalItem]
          : approval.material_request?.[col.key as keyof typeof approval.material_request]
        row[col.label] = value || ''
      })
      return row
    })

    const worksheet = visibleData.map(row => Object.values(row))
    const headers = ALL_COLUMNS.filter(col => visibleColumns.includes(col.key)).map(col => col.label)
    const csv = [headers, ...worksheet].map(row => row.join('\t')).join('\n')
    
    const blob = new Blob([csv], { type: 'application/vnd.ms-excel' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `pending_approvals_${new Date().toISOString().split('T')[0]}.xls`
    a.click()
    window.URL.revokeObjectURL(url)
  }

  const getPriorityColor = (priority: string) => {
    const colors = {
      'LOW': 'bg-gray-100 text-gray-800',
      'MEDIUM': 'bg-yellow-100 text-yellow-800',
      'HIGH': 'bg-orange-100 text-orange-800',
      'URGENT': 'bg-red-100 text-red-800'
    }
    return colors[priority as keyof typeof colors] || 'bg-gray-100 text-gray-800'
  }

  const renderCell = (approval: ApprovalItem, key: string): React.ReactNode => {
    const request = approval.material_request
    const value = key.startsWith('assigned_') ? approval[key as keyof ApprovalItem] : request?.[key as keyof typeof request]
    
    switch(key) {
      case 'priority':
        return <span className={`px-2 py-1 rounded-full text-xs font-medium ${getPriorityColor(String(value || ''))}`}>{String(value || '')}</span>
      case 'request_number':
        return <span className="font-medium text-blue-600">{String(value || '')}</span>
      case 'total_amount':
        return typeof value === 'number' ? `${request?.currency_code || ''} ${value.toFixed(2)}` : '-'
      case 'created_at':
      case 'required_date':
      case 'timeout_at':
        return value ? new Date(String(value)).toLocaleDateString() : '-'
      default:
        return String(value || '-')
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex gap-2 px-6 pt-6">
        <button 
          onClick={() => setShowColumnSettings(!showColumnSettings)}
          className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          title="Column Settings"
        >
          <Settings className="w-5 h-5 text-gray-600" />
        </button>
        <button 
          onClick={exportToExcel} 
          className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          title="Export to Excel"
        >
          <Download className="w-5 h-5 text-gray-600" />
        </button>
      </div>

      {/* Column Settings */}
      {showColumnSettings && (
        <div className="bg-white p-4 rounded-lg border mx-6">
          <div className="text-sm font-medium text-gray-700 mb-3">Select Columns to Display</div>
          <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-2">
            {ALL_COLUMNS.map(col => (
              <label key={col.key} className="flex items-center gap-2 text-sm">
                <input
                  type="checkbox"
                  checked={visibleColumns.includes(col.key)}
                  onChange={() => toggleColumn(col.key)}
                  className="rounded"
                />
                <span>{col.label}</span>
              </label>
            ))}
          </div>
        </div>
      )}

      {/* Filters */}
      <div className="bg-white p-4 rounded-lg border space-y-4 mx-6">
        <div className="flex items-center gap-2 text-sm font-medium text-gray-700">
          <Filter className="w-4 h-4" />
          Filters
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-5 gap-4">
          <input
            type="text"
            placeholder="MR Number"
            value={filters.request_number}
            onChange={(e) => handleFilterChange('request_number', e.target.value)}
            className="px-3 py-2 border rounded-lg text-sm"
          />
          
          <select
            value={filters.priority}
            onChange={(e) => handleFilterChange('priority', e.target.value)}
            className="px-3 py-2 border rounded-lg text-sm"
          >
            <option value="">All Priorities</option>
            <option value="LOW">Low</option>
            <option value="MEDIUM">Medium</option>
            <option value="HIGH">High</option>
            <option value="URGENT">Urgent</option>
          </select>
          
          <input
            type="text"
            placeholder="Project Code"
            value={filters.project_code}
            onChange={(e) => handleFilterChange('project_code', e.target.value)}
            className="px-3 py-2 border rounded-lg text-sm"
          />
          
          <input
            type="date"
            placeholder="Entry Date From"
            value={filters.date_from}
            onChange={(e) => handleFilterChange('date_from', e.target.value)}
            className="px-3 py-2 border rounded-lg text-sm"
            title="Entry Date From"
          />
          
          <input
            type="date"
            placeholder="Entry Date To"
            value={filters.date_to}
            onChange={(e) => handleFilterChange('date_to', e.target.value)}
            className="px-3 py-2 border rounded-lg text-sm"
            title="Entry Date To"
          />
        </div>
        
        <div className="flex gap-2">
          <button
            onClick={applyFilters}
            className="bg-blue-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-blue-700"
          >
            <Search className="w-4 h-4 inline mr-1" />
            Apply
          </button>
          <button
            onClick={clearFilters}
            className="bg-gray-500 text-white px-4 py-2 rounded-lg text-sm hover:bg-gray-600"
          >
            Clear
          </button>
        </div>
      </div>

      {/* Table */}
      <div className="bg-white rounded-lg border mx-6">
        {loading ? (
          <div className="p-8 text-center">
            <Loader className="w-8 h-8 animate-spin mx-auto text-blue-500" />
            <p className="text-sm text-gray-600 mt-2">Loading approvals...</p>
          </div>
        ) : approvals.length === 0 ? (
          <div className="p-8 text-center">
            <CheckCircle className="w-12 h-12 mx-auto text-green-500" />
            <p className="text-gray-600 mt-2">No pending approvals</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-gray-50 sticky top-0">
                <tr>
                  {ALL_COLUMNS.filter(col => visibleColumns.includes(col.key)).map(col => (
                    <th key={col.key} className="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase whitespace-nowrap">
                      {col.label}
                    </th>
                  ))}
                  <th className="px-3 py-2 text-center text-xs font-medium text-gray-500 uppercase whitespace-nowrap">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {approvals.map((approval) => (
                  <tr key={approval.id} className="hover:bg-gray-50">
                    {ALL_COLUMNS.filter(col => visibleColumns.includes(col.key)).map(col => (
                      <td key={col.key} className="px-3 py-2 text-gray-900 whitespace-nowrap">
                        {renderCell(approval, col.key)}
                      </td>
                    ))}
                    <td className="px-3 py-2 text-center">
                      <button
                        onClick={() => {
                          setSelectedApproval(approval)
                          setShowModal(true)
                        }}
                        className="p-1 hover:bg-blue-100 rounded transition-colors"
                        title="Review"
                      >
                        <Eye className="w-4 h-4 text-blue-600" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
      
      <div className="text-sm text-gray-600 px-6 pb-6">
        Total Pending: {approvals.length}
      </div>

      {/* Approval Modal */}
      {showModal && selectedApproval && selectedApproval.material_request && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
            <div className="border-b border-gray-200 px-6 py-4 flex justify-between items-center">
              <h3 className="text-lg font-semibold text-gray-900">Review Request: {selectedApproval.material_request.request_number}</h3>
              <button onClick={() => setShowModal(false)} className="text-gray-400 hover:text-gray-600">
                <X className="w-5 h-5" />
              </button>
            </div>
            
            <div className="p-6 space-y-4">
              {/* Header Info */}
              <div className="grid grid-cols-3 gap-4">
                <div>
                  <label className="text-xs font-medium text-gray-500">Entry Date</label>
                  <p className="text-sm text-gray-900">{new Date(selectedApproval.material_request.created_at).toLocaleDateString()}</p>
                </div>
                <div>
                  <label className="text-xs font-medium text-gray-500">Priority</label>
                  <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getPriorityColor(selectedApproval.material_request.priority)}`}>
                    {selectedApproval.material_request.priority}
                  </span>
                </div>
                <div>
                  <label className="text-xs font-medium text-gray-500">Company</label>
                  <p className="text-sm text-gray-900">{selectedApproval.material_request.company_code}</p>
                </div>
                <div>
                  <label className="text-xs font-medium text-gray-500">Plant</label>
                  <p className="text-sm text-gray-900">{selectedApproval.material_request.plant_code}</p>
                </div>
                <div>
                  <label className="text-xs font-medium text-gray-500">Project</label>
                  <p className="text-sm text-gray-900">{selectedApproval.material_request.project_code || '-'}</p>
                </div>
                <div>
                  <label className="text-xs font-medium text-gray-500">WBS Element</label>
                  <p className="text-sm text-gray-900">{selectedApproval.material_request.wbs_element || '-'}</p>
                </div>
              </div>
              
              {/* Purpose & Justification */}
              {selectedApproval.material_request.purpose && (
                <div>
                  <label className="text-xs font-medium text-gray-500">Purpose</label>
                  <p className="text-sm text-gray-900">{selectedApproval.material_request.purpose}</p>
                </div>
              )}
              
              {selectedApproval.material_request.justification && (
                <div>
                  <label className="text-xs font-medium text-gray-500">Justification</label>
                  <p className="text-sm text-gray-900">{selectedApproval.material_request.justification}</p>
                </div>
              )}
              
              {/* Material Line Items */}
              {selectedApproval.material_request.material_request_items && selectedApproval.material_request.material_request_items.length > 0 && (
                <div>
                  <label className="text-sm font-medium text-gray-700 mb-2 block">Material Items</label>
                  <div className="border rounded-lg overflow-hidden">
                    <table className="min-w-full text-sm">
                      <thead className="bg-gray-50">
                        <tr>
                          <th className="px-3 py-2 text-left text-xs font-medium text-gray-500">#</th>
                          <th className="px-3 py-2 text-left text-xs font-medium text-gray-500">Material</th>
                          <th className="px-3 py-2 text-left text-xs font-medium text-gray-500">Description</th>
                          <th className="px-3 py-2 text-right text-xs font-medium text-gray-500">Quantity</th>
                          <th className="px-3 py-2 text-left text-xs font-medium text-gray-500">UOM</th>
                          <th className="px-3 py-2 text-right text-xs font-medium text-gray-500">Price</th>
                        </tr>
                      </thead>
                      <tbody className="divide-y divide-gray-200">
                        {selectedApproval.material_request.material_request_items.map((item: any) => (
                          <tr key={item.id}>
                            <td className="px-3 py-2 text-gray-900">{item.line_number}</td>
                            <td className="px-3 py-2 text-gray-900 font-medium">{item.material_code}</td>
                            <td className="px-3 py-2 text-gray-900">{item.material_name || item.description || '-'}</td>
                            <td className="px-3 py-2 text-right text-gray-900">{item.requested_quantity?.toFixed(3)}</td>
                            <td className="px-3 py-2 text-gray-900">{item.base_uom}</td>
                            <td className="px-3 py-2 text-right text-gray-900">
                              {item.estimated_price ? `${item.currency_code} ${item.estimated_price.toFixed(2)}` : '-'}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                  <div className="mt-2 text-right">
                    <span className="text-sm font-medium text-gray-700">Total: </span>
                    <span className="text-sm font-bold text-gray-900">
                      {selectedApproval.material_request.currency_code} {selectedApproval.material_request.total_amount?.toFixed(2) || '0.00'}
                    </span>
                  </div>
                </div>
              )}
              
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Comments</label>
                <textarea
                  className="w-full border rounded-lg px-3 py-2"
                  rows={3}
                  placeholder="Add approval/rejection comments..."
                  value={comments}
                  onChange={(e) => setComments(e.target.value)}
                />
              </div>
            </div>
            
            <div className="border-t border-gray-200 px-6 py-4 flex justify-end space-x-3">
              <button
                onClick={handleReject}
                disabled={processing || !comments.trim()}
                className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700 disabled:opacity-50"
              >
                <X className="w-4 h-4 inline mr-1" />
                Reject
              </button>
              <button
                onClick={handleApprove}
                disabled={processing}
                className="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700 disabled:opacity-50"
              >
                <Check className="w-4 h-4 inline mr-1" />
                Approve
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
