'use client'

import React, { useState, useEffect, useMemo } from 'react'
import { Plus, Edit, Trash2, Shield, Save, X, ChevronDown, ChevronRight, Settings, Users, User, Folder, MoreVertical, Copy, Tag } from 'lucide-react'
import * as Icons from 'lucide-react'

interface AuthObject {
  id: string
  object_name: string
  description: string
  module: string
  is_active: boolean
  fields?: AuthField[]
}

interface AuthField {
  id: string
  field_code: string
  is_required: boolean
}

interface RoleAuth {
  id: string
  role_id: string
  role_name: string
  auth_object_id: string
  field_values: Record<string, string[]>
  valid_from: string
  valid_to?: string
  is_active: boolean
  module_full_access?: boolean
  object_full_access?: boolean
  inherited_from?: 'module' | 'object'
}

export default function AuthorizationObjects() {
  const [objects, setObjects] = useState<AuthObject[]>([])
  const [roleAuths, setRoleAuths] = useState<RoleAuth[]>([])
  const [roles, setRoles] = useState<{id: string, name: string}[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [activeTab, setActiveTab] = useState<'objects' | 'fields' | 'assignments'>('objects')
  const [expandedModules, setExpandedModules] = useState<Set<string>>(new Set())
  const [expandedObjects, setExpandedObjects] = useState<Set<string>>(new Set())
  const [expandedRoles, setExpandedRoles] = useState<Set<string>>(new Set())
  const [expandedAssignments, setExpandedAssignments] = useState<Set<string>>(new Set())
  const [selectedObjects, setSelectedObjects] = useState<Set<string>>(new Set())
  const [bulkAssignMode, setBulkAssignMode] = useState(false)
  const [groupByRole, setGroupByRole] = useState(true)
  const [selectedRole, setSelectedRole] = useState<string>('')
  const [selectedModuleObjects, setSelectedModuleObjects] = useState<Record<string, Set<string>>>({})
  const [fieldSelections, setFieldSelections] = useState<Record<string, Record<string, string[]>>>({})
  const [isMobile, setIsMobile] = useState(false)
  const [availableFieldNames, setAvailableFieldNames] = useState<Array<{value: string, label: string, category: string}>>([])
  
  // Form states
  const [showObjectForm, setShowObjectForm] = useState(false)
  const [showFieldForm, setShowFieldForm] = useState(false)
  const [editingObject, setEditingObject] = useState<AuthObject | null>(null)
  const [editingField, setEditingField] = useState<AuthField | null>(null)
  const [selectedObjectId, setSelectedObjectId] = useState<string>('')

  const [objectForm, setObjectForm] = useState({
    object_name: '',
    description: '',
    module: '',
    is_active: true
  })

  const [fieldForm, setFieldForm] = useState({
    field_code: '',
    is_required: true
  })

  useEffect(() => {
    loadData()
    loadAvailableFieldNames()
  }, [])

  useEffect(() => {
    const checkMobile = () => setIsMobile(window.innerWidth < 768)
    checkMobile()
    window.addEventListener('resize', checkMobile)
    return () => window.removeEventListener('resize', checkMobile)
  }, [])

  const loadAvailableFieldNames = async () => {
    try {
      // Static activity field
      const fields = [
        { value: 'ACTVT', label: 'ACTVT - Activity', category: 'Activity' }
      ]
      
      // Fetch organizational fields from their respective tables
      const orgFields = [
        { field: 'COMP_CODE', table: 'company_codes', col: 'company_code', name: 'Company Code' },
        { field: 'PLANT', table: 'plants', col: 'plant_code', name: 'Plant' },
        { field: 'DEPT', table: 'departments', col: 'dept_code', name: 'Department' },
        { field: 'STORAGE_LOC', table: 'storage_locations', col: 'sloc_code', name: 'Storage Location' },
        { field: 'COST_CENTER', table: 'cost_centers', col: 'cost_center_code', name: 'Cost Center' },
        { field: 'PURCH_ORG', table: 'purchasing_organizations', col: 'porg_code', name: 'Purchasing Organization' }
      ]
      
      for (const orgField of orgFields) {
        fields.push({
          value: orgField.field,
          label: `${orgField.field} - ${orgField.name}`,
          category: 'Organizational'
        })
      }
      
      // Project types from projects table
      fields.push(
        { value: 'PROJ_TYPE', label: 'PROJ_TYPE - Project Type', category: 'Organizational' },
        { value: 'MR_TYPE', label: 'MR_TYPE - Material Request Type', category: 'Organizational' },
        { value: 'PR_TYPE', label: 'PR_TYPE - Purchase Requisition Type', category: 'Organizational' },
        { value: 'MAT_TYPE', label: 'MAT_TYPE - Material Type', category: 'Organizational' }
      )
      
      // Static business fields
      fields.push(
        { value: 'PO_TYPE', label: 'PO_TYPE - Purchase Order Type', category: 'Business' },
        { value: 'PO_VALUE', label: 'PO_VALUE - PO Value Limit', category: 'Business' },
        { value: 'GL_ACCT', label: 'GL_ACCT - GL Account Range', category: 'Business' }
      )
      
      setAvailableFieldNames(fields)
    } catch (error) {
      console.error('Failed to load field names:', error)
    }
  }

  const loadData = async () => {
    try {
      console.log('Loading authorization objects...')
      const response = await fetch('/api/authorization-objects')
      const data = await response.json()
      
      console.log('API Response:', data)
      
      if (data.success) {
        setObjects(data.data.objects || [])
        setRoleAuths(data.data.roleAuths || [])
        setRoles(data.data.roles || [])
        console.log('Loaded objects:', data.data.objects?.length || 0)
        console.log('Loaded roleAuths:', data.data.roleAuths?.length || 0)
        console.log('Loaded roles:', data.data.roles?.length || 0)
        console.log('Sample object:', data.data.objects?.[0])
        console.log('Sample roleAuth:', data.data.roleAuths?.[0])
      } else {
        setError(data.error || 'Failed to load data')
        console.error('API Error:', data.error)
      }
    } catch (error) {
      console.error('Network error:', error)
      setError('Network error loading data')
    } finally {
      setLoading(false)
    }
  }

  // Get available modules from database data
  const availableModules = useMemo(() => {
    const modules = Array.from(new Set(objects.map(obj => obj.module).filter(Boolean)))
    return modules.sort()
  }, [objects])

  const getFieldDescription = (fieldName: string): string => {
    const descriptions: Record<string, string> = {
      'ACTVT': 'Activity',
      'COMP_CODE': 'Company Code',
      'PLANT': 'Plant',
      'STORAGE_LOC': 'Storage Location',
      'DEPT': 'Department',
      'COST_CENTER': 'Cost Center',
      'PURCH_ORG': 'Purchasing Organization',
      'PROJ_TYPE': 'Project Type',
      'MR_TYPE': 'Material Request Type',
      'PO_TYPE': 'Purchase Order Type',
      'PR_TYPE': 'Purchase Requisition Type',
      'MAT_TYPE': 'Material Type',
      'PO_VALUE': 'PO Value Limit',
      'GL_ACCT': 'GL Account Range'
    }
    return descriptions[fieldName] || fieldName
  }

  const getDefaultValues = (fieldName: string): string[] => {
    const defaults: Record<string, string[]> = {
      'ACTVT': ['01', '02', '03', '05', '06'],
      'COMP_CODE': ['*'],
      'PLANT': ['*'],
      'STORAGE_LOC': ['*'],
      'DEPT': ['*'],
      'COST_CENTER': ['*'],
      'PURCH_ORG': ['*'],
      'PROJ_TYPE': ['*'],
      'MR_TYPE': ['*'],
      'PO_TYPE': ['*'],
      'PR_TYPE': ['*'],
      'MAT_TYPE': ['*'],
      'PO_VALUE': ['*'],
      'GL_ACCT': ['*']
    }
    return defaults[fieldName] || ['*']
  }

  const handleCreateObject = async () => {
    try {
      const response = await fetch('/api/authorization-objects', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(objectForm)
      })
      
      const result = await response.json()
      if (result.success) {
        setShowObjectForm(false)
        resetObjectForm()
        loadData()
      } else {
        alert(result.error || 'Failed to create object')
      }
    } catch (error) {
      console.error('Failed to create object:', error)
      alert('Failed to create object')
    }
  }

  const handleEditObject = (obj: AuthObject) => {
    setEditingObject(obj)
    setObjectForm({
      object_name: obj.object_name,
      description: obj.description,
      module: obj.module,
      is_active: obj.is_active
    })
    setShowObjectForm(true)
  }

  const handleUpdateObject = async () => {
    if (!editingObject) return
    
    try {
      const response = await fetch('/api/authorization-objects', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: editingObject.id, ...objectForm })
      })
      
      const result = await response.json()
      if (result.success) {
        setShowObjectForm(false)
        setEditingObject(null)
        resetObjectForm()
        loadData()
      } else {
        alert(result.error || 'Failed to update object')
      }
    } catch (error) {
      console.error('Failed to update object:', error)
      alert('Failed to update object')
    }
  }

  const handleDeleteObject = async (obj: AuthObject) => {
    if (!confirm(`Delete authorization object ${obj.object_name}?`)) return
    
    try {
      const response = await fetch('/api/authorization-objects', {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: obj.id })
      })
      
      const result = await response.json()
      if (result.success) {
        loadData()
      } else {
        alert(result.error || 'Failed to delete object')
      }
    } catch (error) {
      console.error('Failed to delete object:', error)
      alert('Failed to delete object')
    }
  }

  const handleCreateField = async () => {
    if (!selectedObjectId) return
    
    try {
      const response = await fetch('/api/authorization-objects/fields', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          auth_object_id: selectedObjectId,
          ...fieldForm
        })
      })
      
      if (!response.ok) {
        const text = await response.text()
        console.error('API Error:', text)
        alert(`Failed to create field: ${response.status} ${response.statusText}`)
        return
      }
      
      const result = await response.json()
      if (result.success) {
        setShowFieldForm(false)
        setSelectedObjectId('')
        resetFieldForm()
        loadData()
      } else {
        alert(result.error || 'Failed to create field')
      }
    } catch (error) {
      console.error('Failed to create field:', error)
      alert('Failed to create field. Please restart the dev server.')
    }
  }

  const handleEditField = (field: AuthField) => {
    setEditingField(field)
    setFieldForm({
      field_code: field.field_code,
      is_required: field.is_required
    })
    setShowFieldForm(true)
  }

  const handleUpdateField = async () => {
    if (!editingField) return
    
    try {
      const response = await fetch('/api/authorization-objects/fields', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          id: editingField.id,
          ...fieldForm
        })
      })
      
      const result = await response.json()
      if (result.success) {
        setShowFieldForm(false)
        setEditingField(null)
        resetFieldForm()
        loadData()
      } else {
        alert(result.error || 'Failed to update field')
      }
    } catch (error) {
      console.error('Failed to update field:', error)
      alert('Failed to update field')
    }
  }

  const handleDeleteField = async (field: AuthField) => {
    if (!confirm(`Delete field ${field.field_code}?`)) return
    
    try {
      const response = await fetch('/api/authorization-objects/fields', {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: field.id })
      })
      
      const result = await response.json()
      if (result.success) {
        loadData()
      } else {
        alert(result.error || 'Failed to delete field')
      }
    } catch (error) {
      console.error('Failed to delete field:', error)
      alert('Failed to delete field')
    }
  }

  // Group objects by module
  const objectsByModule = useMemo(() => {
    const grouped = objects.reduce((acc, obj) => {
      if (!acc[obj.module]) acc[obj.module] = []
      acc[obj.module].push(obj)
      return acc
    }, {} as Record<string, AuthObject[]>)
    return grouped
  }, [objects])

  // Group fields by module
  const fieldsByModule = useMemo(() => {
    const grouped: Record<string, Array<{object: AuthObject, field: AuthField}>> = {}
    objects.forEach(obj => {
      if (obj.fields && obj.fields.length > 0) {
        if (!grouped[obj.module]) grouped[obj.module] = []
        obj.fields.forEach(field => {
          grouped[obj.module].push({ object: obj, field })
        })
      }
    })
    return grouped
  }, [objects])





  // Module assignment workflow states
  const [selectedRoleForAssignment, setSelectedRoleForAssignment] = useState<string>('')
  const [availableModulesForRole, setAvailableModulesForRole] = useState<string[]>([])
  const [selectedModulesForAssignment, setSelectedModulesForAssignment] = useState<Set<string>>(new Set())
  const [showModuleAssignmentModal, setShowModuleAssignmentModal] = useState(false)
  const [assignmentStep, setAssignmentStep] = useState<1 | 2>(1)
  const [selectedObjectsForAssignment, setSelectedObjectsForAssignment] = useState<Set<string>>(new Set())

  // Get unassigned modules for a role
  const getUnassignedModules = (roleName: string): string[] => {
    const assignedModules = new Set(Object.keys(roleAssignmentsByRole[roleName] || {}))
    return availableModules.filter(module => !assignedModules.has(module))
  }

  // Start module assignment workflow
  const startModuleAssignment = async (roleName: string) => {
    try {
      const response = await fetch(`/api/authorization-objects/available-modules?role=${encodeURIComponent(roleName)}`)
      const data = await response.json()
      
      if (data.success) {
        setSelectedRoleForAssignment(roleName)
        setAvailableModulesForRole(data.data.availableModules)
        setSelectedModulesForAssignment(new Set())
        setShowModuleAssignmentModal(true)
      } else {
        console.error('Failed to load available modules:', data.error)
      }
    } catch (error) {
      console.error('Error loading available modules:', error)
    }
  }

  // Toggle module selection in assignment modal
  const toggleModuleForAssignment = (module: string) => {
    const newSelected = new Set(selectedModulesForAssignment)
    if (newSelected.has(module)) {
      newSelected.delete(module)
    } else {
      newSelected.add(module)
    }
    setSelectedModulesForAssignment(newSelected)
  }

  // Select all available modules
  const selectAllAvailableModules = () => {
    setSelectedModulesForAssignment(new Set(availableModulesForRole))
  }

  // Toggle object selection
  const toggleObjectSelection = (objectId: string) => {
    const newSelected = new Set(selectedObjectsForAssignment)
    if (newSelected.has(objectId)) {
      newSelected.delete(objectId)
    } else {
      newSelected.add(objectId)
    }
    setSelectedObjectsForAssignment(newSelected)
  }

  // Select all objects in a module
  const selectAllInModule = (module: string) => {
    const newSelected = new Set(selectedObjectsForAssignment)
    const moduleObjects = objectsByModule[module] || []
    moduleObjects.forEach(obj => newSelected.add(obj.id))
    setSelectedObjectsForAssignment(newSelected)
  }

  // Deselect all objects in a module
  const deselectAllInModule = (module: string) => {
    const newSelected = new Set(selectedObjectsForAssignment)
    const moduleObjects = objectsByModule[module] || []
    moduleObjects.forEach(obj => newSelected.delete(obj.id))
    setSelectedObjectsForAssignment(newSelected)
  }

  // Proceed to object selection (Step 2)
  const proceedToObjectSelection = () => {
    if (selectedModulesForAssignment.size === 0) return
    
    // Pre-select all objects from selected modules
    const allObjectIds = new Set<string>()
    selectedModulesForAssignment.forEach(module => {
      const moduleObjects = objectsByModule[module] || []
      moduleObjects.forEach(obj => allObjectIds.add(obj.id))
    })
    setSelectedObjectsForAssignment(allObjectIds)
    setAssignmentStep(2)
  }

  // Assign selected objects to role
  const assignSelectedObjects = async () => {
    if (selectedObjectsForAssignment.size === 0) return

    try {
      setLoading(true)
      
      // Get role ID from role name
      const role = roles.find(r => r.name === selectedRoleForAssignment)
      if (!role) {
        alert('Role not found')
        return
      }
      
      const response = await fetch('/api/authorization-objects/bulk-assign', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          roleId: role.id,
          objectIds: Array.from(selectedObjectsForAssignment),
          template: 'full_access',
          cascadeLevel: 'object'
        })
      })
      
      if (response.ok) {
        setShowModuleAssignmentModal(false)
        setAssignmentStep(1)
        setSelectedModulesForAssignment(new Set())
        setSelectedObjectsForAssignment(new Set())
        alert(`Successfully assigned ${selectedObjectsForAssignment.size} objects to ${selectedRoleForAssignment}.`)
        loadData()
      } else {
        alert('Failed to assign objects. Please try again.')
      }
    } catch (error) {
      console.error('Failed to assign objects:', error)
      alert('Failed to assign objects. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  // Get available roles from the roles data, not just from roleAuths
  const availableRoles = useMemo(() => {
    if (!roles || roles.length === 0) return []
    return roles.map(role => ({
      name: role.name,
      assignmentCount: roleAuths.filter(auth => auth.role_id === role.id).length
    }))
  }, [roles, roleAuths])

  // Simplified role assignments - just show what we have
  const roleAssignmentsByRole = useMemo(() => {
    const grouped: Record<string, Record<string, RoleAuth[]>> = {}
    let unmatchedCount = 0
    
    roleAuths.forEach(auth => {
      if (!grouped[auth.role_name]) grouped[auth.role_name] = {}
      
      const authObject = objects.find(obj => obj.id === auth.auth_object_id)
      if (!authObject) {
        unmatchedCount++
        console.warn('No object found for auth_object_id:', auth.auth_object_id, 'role:', auth.role_name)
      }
      const module = authObject?.module || 'Unknown Module'
      
      if (!grouped[auth.role_name][module]) grouped[auth.role_name][module] = []
      grouped[auth.role_name][module].push(auth)
    })
    
    if (unmatchedCount > 0) {
      console.error(`${unmatchedCount} role assignments have no matching authorization object`)
    }
    
    return grouped
  }, [roleAuths, objects])

  const toggleModule = (module: string) => {
    const newExpanded = new Set(expandedModules)
    if (newExpanded.has(module)) {
      newExpanded.delete(module)
    } else {
      newExpanded.add(module)
    }
    setExpandedModules(newExpanded)
  }

  const toggleObject = (objectId: string) => {
    const newExpanded = new Set(expandedObjects)
    if (newExpanded.has(objectId)) {
      newExpanded.delete(objectId)
    } else {
      newExpanded.add(objectId)
    }
    setExpandedObjects(newExpanded)
  }

  const toggleRole = (roleName: string) => {
    const newExpanded = new Set(expandedRoles)
    if (newExpanded.has(roleName)) {
      newExpanded.delete(roleName)
    } else {
      newExpanded.add(roleName)
    }
    setExpandedRoles(newExpanded)
  }

  const toggleModuleSelection = (roleName: string, module: string, objects: AuthObject[]) => {
    const moduleKey = `${roleName}-${module}`
    const newSelected = { ...selectedModuleObjects }
    
    if (!newSelected[moduleKey]) {
      newSelected[moduleKey] = new Set()
    }
    
    const moduleObjectIds = objects.map(obj => obj.id)
    const currentSelected = newSelected[moduleKey]
    const allSelected = moduleObjectIds.every(id => currentSelected.has(id))
    
    if (allSelected) {
      // Deselect all
      moduleObjectIds.forEach(id => currentSelected.delete(id))
    } else {
      // Select all
      moduleObjectIds.forEach(id => currentSelected.add(id))
    }
    
    setSelectedModuleObjects(newSelected)
  }

  const toggleAssignment = (assignmentId: string) => {
    const newExpanded = new Set(expandedAssignments)
    if (newExpanded.has(assignmentId)) {
      newExpanded.delete(assignmentId)
    } else {
      newExpanded.add(assignmentId)
    }
    setExpandedAssignments(newExpanded)
  }

  const updateFieldSelection = (assignmentId: string, fieldName: string, selectedValues: string[]) => {
    setFieldSelections(prev => ({
      ...prev,
      [assignmentId]: {
        ...prev[assignmentId],
        [fieldName]: selectedValues
      }
    }))
  }

  // Check if module has full access
  const hasModuleFullAccess = (roleName: string, module: string): boolean => {
    const moduleAssignments = roleAssignmentsByRole[roleName]?.[module] || []
    return moduleAssignments.some(auth => auth.module_full_access)
  }

  // Check if object has full access (inherited or direct)
  const hasObjectFullAccess = (assignment: RoleAuth): boolean => {
    return assignment.module_full_access || assignment.object_full_access
  }

  // Get effective field values (considering cascading)
  const getEffectiveFieldValues = (assignment: RoleAuth, fieldName: string): string[] => {
    if (assignment.module_full_access || assignment.object_full_access) {
      // For inherited full access, always include '*' regardless of stored values
      const storedValues = assignment.field_values[fieldName] || []
      return storedValues.includes('*') ? storedValues : [...storedValues, '*']
    }
    return assignment.field_values[fieldName] || []
  }

  // Check if a field value should be checked (including inherited '*')
  const isFieldValueSelected = (assignment: RoleAuth, fieldName: string, value: string): boolean => {
    const effectiveValues = getEffectiveFieldValues(assignment, fieldName)
    const selectedValues = fieldSelections[assignment.id]?.[fieldName] || effectiveValues
    
    // If inherited full access and value is '*', always show as selected
    if ((assignment.module_full_access || assignment.object_full_access) && value === '*') {
      return true
    }
    
    return selectedValues.includes(value)
  }

  // Convert inherited assignment to custom template
  const convertToCustomTemplate = async (assignmentId: string) => {
    if (!confirm('📝 Convert to custom template?\n\nThis will:\n• Allow field editing\n• Remove inheritance\n• Create role-specific template')) return
    
    try {
      console.log('Converting assignment to custom:', assignmentId)
      const response = await fetch('/api/authorization-objects/convert-to-custom', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ assignmentId })
      })
      
      const result = await response.json()
      console.log('Convert response:', result)
      
      if (result.success) {
        alert('✅ Converted to custom template! You can now edit field values.')
        loadData()
      } else {
        console.error('Convert failed:', result.error)
        alert(`❌ Failed to convert: ${result.error}`)
      }
    } catch (error) {
      console.error('Convert to custom failed:', error)
      alert('❌ Network error. Please try again.')
    }
  }
  const handleModuleCascade = async (roleName: string, module: string, action: 'select_all' | 'reset_default' | 'clear_cascade' | 'remove_all') => {
    try {
      if (action === 'select_all') {
        // Grant full access to entire module with inheritance
        const moduleObjects = objectsByModule[module] || []
        const objectIds = moduleObjects.map(obj => obj.id)
        
        await fetch('/api/authorization-objects/bulk-assign', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            roleId: roleName,
            objectIds: objectIds,
            template: 'full_access',
            cascadeLevel: 'module',
            module: module
          })
        })
      } else if (action === 'reset_default') {
        // Assign all objects with default field values (no inheritance)
        const moduleObjects = objectsByModule[module] || []
        const objectIds = moduleObjects.map(obj => obj.id)
        
        await fetch('/api/authorization-objects/bulk-assign', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            roleId: roleName,
            objectIds: objectIds,
            template: 'default_access',
            cascadeLevel: 'object',
            module: module
          })
        })
      } else if (action === 'clear_cascade') {
        // Remove only inherited permissions, keep custom assignments
        await fetch('/api/authorization-objects/clear-cascade', {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            roleId: roleName,
            module: module
          })
        })
      } else if (action === 'remove_all') {
        // Complete removal (destructive)
        if (!confirm(`Remove ALL access for ${roleName} from ${module} module? This cannot be undone.`)) return
        
        await fetch('/api/authorization-objects/remove-module', {
          method: 'DELETE',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            roleId: roleName,
            module: module
          })
        })
      }
      loadData()
    } catch (error) {
      console.error('Module cascade failed:', error)
    }
  }

  const handleObjectToggle = async (roleName: string, objectId: string, isChecked: boolean) => {
    try {
      if (isChecked) {
        // Assign object with default field values
        await fetch('/api/authorization-objects/bulk-assign', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            roleId: roleName,
            objectIds: [objectId],
            template: 'default_access',
            cascadeLevel: 'object'
          })
        })
      } else {
        // Remove object assignment
        const assignment = roleAuths.find(auth => 
          auth.role_name === roleName && auth.auth_object_id === objectId
        )
        if (assignment) {
          await fetch('/api/authorization-objects/remove-assignment', {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ assignmentId: assignment.id })
          })
        }
      }
      loadData()
    } catch (error) {
      console.error('Object toggle failed:', error)
    }
  }

  const handleObjectCascade = async (assignmentId: string, action: 'full_access') => {
    try {
      await fetch('/api/authorization-objects/update-assignment', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          assignmentId,
          cascadeLevel: 'object',
          template: 'full_access'
        })
      })
      loadData()
    } catch (error) {
      console.error('Object cascade failed:', error)
    }
  }

  const saveFieldSelections = async (assignmentId: string) => {
    const selections = fieldSelections[assignmentId]
    if (!selections) return

    try {
      const response = await fetch('/api/authorization-objects/update-assignment', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          assignmentId,
          fieldValues: selections
        })
      })
      
      if (response.ok) {
        // Clear selections from state
        setFieldSelections(prev => {
          const newSelections = { ...prev }
          delete newSelections[assignmentId]
          return newSelections
        })
        
        // Show success message
        const assignment = roleAuths.find(auth => auth.id === assignmentId)
        const roleName = assignment?.role_name || 'role'
        alert(`✅ Successfully saved custom template for ${roleName}`)
        
        loadData()
      } else {
        alert('❌ Failed to save template. Please try again.')
      }
    } catch (error) {
      console.error('Failed to update field selections:', error)
      alert('❌ Failed to save template. Please try again.')
    }
  }

  const selectAllObjects = () => {
    const allObjectIds = new Set(objects.map(obj => obj.id))
    setSelectedObjects(allObjectIds)
  }

  const clearAllObjects = () => {
    setSelectedObjects(new Set())
  }

  const assignSelectedToRole = async (roleId: string, template: string) => {
    try {
      const response = await fetch('/api/authorization-objects/bulk-assign', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          roleId,
          objectIds: Array.from(selectedObjects),
          template
        })
      })
      
      if (response.ok) {
        setBulkAssignMode(false)
        setSelectedObjects(new Set())
        loadData()
      }
    } catch (error) {
      console.error('Bulk assignment failed:', error)
    }
  }
  const resetFieldForm = () => {
    setFieldForm({ field_code: '', is_required: true })
  }

  const resetObjectForm = () => {
    setObjectForm({ object_name: '', description: '', module: '', is_active: true })
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading Authorization Objects...</p>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="p-6 text-center">
        <p className="text-red-600">Error: {error}</p>
        <button 
          onClick={loadData}
          className="mt-2 px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
        >
          Retry
        </button>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b px-4 py-4">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-600">Manage SAP-style authorization objects and field assignments</p>
          </div>
          <div className="flex items-center space-x-2">
            <button
              onClick={() => setShowObjectForm(true)}
              className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center text-sm"
            >
              <Plus className="w-4 h-4 mr-2" />
              New Object
            </button>
          </div>
        </div>
      </div>

      {/* Tab Navigation */}
      <div className="bg-white border-b px-4 py-3">
        <div className="flex space-x-3">
          <button
            onClick={() => setActiveTab('objects')}
            className={`px-4 py-2 rounded-md ${activeTab === 'objects' ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-700'}`}
          >
            Objects ({objects.length})
          </button>
          <button
            onClick={() => setActiveTab('fields')}
            className={`px-4 py-2 rounded-md ${activeTab === 'fields' ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-700'}`}
          >
            Authorization Fields
          </button>
          <button
            onClick={() => setActiveTab('assignments')}
            className={`px-4 py-2 rounded-md ${activeTab === 'assignments' ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-700'}`}
          >
            Role Assignments ({roleAuths.length})
          </button>
        </div>
      </div>

      {/* Content */}
      <div className="p-4">

        {/* Objects Tab - Enhanced with Module Grouping */}
        {activeTab === 'objects' && (
          <div className="bg-white rounded-lg shadow-sm border">
            <div className="p-6 border-b">
              <div className="flex justify-between items-center">
                <h2 className="text-lg font-semibold">Authorization Objects by Module</h2>
                <div className="flex items-center space-x-2">
                  <button
                    onClick={() => setBulkAssignMode(!bulkAssignMode)}
                    className={`px-4 py-2 rounded-lg text-sm ${
                      bulkAssignMode ? 'bg-orange-600 text-white' : 'bg-gray-200 text-gray-700'
                    }`}
                  >
                    {bulkAssignMode ? 'Exit Bulk Mode' : 'Bulk Assign'}
                  </button>
                  {bulkAssignMode && (
                    <>
                      <button onClick={selectAllObjects} className="bg-blue-600 text-white px-3 py-2 rounded text-sm">
                        Select All ({objects.length})
                      </button>
                      <button onClick={clearAllObjects} className="bg-gray-600 text-white px-3 py-2 rounded text-sm">
                        Clear All
                      </button>
                      <span className="text-sm text-gray-600">
                        {selectedObjects.size} selected
                      </span>
                    </>
                  )}
                </div>
              </div>
            </div>

            <div className="divide-y">
              {Object.entries(objectsByModule).map(([module, moduleObjects]) => (
                <div key={module} className="">
                  <div 
                    className="p-4 bg-gray-50 border-b cursor-pointer hover:bg-gray-100 transition-colors"
                    onClick={() => toggleModule(module)}
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center space-x-3">
                        {expandedModules.has(module) ? 
                          <ChevronDown className="h-5 w-5 text-gray-600" /> : 
                          <ChevronRight className="h-5 w-5 text-gray-600" />
                        }
                        <h3 className="font-medium text-gray-900 capitalize">{module}</h3>
                        <span className="bg-blue-100 text-blue-800 text-xs px-2 py-1 rounded-full">
                          {moduleObjects.length} objects
                        </span>
                      </div>
                      {bulkAssignMode && (
                        <button
                          onClick={(e) => {
                            e.stopPropagation()
                            const moduleObjectIds = moduleObjects.map(obj => obj.id)
                            const newSelected = new Set(selectedObjects)
                            moduleObjectIds.forEach(id => newSelected.add(id))
                            setSelectedObjects(newSelected)
                          }}
                          className="bg-green-600 text-white px-3 py-1 rounded text-xs"
                        >
                          Select Module
                        </button>
                      )}
                    </div>
                  </div>

                  {expandedModules.has(module) && (
                    <div className="divide-y">
                      {moduleObjects.map((obj) => (
                        <div key={obj.id} className="p-4">
                          <div className="flex items-center justify-between">
                            <div className="flex items-center space-x-4">
                              {bulkAssignMode && (
                                <input
                                  type="checkbox"
                                  checked={selectedObjects.has(obj.id)}
                                  onChange={(e) => {
                                    const newSelected = new Set(selectedObjects)
                                    if (e.target.checked) {
                                      newSelected.add(obj.id)
                                    } else {
                                      newSelected.delete(obj.id)
                                    }
                                    setSelectedObjects(newSelected)
                                  }}
                                  className="w-4 h-4"
                                />
                              )}
                              <Shield className="h-5 w-5 text-blue-600" />
                              <div className="flex-1">
                                <div className="flex items-center space-x-3">
                                  <h4 className="font-medium text-gray-900">{obj.object_name}</h4>
                                  <span className={`px-2 py-1 text-xs rounded-full ${
                                    obj.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                                  }`}>
                                    {obj.is_active ? 'Active' : 'Inactive'}
                                  </span>
                                </div>
                                <p className="text-sm text-gray-600 mt-1">{obj.description}</p>
                                <span className="text-xs text-blue-600">
                                  {obj.fields?.length || 0} fields
                                </span>
                              </div>
                            </div>
                            {!bulkAssignMode && (
                              <div className="flex items-center space-x-2">
                                <button
                                  onClick={() => handleEditObject(obj)}
                                  className="p-2 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded transition-colors"
                                >
                                  <Edit className="h-4 w-4" />
                                </button>
                                <button
                                  onClick={() => handleDeleteObject(obj)}
                                  className="p-2 text-red-600 hover:text-red-800 hover:bg-red-50 rounded transition-colors"
                                >
                                  <Trash2 className="h-4 w-4" />
                                </button>
                              </div>
                            )}
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Authorization Fields Tab - Hierarchical Structure */}
        {activeTab === 'fields' && (
          <div className="bg-white rounded-lg shadow-sm border">
            <div className="p-4 md:p-6 border-b">
              <div className="flex flex-col md:flex-row md:items-center justify-between space-y-2 md:space-y-0">
                <h2 className="text-lg font-semibold flex items-center">
                  <Icons.Settings className="w-5 h-5 mr-2" />
                  Authorization Fields Structure
                </h2>
                <div className="flex items-center space-x-2">
                  <button
                    onClick={() => setShowFieldForm(true)}
                    className="bg-green-600 text-white px-3 md:px-4 py-2 rounded-lg hover:bg-green-700 flex items-center text-sm"
                  >
                    <Plus className="w-4 h-4 mr-1 md:mr-2" />
                    {isMobile ? 'Add' : 'New Field'}
                  </button>
                </div>
              </div>
            </div>
            
            <div className="divide-y">
              {Object.entries(objectsByModule).map(([module, moduleObjects]) => {
                const totalFields = moduleObjects.reduce((sum, obj) => sum + (obj.fields?.length || 0), 0)
                return (
                  <div key={module}>
                    {/* Module Level */}
                    <div 
                      className="p-4 bg-gray-50 border-b cursor-pointer hover:bg-gray-100 transition-colors"
                      onClick={() => toggleModule(module)}
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex items-center space-x-3">
                          {expandedModules.has(module) ? 
                            <ChevronDown className="h-5 w-5 text-gray-600" /> : 
                            <ChevronRight className="h-5 w-5 text-gray-600" />
                          }
                          <Icons.Folder className="w-5 h-5 text-blue-600" />
                          <div>
                            <h3 className="font-medium text-gray-900 capitalize">{module} Module</h3>
                            <p className="text-xs text-gray-500">
                              {moduleObjects.length} objects • {totalFields} fields
                            </p>
                          </div>
                        </div>
                        <div className="flex items-center space-x-2">
                          <span className="bg-blue-100 text-blue-800 text-xs px-2 py-1 rounded-full">
                            {moduleObjects.length} objects
                          </span>
                          <button
                            onClick={(e) => {
                              e.stopPropagation()
                              // Bulk operations for module
                            }}
                            className="text-gray-400 hover:text-gray-600 p-1"
                          >
                            <MoreVertical className="w-4 h-4" />
                          </button>
                        </div>
                      </div>
                    </div>

                    {/* Authorization Objects Level */}
                    {expandedModules.has(module) && (
                      <div className="bg-gray-25">
                        {moduleObjects.map((obj) => (
                          <div key={obj.id} className="border-l-4 border-blue-200">
                            <div 
                              className="p-4 pl-8 bg-white hover:bg-gray-50 cursor-pointer transition-colors border-b border-gray-100"
                              onClick={() => toggleObject(obj.id)}
                            >
                              <div className="flex items-center justify-between">
                                <div className="flex items-center space-x-3">
                                  {expandedObjects.has(obj.id) ? 
                                    <ChevronDown className="h-4 w-4 text-gray-500" /> : 
                                    <ChevronRight className="h-4 w-4 text-gray-500" />
                                  }
                                  <Shield className="w-4 h-4 text-green-600" />
                                  <div className="flex-1">
                                    <div className="flex items-center space-x-2">
                                      <h4 className="font-mono text-sm font-semibold text-gray-900">{obj.object_name}</h4>
                                      <span className={`px-2 py-1 text-xs rounded-full ${
                                        obj.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                                      }`}>
                                        {obj.is_active ? 'Active' : 'Inactive'}
                                      </span>
                                    </div>
                                    <p className="text-sm text-gray-600 mt-1">{obj.description}</p>
                                  </div>
                                </div>
                                <div className="flex items-center space-x-2">
                                  <span className="bg-purple-100 text-purple-800 text-xs px-2 py-1 rounded-full">
                                    {obj.fields?.length || 0} fields
                                  </span>
                                  <button
                                    onClick={(e) => {
                                      e.stopPropagation()
                                      setSelectedObjectId(obj.id)
                                      setShowFieldForm(true)
                                    }}
                                    className="text-green-600 hover:bg-green-50 p-1 rounded transition-colors"
                                    title="Add Field"
                                  >
                                    <Plus className="w-4 h-4" />
                                  </button>
                                  <button
                                    onClick={(e) => {
                                      e.stopPropagation()
                                      // Copy fields from another object
                                    }}
                                    className="text-blue-600 hover:bg-blue-50 p-1 rounded transition-colors"
                                    title="Copy Fields"
                                  >
                                    <Icons.Copy className="w-4 h-4" />
                                  </button>
                                </div>
                              </div>
                            </div>

                            {/* Authorization Fields Level */}
                            {expandedObjects.has(obj.id) && obj.fields && (
                              <div className="bg-gray-50 border-l-4 border-purple-200">
                                {obj.fields.length > 0 ? (
                                  <div className="divide-y divide-gray-200">
                                    {obj.fields.map((field) => (
                                      <div key={field.id} className="p-4 pl-12 bg-white hover:bg-gray-50 transition-colors">
                                        <div className="flex flex-col md:flex-row md:items-center justify-between space-y-2 md:space-y-0">
                                          <div className="flex-1">
                                            <div className="flex items-center space-x-2 mb-2">
                                              <Icons.Tag className="w-4 h-4 text-purple-600" />
                                              <span className="font-mono text-sm font-semibold text-purple-700 bg-purple-100 px-2 py-1 rounded">
                                                {field.field_code}
                                              </span>
                                              {field.is_required && (
                                                <span className="bg-red-100 text-red-700 text-xs px-2 py-1 rounded-full font-medium">
                                                  Required
                                                </span>
                                              )}
                                            </div>
                                            <p className="text-sm text-gray-600 mb-2">{getFieldDescription(field.field_code)}</p>
                                          </div>
                                          <div className="flex items-center space-x-1">
                                            <button
                                              onClick={() => handleEditField(field)}
                                              className="p-2 text-blue-600 hover:bg-blue-50 rounded transition-colors"
                                              title="Edit Field"
                                            >
                                              <Edit className="w-4 h-4" />
                                            </button>
                                            <button
                                              onClick={() => handleDeleteField(field)}
                                              className="p-2 text-red-600 hover:bg-red-50 rounded transition-colors"
                                              title="Delete Field"
                                            >
                                              <Trash2 className="w-4 h-4" />
                                            </button>
                                          </div>
                                        </div>
                                      </div>
                                    ))}
                                  </div>
                                ) : (
                                  <div className="p-8 text-center bg-white">
                                    <Icons.Tag className="w-8 h-8 text-gray-400 mx-auto mb-2" />
                                    <p className="text-gray-500 text-sm mb-3">No authorization fields defined</p>
                                    <button
                                      onClick={() => {
                                        setSelectedObjectId(obj.id)
                                        setShowFieldForm(true)
                                      }}
                                      className="bg-green-600 text-white px-3 py-1 rounded text-sm hover:bg-green-700 transition-colors"
                                    >
                                      Add First Field
                                    </button>
                                  </div>
                                )}
                              </div>
                            )}
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                )
              })}
            </div>
            
            {Object.keys(objectsByModule).length === 0 && (
              <div className="text-center py-12">
                <Icons.Settings className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">No authorization objects found</h3>
                <p className="text-gray-600">Create authorization objects to manage their fields</p>
              </div>
            )}
          </div>
        )}
        {/* Role Assignments Tab - Enhanced Cascading Design */}
        {activeTab === 'assignments' && (
          <div className="bg-white rounded-lg shadow-sm border">
            <div className="p-4 md:p-6 border-b">
              <div className="flex flex-col md:flex-row md:items-center justify-between space-y-3 md:space-y-0">
                <h2 className="text-lg font-semibold flex items-center">
                  <Icons.Users className="w-5 h-5 mr-2" />
                  Role Authorization Management
                </h2>
                <div className="flex items-center space-x-3">
                  <span className="text-sm text-gray-500">
                    {availableRoles.length} roles • {roleAuths.length} assignments
                  </span>
                  <div className="bg-green-50 border border-green-200 rounded px-3 py-1">
                    <span className="text-xs text-green-700 font-medium">
                      💡 Use "Assign Modules" to add new module access to roles
                    </span>
                  </div>
                </div>
              </div>
              
              {/* Assignment Summary */}
              {availableRoles.length > 0 && (
                <div className="mt-4 grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="bg-blue-50 border border-blue-200 rounded-lg p-3">
                    <div className="flex items-center justify-between">
                      <span className="text-sm font-medium text-blue-900">Total Modules</span>
                      <span className="text-lg font-bold text-blue-600">{availableModules.length}</span>
                    </div>
                    <p className="text-xs text-blue-700 mt-1">Available in system</p>
                  </div>
                  <div className="bg-green-50 border border-green-200 rounded-lg p-3">
                    <div className="flex items-center justify-between">
                      <span className="text-sm font-medium text-green-900">Assigned Objects</span>
                      <span className="text-lg font-bold text-green-600">{roleAuths.length}</span>
                    </div>
                    <p className="text-xs text-green-700 mt-1">Across all roles</p>
                  </div>
                  <div className="bg-purple-50 border border-purple-200 rounded-lg p-3">
                    <div className="flex items-center justify-between">
                      <span className="text-sm font-medium text-purple-900">Coverage</span>
                      <span className="text-lg font-bold text-purple-600">
                        {Math.round((roleAuths.length / (availableRoles.length * objects.length)) * 100)}%
                      </span>
                    </div>
                    <p className="text-xs text-purple-700 mt-1">Role-object assignments</p>
                  </div>
                </div>
              )}
            </div>
            
            <div className="divide-y">
              {availableRoles.map((role) => {
                const roleModules = roleAssignmentsByRole[role.name] || {}
                
                return (
                  <div key={role.name}>
                    {/* Role Header */}
                    <div className="p-4 bg-blue-50 border-b">
                      <div className="flex items-center justify-between">
                        <div 
                          className="flex items-center space-x-3 cursor-pointer hover:bg-blue-100 transition-colors flex-1 p-2 rounded"
                          onClick={() => toggleRole(role.name)}
                        >
                          {expandedRoles.has(role.name) ? 
                            <ChevronDown className="h-5 w-5 text-blue-600" /> : 
                            <ChevronRight className="h-5 w-5 text-blue-600" />
                          }
                          <User className="w-5 h-5 text-blue-600" />
                          <div>
                            <h3 className="font-semibold text-blue-900">{role.name}</h3>
                            <div className="flex items-center space-x-2">
                              <p className="text-sm text-blue-700">
                                {Object.keys(roleModules).length}/{availableModules.length} modules • {role.assignmentCount} assignments
                              </p>
                              <div className="w-16 bg-blue-200 rounded-full h-2">
                                <div 
                                  className="bg-blue-600 h-2 rounded-full transition-all duration-300"
                                  style={{ width: `${(Object.keys(roleModules).length / availableModules.length) * 100}%` }}
                                ></div>
                              </div>
                            </div>
                          </div>
                        </div>
                        <div className="flex items-center space-x-2">
                          <span className="bg-blue-200 text-blue-800 text-sm px-3 py-1 rounded-full font-medium">
                            {role.assignmentCount} objects
                          </span>
                          {getUnassignedModules(role.name).length > 0 && (
                            <button
                              onClick={() => startModuleAssignment(role.name)}
                              className="bg-green-600 text-white px-3 py-1 rounded text-sm hover:bg-green-700 flex items-center"
                            >
                              <Plus className="w-4 h-4 mr-1" />
                              Assign Modules ({getUnassignedModules(role.name).length})
                            </button>
                          )}
                        </div>
                      </div>
                    </div>

                    {/* Module Level with Assignments */}
                    {expandedRoles.has(role.name) && (
                      <div className="bg-gray-25">
                        {Object.entries(roleModules).map(([module, assignments]) => {
                          const moduleObjects = objectsByModule[module] || []
                          
                          return (
                            <div key={module} className="border-l-4 border-indigo-200">
                              {/* Module Header */}
                              <div className="p-4 pl-8 bg-white hover:bg-gray-50 transition-colors border-b border-gray-100">
                                <div className="flex items-center justify-between">
                                  <div className="flex items-center space-x-3">
                                    <button
                                      onClick={() => toggleModule(module)}
                                      className="text-gray-500 hover:text-gray-700"
                                    >
                                      {expandedModules.has(module) ? 
                                        <ChevronDown className="h-4 w-4" /> : 
                                        <ChevronRight className="h-4 w-4" />
                                      }
                                    </button>
                                    <Folder className="w-5 h-5 text-indigo-600" />
                                    <div className="flex-1">
                                      <div className="flex items-center space-x-2">
                                        <h4 className="font-medium text-gray-900 capitalize">{module} Module</h4>
                                        <span className="bg-green-100 text-green-800 text-xs px-2 py-1 rounded-full font-medium">
                                          ✅ {assignments.length} objects assigned
                                        </span>
                                      </div>
                                      <p className="text-sm text-gray-600">
                                        {assignments.length}/{moduleObjects.length} objects assigned
                                      </p>
                                    </div>
                                  </div>
                                  
                                  {/* Enhanced Module-Level Controls */}
                                  <div className="flex items-center space-x-1">
                                    <button
                                      onClick={() => handleModuleCascade(role.name, module, 'select_all')}
                                      className="bg-green-600 text-white px-2 py-1 rounded text-xs hover:bg-green-700"
                                      title="Grant full access with inheritance"
                                    >
                                      🔓 Full
                                    </button>
                                    <button
                                      onClick={() => handleModuleCascade(role.name, module, 'reset_default')}
                                      className="bg-blue-600 text-white px-2 py-1 rounded text-xs hover:bg-blue-700"
                                      title="Assign all objects with default values"
                                    >
                                      🔄 Reset
                                    </button>
                                    <button
                                      onClick={() => handleModuleCascade(role.name, module, 'clear_cascade')}
                                      className="bg-yellow-600 text-white px-2 py-1 rounded text-xs hover:bg-yellow-700"
                                      title="Remove inherited permissions only"
                                    >
                                      ❌ Clear
                                    </button>
                                    <button
                                      onClick={() => handleModuleCascade(role.name, module, 'remove_all')}
                                      className="bg-red-600 text-white px-2 py-1 rounded text-xs hover:bg-red-700"
                                      title="Remove all access (destructive)"
                                    >
                                      🗑️ Remove
                                    </button>
                                  </div>
                                </div>
                              </div>

                              {/* Authorization Objects Level */}
                              {expandedModules.has(module) && (
                                <div className="bg-gray-50 border-l-4 border-purple-200">
                                  {assignments.map((assignment) => {
                                    const obj = objects.find(o => o.id === assignment.auth_object_id)
                                    if (!obj) return null
                                    
                                    const isInherited = assignment.module_full_access || assignment.object_full_access
                                    
                                    return (
                                      <div key={assignment.id} className="border-b border-gray-200 last:border-b-0">
                                        <div className="p-4 pl-12 bg-white hover:bg-gray-50 transition-colors">
                                          <div className="flex items-center justify-between">
                                            <div className="flex items-center space-x-3">
                                              {obj.fields && obj.fields.length > 0 && (
                                                <button
                                                  onClick={() => toggleAssignment(assignment.id)}
                                                  className="text-gray-500 hover:text-gray-700"
                                                >
                                                  {expandedAssignments.has(assignment.id) ? 
                                                    <ChevronDown className="h-4 w-4" /> : 
                                                    <ChevronRight className="h-4 w-4" />
                                                  }
                                                </button>
                                              )}
                                              <Shield className="w-4 h-4 text-green-600" />
                                              <div className="flex-1">
                                                <div className="flex items-center space-x-2">
                                                  <span className="font-mono text-sm font-semibold text-gray-900">
                                                    {obj.object_name}
                                                  </span>
                                                  <span className={`text-xs px-2 py-1 rounded-full font-medium ${
                                                    isInherited ? 'bg-yellow-100 text-yellow-800' : 'bg-green-100 text-green-800'
                                                  }`}>
                                                    {isInherited ? '🔗 Inherited' : '📝 Custom Template'}
                                                  </span>
                                                </div>
                                                <p className="text-sm text-gray-600">{obj.description}</p>
                                                <span className="text-xs text-purple-600">
                                                  {obj.fields?.length || 0} fields
                                                </span>
                                              </div>
                                            </div>
                                            
                                            {/* Object-Level Controls */}
                                            {!isInherited && (
                                              <div className="flex items-center space-x-2">
                                                <button
                                                  onClick={() => handleObjectCascade(assignment.id, 'full_access')}
                                                  className="bg-orange-600 text-white px-2 py-1 rounded text-xs hover:bg-orange-700"
                                                >
                                                  🔓 Full Access
                                                </button>
                                              </div>
                                            )}
                                          </div>
                                        </div>

                                        {/* Authorization Fields Level */}
                                        {expandedAssignments.has(assignment.id) && obj.fields && (
                                          <div className="bg-gray-100 border-l-4 border-green-200">
                                            <div className="p-4 pl-16">
                                              <div className="flex items-center justify-between mb-4">
                                                <h5 className="font-medium text-gray-800 flex items-center">
                                                  <Tag className="w-4 h-4 mr-2 text-green-600" />
                                                  Field Values ({obj.fields.length} fields)
                                                  {isInherited && (
                                                    <div className="ml-3 flex items-center space-x-2">
                                                      <span className="bg-yellow-100 text-yellow-800 text-xs px-2 py-1 rounded-full">
                                                        🔗 Inherited from {assignment.module_full_access ? 'module' : 'object'} level
                                                      </span>
                                                      <button
                                                        onClick={() => convertToCustomTemplate(assignment.id)}
                                                        className="bg-blue-600 text-white px-2 py-1 rounded text-xs hover:bg-blue-700"
                                                        title="Convert to custom template - allows field editing"
                                                      >
                                                        📝 Customize
                                                      </button>
                                                    </div>
                                                  )}
                                                </h5>
                                                {(!isInherited || fieldSelections[assignment.id]) && (
                                                  <button
                                                    onClick={() => saveFieldSelections(assignment.id)}
                                                    className="bg-green-600 text-white px-3 py-1 rounded text-sm hover:bg-green-700 flex items-center"
                                                  >
                                                    💾 Save Template
                                                  </button>
                                                )}
                                              </div>
                                              
                                              <div className="grid gap-3">
                                                {obj.fields.map((field) => {
                                                  const effectiveValues = getEffectiveFieldValues(assignment, field.field_name)
                                                  const selectedValues = fieldSelections[assignment.id]?.[field.field_name] || effectiveValues
                                                  
                                                  return (
                                                    <div key={field.id} className="bg-white rounded-lg p-3 border">
                                                      <div className="flex items-center justify-between mb-2">
                                                        <div className="flex items-center space-x-2">
                                                          <span className="font-mono text-sm font-semibold text-green-700 bg-green-100 px-2 py-1 rounded">
                                                            {field.field_name}
                                                          </span>
                                                          <span className="text-sm text-gray-600">{field.field_description}</span>
                                                          {field.is_required && (
                                                            <span className="bg-red-100 text-red-700 text-xs px-2 py-1 rounded-full">Required</span>
                                                          )}
                                                        </div>
                                                        {!isInherited && (
                                                          <div className="flex space-x-1">
                                                            <button
                                                              onClick={() => updateFieldSelection(assignment.id, field.field_name, ['*'])}
                                                              className="bg-red-100 text-red-700 px-2 py-1 rounded text-xs hover:bg-red-200"
                                                            >
                                                              * All
                                                            </button>
                                                            <button
                                                              onClick={() => updateFieldSelection(assignment.id, field.field_name, [])}
                                                              className="bg-gray-100 text-gray-700 px-2 py-1 rounded text-xs hover:bg-gray-200"
                                                            >
                                                              Clear
                                                            </button>
                                                          </div>
                                                        )}
                                                      </div>
                                                      
                                                      <div className="flex flex-wrap gap-2">
                                                        {field.field_values?.map((value) => (
                                                          <label key={value} className="flex items-center space-x-1 cursor-pointer">
                                                            <input
                                                              type="checkbox"
                                                              checked={selectedValues.includes(value)}
                                                              onChange={(e) => {
                                                                const newValues = e.target.checked
                                                                  ? [...selectedValues.filter(v => v !== value), value]
                                                                  : selectedValues.filter(v => v !== value)
                                                                updateFieldSelection(assignment.id, field.field_name, newValues)
                                                              }}
                                                              className="w-3 h-3 text-green-600 rounded"
                                                            />
                                                            <span className={`text-xs px-2 py-1 rounded ${
                                                              selectedValues.includes(value)
                                                                ? value === '*' 
                                                                  ? 'bg-red-100 text-red-800 font-medium'
                                                                  : 'bg-green-100 text-green-800 font-medium'
                                                                : 'bg-gray-100 text-gray-600'
                                                            } ${isInherited ? 'opacity-75' : ''}`}>
                                                              {value}
                                                            </span>
                                                          </label>
                                                        ))}
                                                      </div>
                                                    </div>
                                                  )
                                                })}
                                              </div>
                                            </div>
                                          </div>
                                        )}
                                      </div>
                                    )
                                  })}
                                </div>
                              )}
                            </div>
                          )
                        })}
                      </div>
                    )}
                  </div>
                )
              })}
            </div>
            
            {availableRoles.length === 0 && (
              <div className="text-center py-12">
                <Icons.Users className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">No roles found in the system</h3>
                <p className="text-gray-600 mb-4">You need to create roles first before managing role assignments</p>
                <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 max-w-md mx-auto">
                  <p className="text-sm text-blue-800">
                    <strong>Workflow:</strong><br/>
                    1. Create roles in User Management<br/>
                    2. Use "Assign Modules" to select modules for each role<br/>
                    3. Configure field-level permissions as needed<br/>
                    4. Save changes to complete authorization setup
                  </p>
                </div>
              </div>
            )}
          </div>
        )}

        {/* Create Object Modal */}
        {showObjectForm && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg p-6 w-full max-w-md">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-semibold">Create Authorization Object</h3>
                <button onClick={() => setShowObjectForm(false)}>
                  <X className="h-5 w-5" />
                </button>
              </div>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Object Name</label>
                  <input
                    type="text"
                    value={objectForm.object_name}
                    onChange={(e) => setObjectForm({...objectForm, object_name: e.target.value})}
                    className="w-full px-3 py-2 border rounded-md"
                    placeholder="F_CUSTOM_01"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Description</label>
                  <input
                    type="text"
                    value={objectForm.description}
                    onChange={(e) => setObjectForm({...objectForm, description: e.target.value})}
                    className="w-full px-3 py-2 border rounded-md"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Module</label>
                  <select
                    value={objectForm.module}
                    onChange={(e) => setObjectForm({...objectForm, module: e.target.value})}
                    className="w-full px-3 py-2 border rounded-md"
                  >
                    <option value="">Select Module</option>
                    {availableModules.map(module => (
                      <option key={module} value={module}>{module.charAt(0).toUpperCase() + module.slice(1)}</option>
                    ))}
                  </select>
                </div>
                <div className="flex justify-end space-x-3">
                  <button
                    onClick={() => setShowObjectForm(false)}
                    className="px-4 py-2 text-gray-600 border rounded-md hover:bg-gray-50"
                  >
                    Cancel
                  </button>
                  <button
                    onClick={handleCreateObject}
                    className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
                  >
                    Create
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Module Assignment Modal - Two-Step Wizard */}
        {showModuleAssignmentModal && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg p-6 w-full max-w-4xl max-h-[90vh] overflow-y-auto">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-semibold">
                  {assignmentStep === 1 ? 'Step 1: Select Modules' : 'Step 2: Select Objects'} - {selectedRoleForAssignment}
                </h3>
                <button onClick={() => {
                  setShowModuleAssignmentModal(false)
                  setAssignmentStep(1)
                  setSelectedModulesForAssignment(new Set())
                  setSelectedObjectsForAssignment(new Set())
                }}>
                  <X className="h-5 w-5" />
                </button>
              </div>
              
              {/* Step 1: Module Selection */}
              {assignmentStep === 1 && (
                <div className="space-y-4">
                  <div className="flex justify-between items-center">
                    <p className="text-sm text-gray-600">
                      Select modules to assign to this role.
                    </p>
                    <button
                      onClick={selectAllAvailableModules}
                      className="bg-blue-600 text-white px-3 py-1 rounded text-sm hover:bg-blue-700"
                    >
                      Select All ({availableModulesForRole.length})
                    </button>
                  </div>
                  
                  <div className="max-h-60 overflow-y-auto border rounded-lg">
                    {availableModulesForRole.length > 0 ? (
                      <div className="divide-y">
                        {availableModulesForRole.map(module => {
                          const moduleObjects = objectsByModule[module] || []
                          return (
                            <label key={module} className="flex items-center p-3 hover:bg-gray-50 cursor-pointer">
                              <input
                                type="checkbox"
                                checked={selectedModulesForAssignment.has(module)}
                                onChange={() => toggleModuleForAssignment(module)}
                                className="w-4 h-4 text-blue-600 mr-3"
                              />
                              <div className="flex-1">
                                <div className="flex items-center space-x-2">
                                  <span className="font-medium capitalize">{module}</span>
                                  <span className="bg-gray-100 text-gray-700 text-xs px-2 py-1 rounded-full">
                                    {moduleObjects.length} objects
                                  </span>
                                </div>
                                <p className="text-sm text-gray-500">
                                  {moduleObjects.map(obj => obj.object_name).slice(0, 3).join(', ')}
                                  {moduleObjects.length > 3 && ` +${moduleObjects.length - 3} more`}
                                </p>
                              </div>
                            </label>
                          )
                        })}
                      </div>
                    ) : (
                      <div className="p-8 text-center text-gray-500">
                        <Folder className="w-8 h-8 mx-auto mb-2 text-gray-400" />
                        <p>All modules are already assigned to this role</p>
                      </div>
                    )}
                  </div>
                  
                  <div className="flex justify-between items-center pt-4 border-t">
                    <span className="text-sm text-gray-600">
                      {selectedModulesForAssignment.size} modules selected
                    </span>
                    <div className="flex space-x-3">
                      <button
                        onClick={() => {
                          setShowModuleAssignmentModal(false)
                          setSelectedModulesForAssignment(new Set())
                        }}
                        className="px-4 py-2 text-gray-600 border rounded-md hover:bg-gray-50"
                      >
                        Cancel
                      </button>
                      <button
                        onClick={proceedToObjectSelection}
                        disabled={selectedModulesForAssignment.size === 0}
                        className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed flex items-center"
                      >
                        Next: Select Objects →
                      </button>
                    </div>
                  </div>
                </div>
              )}

              {/* Step 2: Object Selection */}
              {assignmentStep === 2 && (
                <div className="space-y-4">
                  <div className="bg-blue-50 border border-blue-200 rounded-lg p-3">
                    <p className="text-sm text-blue-800">
                      <strong>Selected Modules:</strong> {Array.from(selectedModulesForAssignment).join(', ')}
                    </p>
                    <p className="text-sm text-blue-700 mt-1">
                      {selectedObjectsForAssignment.size} of {Array.from(selectedModulesForAssignment).reduce((sum, m) => sum + (objectsByModule[m]?.length || 0), 0)} objects selected
                    </p>
                  </div>

                  <div className="max-h-96 overflow-y-auto border rounded-lg">
                    {Array.from(selectedModulesForAssignment).map(module => {
                      const moduleObjects = objectsByModule[module] || []
                      
                      return (
                        <div key={module} className="border-b last:border-b-0">
                          <div className="bg-gray-50 p-3 flex items-center justify-between">
                            <div className="flex items-center space-x-2">
                              <Folder className="w-4 h-4 text-blue-600" />
                              <span className="font-medium capitalize">{module} Module</span>
                              <span className="text-xs text-gray-600">
                                ({moduleObjects.filter(obj => selectedObjectsForAssignment.has(obj.id)).length}/{moduleObjects.length})
                              </span>
                            </div>
                            <div className="flex space-x-2">
                              <button
                                onClick={() => selectAllInModule(module)}
                                className="text-xs bg-green-100 text-green-700 px-2 py-1 rounded hover:bg-green-200"
                              >
                                Select All
                              </button>
                              <button
                                onClick={() => deselectAllInModule(module)}
                                className="text-xs bg-gray-100 text-gray-700 px-2 py-1 rounded hover:bg-gray-200"
                              >
                                Deselect All
                              </button>
                            </div>
                          </div>
                          
                          <div className="divide-y">
                            {moduleObjects.map(obj => (
                              <label key={obj.id} className="flex items-start p-3 hover:bg-gray-50 cursor-pointer">
                                <input
                                  type="checkbox"
                                  checked={selectedObjectsForAssignment.has(obj.id)}
                                  onChange={() => toggleObjectSelection(obj.id)}
                                  className="w-4 h-4 text-blue-600 mt-1 mr-3"
                                />
                                <div className="flex-1">
                                  <div className="flex items-center space-x-2">
                                    <Shield className="w-4 h-4 text-green-600" />
                                    <span className="font-mono text-sm font-semibold">{obj.object_name}</span>
                                  </div>
                                  <p className="text-sm text-gray-600 mt-1">{obj.description}</p>
                                </div>
                              </label>
                            ))}
                          </div>
                        </div>
                      )
                    })}
                  </div>

                  <div className="flex justify-between items-center pt-4 border-t">
                    <button
                      onClick={() => {
                        setAssignmentStep(1)
                        setSelectedObjectsForAssignment(new Set())
                      }}
                      className="px-4 py-2 text-gray-600 border rounded-md hover:bg-gray-50 flex items-center"
                    >
                      ← Back to Modules
                    </button>
                    <div className="flex items-center space-x-3">
                      <span className="text-sm text-gray-600">
                        {selectedObjectsForAssignment.size} objects selected
                      </span>
                      <button
                        onClick={assignSelectedObjects}
                        disabled={selectedObjectsForAssignment.size === 0}
                        className="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 disabled:bg-gray-400 disabled:cursor-not-allowed"
                      >
                        Assign {selectedObjectsForAssignment.size} Objects
                      </button>
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Create Field Modal */}
        {showFieldForm && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg p-6 w-full max-w-md">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-semibold">{editingField ? 'Edit Authorization Field' : 'Add Authorization Field'}</h3>
                <button onClick={() => {
                  setShowFieldForm(false)
                  setEditingField(null)
                  resetFieldForm()
                }}>
                  <X className="h-5 w-5" />
                </button>
              </div>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Field Type</label>
                  <select
                    value={fieldForm.field_code}
                    onChange={(e) => setFieldForm({ ...fieldForm, field_code: e.target.value })}
                    className="w-full px-3 py-2 border rounded-md"
                    disabled={!!editingField}
                  >
                    <option value="">Select Field</option>
                    {['Activity', 'Organizational', 'Business'].map(category => {
                      const categoryFields = availableFieldNames.filter(f => f.category === category)
                      if (categoryFields.length === 0) return null
                      return (
                        <optgroup key={category} label={`${category} Fields`}>
                          {categoryFields.map(field => (
                            <option key={field.value} value={field.value}>{field.label}</option>
                          ))}
                        </optgroup>
                      )
                    })}
                  </select>
                  {fieldForm.field_code && (
                    <p className="text-xs text-gray-500 mt-1">
                      {fieldForm.field_code === 'ACTVT' && '📊 Static values: Activity codes'}
                      {fieldForm.field_code === 'COMP_CODE' && '🏢 From: company_codes table'}
                      {fieldForm.field_code === 'PLANT' && '🏭 From: plants table'}
                      {fieldForm.field_code === 'STORAGE_LOC' && '📦 From: storage_locations table'}
                      {fieldForm.field_code === 'DEPT' && '👥 From: departments table'}
                      {fieldForm.field_code === 'COST_CENTER' && '💰 From: cost_centers table'}
                      {fieldForm.field_code === 'PURCH_ORG' && '🛒 From: purchasing_organizations table'}
                      {fieldForm.field_code === 'PROJ_TYPE' && '📋 From: projects.project_type (distinct values)'}
                      {fieldForm.field_code === 'MR_TYPE' && '📝 From: material_requests.mr_type (distinct values)'}
                      {fieldForm.field_code === 'PR_TYPE' && '📄 From: purchase_requisitions.pr_type (distinct values)'}
                      {fieldForm.field_code === 'MAT_TYPE' && '🔧 From: materials.material_type (distinct values)'}
                      {fieldForm.field_code === 'PO_TYPE' && '📑 Static values: Purchase Order types'}
                      {fieldForm.field_code === 'PO_VALUE' && '💵 Custom: Value limits'}
                      {fieldForm.field_code === 'GL_ACCT' && '📊 Custom: GL account ranges'}
                    </p>
                  )}
                </div>
                <div className="flex items-center">
                  <input
                    type="checkbox"
                    checked={fieldForm.is_required}
                    onChange={(e) => setFieldForm({...fieldForm, is_required: e.target.checked})}
                    className="mr-2"
                  />
                  <label className="text-sm">Required Field</label>
                </div>
                <div className="flex justify-end space-x-3">
                  <button
                    onClick={() => {
                      setShowFieldForm(false)
                      setEditingField(null)
                      resetFieldForm()
                    }}
                    className="px-4 py-2 text-gray-600 border rounded-md hover:bg-gray-50"
                  >
                    Cancel
                  </button>
                  <button
                    onClick={editingField ? handleUpdateField : handleCreateField}
                    className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
                  >
                    {editingField ? 'Update' : 'Add Field'}
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}

        {objects.length === 0 && !loading && (
          <div className="text-center py-12">
            <Shield className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">No authorization objects found</h3>
            <p className="text-gray-600">Create your first authorization object to get started</p>
          </div>
        )}
      </div>
    </div>
  )
}