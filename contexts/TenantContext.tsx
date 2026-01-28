import React, { createContext, useContext, useState, useEffect } from 'react';

interface Tenant {
  id: string;
  tenant_code: string;
  tenant_name: string;
  is_active: boolean;
}

interface TenantContextType {
  currentTenant: Tenant | null;
  setCurrentTenant: (tenant: Tenant | null) => void;
  tenants: Tenant[];
  isLoading: boolean;
}

const TenantContext = createContext<TenantContextType | undefined>(undefined);

export function TenantProvider({ children }: { children: React.ReactNode }) {
  const [currentTenant, setCurrentTenant] = useState<Tenant | null>(null);
  const [tenants, setTenants] = useState<Tenant[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    loadTenants();
    loadCurrentTenant();
  }, []);

  const loadTenants = async () => {
    try {
      const response = await fetch('/api/tenants');
      const data = await response.json();
      if (data.success) {
        setTenants(data.data);
      }
    } catch (error) {
      console.error('Failed to load tenants:', error);
    }
  };

  const loadCurrentTenant = () => {
    const stored = localStorage.getItem('currentTenant');
    if (stored) {
      setCurrentTenant(JSON.parse(stored));
    }
    setIsLoading(false);
  };

  const handleSetCurrentTenant = (tenant: Tenant | null) => {
    setCurrentTenant(tenant);
    if (tenant) {
      localStorage.setItem('currentTenant', JSON.stringify(tenant));
    } else {
      localStorage.removeItem('currentTenant');
    }
  };

  return (
    <TenantContext.Provider value={{
      currentTenant,
      setCurrentTenant: handleSetCurrentTenant,
      tenants,
      isLoading
    }}>
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