// Enhanced project config services with dependent dropdown support
import { projectConfigService } from './projectConfigServices'

export class DependentDropdownService {
  // Load project types when category changes
  static async loadProjectTypes(categoryCode: string, companyCode?: string) {
    if (!categoryCode) return []
    return await projectConfigService.getProjectTypes(categoryCode, companyCode)
  }

  // Load material groups when category changes
  static async loadMaterialGroups(categoryCode: string) {
    if (!categoryCode) return []
    
    const response = await fetch(`/api/materials/master-data?type=groups&category=${categoryCode}`)
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
    return result.data
  }

  // Load suppliers by state for GST calculation
  static async loadSuppliersByState(stateCode: string, companyCode?: string) {
    if (!stateCode) return []
    
    const company = companyCode || 'C001'
    const response = await fetch(`/api/suppliers?company=${company}&state=${stateCode}`)
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
    return result.data
  }

  // Get HSN options for material
  static async getHSNOptions(materialCode: string, companyCode?: string) {
    const company = companyCode || 'C001'
    const response = await fetch('/api/erp-config/projects?section=gl-minimal', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        company_code: company,
        material_code: materialCode,
        movement_type: 'C101',
        supplier_code: 'TEMP',
        taxable_amount: 1000
      })
    })
    
    const result = await response.json()
    if (result.validation_status === 'HSN_SELECTION_REQUIRED') {
      return {
        requiresSelection: true,
        options: result.hsn_options,
        defaultHsn: result.default_hsn,
        materialGroup: result.material_group
      }
    }
    
    return { requiresSelection: false, options: [] }
  }
}

export const dependentDropdownService = new DependentDropdownService()