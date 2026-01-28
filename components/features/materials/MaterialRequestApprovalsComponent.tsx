import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'

export function MaterialRequestApprovalsComponent() {
  const [requests, setRequests] = useState([])
  const [loading, setLoading] = useState(false)
  const [selectedRequest, setSelectedRequest] = useState(null)
  const [showModal, setShowModal] = useState(false)
  const [comments, setComments] = useState('')
  const [processing, setProcessing] = useState(false)

  useEffect(() => {
    loadPendingRequests()
  }, [])

  const loadPendingRequests = async () => {
    setLoading(true)
    try {
      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          category: 'materials',
          action: 'material-request-list',
          payload: { 
            request_type: 'MATERIAL_REQ',
            status: 'SUBMITTED'
          }
        })
      })
      const data = await response.json()
      if (data.success) setRequests(data.data || [])
    } catch (error) {
      console.error('Failed to load requests:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleApprove = async (requestId) => {
    setProcessing(true)
    try {
      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          category: 'materials',
          action: 'approve-material-request',
          payload: {
            request_id: requestId,
            status: 'APPROVED',
            comments
          }
        })
      })
      const data = await response.json()
      if (data.success) {
        alert('Request approved successfully!')
        setShowModal(false)
        setComments('')
        loadPendingRequests()
      }
    } catch (error) {
      alert('Error: ' + error.message)
    } finally {
      setProcessing(false)
    }
  }

  const handleReject = async (requestId) => {
    if (!comments.trim()) {
      alert('Please provide rejection reason')
      return
    }
    
    setProcessing(true)
    try {
      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          category: 'materials',
          action: 'approve-material-request',
          payload: {
            request_id: requestId,
            status: 'REJECTED',
            comments
          }
        })
      })
      const data = await response.json()
      if (data.success) {
        alert('Request rejected')
        setShowModal(false)
        setComments('')
        loadPendingRequests()
      }
    } catch (error) {
      alert('Error: ' + error.message)
    } finally {
      setProcessing(false)
    }
  }

  const getPriorityColor = (priority) => {
    const colors = {
      'LOW': 'bg-gray-100 text-gray-800',
      'MEDIUM': 'bg-yellow-100 text-yellow-800',
      'HIGH': 'bg-orange-100 text-orange-800',
      'URGENT': 'bg-red-100 text-red-800'
    }
    return colors[priority] || 'bg-gray-100 text-gray-800'
  }

  return (
    <div className="p-6">
      <div className="bg-white rounded-lg shadow">
        <div className="border-b border-gray-200 px-6 py-4">
          <h2 className="text-lg font-semibold text-gray-900">Pending Material Request Approvals</h2>
          <p className="text-sm text-gray-600 mt-1">Review and approve/reject material requests</p>
        </div>

        <div className="p-6">
          {loading ? (
            <div className="text-center py-8">
              <Icons.Loader className="w-8 h-8 animate-spin mx-auto text-blue-500" />
              <p className="text-sm text-gray-600 mt-2">Loading requests...</p>
            </div>
          ) : requests.length === 0 ? (
            <div className="text-center py-8">
              <Icons.CheckCircle className="w-12 h-12 mx-auto text-green-500" />
              <p className="text-gray-600 mt-2">No pending approvals</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Request #</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Entry Date</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Required Date</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Priority</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Purpose</th>
                    <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Actions</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {requests.map((request) => (
                    <tr key={request.id} className="hover:bg-gray-50">
                      <td className="px-4 py-4 text-sm font-medium text-gray-900">{request.request_number}</td>
                      <td className="px-4 py-4 text-sm text-gray-900">{new Date(request.created_at).toLocaleDateString()}</td>
                      <td className="px-4 py-4 text-sm text-gray-900">{request.required_date}</td>
                      <td className="px-4 py-4 text-sm">
                        <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getPriorityColor(request.priority)}`}>
                          {request.priority}
                        </span>
                      </td>
                      <td className="px-4 py-4 text-sm text-gray-900">{request.purpose || '-'}</td>
                      <td className="px-4 py-4 text-center space-x-2">
                        <button
                          onClick={() => {
                            setSelectedRequest(request)
                            setShowModal(true)
                          }}
                          className="bg-blue-100 text-blue-700 px-3 py-1 rounded text-xs hover:bg-blue-200"
                        >
                          <Icons.Eye className="w-3 h-3 inline mr-1" />
                          Review
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>

      {/* Approval Modal */}
      {showModal && selectedRequest && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
            <div className="border-b border-gray-200 px-6 py-4 flex justify-between items-center">
              <h3 className="text-lg font-semibold text-gray-900">Review Request: {selectedRequest.request_number}</h3>
              <button onClick={() => setShowModal(false)} className="text-gray-400 hover:text-gray-600">
                <Icons.X className="w-5 h-5" />
              </button>
            </div>
            
            <div className="p-6 space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="text-xs font-medium text-gray-500">Entry Date</label>
                  <p className="text-sm text-gray-900">{new Date(selectedRequest.created_at).toLocaleDateString()}</p>
                </div>
                <div>
                  <label className="text-xs font-medium text-gray-500">Required Date</label>
                  <p className="text-sm text-gray-900">{selectedRequest.required_date}</p>
                </div>
                <div>
                  <label className="text-xs font-medium text-gray-500">Priority</label>
                  <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getPriorityColor(selectedRequest.priority)}`}>
                    {selectedRequest.priority}
                  </span>
                </div>
                <div>
                  <label className="text-xs font-medium text-gray-500">Company</label>
                  <p className="text-sm text-gray-900">{selectedRequest.company_code}</p>
                </div>
              </div>
              
              {selectedRequest.purpose && (
                <div>
                  <label className="text-xs font-medium text-gray-500">Purpose</label>
                  <p className="text-sm text-gray-900">{selectedRequest.purpose}</p>
                </div>
              )}
              
              {selectedRequest.justification && (
                <div>
                  <label className="text-xs font-medium text-gray-500">Justification</label>
                  <p className="text-sm text-gray-900">{selectedRequest.justification}</p>
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
                onClick={() => handleReject(selectedRequest.id)}
                disabled={processing}
                className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700 disabled:opacity-50"
              >
                <Icons.X className="w-4 h-4 inline mr-1" />
                Reject
              </button>
              <button
                onClick={() => handleApprove(selectedRequest.id)}
                disabled={processing}
                className="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700 disabled:opacity-50"
              >
                <Icons.Check className="w-4 h-4 inline mr-1" />
                Approve
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
