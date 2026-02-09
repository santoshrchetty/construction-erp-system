'use client'
import { useState, useEffect } from 'react'
import { Search, Filter, FileText, Download, Settings } from 'lucide-react'

interface MaterialRequestItem {
  request_id: string
  item_id: string
  request_number: string
  request_type: string
  status: string
  priority: string
  project_code: string
  wbs_element: string
  company_code: string
  plant_code: string
  cost_center: string
  created_at: string
  line_number: number
  material_code: string
  material_name: string
  description: string
  requested_quantity: number
  base_uom: string
  estimated_price: number
  currency_code: string
  delivery_date: string
  storage_location: string
  required_date: string
}

interface MaterialRequestListProps {
  onNavigateToCreate?: () => void
}

const ALL_COLUMNS = [
  { key: 'request_number', label: 'MR Number', default: true },
  { key: 'line_number', label: 'Line', default: true },
  { key: 'status', label: 'Status', default: true },
  { key: 'request_type', label: 'Type', default: true },
  { key: 'priority', label: 'Priority', default: false },
  { key: 'material_code', label: 'Material Code', default: true },
  { key: 'material_name', label: 'Material Name', default: true },
  { key: 'description', label: 'Description', default: false },
  { key: 'requested_quantity', label: 'Quantity', default: true },
  { key: 'base_uom', label: 'UOM', default: true },
  { key: 'estimated_price', label: 'Price', default: true },
  { key: 'currency_code', label: 'Currency', default: false },
  { key: 'project_code', label: 'Project', default: true },
  { key: 'wbs_element', label: 'WBS', default: true },
  { key: 'company_code', label: 'Company', default: false },
  { key: 'plant_code', label: 'Plant', default: true },
  { key: 'cost_center', label: 'Cost Center', default: false },
  { key: 'storage_location', label: 'Storage Loc', default: true },
  { key: 'required_date', label: 'Required Date', default: true },
  { key: 'delivery_date', label: 'Delivery Date', default: false },
  { key: 'created_at', label: 'Created At', default: false }
]

export function MaterialRequestList({ onNavigateToCreate }: MaterialRequestListProps) {
  const [items, setItems] = useState<MaterialRequestItem[]>([])
  const [loading, setLoading] = useState(true)
  const [showColumnSettings, setShowColumnSettings] = useState(false)
  const [visibleColumns, setVisibleColumns] = useState<string[]>(
    ALL_COLUMNS.filter(col => col.default).map(col => col.key)
  )
  const [filters, setFilters] = useState({
    status: '',
    request_type: '',
    project_code: '',
    date_from: '',
    date_to: '',
    request_number: '',
    material_code: ''
  })

  const fetchRequests = async () => {
    setLoading(true)
    const params = new URLSearchParams()
    Object.entries(filters).forEach(([key, value]) => {
      if (value) params.append(key, value)
    })
    
    try {
      const response = await fetch(`/api/material-requests/list?${params}`)
      const result = await response.json()
      if (result.success) {
        setItems(result.data || [])
      } else {
        console.error('API error:', result.error)
      }
    } catch (error) {
      console.error('Failed to fetch requests:', error)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchRequests()
  }, [])

  const handleFilterChange = (key: string, value: string) => {
    setFilters(prev => ({ ...prev, [key]: value }))
  }

  const applyFilters = () => {
    fetchRequests()
  }

  const clearFilters = () => {
    setFilters({
      status: '',
      request_type: '',
      project_code: '',
      date_from: '',
      date_to: '',
      request_number: '',
      material_code: ''
    })
    setTimeout(fetchRequests, 100)
  }

  const toggleColumn = (key: string) => {
    setVisibleColumns(prev => 
      prev.includes(key) ? prev.filter(k => k !== key) : [...prev, key]
    )
  }

  const exportToExcel = () => {
    const visibleData = items.map(item => {
      const row: any = {}
      ALL_COLUMNS.filter(col => visibleColumns.includes(col.key)).forEach(col => {
        row[col.label] = item[col.key as keyof MaterialRequestItem] || ''
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
    a.download = `material_requests_${new Date().toISOString().split('T')[0]}.xls`
    a.click()
    window.URL.revokeObjectURL(url)
  }

  const getStatusBadge = (status: string) => {
    const colors = {
      DRAFT: 'bg-gray-100 text-gray-800',
      SUBMITTED: 'bg-blue-100 text-blue-800',
      APPROVED: 'bg-green-100 text-green-800',
      REJECTED: 'bg-red-100 text-red-800'
    }
    return colors[status as keyof typeof colors] || 'bg-gray-100 text-gray-800'
  }

  const renderCell = (item: MaterialRequestItem, key: string): React.ReactNode => {
    const value = item[key as keyof MaterialRequestItem]
    
    switch(key) {
      case 'status':
        return <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusBadge(String(value || ''))}`}>{String(value || '')}</span>
      case 'request_number':
        return <span className="font-medium text-blue-600">{String(value || '')}</span>
      case 'material_code':
        return <span className="font-medium">{String(value || '')}</span>
      case 'requested_quantity':
        return <span className="text-right block">{typeof value === 'number' ? value.toFixed(3) : '-'}</span>
      case 'estimated_price':
        return typeof value === 'number' ? `${item.currency_code || ''} ${value.toFixed(2)}` : '-'
      case 'required_date':
      case 'delivery_date':
      case 'created_at':
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
        <button 
          onClick={onNavigateToCreate} 
          className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          title="New Request"
        >
          <FileText className="w-5 h-5 text-gray-600" />
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
        
        <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-7 gap-4">
          <input
            type="text"
            placeholder="MR Number"
            value={filters.request_number}
            onChange={(e) => handleFilterChange('request_number', e.target.value)}
            className="px-3 py-2 border rounded-lg text-sm"
          />
          
          <select
            value={filters.status}
            onChange={(e) => handleFilterChange('status', e.target.value)}
            className="px-3 py-2 border rounded-lg text-sm"
          >
            <option value="">All Status</option>
            <option value="DRAFT">Draft</option>
            <option value="SUBMITTED">Submitted</option>
            <option value="APPROVED">Approved</option>
            <option value="REJECTED">Rejected</option>
          </select>
          
          <select
            value={filters.request_type}
            onChange={(e) => handleFilterChange('request_type', e.target.value)}
            className="px-3 py-2 border rounded-lg text-sm"
          >
            <option value="">All Types</option>
            <option value="MATERIAL_REQ">Material Request</option>
            <option value="PURCHASE_REQ">Purchase Request</option>
            <option value="PURCHASE_ORDER">Purchase Order</option>
            <option value="RESERVATION">Reservation</option>
          </select>
          
          <input
            type="text"
            placeholder="Project Code"
            value={filters.project_code}
            onChange={(e) => handleFilterChange('project_code', e.target.value)}
            className="px-3 py-2 border rounded-lg text-sm"
          />
          
          <input
            type="text"
            placeholder="Material Code"
            value={filters.material_code}
            onChange={(e) => handleFilterChange('material_code', e.target.value)}
            className="px-3 py-2 border rounded-lg text-sm"
          />
          
          <input
            type="date"
            placeholder="Creation Date From"
            value={filters.date_from}
            onChange={(e) => handleFilterChange('date_from', e.target.value)}
            className="px-3 py-2 border rounded-lg text-sm"
            title="Creation Date From"
          />
          
          <input
            type="date"
            placeholder="Creation Date To"
            value={filters.date_to}
            onChange={(e) => handleFilterChange('date_to', e.target.value)}
            className="px-3 py-2 border rounded-lg text-sm"
            title="Creation Date To"
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
          <div className="p-8 text-center">Loading...</div>
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
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {items.map((item) => (
                  <tr key={`${item.request_id}-${item.item_id}`} className="hover:bg-gray-50">
                    {ALL_COLUMNS.filter(col => visibleColumns.includes(col.key)).map(col => (
                      <td key={col.key} className="px-3 py-2 text-gray-900 whitespace-nowrap">
                        {renderCell(item, col.key)}
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
            
            {items.length === 0 && !loading && (
              <div className="p-8 text-center text-gray-500">
                No material request items found
              </div>
            )}
          </div>
        )}
      </div>
      
      <div className="text-sm text-gray-600 px-6 pb-6">
        Total Items: {items.length}
      </div>
    </div>
  )
}