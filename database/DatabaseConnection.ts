// Layer 4: Database Connection - database/DatabaseConnection.ts
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

const supabase = createClient(supabaseUrl, supabaseKey);

export class DatabaseConnection {
  static async query(sql: string, params: any[] = []): Promise<{ rows: any[] }> {
    const { data, error } = await supabase.rpc('execute_sql', {
      query: sql,
      parameters: params
    });
    
    if (error) {
      console.error('Supabase query error:', error);
      throw error;
    }
    
    return { rows: data || [] };
  }
}