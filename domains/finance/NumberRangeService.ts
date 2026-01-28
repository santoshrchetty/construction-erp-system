import { NumberRangeRepository } from '../administration/numberRangeRepository';

export interface NumberRange {
  id: string;
  company_code: string;
  document_type: string;
  from_number: number;
  to_number: number;
  current_number: number;
  status: 'ACTIVE' | 'INACTIVE' | 'EXHAUSTED' | 'SUSPENDED';
  warning_threshold: number;
  critical_threshold: number;
  external_numbering: boolean;
  prefix?: string;
  suffix?: string;
  year_dependent: boolean;
  last_used_date?: string;
  auto_extend: boolean;
  extend_by: number;
}

export interface NumberRangeAlert {
  id: string;
  company_code: string;
  document_type: string;
  alert_type: 'WARNING' | 'CRITICAL';
  alert_message: string;
  usage_percentage: number;
  is_acknowledged: boolean;
  created_at: string;
}

export interface NumberRangeStatistics {
  company_code: string;
  document_type: string;
  total_capacity: number;
  numbers_used: number;
  usage_percentage: number;
  status: string;
  days_since_last_use?: number;
  estimated_days_remaining?: number;
}

export class NumberRangeService {
  private repository: NumberRangeRepository;

  constructor() {
    this.repository = new NumberRangeRepository();
  }

  async getNextNumber(companyCode: string, documentType: string, fiscalYear?: string): Promise<string> {
    try {
      const result = await this.repository.getNextNumber(companyCode, documentType, fiscalYear);
      return result;
    } catch (error) {
      throw new Error(`Failed to get next number: ${error.message}`);
    }
  }

  async getNumberRanges(companyCode?: string): Promise<NumberRange[]> {
    return this.repository.getNumberRanges(companyCode);
  }

  async createNumberRange(numberRange: Omit<NumberRange, 'id'>): Promise<NumberRange> {
    this.validateNumberRange(numberRange);
    return this.repository.createNumberRange(numberRange);
  }

  async updateNumberRange(id: string, updates: Partial<NumberRange>): Promise<NumberRange> {
    if (updates.from_number !== undefined || updates.to_number !== undefined || updates.current_number !== undefined) {
      const existing = await this.repository.getNumberRangeById(id);
      const updated = { ...existing, ...updates };
      this.validateNumberRange(updated);
    }
    return this.repository.updateNumberRange(id, updates);
  }

  async getAlerts(companyCode?: string, unacknowledgedOnly: boolean = true): Promise<NumberRangeAlert[]> {
    return this.repository.getAlerts(companyCode, unacknowledgedOnly);
  }

  async acknowledgeAlert(alertId: string): Promise<void> {
    return this.repository.acknowledgeAlert(alertId);
  }

  async getStatistics(companyCode?: string): Promise<NumberRangeStatistics[]> {
    return this.repository.getStatistics(companyCode);
  }

  async extendNumberRange(id: string, extendBy?: number): Promise<NumberRange> {
    const numberRange = await this.repository.getNumberRangeById(id);
    const extension = extendBy || numberRange.extend_by;
    
    const updates = {
      to_number: numberRange.to_number + extension,
      status: 'ACTIVE' as const
    };
    
    return this.repository.updateNumberRange(id, updates);
  }

  private validateNumberRange(numberRange: Partial<NumberRange>): void {
    if (numberRange.from_number && numberRange.to_number && numberRange.from_number >= numberRange.to_number) {
      throw new Error('From number must be less than to number');
    }
    
    if (numberRange.current_number && numberRange.from_number && numberRange.current_number < numberRange.from_number) {
      throw new Error('Current number cannot be less than from number');
    }
    
    if (numberRange.current_number && numberRange.to_number && numberRange.current_number > numberRange.to_number) {
      throw new Error('Current number cannot be greater than to number');
    }
    
    if (numberRange.warning_threshold && (numberRange.warning_threshold < 0 || numberRange.warning_threshold > 100)) {
      throw new Error('Warning threshold must be between 0 and 100');
    }
    
    if (numberRange.critical_threshold && (numberRange.critical_threshold < 0 || numberRange.critical_threshold > 100)) {
      throw new Error('Critical threshold must be between 0 and 100');
    }
  }
}