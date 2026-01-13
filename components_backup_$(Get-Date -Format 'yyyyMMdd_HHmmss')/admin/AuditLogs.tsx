'use client'

import { useState, useEffect } from 'react'

interface AuditLog {
  id: string
  user_email: string
  action: string
  resource: string
  resource_id: string
  details: string
  ip_address: string
  timestamp: string
}

export default function AuditLogs() {
  const [logs, setLogs] = useState<AuditLog[]>([])
  const [loading, setLoading] = useState(true)
  const [filter, setFilter] = useState({
    action: '',
    resource: '',
    dateFrom: '',
    dateTo: ''
  })

  useEffect(() => {
    loadAuditLogs()
  }, [])

  const loadAuditLogs = async () => {
    // Mock data - replace with actual API call
    const mockLogs: AuditLog[] = [
      {
        id: '1',
        user_email: 'admin@company.com',
        action: 'CREATE',
        resource: 'USER',
        resource_id: 'user-123',
        details: 'Created new user: john.doe@company.com',
        ip_address: '192.168.1.100',
        timestamp: '2024-01-30T10:30:00Z'
      },
      {
        id: '2',
        user_email: 'manager@company.com',
        action: 'UPDATE',
        resource: 'PROJECT',
        resource_id: 'proj-456',
        details: 'Updated project budget from $100K to $120K',
        ip_address: '192.168.1.101',
        timestamp: '2024-01-30T09:15:00Z'
      },
      {
        id: '3',
        user_email: 'engineer@company.com',
        action: 'DELETE',
        resource: 'TASK',
        resource_id: 'task-789',
        details: 'Deleted task: Foundation inspection',
        ip_address: '192.168.1.102',
        timestamp: '2024-01-30T08:45:00Z'
      },
      {
        id: '4',
        user_email: 'procurement@company.com',
        action: 'APPROVE',
        resource: 'PURCHASE_ORDER',
        resource_id: 'po-101',
        details: 'Approved purchase order PO-2024-001 for $25,000',
        ip_address: '192.168.1.103',
        timestamp: '2024-01-29T16:20:00Z'
      }
    ]

    setLogs(mockLogs)
    setLoading(false)
  }

  const getActionColor = (action: string) => {
    switch (action) {
      case 'CREATE': return 'bg-green-100 text-green-800'
      case 'UPDATE': return 'bg-blue-100 text-blue-800'
      case 'DELETE': return 'bg-red-100 text-red-800'
      case 'APPROVE': return 'bg-purple-100 text-purple-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const filteredLogs = logs.filter(log => {
    if (filter.action && log.action !== filter.action) return false
    if (filter.resource && log.resource !== filter.resource) return false
    if (filter.dateFrom && new Date(log.timestamp) < new Date(filter.dateFrom)) return false
    if (filter.dateTo && new Date(log.timestamp) > new Date(filter.dateTo)) return false
    return true
  })

  if (loading) return <div className="p-6">Loading audit logs...</div>

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-bold">Audit Logs</h2>
        <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
          Export Logs
        </button>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-lg shadow p-4">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <label className="block text-sm font-medium mb-1">Action</label>
            <select
              value={filter.action}
              onChange={(e) => setFilter({...filter, action: e.target.value})}
              className="w-full border rounded px-3 py-2"
            >
              <option value="">All Actions</option>
              <option value="CREATE">Create</option>
              <option value="UPDATE">Update</option>
              <option value="DELETE">Delete</option>
              <option value="APPROVE">Approve</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Resource</label>
            <select
              value={filter.resource}
              onChange={(e) => setFilter({...filter, resource: e.target.value})}
              className="w-full border rounded px-3 py-2"
            >
              <option value="">All Resources</option>
              <option value="USER">User</option>
              <option value="PROJECT">Project</option>
              <option value="TASK">Task</option>
              <option value="PURCHASE_ORDER">Purchase Order</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">From Date</label>
            <input
              type="date"
              value={filter.dateFrom}
              onChange={(e) => setFilter({...filter, dateFrom: e.target.value})}
              className="w-full border rounded px-3 py-2"
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">To Date</label>
            <input
              type="date"
              value={filter.dateTo}
              onChange={(e) => setFilter({...filter, dateTo: e.target.value})}
              className="w-full border rounded px-3 py-2"
            />
          </div>
        </div>
      </div>

      {/* Logs Table */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Timestamp</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">User</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Action</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Resource</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Details</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">IP Address</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {filteredLogs.map((log) => (
              <tr key={log.id}>
                <td className="px-4 py-3 text-sm">
                  {new Date(log.timestamp).toLocaleString()}
                </td>
                <td className="px-4 py-3 text-sm font-medium">
                  {log.user_email}
                </td>
                <td className="px-4 py-3">
                  <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getActionColor(log.action)}`}>
                    {log.action}
                  </span>
                </td>
                <td className="px-4 py-3 text-sm">
                  {log.resource}
                </td>
                <td className="px-4 py-3 text-sm">
                  {log.details}
                </td>
                <td className="px-4 py-3 text-sm text-gray-500">
                  {log.ip_address}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {filteredLogs.length === 0 && (
        <div className="text-center py-8 text-gray-500">
          No audit logs found matching the current filters.
        </div>
      )}
    </div>
  )
}