import { SupabaseClient } from '@supabase/supabase-js'
import { Database } from '../supabase/database.types'
import { BaseRepository } from './base.repository'

type VendorRow = Database['public']['Tables']['vendors']['Row']
type PurchaseOrderRow = Database['public']['Tables']['purchase_orders']['Row']

export class VendorRepository extends BaseRepository<'vendors'> {
  constructor(supabase: SupabaseClient<Database>) {
    super(supabase, 'vendors')
  }

  async findByStatus(status: Database['public']['Enums']['vendor_status']): Promise<VendorRow[]> {
    const { data, error } = await this.supabase
      .from('vendors')
      .select('*')
      .eq('status', status)
      .order('name', { ascending: true })

    if (error) throw error
    return data || []
  }

  async findBySpecialization(specialization: string): Promise<VendorRow[]> {
    const { data, error } = await this.supabase
      .from('vendors')
      .select('*')
      .contains('specializations', [specialization])
      .eq('status', 'active')
      .order('rating', { ascending: false })

    if (error) throw error
    return data || []
  }

  async findByCode(code: string): Promise<VendorRow | null> {
    const { data, error } = await this.supabase
      .from('vendors')
      .select('*')
      .eq('code', code)
      .single()

    if (error) throw error
    return data
  }

  async updateRating(id: string, rating: number): Promise<VendorRow> {
    const { data, error } = await this.supabase
      .from('vendors')
      .update({ rating })
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  }

  async getVendorPerformance(vendorId: string): Promise<{
    vendor: VendorRow
    totalOrders: number
    completedOrders: number
    averageDeliveryTime: number
    onTimeDeliveryRate: number
  } | null> {
    const vendor = await this.findById(vendorId)
    if (!vendor) return null

    // This would typically calculate from purchase_orders and goods_receipts
    // For now, returning basic vendor info
    return {
      vendor,
      totalOrders: 0,
      completedOrders: 0,
      averageDeliveryTime: 0,
      onTimeDeliveryRate: 0
    }
  }
}

export class ProcurementRepository extends BaseRepository<'purchase_orders'> {
  constructor(supabase: SupabaseClient<Database>) {
    super(supabase, 'purchase_orders')
  }

  async findByProject(projectId: string): Promise<PurchaseOrderRow[]> {
    const { data, error } = await this.supabase
      .from('purchase_orders')
      .select('*')
      .eq('project_id', projectId)
      .order('issue_date', { ascending: false })

    if (error) throw error
    return data || []
  }

  async findByVendor(vendorId: string): Promise<PurchaseOrderRow[]> {
    const { data, error } = await this.supabase
      .from('purchase_orders')
      .select('*')
      .eq('vendor_id', vendorId)
      .order('issue_date', { ascending: false })

    if (error) throw error
    return data || []
  }

  async findByStatus(status: Database['public']['Enums']['po_status']): Promise<PurchaseOrderRow[]> {
    const { data, error } = await this.supabase
      .from('purchase_orders')
      .select('*')
      .eq('status', status)
      .order('issue_date', { ascending: true })

    if (error) throw error
    return data || []
  }

  async findPendingApproval(): Promise<PurchaseOrderRow[]> {
    const { data, error } = await this.supabase
      .from('purchase_orders')
      .select('*')
      .eq('status', 'pending_approval')
      .order('issue_date', { ascending: true })

    if (error) throw error
    return data || []
  }

  async findOverdueDeliveries(): Promise<PurchaseOrderRow[]> {
    const today = new Date().toISOString().split('T')[0]
    
    const { data, error } = await this.supabase
      .from('purchase_orders')
      .select('*')
      .lt('delivery_date', today)
      .in('status', ['approved', 'sent', 'acknowledged', 'partially_received'])
      .order('delivery_date', { ascending: true })

    if (error) throw error
    return data || []
  }

  async updateStatus(id: string, status: Database['public']['Enums']['po_status']): Promise<PurchaseOrderRow> {
    const { data, error } = await this.supabase
      .from('purchase_orders')
      .update({ status })
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  }

  async approvePO(id: string, approvedBy: string): Promise<PurchaseOrderRow> {
    const { data, error } = await this.supabase
      .from('purchase_orders')
      .update({
        status: 'approved',
        approved_by: approvedBy,
        approved_date: new Date().toISOString()
      })
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  }

  async getPOWithLines(id: string): Promise<{
    po: PurchaseOrderRow
    lines: any[]
  } | null> {
    const po = await this.findById(id)
    if (!po) return null

    const { data: lines, error } = await this.supabase
      .from('po_lines')
      .select('*')
      .eq('po_id', id)
      .order('line_number', { ascending: true })

    if (error) throw error

    return {
      po,
      lines: lines || []
    }
  }
}