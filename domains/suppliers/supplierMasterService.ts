// Layer 3: Business Logic - Supplier Master Service
export interface Supplier {
  id?: string
  supplier_code: string
  supplier_name: string
  state_code: string
  gstin: string
  company_code: string
  is_active: boolean
}

class SupplierMasterService {
  private baseUrl = '/api/suppliers'

  async getSuppliers(companyCode?: string): Promise<Supplier[]> {
    const company = companyCode || 'C001'
    const response = await fetch(`${this.baseUrl}?company=${company}`)
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
    return result.data
  }

  async createSupplier(supplier: Omit<Supplier, 'id'>): Promise<Supplier> {
    const response = await fetch(this.baseUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(supplier)
    })
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
    return result.data
  }

  async updateSupplier(id: string, supplier: Partial<Supplier>): Promise<Supplier> {
    const response = await fetch(`${this.baseUrl}?id=${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(supplier)
    })
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
    return result.data
  }

  async searchSuppliers(searchTerm: string, companyCode?: string): Promise<Supplier[]> {
    const company = companyCode || 'C001'
    const response = await fetch(`${this.baseUrl}?company=${company}&search=${searchTerm}`)
    const result = await response.json()
    if (!result.success) throw new Error(result.error)
    return result.data
  }
}

export const supplierMasterService = new SupplierMasterService()