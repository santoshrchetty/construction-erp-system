'use client'

import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'

interface User {
  id: string
  email: string
  first_name: string | null
  last_name: string | null
  employee_code: string | null
  roles: { id: string; name: string } | null
}

interface Role {
  id: string
  name: string
  description: string
}

export default function UserRoleAssignmentTile() {
  const [users, setUsers] = useState<User[]>([])
  const [roles, setRoles] = useState<Role[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedUser, setSelectedUser] = useState<User | null>(null)
  const [showAssignForm, setShowAssignForm] = useState(false)

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    try {
      const [usersRes, rolesRes] = await Promise.all([
        fetch('/api/administration?action=user-management'),
        fetch('/api/administration?action=roles')
      ])

      const [usersData, rolesData] = await Promise.all([
        usersRes.json(),
        rolesRes.json()
      ])

      if (usersData.success) setUsers(usersData.data)
      if (rolesData.success) setRoles(rolesData.data)
    } catch (error) {
      console.error('Error loading data:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleAssignRole = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    if (!selectedUser) return

    const formData = new FormData(e.currentTarget)
    const roleId = formData.get('role_id') as string
    
    try {
      const response = await fetch(`/api/administration?action=assign-role`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          user_id: selectedUser.id,
          role_id: roleId
        })
      })
      
      const result = await response.json()
      if (result.success) {
        setShowAssignForm(false)
        setSelectedUser(null)
        loadData()
      } else {
        alert(result.error)
      }
    } catch (error) {
      alert('Error assigning role')
    }
  }

  const handleRemoveRole = async (userId: string) => {
    if (confirm('Are you sure you want to remove this user\'s role?')) {
      try {
        const response = await fetch(`/api/administration?action=remove-role`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ user_id: userId })
        })
        
        const result = await response.json()
        if (result.success) {
          loadData()
        } else {
          alert(result.error)
        }
      } catch (error) {
        alert('Error removing role')
      }
    }
  }

  const openAssignForm = (user: User) => {
    setSelectedUser(user)
    setShowAssignForm(true)
  }

  if (loading) return <div className="p-6">Loading user role assignments...</div>

  return (
    <div className="p-6">
      <div className="mb-6">
        <p className="text-gray-600">Assign and manage user roles and permissions</p>
      </div>

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">User</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Current Role</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {users.map((user) => (
              <tr key={user.id}>
                <td className="px-4 py-3">
                  <div>
                    <div className="font-medium">{user.first_name} {user.last_name}</div>
                    <div className="text-sm text-gray-500">{user.email}</div>
                    {user.employee_code && (
                      <div className="text-xs text-gray-400">ID: {user.employee_code}</div>
                    )}
                  </div>
                </td>
                <td className="px-4 py-3">
                  {user.roles ? (
                    <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800">
                      {user.roles.name}
                    </span>
                  ) : (
                    <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-gray-100 text-gray-800">
                      No Role Assigned
                    </span>
                  )}
                </td>
                <td className="px-4 py-3">
                  <div className="flex space-x-2">
                    <button
                      onClick={() => openAssignForm(user)}
                      className="text-blue-600 hover:text-blue-800 text-sm"
                    >
                      {user.roles ? 'Change Role' : 'Assign Role'}
                    </button>
                    {user.roles && (
                      <button
                        onClick={() => handleRemoveRole(user.id)}
                        className="text-red-600 hover:text-red-800 text-sm"
                      >
                        Remove Role
                      </button>
                    )}
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Role Assignment Modal */}
      {showAssignForm && selectedUser && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-bold mb-4">
              Assign Role to {selectedUser.first_name} {selectedUser.last_name}
            </h3>
            <form onSubmit={handleAssignRole} className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1">Select Role</label>
                <select name="role_id" required className="w-full border rounded px-3 py-2">
                  <option value="">Choose a role...</option>
                  {roles.map((role) => (
                    <option key={role.id} value={role.id}>
                      {role.name} - {role.description}
                    </option>
                  ))}
                </select>
              </div>
              <div className="bg-gray-50 p-3 rounded">
                <p className="text-sm text-gray-600">
                  <strong>Current Role:</strong> {selectedUser.roles?.name || 'None'}
                </p>
              </div>
              <div className="flex justify-end space-x-3">
                <button 
                  type="button" 
                  onClick={() => {
                    setShowAssignForm(false)
                    setSelectedUser(null)
                  }} 
                  className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button 
                  type="submit" 
                  className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
                >
                  Assign Role
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Summary Stats */}
      <div className="mt-6 grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-white p-4 rounded-lg shadow">
          <div className="text-2xl font-bold text-blue-600">{users.length}</div>
          <div className="text-sm text-gray-600">Total Users</div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow">
          <div className="text-2xl font-bold text-green-600">
            {users.filter(u => u.roles).length}
          </div>
          <div className="text-sm text-gray-600">Users with Roles</div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow">
          <div className="text-2xl font-bold text-orange-600">
            {users.filter(u => !u.roles).length}
          </div>
          <div className="text-sm text-gray-600">Unassigned Users</div>
        </div>
      </div>
    </div>
  )
}