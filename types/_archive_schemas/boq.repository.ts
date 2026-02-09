import { SupabaseClient } from '@supabase/supabase-js'
import { Database } from '@/types/supabase/database.types'
import { BaseRepository } from './base.repository'

export class BOQRepository extends BaseRepository {
  constructor(supabase: SupabaseClient<Database>) {
    super(supabase)
  }

  async createCategory(data: any) {
    return this.supabase
      .from('boq_categories')
      .insert(data)
      .select()
      .single()
  }

  async createItem(data: any) {
    return this.supabase
      .from('boq_items')
      .insert(data)
      .select()
      .single()
  }

  async getByProject(projectId: string) {
    return this.supabase
      .from('boq_items')
      .select('*, boq_categories(*)')
      .eq('project_id', projectId)
  }

  async updateItem(id: string, data: any) {
    return this.supabase
      .from('boq_items')
      .update(data)
      .eq('id', id)
      .select()
      .single()
  }

  async deleteItem(id: string) {
    return this.supabase
      .from('boq_items')
      .delete()
      .eq('id', id)
  }

  async getSummary(projectId: string) {
    return this.supabase
      .from('boq_items')
      .select('quantity, unit_rate')
      .eq('project_id', projectId)
  }
}