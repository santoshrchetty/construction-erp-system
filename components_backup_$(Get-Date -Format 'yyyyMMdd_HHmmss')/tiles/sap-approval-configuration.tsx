'use client'

import React, { useState, useCallback, useMemo } from 'react'
import * as Icons from 'lucide-react'
import { ContextFieldSelector } from '../ContextFieldSelector'

const DEFAULT_CUSTOMER_ID = '550e8400-e29b-41d4-a716-446655440001'

// Local types
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

interface WorkflowStep {
  id: string
  step_sequence: number
  step_name: string
  step_code: string
  completion_rule: string
  min_approvals?: number
  step_agents?: Array<{
    agent_rules?: {
      rule_name: string
      rule_type: string
    }
  }>
}

export default function ApprovalConfiguration() {
  const [activeTab, setActiveTab] = useState('workflows')
  const [selectedObjectType, setSelectedObjectType] = useState('')
  const [workflowDefinitions, setWorkflowDefinitions] = useState<WorkflowDefinition[]>([])
  const [workflowSteps, setWorkflowSteps] = useState<WorkflowStep[]>([])
  const [activeWorkflows, setActiveWorkflows] = useState<WorkflowInstance[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

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
      setLoading(true)
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
    } finally {
      setLoading(false)
    }
  }, [selectedObjectType])

  React.useEffect(() => {
    if (activeTab === 'workflows') {
      loadWorkflowDefinitions()
      loadActiveWorkflows()
    }
  }, [activeTab, loadWorkflowDefinitions, loadActiveWorkflows])

  const handleObjectTypeChange = useCallback((objectType: string) => {
    setSelectedObjectType(objectType)
    setError(null)
    setWorkflowSteps([])
  }, [])

  const handleViewSteps = async (workflowId: string) => {
    try {
      const response = await fetch(`/api/approvals?action=workflow-steps&workflow_id=${workflowId}`)
      const result = await response.json()
      if (result.success) {
        setWorkflowSteps(result.data || [])
      }
    } catch (error) {
      console.error('Failed to load workflow steps:', error)
      setError('Failed to load workflow steps')
    }
  }

  const testSAPWorkflow = async () => {
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
      console.error('Test workflow failed:', error)
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
            <Icons.Settings className="w-5 h-5 text-blue-600 mr-2" />
            <div>
              <p className="text-sm text-blue-600">Step-driven workflow engine with dynamic agent resolution</p>
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
                Workflows
              </button>
              <button
                onClick={() => setActiveTab('test')}
                className={`py-2 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'test'
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                Test Engine
              </button>
            </div>
            {activeTab === 'workflows' && (
              <div className="flex space-x-2">
                <button 
                  onClick={testSAPWorkflow}
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
                  <p className="text-sm text-blue-600">Step-driven workflows with dynamic agent resolution and parallel approvals</p>
                </div>
              </div>
            </div>

            {/* Object Type Filter */}
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

            {/* Workflow Definitions */}
            <div className="bg-white border rounded-lg overflow-hidden">
              <div className="px-4 py-3 border-b bg-gray-50">
                <h3 className="text-lg font-medium text-gray-900">Workflow Definitions</h3>
              </div>
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-gray-200">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Workflow Code</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Object Type</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Steps</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {workflowDefinitions.map((workflow, index) => (
                      <tr key={index} className="hover:bg-gray-50">
                        <td className="px-4 py-4 text-sm font-medium text-blue-600">{workflow.workflow_code}</td>
                        <td className="px-4 py-4 text-sm text-gray-900">{workflow.workflow_name}</td>
                        <td className="px-4 py-4 text-sm text-gray-600">{workflow.object_type}</td>
                        <td className="px-4 py-4 text-sm text-gray-600">
                          <button
                            onClick={() => handleViewSteps(workflow.id)}
                            className="text-blue-600 hover:text-blue-800 text-xs"
                          >
                            View Steps
                          </button>
                        </td>
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

            {/* Active Workflow Instances */}
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
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Requester</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Current Step</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Created</th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {activeWorkflows.map((instance, index) => (
                      <tr key={index} className="hover:bg-gray-50">
                        <td className="px-4 py-4 text-sm font-medium text-blue-600">{instance.object_id}</td>
                        <td className="px-4 py-4 text-sm text-gray-900">{instance.workflow_definitions?.workflow_name}</td>
                        <td className="px-4 py-4 text-sm text-gray-600">{instance.org_hierarchy?.employee_name}</td>
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

            {/* Workflow Steps Detail */}
            {workflowSteps.length > 0 && (
              <div className="bg-white border rounded-lg overflow-hidden">
                <div className="px-4 py-3 border-b bg-gray-50">
                  <h3 className="text-lg font-medium text-gray-900">Workflow Steps Detail</h3>
                </div>
                <div className="p-4 space-y-3">
                  {workflowSteps.map((step, index) => (
                    <div key={index} className="border rounded-lg p-3">
                      <div className="flex items-center justify-between mb-2">
                        <h4 className="font-medium text-gray-900">Step {step.step_sequence}: {step.step_name}</h4>
                        <span className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded">
                          {step.completion_rule}
                        </span>
                      </div>
                      <div className="text-sm text-gray-600 space-y-1">
                        <p><strong>Code:</strong> {step.step_code}</p>
                        {step.min_approvals && (
                          <p><strong>Min Approvals:</strong> {step.min_approvals}</p>
                        )}
                        <div>
                          <strong>Agent Rules:</strong>
                          <ul className="ml-4 mt-1">
                            {step.step_agents?.map((agent, agentIndex) => (
                              <li key={agentIndex} className="text-xs">
                                • {agent.agent_rules?.rule_name} ({agent.agent_rules?.rule_type})
                              </li>
                            ))}
                          </ul>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}

        {activeTab === 'test' && (
          <div className="space-y-4">
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-4">
              <h3 className="font-medium text-blue-900 mb-2">Workflow Engine Test</h3>
              <p className="text-sm text-blue-700 mb-2">
                Test the new flexible workflow engine with step-driven logic:
              </p>
              <ul className="text-xs text-blue-600 space-y-1">
                <li>• <strong>Step-Driven</strong>: Sequential steps with completion rules (ALL/ANY/MIN_N)</li>
                <li>• <strong>Dynamic Agents</strong>: Agent resolution based on hierarchy, roles, and responsibilities</li>
                <li>• <strong>Parallel Approvals</strong>: Multiple agents per step with completion rules</li>
                <li>• <strong>Context-Aware</strong>: Workflow selection based on activation conditions</li>
              </ul>
            </div>
            
            <button 
              onClick={testSAPWorkflow}
              disabled={loading}
              className="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 disabled:opacity-50 font-medium"
            >
              {loading ? 'Creating Test Workflow...' : 'Create Test Workflow Instance'}
            </button>
            
            <div className="bg-gray-50 border rounded-lg p-4">
              <h4 className="font-medium text-gray-900 mb-2">Test Scenario</h4>
              <div className="text-sm text-gray-600 space-y-1">
                <p><strong>Object Type:</strong> Purchase Requisition (PR)</p>
                <p><strong>Amount:</strong> $15,000</p>
                <p><strong>Requester:</strong> EMP015 (Pooja Reddy - Site Supervisor)</p>
                <p><strong>Plant:</strong> PLT_MUM (Mumbai Plant)</p>
                <p><strong>Expected Flow:</strong> Manager Approval → Finance Review → Final Approval</p>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}