import { createClient } from '@/lib/supabase/client'

export interface DocumentNumberConfig {
  documentType: string
  subtype: string
  digits: number // 6 or 8
  description: string
}

export class DocumentNumberingService {
  private supabase = createClient()

  // Document type configurations
  private static readonly DOCUMENT_CONFIGS: Record<string, DocumentNumberConfig> = {
    // Procurement (6 digits)
    'MATERIAL_REQ': { documentType: 'MR', subtype: '01', digits: 6, description: 'Material Request - Standard' },
    'MATERIAL_REQ_EMERGENCY': { documentType: 'MR', subtype: '02', digits: 6, description: 'Material Request - Emergency' },
    'PURCHASE_REQ': { documentType: 'PR', subtype: '01', digits: 6, description: 'Purchase Requisition - Standard' },
    'PURCHASE_ORDER': { documentType: 'PO', subtype: '01', digits: 6, description: 'Purchase Order - Standard' },
    
    // Material Movements (8 digits)
    'GOODS_RECEIPT': { documentType: 'GR', subtype: '01', digits: 8, description: 'Goods Receipt - From PO' },
    'GOODS_ISSUE': { documentType: 'GI', subtype: '01', digits: 8, description: 'Goods Issue - To Cost Center' },
    'TRANSFER': { documentType: 'TR', subtype: '01', digits: 8, description: 'Transfer - Plant to Plant' },
    'MATERIAL_ISSUE': { documentType: 'MI', subtype: '01', digits: 8, description: 'Material Issue - To Production' },
    'REVERSAL': { documentType: 'RV', subtype: '01', digits: 8, description: 'Reversal - Goods Receipt' },
    
    // Financial Documents (8 digits)
    'CUSTOMER_INVOICE': { documentType: 'CI', subtype: '01', digits: 8, description: 'Customer Invoice - Standard' },
    'VENDOR_INVOICE': { documentType: 'VI', subtype: '01', digits: 8, description: 'Vendor Invoice - Standard' },
    'CUSTOMER_CREDIT': { documentType: 'CC', subtype: '01', digits: 8, description: 'Customer Credit Memo' },
    'VENDOR_CREDIT': { documentType: 'VC', subtype: '01', digits: 8, description: 'Vendor Credit Memo' },
    'PAYMENT_DOCUMENT': { documentType: 'PD', subtype: '01', digits: 8, description: 'Payment - Outgoing' },
    'JOURNAL_ENTRY': { documentType: 'JE', subtype: '01', digits: 8, description: 'Journal Entry - Standard' },
    'GENERAL_DOCUMENT': { documentType: 'GD', subtype: '01', digits: 8, description: 'G/L Document - Standard' },
    'DOWN_PAYMENT': { documentType: 'DP', subtype: '01', digits: 8, description: 'Down Payment - Customer' },
    'RECEIPT_CONFIRMATION': { documentType: 'RC', subtype: '01', digits: 8, description: 'Receipt - Invoice Receipt' },
    'CLEARING_DOCUMENT': { documentType: 'CL', subtype: '01', digits: 8, description: 'Clearing - AR' },
    'ADJUSTMENT_DOCUMENT': { documentType: 'AD', subtype: '01', digits: 6, description: 'Adjustment - Period End' }
  }

  /**
   * Generate document number with 4-digit year format
   * Format: [BASE]-[SUBTYPE]-[YYYY]-[NUMBER]
   * Example: MR-01-2024-000001
   */
  async generateDocumentNumber(
    documentTypeKey: string, 
    companyCode: string, 
    tenantId: string,
    customSubtype?: string
  ): Promise<string> {
    const config = DocumentNumberingService.DOCUMENT_CONFIGS[documentTypeKey]
    if (!config) {
      throw new Error(`Unknown document type: ${documentTypeKey}`)
    }

    const currentYear = new Date().getFullYear().toString()
    const subtype = customSubtype || config.subtype

    const { data, error } = await this.supabase.rpc('get_next_document_number', {
      p_company_code: companyCode,
      p_document_type: config.documentType,
      p_number_range_group: subtype,
      p_fiscal_year: currentYear
    })
    
    if (error || !data) {
      throw new Error(`Failed to generate document number: ${error?.message || 'No data returned'}`)
    }

    return data
  }



  /**
   * Get all available document types
   */
  static getDocumentTypes(): Record<string, DocumentNumberConfig> {
    return DocumentNumberingService.DOCUMENT_CONFIGS
  }

  /**
   * Get document type configuration
   */
  static getDocumentConfig(documentTypeKey: string): DocumentNumberConfig | undefined {
    return DocumentNumberingService.DOCUMENT_CONFIGS[documentTypeKey]
  }

  /**
   * Parse document number into components
   */
  static parseDocumentNumber(documentNumber: string): {
    documentType: string
    subtype: string
    year: string
    sequence: string
  } | null {
    const parts = documentNumber.split('-')
    if (parts.length !== 4) return null

    return {
      documentType: parts[0],
      subtype: parts[1],
      year: parts[2],
      sequence: parts[3]
    }
  }

  /**
   * Validate document number format
   */
  static isValidDocumentNumber(documentNumber: string): boolean {
    const parsed = DocumentNumberingService.parseDocumentNumber(documentNumber)
    if (!parsed) return false

    // Check if document type exists in our configs
    const config = Object.values(DocumentNumberingService.DOCUMENT_CONFIGS)
      .find(c => c.documentType === parsed.documentType)
    
    if (!config) return false

    // Check year format (4 digits)
    if (!/^\d{4}$/.test(parsed.year)) return false

    // Check sequence format (6 or 8 digits)
    const expectedDigits = config.digits
    if (parsed.sequence.length !== expectedDigits) return false
    if (!/^\d+$/.test(parsed.sequence)) return false

    return true
  }
}

// Export singleton instance
export const documentNumberingService = new DocumentNumberingService()