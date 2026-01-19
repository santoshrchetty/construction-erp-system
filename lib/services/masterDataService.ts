// Master Data API Service for Dropdowns
// File: lib/services/masterDataService.ts

import { createClient } from '@/lib/supabase/server'

export class MasterDataService {
  private supabase: any

  constructor() {
    this.init()
  }

  private async init() {
    this.supabase = await createClient()
  }

  // Get Companies
  async getCompanies() {
    const { data, error } = await this.supabase
      .from('companies')
      .select('company_code, company_name, currency')
      .eq('is_active', true)
      .order('company_name')

    if (error) throw error
    return data || []
  }

  // Get Plants (filtered by company)
  async getPlants(companyCode?: string) {
    let query = this.supabase
      .from('plants')
      .select('plant_code, plant_name, company_code, address')
      .eq('is_active', true)

    if (companyCode) {
      query = query.eq('company_code', companyCode)
    }

    const { data, error } = await query.order('plant_name')
    if (error) throw error
    return data || []
  }

  // Get Cost Centers (filtered by company)
  async getCostCenters(companyCode?: string) {
    let query = this.supabase
      .from('cost_centers')
      .select('cost_center, cost_center_name, company_code, responsible_person')
      .eq('is_active', true)

    if (companyCode) {
      query = query.eq('company_code', companyCode)
    }

    const { data, error } = await query.order('cost_center_name')
    if (error) throw error
    return data || []
  }

  // Get Projects (filtered by company)
  async getProjects(companyCode?: string) {
    let query = this.supabase
      .from('projects')
      .select('project_code, project_name, company_code, status, start_date, end_date')
      .eq('status', 'ACTIVE')

    if (companyCode) {
      query = query.eq('company_code', companyCode)
    }

    const { data, error } = await query.order('project_name')
    if (error) throw error
    return data || []
  }

  // Search Materials (with autocomplete)
  async searchMaterials(searchTerm: string, limit: number = 20) {
    const { data, error } = await this.supabase
      .from('material_master')
      .select('material_code, material_name, base_uom, standard_price, material_group')
      .eq('is_active', true)
      .or(`material_code.ilike.%${searchTerm}%,material_name.ilike.%${searchTerm}%`)
      .limit(limit)
      .order('material_name')

    if (error) throw error
    return data || []
  }

  // Get Material Details (with stock info)
  async getMaterialDetails(materialCode: string, plantCode?: string) {
    // Get material master data
    const { data: material, error: matError } = await this.supabase
      .from('material_master')
      .select('*')
      .eq('material_code', materialCode)
      .single()

    if (matError) throw matError

    // Get stock levels if plant provided
    let stockData = null
    if (plantCode) {
      const { data: stock, error: stockError } = await this.supabase
        .from('material_stock')
        .select('available_quantity, reserved_quantity, unit_of_measure')
        .eq('material_code', materialCode)
        .eq('plant_code', plantCode)
        .single()

      if (!stockError) stockData = stock
    }

    // Get last purchase price
    const { data: lastPO, error: poError } = await this.supabase
      .from('purchase_order_items')
      .select('unit_price, currency')
      .eq('material_code', materialCode)
      .order('created_at', { ascending: false })
      .limit(1)
      .single()

    return {
      ...material,
      stock: stockData,
      last_price: lastPO?.unit_price || material.standard_price,
      currency: lastPO?.currency || 'USD'
    }
  }

  // Get Storage Locations (filtered by plant)
  async getStorageLocations(plantCode?: string) {
    let query = this.supabase
      .from('storage_locations')
      .select('storage_location, location_name, plant_code, location_type')
      .eq('is_active', true)

    if (plantCode) {
      query = query.eq('plant_code', plantCode)
    }

    const { data, error } = await query.order('location_name')
    if (error) throw error
    return data || []
  }

  // Get Vendors (optionally filtered by material)
  async getVendors(materialCode?: string) {
    if (materialCode) {
      // Get vendors who supply this material
      const { data, error } = await this.supabase
        .from('vendor_materials')
        .select(`
          vendor_id,
          vendors (
            vendor_code,
            vendor_name,
            vendor_type
          )
        `)
        .eq('material_code', materialCode)

      if (error) throw error
      return data?.map(v => v.vendors) || []
    } else {
      // Get all active vendors
      const { data, error } = await this.supabase
        .from('vendors')
        .select('vendor_code, vendor_name, vendor_type')
        .eq('is_active', true)
        .order('vendor_name')

      if (error) throw error
      return data || []
    }
  }

  // Get User's Default Values (smart defaults)
  async getUserDefaults(userId: string) {
    const { data, error } = await this.supabase
      .from('user_profiles')
      .select('company_code, default_plant, default_cost_center')
      .eq('id', userId)
      .single()

    if (error) return null
    return data
  }
}
