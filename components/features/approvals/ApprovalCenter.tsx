'use client'

import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'

// API service functions following 4-layer architecture
const getPendingApprovals = async () => {
  const response = await fetch('/api/admin?action=pending-approvals')
  return await response.json()
}

const approvePurchaseOrder = async (poId: string) => {
  const response = await fetch(`/api/procurement?action=approve-po&id=${poId}`, {
    method: 'POST'
  })
  return await response.json()
}

const rejectPurchaseOrder = async (poId: string, reason: string) => {
  const response = await fetch(`/api/procurement?action=reject-po&id=${poId}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ reason })
  })
  return await response.json()
}

const approveTimesheet = async (timesheetId: string) => {
  const response = await fetch(`/api/hr?action=approve-timesheet&id=${timesheetId}`, {
    method: 'POST'
  })
  return await response.json()
}

const rejectTimesheet = async (timesheetId: string, reason: string) => {
  const response = await fetch(`/api/hr?action=reject-timesheet&id=${timesheetId}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ reason })
  })
  return await response.json()
}
import { useAuth } from '@/lib/contexts/AuthContext'

interface PendingApproval {
  purchaseOrders: any[]
  timesheets: any[]
  tasks: any[]
}

export default function ApprovalCenter() {
  const [approvals, setApprovals] = useState<PendingApproval>({ purchaseOrders: [], timesheets: [], tasks: [] })
  const [loading, setLoading] = useState(true)
  const [activeTab, setActiveTab] = useState('purchase-orders')
  const [showRejectModal, setShowRejectModal] = useState<{ show: boolean; type: string; id: string }>({ show: false, type: '', id: '' })
  const [rejectionReason, setRejectionReason] = useState('')
  const { user } = useAuth()

  useEffect(() => {
    loadApprovals()
  }, [])

  const loadApprovals = async () => {
    const result = await getPendingApprovals()
    if (result.success) {
      setApprovals(result.data)
    }
    setLoading(false)
  }

  const handleApprove = async (type: string, id: string) => {
    if (!user) return

    let result
    if (type === 'purchase-order') {
      result = await approvePurchaseOrder(id)
    } else if (type === 'timesheet') {
      result = await approveTimesheet(id)
    }

    if (result?.success) {
      loadApprovals()
    }
  }

  const handleReject = async () => {
    if (!user || !rejectionReason.trim()) return

    let result
    if (showRejectModal.type === 'purchase-order') {
      result = await rejectPurchaseOrder(showRejectModal.id, rejectionReason)
    } else if (showRejectModal.type === 'timesheet') {
      result = await rejectTimesheet(showRejectModal.id, rejectionReason)
    }

    if (result?.success) {
      setShowRejectModal({ show: false, type: '', id: '' })
      setRejectionReason('')
      loadApprovals()
    }
  }

  const tabs = [
    { key: 'purchase-orders', label: 'Purchase Orders', count: approvals.purchaseOrders.length },
    { key: 'timesheets', label: 'Timesheets', count: approvals.timesheets.length },
    { key: 'tasks', label: 'Tasks', count: approvals.tasks.length }
  ]

  if (loading) return <div className="p-6">Loading approvals...</div>

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-2xl font-bold">Approval Center</h2>
        <div className="text-sm text-gray-600">
          {approvals.purchaseOrders.length + approvals.timesheets.length + approvals.tasks.length} items pending
        </div>
      </div>

      <div className="border-b border-gray-200">
        <nav className="flex space-x-8">
          {tabs.map((tab) => (
            <button
              key={tab.key}
              onClick={() => setActiveTab(tab.key)}
              className={`py-2 px-1 border-b-2 font-medium text-sm ${
                activeTab === tab.key
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
            >
              {tab.label}
              {tab.count > 0 && (
                <span className="ml-2 bg-red-100 text-red-600 py-0.5 px-2 rounded-full text-xs">
                  {tab.count}
                </span>
              )}
            </button>
          ))}
        </nav>
      </div>

      {activeTab === 'purchase-orders' && (
        <div className="bg-white rounded-lg shadow">
          <div className="p-4 border-b">
            <h3 className="text-lg font-medium">Purchase Orders Pending Approval</h3>
          </div>
          <div className="divide-y">
            {approvals.purchaseOrders.map((po) => (
              <div key={po.id} className="p-4 flex justify-between items-center">
                <div>
                  <div className="font-medium">{po.po_number}</div>
                  <div className="text-sm text-gray-600">
                    Vendor: {po.vendors?.name} • Amount: ${po.total_amount?.toLocaleString()}
                  </div>
                  <div className="text-xs text-gray-500">
                    Issued: {new Date(po.issue_date).toLocaleDateString()}
                  </div>
                </div>
                <div className="flex space-x-2">
                  <button
                    onClick={() => handleApprove('purchase-order', po.id)}
                    className="bg-green-600 text-white px-3 py-1 rounded text-sm hover:bg-green-700"
                  >
                    Approve
                  </button>
                  <button
                    onClick={() => setShowRejectModal({ show: true, type: 'purchase-order', id: po.id })}
                    className="bg-red-600 text-white px-3 py-1 rounded text-sm hover:bg-red-700"
                  >
                    Reject
                  </button>
                </div>
              </div>
            ))}
            {approvals.purchaseOrders.length === 0 && (
              <div className="p-8 text-center text-gray-500">
                No purchase orders pending approval
              </div>
            )}
          </div>
        </div>
      )}

      {activeTab === 'timesheets' && (
        <div className="bg-white rounded-lg shadow">
          <div className="p-4 border-b">
            <h3 className="text-lg font-medium">Timesheets Pending Approval</h3>
          </div>
          <div className="divide-y">
            {approvals.timesheets.map((timesheet) => (
              <div key={timesheet.id} className="p-4 flex justify-between items-center">
                <div>
                  <div className="font-medium">
                    {timesheet.users?.first_name} {timesheet.users?.last_name}
                  </div>
                  <div className="text-sm text-gray-600">
                    Week ending: {new Date(timesheet.week_ending_date).toLocaleDateString()} • 
                    Hours: {timesheet.total_hours}
                  </div>
                  <div className="text-xs text-gray-500">
                    Submitted: {new Date(timesheet.submitted_at).toLocaleDateString()}
                  </div>
                </div>
                <div className="flex space-x-2">
                  <button
                    onClick={() => handleApprove('timesheet', timesheet.id)}
                    className="bg-green-600 text-white px-3 py-1 rounded text-sm hover:bg-green-700"
                  >
                    Approve
                  </button>
                  <button
                    onClick={() => setShowRejectModal({ show: true, type: 'timesheet', id: timesheet.id })}
                    className="bg-red-600 text-white px-3 py-1 rounded text-sm hover:bg-red-700"
                  >
                    Reject
                  </button>
                </div>
              </div>
            ))}
            {approvals.timesheets.length === 0 && (
              <div className="p-8 text-center text-gray-500">
                No timesheets pending approval
              </div>
            )}
          </div>
        </div>
      )}

      {activeTab === 'tasks' && (
        <div className="bg-white rounded-lg shadow">
          <div className="p-4 border-b">
            <h3 className="text-lg font-medium">Tasks Pending Approval</h3>
          </div>
          <div className="divide-y">
            {approvals.tasks.map((task) => (
              <div key={task.id} className="p-4 flex justify-between items-center">
                <div>
                  <div className="font-medium">{task.name}</div>
                  <div className="text-sm text-gray-600">
                    Assigned to: {task.users?.first_name} {task.users?.last_name}
                  </div>
                  <div className="text-xs text-gray-500">
                    Priority: {task.priority} • Created: {new Date(task.created_at).toLocaleDateString()}
                  </div>
                </div>
                <div className="flex space-x-2">
                  <button className="bg-green-600 text-white px-3 py-1 rounded text-sm hover:bg-green-700">
                    Approve
                  </button>
                  <button className="bg-red-600 text-white px-3 py-1 rounded text-sm hover:bg-red-700">
                    Reject
                  </button>
                </div>
              </div>
            ))}
            {approvals.tasks.length === 0 && (
              <div className="p-8 text-center text-gray-500">
                No tasks pending approval
              </div>
            )}
          </div>
        </div>
      )}

      {/* Rejection Modal */}
      {showRejectModal.show && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-bold mb-4">Reject Item</h3>
            <div className="mb-4">
              <label className="block text-sm font-medium mb-2">Reason for rejection:</label>
              <textarea
                value={rejectionReason}
                onChange={(e) => setRejectionReason(e.target.value)}
                className="w-full border rounded px-3 py-2 h-24"
                placeholder="Please provide a reason for rejection..."
                required
              />
            </div>
            <div className="flex justify-end space-x-3">
              <button
                onClick={() => {
                  setShowRejectModal({ show: false, type: '', id: '' })
                  setRejectionReason('')
                }}
                className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                onClick={handleReject}
                disabled={!rejectionReason.trim()}
                className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 disabled:opacity-50"
              >
                Reject
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}