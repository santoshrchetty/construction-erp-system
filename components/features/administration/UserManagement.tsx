'use client'

import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'

interface User {
  id: string
  email: string
  first_name: string | null
  last_name: string | null
  employee_code: string | null
  department: string | null
  is_active: boolean
  created_at: string
  roles: { id: string; name: string; description: string } | null
}

interface Role {
  id: string
  name: string
  description: string
}

export default function UserManagementTile() {
  const [users, setUsers] = useState<User[]>([])
  const [roles, setRoles] = useState<Role[]>([])
  const [loading, setLoading] = useState(true)
  const [showCreateForm, setShowCreateForm] = useState(false)
  const [editingUser, setEditingUser] = useState<User | null>(null)

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
      alert(error.message || 'Failed to load user data')
    } finally {
      setLoading(false)
    }
  }

  const handleCreateUser = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    
    try {
      const formData = new FormData(e.currentTarget)
      const userData = {
        email: formData.get('email') as string,
        password: formData.get('password') as string,
        first_name: formData.get('first_name') as string,
        last_name: formData.get('last_name') as string,
        employee_code: formData.get('employee_code') as string,
        department: formData.get('department') as string,
        role_id: formData.get('role_id') as string
      }
      
      const response = await fetch('/api/administration?action=create-user', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(userData)
      })
      
      const result = await response.json()
      if (result.success) {
        setShowCreateForm(false)
        loadData()
      } else {
        alert(result.error)
      }
    } catch (error) {
      alert('Error creating user')
    }
  }

  const handleUpdateUser = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    if (!editingUser) return

    try {
      const formData = new FormData(e.currentTarget)
      const userData = {
        first_name: formData.get('first_name') as string,
        last_name: formData.get('last_name') as string,
        employee_code: formData.get('employee_code') as string,
        department: formData.get('department') as string,
        role_id: formData.get('role_id') as string,
        is_active: formData.get('is_active') === 'true'
      }
      
      const response = await fetch(`/api/administration?action=update-user&id=${editingUser.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(userData)
      })
      
      const result = await response.json()
      if (result.success) {
        setEditingUser(null)
        loadData()
      } else {
        alert(result.error)
      }
    } catch (error) {
      alert('Error updating user')
    }
  }

  const handleDeactivateUser = async (userId: string) => {
    if (confirm('Are you sure you want to deactivate this user?')) {
      try {
        const response = await fetch(`/api/administration?action=deactivate-user&id=${userId}`, {
          method: 'DELETE'
        })
        
        const result = await response.json()
        if (result.success) {
          loadData()
        } else {
          alert(result.error)
        }
      } catch (error) {
        alert('Error deactivating user')
      }
    }
  }

  if (loading) return <div className="p-6">Loading users...</div>

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <p className="text-gray-600">Create, modify, and manage system users</p>
        </div>
        <button
          onClick={() => setShowCreateForm(true)}
          className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 flex items-center"
        >
          <Icons.Plus className="w-4 h-4 mr-2" />
          Add User
        </button>
      </div>

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">User</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Role</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Department</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
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
                  <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800">
                    {user.roles?.name || 'No Role'}
                  </span>
                </td>
                <td className="px-4 py-3 text-sm">{user.department || '-'}</td>
                <td className="px-4 py-3">
                  <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                    user.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                  }`}>
                    {user.is_active ? 'Active' : 'Inactive'}
                  </span>
                </td>
                <td className="px-4 py-3">
                  <div className="flex space-x-2">
                    <button
                      onClick={() => setEditingUser(user)}
                      className="text-blue-600 hover:text-blue-800 text-sm"
                    >
                      Edit
                    </button>
                    {user.is_active && (
                      <button
                        onClick={() => handleDeactivateUser(user.id)}
                        className="text-red-600 hover:text-red-800 text-sm"
                      >
                        Deactivate
                      </button>
                    )}
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Create User Modal */}
      {showCreateForm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-bold mb-4">Create New User</h3>
            <form onSubmit={handleCreateUser} className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1">Email</label>
                <input type="email" name="email" required className="w-full border rounded px-3 py-2" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Password</label>
                <input type="password" name="password" required className="w-full border rounded px-3 py-2" />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">First Name</label>
                  <input type="text" name="first_name" className="w-full border rounded px-3 py-2" />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Last Name</label>
                  <input type="text" name="last_name" className="w-full border rounded px-3 py-2" />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Employee Code</label>
                <input type="text" name="employee_code" className="w-full border rounded px-3 py-2" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Department</label>
                <input type="text" name="department" className="w-full border rounded px-3 py-2" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Role</label>
                <select name="role_id" required className="w-full border rounded px-3 py-2">
                  <option value="">Select Role</option>
                  {roles.map((role) => (
                    <option key={role.id} value={role.id}>{role.name}</option>
                  ))}
                </select>
              </div>
              <div className="flex justify-end space-x-3">
                <button type="button" onClick={() => setShowCreateForm(false)} className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50">Cancel</button>
                <button type="submit" className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">Create User</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Edit User Modal */}
      {editingUser && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-bold mb-4">Edit User</h3>
            <form onSubmit={handleUpdateUser} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">First Name</label>
                  <input type="text" name="first_name" defaultValue={editingUser.first_name || ''} className="w-full border rounded px-3 py-2" />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Last Name</label>
                  <input type="text" name="last_name" defaultValue={editingUser.last_name || ''} className="w-full border rounded px-3 py-2" />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Employee Code</label>
                <input type="text" name="employee_code" defaultValue={editingUser.employee_code || ''} className="w-full border rounded px-3 py-2" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Department</label>
                <input type="text" name="department" defaultValue={editingUser.department || ''} className="w-full border rounded px-3 py-2" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Role</label>
                <select name="role_id" defaultValue={editingUser.roles?.id || ''} className="w-full border rounded px-3 py-2">
                  <option value="">Select Role</option>
                  {roles.map((role) => (
                    <option key={role.id} value={role.id}>{role.name}</option>
                  ))}
                </select>
              </div>
              <div>
                <label className="flex items-center">
                  <input type="checkbox" name="is_active" value="true" defaultChecked={editingUser.is_active} className="mr-2" />
                  Active User
                </label>
              </div>
              <div className="flex justify-end space-x-3">
                <button type="button" onClick={() => setEditingUser(null)} className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50">Cancel</button>
                <button type="submit" className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">Update User</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}