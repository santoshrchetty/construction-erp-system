'use client'

import { useEffect, useState, Suspense } from 'react'
import { useParams, useRouter, useSearchParams } from 'next/navigation'
import { ChevronDown, ChevronRight } from 'lucide-react'
import React from 'react'

function MaterialRequestDetail() {
  const params = useParams()
  const router = useRouter()
  const searchParams = useSearchParams()
  const [request, setRequest] = useState<any>(null)
  const [loading, setLoading] = useState(true)
  const [expandedRows, setExpandedRows] = useState<number[]>([])
  const [projects, setProjects] = useState<any[]>([])
  const fromApprovals = searchParams.get('from') === 'approvals'

  useEffect(() => {
    if (params.id) {
      fetchRequest(params.id as string)
      fetchProjects()
    }
  }, [params.id])

  const fetchRequest = async (id: string) => {
    try {
      const response = await fetch(`/api/material-requests?id=${id}`)
      const data = await response.json()
      if (data.success) {
        setRequest(data.data)
      }
    } catch (error) {
      console.error('Failed to fetch request:', error)
    } finally {
      setLoading(false)
    }
  }

  const fetchProjects = async () => {
    try {
      const response = await fetch('/api/projects')
      const data = await response.json()
      if (data.success) {
        setProjects(data.data || [])
      }
    } catch (error) {
      console.error('Failed to fetch projects:', error)
    }
  }

  const getProjectCode = (projectId: string) => {
    const project = projects.find(p => p.id === projectId)
    return project?.project_code || projectId
  }

  const handleEdit = () => {
    router.push(`/materials/requests/${params.id}/edit`)
  }

  const handleDelete = async () => {
    if (!confirm('Are you sure you want to delete this material request?')) return
    
    try {
      const response = await fetch(`/api/material-requests/${params.id}`, {
        method: 'DELETE'
      })
      const data = await response.json()
      if (data.success) {
        alert('Material Request deleted successfully')
        router.push('/materials/requests')
      } else {
        alert('Failed to delete: ' + data.error)
      }
    } catch (error) {
      alert('Failed to delete material request')
    }
  }

  const handleSubmit = async () => {
    if (!confirm('Submit this material request for approval?')) return
    
    try {
      // 1. Update MR status to IN_APPROVAL
      const updateResponse = await fetch(`/api/material-requests/${params.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          mr_type: request.request_type,
          company_code: request.company_code,
          requested_by: request.requested_by,
          priority: request.priority,
          submit: true,
          items: request.items
        })
      })
      
      const updateData = await updateResponse.json()
      if (!updateData.success) {
        alert('Failed to submit: ' + updateData.error)
        return
      }

      // 2. Create workflow instance
      const workflowResponse = await fetch('/api/workflows', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          object_type: 'MATERIAL_REQUEST',
          object_id: params.id,
          context_data: {
            request_number: request.request_number,
            request_type: request.request_type,
            company_code: request.company_code,
            plant_code: request.items?.[0]?.plant_code,
            department_code: request.items?.[0]?.department_code
          }
        })
      })
      
      const workflowData = await workflowResponse.json()
      if (workflowData.success) {
        alert('Material Request submitted for approval successfully!')
        fetchRequest(params.id as string)
      } else {
        alert('Request updated but workflow creation failed: ' + workflowData.error)
      }
    } catch (error) {
      alert('Failed to submit material request')
    }
  }

  const toggleRowExpansion = (index: number) => {
    setExpandedRows(prev => 
      prev.includes(index) ? prev.filter(i => i !== index) : [...prev, index]
    )
  }

  if (loading) return <div className="p-8">Loading...</div>

  if (!request) return <div className="p-8">Material Request not found</div>

  const isDraft = request.status === 'DRAFT'

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
                <button
                  onClick={() => router.push('/materials/requests')}
                  className="ml-1 text-sm font-medium text-gray-700 hover:text-blue-600 md:ml-2"
                >
                  Material Requests
                </button>
              </div>
            </li>
            <li>
              <div className="flex items-center">
                <svg className="w-6 h-6 text-gray-400" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clipRule="evenodd"></path>
                </svg>
                <span className="ml-1 text-sm font-medium text-gray-500 md:ml-2">{request.request_number}</span>
              </div>
            </li>
          </ol>
        </nav>
      </div>
      <div className="bg-white border rounded-lg">
        <div className="bg-gray-100 px-6 py-4 border-b flex justify-between items-center">
          <div>
            <h1 className="text-xl font-semibold">Material Request</h1>
            <p className="text-sm text-gray-600">{request.request_number}</p>
          </div>
          <div className="flex gap-2">
            <button 
              onClick={() => router.push(fromApprovals ? '/approvals/inbox' : '/materials/requests')}
              className="px-4 py-2 text-sm border bg-white hover:bg-gray-50"
            >
              {fromApprovals ? 'Back to Approvals' : 'Back to List'}
            </button>
            {isDraft && (
              <>
                <button 
                  onClick={handleEdit}
                  className="px-4 py-2 text-sm border bg-white hover:bg-gray-50"
                >
                  Edit
                </button>
                <button 
                  onClick={handleSubmit}
                  className="px-4 py-2 text-sm bg-blue-600 text-white hover:bg-blue-700"
                >
                  Submit
                </button>
                <button 
                  onClick={handleDelete}
                  className="px-4 py-2 text-sm bg-red-600 text-white hover:bg-red-700"
                >
                  Delete
                </button>
              </>
            )}
          </div>
        </div>

        <div className="p-6 space-y-6">
          <div className="grid grid-cols-4 gap-4">
            <div>
              <label className="text-xs font-medium text-gray-500">Status</label>
              <div className="mt-1">
                <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                  request.status === 'DRAFT' ? 'bg-gray-100 text-gray-800' :
                  request.status === 'SUBMITTED' ? 'bg-blue-100 text-blue-800' :
                  request.status === 'APPROVED' ? 'bg-green-100 text-green-800' :
                  'bg-red-100 text-red-800'
                }`}>
                  {request.status}
                </span>
              </div>
            </div>
            <div>
              <label className="text-xs font-medium text-gray-500">MR Type</label>
              <p className="mt-1 text-sm">{request.request_type}</p>
            </div>
            <div>
              <label className="text-xs font-medium text-gray-500">Company Code</label>
              <p className="mt-1 text-sm">{request.company_code}</p>
            </div>
            <div>
              <label className="text-xs font-medium text-gray-500">Requested By</label>
              <p className="mt-1 text-sm">{request.requested_by || '-'}</p>
            </div>
            <div>
              <label className="text-xs font-medium text-gray-500">Priority</label>
              <p className="mt-1 text-sm">{request.priority}</p>
            </div>
            <div>
              <label className="text-xs font-medium text-gray-500">Created At</label>
              <p className="mt-1 text-sm">{new Date(request.created_at).toLocaleString()}</p>
            </div>
          </div>

          <div>
            <h2 className="text-lg font-semibold mb-4">Line Items</h2>
            <div className="overflow-x-auto border rounded">
              <table className="w-full text-sm">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-3 py-2 text-left text-xs font-medium text-gray-500 w-8"></th>
                    <th className="px-3 py-2 text-left text-xs font-medium text-gray-500">Line</th>
                    <th className="px-3 py-2 text-left text-xs font-medium text-gray-500">Acct</th>
                    <th className="px-3 py-2 text-left text-xs font-medium text-gray-500">Material</th>
                    <th className="px-3 py-2 text-left text-xs font-medium text-gray-500">Description</th>
                    <th className="px-3 py-2 text-left text-xs font-medium text-gray-500">Quantity</th>
                    <th className="px-3 py-2 text-left text-xs font-medium text-gray-500">UoM</th>
                    <th className="px-3 py-2 text-left text-xs font-medium text-gray-500">Plant</th>
                    <th className="px-3 py-2 text-left text-xs font-medium text-gray-500">Required Date</th>
                  </tr>
                </thead>
                <tbody className="divide-y">
                  {request.items?.map((item: any, idx: number) => (
                    <React.Fragment key={item.id}>
                      <tr className="hover:bg-gray-50">
                        <td className="px-3 py-2 text-center">
                          <button onClick={() => toggleRowExpansion(idx)} className="p-0">
                            {expandedRows.includes(idx) ? <ChevronDown className="h-4 w-4" /> : <ChevronRight className="h-4 w-4" />}
                          </button>
                        </td>
                        <td className="px-3 py-2">{item.line_number}</td>
                        <td className="px-3 py-2">{item.account_assignment_code || '-'}</td>
                        <td className="px-3 py-2 font-medium">{item.material_code}</td>
                        <td className="px-3 py-2">{item.material_name || '-'}</td>
                        <td className="px-3 py-2 text-right">{item.requested_quantity}</td>
                        <td className="px-3 py-2">{item.base_uom}</td>
                        <td className="px-3 py-2">{item.plant_code || '-'}</td>
                        <td className="px-3 py-2">{item.required_date ? new Date(item.required_date).toLocaleDateString() : '-'}</td>
                      </tr>
                      {expandedRows.includes(idx) && (
                        <tr className="bg-blue-50">
                          <td colSpan={9} className="px-3 py-3">
                            <div className="grid grid-cols-4 gap-3 text-xs">
                              <div>
                                <label className="font-medium text-gray-600">Priority</label>
                                <p className="mt-1">{item.priority || '-'}</p>
                              </div>
                              <div>
                                <label className="font-medium text-gray-600">Storage Location</label>
                                <p className="mt-1">{item.storage_location || '-'}</p>
                              </div>
                              <div>
                                <label className="font-medium text-gray-600">Department</label>
                                <p className="mt-1">{item.department_code || '-'}</p>
                              </div>
                              <div>
                                <label className="font-medium text-gray-600">Delivery Location</label>
                                <p className="mt-1">{item.delivery_location || '-'}</p>
                              </div>
                              {item.account_assignment_code === 'P' && (
                                <>
                                  <div>
                                    <label className="font-medium text-gray-600">Project</label>
                                    <p className="mt-1">{item.project_id ? getProjectCode(item.project_id) : '-'}</p>
                                  </div>
                                  <div>
                                    <label className="font-medium text-gray-600">WBS Element</label>
                                    <p className="mt-1">{item.wbs_element || '-'}</p>
                                  </div>
                                  <div>
                                    <label className="font-medium text-gray-600">Activity</label>
                                    <p className="mt-1">{item.activity_code || '-'}</p>
                                  </div>
                                </>
                              )}
                              {item.account_assignment_code === 'K' && (
                                <div>
                                  <label className="font-medium text-gray-600">Cost Center</label>
                                  <p className="mt-1">{item.cost_center || '-'}</p>
                                </div>
                              )}
                              {item.account_assignment_code === 'A' && (
                                <div>
                                  <label className="font-medium text-gray-600">Asset Number</label>
                                  <p className="mt-1">{item.asset_number || '-'}</p>
                                </div>
                              )}
                              {item.account_assignment_code === 'O' && (
                                <div>
                                  <label className="font-medium text-gray-600">Order Number</label>
                                  <p className="mt-1">{item.order_number || '-'}</p>
                                </div>
                              )}
                              {item.account_assignment_code === 'OP' && (
                                <>
                                  <div>
                                    <label className="font-medium text-gray-600">Production Order</label>
                                    <p className="mt-1">{item.production_order_number || '-'}</p>
                                  </div>
                                  <div>
                                    <label className="font-medium text-gray-600">Operation</label>
                                    <p className="mt-1">{item.operation_number || '-'}</p>
                                  </div>
                                </>
                              )}
                              {item.account_assignment_code === 'OQ' && (
                                <>
                                  <div>
                                    <label className="font-medium text-gray-600">Quality Order</label>
                                    <p className="mt-1">{item.quality_order_number || '-'}</p>
                                  </div>
                                  <div>
                                    <label className="font-medium text-gray-600">Inspection Lot</label>
                                    <p className="mt-1">{item.inspection_lot || '-'}</p>
                                  </div>
                                </>
                              )}
                              {item.notes && (
                                <div className="col-span-4">
                                  <label className="font-medium text-gray-600">Notes</label>
                                  <p className="mt-1">{item.notes}</p>
                                </div>
                              )}
                            </div>
                          </td>
                        </tr>
                      )}
                    </React.Fragment>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default function MaterialRequestDetailPage() {
  return (
    <Suspense fallback={<div className="p-8">Loading...</div>}>
      <MaterialRequestDetail />
    </Suspense>
  )
}
