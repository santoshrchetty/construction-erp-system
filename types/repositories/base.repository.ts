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
      .eq('id' as any, id)
      .single()

    if (error) throw error
    return data as any
  }

  async findAll(): Promise<Database['public']['Tables'][T]['Row'][]> {
    const { data, error } = await this.supabase
      .from(this.tableName)
      .select('*')

    if (error) throw error
    return (data || []) as any
  }

  async create(data: Database['public']['Tables'][T]['Insert']): Promise<Database['public']['Tables'][T]['Row']> {
    const { data: result, error } = await this.supabase
      .from(this.tableName)
      .insert(data as any)
      .select()
      .single()

    if (error) throw error
    return result as any
  }

  async update(id: string, data: Database['public']['Tables'][T]['Update']): Promise<Database['public']['Tables'][T]['Row']> {
    const { data: result, error } = await this.supabase
      .from(this.tableName)
      .update(data as any)
      .eq('id' as any, id)
      .select()
      .single()

    if (error) throw error
    return result as any
  }

  async delete(id: string): Promise<void> {
    const { error } = await this.supabase
      .from(this.tableName)
      .delete()
      .eq('id' as any, id)

    if (error) throw error
  }
}