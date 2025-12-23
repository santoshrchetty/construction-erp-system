import { SupabaseClient } from '@supabase/supabase-js'
import { Database } from '../supabase/database.types'
import { BaseRepository } from './base.repository'

type PurchaseRequisitionRow = Database['public']['Tables']['purchase_requisitions']['Row']
type VendorQuotationRow = Database['public']['Tables']['vendor_quotations']['Row']
type SubcontractOrderRow = Database['public']['Tables']['subcontract_orders']['Row']
type CostTransactionRow = Database['public']['Tables']['cost_transactions']['Row']

export class PurchaseRequisitionRepository extends BaseRepository {
  constructor(supabase: SupabaseClient<Database>) {
    super(supabase)
  }

  async createWithLines(prData: any, lines: any[]) {
    const { data: pr, error: prError } = await this.supabase
      .from('purchase_requisitions')
      .insert(prData)
      .select()
      .single()

    if (prError) throw prError

    const prLines = lines.map((line, index) => ({
      pr_id: pr.id,
      line_number: index + 1,
      ...line
    }))

    const { error: linesError } = await this.supabase
      .from('pr_lines')
      .insert(prLines)

    if (linesError) throw linesError

    return pr
  }

  async findPendingApproval(): Promise<PurchaseRequisitionRow[]> {
    const { data, error } = await this.supabase
      .from('purchase_requisitions')
      .select(`
        *,
        pr_lines(*),
        projects(name)
      `)
      .eq('status', 'submitted')
      .order('created_at', { ascending: true })

    if (error) throw error
    return data || []
  }

  async findByProject(projectId: string): Promise<PurchaseRequisitionRow[]> {
    const { data, error } = await this.supabase
      .from('purchase_requisitions')
      .select(`
        *,
        pr_lines(*)
      `)
      .eq('project_id', projectId)
      .order('created_at', { ascending: false })

    if (error) throw error
    return data || []
  }

  async findByStatus(status: string): Promise<PurchaseRequisitionRow[]> {
    const { data, error } = await this.supabase
      .from('purchase_requisitions')
      .select(`
        *,
        pr_lines(*),
        projects(name)
      `)
      .eq('status', status)
      .order('created_at', { ascending: false })

    if (error) throw error
    return data || []
  }

  async updateStatus(id: string, status: string, userId?: string, reason?: string) {
    const updateData: any = { status }
    
    if (status === 'approved' && userId) {
      updateData.approved_by = userId
      updateData.approved_date = new Date().toISOString()
    }
    
    if (status === 'rejected' && reason) {
      updateData.rejection_reason = reason
    }

    const { data, error } = await this.supabase
      .from('purchase_requisitions')
      .update(updateData)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return data
  }

  async getWithQuotations(prId: string) {
    const { data, error } = await this.supabase
      .from('purchase_requisitions')
      .select(`
        *,
        pr_lines(
          *,
          vendor_quotations(
            *,
            vendors(name, code)
          )
        )
      `)
      .eq('id', prId)
      .single()

    if (error) throw error
    return data
  }
}

export class VendorQuotationRepository extends BaseRepository {
  constructor(supabase: SupabaseClient<Database>) {
    super(supabase)
  }

  async findByPRLine(prLineId: string): Promise<VendorQuotationRow[]> {
    const { data, error } = await this.supabase
      .from('vendor_quotations')
      .select(`
        *,
        vendors(name, code, rating)
      `)
      .eq('pr_line_id', prLineId)
      .order('quoted_price', { ascending: true })

    if (error) throw error
    return data || []
  }

  async findByVendor(vendorId: string): Promise<VendorQuotationRow[]> {
    const { data, error } = await this.supabase
      .from('vendor_quotations')
      .select(`
        *,
        pr_lines(
          description,
          quantity,
          unit,
          purchase_requisitions(requisition_number, project_id)
        )
      `)
      .eq('vendor_id', vendorId)
      .order('created_at', { ascending: false })

    if (error) throw error
    return data || []
  }

  async selectQuotation(quotationId: string, prLineId: string) {
    // First, unselect all quotations for this PR line
    await this.supabase
      .from('vendor_quotations')
      .update({ is_selected: false })
      .eq('pr_line_id', prLineId)

    // Then select the chosen quotation
    const { data, error } = await this.supabase
      .from('vendor_quotations')
      .update({ is_selected: true })
      .eq('id', quotationId)
      .select()
      .single()

    if (error) throw error
    return data
  }

  async getComparativeAnalysis(prLineId: string) {
    const { data, error } = await this.supabase
      .from('vendor_quotations')
      .select(`
        *,
        vendors(name, code, rating, specializations)
      `)
      .eq('pr_line_id', prLineId)
      .order('quoted_price', { ascending: true })

    if (error) throw error

    // Calculate analysis metrics
    const quotations = data || []
    const prices = quotations.map(q => q.quoted_price).filter(p => p > 0)
    const avgPrice = prices.reduce((sum, price) => sum + price, 0) / prices.length
    const minPrice = Math.min(...prices)
    const maxPrice = Math.max(...prices)

    return {
      quotations,
      analysis: {
        total_quotations: quotations.length,
        average_price: avgPrice,
        min_price: minPrice,
        max_price: maxPrice,
        price_variance: maxPrice - minPrice,
        recommended_vendor: quotations.find(q => q.quoted_price === minPrice)?.vendor_id
      }
    }
  }
}

export class SubcontractRepository extends BaseRepository {
  constructor(supabase: SupabaseClient<Database>) {
    super(supabase)
  }

  async createWithMilestones(subcontractData: any, milestones: any[]) {
    const { data: subcontract, error: scError } = await this.supabase
      .from('subcontract_orders')
      .insert(subcontractData)
      .select()
      .single()

    if (scError) throw scError

    if (milestones.length > 0) {
      const milestonesWithId = milestones.map(milestone => ({
        subcontract_id: subcontract.id,
        ...milestone
      }))

      const { error: milestonesError } = await this.supabase
        .from('subcontract_milestones')
        .insert(milestonesWithId)

      if (milestonesError) throw milestonesError
    }

    return subcontract
  }

  async findByProject(projectId: string): Promise<SubcontractOrderRow[]> {
    const { data, error } = await this.supabase
      .from('subcontract_orders')
      .select(`
        *,
        vendors(name, code),
        subcontract_milestones(*)
      `)
      .eq('project_id', projectId)
      .order('created_at', { ascending: false })

    if (error) throw error
    return data || []
  }

  async findByStatus(status: string): Promise<SubcontractOrderRow[]> {
    const { data, error } = await this.supabase
      .from('subcontract_orders')
      .select(`
        *,
        vendors(name, code),
        projects(name)
      `)
      .eq('status', status)
      .order('start_date', { ascending: true })

    if (error) throw error
    return data || []
  }

  async findByVendor(vendorId: string): Promise<SubcontractOrderRow[]> {
    const { data, error } = await this.supabase
      .from('subcontract_orders')
      .select(`
        *,
        projects(name, code),
        subcontract_milestones(*)
      `)
      .eq('vendor_id', vendorId)
      .order('start_date', { ascending: false })

    if (error) throw error
    return data || []
  }

  async updateMilestone(milestoneId: string, updateData: any) {
    const { data, error } = await this.supabase
      .from('subcontract_milestones')
      .update(updateData)
      .eq('id', milestoneId)
      .select()
      .single()

    if (error) throw error
    return data
  }

  async getProgressSummary(subcontractId: string) {
    const { data: subcontract, error: scError } = await this.supabase
      .from('subcontract_orders')
      .select(`
        *,
        subcontract_milestones(*)
      `)
      .eq('id', subcontractId)
      .single()

    if (scError) throw scError

    const milestones = subcontract.subcontract_milestones || []
    const completedMilestones = milestones.filter(m => m.is_completed)
    const totalValue = milestones.reduce((sum, m) => sum + m.milestone_value, 0)
    const completedValue = completedMilestones.reduce((sum, m) => sum + m.milestone_value, 0)

    return {
      subcontract,
      progress: {
        total_milestones: milestones.length,
        completed_milestones: completedMilestones.length,
        progress_percentage: milestones.length > 0 ? (completedMilestones.length / milestones.length) * 100 : 0,
        value_progress_percentage: totalValue > 0 ? (completedValue / totalValue) * 100 : 0,
        next_milestone: milestones.find(m => !m.is_completed && new Date(m.planned_completion_date) >= new Date()),
        overdue_milestones: milestones.filter(m => !m.is_completed && new Date(m.planned_completion_date) < new Date())
      }
    }
  }
}

export class CostTransactionRepository extends BaseRepository {
  constructor(supabase: SupabaseClient<Database>) {
    super(supabase)
  }

  async findByCostObject(costObjectId: string): Promise<CostTransactionRow[]> {
    const { data, error } = await this.supabase
      .from('cost_transactions')
      .select('*')
      .eq('cost_object_id', costObjectId)
      .order('transaction_date', { ascending: false })

    if (error) throw error
    return data || []
  }

  async findByProject(projectId: string): Promise<CostTransactionRow[]> {
    const { data, error } = await this.supabase
      .from('cost_transactions')
      .select(`
        *,
        cost_objects(code, name)
      `)
      .eq('cost_objects.project_id', projectId)
      .order('transaction_date', { ascending: false })

    if (error) throw error
    return data || []
  }

  async getCostSummary(projectId: string) {
    const { data, error } = await this.supabase
      .from('cost_objects')
      .select(`
        *,
        cost_transactions(*)
      `)
      .eq('project_id', projectId)

    if (error) throw error

    const costObjects = data || []
    const summary = costObjects.map(co => {
      const transactions = co.cost_transactions || []
      const planned = transactions.filter(t => t.transaction_type === 'planned').reduce((sum, t) => sum + t.amount, 0)
      const committed = transactions.filter(t => t.transaction_type === 'committed').reduce((sum, t) => sum + t.amount, 0)
      const actual = transactions.filter(t => t.transaction_type === 'actual').reduce((sum, t) => sum + t.amount, 0)

      return {
        cost_object: co,
        planned_cost: planned,
        committed_cost: committed,
        actual_cost: actual,
        variance: planned - actual,
        commitment_ratio: planned > 0 ? (committed / planned) * 100 : 0,
        spend_ratio: planned > 0 ? (actual / planned) * 100 : 0
      }
    })

    return {
      cost_objects: summary,
      totals: {
        total_planned: summary.reduce((sum, s) => sum + s.planned_cost, 0),
        total_committed: summary.reduce((sum, s) => sum + s.committed_cost, 0),
        total_actual: summary.reduce((sum, s) => sum + s.actual_cost, 0),
        total_variance: summary.reduce((sum, s) => sum + s.variance, 0)
      }
    }
  }

  async createManualPosting(transactionData: any) {
    const { data, error } = await this.supabase
      .from('cost_transactions')
      .insert(transactionData)
      .select()
      .single()

    if (error) throw error

    // Update cost object totals
    await this.updateCostObjectTotals(transactionData.cost_object_id)

    return data
  }

  private async updateCostObjectTotals(costObjectId: string) {
    const transactions = await this.findByCostObject(costObjectId)
    
    const planned = transactions.filter(t => t.transaction_type === 'planned').reduce((sum, t) => sum + t.amount, 0)
    const committed = transactions.filter(t => t.transaction_type === 'committed').reduce((sum, t) => sum + t.amount, 0)
    const actual = transactions.filter(t => t.transaction_type === 'actual').reduce((sum, t) => sum + t.amount, 0)

    await this.supabase
      .from('cost_objects')
      .update({
        budget_amount: planned,
        committed_amount: committed,
        actual_amount: actual,
        updated_at: new Date().toISOString()
      })
      .eq('id', costObjectId)
  }
}