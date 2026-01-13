'use client'

import React, { useState, useCallback } from 'react'
import * as Icons from 'lucide-react'
import { FlexibleApprovalService } from '../../domains/approval/FlexibleApprovalService'

export default function FlexibleApprovalConfiguration() {
  const [activeTab, setActiveTab] = useState('workflows')
  const [selectedObjectType, setSelectedObjectType] = useState('')
  const [workflowDefinitions, setWorkflowDefinitions] = useState<any[]>([])
  const [workflowSteps, setWorkflowSteps] = useState<any[]>([])
  const [activeWorkflows, setActiveWorkflows] = useState<any[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [selectedWorkflow, setSelectedWorkflow] = useState<any>(null)

  const loadWorkflowDefinitions = useCallback(async () => {
    try {
      setLoading(true)
      const workflows = await FlexibleApprovalService.getWorkflowDefinitions(selectedObjectType)
      setWorkflowDefinitions(workflows)
    } catch (error) {
      setError('Failed to load workflow definitions')
    } finally {
      setLoading(false)
    }
  }, [selectedObjectType])

  const loadActiveWorkflows = useCallback(async () => {
    try {
      setLoading(true)
      const workflows = await FlexibleApprovalService.getActiveWorkflows({ object_type: selectedObjectType })
      setActiveWorkflows(workflows)
    } catch (error) {
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

  const handleViewSteps = async (workflow: any) => {
    try {
      setLoading(true)
      const steps = await FlexibleApprovalService.getWorkflowSteps(workflow.id)
      setWorkflowSteps(steps)
      setSelectedWorkflow(workflow)
    } catch (error) {
      setError('Failed to load workflow steps')
    } finally {
      setLoading(false)
    }
  }

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

      const result = await FlexibleApprovalService.createWorkflowInstance(testData)
      
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
    <div className="min-h-screen bg-gray-50">
      {/* Mobile-optimized header */}
      <div className="bg-white shadow-sm border-b sticky top-0 z-10">
        <div className="px-4 py-3">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-lg font-semibold text-gray-900 sm:text-xl">Flexible Workflows</h1>
              <p className="text-xs text-gray-600 sm:text-sm">Step-driven approval engine</p>
            </div>
            <div className="flex items-center space-x-2">
              {loading && (
                <div className="animate-spin rounded-full h-5 w-5 border-2 border-blue-600 border-t-transparent"></div>
              )}
              <button 
                onClick={testWorkflow}
                disabled={loading}
                className="bg-blue-600 text-white px-3 py-1.5 rounded-lg text-sm font-medium disabled:opacity-50 hover:bg-blue-700 transition-colors"
              >
                Test
              </button>
            </div>
          </div>
        </div>

        {/* Mobile-optimized tabs */}
        <div className="px-4">
          <div className="flex space-x-1 overflow-x-auto scrollbar-hide">
            {[
              { id: 'workflows', label: 'Workflows', icon: Icons.GitBranch },
              { id: 'active', label: 'Active', icon: Icons.Activity },
              { id: 'test', label: 'Test', icon: Icons.Play }
            ].map(tab => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex items-center space-x-2 px-4 py-2 text-sm font-medium rounded-t-lg whitespace-nowrap transition-colors ${
                  activeTab === tab.id
                    ? 'bg-blue-50 text-blue-600 border-b-2 border-blue-600'
                    : 'text-gray-500 hover:text-gray-700'
                }`}
              >
                <tab.icon className="w-4 h-4" />
                <span>{tab.label}</span>
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Error banner */}
      {error && (
        <div className="mx-4 mt-4 p-3 bg-red-50 border border-red-200 rounded-lg">
          <div className="flex items-center justify-between">
            <div className="flex items-center">
              <Icons.AlertCircle className="w-4 h-4 text-red-600 mr-2" />
              <p className="text-sm text-red-600">{error}</p>
            </div>
            <button onClick={() => setError(null)} className="text-red-600">
              <Icons.X className="w-4 h-4" />
            </button>
          </div>
        </div>
      )}

      {/* Content */}
      <div className="p-4 space-y-4">
        {activeTab === 'workflows' && (
          <>
            {/* Object type filter */}
            <div className="bg-white rounded-lg shadow-sm border p-4">
              <label className="block text-sm font-medium text-gray-700 mb-2">Object Type</label>
              <select 
                className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                value={selectedObjectType}
                onChange={(e) => setSelectedObjectType(e.target.value)}
              >
                <option value="">All Types</option>
                <option value="PR">Purchase Requisition</option>
                <option value="PO">Purchase Order</option>
                <option value="DOCUMENT">Technical Document</option>
                <option value="MR">Material Request</option>
              </select>
            </div>

            {/* Workflow definitions - Mobile cards */}
            <div className="space-y-3">
              <h3 className="text-lg font-medium text-gray-900">Workflow Definitions</h3>
              {workflowDefinitions.length === 0 ? (
                <div className="bg-white rounded-lg shadow-sm border p-6 text-center">
                  <Icons.Workflow className="w-12 h-12 text-gray-400 mx-auto mb-3" />
                  <p className="text-gray-500">No workflows found</p>
                </div>
              ) : (
                <div className="grid gap-3">
                  {workflowDefinitions.map((workflow, index) => (
                    <div key={index} className="bg-white rounded-lg shadow-sm border p-4">
                      <div className="flex items-start justify-between mb-3">
                        <div className="flex-1 min-w-0">
                          <h4 className="font-medium text-gray-900 truncate">{workflow.workflow_code}</h4>
                          <p className="text-sm text-gray-600 mt-1">{workflow.workflow_name}</p>
                        </div>
                        <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                          workflow.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                        }`}>
                          {workflow.is_active ? 'Active' : 'Inactive'}
                        </span>
                      </div>
                      <div className="flex items-center justify-between">
                        <span className="text-xs bg-gray-100 text-gray-700 px-2 py-1 rounded">
                          {workflow.object_type}
                        </span>
                        <button
                          onClick={() => handleViewSteps(workflow)}
                          className="text-blue-600 hover:text-blue-800 text-sm font-medium"
                        >
                          View Steps
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Workflow steps modal/drawer */}
            {selectedWorkflow && workflowSteps.length > 0 && (
              <div className="bg-white rounded-lg shadow-sm border p-4">
                <div className="flex items-center justify-between mb-4">
                  <h4 className="font-medium text-gray-900">{selectedWorkflow.workflow_name} - Steps</h4>
                  <button
                    onClick={() => {
                      setSelectedWorkflow(null)
                      setWorkflowSteps([])
                    }}
                    className="text-gray-400 hover:text-gray-600"
                  >
                    <Icons.X className="w-5 h-5" />
                  </button>
                </div>
                <div className="space-y-3">
                  {workflowSteps.map((step, index) => (
                    <div key={index} className="border rounded-lg p-3">
                      <div className="flex items-center justify-between mb-2">
                        <span className="font-medium text-sm">Step {step.step_sequence}: {step.step_name}</span>
                        <span className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded">
                          {step.completion_rule}
                        </span>
                      </div>
                      <div className="text-xs text-gray-600 space-y-1">
                        <p><strong>Code:</strong> {step.step_code}</p>
                        {step.min_approvals && (
                          <p><strong>Min Approvals:</strong> {step.min_approvals}</p>
                        )}
                        {step.step_agents?.length > 0 && (
                          <div>
                            <strong>Agents:</strong>
                            <ul className="ml-2 mt-1">
                              {step.step_agents.map((agent, agentIndex) => (
                                <li key={agentIndex} className="text-xs">
                                  • {agent.agent_rules?.rule_name} ({agent.agent_rules?.rule_type})
                                </li>
                              ))}
                            </ul>
                          </div>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </>
        )}

        {activeTab === 'active' && (
          <div className="space-y-3">
            <h3 className="text-lg font-medium text-gray-900">Active Workflow Instances</h3>
            {activeWorkflows.length === 0 ? (
              <div className="bg-white rounded-lg shadow-sm border p-6 text-center">
                <Icons.Activity className="w-12 h-12 text-gray-400 mx-auto mb-3" />
                <p className="text-gray-500">No active workflows</p>
              </div>
            ) : (
              <div className="grid gap-3">
                {activeWorkflows.map((instance, index) => (
                  <div key={index} className="bg-white rounded-lg shadow-sm border p-4">
                    <div className="flex items-start justify-between mb-3">
                      <div className="flex-1 min-w-0">
                        <h4 className="font-medium text-gray-900 truncate">{instance.object_id}</h4>
                        <p className="text-sm text-gray-600 mt-1">{instance.workflow_definitions?.workflow_name}</p>
                      </div>
                      <span className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded">
                        Step {instance.current_step_sequence}
                      </span>
                    </div>
                    <div className="flex items-center justify-between text-xs text-gray-500">
                      <span>{instance.org_hierarchy?.employee_name}</span>
                      <span>{new Date(instance.created_at).toLocaleDateString()}</span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {activeTab === 'test' && (
          <div className="space-y-4">
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
              <h3 className="font-medium text-blue-900 mb-2">Workflow Engine Test</h3>
              <p className="text-sm text-blue-700 mb-3">
                Test the flexible workflow engine with step-driven logic:
              </p>
              <ul className="text-xs text-blue-600 space-y-1">
                <li>• <strong>Step-Driven:</strong> Sequential steps with completion rules</li>
                <li>• <strong>Dynamic Agents:</strong> Agent resolution based on hierarchy and roles</li>
                <li>• <strong>Parallel Approvals:</strong> Multiple agents per step</li>
                <li>• <strong>Context-Aware:</strong> Workflow selection based on conditions</li>
              </ul>
            </div>
            
            <button 
              onClick={testWorkflow}
              disabled={loading}
              className="w-full bg-blue-600 text-white py-3 rounded-lg font-medium disabled:opacity-50 hover:bg-blue-700 transition-colors"
            >
              {loading ? 'Creating Test Workflow...' : 'Create Test Workflow Instance'}
            </button>
            
            <div className="bg-gray-50 border rounded-lg p-4">
              <h4 className="font-medium text-gray-900 mb-2">Test Scenario</h4>
              <div className="text-sm text-gray-600 space-y-1">
                <p><strong>Object Type:</strong> Purchase Requisition (PR)</p>
                <p><strong>Amount:</strong> $15,000</p>
                <p><strong>Requester:</strong> EMP015 (Pooja Reddy)</p>
                <p><strong>Plant:</strong> PLT_MUM (Mumbai Plant)</p>
                <p><strong>Expected Flow:</strong> Manager → Finance → Final Approval</p>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}