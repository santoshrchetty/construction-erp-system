import { MaterialRequestInsert } from './database'

// Form data type based on database schema
export interface MaterialRequestFormData {
  // MR number (generated after submission)
  request_number: string
  
  // Required fields
  priority: MaterialRequestInsert['priority']
  company_code: string
  
  // Optional organizational fields
  plant_code: string
  storage_location: string
  cost_center: string
  wbs_element: string
  project_code: string
  activity_code: string
  
  // UI-only fields (not in database)
  account_assignment: 'P' | 'K' | 'M' | 'F' | ''
  order_number: string
  
  // Text fields
  purpose: string
  justification: string
  notes: string
  
  // Items array
  items: MaterialRequestItem[]
}

export interface MaterialRequestItem {
  line_number: number
  material_code: string
  material_name: string
  requested_quantity: number
  base_uom: string
  available_stock: number
  priority: 'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT'
  required_date: string
}

// Validation result interface
export interface ValidationResult {
  isValid: boolean
  errors: string[]
  data?: Omit<MaterialRequestInsert, 'request_number'>
}

// Type guard to validate form data against database schema
export function validateMaterialRequestData(
  formData: MaterialRequestFormData
): ValidationResult {
  const errors: string[] = []
  
  // Required field validations
  if (!formData.account_assignment) errors.push('Account assignment is required')
  if (!formData.project_code) errors.push('Project is required')
  
  // Account assignment specific validations
  if (formData.account_assignment === 'P' && !formData.wbs_element) {
    errors.push('WBS element is required for project assignment')
  }
  if (formData.account_assignment === 'K' && !formData.cost_center) {
    errors.push('Cost center is required for cost center assignment')
  }
  
  // Company code should be auto-populated from WBS element for project assignments
  if (formData.account_assignment === 'P' && !formData.company_code) {
    errors.push('Company code should be auto-populated from WBS element')
  }
  
  // Plant and storage location are required after company code is set
  if (formData.company_code && !formData.plant_code) {
    errors.push('Plant code is required')
  }
  if (formData.plant_code && !formData.storage_location) {
    errors.push('Receiving location is required')
  }
  
  // Items validation
  if (!formData.items || formData.items.length === 0) {
    errors.push('At least one material item is required')
  } else {
    formData.items.forEach((item, index) => {
      if (!item.material_code) errors.push(`Material code is required for item ${index + 1}`)
      if (!item.requested_quantity || item.requested_quantity <= 0) {
        errors.push(`Valid quantity is required for item ${index + 1}`)
      }
      if (!item.required_date) errors.push(`Required date is required for item ${index + 1}`)
    })
  }
  
  const isValid = errors.length === 0
  
  const data = isValid ? {
    request_type: 'MATERIAL_REQ' as const,
    priority: formData.items[0]?.priority || 'MEDIUM',
    company_code: formData.company_code,
    plant_code: formData.plant_code || null,
    cost_center: formData.cost_center || null,
    wbs_element: formData.wbs_element || null,
    project_code: formData.project_code || null,
    storage_location: formData.storage_location || null,
    activity_code: formData.activity_code || null,
    purpose: formData.purpose || null,
    justification: formData.justification || null,
    notes: formData.notes || null,
    requested_by: '', // Will be set by backend
    created_by: '',   // Will be set by backend
    items: formData.items // Include items array
  } : undefined
  
  return { isValid, errors, data }
}