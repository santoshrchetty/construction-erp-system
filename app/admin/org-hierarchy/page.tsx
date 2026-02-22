'use client'
import { useState, useEffect } from 'react'

export default function OrgHierarchyPage() {
  const [employees, setEmployees] = useState([])
  const [filter, setFilter] = useState('')

  useEffect(() => {
    loadEmployees()
  }, [])

  const loadEmployees = async () => {
    const res = await fetch('/api/org-hierarchy')
    const data = await res.json()
    setEmployees(data)
  }

  const filteredEmployees = employees.filter(emp =>
    emp.employee_name?.toLowerCase().includes(filter.toLowerCase()) ||
    emp.department_code?.toLowerCase().includes(filter.toLowerCase())
  )

  return (
    <div className="p-8 space-y-6">
      <h1 className="text-3xl font-bold">Organizational Hierarchy</h1>

      <div className="bg-white rounded-lg shadow p-4">
        <input
          type="text"
          placeholder="Search by name or department..."
          value={filter}
          onChange={e => setFilter(e.target.value)}
          className="w-full border rounded px-3 py-2"
        />
      </div>

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Employee</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Position</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Department</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Manager</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {filteredEmployees.map(emp => {
              const manager = employees.find(e => e.employee_id === emp.manager_id)
              return (
                <tr key={emp.employee_id}>
                  <td className="px-6 py-4 whitespace-nowrap font-medium">{emp.employee_name}</td>
                  <td className="px-6 py-4 whitespace-nowrap">{emp.position_title}</td>
                  <td className="px-6 py-4 whitespace-nowrap">{emp.department_code}</td>
                  <td className="px-6 py-4 whitespace-nowrap">{manager?.employee_name || '-'}</td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>
    </div>
  )
}
