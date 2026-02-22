'use client'
import { useState, useEffect } from 'react'

export default function WorkflowAdminPage() {
  const [workflows, setWorkflows] = useState([])
  const [selectedWorkflow, setSelectedWorkflow] = useState(null)
  const [steps, setSteps] = useState([])
  const [agentRules, setAgentRules] = useState([])

  useEffect(() => {
    loadWorkflows()
    loadAgentRules()
  }, [])

  const loadWorkflows = async () => {
    const res = await fetch('/api/workflows/definitions')
    const data = await res.json()
    setWorkflows(data)
  }

  const loadAgentRules = async () => {
    const res = await fetch('/api/workflows/agent-rules')
    const data = await res.json()
    setAgentRules(data)
  }

  const loadSteps = async (workflowId: string) => {
    const res = await fetch(`/api/workflows/definitions/${workflowId}/steps`)
    const data = await res.json()
    setSteps(data)
  }

  const handleWorkflowSelect = (workflowId: string) => {
    const workflow = workflows.find(w => w.id === workflowId)
    setSelectedWorkflow(workflow)
    loadSteps(workflowId)
  }

  const addStep = async () => {
    if (!selectedWorkflow) return

    const newStep = {
      workflow_id: selectedWorkflow.id,
      step_sequence: steps.length + 1,
      step_code: `STEP_${steps.length + 1}`,
      step_name: `Step ${steps.length + 1}`,
      completion_rule: 'ANY',
      is_active: true
    }

    const res = await fetch('/api/workflows/steps', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(newStep)
    })

    if (res.ok) {
      loadSteps(selectedWorkflow.id)
    }
  }

  return (
    <div className="p-8 space-y-6">
      <h1 className="text-3xl font-bold">Workflow Administration</h1>

      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-xl font-semibold mb-4">Select Workflow</h2>
        <select 
          onChange={(e) => handleWorkflowSelect(e.target.value)}
          className="w-full border rounded px-3 py-2"
        >
          <option value="">Select a workflow</option>
          {workflows.map(w => (
            <option key={w.id} value={w.id}>
              {w.workflow_name} ({w.object_type})
            </option>
          ))}
        </select>
      </div>

      {selectedWorkflow && (
        <div className="bg-white rounded-lg shadow p-6">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">Workflow Steps</h2>
            <button 
              onClick={addStep}
              className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
            >
              Add Step
            </button>
          </div>
          <div className="space-y-4">
            {steps.map(step => (
              <StepCard 
                key={step.id} 
                step={step} 
                agentRules={agentRules}
                onUpdate={() => loadSteps(selectedWorkflow.id)}
              />
            ))}
          </div>
        </div>
      )}
    </div>
  )
}

function StepCard({ step, agentRules, onUpdate }) {
  const [editing, setEditing] = useState(false)
  const [stepName, setStepName] = useState(step.step_name)
  const [completionRule, setCompletionRule] = useState(step.completion_rule)
  const [selectedRule, setSelectedRule] = useState('')

  const updateStep = async () => {
    const res = await fetch(`/api/workflows/steps/${step.id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ step_name: stepName, completion_rule: completionRule })
    })

    if (res.ok) {
      setEditing(false)
      onUpdate()
    }
  }

  const addAgent = async () => {
    if (!selectedRule) return

    const res = await fetch('/api/workflows/step-agents', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        workflow_step_id: step.id,
        agent_rule_code: selectedRule
      })
    })

    if (res.ok) {
      onUpdate()
    }
  }

  return (
    <div className="border rounded-lg p-4 space-y-4">
      <div className="flex items-center justify-between">
        <div className="flex-1">
          <h3 className="font-semibold">Step {step.step_sequence}</h3>
          {editing ? (
            <input 
              value={stepName} 
              onChange={e => setStepName(e.target.value)}
              className="border rounded px-2 py-1 w-full mt-1"
            />
          ) : (
            <p>{step.step_name}</p>
          )}
        </div>
        <button 
          onClick={() => editing ? updateStep() : setEditing(true)}
          className="bg-gray-600 text-white px-3 py-1 rounded hover:bg-gray-700"
        >
          {editing ? 'Save' : 'Edit'}
        </button>
      </div>

      <div>
        <label className="block text-sm font-medium mb-1">Completion Rule</label>
        {editing ? (
          <select 
            value={completionRule} 
            onChange={e => setCompletionRule(e.target.value)}
            className="border rounded px-2 py-1 w-full"
          >
            <option value="ANY">Any</option>
            <option value="ALL">All</option>
            <option value="MIN_N">Minimum N</option>
          </select>
        ) : (
          <p className="text-sm text-gray-600">{completionRule}</p>
        )}
      </div>

      <div>
        <label className="block text-sm font-medium mb-1">Agent Rules</label>
        <div className="space-y-2 mb-2">
          {step.step_agents?.map(sa => (
            <div key={sa.id} className="text-sm bg-gray-100 p-2 rounded">
              {sa.agent_rules?.rule_name} ({sa.agent_rules?.rule_type})
            </div>
          ))}
        </div>
        <div className="flex gap-2">
          <select 
            value={selectedRule} 
            onChange={e => setSelectedRule(e.target.value)}
            className="border rounded px-2 py-1 flex-1"
          >
            <option value="">Add agent rule</option>
            {agentRules.map(rule => (
              <option key={rule.rule_code} value={rule.rule_code}>
                {rule.rule_name}
              </option>
            ))}
          </select>
          <button 
            onClick={addAgent}
            className="bg-green-600 text-white px-3 py-1 rounded hover:bg-green-700"
          >
            Add
          </button>
        </div>
      </div>
    </div>
  )
}
