'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'

export default function ApprovalInboxPage() {
  const router = useRouter()
  const [approvals, setApprovals] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchPendingApprovals()
  }, [])

  const fetchPendingApprovals = async () => {
    try {
      const supabase = createClient()
      const { data: { user } } = await supabase.auth.getUser()
      
      if (!user) return

      const { data, error } = await supabase
        .from('step_instances')
        .select(`
          *,
          workflow_instances (
            object_type,
            object_id,
            context_data,
            workflow_definitions (workflow_name)
          ),
          workflow_steps (step_name)
        `)
        .eq('assigned_agent_id', user.id)
        .eq('status', 'PENDING')
        .order('created_at', { ascending: false })

      if (error) throw error
      setApprovals(data || [])
    } catch (error) {
      console.error('Failed to fetch approvals:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleAction = async (stepInstanceId: string, action: 'APPROVE' | 'REJECT') => {
    const comments = prompt(`${action === 'APPROVE' ? 'Approve' : 'Reject'} - Enter comments (optional):`)
    
    try {
      const response = await fetch('/api/workflows/approve', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          step_instance_id: stepInstanceId,
          action,
          comments
        })
      })

      const data = await response.json()
      if (data.success) {
        alert(`Request ${action.toLowerCase()}d successfully`)
        fetchPendingApprovals()
      } else {
        alert('Failed: ' + data.error)
      }
    } catch (error) {
      alert('Failed to process approval')
    }
  }

  const viewDocument = (approval: any) => {
    const objectType = approval.workflow_instances?.object_type
    const objectId = approval.workflow_instances?.object_id
    
    if (objectType === 'MATERIAL_REQUEST') {
      router.push(`/materials/requests/${objectId}?from=approvals`)
    }
  }

  if (loading) return <div className="p-8">Loading...</div>

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <div className="mb-4">
        <nav className="flex" aria-label="Breadcrumb">
          <ol className="inline-flex items-center space-x-1 md:space-x-3">
            <li className="inline-flex items-center">
              <button
                onClick={() => router.push('/erp-modules')}
                className="inline-flex items-center text-sm font-medium text-gray-700 hover:text-blue-600"
              >
                <svg className="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z"></path>
                </svg>
                Modules
              </button>
            </li>
            <li>
              <div className="flex items-center">
                <svg className="w-6 h-6 text-gray-400" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clipRule="evenodd"></path>
                </svg>
                <span className="ml-1 text-sm font-medium text-gray-500 md:ml-2">My Approval Inbox</span>
              </div>
            </li>
          </ol>
        </nav>
      </div>
      <div className="bg-white border rounded-lg">
        <div className="bg-gray-100 px-6 py-4 border-b">
          <h1 className="text-xl font-semibold">My Approval Inbox</h1>
          <p className="text-sm text-gray-600">{approvals.length} pending approval(s)</p>
        </div>

        <div className="p-6">
          {approvals.length === 0 ? (
            <div className="text-center py-12 text-gray-500">
              No pending approvals
            </div>
          ) : (
            <div className="space-y-4">
              {approvals.map((approval) => (
                <div key={approval.id} className="border rounded-lg p-4 hover:bg-gray-50">
                  <div className="flex justify-between items-start">
                    <div className="flex-1">
                      <div className="flex items-center gap-3 mb-2">
                        <span className="px-2 py-1 bg-blue-100 text-blue-800 text-xs font-medium rounded">
                          {approval.workflow_instances?.workflow_definitions?.workflow_name}
                        </span>
                        <span className="text-sm font-medium">
                          {approval.workflow_steps?.step_name}
                        </span>
                      </div>
                      
                      <div className="grid grid-cols-2 gap-2 text-sm mb-3">
                        <div>
                          <span className="text-gray-500">Document:</span>{' '}
                          <span className="font-medium">
                            {approval.workflow_instances?.context_data?.request_number || approval.workflow_instances?.object_id}
                          </span>
                        </div>
                        <div>
                          <span className="text-gray-500">Type:</span>{' '}
                          <span>{approval.workflow_instances?.context_data?.request_type}</span>
                        </div>
                        <div>
                          <span className="text-gray-500">Company:</span>{' '}
                          <span>{approval.workflow_instances?.context_data?.company_code}</span>
                        </div>
                        <div>
                          <span className="text-gray-500">Received:</span>{' '}
                          <span>{new Date(approval.created_at).toLocaleDateString()}</span>
                        </div>
                      </div>

                      {approval.timeout_at && (
                        <div className="text-xs text-orange-600">
                          Due: {new Date(approval.timeout_at).toLocaleString()}
                        </div>
                      )}
                    </div>

                    <div className="flex gap-2 ml-4">
                      <button
                        onClick={() => viewDocument(approval)}
                        className="px-4 py-2 text-sm border bg-white hover:bg-gray-50"
                      >
                        View
                      </button>
                      <button
                        onClick={() => handleAction(approval.id, 'APPROVE')}
                        className="px-4 py-2 text-sm bg-green-600 text-white hover:bg-green-700"
                      >
                        Approve
                      </button>
                      <button
                        onClick={() => handleAction(approval.id, 'REJECT')}
                        className="px-4 py-2 text-sm bg-red-600 text-white hover:bg-red-700"
                      >
                        Reject
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
