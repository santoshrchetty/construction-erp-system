// Real-time validation service for business rules
export interface ValidationResult {
  isValid: boolean
  errors: string[]
  warnings: string[]
}

export class RealTimeValidationService {
  // Validate material code uniqueness
  static async validateMaterialCode(materialCode: string, companyCode: string): Promise<ValidationResult> {
    if (!materialCode.trim()) {
      return { isValid: false, errors: ['Material code is required'], warnings: [] }
    }

    try {
      const response = await fetch(`/api/materials?id=${materialCode}&company=${companyCode}`)
      const result = await response.json()
      
      if (result.success && result.data) {
        return { isValid: false, errors: ['Material code already exists'], warnings: [] }
      }
      
      return { isValid: true, errors: [], warnings: [] }
    } catch (error) {
      return { isValid: true, errors: [], warnings: ['Could not validate uniqueness'] }
    }
  }

  // Validate supplier GSTIN format
  static validateGSTIN(gstin: string, stateCode: string): ValidationResult {
    if (!gstin) {
      return { isValid: false, errors: ['GSTIN is required'], warnings: [] }
    }

    const gstinRegex = /^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/
    if (!gstinRegex.test(gstin)) {
      return { isValid: false, errors: ['Invalid GSTIN format'], warnings: [] }
    }

    const gstinStateCode = gstin.substring(0, 2)
    if (gstinStateCode !== stateCode) {
      return { isValid: false, errors: ['GSTIN state code does not match supplier state'], warnings: [] }
    }

    return { isValid: true, errors: [], warnings: [] }
  }

  // Validate HSN code format
  static validateHSNCode(hsnCode: string): ValidationResult {
    if (!hsnCode) {
      return { isValid: false, errors: ['HSN code is required'], warnings: [] }
    }

    const hsnRegex = /^[0-9]{4,8}$/
    if (!hsnRegex.test(hsnCode)) {
      return { isValid: false, errors: ['HSN code must be 4-8 digits'], warnings: [] }
    }

    return { isValid: true, errors: [], warnings: [] }
  }

  // Validate GL account range
  static validateGLAccount(glAccount: string, accountType: string): ValidationResult {
    if (!glAccount) {
      return { isValid: false, errors: ['GL account is required'], warnings: [] }
    }

    const accountRanges = {
      'ASSET': { min: '100000', max: '199999' },
      'LIABILITY': { min: '200000', max: '299999' },
      'EXPENSE': { min: '500000', max: '599999' },
      'REVENUE': { min: '400000', max: '499999' }
    }

    const range = accountRanges[accountType as keyof typeof accountRanges]
    if (range && (glAccount < range.min || glAccount > range.max)) {
      return { 
        isValid: false, 
        errors: [`GL account ${glAccount} is not in valid range for ${accountType} (${range.min}-${range.max})`], 
        warnings: [] 
      }
    }

    return { isValid: true, errors: [], warnings: [] }
  }
}

export const realTimeValidationService = new RealTimeValidationService()