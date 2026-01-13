'use client'

import React, { useState, useCallback } from 'react'
import * as Icons from 'lucide-react'
import { ContextFieldSelector } from '../ContextFieldSelector'

const DEFAULT_CUSTOMER_ID = '550e8400-e29b-41d4-a716-446655440001'

// Local types
interface FieldDefinition {
  id: string
  field_name: string
  field_description: string
  field_type: string
}

interface DocumentType {
  object_type: string
  document_type: string
  document_label: string
  document_description: string
}

interface Approver {
  id: string
  functional_domain: string
  approver_role: string
  approval_scope: string
  approval_limit: number
}

interface WorkflowDefinition {
  id: string
  workflow_code: string
  workflow_name: string
  object_type: string
  is_active: boolean
}

interface WorkflowInstance {
  id: string
  object_id: string
  current_step_sequence: number
  created_at: string
  workflow_definitions?: {
    workflow_name: string
  }
  org_hierarchy?: {
    employee_name: string
  }
}

export default function ApprovalConfiguration() {
  const [activeTab, setActiveTab] = useState('workflows')
  const [loading, setLoading] = useState(false)
  const [selectedObjectType, setSelectedObjectType] = useState('')
  const [selectedDocumentType, setSelectedDocumentType] = useState('')
  const [fieldDefinitions, setFieldDefinitions] = useState<FieldDefinition[]>([])
  const [policySelections, setPolicySelections] = useState<Record<string, string[] | null>>({})
  const [existingPolicies, setExistingPolicies] = useState<any[]>([])
  const [loadingPolicies, setLoadingPolicies] = useState(false)
  const [approvers, setApprovers] = useState<Approver[]>([])
  const [loadingApprovers, setLoadingApprovers] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [documentTypes, setDocumentTypes] = useState<Record<string, any[]>>({})
  const [workflowDefinitions, setWorkflowDefinitions] = useState<WorkflowDefinition[]>([])
  const [workflowSteps, setWorkflowSteps] = useState<any[]>([])
  const [activeWorkflows, setActiveWorkflows] = useState<WorkflowInstance[]>([])

  const loadFieldDefinitions = useCallback(async () => {
    try {
      const response = await fetch('/api/approvals?action=field-definitions')
      const result = await response.json()
      if (result.success && result.data) {
        setFieldDefinitions(result.data)
      }
    } catch (error) {
      console.error('Failed to load field definitions:', error)
      setError('Failed to load field definitions')
    }
  }, [])

  const loadWorkflowDefinitions = useCallback(async () => {
    try {
      setLoading(true)
      const params = new URLSearchParams({
        action: 'workflow-definitions',
        ...(selectedObjectType && { object_type: selectedObjectType })
      })
      const response = await fetch(`/api/approvals?${params}`)
      const result = await response.json()
      if (result.success) {
        setWorkflowDefinitions(result.data || [])
      }
    } catch (error) {
      console.error('Failed to load workflow definitions:', error)
      setError('Failed to load workflow definitions')
    } finally {
      setLoading(false)
    }
  }, [selectedObjectType])

  const loadActiveWorkflows = useCallback(async () => {
    try {
      const params = new URLSearchParams({
        action: 'active-workflows',
        ...(selectedObjectType && { object_type: selectedObjectType })
      })
      const response = await fetch(`/api/approvals?${params}`)
      const result = await response.json()
      if (result.success) {
        setActiveWorkflows(result.data || [])
      }
    } catch (error) {
      console.error('Failed to load active workflows:', error)
      setError('Failed to load active workflows')
    }
  }, [selectedObjectType])

  const loadDocumentTypes = useCallback(async () => {
    try {
      const response = await fetch('/api/approvals?action=document-types')
      const result = await response.json()
      if (result.success && result.data && Array.isArray(result.data)) {
        const mapping: Record<string, any[]> = {}
        result.data.forEach((docType: DocumentType) => {
          if (!mapping[docType.object_type]) {
            mapping[docType.object_type] = []
          }
          mapping[docType.object_type].push({
            value: docType.document_type,
            label: docType.document_label,
            description: docType.document_description
          })
        })
        setDocumentTypes(mapping)
      }
    } catch (error) {
      console.error('Failed to load document types:', error)
      setDocumentTypes({
        'MR': [
          { value: 'NB', label: 'Normal Business', description: 'Standard material requests' },
          { value: 'EM', label: 'Emergency', description: 'Urgent material needs' }
        ],
        'PR': [
          { value: 'NB', label: 'Normal Business', description: 'Standard purchase requisitions' },
          { value: 'EM', label: 'Emergency', description: 'Urgent procurement needs' }
        ],
        'PO': [
          { value: 'NB', label: 'Normal Business', description: 'Standard purchase orders' },
          { value: 'EM', label: 'Emergency', description: 'Emergency procurement' }
        ]
      })
    }
  }, [])

  const loadApprovers = useCallback(async () => {
    setLoadingApprovers(true)
    setError(null)
    try {
      const response = await fetch('/api/approvals?action=approvers')
      const result = await response.json()
      if (result.success) {
        setApprovers(result.approvers || [])
      } else {
        setError(result.message || 'Failed to load approvers')
      }
    } catch (error) {
      console.error('Failed to load approvers:', error)
      setError('Failed to load approvers')
    } finally {
      setLoadingApprovers(false)
    }
  }, [])

  React.useEffect(() => {
    if (activeTab === 'workflows') {
      loadWorkflowDefinitions()
      loadActiveWorkflows()
    } else if (activeTab === 'policies') {
      loadFieldDefinitions()
      loadDocumentTypes()
    } else if (activeTab === 'approvers') {
      loadApprovers()
    }
  }, [activeTab, loadFieldDefinitions, loadDocumentTypes, loadWorkflowDefinitions, loadActiveWorkflows, loadApprovers])

  const handleObjectTypeChange = useCallback((objectType: string) => {
    setSelectedObjectType(objectType)
    setSelectedDocumentType('')
    setError(null)
  }, [])

  const getAvailableDocumentTypes = useCallback(() => {
    return selectedObjectType ? documentTypes[selectedObjectType] || [] : []
  }, [selectedObjectType, documentTypes])

  const testWorkflow = async () => {
    try {
      setLoading(true)
      const testData = {
        object_type: 'PR',
        object_id: 'PR-TEST-001',
        requester_id: 'EMP015',
        context_data: {
          amount: 15000,
          material_type: 'STANDARD',
          department_code: 'OPERATIONS',
          plant_code: 'PLT_MUM',
          company_code: 'C001'
        }
      }
      
      const response = await fetch('/api/approvals', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'create-workflow-instance',
          ...testData
        })
      })
      
      const result = await response.json()
      if (result.success) {
        alert('✅ Workflow instance created successfully!')
        loadActiveWorkflows()
      } else {
        alert(`❌ ${result.message}`)
      }
    } catch (error) {
      alert('❌ Test workflow failed')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="p-6">
      <div className="bg-white rounded-lg shadow p-6">
        <div className="mb-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <div className="flex items-center">
            <Icons.GitBranch className="w-5 h-5 text-blue-600 mr-2" />
            <div>
              <h4 className="font-medium text-blue-900">Flexible Approval Engine</h4>
              <p className="text-sm text-blue-600">Configure step-driven workflows and approval policies</p>
            </div>
          </div>
        </div>

        {error && (
          <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg">
            <div className="flex items-center">
              <Icons.AlertCircle className="w-5 h-5 text-red-600 mr-2" />
              <p className="text-sm text-red-600">{error}</p>
              <button
                onClick={() => setError(null)}
                className="ml-auto text-red-600 hover:text-red-800"
              >
                <Icons.X className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}

        <div className="border-b border-gray-200 mb-6">
          <nav className="flex justify-between items-center">
            <div className="flex space-x-8">
              <button
                onClick={() => setActiveTab('workflows')}
                className={`py-2 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'workflows'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                <div className="flex items-center space-x-2">
                  <Icons.GitBranch className="w-4 h-4" />
                  <span>Workflows</span>
                  <span className="bg-green-100 text-green-800 text-xs px-2 py-0.5 rounded-full font-medium">NEW</span>
                </div>
              </button>
              <button
                onClick={() => setActiveTab('policies')}
                className={`py-2 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'policies'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                Policies
              </button>
              <button
                onClick={() => setActiveTab('approvers')}
                className={`py-2 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'approvers'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                Approvers
              </button>
            </div>
            {activeTab === 'workflows' && (
              <div className="flex space-x-2">
                <button 
                  onClick={testWorkflow}
                  disabled={loading}
                  className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 disabled:opacity-50 text-sm"
                >
                  {loading ? 'Testing...' : 'Test Workflow'}
                </button>
                <button 
                  onClick={() => {
                    loadWorkflowDefinitions()
                    loadActiveWorkflows()
                  }}
                  disabled={loading}
                  className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 disabled:opacity-50 text-sm"
                >
                  {loading ? 'Loading...' : 'Refresh'}
                </button>
              </div>
            )}
          </nav>
        </div>

        {activeTab === 'workflows' && (
          <div className="space-y-4">
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
              <div className="flex items-center">
                <Icons.GitBranch className="w-5 h-5 text-blue-600 mr-2" />
                <div>
                  <h4 className="font-medium text-blue-900">Flexible Workflows</h4>
                  <p className="text-sm text-blue-600">Step-driven workflows with dynamic agent resolution</p>
                </div>
              </div>
            </div>

            <div className="bg-white border rounded-lg p-4">
              <label className="block text-sm font-medium text-gray-700 mb-2">Filter by Object Type</label>
              <select 
                className="w-full border rounded-lg px-3 py-2"
                value={selectedObjectType}
                onChange={(e) => handleObjectTypeChange(e.target.value)}
              >
                <option value="">All Object Types</option>
                <option value="PR">Purchase Requisition</option>
                <option value="PO">Purchase Order</option>
                <option value="DOCUMENT">Technical Document</option>
                <option value="MR">Material Request</option>
              </select>
            </div>

            <div className="bg-white border rounded-lg overflow-hidden">
              <div className="px-4 py-3 border-b bg-gray-50">
                <h3 className="text-lg font-medium text-gray-900">Workflow Definitions</h3>
              </div>
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Code</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {workflowDefinitions.map((workflow, index) => (
                      <tr key={index} className="hover:bg-gray-50">
                        <td className="px-4 py-4 text-sm font-medium text-blue-600">{workflow.workflow_code}</td>
                        <td className="px-4 py-4 text-sm text-gray-900">{workflow.workflow_name}</td>
                        <td className="px-4 py-4 text-sm text-gray-600">{workflow.object_type}</td>
                        <td className="px-4 py-4 text-sm">
                          <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                            workflow.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                          }`}>
                            {workflow.is_active ? 'Active' : 'Inactive'}
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

            <div className="bg-white border rounded-lg overflow-hidden">
              <div className="px-4 py-3 border-b bg-gray-50">
                <h3 className="text-lg font-medium text-gray-900">Active Workflow Instances</h3>
              </div>
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Object ID</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Workflow</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Step</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Created</th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {activeWorkflows.map((instance, index) => (
                      <tr key={index} className="hover:bg-gray-50">
                        <td className="px-4 py-4 text-sm font-medium text-blue-600">{instance.object_id}</td>
                        <td className="px-4 py-4 text-sm text-gray-900">{instance.workflow_definitions?.workflow_name}</td>
                        <td className="px-4 py-4 text-sm text-gray-600">Step {instance.current_step_sequence}</td>
                        <td className="px-4 py-4 text-sm text-gray-500">
                          {new Date(instance.created_at).toLocaleDateString()}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'policies' && (
          <div className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="bg-white border rounded-lg p-4">
                <label className="block text-sm font-medium text-gray-700 mb-2">Object Type</label>
                <select 
                  className="w-full border rounded-lg px-3 py-2"
                  value={selectedObjectType}
                  onChange={(e) => handleObjectTypeChange(e.target.value)}
                >
                  <option value="">Select Object Type</option>
                  <option value="MR">Material Request</option>
                  <option value="PR">Purchase Requisition</option>
                  <option value="PO">Purchase Order</option>
                </select>
              </div>
              <div className="bg-white border rounded-lg p-4">
                <label className="block text-sm font-medium text-gray-700 mb-2">Document Type</label>
                <select 
                  className="w-full border rounded-lg px-3 py-2"
                  value={selectedDocumentType}
                  onChange={(e) => setSelectedDocumentType(e.target.value)}
                  disabled={!selectedObjectType}
                >
                  <option value="">Select Document Type</option>
                  {getAvailableDocumentTypes().map(docType => (
                    <option key={docType.value} value={docType.value}>
                      {docType.label} - {docType.description}
                    </option>
                  ))}
                </select>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'approvers' && (
          <div className="space-y-4">
            <div className="bg-white border rounded-lg overflow-hidden">
              <div className="px-4 py-3 border-b bg-gray-50">
                <h3 className="text-lg font-medium text-gray-900">Functional Approvers</h3>
              </div>
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Domain</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Role</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Scope</th>
                      <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Limit</th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {loadingApprovers ? (
                      <tr><td colSpan={4} className="px-4 py-8 text-center"><div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600 mx-auto"></div></td></tr>
                    ) : approvers.length > 0 ? (
                      approvers.map((approver, index) => (
                        <tr key={index} className="hover:bg-gray-50">
                          <td className="px-4 py-4 text-sm font-medium text-blue-600">{approver.functional_domain}</td>
                          <td className="px-4 py-4 text-sm text-gray-900">{approver.approver_role}</td>
                          <td className="px-4 py-4 text-sm">
                            <span className="px-2 py-1 rounded-full text-xs bg-green-100 text-green-800">
                              {approver.approval_scope}
                            </span>
                          </td>
                          <td className="px-4 py-4 text-sm text-gray-900 text-right">
                            ${approver.approval_limit ? Number(approver.approval_limit).toLocaleString() : '0'}
                          </td>
                        </tr>
                      ))
                    ) : (
                      <tr><td colSpan={4} className="px-4 py-8 text-center text-gray-500">No approvers found</td></tr>
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}