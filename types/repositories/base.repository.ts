import { SupabaseClient } from '@supabase/supabase-js'
import { Database } from '../supabase/database.types'

interface UserContext {
  userId: string
  role: string
}

export abstract class BaseRepository<T extends keyof Database['public']['Tables']> {
  protected supabase: SupabaseClient<Database>
  protected tableName: T
  protected userContext?: UserContext

  constructor(supabase: SupabaseClient<Database>, tableName: T, userContext?: UserContext) {
    this.supabase = supabase
    this.tableName = tableName
    this.userContext = userContext
  }

  async findById(id: string): Promise<Database['public']['Tables'][T]['Row'] | null> {
    const { data, error } = await this.supabase
      .from(this.tableName)
      .select('*')
      .eq('id', id)
      .single()

    if (error) throw error
    return data
  }

  async findAll(): Promise<Database['public']['Tables'][T]['Row'][]> {
    const { data, error } = await this.supabase
      .from(this.tableName)
      .select('*')

    if (error) throw error
    return data || []
  }

  async create(data: Database['public']['Tables'][T]['Insert']): Promise<Database['public']['Tables'][T]['Row']> {
    const { data: result, error } = await this.supabase
      .from(this.tableName)
      .insert(data)
      .select()
      .single()

    if (error) throw error
    return result
  }

  async update(id: string, data: Database['public']['Tables'][T]['Update']): Promise<Database['public']['Tables'][T]['Row']> {
    const { data: result, error } = await this.supabase
      .from(this.tableName)
      .update(data)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error
    return result
  }

  async delete(id: string): Promise<void> {
    const { error } = await this.supabase
      .from(this.tableName)
      .delete()
      .eq('id', id)

    if (error) throw error
  }
}