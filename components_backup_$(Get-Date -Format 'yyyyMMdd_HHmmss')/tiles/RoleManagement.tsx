'use client'

import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'

interface Role {
  id: string
  name: string
  description: string
  created_at?: string
}

export default function RoleManagementTile() {
  const [roles, setRoles] = useState<Role[]>([])
  const [loading, setLoading] = useState(true)
  const [showCreateForm, setShowCreateForm] = useState(false)
  const [editingRole, setEditingRole] = useState<Role | null>(null)

  useEffect(() => {
    loadRoles()
  }, [])

  const loadRoles = async () => {
    try {
      const response = await fetch('/api/administration?action=roles')
      const data = await response.json()
      
      if (data.success) {
        setRoles(data.data)
      }
    } catch (error) {
      console.error('Error loading roles:', error)
      alert(error.message || 'Failed to load roles')
    } finally {
      setLoading(false)
    }
  }

  const handleCreateRole = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    
    try {
      const formData = new FormData(e.currentTarget)
      const roleData = {
        name: formData.get('name') as string,
        description: formData.get('description') as string
      }
      
      const response = await fetch('/api/administration?action=create-role', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(roleData)
      })
      
      const result = await response.json()
      if (result.success) {
        setShowCreateForm(false)
        loadRoles()
      } else {
        alert(result.error)
      }
    } catch (error) {
      alert('Error creating role')
    }
  }

  const handleUpdateRole = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    if (!editingRole) return

    const formData = new FormData(e.currentTarget)
    const roleData = {
      name: formData.get('name') as string,
      description: formData.get('description') as string
    }
    
    try {
      const response = await fetch(`/api/administration?action=update-role&id=${editingRole.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(roleData)
      })
      
      const result = await response.json()
      if (result.success) {
        setEditingRole(null)
        loadRoles()
      } else {
        alert(result.error)
      }
    } catch (error) {
      alert('Error updating role')
    }
  }

  const handleDeleteRole = async (roleId: string) => {
    if (confirm('Are you sure you want to delete this role?')) {
      try {
        const response = await fetch(`/api/administration?action=delete-role&id=${roleId}`, {
          method: 'DELETE'
        })
        
        const result = await response.json()
        if (result.success) {
          loadRoles()
        } else {
          alert(result.error)
        }
      } catch (error) {
        alert('Error deleting role')
      }
    }
  }

  if (loading) return <div className="p-6">Loading roles...</div>

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <p className="text-gray-600">Create and manage user roles and permissions</p>
        </div>
        <button
          onClick={() => setShowCreateForm(true)}
          className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 flex items-center"
        >
          <Icons.Plus className="w-4 h-4 mr-2" />
          Add Role
        </button>
      </div>

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Role Name</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Description</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {roles.map((role) => (
              <tr key={role.id}>
                <td className="px-4 py-3">
                  <div className="font-medium">{role.name}</div>
                </td>
                <td className="px-4 py-3 text-sm text-gray-600">{role.description}</td>
                <td className="px-4 py-3">
                  <div className="flex space-x-2">
                    <button
                      onClick={() => setEditingRole(role)}
                      className="text-blue-600 hover:text-blue-800 text-sm"
                    >
                      Edit
                    </button>
                    <button
                      onClick={() => handleDeleteRole(role.id)}
                      className="text-red-600 hover:text-red-800 text-sm"
                    >
                      Delete
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Create Role Modal */}
      {showCreateForm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-bold mb-4">Create New Role</h3>
            <form onSubmit={handleCreateRole} className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1">Role Name</label>
                <input type="text" name="name" required className="w-full border rounded px-3 py-2" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Description</label>
                <textarea name="description" rows={3} className="w-full border rounded px-3 py-2"></textarea>
              </div>
              <div className="flex justify-end space-x-3">
                <button type="button" onClick={() => setShowCreateForm(false)} className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50">Cancel</button>
                <button type="submit" className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">Create Role</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Edit Role Modal */}
      {editingRole && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-bold mb-4">Edit Role</h3>
            <form onSubmit={handleUpdateRole} className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1">Role Name</label>
                <input type="text" name="name" defaultValue={editingRole.name} required className="w-full border rounded px-3 py-2" />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Description</label>
                <textarea name="description" defaultValue={editingRole.description} rows={3} className="w-full border rounded px-3 py-2"></textarea>
              </div>
              <div className="flex justify-end space-x-3">
                <button type="button" onClick={() => setEditingRole(null)} className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50">Cancel</button>
                <button type="submit" className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">Update Role</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}