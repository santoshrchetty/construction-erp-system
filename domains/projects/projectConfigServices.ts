// Domain Layer - Project Configuration Services
export interface ProjectType {
  id?: string
  type_code: string
  type_name: string
  category_code: string
  gl_posting_variant?: string
  description?: string
  is_active: boolean
  company_code: string
  sort_order?: number
}

export interface ProjectCategory {
  id?: string
  category_code: string
  category_name: string
  cost_ownership: string
  real_time_posting: boolean
  is_active: boolean
  company_code: string
  sort_order?: number
  project_types?: ProjectType[]
}

export interface GLDeterminationRule {
  id?: string
  project_category: string
  event_type: string
  gl_account_type: string
  debit_credit: 'D' | 'C'
  posting_key: string
  company_code: string
  hsn_sac_code?: string  // Added for GST compliance
  supplier_code?: string // Added for state-based GST
  gst_rate?: number     // Added for GST calculation
  is_capital_goods?: boolean // Added for input credit
  is_active: boolean
}

export interface NumberingRule {
  id?: string
  entity_type: string
  pattern: string
  current_number: number
  description: string
  is_active: boolean
}

export interface ProjectWorkflow {
  id?: string
  workflow_name: string
  workflow_type: string
  steps: number
  status: 'Active' | 'Draft' | 'Inactive'
  description: string
  is_active: boolean
}

class ProjectConfigService {
  private baseUrl = '/api/erp-config/projects'
  private defaultCompanyCode = process.env.NEXT_PUBLIC_DEFAULT_COMPANY_CODE || 'C001'

  private async safeFetch(url: string, options?: RequestInit) {
    if (!url.startsWith('/api/')) {
      throw new Error('Invalid URL: Only internal API calls allowed')
    }
    const response = await fetch(url, options)
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }
    return response
  }

  async getProjectCategories(companyCode?: string): Promise<ProjectCategory[]> {
    const company = companyCode || this.defaultCompanyCode
    const response = await this.safeFetch(`${this.baseUrl}?section=categories&company=${company}`)
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
    return result.data
  }

  async createProjectCategory(category: Omit<ProjectCategory, 'id'>, companyCode?: string): Promise<ProjectCategory> {
    const company = companyCode || this.defaultCompanyCode
    const response = await this.safeFetch(`${this.baseUrl}?section=categories`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ...category, company_code: company })
    })
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
    return result.data
  }

  async updateProjectCategory(id: string, category: Partial<ProjectCategory>): Promise<ProjectCategory> {
    const response = await this.safeFetch(`${this.baseUrl}?section=categories&id=${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(category)
    })
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
    return result.data
  }

  async deleteProjectCategory(id: string): Promise<void> {
    const response = await this.safeFetch(`${this.baseUrl}?section=categories&id=${id}`, {
      method: 'DELETE'
    })
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
  }

  async getGLRules(companyCode?: string): Promise<GLDeterminationRule[]> {
    const company = companyCode || this.defaultCompanyCode
    const response = await this.safeFetch(`${this.baseUrl}?section=gl-rules&company=${company}`)
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
    return result.data
  }

  // Multi-country tax calculation
  async getUniversalTaxCalculation(
    materialCode: string,
    movementType: string,
    supplierCode: string,
    taxableAmount: number,
    companyCode?: string
  ): Promise<any> {
    const company = companyCode || this.defaultCompanyCode
    const response = await this.safeFetch(`${this.baseUrl}?section=gl-universal`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        company_code: company,
        material_code: materialCode,
        movement_type: movementType,
        supplier_code: supplierCode,
        taxable_amount: taxableAmount
      })
    })
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
    return result.data
  }
  async getGLDeterminationWithValidation(
    materialCode: string,
    movementType: string,
    supplierCode: string,
    taxableAmount: number,
    companyCode?: string,
    transactionId?: string,
    overrideHsn?: string
  ): Promise<any> {
    const company = companyCode || this.defaultCompanyCode
    const response = await this.safeFetch(`${this.baseUrl}?section=gl-minimal`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        company_code: company,
        material_code: materialCode,
        movement_type: movementType,
        supplier_code: supplierCode,
        taxable_amount: taxableAmount,
        transaction_id: transactionId,
        override_hsn: overrideHsn
      })
    })
    const result = await response.json()
    if (!result.success) {
      // SAP-like error with validation details
      const error = new Error(result.error) as any
      error.validationStatus = result.validation_status
      error.suggestedHsn = result.suggested_hsn
      error.requiresUserInput = result.requires_user_input
      throw error
    }
    return result.data
  }

  async createGLRule(rule: Omit<GLDeterminationRule, 'id'>, companyCode?: string): Promise<GLDeterminationRule> {
    const company = companyCode || this.defaultCompanyCode
    const response = await this.safeFetch(`${this.baseUrl}?section=gl-rules`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ...rule, company_code: company })
    })
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
    return result.data
  }

  async updateGLRule(id: string, rule: Partial<GLDeterminationRule>): Promise<GLDeterminationRule> {
    const response = await this.safeFetch(`${this.baseUrl}?section=gl-rules&id=${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(rule)
    })
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
    return result.data
  }

  async deleteGLRule(id: string): Promise<void> {
    const response = await this.safeFetch(`${this.baseUrl}?section=gl-rules&id=${id}`, {
      method: 'DELETE'
    })
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
  }

  async getNumberingRules(companyCode?: string): Promise<NumberingRule[]> {
    const company = companyCode || this.defaultCompanyCode
    const response = await this.safeFetch(`${this.baseUrl}?section=numbering&company=${company}`)
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
    return result.data
  }

  async getWorkflows(companyCode?: string): Promise<ProjectWorkflow[]> {
    const company = companyCode || this.defaultCompanyCode
    const response = await this.safeFetch(`${this.baseUrl}?section=workflows&company=${company}`)
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
    return result.data
  }

  async getProjectTypes(categoryCode?: string, companyCode?: string): Promise<ProjectType[]> {
    const company = companyCode || this.defaultCompanyCode
    let url = `${this.baseUrl}?section=types&company=${company}`
    if (categoryCode) url += `&category=${categoryCode}`
    
    const response = await this.safeFetch(url)
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
    return result.data
  }

  async createProjectType(type: Omit<ProjectType, 'id'>, companyCode?: string): Promise<ProjectType> {
    const company = companyCode || this.defaultCompanyCode
    const response = await this.safeFetch(`${this.baseUrl}?section=types`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ...type, company_code: company })
    })
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
    return result.data
  }

  async updateProjectType(id: string, type: Partial<ProjectType>): Promise<ProjectType> {
    const response = await this.safeFetch(`${this.baseUrl}?section=types&id=${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(type)
    })
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
    return result.data
  }

  async deleteProjectType(id: string): Promise<void> {
    const response = await this.safeFetch(`${this.baseUrl}?section=types&id=${id}`, {
      method: 'DELETE'
    })
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
  }

  async createNumberingRule(rule: Omit<NumberingRule, 'id'>, companyCode?: string): Promise<NumberingRule> {
    const company = companyCode || this.defaultCompanyCode
    const response = await this.safeFetch(`${this.baseUrl}?section=numbering`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ...rule, company_code: company })
    })
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
    return result.data
  }

  async updateNumberingRule(id: string, rule: Partial<NumberingRule>): Promise<NumberingRule> {
    const response = await this.safeFetch(`${this.baseUrl}?section=numbering&id=${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(rule)
    })
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
    return result.data
  }

  async deleteNumberingRule(id: string): Promise<void> {
    const response = await this.safeFetch(`${this.baseUrl}?section=numbering&id=${id}`, {
      method: 'DELETE'
    })
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
  }
}

export const projectConfigService = new ProjectConfigService()