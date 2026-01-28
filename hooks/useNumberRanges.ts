import { useState, useEffect } from 'react';
import { NumberRangeService } from '../domains/finance/NumberRangeService';
import { NumberRangeRepository } from '../domains/administration/numberRangeRepository';

interface NumberRange {
  company_code: string;
  document_type: string;
  range_from: number;
  range_to: number;
  current_number: number;
  status: 'ACTIVE' | 'INACTIVE' | 'EXHAUSTED';
  year_dependent: boolean;
  fiscal_year?: number;
}

interface NumberRangeStats {
  company_code: string;
  document_type: string;
  total_capacity: number;
  numbers_used: number;
  usage_percentage: number;
  status: string;
  days_since_last_use?: number;
  estimated_days_remaining?: number;
}

interface NumberRangeAlert {
  id: string;
  company_code: string;
  document_type: string;
  alert_type: 'THRESHOLD' | 'EXHAUSTED' | 'INACTIVE';
  message: string;
  created_at: string;
}

const numberRangeRepository = new NumberRangeRepository();
const numberRangeService = new NumberRangeService();

export const useNumberRanges = (companyCode: string) => {
  const [ranges, setRanges] = useState<NumberRange[]>([]);
  const [stats, setStats] = useState<NumberRangeStats[]>([]);
  const [alerts, setAlerts] = useState<NumberRangeAlert[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchRanges = async () => {
    setLoading(true);
    try {
      const data = await numberRangeService.getAllNumberRanges(companyCode);
      setRanges(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const fetchStats = async () => {
    try {
      const data = await numberRangeRepository.getNumberRangeStatistics(companyCode);
      setStats(data);
    } catch (err) {
      console.error('Failed to fetch stats:', err);
    }
  };

  const fetchAlerts = async () => {
    try {
      const data = await numberRangeService.getNumberRangeAlerts(companyCode);
      setAlerts(data);
    } catch (err) {
      console.error('Failed to fetch alerts:', err);
    }
  };

  const getNextNumber = async (documentType: string): Promise<string> => {
    return await numberRangeService.getNextNumber(companyCode, documentType);
  };

  const updateRange = async (documentType: string, updates: Partial<NumberRange>) => {
    await numberRangeService.updateNumberRange(documentType, updates);
    await fetchRanges();
    await fetchStats();
  };

  const configureCompany = async () => {
    await numberRangeRepository.configureCompanyNumberRanges(companyCode);
    await fetchRanges();
    await fetchStats();
  };

  useEffect(() => {
    if (companyCode) {
      fetchRanges();
      fetchStats();
      fetchAlerts();
    }
  }, [companyCode]);

  return {
    ranges,
    stats,
    alerts,
    loading,
    error,
    getNextNumber,
    updateRange,
    configureCompany,
    refresh: () => {
      fetchRanges();
      fetchStats();
      fetchAlerts();
    }
  };
};