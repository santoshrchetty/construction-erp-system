// Layer 4: Data Access Layer - Organisation Configuration Repository
import { createServerClient } from '@supabase/ssr'

export class OrganisationConfigRepository {
  private supabase: any

  constructor(supabase: any) {
    this.supabase = supabase
  }

  async getCompanyCodes() {
    const { data, error } = await this.supabase
      .from('company_codes')
      .select('*')
      .order('company_code')
    
    if (error) throw error
    return data || []
  }

  async getControllingAreas() {
    const { data, error } = await this.supabase
      .from('controlling_areas')
      .select('*')
      .order('cocarea_code')
    
    if (error) throw error
    return data || []
  }

  async getPlants() {
    const { data, error } = await this.supabase
      .from('plants')
      .select('*')
      .order('plant_code')
    
    if (error) throw error
    return data || []
  }

  async getCostCenters() {
    const { data, error } = await this.supabase
      .from('cost_centers')
      .select('*')
      .order('cost_center_code')
    
    if (error) throw error
    return data || []
  }

  async getProfitCenters() {
    const { data, error } = await this.supabase
      .from('profit_centers')
      .select('*')
      .order('profit_center_code')
    
    if (error) throw error
    return data || []
  }

  async getPurchasingOrgs() {
    const { data, error } = await this.supabase
      .from('purchasing_organizations')
      .select('*')
      .order('porg_code')
    
    if (error) throw error
    return data || []
  }

  async getStorageLocations() {
    const { data, error } = await this.supabase
      .from('storage_locations')
      .select('*')
      .order('sloc_code')
    
    if (error) throw error
    return data || []
  }

  async getDepartments() {
    const { data, error } = await this.supabase
      .from('departments')
      .select('*')
      .order('name')
    
    if (error) throw error
    return data || []
  }

  async createObject(tableName: string, data: any) {
    const { data: result, error } = await this.supabase
      .from(tableName)
      .insert([data])
      .select()
      .single()
    
    if (error) throw error
    return result
  }

  async updateObject(tableName: string, id: string, data: any) {
    const { data: result, error } = await this.supabase
      .from(tableName)
      .update(data)
      .eq('id', id)
      .select()
      .single()
    
    if (error) throw error
    return result
  }
}