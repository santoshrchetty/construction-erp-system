'use client'
import { useState, useEffect } from 'react'

export default function RoleAssignmentsPage() {
  const [assignments, setAssignments] = useState([])
  const [employees, setEmployees] = useState([])
  const [showForm, setShowForm] = useState(false)
  const [formData, setFormData] = useState({
    employee_id: '',
    role_code: '',
    scope_type: 'DEPARTMENT',
    scope_value: ''
  })

  useEffect(() => {
    loadAssignments()
    loadEmployees()
  }, [])

  const loadAssignments = async () => {
    const res = await fetch('/api/role-assignments')
    const data = await res.json()
    setAssignments(data)
  }

  const loadEmployees = async () => {
    const res = await fetch('/api/org-hierarchy')
    const data = await res.json()
    setEmployees(data)
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    const res = await fetch('/api/role-assignments', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        ...formData,
        tenant_id: '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
      })
    })

    if (res.ok) {
      setShowForm(false)
      setFormData({ employee_id: '', role_code: '', scope_type: 'DEPARTMENT', scope_value: '' })
      loadAssignments()
    }
  }

  const handleDelete = async (id) => {
    if (!confirm('Delete this role assignment?')) return
    const res = await fetch(`/api/role-assignments?id=${id}`, { method: 'DELETE' })
    if (res.ok) loadAssignments()
  }

  return (
    <div className="p-8 space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold">Role Assignments</h1>
        <button
          onClick={() => setShowForm(!showForm)}
          className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
        >
          {showForm ? 'Cancel' : 'Add Assignment'}
        </button>
      </div>

      {showForm && (
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-xl font-semibold mb-4">New Role Assignment</h2>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-1">Employee</label>
              <select
                value={formData.employee_id}
                onChange={e => setFormData({ ...formData, employee_id: e.target.value })}
                className="w-full border rounded px-3 py-2"
                required
              >
                <option value="">Select employee</option>
                {employees.map(emp => (
                  <option key={emp.employee_id} value={emp.employee_id}>
                    {emp.employee_name} - {emp.position_title}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium mb-1">Role</label>
              <select
                value={formData.role_code}
                onChange={e => setFormData({ ...formData, role_code: e.target.value })}
                className="w-full border rounded px-3 py-2"
                required
              >
                <option value="">Select role</option>
                <option value="DEPT_HEAD">Department Head</option>
                <option value="APPROVER">Approver</option>
                <option value="REVIEWER">Reviewer</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium mb-1">Scope Type</label>
              <select
                value={formData.scope_type}
                onChange={e => setFormData({ ...formData, scope_type: e.target.value })}
                className="w-full border rounded px-3 py-2"
              >
                <option value="DEPARTMENT">Department</option>
                <option value="PLANT">Plant</option>
                <option value="COMPANY">Company</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium mb-1">Scope Value</label>
              <input
                type="text"
                value={formData.scope_value}
                onChange={e => setFormData({ ...formData, scope_value: e.target.value })}
                placeholder="e.g., ENG, P001"
                className="w-full border rounded px-3 py-2"
                required
              />
            </div>

            <button
              type="submit"
              className="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700"
            >
              Create Assignment
            </button>
          </form>
        </div>
      )}

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Employee</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Role</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Scope</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {assignments.map(assignment => (
              <tr key={assignment.id}>
                <td className="px-6 py-4 whitespace-nowrap">
                  {assignment.org_hierarchy?.employee_name || 'Unknown'}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">{assignment.role_code}</td>
                <td className="px-6 py-4 whitespace-nowrap">
                  {assignment.scope_type}: {assignment.scope_value}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <button
                    onClick={() => handleDelete(assignment.id)}
                    className="text-red-600 hover:text-red-800"
                  >
                    Delete
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
