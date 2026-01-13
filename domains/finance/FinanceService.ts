// Enhanced Finance Service - 4-Layer Architecture Compliant
// Business Logic Layer for GL Posting with comprehensive validation

import { FinanceRepository } from '@/data/FinanceRepository'

export interface GLEntry {
  account_code: string
  debit_amount: number
  credit_amount: number
  cost_center?: string
  project_code?: string
  wbs_element?: string
  profit_center?: string
  description: string
  tax_code?: string
  tax_amount?: number
  assignment?: string
  text?: string
}

export interface GLDocument {
  company_code: string
  document_type?: string
  posting_date: string
  document_date: string
  reference?: string
  header_text?: string
  currency_code?: string
  entries: GLEntry[]
}

export interface ValidationResult {
  is_valid: boolean
  error_message?: string
}

export interface PostingResult {
  success: boolean
  document_number?: string
  document_id?: string
  error?: string
}

export class FinanceService {
  private repository: FinanceRepository

  constructor() {
    this.repository = new FinanceRepository()
  }

  // Get Cost Centers for dropdown
  async getCostCenters(companyCode: string): Promise<any[]> {
    try {
      return await this.repository.getCostCenters(companyCode)
    } catch (error) {
      console.error('Error fetching cost centers:', error)
      throw new Error('Failed to fetch cost centers')
    }
  }

  // Get Projects/WBS Elements for dropdown
  async getWBSElements(companyCode: string): Promise<any[]> {
    try {
      return await this.repository.getWBSElements(companyCode)
    } catch (error) {
      console.error('Error fetching WBS elements:', error)
      throw new Error('Failed to fetch WBS elements')
    }
  }

  // Get Profit Centers for dropdown
  async getProfitCenters(companyCode: string): Promise<any[]> {
    try {
      return await this.repository.getProfitCenters(companyCode)
    } catch (error) {
      console.error('Error fetching profit centers:', error)
      throw new Error('Failed to fetch profit centers')
    }
  }

  // Validate GL Posting before submission
  async validateGLPosting(document: GLDocument): Promise<ValidationResult> {
    try {
      // Basic validation
      if (!document.company_code) {
        return { is_valid: false, error_message: 'Company code is required' }
      }

      if (!document.entries || document.entries.length === 0) {
        return { is_valid: false, error_message: 'At least one entry is required' }
      }

      // Calculate totals
      const totalDebit = document.entries.reduce((sum, entry) => sum + (entry.debit_amount || 0), 0)
      const totalCredit = document.entries.reduce((sum, entry) => sum + (entry.credit_amount || 0), 0)

      if (Math.abs(totalDebit - totalCredit) > 0.01) {
        return { 
          is_valid: false, 
          error_message: `Document is not balanced. Debit: ${totalDebit.toFixed(2)}, Credit: ${totalCredit.toFixed(2)}` 
        }
      }

      // Validate each entry has either debit or credit (not both)
      for (const entry of document.entries) {
        if (!entry.account_code) {
          return { is_valid: false, error_message: 'All entries must have an account code' }
        }

        if ((entry.debit_amount > 0 && entry.credit_amount > 0) || 
            (entry.debit_amount === 0 && entry.credit_amount === 0)) {
          return { is_valid: false, error_message: 'Each entry must have either debit or credit amount (not both or neither)' }
        }
      }

      // Database validation using stored procedure
      const dbValidation = await this.repository.validateGLPosting(
        document.company_code,
        document.posting_date,
        document.entries
      )

      return dbValidation
    } catch (error) {
      console.error('Error validating GL posting:', error)
      return { is_valid: false, error_message: 'Validation failed due to system error' }
    }
  }

  // Check user authorization for GL posting
  async checkPostingAuthorization(userId: string, document: GLDocument): Promise<ValidationResult> {
    try {
      // Check if user has authorization for all accounts
      for (const entry of document.entries) {
        const hasAuth = await this.repository.checkAccountAuthorization(
          userId,
          document.company_code,
          entry.account_code,
          'POST',
          Math.max(entry.debit_amount || 0, entry.credit_amount || 0)
        )

        if (!hasAuth) {
          return { 
            is_valid: false, 
            error_message: `No authorization to post to account ${entry.account_code}` 
          }
        }
      }

      return { is_valid: true }
    } catch (error) {
      console.error('Error checking authorization:', error)
      return { is_valid: false, error_message: 'Authorization check failed' }
    }
  }

  // Create GL Posting with full validation and controls
  async createGLPosting(document: GLDocument, userId: string): Promise<PostingResult> {
    try {
      // Step 1: Validate document
      const validation = await this.validateGLPosting(document)
      if (!validation.is_valid) {
        return { success: false, error: validation.error_message }
      }

      // Step 2: Check authorization
      const authorization = await this.checkPostingAuthorization(userId, document)
      if (!authorization.is_valid) {
        return { success: false, error: authorization.error_message }
      }

      // Step 3: Check if approval required
      const totalAmount = document.entries.reduce((sum, entry) => 
        sum + Math.max(entry.debit_amount || 0, entry.credit_amount || 0), 0
      )

      const requiresApproval = await this.repository.checkApprovalRequired(
        document.document_type || 'SA',
        totalAmount
      )

      if (requiresApproval) {
        // Create draft document for approval workflow
        const draftResult = await this.repository.createDraftDocument(document, userId)
        return { 
          success: true, 
          document_number: draftResult.document_number,
          document_id: draftResult.document_id,
          error: 'Document created as draft - approval required'
        }
      }

      // Step 4: Generate document number
      const documentNumber = await this.repository.getNextDocumentNumber(
        document.company_code,
        document.document_type || 'SA'
      )

      // Step 5: Create and post document
      const result = await this.repository.createGLDocument({
        ...document,
        document_number: documentNumber,
        status: 'POSTED'
      }, userId)

      return { 
        success: true, 
        document_number: result.document_number,
        document_id: result.document_id
      }

    } catch (error) {
      console.error('Error creating GL posting:', error)
      return { success: false, error: 'Failed to create GL posting' }
    }
  }

  // Get GL Document for display/edit
  async getGLDocument(documentId: string): Promise<any> {
    try {
      return await this.repository.getGLDocument(documentId)
    } catch (error) {
      console.error('Error fetching GL document:', error)
      throw new Error('Failed to fetch GL document')
    }
  }

  // Reverse GL Document
  async reverseGLDocument(documentId: string, userId: string, reason: string): Promise<PostingResult> {
    try {
      const result = await this.repository.reverseGLDocument(documentId, userId, reason)
      return { success: true, document_number: result.reversal_document_number }
    } catch (error) {
      console.error('Error reversing GL document:', error)
      return { success: false, error: 'Failed to reverse GL document' }
    }
  }

  // Get Companies for dropdown
  async getCompanies(): Promise<any[]> {
    try {
      return await this.repository.getCompanies()
    } catch (error) {
      console.error('Error fetching companies:', error)
      throw new Error('Failed to fetch companies')
    }
  }

  // Get GL Posting Configuration
  async getGLPostingConfig(companyCode: string): Promise<any> {
    try {
      return await this.repository.getGLPostingConfig(companyCode)
    } catch (error) {
      console.error('Error fetching GL posting config:', error)
      throw new Error('Failed to fetch GL posting configuration')
    }
  }

  // Copy Chart of Accounts from another company
  async copyChartOfAccounts(sourceCompany: string, targetCompany: string): Promise<any> {
    try {
      console.log('FinanceService: Copy request', { sourceCompany, targetCompany }) // Debug
      const result = await this.repository.copyChartOfAccounts(sourceCompany, targetCompany)
      console.log('FinanceService: Copy result', result) // Debug
      return result
    } catch (error) {
      console.error('Error copying chart of accounts:', error)
      throw new Error('Failed to copy chart of accounts')
    }
  }
  // Get Chart of Accounts for dropdown
  async getChartOfAccounts(companyCode: string): Promise<any[]> {
    try {
      return await this.repository.getChartOfAccounts(companyCode)
    } catch (error) {
      console.error('Error fetching chart of accounts:', error)
      throw new Error('Failed to fetch chart of accounts')
    }
  }
}