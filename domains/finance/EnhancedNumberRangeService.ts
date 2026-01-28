import { NumberRangeRepository } from '../administration/numberRangeRepository';

export interface UserContext {
  userId: string;
  tenantId: string;
  currentCompanyCode: string;
  assignedCompanies: string[];
  defaultCompany: string;
}

export class EnhancedNumberRangeService {
  private repository: NumberRangeRepository;

  constructor() {
    this.repository = new NumberRangeRepository();
  }

  async getNextNumber(
    tenantId: string,
    companyCode: string, 
    documentType: string, 
    fiscalYear?: string
  ): Promise<string> {
    try {
      // Use tenant-aware function
      const result = await this.repository.getNextNumberWithTenant(
        tenantId, 
        companyCode, 
        documentType, 
        fiscalYear
      );
      return result;
    } catch (error) {
      throw new Error(`Failed to get next number: ${error.message}`);
    }
  }

  async validateUserCompanyAccess(
    userId: string, 
    tenantId: string, 
    companyCode: string
  ): Promise<boolean> {
    return this.repository.validateUserCompanyAccess(userId, tenantId, companyCode);
  }

  // Material Request specific numbering
  async getNextMRNumber(userContext: UserContext, companyCode: string): Promise<string> {
    await this.validateAccess(userContext, companyCode);
    return this.getNextNumber(userContext.tenantId, companyCode, 'MATERIAL_REQUEST');
  }

  // Purchase Requisition specific numbering  
  async getNextPRNumber(userContext: UserContext, companyCode: string): Promise<string> {
    await this.validateAccess(userContext, companyCode);
    return this.getNextNumber(userContext.tenantId, companyCode, 'PURCHASE_REQ');
  }

  // Stock Reservation numbering
  async getNextReservationNumber(userContext: UserContext, companyCode: string): Promise<string> {
    await this.validateAccess(userContext, companyCode);
    return this.getNextNumber(userContext.tenantId, companyCode, 'STOCK_RESERVATION');
  }

  private async validateAccess(userContext: UserContext, companyCode: string): Promise<void> {
    if (!userContext.assignedCompanies.includes(companyCode)) {
      throw new Error(`Access denied to company ${companyCode}`);
    }
  }
}