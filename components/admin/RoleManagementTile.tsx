'use client'

import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'

interface AuthObject {
  id: string
  object_name: string
  description: string
  module: string
  fields: AuthField[]
}

interface AuthField {
  id: string
  field_name: string
  field_description: string
  field_values: string[]
}

interface Role {
  id: string
  name: string
  description: string
}

export default function RoleManagementTile() {
  const [roles, setRoles] = useState<Role[]>([])
  const [authObjects, setAuthObjects] = useState<AuthObject[]>([])
  const [selectedRole, setSelectedRole] = useState<Role | null>(null)
  const [showCreateRole, setShowCreateRole] = useState(false)
  const [expandedModules, setExpandedModules] = useState<Set<string>>(new Set())
  const [selectedAuthObjects, setSelectedAuthObjects] = useState<Set<string>>(new Set())
  const [authFieldValues, setAuthFieldValues] = useState<{[key: string]: {[key: string]: string[]}}>({})

  const [newRole, setNewRole] = useState({
    name: '',
    description: ''
  })

  useEffect(() => {
    fetchRoles()
    fetchAuthObjects()
  }, [])

  const fetchRoles = async () => {
    try {
      const response = await fetch('/api/admin?action=roles')
      const data = await response.json()
      if (data.roles) setRoles(data.roles)
    } catch (error) {
      console.error('Failed to fetch roles:', error)
    }
  }

  const fetchAuthObjects = async () => {
    try {
      const response = await fetch('/api/admin?action=auth-objects')
      const data = await response.json()
      if (data.authObjects) setAuthObjects(data.authObjects)
    } catch (error) {
      console.error('Failed to fetch auth objects:', error)
    }
  }

  const fetchRoleAuthorizations = async (roleName: string) => {
    try {
      const response = await fetch(`/api/admin?action=role-authorizations&roleName=${roleName}`)
      const data = await response.json()
      if (data.authorizations) {
        const selected = new Set<string>(data.authorizations.map((item: any) => item.auth_object_name))
        setSelectedAuthObjects(selected)
        
        const fieldValues: {[key: string]: {[key: string]: string[]}} = {}
        data.authorizations.forEach((item: any) => {
          fieldValues[item.auth_object_name] = item.field_values || {}
        })
        setAuthFieldValues(fieldValues)
      }
    } catch (error) {
      console.error('Failed to fetch role authorizations:', error)
    }
  }

  const handleRoleSelect = (role: Role) => {
    setSelectedRole(role)
    fetchRoleAuthorizations(role.name)
  }

  const handleCreateRole = async (e: React.FormEvent) => {
    e.preventDefault()
    
    try {
      const response = await fetch('/api/admin', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'create-role',
          name: newRole.name,
          description: newRole.description
        })
      })

      if (response.ok) {
        setNewRole({ name: '', description: '' })
        setShowCreateRole(false)
        fetchRoles()
      }
    } catch (error) {
      console.error('Error creating role:', error)
    }
  }

  const saveRoleAuthorizations = async () => {
    if (!selectedRole) return

    try {
      const authorizations = Array.from(selectedAuthObjects).map(objectName => ({
        auth_object_name: objectName,
        field_values: authFieldValues[objectName] || {}
      }))

      const response = await fetch('/api/admin', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'save-authorizations',
          roleName: selectedRole.name,
          authorizations
        })
      })

      if (response.ok) {
        alert('Role authorizations saved successfully!')
      }
    } catch (error) {
      console.error('Error saving role authorizations:', error)
    }
  }

  const toggleAuthObject = (objectName: string) => {
    const newSelected = new Set(selectedAuthObjects)
    if (newSelected.has(objectName)) {
      newSelected.delete(objectName)
      const newFieldValues = { ...authFieldValues }
      delete newFieldValues[objectName]
      setAuthFieldValues(newFieldValues)
    } else {
      newSelected.add(objectName)
      const authObj = authObjects.find(obj => obj.object_name === objectName)
      if (authObj && authObj.fields.length > 0) {
        const newFieldValues = { ...authFieldValues }
        newFieldValues[objectName] = {}
        authObj.fields.forEach(field => {
          newFieldValues[objectName][field.field_name] = [...field.field_values]
        })
        setAuthFieldValues(newFieldValues)
      }
    }
    setSelectedAuthObjects(newSelected)
  }

  const groupedAuthObjects = authObjects.reduce((acc, obj) => {
    if (!acc[obj.module]) {
      acc[obj.module] = []
    }
    acc[obj.module].push(obj)
    return acc
  }, {} as {[key: string]: AuthObject[]})

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <p className="text-gray-600">Create roles and assign authorization objects</p>
        </div>
        <button
          onClick={() => setShowCreateRole(true)}
          className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 flex items-center"
        >
          <Icons.Plus className="w-4 h-4 mr-2" />
          Create Role
        </button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="bg-white rounded-lg shadow p-4">
          <h3 className="text-lg font-semibold mb-4">Roles</h3>
          <div className="space-y-2">
            {roles.map((role) => (
              <div
                key={role.id}
                onClick={() => handleRoleSelect(role)}
                className={`p-3 rounded cursor-pointer transition-colors ${
                  selectedRole?.id === role.id
                    ? 'bg-blue-100 border-blue-300 border'
                    : 'bg-gray-50 hover:bg-gray-100'
                }`}
              >
                <div className="font-medium">{role.name}</div>
                <div className="text-sm text-gray-600">{role.description}</div>
              </div>
            ))}
          </div>
        </div>

        <div className="lg:col-span-2 bg-white rounded-lg shadow p-4">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-lg font-semibold">
              Authorization Objects
              {selectedRole && <span className="text-blue-600"> - {selectedRole.name}</span>}
            </h3>
            {selectedRole && (
              <button
                onClick={saveRoleAuthorizations}
                className="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700"
              >
                Save Authorizations
              </button>
            )}
          </div>

          {!selectedRole ? (
            <div className="text-center py-12 text-gray-500">
              Select a role to manage its authorization objects
            </div>
          ) : (
            <div className="space-y-4">
              {Object.entries(groupedAuthObjects).map(([module, objects]) => (
                <div key={module} className="border rounded">
                  <div className="p-3 bg-gray-50">
                    <span className="font-medium">{module.toUpperCase()}</span>
                  </div>
                  <div className="p-3 space-y-3">
                    {objects.map((authObj) => (
                      <div key={authObj.id} className="flex items-start space-x-3">
                        <input
                          type="checkbox"
                          checked={selectedAuthObjects.has(authObj.object_name)}
                          onChange={() => toggleAuthObject(authObj.object_name)}
                          className="mt-1"
                        />
                        <div className="flex-1">
                          <div className="font-medium text-sm">{authObj.object_name}</div>
                          <div className="text-xs text-gray-600">{authObj.description}</div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {showCreateRole && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-bold mb-4">Create New Role</h3>
            <form onSubmit={handleCreateRole} className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1">Role Name</label>
                <input
                  type="text"
                  value={newRole.name}
                  onChange={(e) => setNewRole({...newRole, name: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Description</label>
                <textarea
                  value={newRole.description}
                  onChange={(e) => setNewRole({...newRole, description: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                  rows={3}
                />
              </div>
              <div className="flex justify-end space-x-3">
                <button
                  type="button"
                  onClick={() => setShowCreateRole(false)}
                  className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
                >
                  Create Role
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}