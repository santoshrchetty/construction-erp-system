'use client';

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';

interface TenantContextType {
  tenantId: string | null;
  tenantCode: string | null;
  tenantName: string | null;
  companyCode: string | null;
  setTenant: (tenant: TenantInfo) => void;
  setCompanyCode: (companyCode: string) => void;
  clearTenant: () => void;
  isValidTenant: boolean;
}

interface TenantInfo {
  id: string;
  code: string;
  name: string;
}

const TenantContext = createContext<TenantContextType | undefined>(undefined);

interface TenantProviderProps {
  children: ReactNode;
}

export function TenantProvider({ children }: TenantProviderProps) {
  const [tenantId, setTenantId] = useState<string | null>(null);
  const [tenantCode, setTenantCode] = useState<string | null>(null);
  const [tenantName, setTenantName] = useState<string | null>(null);
  const [companyCode, setCompanyCodeState] = useState<string | null>(null);

  // Load tenant info from localStorage on mount
  useEffect(() => {
    const savedTenant = localStorage.getItem('tenant_info');
    const savedCompany = localStorage.getItem('company_code');
    
    if (savedTenant) {
      try {
        const tenant = JSON.parse(savedTenant);
        setTenantId(tenant.id);
        setTenantCode(tenant.code);
        setTenantName(tenant.name);
      } catch (error) {
        console.error('Failed to parse saved tenant info:', error);
        localStorage.removeItem('tenant_info');
      }
    }
    
    if (savedCompany) {
      setCompanyCodeState(savedCompany);
    }
  }, []);

  const setTenant = (tenant: TenantInfo) => {
    setTenantId(tenant.id);
    setTenantCode(tenant.code);
    setTenantName(tenant.name);
    
    // Save to localStorage
    localStorage.setItem('tenant_info', JSON.stringify(tenant));
  };

  const setCompanyCode = (code: string) => {
    setCompanyCodeState(code);
    localStorage.setItem('company_code', code);
  };

  const clearTenant = () => {
    setTenantId(null);
    setTenantCode(null);
    setTenantName(null);
    setCompanyCodeState(null);
    
    // Clear from localStorage
    localStorage.removeItem('tenant_info');
    localStorage.removeItem('company_code');
  };

  const isValidTenant = Boolean(tenantId && tenantCode && companyCode);

  const value: TenantContextType = {
    tenantId,
    tenantCode,
    tenantName,
    companyCode,
    setTenant,
    setCompanyCode,
    clearTenant,
    isValidTenant,
  };

  return (
    <TenantContext.Provider value={value}>
      {children}
    </TenantContext.Provider>
  );
}

export function useTenant() {
  const context = useContext(TenantContext);
  if (context === undefined) {
    throw new Error('useTenant must be used within a TenantProvider');
  }
  return context;
}

// Hook for API calls that need tenant context
export function useTenantHeaders() {
  const { tenantId, companyCode } = useTenant();
  
  return {
    'x-tenant-id': tenantId || '',
    'x-company-code': companyCode || '',
  };
}

// Utility function to validate tenant access
export function validateTenantAccess(tenantId?: string, companyCode?: string): boolean {
  return Boolean(tenantId && companyCode);
}