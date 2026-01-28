export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      company_groups: {
        Row: {
          grpcompany_code: string
          grpcompany_name: string
          description: string | null
          is_active: boolean
          created_at: string
        }
        Insert: {
          grpcompany_code: string
          grpcompany_name: string
          description?: string | null
          is_active?: boolean
        }
        Update: {
          grpcompany_name?: string
          description?: string | null
          is_active?: boolean
        }
      }
      company_codes: {
        Row: {
          id: string
          company_code: string
          company_name: string
          grpcompany_code: string
          currency: string | null
          country_code: string | null
          is_active: boolean
          created_at: string
        }
        Insert: {
          id?: string
          company_code: string
          company_name: string
          grpcompany_code: string
          currency?: string | null
          country_code?: string | null
          is_active?: boolean
        }
        Update: {
          company_name?: string
          grpcompany_code?: string
          currency?: string | null
          country_code?: string | null
          is_active?: boolean
        }
      }
      project_categories: {
        Row: {
          id: number
          category_code: string
          category_name: string
          description: string | null
          is_active: boolean
          created_at: string
        }
        Insert: {
          category_code: string
          category_name: string
          description?: string | null
          is_active?: boolean
        }
        Update: {
          category_name?: string
          description?: string | null
          is_active?: boolean
        }
      }
      projects: {
        Row: {
          id: string
          code: string
          name: string
          description: string | null
          category_code: string
          project_type: string | null
          status: string
          start_date: string | null
          planned_end_date: string | null
          budget: number | null
          location: string | null
          company_code: string
          plant_code: string | null
          cost_center: string | null
          profit_center: string | null
          created_at: string
          updated_at: string
          created_by: string
          updated_by: string | null
        }
        Insert: {
          id?: string
          code: string
          name: string
          description?: string | null
          category_code: string
          project_type?: string | null
          status?: string
          start_date?: string | null
          planned_end_date?: string | null
          budget?: number | null
          location?: string | null
          company_code: string
          plant_code?: string | null
          cost_center?: string | null
          profit_center?: string | null
          created_by: string
        }
        Update: {
          code?: string
          name?: string
          description?: string | null
          category_code?: string
          project_type?: string | null
          status?: string
          start_date?: string | null
          planned_end_date?: string | null
          budget?: number | null
          location?: string | null
          company_code?: string
          plant_code?: string | null
          cost_center?: string | null
          profit_center?: string | null
          updated_by?: string | null
        }
      }
      wbs_element: {
        Row: {
          id: string
          wbs_element_code: string
          wbs_element_name: string
          description: string | null
          project_code: string
          parent_wbs_code: string | null
          level: number
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          wbs_element_code: string
          wbs_element_name: string
          description?: string | null
          project_code: string
          parent_wbs_code?: string | null
          level?: number
          is_active?: boolean
        }
        Update: {
          wbs_element_name?: string
          description?: string | null
          parent_wbs_code?: string | null
          level?: number
          is_active?: boolean
        }
      }
      activities: {
        Row: {
          id: string
          activity_code: string
          activity_name: string
          description: string | null
          project_code: string
          wbs_element_code: string | null
          parent_activity_code: string | null
          activity_type: string | null
          status: 'PLANNED' | 'IN_PROGRESS' | 'COMPLETED' | 'ON_HOLD' | 'CANCELLED'
          start_date: string | null
          end_date: string | null
          duration: number | null
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          activity_code: string
          activity_name: string
          description?: string | null
          project_code: string
          wbs_element_code?: string | null
          parent_activity_code?: string | null
          activity_type?: string | null
          status?: 'PLANNED' | 'IN_PROGRESS' | 'COMPLETED' | 'ON_HOLD' | 'CANCELLED'
          start_date?: string | null
          end_date?: string | null
          duration?: number | null
          is_active?: boolean
        }
        Update: {
          activity_name?: string
          description?: string | null
          wbs_element_code?: string | null
          parent_activity_code?: string | null
          activity_type?: string | null
          status?: 'PLANNED' | 'IN_PROGRESS' | 'COMPLETED' | 'ON_HOLD' | 'CANCELLED'
          start_date?: string | null
          end_date?: string | null
          duration?: number | null
          is_active?: boolean
        }
      }
      material_requests: {
        Row: {
          id: string
          request_number: string
          request_type: 'RESERVATION' | 'PURCHASE_REQ' | 'MATERIAL_REQ'
          status: 'DRAFT' | 'SUBMITTED' | 'APPROVED' | 'REJECTED' | 'CONVERTED' | 'FULFILLED' | 'CANCELLED'
          priority: 'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT'
          requested_by: string
          requested_date: string
          required_date: string
          company_code: string
          plant_code: string | null
          cost_center: string | null
          wbs_element: string | null
          project_code: string | null
          storage_location: string | null
          activity_code: string | null
          purpose: string | null
          justification: string | null
          notes: string | null
          created_at: string
          updated_at: string
          created_by: string
          updated_by: string | null
        }
        Insert: {
          id?: string
          request_number: string
          request_type: 'RESERVATION' | 'PURCHASE_REQ' | 'MATERIAL_REQ'
          status?: 'DRAFT' | 'SUBMITTED' | 'APPROVED' | 'REJECTED' | 'CONVERTED' | 'FULFILLED' | 'CANCELLED'
          priority?: 'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT'
          requested_by: string
          requested_date?: string
          required_date: string
          company_code: string
          plant_code?: string | null
          cost_center?: string | null
          wbs_element?: string | null
          project_code?: string | null
          storage_location?: string | null
          activity_code?: string | null
          purpose?: string | null
          justification?: string | null
          notes?: string | null
          created_by: string
        }
        Update: {
          request_type?: 'RESERVATION' | 'PURCHASE_REQ' | 'MATERIAL_REQ'
          status?: 'DRAFT' | 'SUBMITTED' | 'APPROVED' | 'REJECTED' | 'CONVERTED' | 'FULFILLED' | 'CANCELLED'
          priority?: 'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT'
          required_date?: string
          company_code?: string
          plant_code?: string | null
          cost_center?: string | null
          wbs_element?: string | null
          project_code?: string | null
          storage_location?: string | null
          activity_code?: string | null
          purpose?: string | null
          justification?: string | null
          notes?: string | null
          updated_by?: string | null
        }
      }
    }
  }
}

// Derived types for components
export type CompanyGroup = Database['public']['Tables']['company_groups']['Row']
export type CompanyGroupInsert = Database['public']['Tables']['company_groups']['Insert']
export type CompanyGroupUpdate = Database['public']['Tables']['company_groups']['Update']

export type CompanyCode = Database['public']['Tables']['company_codes']['Row']
export type CompanyCodeInsert = Database['public']['Tables']['company_codes']['Insert']
export type CompanyCodeUpdate = Database['public']['Tables']['company_codes']['Update']

export type ProjectCategory = Database['public']['Tables']['project_categories']['Row']
export type ProjectCategoryInsert = Database['public']['Tables']['project_categories']['Insert']
export type ProjectCategoryUpdate = Database['public']['Tables']['project_categories']['Update']

export type Project = Database['public']['Tables']['projects']['Row']
export type ProjectInsert = Database['public']['Tables']['projects']['Insert']
export type ProjectUpdate = Database['public']['Tables']['projects']['Update']

export type WbsElement = Database['public']['Tables']['wbs_element']['Row']
export type WbsElementInsert = Database['public']['Tables']['wbs_element']['Insert']
export type WbsElementUpdate = Database['public']['Tables']['wbs_element']['Update']

export type Activity = Database['public']['Tables']['activities']['Row']
export type ActivityInsert = Database['public']['Tables']['activities']['Insert']
export type ActivityUpdate = Database['public']['Tables']['activities']['Update']

export type MaterialRequest = Database['public']['Tables']['material_requests']['Row']
export type MaterialRequestInsert = Database['public']['Tables']['material_requests']['Insert']
export type MaterialRequestUpdate = Database['public']['Tables']['material_requests']['Update']