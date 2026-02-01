import { createClient } from '@/lib/supabase/client'

export interface MasterDataNumberConfig {
  documentType: string
  description: string
  rangeStart: number
  rangeEnd: number
}

export class MasterDataNumberingService {
  private supabase = createClient()

  // Master data configurations
  private static readonly MASTER_DATA_CONFIGS: Record<string, MasterDataNumberConfig> = {
    'BUSINESS_PARTNER': { documentType: 'BP', description: 'Business Partner', rangeStart: 10000000, rangeEnd: 19999999 },
    'CUSTOMER': { documentType: 'CUSTOMER', description: 'Customer Master', rangeStart: 20000000, rangeEnd: 29999999 },
    'VENDOR': { documentType: 'VENDOR', description: 'Vendor Master', rangeStart: 30000000, rangeEnd: 39999999 },
    'EMPLOYEE': { documentType: 'EMPLOYEE', description: 'Employee Master', rangeStart: 40000000, rangeEnd: 49999999 },
    'CONTACT': { documentType: 'CONTACT', description: 'Contact Person', rangeStart: 50000000, rangeEnd: 59999999 },
    'MATERIAL': { documentType: 'MATERIAL', description: 'Material Master', rangeStart: 5600000000, rangeEnd: 5699999999 }
  }

  /**
   * Generate master data number
   * Returns 10-digit number (e.g., "0010000001", "5600000001")
   */
  async generateMasterDataNumber(
    masterDataType: string,
    companyCode: string,
    tenantId: string
  ): Promise<string> {
    const config = MasterDataNumberingService.MASTER_DATA_CONFIGS[masterDataType]
    if (!config) {
      throw new Error(`Unknown master data type: ${masterDataType}`)
    }

    try {
      // Use RPC function to get next number
      const { data, error } = await this.supabase.rpc('get_next_number_by_group', {
        p_company_code: companyCode,
        p_document_type: config.documentType,
        p_number_range_group: '01',
        p_fiscal_year: new Date().getFullYear().toString()
      })

      if (error) throw error
      return data
    } catch (error) {
      console.error('Failed to generate master data number:', error)
      throw new Error(`Failed to generate ${config.description} number`)
    }
  }

  /**
   * Validate master data number format
   */
  static isValidMasterDataNumber(number: string, masterDataType: string): boolean {
    const config = MasterDataNumberingService.MASTER_DATA_CONFIGS[masterDataType]
    if (!config) return false

    // Check if it's a 10-digit number
    if (!/^\d{10}$/.test(number)) return false

    const numValue = parseInt(number)
    return numValue >= config.rangeStart && numValue <= config.rangeEnd
  }

  /**
   * Get master data type from number
   */
  static getMasterDataTypeFromNumber(number: string): string | null {
    if (!/^\d{10}$/.test(number)) return null

    const numValue = parseInt(number)
    
    for (const [key, config] of Object.entries(MasterDataNumberingService.MASTER_DATA_CONFIGS)) {
      if (numValue >= config.rangeStart && numValue <= config.rangeEnd) {
        return key
      }
    }
    
    return null
  }

  /**
   * Get all master data configurations
   */
  static getMasterDataConfigs(): Record<string, MasterDataNumberConfig> {
    return MasterDataNumberingService.MASTER_DATA_CONFIGS
  }
}

// Export singleton instance
export const masterDataNumberingService = new MasterDataNumberingService()