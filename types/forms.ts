import { MaterialRequestInsert } from './database'

// Form data type based on database schema
export interface MaterialRequestFormData {
  // Required fields
  priority: MaterialRequestInsert['priority']
  required_date: string
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
}

// Type guard to validate form data against database schema
export function validateMaterialRequestData(
  formData: MaterialRequestFormData
): MaterialRequestInsert {
  return {
    request_type: 'MATERIAL_REQ',
    priority: formData.priority || 'MEDIUM',
    required_date: formData.required_date,
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
    created_by: ''    // Will be set by backend
  }
}