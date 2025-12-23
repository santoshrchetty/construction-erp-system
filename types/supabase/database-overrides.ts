import { Database as GeneratedDatabase } from './database.types'

// Extend the generated Database type with missing tables
export interface Database extends GeneratedDatabase {
  public: GeneratedDatabase['public'] & {
    Tables: GeneratedDatabase['public']['Tables'] & {
      // Add missing tables that exist in your schema but not in generated types
      task_dependencies: {
        Row: {
          id: string
          predecessor_task_id: string
          successor_task_id: string
          dependency_type: string
          lag_days: number
          created_at: string
        }
        Insert: {
          id?: string
          predecessor_task_id: string
          successor_task_id: string
          dependency_type: string
          lag_days?: number
          created_at?: string
        }
        Update: {
          id?: string
          predecessor_task_id?: string
          successor_task_id?: string
          dependency_type?: string
          lag_days?: number
          created_at?: string
        }
      }
      stock_movements: {
        Row: {
          id: string
          store_id: string
          stock_item_id: string
          movement_type: string
          quantity: number
          unit_cost: number
          reference_number: string
          reference_type: string
          reference_id: string | null
          movement_date: string
          created_by: string
          notes: string | null
          created_at: string
        }
        Insert: {
          id?: string
          store_id: string
          stock_item_id: string
          movement_type: string
          quantity: number
          unit_cost: number
          reference_number: string
          reference_type: string
          reference_id?: string | null
          movement_date: string
          created_by: string
          notes?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          store_id?: string
          stock_item_id?: string
          movement_type?: string
          quantity?: number
          unit_cost?: number
          reference_number?: string
          reference_type?: string
          reference_id?: string | null
          movement_date?: string
          created_by?: string
          notes?: string | null
          created_at?: string
        }
      }
    }
  }
}