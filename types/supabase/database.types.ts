export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "13.0.5"
  }
  public: {
    Tables: {
      account_assignment_categories: {
        Row: {
          category_code: string
          category_name: string | null
          description: string | null
          is_active: boolean | null
        }
        Insert: {
          category_code: string
          category_name?: string | null
          description?: string | null
          is_active?: boolean | null
        }
        Update: {
          category_code?: string
          category_name?: string | null
          description?: string | null
          is_active?: boolean | null
        }
        Relationships: []
      }
      account_assignment_config: {
        Row: {
          assignment_key: string
          assignment_value: string
          company_code: string
          conditions: Json | null
          config_type: string
          created_at: string | null
          id: number
          is_active: boolean | null
        }
        Insert: {
          assignment_key: string
          assignment_value: string
          company_code: string
          conditions?: Json | null
          config_type: string
          created_at?: string | null
          id?: number
          is_active?: boolean | null
        }
        Update: {
          assignment_key?: string
          assignment_value?: string
          company_code?: string
          conditions?: Json | null
          config_type?: string
          created_at?: string | null
          id?: number
          is_active?: boolean | null
        }
        Relationships: []
      }
      account_determination: {
        Row: {
          account_assignment_category: string | null
          account_key_id: string
          company_code: string | null
          company_code_id: string
          gl_account_id: string
          id: string
          is_active: boolean | null
          valuation_class_id: string
        }
        Insert: {
          account_assignment_category?: string | null
          account_key_id: string
          company_code?: string | null
          company_code_id: string
          gl_account_id: string
          id?: string
          is_active?: boolean | null
          valuation_class_id: string
        }
        Update: {
          account_assignment_category?: string | null
          account_key_id?: string
          company_code?: string | null
          company_code_id?: string
          gl_account_id?: string
          id?: string
          is_active?: boolean | null
          valuation_class_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "account_determination_account_key_id_fkey"
            columns: ["account_key_id"]
            isOneToOne: false
            referencedRelation: "account_keys"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "account_determination_company_code_fkey"
            columns: ["company_code"]
            isOneToOne: false
            referencedRelation: "company_codes"
            referencedColumns: ["company_code"]
          },
          {
            foreignKeyName: "account_determination_company_code_fkey"
            columns: ["company_code"]
            isOneToOne: false
            referencedRelation: "v_companies_with_names"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "account_determination_company_code_id_fkey"
            columns: ["company_code_id"]
            isOneToOne: false
            referencedRelation: "company_codes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "account_determination_gl_account_id_fkey"
            columns: ["gl_account_id"]
            isOneToOne: false
            referencedRelation: "chart_of_accounts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "account_determination_valuation_class_id_fkey"
            columns: ["valuation_class_id"]
            isOneToOne: false
            referencedRelation: "valuation_classes"
            referencedColumns: ["id"]
          },
        ]
      }
      account_keys: {
        Row: {
          account_key_code: string
          account_key_name: string
          debit_credit_indicator: string
          description: string | null
          id: string
          is_active: boolean | null
        }
        Insert: {
          account_key_code: string
          account_key_name: string
          debit_credit_indicator: string
          description?: string | null
          id?: string
          is_active?: boolean | null
        }
        Update: {
          account_key_code?: string
          account_key_name?: string
          debit_credit_indicator?: string
          description?: string | null
          id?: string
          is_active?: boolean | null
        }
        Relationships: []
      }
      activities: {
        Row: {
          activity_type: Database["public"]["Enums"]["activity_type"] | null
          actual_duration_days: number | null
          actual_end_date: string | null
          actual_start_date: string | null
          assigned_internal_team: string[] | null
          assigned_resources: string[] | null
          baseline_duration_days: number | null
          baseline_end_date: string | null
          baseline_start_date: string | null
          budget_amount: number | null
          code: string
          cost_rate: number | null
          created_at: string | null
          dependency_type: string | null
          description: string | null
          direct_cost_total: number | null
          direct_equipment_cost: number | null
          direct_expense_cost: number | null
          direct_labor_cost: number | null
          direct_material_cost: number | null
          direct_subcontract_cost: number | null
          duration_days: number | null
          id: string
          is_active: boolean | null
          lag_days: number | null
          name: string
          planned_end_date: string | null
          planned_hours: number | null
          planned_start_date: string | null
          predecessor_activities: string[] | null
          priority: string | null
          progress_percentage: number | null
          project_id: string
          quantity: number | null
          rate: number | null
          requires_po: boolean | null
          responsible_user_id: string | null
          status: string | null
          updated_at: string | null
          vendor_id: string | null
          wbs_node_id: string
        }
        Insert: {
          activity_type?: Database["public"]["Enums"]["activity_type"] | null
          actual_duration_days?: number | null
          actual_end_date?: string | null
          actual_start_date?: string | null
          assigned_internal_team?: string[] | null
          assigned_resources?: string[] | null
          baseline_duration_days?: number | null
          baseline_end_date?: string | null
          baseline_start_date?: string | null
          budget_amount?: number | null
          code: string
          cost_rate?: number | null
          created_at?: string | null
          dependency_type?: string | null
          description?: string | null
          direct_cost_total?: number | null
          direct_equipment_cost?: number | null
          direct_expense_cost?: number | null
          direct_labor_cost?: number | null
          direct_material_cost?: number | null
          direct_subcontract_cost?: number | null
          duration_days?: number | null
          id?: string
          is_active?: boolean | null
          lag_days?: number | null
          name: string
          planned_end_date?: string | null
          planned_hours?: number | null
          planned_start_date?: string | null
          predecessor_activities?: string[] | null
          priority?: string | null
          progress_percentage?: number | null
          project_id: string
          quantity?: number | null
          rate?: number | null
          requires_po?: boolean | null
          responsible_user_id?: string | null
          status?: string | null
          updated_at?: string | null
          vendor_id?: string | null
          wbs_node_id: string
        }
        Update: {
          activity_type?: Database["public"]["Enums"]["activity_type"] | null
          actual_duration_days?: number | null
          actual_end_date?: string | null
          actual_start_date?: string | null
          assigned_internal_team?: string[] | null
          assigned_resources?: string[] | null
          baseline_duration_days?: number | null
          baseline_end_date?: string | null
          baseline_start_date?: string | null
          budget_amount?: number | null
          code?: string
          cost_rate?: number | null
          created_at?: string | null
          dependency_type?: string | null
          description?: string | null
          direct_cost_total?: number | null
          direct_equipment_cost?: number | null
          direct_expense_cost?: number | null
          direct_labor_cost?: number | null
          direct_material_cost?: number | null
          direct_subcontract_cost?: number | null
          duration_days?: number | null
          id?: string
          is_active?: boolean | null
          lag_days?: number | null
          name?: string
          planned_end_date?: string | null
          planned_hours?: number | null
          planned_start_date?: string | null
          predecessor_activities?: string[] | null
          priority?: string | null
          progress_percentage?: number | null
          project_id?: string
          quantity?: number | null
          rate?: number | null
          requires_po?: boolean | null
          responsible_user_id?: string | null
          status?: string | null
          updated_at?: string | null
          vendor_id?: string | null
          wbs_node_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "activities_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "activities_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "activities_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "activities_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activities_vendor_id_fkey"
            columns: ["vendor_id"]
            isOneToOne: false
            referencedRelation: "vendors"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activities_wbs_node_id_fkey"
            columns: ["wbs_node_id"]
            isOneToOne: false
            referencedRelation: "wbs_nodes"
            referencedColumns: ["id"]
          },
        ]
      }
      activity_dependencies: {
        Row: {
          created_at: string | null
          dependency_type: string
          id: string
          lag_days: number | null
          predecessor_activity_id: string
          successor_activity_id: string
        }
        Insert: {
          created_at?: string | null
          dependency_type?: string
          id?: string
          lag_days?: number | null
          predecessor_activity_id: string
          successor_activity_id: string
        }
        Update: {
          created_at?: string | null
          dependency_type?: string
          id?: string
          lag_days?: number | null
          predecessor_activity_id?: string
          successor_activity_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "activity_dependencies_predecessor_activity_id_fkey"
            columns: ["predecessor_activity_id"]
            isOneToOne: false
            referencedRelation: "activities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_dependencies_predecessor_activity_id_fkey"
            columns: ["predecessor_activity_id"]
            isOneToOne: false
            referencedRelation: "activity_variance"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_dependencies_predecessor_activity_id_fkey"
            columns: ["predecessor_activity_id"]
            isOneToOne: false
            referencedRelation: "mv_activities_resource_status"
            referencedColumns: ["activity_id"]
          },
          {
            foreignKeyName: "activity_dependencies_successor_activity_id_fkey"
            columns: ["successor_activity_id"]
            isOneToOne: false
            referencedRelation: "activities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_dependencies_successor_activity_id_fkey"
            columns: ["successor_activity_id"]
            isOneToOne: false
            referencedRelation: "activity_variance"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_dependencies_successor_activity_id_fkey"
            columns: ["successor_activity_id"]
            isOneToOne: false
            referencedRelation: "mv_activities_resource_status"
            referencedColumns: ["activity_id"]
          },
        ]
      }
      activity_equipment: {
        Row: {
          activity_id: string
          actual_end_date: string | null
          actual_start_date: string | null
          consumed_hours: number | null
          created_at: string | null
          equipment_id: string
          hourly_rate: number | null
          id: string
          notes: string | null
          planned_end_date: string | null
          planned_start_date: string | null
          priority_level: string | null
          project_id: string
          required_hours: number
          reserved_hours: number | null
          status: string | null
          total_cost: number | null
          unit_of_measure: string | null
          updated_at: string | null
          wbs_node_id: string | null
        }
        Insert: {
          activity_id: string
          actual_end_date?: string | null
          actual_start_date?: string | null
          consumed_hours?: number | null
          created_at?: string | null
          equipment_id: string
          hourly_rate?: number | null
          id?: string
          notes?: string | null
          planned_end_date?: string | null
          planned_start_date?: string | null
          priority_level?: string | null
          project_id: string
          required_hours: number
          reserved_hours?: number | null
          status?: string | null
          total_cost?: number | null
          unit_of_measure?: string | null
          updated_at?: string | null
          wbs_node_id?: string | null
        }
        Update: {
          activity_id?: string
          actual_end_date?: string | null
          actual_start_date?: string | null
          consumed_hours?: number | null
          created_at?: string | null
          equipment_id?: string
          hourly_rate?: number | null
          id?: string
          notes?: string | null
          planned_end_date?: string | null
          planned_start_date?: string | null
          priority_level?: string | null
          project_id?: string
          required_hours?: number
          reserved_hours?: number | null
          status?: string | null
          total_cost?: number | null
          unit_of_measure?: string | null
          updated_at?: string | null
          wbs_node_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "activity_equipment_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_equipment_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activity_variance"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_equipment_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "mv_activities_resource_status"
            referencedColumns: ["activity_id"]
          },
          {
            foreignKeyName: "activity_equipment_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "activity_equipment_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "activity_equipment_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "activity_equipment_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_equipment_wbs_node_id_fkey"
            columns: ["wbs_node_id"]
            isOneToOne: false
            referencedRelation: "wbs_nodes"
            referencedColumns: ["id"]
          },
        ]
      }
      activity_manpower: {
        Row: {
          activity_id: string
          actual_end_date: string | null
          actual_hours: number | null
          actual_start_date: string | null
          allocated_hours: number | null
          created_at: string | null
          employee_id: string | null
          hourly_rate: number | null
          id: string
          notes: string | null
          planned_end_date: string | null
          planned_start_date: string | null
          priority_level: string | null
          project_id: string
          required_hours: number
          role: string
          status: string | null
          total_cost: number | null
          updated_at: string | null
          wbs_node_id: string | null
        }
        Insert: {
          activity_id: string
          actual_end_date?: string | null
          actual_hours?: number | null
          actual_start_date?: string | null
          allocated_hours?: number | null
          created_at?: string | null
          employee_id?: string | null
          hourly_rate?: number | null
          id?: string
          notes?: string | null
          planned_end_date?: string | null
          planned_start_date?: string | null
          priority_level?: string | null
          project_id: string
          required_hours: number
          role: string
          status?: string | null
          total_cost?: number | null
          updated_at?: string | null
          wbs_node_id?: string | null
        }
        Update: {
          activity_id?: string
          actual_end_date?: string | null
          actual_hours?: number | null
          actual_start_date?: string | null
          allocated_hours?: number | null
          created_at?: string | null
          employee_id?: string | null
          hourly_rate?: number | null
          id?: string
          notes?: string | null
          planned_end_date?: string | null
          planned_start_date?: string | null
          priority_level?: string | null
          project_id?: string
          required_hours?: number
          role?: string
          status?: string | null
          total_cost?: number | null
          updated_at?: string | null
          wbs_node_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "activity_manpower_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_manpower_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activity_variance"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_manpower_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "mv_activities_resource_status"
            referencedColumns: ["activity_id"]
          },
          {
            foreignKeyName: "activity_manpower_employee_id_fkey"
            columns: ["employee_id"]
            isOneToOne: false
            referencedRelation: "employees"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_manpower_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "activity_manpower_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "activity_manpower_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "activity_manpower_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_manpower_wbs_node_id_fkey"
            columns: ["wbs_node_id"]
            isOneToOne: false
            referencedRelation: "wbs_nodes"
            referencedColumns: ["id"]
          },
        ]
      }
      activity_materials: {
        Row: {
          activity_id: string
          consumed_quantity: number | null
          created_at: string | null
          demand_line_id: string | null
          id: string
          material_id: string
          notes: string | null
          planned_consumption_date: string | null
          priority_level: string | null
          project_id: string
          required_quantity: number
          reservation_id: string | null
          reserved_quantity: number | null
          status: string | null
          total_cost: number | null
          unit_cost: number | null
          unit_of_measure: string
          updated_at: string | null
          wbs_node_id: string | null
        }
        Insert: {
          activity_id: string
          consumed_quantity?: number | null
          created_at?: string | null
          demand_line_id?: string | null
          id?: string
          material_id: string
          notes?: string | null
          planned_consumption_date?: string | null
          priority_level?: string | null
          project_id: string
          required_quantity: number
          reservation_id?: string | null
          reserved_quantity?: number | null
          status?: string | null
          total_cost?: number | null
          unit_cost?: number | null
          unit_of_measure: string
          updated_at?: string | null
          wbs_node_id?: string | null
        }
        Update: {
          activity_id?: string
          consumed_quantity?: number | null
          created_at?: string | null
          demand_line_id?: string | null
          id?: string
          material_id?: string
          notes?: string | null
          planned_consumption_date?: string | null
          priority_level?: string | null
          project_id?: string
          required_quantity?: number
          reservation_id?: string | null
          reserved_quantity?: number | null
          status?: string | null
          total_cost?: number | null
          unit_cost?: number | null
          unit_of_measure?: string
          updated_at?: string | null
          wbs_node_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "activity_materials_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_materials_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activity_variance"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_materials_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "mv_activities_resource_status"
            referencedColumns: ["activity_id"]
          },
          {
            foreignKeyName: "activity_materials_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "activity_materials_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "activity_materials_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "activity_materials_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_materials_wbs_node_id_fkey"
            columns: ["wbs_node_id"]
            isOneToOne: false
            referencedRelation: "wbs_nodes"
            referencedColumns: ["id"]
          },
        ]
      }
      activity_services: {
        Row: {
          activity_id: string
          actual_date: string | null
          created_at: string | null
          duration_hours: number | null
          id: string
          notes: string | null
          planned_end_date: string | null
          planned_start_date: string | null
          priority_level: string | null
          project_id: string
          result: string | null
          result_document_url: string | null
          scheduled_date: string | null
          service_description: string
          service_provider_id: string | null
          service_type: string
          status: string | null
          total_cost: number | null
          unit_cost: number | null
          updated_at: string | null
          wbs_node_id: string | null
        }
        Insert: {
          activity_id: string
          actual_date?: string | null
          created_at?: string | null
          duration_hours?: number | null
          id?: string
          notes?: string | null
          planned_end_date?: string | null
          planned_start_date?: string | null
          priority_level?: string | null
          project_id: string
          result?: string | null
          result_document_url?: string | null
          scheduled_date?: string | null
          service_description: string
          service_provider_id?: string | null
          service_type: string
          status?: string | null
          total_cost?: number | null
          unit_cost?: number | null
          updated_at?: string | null
          wbs_node_id?: string | null
        }
        Update: {
          activity_id?: string
          actual_date?: string | null
          created_at?: string | null
          duration_hours?: number | null
          id?: string
          notes?: string | null
          planned_end_date?: string | null
          planned_start_date?: string | null
          priority_level?: string | null
          project_id?: string
          result?: string | null
          result_document_url?: string | null
          scheduled_date?: string | null
          service_description?: string
          service_provider_id?: string | null
          service_type?: string
          status?: string | null
          total_cost?: number | null
          unit_cost?: number | null
          updated_at?: string | null
          wbs_node_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "activity_services_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_services_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activity_variance"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_services_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "mv_activities_resource_status"
            referencedColumns: ["activity_id"]
          },
          {
            foreignKeyName: "activity_services_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "activity_services_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "activity_services_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "activity_services_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_services_service_provider_id_fkey"
            columns: ["service_provider_id"]
            isOneToOne: false
            referencedRelation: "vendors"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_services_wbs_node_id_fkey"
            columns: ["wbs_node_id"]
            isOneToOne: false
            referencedRelation: "wbs_nodes"
            referencedColumns: ["id"]
          },
        ]
      }
      activity_subcontractors: {
        Row: {
          activity_id: string
          actual_end_date: string | null
          actual_start_date: string | null
          contract_id: string | null
          contract_number: string | null
          contract_value: number | null
          created_at: string | null
          crew_size: number | null
          id: string
          mobilization_date: string | null
          notes: string | null
          paid_to_date: number | null
          performance_rating: number | null
          planned_end_date: string | null
          planned_start_date: string | null
          priority_level: string | null
          progress_percentage: number | null
          project_id: string
          retention_amount: number | null
          scope_of_work: string
          status: string | null
          subcontractor_id: string
          trade: string
          updated_at: string | null
          wbs_node_id: string | null
        }
        Insert: {
          activity_id: string
          actual_end_date?: string | null
          actual_start_date?: string | null
          contract_id?: string | null
          contract_number?: string | null
          contract_value?: number | null
          created_at?: string | null
          crew_size?: number | null
          id?: string
          mobilization_date?: string | null
          notes?: string | null
          paid_to_date?: number | null
          performance_rating?: number | null
          planned_end_date?: string | null
          planned_start_date?: string | null
          priority_level?: string | null
          progress_percentage?: number | null
          project_id: string
          retention_amount?: number | null
          scope_of_work: string
          status?: string | null
          subcontractor_id: string
          trade: string
          updated_at?: string | null
          wbs_node_id?: string | null
        }
        Update: {
          activity_id?: string
          actual_end_date?: string | null
          actual_start_date?: string | null
          contract_id?: string | null
          contract_number?: string | null
          contract_value?: number | null
          created_at?: string | null
          crew_size?: number | null
          id?: string
          mobilization_date?: string | null
          notes?: string | null
          paid_to_date?: number | null
          performance_rating?: number | null
          planned_end_date?: string | null
          planned_start_date?: string | null
          priority_level?: string | null
          progress_percentage?: number | null
          project_id?: string
          retention_amount?: number | null
          scope_of_work?: string
          status?: string | null
          subcontractor_id?: string
          trade?: string
          updated_at?: string | null
          wbs_node_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "activity_subcontractors_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_subcontractors_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activity_variance"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_subcontractors_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "mv_activities_resource_status"
            referencedColumns: ["activity_id"]
          },
          {
            foreignKeyName: "activity_subcontractors_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "activity_subcontractors_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "activity_subcontractors_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "activity_subcontractors_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_subcontractors_subcontractor_id_fkey"
            columns: ["subcontractor_id"]
            isOneToOne: false
            referencedRelation: "vendors"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_subcontractors_wbs_node_id_fkey"
            columns: ["wbs_node_id"]
            isOneToOne: false
            referencedRelation: "wbs_nodes"
            referencedColumns: ["id"]
          },
        ]
      }
      actual_costs: {
        Row: {
          activity_id: string | null
          amount: number
          cost_date: string
          cost_object_id: string
          cost_status: Database["public"]["Enums"]["cost_status"]
          cost_type: Database["public"]["Enums"]["cost_type"]
          created_at: string | null
          created_by: string
          description: string | null
          id: string
          project_id: string
          reference_id: string | null
          reference_number: string | null
          reference_type: string | null
          task_id: string | null
          wbs_node_id: string | null
        }
        Insert: {
          activity_id?: string | null
          amount: number
          cost_date: string
          cost_object_id: string
          cost_status?: Database["public"]["Enums"]["cost_status"]
          cost_type: Database["public"]["Enums"]["cost_type"]
          created_at?: string | null
          created_by: string
          description?: string | null
          id?: string
          project_id: string
          reference_id?: string | null
          reference_number?: string | null
          reference_type?: string | null
          task_id?: string | null
          wbs_node_id?: string | null
        }
        Update: {
          activity_id?: string | null
          amount?: number
          cost_date?: string
          cost_object_id?: string
          cost_status?: Database["public"]["Enums"]["cost_status"]
          cost_type?: Database["public"]["Enums"]["cost_type"]
          created_at?: string | null
          created_by?: string
          description?: string | null
          id?: string
          project_id?: string
          reference_id?: string | null
          reference_number?: string | null
          reference_type?: string | null
          task_id?: string | null
          wbs_node_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "actual_costs_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "actual_costs_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activity_variance"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "actual_costs_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "mv_activities_resource_status"
            referencedColumns: ["activity_id"]
          },
          {
            foreignKeyName: "actual_costs_cost_object_id_fkey"
            columns: ["cost_object_id"]
            isOneToOne: false
            referencedRelation: "cost_objects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "actual_costs_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "actual_costs_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "actual_costs_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "actual_costs_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "actual_costs_task_id_fkey"
            columns: ["task_id"]
            isOneToOne: false
            referencedRelation: "tasks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "actual_costs_wbs_node_id_fkey"
            columns: ["wbs_node_id"]
            isOneToOne: false
            referencedRelation: "wbs_nodes"
            referencedColumns: ["id"]
          },
        ]
      }
      agent_rules: {
        Row: {
          description: string | null
          fallback_rule: string | null
          id: string
          is_active: boolean | null
          resolution_logic: Json
          rule_code: string
          rule_name: string
          rule_type: string
        }
        Insert: {
          description?: string | null
          fallback_rule?: string | null
          id?: string
          is_active?: boolean | null
          resolution_logic: Json
          rule_code: string
          rule_name: string
          rule_type: string
        }
        Update: {
          description?: string | null
          fallback_rule?: string | null
          id?: string
          is_active?: boolean | null
          resolution_logic?: Json
          rule_code?: string
          rule_name?: string
          rule_type?: string
        }
        Relationships: []
      }
      approval_actions: {
        Row: {
          action: string
          action_date: string | null
          approver_id: string
          approver_role: string
          comments: string | null
          created_at: string | null
          delegation_to: string | null
          escalation_reason: string | null
          execution_id: string
          id: string
          level_number: number
        }
        Insert: {
          action: string
          action_date?: string | null
          approver_id: string
          approver_role: string
          comments?: string | null
          created_at?: string | null
          delegation_to?: string | null
          escalation_reason?: string | null
          execution_id: string
          id?: string
          level_number: number
        }
        Update: {
          action?: string
          action_date?: string | null
          approver_id?: string
          approver_role?: string
          comments?: string | null
          created_at?: string | null
          delegation_to?: string | null
          escalation_reason?: string | null
          execution_id?: string
          id?: string
          level_number?: number
        }
        Relationships: [
          {
            foreignKeyName: "approval_actions_execution_id_fkey"
            columns: ["execution_id"]
            isOneToOne: false
            referencedRelation: "approval_executions"
            referencedColumns: ["id"]
          },
        ]
      }
      approval_delegations: {
        Row: {
          amount_limit: number | null
          approval_object_types: string[] | null
          created_at: string | null
          delegate_user_id: string
          delegation_scope: string | null
          delegator_user_id: string
          functional_domains: string[] | null
          id: string
          is_active: boolean | null
          reason: string | null
          valid_from: string
          valid_to: string
        }
        Insert: {
          amount_limit?: number | null
          approval_object_types?: string[] | null
          created_at?: string | null
          delegate_user_id: string
          delegation_scope?: string | null
          delegator_user_id: string
          functional_domains?: string[] | null
          id?: string
          is_active?: boolean | null
          reason?: string | null
          valid_from: string
          valid_to: string
        }
        Update: {
          amount_limit?: number | null
          approval_object_types?: string[] | null
          created_at?: string | null
          delegate_user_id?: string
          delegation_scope?: string | null
          delegator_user_id?: string
          functional_domains?: string[] | null
          id?: string
          is_active?: boolean | null
          reason?: string | null
          valid_from?: string
          valid_to?: string
        }
        Relationships: []
      }
      approval_document_types: {
        Row: {
          created_at: string | null
          customer_id: string
          display_order: number | null
          document_description: string | null
          document_label: string
          document_type: string
          id: string
          is_active: boolean | null
          object_type: string
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          customer_id: string
          display_order?: number | null
          document_description?: string | null
          document_label: string
          document_type: string
          id?: string
          is_active?: boolean | null
          object_type: string
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          customer_id?: string
          display_order?: number | null
          document_description?: string | null
          document_label?: string
          document_type?: string
          id?: string
          is_active?: boolean | null
          object_type?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      approval_executions: {
        Row: {
          completed_at: string | null
          config_id: string
          created_at: string | null
          current_level: number | null
          execution_path: Json
          id: string
          request_id: string
          started_at: string | null
          status: string | null
          total_levels: number
          updated_at: string | null
        }
        Insert: {
          completed_at?: string | null
          config_id: string
          created_at?: string | null
          current_level?: number | null
          execution_path: Json
          id?: string
          request_id: string
          started_at?: string | null
          status?: string | null
          total_levels: number
          updated_at?: string | null
        }
        Update: {
          completed_at?: string | null
          config_id?: string
          created_at?: string | null
          current_level?: number | null
          execution_path?: Json
          id?: string
          request_id?: string
          started_at?: string | null
          status?: string | null
          total_levels?: number
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "approval_executions_config_id_fkey"
            columns: ["config_id"]
            isOneToOne: false
            referencedRelation: "customer_approval_configuration"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "approval_executions_request_id_fkey"
            columns: ["request_id"]
            isOneToOne: false
            referencedRelation: "material_requests"
            referencedColumns: ["id"]
          },
        ]
      }
      approval_field_definitions: {
        Row: {
          created_at: string | null
          customer_id: string
          display_order: number | null
          field_category: string | null
          field_label: string
          field_name: string
          field_type: string
          id: string
          is_active: boolean | null
          is_required: boolean | null
        }
        Insert: {
          created_at?: string | null
          customer_id: string
          display_order?: number | null
          field_category?: string | null
          field_label: string
          field_name: string
          field_type: string
          id?: string
          is_active?: boolean | null
          is_required?: boolean | null
        }
        Update: {
          created_at?: string | null
          customer_id?: string
          display_order?: number | null
          field_category?: string | null
          field_label?: string
          field_name?: string
          field_type?: string
          id?: string
          is_active?: boolean | null
          is_required?: boolean | null
        }
        Relationships: []
      }
      approval_field_options: {
        Row: {
          created_at: string | null
          customer_id: string
          display_order: number | null
          field_definition_id: string
          id: string
          is_active: boolean | null
          option_description: string | null
          option_label: string
          option_value: string
          parent_option_id: string | null
        }
        Insert: {
          created_at?: string | null
          customer_id: string
          display_order?: number | null
          field_definition_id: string
          id?: string
          is_active?: boolean | null
          option_description?: string | null
          option_label: string
          option_value: string
          parent_option_id?: string | null
        }
        Update: {
          created_at?: string | null
          customer_id?: string
          display_order?: number | null
          field_definition_id?: string
          id?: string
          is_active?: boolean | null
          option_description?: string | null
          option_label?: string
          option_value?: string
          parent_option_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "approval_field_options_field_definition_id_fkey"
            columns: ["field_definition_id"]
            isOneToOne: false
            referencedRelation: "approval_field_definitions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "approval_field_options_field_definition_id_fkey"
            columns: ["field_definition_id"]
            isOneToOne: false
            referencedRelation: "mv_approval_field_cache"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "approval_field_options_parent_option_id_fkey"
            columns: ["parent_option_id"]
            isOneToOne: false
            referencedRelation: "approval_field_options"
            referencedColumns: ["id"]
          },
        ]
      }
      approval_instances: {
        Row: {
          approval_flow: Json
          approval_object_document_type: string
          approval_object_type: string
          audit_explanation: Json
          company_code: string
          completed_at: string | null
          country_code: string
          created_at: string | null
          currency: string | null
          department_code: string
          document_id: string
          document_value: number | null
          id: string
          plant_code: string | null
          project_code: string | null
          requestor_user_id: string
          resolved_pattern: string
          resolved_strategy: string
          status: string | null
        }
        Insert: {
          approval_flow: Json
          approval_object_document_type: string
          approval_object_type: string
          audit_explanation: Json
          company_code: string
          completed_at?: string | null
          country_code: string
          created_at?: string | null
          currency?: string | null
          department_code: string
          document_id: string
          document_value?: number | null
          id?: string
          plant_code?: string | null
          project_code?: string | null
          requestor_user_id: string
          resolved_pattern: string
          resolved_strategy: string
          status?: string | null
        }
        Update: {
          approval_flow?: Json
          approval_object_document_type?: string
          approval_object_type?: string
          audit_explanation?: Json
          company_code?: string
          completed_at?: string | null
          country_code?: string
          created_at?: string | null
          currency?: string | null
          department_code?: string
          document_id?: string
          document_value?: number | null
          id?: string
          plant_code?: string | null
          project_code?: string | null
          requestor_user_id?: string
          resolved_pattern?: string
          resolved_strategy?: string
          status?: string | null
        }
        Relationships: []
      }
      approval_level_templates: {
        Row: {
          created_at: string | null
          created_by: string | null
          customer_type: string | null
          description: string | null
          id: string
          industry_type: string | null
          is_active: boolean | null
          is_public: boolean | null
          template_name: string
          updated_at: string | null
          usage_count: number | null
        }
        Insert: {
          created_at?: string | null
          created_by?: string | null
          customer_type?: string | null
          description?: string | null
          id?: string
          industry_type?: string | null
          is_active?: boolean | null
          is_public?: boolean | null
          template_name: string
          updated_at?: string | null
          usage_count?: number | null
        }
        Update: {
          created_at?: string | null
          created_by?: string | null
          customer_type?: string | null
          description?: string | null
          id?: string
          industry_type?: string | null
          is_active?: boolean | null
          is_public?: boolean | null
          template_name?: string
          updated_at?: string | null
          usage_count?: number | null
        }
        Relationships: []
      }
      approval_object_registry: {
        Row: {
          approval_object_document_type: string
          approval_object_type: string
          check_for_value: boolean | null
          created_at: string | null
          default_strategy: string | null
          id: string
          is_active: boolean | null
          object_name: string
          required_functional_domains: string[] | null
        }
        Insert: {
          approval_object_document_type: string
          approval_object_type: string
          check_for_value?: boolean | null
          created_at?: string | null
          default_strategy?: string | null
          id?: string
          is_active?: boolean | null
          object_name: string
          required_functional_domains?: string[] | null
        }
        Update: {
          approval_object_document_type?: string
          approval_object_type?: string
          check_for_value?: boolean | null
          created_at?: string | null
          default_strategy?: string | null
          id?: string
          is_active?: boolean | null
          object_name?: string
          required_functional_domains?: string[] | null
        }
        Relationships: []
      }
      approval_object_types: {
        Row: {
          created_at: string | null
          customer_id: string
          default_strategy: string | null
          description: string | null
          form_config: Json | null
          id: string
          is_active: boolean | null
          object_category: string
          object_name: string
          object_type: string
          required_fields: Json | null
          validation_rules: Json | null
        }
        Insert: {
          created_at?: string | null
          customer_id: string
          default_strategy?: string | null
          description?: string | null
          form_config?: Json | null
          id?: string
          is_active?: boolean | null
          object_category: string
          object_name: string
          object_type: string
          required_fields?: Json | null
          validation_rules?: Json | null
        }
        Update: {
          created_at?: string | null
          customer_id?: string
          default_strategy?: string | null
          description?: string | null
          form_config?: Json | null
          id?: string
          is_active?: boolean | null
          object_category?: string
          object_name?: string
          object_type?: string
          required_fields?: Json | null
          validation_rules?: Json | null
        }
        Relationships: []
      }
      approval_policies: {
        Row: {
          amount_thresholds: Json | null
          approval_context: Json | null
          approval_object_document_type: string
          approval_object_type: string
          approval_pattern: string
          approval_strategy: string
          business_rules: Json | null
          company_code: string | null
          context_specificity: number | null
          country_code: string | null
          created_at: string | null
          custom_fields: Json | null
          customer_id: string
          department_code: string | null
          document_category: string | null
          document_discipline: string | null
          escalation_rules: Json | null
          functional_domains: Json | null
          id: string
          is_active: boolean | null
          location_code: string | null
          object_category: string | null
          object_subtype: string | null
          plant_code: string | null
          policy_name: string
          priority_order: number | null
          project_code: string | null
          purchase_org: string | null
          revision_type: string | null
          selected_countries: Json | null
          selected_departments: Json | null
          selected_plants: Json | null
          selected_projects: Json | null
          selected_purchase_orgs: Json | null
          selected_storage_locations: Json | null
          special_conditions: Json | null
          storage_location_code: string | null
          storage_type: string | null
        }
        Insert: {
          amount_thresholds?: Json | null
          approval_context?: Json | null
          approval_object_document_type: string
          approval_object_type: string
          approval_pattern: string
          approval_strategy: string
          business_rules?: Json | null
          company_code?: string | null
          context_specificity?: number | null
          country_code?: string | null
          created_at?: string | null
          custom_fields?: Json | null
          customer_id: string
          department_code?: string | null
          document_category?: string | null
          document_discipline?: string | null
          escalation_rules?: Json | null
          functional_domains?: Json | null
          id?: string
          is_active?: boolean | null
          location_code?: string | null
          object_category?: string | null
          object_subtype?: string | null
          plant_code?: string | null
          policy_name: string
          priority_order?: number | null
          project_code?: string | null
          purchase_org?: string | null
          revision_type?: string | null
          selected_countries?: Json | null
          selected_departments?: Json | null
          selected_plants?: Json | null
          selected_projects?: Json | null
          selected_purchase_orgs?: Json | null
          selected_storage_locations?: Json | null
          special_conditions?: Json | null
          storage_location_code?: string | null
          storage_type?: string | null
        }
        Update: {
          amount_thresholds?: Json | null
          approval_context?: Json | null
          approval_object_document_type?: string
          approval_object_type?: string
          approval_pattern?: string
          approval_strategy?: string
          business_rules?: Json | null
          company_code?: string | null
          context_specificity?: number | null
          country_code?: string | null
          created_at?: string | null
          custom_fields?: Json | null
          customer_id?: string
          department_code?: string | null
          document_category?: string | null
          document_discipline?: string | null
          escalation_rules?: Json | null
          functional_domains?: Json | null
          id?: string
          is_active?: boolean | null
          location_code?: string | null
          object_category?: string | null
          object_subtype?: string | null
          plant_code?: string | null
          policy_name?: string
          priority_order?: number | null
          project_code?: string | null
          purchase_org?: string | null
          revision_type?: string | null
          selected_countries?: Json | null
          selected_departments?: Json | null
          selected_plants?: Json | null
          selected_projects?: Json | null
          selected_purchase_orgs?: Json | null
          selected_storage_locations?: Json | null
          special_conditions?: Json | null
          storage_location_code?: string | null
          storage_type?: string | null
        }
        Relationships: []
      }
      approval_steps: {
        Row: {
          action_date: string | null
          approval_domain: string | null
          approval_limit_used: number | null
          approval_scope: string
          approval_type: string
          approver_role: string
          approver_user_id: string
          comments: string | null
          created_at: string | null
          execution_mode: string | null
          id: string
          instance_id: string
          parallel_group: number | null
          sequence_number: number
          status: string | null
        }
        Insert: {
          action_date?: string | null
          approval_domain?: string | null
          approval_limit_used?: number | null
          approval_scope: string
          approval_type: string
          approver_role: string
          approver_user_id: string
          comments?: string | null
          created_at?: string | null
          execution_mode?: string | null
          id?: string
          instance_id: string
          parallel_group?: number | null
          sequence_number: number
          status?: string | null
        }
        Update: {
          action_date?: string | null
          approval_domain?: string | null
          approval_limit_used?: number | null
          approval_scope?: string
          approval_type?: string
          approver_role?: string
          approver_user_id?: string
          comments?: string | null
          created_at?: string | null
          execution_mode?: string | null
          id?: string
          instance_id?: string
          parallel_group?: number | null
          sequence_number?: number
          status?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "approval_steps_instance_id_fkey"
            columns: ["instance_id"]
            isOneToOne: false
            referencedRelation: "approval_instances"
            referencedColumns: ["id"]
          },
        ]
      }
      authorization_audit_log: {
        Row: {
          access_granted: boolean
          auth_object_name: string
          id: string
          ip_address: unknown
          session_id: string | null
          timestamp: string | null
          user_agent: string | null
          user_id: string
        }
        Insert: {
          access_granted: boolean
          auth_object_name: string
          id?: string
          ip_address?: unknown
          session_id?: string | null
          timestamp?: string | null
          user_agent?: string | null
          user_id: string
        }
        Update: {
          access_granted?: boolean
          auth_object_name?: string
          id?: string
          ip_address?: unknown
          session_id?: string | null
          timestamp?: string | null
          user_agent?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_audit_user"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      authorization_fields: {
        Row: {
          auth_object_id: string
          created_at: string | null
          field_description: string | null
          field_name: string
          field_values: string[]
          id: string
          is_required: boolean | null
        }
        Insert: {
          auth_object_id: string
          created_at?: string | null
          field_description?: string | null
          field_name: string
          field_values: string[]
          id?: string
          is_required?: boolean | null
        }
        Update: {
          auth_object_id?: string
          created_at?: string | null
          field_description?: string | null
          field_name?: string
          field_values?: string[]
          id?: string
          is_required?: boolean | null
        }
        Relationships: [
          {
            foreignKeyName: "authorization_fields_auth_object_id_fkey"
            columns: ["auth_object_id"]
            isOneToOne: false
            referencedRelation: "authorization_objects"
            referencedColumns: ["id"]
          },
        ]
      }
      authorization_objects: {
        Row: {
          created_at: string | null
          description: string
          id: string
          is_active: boolean | null
          module: string
          object_name: string
        }
        Insert: {
          created_at?: string | null
          description: string
          id?: string
          is_active?: boolean | null
          module: string
          object_name: string
        }
        Update: {
          created_at?: string | null
          description?: string
          id?: string
          is_active?: boolean | null
          module?: string
          object_name?: string
        }
        Relationships: []
      }
      boq_categories: {
        Row: {
          code: string
          description: string | null
          id: string
          name: string
          parent_category_id: string | null
          project_id: string
          sequence_order: number | null
        }
        Insert: {
          code: string
          description?: string | null
          id?: string
          name: string
          parent_category_id?: string | null
          project_id: string
          sequence_order?: number | null
        }
        Update: {
          code?: string
          description?: string | null
          id?: string
          name?: string
          parent_category_id?: string | null
          project_id?: string
          sequence_order?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "boq_categories_parent_category_id_fkey"
            columns: ["parent_category_id"]
            isOneToOne: false
            referencedRelation: "boq_categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "boq_categories_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "boq_categories_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "boq_categories_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "boq_categories_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
        ]
      }
      boq_items: {
        Row: {
          amount: number | null
          category_id: string
          created_at: string | null
          description: string
          id: string
          is_provisional: boolean | null
          item_code: string
          project_id: string
          quantity: number
          rate: number
          specification: string | null
          unit: string
          updated_at: string | null
          wbs_node_id: string | null
        }
        Insert: {
          amount?: number | null
          category_id: string
          created_at?: string | null
          description: string
          id?: string
          is_provisional?: boolean | null
          item_code: string
          project_id: string
          quantity: number
          rate: number
          specification?: string | null
          unit: string
          updated_at?: string | null
          wbs_node_id?: string | null
        }
        Update: {
          amount?: number | null
          category_id?: string
          created_at?: string | null
          description?: string
          id?: string
          is_provisional?: boolean | null
          item_code?: string
          project_id?: string
          quantity?: number
          rate?: number
          specification?: string | null
          unit?: string
          updated_at?: string | null
          wbs_node_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "boq_items_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "boq_categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "boq_items_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "boq_items_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "boq_items_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "boq_items_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "boq_items_wbs_node_id_fkey"
            columns: ["wbs_node_id"]
            isOneToOne: false
            referencedRelation: "wbs_nodes"
            referencedColumns: ["id"]
          },
        ]
      }
      capital_goods_itc_tracking: {
        Row: {
          company_code: string
          created_at: string | null
          deferred_itc_amount: number
          id: string
          immediate_itc_amount: number
          material_code: string
          purchase_date: string
          purchase_document: string
          remaining_itc: number
          total_itc_amount: number
        }
        Insert: {
          company_code: string
          created_at?: string | null
          deferred_itc_amount: number
          id?: string
          immediate_itc_amount: number
          material_code: string
          purchase_date: string
          purchase_document: string
          remaining_itc: number
          total_itc_amount: number
        }
        Update: {
          company_code?: string
          created_at?: string | null
          deferred_itc_amount?: number
          id?: string
          immediate_itc_amount?: number
          material_code?: string
          purchase_date?: string
          purchase_document?: string
          remaining_itc?: number
          total_itc_amount?: number
        }
        Relationships: []
      }
      chart_of_accounts: {
        Row: {
          account_code: string | null
          account_name: string | null
          account_type: string | null
          balance_sheet_account: boolean | null
          coa_code: string
          coa_name: string
          company_code: string | null
          cost_category: string | null
          cost_element_category: string | null
          cost_relevant: boolean | null
          country: string | null
          created_at: string | null
          currency: string | null
          description: string | null
          id: string
          is_active: boolean | null
        }
        Insert: {
          account_code?: string | null
          account_name?: string | null
          account_type?: string | null
          balance_sheet_account?: boolean | null
          coa_code: string
          coa_name: string
          company_code?: string | null
          cost_category?: string | null
          cost_element_category?: string | null
          cost_relevant?: boolean | null
          country?: string | null
          created_at?: string | null
          currency?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
        }
        Update: {
          account_code?: string | null
          account_name?: string | null
          account_type?: string | null
          balance_sheet_account?: boolean | null
          coa_code?: string
          coa_name?: string
          company_code?: string | null
          cost_category?: string | null
          cost_element_category?: string | null
          cost_relevant?: boolean | null
          country?: string | null
          created_at?: string | null
          currency?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
        }
        Relationships: []
      }
      companies: {
        Row: {
          company_id: string
          company_name: string
          country: string | null
          created_at: string | null
          industry: string | null
          is_active: boolean | null
        }
        Insert: {
          company_id?: string
          company_name: string
          country?: string | null
          created_at?: string | null
          industry?: string | null
          is_active?: boolean | null
        }
        Update: {
          company_id?: string
          company_name?: string
          country?: string | null
          created_at?: string | null
          industry?: string | null
          is_active?: boolean | null
        }
        Relationships: []
      }
      company_codes: {
        Row: {
          address: string | null
          company_code: string
          company_id: string | null
          company_name: string
          controlling_area_code: string | null
          country: string | null
          country_code: string | null
          created_at: string | null
          currency: string | null
          id: string
          is_active: boolean | null
          legal_entity_name: string
          local_currency: string | null
          reporting_currency: string | null
          tax_number: string | null
        }
        Insert: {
          address?: string | null
          company_code: string
          company_id?: string | null
          company_name: string
          controlling_area_code?: string | null
          country?: string | null
          country_code?: string | null
          created_at?: string | null
          currency?: string | null
          id?: string
          is_active?: boolean | null
          legal_entity_name: string
          local_currency?: string | null
          reporting_currency?: string | null
          tax_number?: string | null
        }
        Update: {
          address?: string | null
          company_code?: string
          company_id?: string | null
          company_name?: string
          controlling_area_code?: string | null
          country?: string | null
          country_code?: string | null
          created_at?: string | null
          currency?: string | null
          id?: string
          is_active?: boolean | null
          legal_entity_name?: string
          local_currency?: string | null
          reporting_currency?: string | null
          tax_number?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "company_codes_country_code_fkey"
            columns: ["country_code"]
            isOneToOne: false
            referencedRelation: "countries"
            referencedColumns: ["country_code"]
          },
        ]
      }
      company_controlling_areas: {
        Row: {
          company_code_id: string
          controlling_area_id: string
          id: string
          valid_from: string | null
          valid_to: string | null
        }
        Insert: {
          company_code_id: string
          controlling_area_id: string
          id?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Update: {
          company_code_id?: string
          controlling_area_id?: string
          id?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "company_controlling_areas_company_code_id_fkey"
            columns: ["company_code_id"]
            isOneToOne: false
            referencedRelation: "company_codes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "company_controlling_areas_controlling_area_id_fkey"
            columns: ["controlling_area_id"]
            isOneToOne: false
            referencedRelation: "controlling_areas"
            referencedColumns: ["id"]
          },
        ]
      }
      controlling_areas: {
        Row: {
          chart_of_accounts_id: string | null
          cocarea_code: string
          cocarea_name: string
          created_at: string | null
          currency: string
          fiscal_year_variant: string | null
          id: string
          is_active: boolean | null
          updated_at: string | null
        }
        Insert: {
          chart_of_accounts_id?: string | null
          cocarea_code: string
          cocarea_name: string
          created_at?: string | null
          currency?: string
          fiscal_year_variant?: string | null
          id?: string
          is_active?: boolean | null
          updated_at?: string | null
        }
        Update: {
          chart_of_accounts_id?: string | null
          cocarea_code?: string
          cocarea_name?: string
          created_at?: string | null
          currency?: string
          fiscal_year_variant?: string | null
          id?: string
          is_active?: boolean | null
          updated_at?: string | null
        }
        Relationships: []
      }
      cost_centers: {
        Row: {
          company_code: string
          controlling_area_code: string | null
          controlling_area_id: string | null
          cost_center_code: string
          cost_center_name: string
          cost_center_type: string | null
          created_at: string | null
          id: string
          is_active: boolean | null
          profit_center_code: string | null
          profit_center_id: string | null
          responsible_person: string | null
          updated_at: string | null
          valid_from: string | null
          valid_to: string | null
        }
        Insert: {
          company_code: string
          controlling_area_code?: string | null
          controlling_area_id?: string | null
          cost_center_code: string
          cost_center_name: string
          cost_center_type?: string | null
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          profit_center_code?: string | null
          profit_center_id?: string | null
          responsible_person?: string | null
          updated_at?: string | null
          valid_from?: string | null
          valid_to?: string | null
        }
        Update: {
          company_code?: string
          controlling_area_code?: string | null
          controlling_area_id?: string | null
          cost_center_code?: string
          cost_center_name?: string
          cost_center_type?: string | null
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          profit_center_code?: string | null
          profit_center_id?: string | null
          responsible_person?: string | null
          updated_at?: string | null
          valid_from?: string | null
          valid_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "cost_centers_company_code_fkey"
            columns: ["company_code"]
            isOneToOne: false
            referencedRelation: "company_codes"
            referencedColumns: ["company_code"]
          },
          {
            foreignKeyName: "cost_centers_company_code_fkey"
            columns: ["company_code"]
            isOneToOne: false
            referencedRelation: "v_companies_with_names"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "cost_centers_controlling_area_code_fkey"
            columns: ["controlling_area_code"]
            isOneToOne: false
            referencedRelation: "controlling_areas"
            referencedColumns: ["cocarea_code"]
          },
          {
            foreignKeyName: "cost_centers_controlling_area_id_fkey"
            columns: ["controlling_area_id"]
            isOneToOne: false
            referencedRelation: "controlling_areas"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "cost_centers_profit_center_id_fkey"
            columns: ["profit_center_id"]
            isOneToOne: false
            referencedRelation: "profit_centers"
            referencedColumns: ["id"]
          },
        ]
      }
      cost_objects: {
        Row: {
          activity_id: string | null
          actual_amount: number | null
          budget_amount: number | null
          code: string
          committed_amount: number | null
          cost_type: Database["public"]["Enums"]["cost_type"]
          created_at: string | null
          id: string
          is_active: boolean | null
          name: string
          project_id: string
          task_id: string | null
          updated_at: string | null
          wbs_node_id: string | null
        }
        Insert: {
          activity_id?: string | null
          actual_amount?: number | null
          budget_amount?: number | null
          code: string
          committed_amount?: number | null
          cost_type: Database["public"]["Enums"]["cost_type"]
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          name: string
          project_id: string
          task_id?: string | null
          updated_at?: string | null
          wbs_node_id?: string | null
        }
        Update: {
          activity_id?: string | null
          actual_amount?: number | null
          budget_amount?: number | null
          code?: string
          committed_amount?: number | null
          cost_type?: Database["public"]["Enums"]["cost_type"]
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          name?: string
          project_id?: string
          task_id?: string | null
          updated_at?: string | null
          wbs_node_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "cost_objects_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "cost_objects_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activity_variance"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "cost_objects_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "mv_activities_resource_status"
            referencedColumns: ["activity_id"]
          },
          {
            foreignKeyName: "cost_objects_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "cost_objects_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "cost_objects_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "cost_objects_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "cost_objects_task_id_fkey"
            columns: ["task_id"]
            isOneToOne: false
            referencedRelation: "tasks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "cost_objects_wbs_node_id_fkey"
            columns: ["wbs_node_id"]
            isOneToOne: false
            referencedRelation: "wbs_nodes"
            referencedColumns: ["id"]
          },
        ]
      }
      cost_transactions: {
        Row: {
          amount: number
          cost_object_id: string
          created_at: string | null
          created_by: string
          description: string | null
          id: string
          reference_id: string
          reference_type: string
          transaction_date: string
          transaction_type: Database["public"]["Enums"]["cost_status"]
        }
        Insert: {
          amount: number
          cost_object_id: string
          created_at?: string | null
          created_by: string
          description?: string | null
          id?: string
          reference_id: string
          reference_type: string
          transaction_date: string
          transaction_type: Database["public"]["Enums"]["cost_status"]
        }
        Update: {
          amount?: number
          cost_object_id?: string
          created_at?: string | null
          created_by?: string
          description?: string | null
          id?: string
          reference_id?: string
          reference_type?: string
          transaction_date?: string
          transaction_type?: Database["public"]["Enums"]["cost_status"]
        }
        Relationships: [
          {
            foreignKeyName: "cost_transactions_cost_object_id_fkey"
            columns: ["cost_object_id"]
            isOneToOne: false
            referencedRelation: "cost_objects"
            referencedColumns: ["id"]
          },
        ]
      }
      countries: {
        Row: {
          country_code: string
          country_code_3: string | null
          country_name: string
          created_at: string | null
          id: string
          is_active: boolean | null
          region: string | null
        }
        Insert: {
          country_code: string
          country_code_3?: string | null
          country_name: string
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          region?: string | null
        }
        Update: {
          country_code?: string
          country_code_3?: string | null
          country_name?: string
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          region?: string | null
        }
        Relationships: []
      }
      currencies: {
        Row: {
          created_at: string | null
          currency_code: string
          currency_name: string
          currency_symbol: string | null
          decimal_places: number | null
          id: string
          is_active: boolean | null
        }
        Insert: {
          created_at?: string | null
          currency_code: string
          currency_name: string
          currency_symbol?: string | null
          decimal_places?: number | null
          id?: string
          is_active?: boolean | null
        }
        Update: {
          created_at?: string | null
          currency_code?: string
          currency_name?: string
          currency_symbol?: string | null
          decimal_places?: number | null
          id?: string
          is_active?: boolean | null
        }
        Relationships: []
      }
      customer_approval_configuration: {
        Row: {
          auto_approval_rules: Json | null
          bulk_approval_enabled: boolean | null
          config_name: string
          created_at: string | null
          customer_id: string
          document_type: string
          emergency_override_enabled: boolean | null
          emergency_override_roles: string[] | null
          id: string
          is_active: boolean | null
          is_template_based: boolean | null
          parallel_approval_enabled: boolean | null
          template_id: string | null
          updated_at: string | null
        }
        Insert: {
          auto_approval_rules?: Json | null
          bulk_approval_enabled?: boolean | null
          config_name: string
          created_at?: string | null
          customer_id: string
          document_type: string
          emergency_override_enabled?: boolean | null
          emergency_override_roles?: string[] | null
          id?: string
          is_active?: boolean | null
          is_template_based?: boolean | null
          parallel_approval_enabled?: boolean | null
          template_id?: string | null
          updated_at?: string | null
        }
        Update: {
          auto_approval_rules?: Json | null
          bulk_approval_enabled?: boolean | null
          config_name?: string
          created_at?: string | null
          customer_id?: string
          document_type?: string
          emergency_override_enabled?: boolean | null
          emergency_override_roles?: string[] | null
          id?: string
          is_active?: boolean | null
          is_template_based?: boolean | null
          parallel_approval_enabled?: boolean | null
          template_id?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "customer_approval_configuration_template_id_fkey"
            columns: ["template_id"]
            isOneToOne: false
            referencedRelation: "approval_level_templates"
            referencedColumns: ["id"]
          },
        ]
      }
      customer_material_request_config: {
        Row: {
          auto_routing_enabled: boolean | null
          config_name: string
          created_at: string | null
          customer_id: string
          id: string
          intelligence_level: string | null
          is_active: boolean | null
          predictive_approval_enabled: boolean | null
          request_mode: string | null
          smart_thresholds_enabled: boolean | null
          updated_at: string | null
        }
        Insert: {
          auto_routing_enabled?: boolean | null
          config_name: string
          created_at?: string | null
          customer_id: string
          id?: string
          intelligence_level?: string | null
          is_active?: boolean | null
          predictive_approval_enabled?: boolean | null
          request_mode?: string | null
          smart_thresholds_enabled?: boolean | null
          updated_at?: string | null
        }
        Update: {
          auto_routing_enabled?: boolean | null
          config_name?: string
          created_at?: string | null
          customer_id?: string
          id?: string
          intelligence_level?: string | null
          is_active?: boolean | null
          predictive_approval_enabled?: boolean | null
          request_mode?: string | null
          smart_thresholds_enabled?: boolean | null
          updated_at?: string | null
        }
        Relationships: []
      }
      daily_timesheets: {
        Row: {
          approved_at: string | null
          approved_by: string | null
          created_at: string | null
          employee_id: string | null
          id: string
          project_id: string
          rejection_reason: string | null
          status: string | null
          submitted_at: string | null
          supervisor_id: string | null
          timesheet_date: string
          total_cost: number | null
          total_overtime_hours: number | null
          total_regular_hours: number | null
          updated_at: string | null
          vendor_id: string | null
        }
        Insert: {
          approved_at?: string | null
          approved_by?: string | null
          created_at?: string | null
          employee_id?: string | null
          id?: string
          project_id: string
          rejection_reason?: string | null
          status?: string | null
          submitted_at?: string | null
          supervisor_id?: string | null
          timesheet_date: string
          total_cost?: number | null
          total_overtime_hours?: number | null
          total_regular_hours?: number | null
          updated_at?: string | null
          vendor_id?: string | null
        }
        Update: {
          approved_at?: string | null
          approved_by?: string | null
          created_at?: string | null
          employee_id?: string | null
          id?: string
          project_id?: string
          rejection_reason?: string | null
          status?: string | null
          submitted_at?: string | null
          supervisor_id?: string | null
          timesheet_date?: string
          total_cost?: number | null
          total_overtime_hours?: number | null
          total_regular_hours?: number | null
          updated_at?: string | null
          vendor_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "daily_timesheets_approved_by_fkey"
            columns: ["approved_by"]
            isOneToOne: false
            referencedRelation: "employees"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "daily_timesheets_employee_id_fkey"
            columns: ["employee_id"]
            isOneToOne: false
            referencedRelation: "employees"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "daily_timesheets_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "daily_timesheets_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "daily_timesheets_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "daily_timesheets_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "daily_timesheets_supervisor_id_fkey"
            columns: ["supervisor_id"]
            isOneToOne: false
            referencedRelation: "employees"
            referencedColumns: ["id"]
          },
        ]
      }
      demand_headers: {
        Row: {
          cost_object_id: string
          cost_object_type: string
          created_at: string | null
          created_by: string
          demand_number: string
          demand_source_id: string
          demand_source_type: string
          demand_status: string | null
          id: string
          planning_horizon_end: string | null
          planning_horizon_start: string | null
        }
        Insert: {
          cost_object_id: string
          cost_object_type: string
          created_at?: string | null
          created_by: string
          demand_number: string
          demand_source_id: string
          demand_source_type: string
          demand_status?: string | null
          id?: string
          planning_horizon_end?: string | null
          planning_horizon_start?: string | null
        }
        Update: {
          cost_object_id?: string
          cost_object_type?: string
          created_at?: string | null
          created_by?: string
          demand_number?: string
          demand_source_id?: string
          demand_source_type?: string
          demand_status?: string | null
          id?: string
          planning_horizon_end?: string | null
          planning_horizon_start?: string | null
        }
        Relationships: []
      }
      demand_lines: {
        Row: {
          bom_explosion_level: number | null
          demand_header_id: string
          demand_line_id: string | null
          demand_line_type: string
          id: string
          line_status: string | null
          material_code: string
          priority_level: string | null
          required_date: string
          required_quantity: number
          unit_of_measure: string
        }
        Insert: {
          bom_explosion_level?: number | null
          demand_header_id: string
          demand_line_id?: string | null
          demand_line_type: string
          id?: string
          line_status?: string | null
          material_code: string
          priority_level?: string | null
          required_date: string
          required_quantity: number
          unit_of_measure: string
        }
        Update: {
          bom_explosion_level?: number | null
          demand_header_id?: string
          demand_line_id?: string | null
          demand_line_type?: string
          id?: string
          line_status?: string | null
          material_code?: string
          priority_level?: string | null
          required_date?: string
          required_quantity?: number
          unit_of_measure?: string
        }
        Relationships: [
          {
            foreignKeyName: "demand_lines_demand_header_id_fkey"
            columns: ["demand_header_id"]
            isOneToOne: false
            referencedRelation: "demand_headers"
            referencedColumns: ["id"]
          },
        ]
      }
      departments: {
        Row: {
          code: string
          company_code: string
          created_at: string | null
          description: string | null
          id: string
          is_active: boolean | null
          name: string
        }
        Insert: {
          code: string
          company_code: string
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
          name: string
        }
        Update: {
          code?: string
          company_code?: string
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
          name?: string
        }
        Relationships: [
          {
            foreignKeyName: "departments_company_code_fkey"
            columns: ["company_code"]
            isOneToOne: false
            referencedRelation: "company_codes"
            referencedColumns: ["company_code"]
          },
          {
            foreignKeyName: "departments_company_code_fkey"
            columns: ["company_code"]
            isOneToOne: false
            referencedRelation: "v_companies_with_names"
            referencedColumns: ["code"]
          },
        ]
      }
      document_number_ranges: {
        Row: {
          auto_extend: boolean | null
          buffer_size: number | null
          change_document: string | null
          company_code: string
          created_at: string | null
          created_by: string | null
          critical_threshold: number | null
          current_number: string
          description: string | null
          document_type: string
          extend_by: number | null
          external_numbering: boolean | null
          fiscal_year: number
          fiscal_year_variant: string | null
          from_number: number
          id: string
          interval_size: number | null
          last_used_date: string | null
          locked_at: string | null
          locked_by: string | null
          modified_at: string | null
          modified_by: string | null
          number_range_group: string | null
          number_range_object: string
          prefix: string | null
          range_from: string
          range_to: string
          status: string | null
          suffix: string | null
          to_number: number
          transport_request: string | null
          warning_threshold: number | null
          year_dependent: boolean | null
        }
        Insert: {
          auto_extend?: boolean | null
          buffer_size?: number | null
          change_document?: string | null
          company_code: string
          created_at?: string | null
          created_by?: string | null
          critical_threshold?: number | null
          current_number: string
          description?: string | null
          document_type: string
          extend_by?: number | null
          external_numbering?: boolean | null
          fiscal_year: number
          fiscal_year_variant?: string | null
          from_number?: number
          id?: string
          interval_size?: number | null
          last_used_date?: string | null
          locked_at?: string | null
          locked_by?: string | null
          modified_at?: string | null
          modified_by?: string | null
          number_range_group?: string | null
          number_range_object?: string
          prefix?: string | null
          range_from: string
          range_to: string
          status?: string | null
          suffix?: string | null
          to_number?: number
          transport_request?: string | null
          warning_threshold?: number | null
          year_dependent?: boolean | null
        }
        Update: {
          auto_extend?: boolean | null
          buffer_size?: number | null
          change_document?: string | null
          company_code?: string
          created_at?: string | null
          created_by?: string | null
          critical_threshold?: number | null
          current_number?: string
          description?: string | null
          document_type?: string
          extend_by?: number | null
          external_numbering?: boolean | null
          fiscal_year?: number
          fiscal_year_variant?: string | null
          from_number?: number
          id?: string
          interval_size?: number | null
          last_used_date?: string | null
          locked_at?: string | null
          locked_by?: string | null
          modified_at?: string | null
          modified_by?: string | null
          number_range_group?: string | null
          number_range_object?: string
          prefix?: string | null
          range_from?: string
          range_to?: string
          status?: string | null
          suffix?: string | null
          to_number?: number
          transport_request?: string | null
          warning_threshold?: number | null
          year_dependent?: boolean | null
        }
        Relationships: []
      }
      document_types: {
        Row: {
          account_type_allowed: string | null
          approval_amount_limit: number | null
          created_at: string | null
          document_type: string
          document_type_name: string
          id: string
          number_range_object: string
          requires_approval: boolean | null
        }
        Insert: {
          account_type_allowed?: string | null
          approval_amount_limit?: number | null
          created_at?: string | null
          document_type: string
          document_type_name: string
          id?: string
          number_range_object: string
          requires_approval?: boolean | null
        }
        Update: {
          account_type_allowed?: string | null
          approval_amount_limit?: number | null
          created_at?: string | null
          document_type?: string
          document_type_name?: string
          id?: string
          number_range_object?: string
          requires_approval?: boolean | null
        }
        Relationships: []
      }
      employee_hierarchy: {
        Row: {
          approval_limit: number | null
          created_at: string | null
          customer_id: string
          department_code: string | null
          department_head_id: string | null
          employee_id: string
          employee_name: string
          id: string
          is_active: boolean | null
          manager_employee_id: string | null
          plant_code: string | null
          position_level: number | null
          position_title: string
          updated_at: string | null
        }
        Insert: {
          approval_limit?: number | null
          created_at?: string | null
          customer_id: string
          department_code?: string | null
          department_head_id?: string | null
          employee_id: string
          employee_name: string
          id?: string
          is_active?: boolean | null
          manager_employee_id?: string | null
          plant_code?: string | null
          position_level?: number | null
          position_title: string
          updated_at?: string | null
        }
        Update: {
          approval_limit?: number | null
          created_at?: string | null
          customer_id?: string
          department_code?: string | null
          department_head_id?: string | null
          employee_id?: string
          employee_name?: string
          id?: string
          is_active?: boolean | null
          manager_employee_id?: string | null
          plant_code?: string | null
          position_level?: number | null
          position_title?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      employee_rates: {
        Row: {
          created_at: string | null
          effective_from: string
          effective_to: string | null
          employee_id: string
          hourly_rate: number
          id: string
          is_active: boolean | null
          project_id: string | null
          rate_type: string
        }
        Insert: {
          created_at?: string | null
          effective_from: string
          effective_to?: string | null
          employee_id: string
          hourly_rate: number
          id?: string
          is_active?: boolean | null
          project_id?: string | null
          rate_type?: string
        }
        Update: {
          created_at?: string | null
          effective_from?: string
          effective_to?: string | null
          employee_id?: string
          hourly_rate?: number
          id?: string
          is_active?: boolean | null
          project_id?: string | null
          rate_type?: string
        }
        Relationships: [
          {
            foreignKeyName: "employee_rates_employee_id_fkey"
            columns: ["employee_id"]
            isOneToOne: false
            referencedRelation: "employees"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "employee_rates_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "employee_rates_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "employee_rates_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "employee_rates_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
        ]
      }
      employees: {
        Row: {
          created_at: string | null
          department: string | null
          email: string | null
          employee_code: string
          employment_type: string | null
          first_name: string
          hire_date: string
          id: string
          is_active: boolean | null
          job_title: string | null
          last_name: string
          phone: string | null
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          department?: string | null
          email?: string | null
          employee_code: string
          employment_type?: string | null
          first_name: string
          hire_date: string
          id?: string
          is_active?: boolean | null
          job_title?: string | null
          last_name: string
          phone?: string | null
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          department?: string | null
          email?: string | null
          employee_code?: string
          employment_type?: string | null
          first_name?: string
          hire_date?: string
          id?: string
          is_active?: boolean | null
          job_title?: string | null
          last_name?: string
          phone?: string | null
          updated_at?: string | null
        }
        Relationships: []
      }
      financial_documents: {
        Row: {
          company_code: string | null
          created_at: string | null
          created_by: string
          currency: string | null
          document_date: string
          document_number: string
          document_type: string
          id: string
          is_reversed: boolean | null
          posting_date: string
          reference_document: string | null
          reversal_date: string | null
          reversal_reason: string | null
          reversed_by: string | null
          total_amount: number
        }
        Insert: {
          company_code?: string | null
          created_at?: string | null
          created_by: string
          currency?: string | null
          document_date: string
          document_number: string
          document_type: string
          id?: string
          is_reversed?: boolean | null
          posting_date: string
          reference_document?: string | null
          reversal_date?: string | null
          reversal_reason?: string | null
          reversed_by?: string | null
          total_amount: number
        }
        Update: {
          company_code?: string | null
          created_at?: string | null
          created_by?: string
          currency?: string | null
          document_date?: string
          document_number?: string
          document_type?: string
          id?: string
          is_reversed?: boolean | null
          posting_date?: string
          reference_document?: string | null
          reversal_date?: string | null
          reversal_reason?: string | null
          reversed_by?: string | null
          total_amount?: number
        }
        Relationships: []
      }
      fiscal_year_variants: {
        Row: {
          company_code: string | null
          created_at: string | null
          description: string | null
          fiscal_year: number | null
          fiscal_year_variant: string | null
          id: string
          is_active: boolean | null
          is_open: boolean | null
          period_end_date: string | null
          period_number: number | null
          period_start_date: string | null
          periods: number | null
          start_day: number
          start_month: number
          variant_code: string
          variant_name: string
        }
        Insert: {
          company_code?: string | null
          created_at?: string | null
          description?: string | null
          fiscal_year?: number | null
          fiscal_year_variant?: string | null
          id?: string
          is_active?: boolean | null
          is_open?: boolean | null
          period_end_date?: string | null
          period_number?: number | null
          period_start_date?: string | null
          periods?: number | null
          start_day: number
          start_month: number
          variant_code: string
          variant_name: string
        }
        Update: {
          company_code?: string | null
          created_at?: string | null
          description?: string | null
          fiscal_year?: number | null
          fiscal_year_variant?: string | null
          id?: string
          is_active?: boolean | null
          is_open?: boolean | null
          period_end_date?: string | null
          period_number?: number | null
          period_start_date?: string | null
          periods?: number | null
          start_day?: number
          start_month?: number
          variant_code?: string
          variant_name?: string
        }
        Relationships: []
      }
      fixed_assets: {
        Row: {
          asset_description: string | null
          asset_number: string
          company_code: string | null
          is_active: boolean | null
        }
        Insert: {
          asset_description?: string | null
          asset_number: string
          company_code?: string | null
          is_active?: boolean | null
        }
        Update: {
          asset_description?: string | null
          asset_number?: string
          company_code?: string | null
          is_active?: boolean | null
        }
        Relationships: []
      }
      flexible_approval_levels: {
        Row: {
          amount_threshold_max: number | null
          amount_threshold_min: number | null
          approval_type: string | null
          approver_role: string
          approver_user_id: string | null
          can_delegate: boolean | null
          created_at: string | null
          customer_id: string
          delegation_rules: Json | null
          department_code: string | null
          document_type: string
          escalation_hours: number | null
          id: string
          is_active: boolean | null
          is_required: boolean | null
          level_name: string
          level_number: number
          notification_settings: Json | null
          project_code: string | null
          scope_type: string | null
          updated_at: string | null
        }
        Insert: {
          amount_threshold_max?: number | null
          amount_threshold_min?: number | null
          approval_type?: string | null
          approver_role: string
          approver_user_id?: string | null
          can_delegate?: boolean | null
          created_at?: string | null
          customer_id: string
          delegation_rules?: Json | null
          department_code?: string | null
          document_type: string
          escalation_hours?: number | null
          id?: string
          is_active?: boolean | null
          is_required?: boolean | null
          level_name: string
          level_number: number
          notification_settings?: Json | null
          project_code?: string | null
          scope_type?: string | null
          updated_at?: string | null
        }
        Update: {
          amount_threshold_max?: number | null
          amount_threshold_min?: number | null
          approval_type?: string | null
          approver_role?: string
          approver_user_id?: string | null
          can_delegate?: boolean | null
          created_at?: string | null
          customer_id?: string
          delegation_rules?: Json | null
          department_code?: string | null
          document_type?: string
          escalation_hours?: number | null
          id?: string
          is_active?: boolean | null
          is_required?: boolean | null
          level_name?: string
          level_number?: number
          notification_settings?: Json | null
          project_code?: string | null
          scope_type?: string | null
          updated_at?: string | null
        }
        Relationships: []
      }
      functional_approver_assignments: {
        Row: {
          approval_limit: number | null
          approval_limit_currency: string | null
          approval_scope: string
          approver_role: string
          approver_user_id: string
          company_code: string | null
          country_code: string | null
          created_at: string | null
          customer_id: string
          department_code: string | null
          execution_mode: string | null
          functional_domain: string
          id: string
          is_active: boolean | null
          plant_code: string | null
        }
        Insert: {
          approval_limit?: number | null
          approval_limit_currency?: string | null
          approval_scope: string
          approver_role: string
          approver_user_id: string
          company_code?: string | null
          country_code?: string | null
          created_at?: string | null
          customer_id: string
          department_code?: string | null
          execution_mode?: string | null
          functional_domain: string
          id?: string
          is_active?: boolean | null
          plant_code?: string | null
        }
        Update: {
          approval_limit?: number | null
          approval_limit_currency?: string | null
          approval_scope?: string
          approver_role?: string
          approver_user_id?: string
          company_code?: string | null
          country_code?: string | null
          created_at?: string | null
          customer_id?: string
          department_code?: string | null
          execution_mode?: string | null
          functional_domain?: string
          id?: string
          is_active?: boolean | null
          plant_code?: string | null
        }
        Relationships: []
      }
      fx_rates: {
        Row: {
          created_at: string | null
          exchange_rate: number
          from_currency: string
          id: string
          rate_date: string
          rate_source: string | null
          to_currency: string
        }
        Insert: {
          created_at?: string | null
          exchange_rate: number
          from_currency: string
          id?: string
          rate_date: string
          rate_source?: string | null
          to_currency: string
        }
        Update: {
          created_at?: string | null
          exchange_rate?: number
          from_currency?: string
          id?: string
          rate_date?: string
          rate_source?: string | null
          to_currency?: string
        }
        Relationships: []
      }
      gl_account_authorization: {
        Row: {
          account_code: string
          amount_limit: number | null
          authorization_type: string
          company_code: string
          created_at: string | null
          id: string
          user_id: string
        }
        Insert: {
          account_code: string
          amount_limit?: number | null
          authorization_type: string
          company_code: string
          created_at?: string | null
          id?: string
          user_id: string
        }
        Update: {
          account_code?: string
          amount_limit?: number | null
          authorization_type?: string
          company_code?: string
          created_at?: string | null
          id?: string
          user_id?: string
        }
        Relationships: []
      }
      gl_accounts: {
        Row: {
          account_code: string
          account_name: string
          account_type: string
          chart_of_accounts_id: string
          created_at: string | null
          description: string | null
          id: string
          is_active: boolean | null
        }
        Insert: {
          account_code: string
          account_name: string
          account_type: string
          chart_of_accounts_id: string
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
        }
        Update: {
          account_code?: string
          account_name?: string
          account_type?: string
          chart_of_accounts_id?: string
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
        }
        Relationships: [
          {
            foreignKeyName: "gl_accounts_chart_of_accounts_id_fkey"
            columns: ["chart_of_accounts_id"]
            isOneToOne: false
            referencedRelation: "chart_of_accounts"
            referencedColumns: ["id"]
          },
        ]
      }
      gl_determination_rules: {
        Row: {
          account_determination_logic: Json | null
          company_code: string
          created_at: string | null
          created_by: string | null
          debit_credit: string
          effective_date: string | null
          event_type: string
          expiry_date: string | null
          gl_account_type: string
          id: number
          is_active: boolean | null
          posting_key: string | null
          priority: number | null
          project_category: string | null
          rule_code: string
          rule_name: string
        }
        Insert: {
          account_determination_logic?: Json | null
          company_code: string
          created_at?: string | null
          created_by?: string | null
          debit_credit: string
          effective_date?: string | null
          event_type: string
          expiry_date?: string | null
          gl_account_type: string
          id?: number
          is_active?: boolean | null
          posting_key?: string | null
          priority?: number | null
          project_category?: string | null
          rule_code: string
          rule_name: string
        }
        Update: {
          account_determination_logic?: Json | null
          company_code?: string
          created_at?: string | null
          created_by?: string | null
          debit_credit?: string
          effective_date?: string | null
          event_type?: string
          expiry_date?: string | null
          gl_account_type?: string
          id?: number
          is_active?: boolean | null
          posting_key?: string | null
          priority?: number | null
          project_category?: string | null
          rule_code?: string
          rule_name?: string
        }
        Relationships: []
      }
      goods_receipts: {
        Row: {
          created_at: string | null
          delivery_note_number: string | null
          driver_name: string | null
          grn_number: string
          id: string
          notes: string | null
          po_id: string
          project_id: string
          quality_check_date: string | null
          quality_checked_by: string | null
          quality_notes: string | null
          quality_status: Database["public"]["Enums"]["quality_status"] | null
          receipt_date: string
          received_by: string
          status: Database["public"]["Enums"]["receipt_status"]
          store_id: string
          total_received_value: number | null
          updated_at: string | null
          vehicle_number: string | null
          vendor_id: string
        }
        Insert: {
          created_at?: string | null
          delivery_note_number?: string | null
          driver_name?: string | null
          grn_number: string
          id?: string
          notes?: string | null
          po_id: string
          project_id: string
          quality_check_date?: string | null
          quality_checked_by?: string | null
          quality_notes?: string | null
          quality_status?: Database["public"]["Enums"]["quality_status"] | null
          receipt_date: string
          received_by: string
          status?: Database["public"]["Enums"]["receipt_status"]
          store_id: string
          total_received_value?: number | null
          updated_at?: string | null
          vehicle_number?: string | null
          vendor_id: string
        }
        Update: {
          created_at?: string | null
          delivery_note_number?: string | null
          driver_name?: string | null
          grn_number?: string
          id?: string
          notes?: string | null
          po_id?: string
          project_id?: string
          quality_check_date?: string | null
          quality_checked_by?: string | null
          quality_notes?: string | null
          quality_status?: Database["public"]["Enums"]["quality_status"] | null
          receipt_date?: string
          received_by?: string
          status?: Database["public"]["Enums"]["receipt_status"]
          store_id?: string
          total_received_value?: number | null
          updated_at?: string | null
          vehicle_number?: string | null
          vendor_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "goods_receipts_po_id_fkey"
            columns: ["po_id"]
            isOneToOne: false
            referencedRelation: "purchase_orders"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "goods_receipts_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "goods_receipts_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "goods_receipts_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "goods_receipts_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "goods_receipts_store_id_fkey"
            columns: ["store_id"]
            isOneToOne: false
            referencedRelation: "stores"
            referencedColumns: ["id"]
          },
        ]
      }
      grn_lines: {
        Row: {
          accepted_quantity: number
          batch_number: string | null
          expiry_date: string | null
          grn_id: string
          id: string
          line_value: number | null
          notes: string | null
          ordered_quantity: number
          po_line_id: string
          quality_status: Database["public"]["Enums"]["quality_status"]
          received_quantity: number
          rejected_quantity: number | null
          unit_rate: number
        }
        Insert: {
          accepted_quantity: number
          batch_number?: string | null
          expiry_date?: string | null
          grn_id: string
          id?: string
          line_value?: number | null
          notes?: string | null
          ordered_quantity: number
          po_line_id: string
          quality_status?: Database["public"]["Enums"]["quality_status"]
          received_quantity: number
          rejected_quantity?: number | null
          unit_rate: number
        }
        Update: {
          accepted_quantity?: number
          batch_number?: string | null
          expiry_date?: string | null
          grn_id?: string
          id?: string
          line_value?: number | null
          notes?: string | null
          ordered_quantity?: number
          po_line_id?: string
          quality_status?: Database["public"]["Enums"]["quality_status"]
          received_quantity?: number
          rejected_quantity?: number | null
          unit_rate?: number
        }
        Relationships: [
          {
            foreignKeyName: "grn_lines_grn_id_fkey"
            columns: ["grn_id"]
            isOneToOne: false
            referencedRelation: "goods_receipts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "grn_lines_po_line_id_fkey"
            columns: ["po_line_id"]
            isOneToOne: false
            referencedRelation: "po_lines"
            referencedColumns: ["id"]
          },
        ]
      }
      internal_orders: {
        Row: {
          company_code: string | null
          cost_center: string | null
          is_active: boolean | null
          order_description: string | null
          order_number: string
        }
        Insert: {
          company_code?: string | null
          cost_center?: string | null
          is_active?: boolean | null
          order_description?: string | null
          order_number: string
        }
        Update: {
          company_code?: string | null
          cost_center?: string | null
          is_active?: boolean | null
          order_description?: string | null
          order_number?: string
        }
        Relationships: []
      }
      journal_entries: {
        Row: {
          account_code: string
          cost_center: string | null
          created_at: string | null
          credit_amount: number | null
          debit_amount: number | null
          description: string | null
          document_id: string
          id: string
          line_item: number
          profit_center: string | null
          project_code: string | null
          reference_key: string | null
          wbs_element: string | null
        }
        Insert: {
          account_code: string
          cost_center?: string | null
          created_at?: string | null
          credit_amount?: number | null
          debit_amount?: number | null
          description?: string | null
          document_id: string
          id?: string
          line_item: number
          profit_center?: string | null
          project_code?: string | null
          reference_key?: string | null
          wbs_element?: string | null
        }
        Update: {
          account_code?: string
          cost_center?: string | null
          created_at?: string | null
          credit_amount?: number | null
          debit_amount?: number | null
          description?: string | null
          document_id?: string
          id?: string
          line_item?: number
          profit_center?: string | null
          project_code?: string | null
          reference_key?: string | null
          wbs_element?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "journal_entries_document_id_fkey"
            columns: ["document_id"]
            isOneToOne: false
            referencedRelation: "financial_documents"
            referencedColumns: ["id"]
          },
        ]
      }
      material_categories: {
        Row: {
          category_code: string
          category_name: string
          created_at: string | null
          description: string | null
          is_active: boolean | null
          parent_category: string | null
        }
        Insert: {
          category_code: string
          category_name: string
          created_at?: string | null
          description?: string | null
          is_active?: boolean | null
          parent_category?: string | null
        }
        Update: {
          category_code?: string
          category_name?: string
          created_at?: string | null
          description?: string | null
          is_active?: boolean | null
          parent_category?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_material_categories_parent"
            columns: ["parent_category"]
            isOneToOne: false
            referencedRelation: "material_categories"
            referencedColumns: ["category_code"]
          },
        ]
      }
      material_groups: {
        Row: {
          category_code: string | null
          created_at: string | null
          description: string | null
          group_code: string
          group_name: string
          id: string
          is_active: boolean | null
        }
        Insert: {
          category_code?: string | null
          created_at?: string | null
          description?: string | null
          group_code: string
          group_name: string
          id?: string
          is_active?: boolean | null
        }
        Update: {
          category_code?: string | null
          created_at?: string | null
          description?: string | null
          group_code?: string
          group_name?: string
          id?: string
          is_active?: boolean | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_material_groups_category"
            columns: ["category_code"]
            isOneToOne: false
            referencedRelation: "material_categories"
            referencedColumns: ["category_code"]
          },
          {
            foreignKeyName: "material_groups_category_code_fkey"
            columns: ["category_code"]
            isOneToOne: false
            referencedRelation: "material_categories"
            referencedColumns: ["category_code"]
          },
        ]
      }
      material_movements: {
        Row: {
          created_at: string | null
          created_by: string | null
          id: string
          material_id: string | null
          movement_date: string
          movement_type: string
          posting_date: string
          quantity: number
          reference_doc: string | null
          storage_location: string | null
          unit_price: number | null
        }
        Insert: {
          created_at?: string | null
          created_by?: string | null
          id?: string
          material_id?: string | null
          movement_date: string
          movement_type: string
          posting_date: string
          quantity: number
          reference_doc?: string | null
          storage_location?: string | null
          unit_price?: number | null
        }
        Update: {
          created_at?: string | null
          created_by?: string | null
          id?: string
          material_id?: string | null
          movement_date?: string
          movement_type?: string
          posting_date?: string
          quantity?: number
          reference_doc?: string | null
          storage_location?: string | null
          unit_price?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "material_movements_material_id_fkey"
            columns: ["material_id"]
            isOneToOne: false
            referencedRelation: "materials"
            referencedColumns: ["id"]
          },
        ]
      }
      material_plant_data: {
        Row: {
          created_at: string | null
          currency: string | null
          default_storage_location_id: string | null
          id: string
          is_active: boolean | null
          material_code: string
          material_id: string
          maximum_stock: number | null
          minimum_lot_size: number | null
          mrp_type: string | null
          planned_delivery_time: number | null
          plant_code: string
          plant_id: string
          plant_status: string | null
          price_unit: number | null
          procurement_type: string | null
          reorder_level: number | null
          reorder_point: number | null
          safety_stock: number | null
          standard_price: number | null
        }
        Insert: {
          created_at?: string | null
          currency?: string | null
          default_storage_location_id?: string | null
          id?: string
          is_active?: boolean | null
          material_code: string
          material_id: string
          maximum_stock?: number | null
          minimum_lot_size?: number | null
          mrp_type?: string | null
          planned_delivery_time?: number | null
          plant_code: string
          plant_id: string
          plant_status?: string | null
          price_unit?: number | null
          procurement_type?: string | null
          reorder_level?: number | null
          reorder_point?: number | null
          safety_stock?: number | null
          standard_price?: number | null
        }
        Update: {
          created_at?: string | null
          currency?: string | null
          default_storage_location_id?: string | null
          id?: string
          is_active?: boolean | null
          material_code?: string
          material_id?: string
          maximum_stock?: number | null
          minimum_lot_size?: number | null
          mrp_type?: string | null
          planned_delivery_time?: number | null
          plant_code?: string
          plant_id?: string
          plant_status?: string | null
          price_unit?: number | null
          procurement_type?: string | null
          reorder_level?: number | null
          reorder_point?: number | null
          safety_stock?: number | null
          standard_price?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_material_plant_data_material"
            columns: ["material_code"]
            isOneToOne: false
            referencedRelation: "material_master_view"
            referencedColumns: ["material_code"]
          },
          {
            foreignKeyName: "fk_material_plant_data_material"
            columns: ["material_code"]
            isOneToOne: false
            referencedRelation: "materials"
            referencedColumns: ["material_code"]
          },
          {
            foreignKeyName: "material_plant_data_default_storage_location_id_fkey"
            columns: ["default_storage_location_id"]
            isOneToOne: false
            referencedRelation: "storage_locations"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "material_plant_data_plant_id_fkey"
            columns: ["plant_id"]
            isOneToOne: false
            referencedRelation: "plants"
            referencedColumns: ["id"]
          },
        ]
      }
      material_price_history: {
        Row: {
          created_at: string | null
          currency: string | null
          id: number
          material_code: string | null
          price: number | null
          unit: string | null
          valid_from: string | null
          valid_to: string | null
          vendor_code: string | null
        }
        Insert: {
          created_at?: string | null
          currency?: string | null
          id?: number
          material_code?: string | null
          price?: number | null
          unit?: string | null
          valid_from?: string | null
          valid_to?: string | null
          vendor_code?: string | null
        }
        Update: {
          created_at?: string | null
          currency?: string | null
          id?: number
          material_code?: string | null
          price?: number | null
          unit?: string | null
          valid_from?: string | null
          valid_to?: string | null
          vendor_code?: string | null
        }
        Relationships: []
      }
      material_pricing: {
        Row: {
          company_code: string
          created_at: string | null
          created_by: string | null
          currency: string
          id: string
          is_active: boolean | null
          material_code: string
          plant_code: string | null
          price: number
          price_type: string
          price_unit: number | null
          price_uom: string | null
          updated_at: string | null
          updated_by: string | null
          valid_from: string
          valid_to: string | null
        }
        Insert: {
          company_code: string
          created_at?: string | null
          created_by?: string | null
          currency?: string
          id?: string
          is_active?: boolean | null
          material_code: string
          plant_code?: string | null
          price?: number
          price_type?: string
          price_unit?: number | null
          price_uom?: string | null
          updated_at?: string | null
          updated_by?: string | null
          valid_from?: string
          valid_to?: string | null
        }
        Update: {
          company_code?: string
          created_at?: string | null
          created_by?: string | null
          currency?: string
          id?: string
          is_active?: boolean | null
          material_code?: string
          plant_code?: string | null
          price?: number
          price_type?: string
          price_unit?: number | null
          price_uom?: string | null
          updated_at?: string | null
          updated_by?: string | null
          valid_from?: string
          valid_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_material_pricing_material"
            columns: ["material_code"]
            isOneToOne: false
            referencedRelation: "material_master_view"
            referencedColumns: ["material_code"]
          },
          {
            foreignKeyName: "fk_material_pricing_material"
            columns: ["material_code"]
            isOneToOne: false
            referencedRelation: "materials"
            referencedColumns: ["material_code"]
          },
        ]
      }
      material_request_items: {
        Row: {
          base_uom: string
          created_at: string | null
          currency_code: string | null
          delivery_date: string | null
          description: string | null
          estimated_price: number | null
          id: string
          line_number: number
          line_total: number | null
          material_code: string | null
          material_name: string | null
          notes: string | null
          request_id: string
          requested_quantity: number
          updated_at: string | null
        }
        Insert: {
          base_uom: string
          created_at?: string | null
          currency_code?: string | null
          delivery_date?: string | null
          description?: string | null
          estimated_price?: number | null
          id?: string
          line_number: number
          line_total?: number | null
          material_code?: string | null
          material_name?: string | null
          notes?: string | null
          request_id: string
          requested_quantity: number
          updated_at?: string | null
        }
        Update: {
          base_uom?: string
          created_at?: string | null
          currency_code?: string | null
          delivery_date?: string | null
          description?: string | null
          estimated_price?: number | null
          id?: string
          line_number?: number
          line_total?: number | null
          material_code?: string | null
          material_name?: string | null
          notes?: string | null
          request_id?: string
          requested_quantity?: number
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "material_request_items_request_id_fkey"
            columns: ["request_id"]
            isOneToOne: false
            referencedRelation: "material_requests"
            referencedColumns: ["id"]
          },
        ]
      }
      material_requests: {
        Row: {
          company_code: string | null
          cost_center: string | null
          created_at: string | null
          created_by: string
          currency_code: string | null
          id: string
          notes: string | null
          plant_code: string | null
          priority: string | null
          project_code: string | null
          purpose: string | null
          request_number: string
          request_type: string
          requested_by: string
          required_date: string | null
          status: string | null
          total_amount: number | null
          updated_at: string | null
        }
        Insert: {
          company_code?: string | null
          cost_center?: string | null
          created_at?: string | null
          created_by: string
          currency_code?: string | null
          id?: string
          notes?: string | null
          plant_code?: string | null
          priority?: string | null
          project_code?: string | null
          purpose?: string | null
          request_number: string
          request_type: string
          requested_by: string
          required_date?: string | null
          status?: string | null
          total_amount?: number | null
          updated_at?: string | null
        }
        Update: {
          company_code?: string | null
          cost_center?: string | null
          created_at?: string | null
          created_by?: string
          currency_code?: string | null
          id?: string
          notes?: string | null
          plant_code?: string | null
          priority?: string | null
          project_code?: string | null
          purpose?: string | null
          request_number?: string
          request_type?: string
          requested_by?: string
          required_date?: string | null
          status?: string | null
          total_amount?: number | null
          updated_at?: string | null
        }
        Relationships: []
      }
      material_status: {
        Row: {
          allow_consumption: boolean | null
          allow_procurement: boolean | null
          created_at: string | null
          id: string
          is_active: boolean | null
          status_code: string
          status_name: string
        }
        Insert: {
          allow_consumption?: boolean | null
          allow_procurement?: boolean | null
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          status_code: string
          status_name: string
        }
        Update: {
          allow_consumption?: boolean | null
          allow_procurement?: boolean | null
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          status_code?: string
          status_name?: string
        }
        Relationships: []
      }
      material_storage_data: {
        Row: {
          available_stock: number | null
          bin_location: string | null
          current_stock: number | null
          id: string
          last_movement_date: string | null
          material_id: string
          reserved_stock: number | null
          storage_location_id: string
        }
        Insert: {
          available_stock?: number | null
          bin_location?: string | null
          current_stock?: number | null
          id?: string
          last_movement_date?: string | null
          material_id: string
          reserved_stock?: number | null
          storage_location_id: string
        }
        Update: {
          available_stock?: number | null
          bin_location?: string | null
          current_stock?: number | null
          id?: string
          last_movement_date?: string | null
          material_id?: string
          reserved_stock?: number | null
          storage_location_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "material_storage_data_material_id_fkey"
            columns: ["material_id"]
            isOneToOne: false
            referencedRelation: "global_materials"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "material_storage_data_material_id_fkey"
            columns: ["material_id"]
            isOneToOne: false
            referencedRelation: "project_materials"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "material_storage_data_material_id_fkey"
            columns: ["material_id"]
            isOneToOne: false
            referencedRelation: "stock_items"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "material_storage_data_storage_location_id_fkey"
            columns: ["storage_location_id"]
            isOneToOne: false
            referencedRelation: "storage_locations"
            referencedColumns: ["id"]
          },
        ]
      }
      material_types: {
        Row: {
          description: string | null
          id: string
          inventory_managed: boolean | null
          is_active: boolean | null
          material_type_code: string
          material_type_name: string
          quantity_update: boolean | null
          value_update: boolean | null
        }
        Insert: {
          description?: string | null
          id?: string
          inventory_managed?: boolean | null
          is_active?: boolean | null
          material_type_code: string
          material_type_name: string
          quantity_update?: boolean | null
          value_update?: boolean | null
        }
        Update: {
          description?: string | null
          id?: string
          inventory_managed?: boolean | null
          is_active?: boolean | null
          material_type_code?: string
          material_type_name?: string
          quantity_update?: boolean | null
          value_update?: boolean | null
        }
        Relationships: []
      }
      materials: {
        Row: {
          base_uom: string
          category: string | null
          created_at: string | null
          description: string | null
          id: string
          is_active: boolean | null
          material_code: string
          material_group: string | null
          material_group_id: string | null
          material_name: string
          material_status_id: string | null
          material_type: string | null
          standard_price: number | null
          valuation_class_id: string | null
        }
        Insert: {
          base_uom: string
          category?: string | null
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
          material_code: string
          material_group?: string | null
          material_group_id?: string | null
          material_name: string
          material_status_id?: string | null
          material_type?: string | null
          standard_price?: number | null
          valuation_class_id?: string | null
        }
        Update: {
          base_uom?: string
          category?: string | null
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
          material_code?: string
          material_group?: string | null
          material_group_id?: string | null
          material_name?: string
          material_status_id?: string | null
          material_type?: string | null
          standard_price?: number | null
          valuation_class_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_materials_category"
            columns: ["category"]
            isOneToOne: false
            referencedRelation: "material_categories"
            referencedColumns: ["category_code"]
          },
          {
            foreignKeyName: "fk_materials_group"
            columns: ["material_group"]
            isOneToOne: false
            referencedRelation: "material_groups"
            referencedColumns: ["group_code"]
          },
          {
            foreignKeyName: "materials_material_group_id_fkey"
            columns: ["material_group_id"]
            isOneToOne: false
            referencedRelation: "material_groups"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "materials_material_status_id_fkey"
            columns: ["material_status_id"]
            isOneToOne: false
            referencedRelation: "material_status"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "materials_valuation_class_id_fkey"
            columns: ["valuation_class_id"]
            isOneToOne: false
            referencedRelation: "valuation_classes"
            referencedColumns: ["id"]
          },
        ]
      }
      mobile_ui_config: {
        Row: {
          company_code: string
          component_type: string
          config_data: Json | null
          created_at: string | null
          display_order: number | null
          id: number
          is_required: boolean | null
          is_visible: boolean | null
          mobile_optimized: boolean | null
          screen_code: string
        }
        Insert: {
          company_code: string
          component_type: string
          config_data?: Json | null
          created_at?: string | null
          display_order?: number | null
          id?: number
          is_required?: boolean | null
          is_visible?: boolean | null
          mobile_optimized?: boolean | null
          screen_code: string
        }
        Update: {
          company_code?: string
          component_type?: string
          config_data?: Json | null
          created_at?: string | null
          display_order?: number | null
          id?: number
          is_required?: boolean | null
          is_visible?: boolean | null
          mobile_optimized?: boolean | null
          screen_code?: string
        }
        Relationships: []
      }
      movement_type_account_keys: {
        Row: {
          account_assignment_category: string | null
          account_key_id: string
          created_at: string | null
          debit_credit_indicator: string
          id: string
          is_active: boolean | null
          movement_type_id: string
          sequence_order: number
        }
        Insert: {
          account_assignment_category?: string | null
          account_key_id: string
          created_at?: string | null
          debit_credit_indicator: string
          id?: string
          is_active?: boolean | null
          movement_type_id: string
          sequence_order?: number
        }
        Update: {
          account_assignment_category?: string | null
          account_key_id?: string
          created_at?: string | null
          debit_credit_indicator?: string
          id?: string
          is_active?: boolean | null
          movement_type_id?: string
          sequence_order?: number
        }
        Relationships: [
          {
            foreignKeyName: "movement_type_account_keys_account_key_id_fkey"
            columns: ["account_key_id"]
            isOneToOne: false
            referencedRelation: "account_keys"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "movement_type_account_keys_movement_type_id_fkey"
            columns: ["movement_type_id"]
            isOneToOne: false
            referencedRelation: "movement_types"
            referencedColumns: ["id"]
          },
        ]
      }
      movement_type_account_mappings: {
        Row: {
          account_modification: string | null
          company_code: string
          created_at: string | null
          credit_account: string
          debit_account: string
          id: string
          is_active: boolean | null
          material_type: string | null
          movement_type: string
        }
        Insert: {
          account_modification?: string | null
          company_code: string
          created_at?: string | null
          credit_account: string
          debit_account: string
          id?: string
          is_active?: boolean | null
          material_type?: string | null
          movement_type: string
        }
        Update: {
          account_modification?: string | null
          company_code?: string
          created_at?: string | null
          credit_account?: string
          debit_account?: string
          id?: string
          is_active?: boolean | null
          material_type?: string | null
          movement_type?: string
        }
        Relationships: []
      }
      movement_types: {
        Row: {
          created_at: string | null
          description: string | null
          id: string
          is_active: boolean | null
          movement_indicator: string
          movement_name: string
          movement_type: string
        }
        Insert: {
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
          movement_indicator: string
          movement_name: string
          movement_type: string
        }
        Update: {
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
          movement_indicator?: string
          movement_name?: string
          movement_type?: string
        }
        Relationships: []
      }
      mrp_shortage_analysis: {
        Row: {
          analysis_run_id: string
          available_stock: number
          created_at: string | null
          id: string
          material_code: string
          net_shortage: number
          planning_date: string
          procurement_proposal_date: string | null
          procurement_proposal_qty: number | null
          reserved_stock: number
          total_demand: number
        }
        Insert: {
          analysis_run_id: string
          available_stock: number
          created_at?: string | null
          id?: string
          material_code: string
          net_shortage: number
          planning_date: string
          procurement_proposal_date?: string | null
          procurement_proposal_qty?: number | null
          reserved_stock: number
          total_demand: number
        }
        Update: {
          analysis_run_id?: string
          available_stock?: number
          created_at?: string | null
          id?: string
          material_code?: string
          net_shortage?: number
          planning_date?: string
          procurement_proposal_date?: string | null
          procurement_proposal_qty?: number | null
          reserved_stock?: number
          total_demand?: number
        }
        Relationships: []
      }
      number_range_alerts: {
        Row: {
          acknowledged_at: string | null
          acknowledged_by: string | null
          alert_message: string
          alert_type: string
          company_code: string
          created_at: string | null
          document_type: string
          id: string
          is_acknowledged: boolean | null
          usage_percentage: number
        }
        Insert: {
          acknowledged_at?: string | null
          acknowledged_by?: string | null
          alert_message: string
          alert_type: string
          company_code: string
          created_at?: string | null
          document_type: string
          id?: string
          is_acknowledged?: boolean | null
          usage_percentage: number
        }
        Update: {
          acknowledged_at?: string | null
          acknowledged_by?: string | null
          alert_message?: string
          alert_type?: string
          company_code?: string
          created_at?: string | null
          document_type?: string
          id?: string
          is_acknowledged?: boolean | null
          usage_percentage?: number
        }
        Relationships: []
      }
      number_range_buffer: {
        Row: {
          allocated_at: string | null
          buffer_end: number
          buffer_start: number
          company_code: string
          document_type: string
          expires_at: string | null
          id: string
          server_instance: string | null
        }
        Insert: {
          allocated_at?: string | null
          buffer_end: number
          buffer_start: number
          company_code: string
          document_type: string
          expires_at?: string | null
          id?: string
          server_instance?: string | null
        }
        Update: {
          allocated_at?: string | null
          buffer_end?: number
          buffer_start?: number
          company_code?: string
          document_type?: string
          expires_at?: string | null
          id?: string
          server_instance?: string | null
        }
        Relationships: []
      }
      number_range_groups: {
        Row: {
          company_code: string
          created_at: string | null
          description: string | null
          group_code: string
          group_name: string
          id: string
        }
        Insert: {
          company_code: string
          created_at?: string | null
          description?: string | null
          group_code: string
          group_name: string
          id?: string
        }
        Update: {
          company_code?: string
          created_at?: string | null
          description?: string | null
          group_code?: string
          group_name?: string
          id?: string
        }
        Relationships: []
      }
      number_range_usage_history: {
        Row: {
          company_code: string
          created_at: string | null
          document_id: string | null
          document_number: string
          document_type: string
          id: string
          used_at: string | null
          used_by: string | null
        }
        Insert: {
          company_code: string
          created_at?: string | null
          document_id?: string | null
          document_number: string
          document_type: string
          id?: string
          used_at?: string | null
          used_by?: string | null
        }
        Update: {
          company_code?: string
          created_at?: string | null
          document_id?: string | null
          document_number?: string
          document_type?: string
          id?: string
          used_at?: string | null
          used_by?: string | null
        }
        Relationships: []
      }
      org_hierarchy: {
        Row: {
          company_code: string | null
          department_code: string | null
          email: string | null
          employee_id: string
          employee_name: string
          id: string
          is_active: boolean | null
          manager_id: string | null
          plant_code: string | null
          position_title: string | null
        }
        Insert: {
          company_code?: string | null
          department_code?: string | null
          email?: string | null
          employee_id: string
          employee_name: string
          id?: string
          is_active?: boolean | null
          manager_id?: string | null
          plant_code?: string | null
          position_title?: string | null
        }
        Update: {
          company_code?: string | null
          department_code?: string | null
          email?: string | null
          employee_id?: string
          employee_name?: string
          id?: string
          is_active?: boolean | null
          manager_id?: string | null
          plant_code?: string | null
          position_title?: string | null
        }
        Relationships: []
      }
      organizational_hierarchy: {
        Row: {
          approval_limit: number | null
          approval_limit_currency: string | null
          company_code: string
          company_code_id: string | null
          country_code: string
          created_at: string | null
          customer_id: string | null
          department_code: string
          effective_from: string
          effective_to: string | null
          id: string
          is_active: boolean | null
          manager_id: string | null
          plant_code: string | null
          position_level: number | null
          position_title: string | null
          user_id: string
        }
        Insert: {
          approval_limit?: number | null
          approval_limit_currency?: string | null
          company_code: string
          company_code_id?: string | null
          country_code: string
          created_at?: string | null
          customer_id?: string | null
          department_code: string
          effective_from: string
          effective_to?: string | null
          id?: string
          is_active?: boolean | null
          manager_id?: string | null
          plant_code?: string | null
          position_level?: number | null
          position_title?: string | null
          user_id: string
        }
        Update: {
          approval_limit?: number | null
          approval_limit_currency?: string | null
          company_code?: string
          company_code_id?: string | null
          country_code?: string
          created_at?: string | null
          customer_id?: string | null
          department_code?: string
          effective_from?: string
          effective_to?: string | null
          id?: string
          is_active?: boolean | null
          manager_id?: string | null
          plant_code?: string | null
          position_level?: number | null
          position_title?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_org_hierarchy_company_code"
            columns: ["company_code_id"]
            isOneToOne: false
            referencedRelation: "company_codes"
            referencedColumns: ["id"]
          },
        ]
      }
      payment_terms: {
        Row: {
          created_at: string | null
          discount_days: number | null
          discount_percent: number | null
          id: string
          is_active: boolean | null
          net_days: number
          term_code: string
          term_name: string
        }
        Insert: {
          created_at?: string | null
          discount_days?: number | null
          discount_percent?: number | null
          id?: string
          is_active?: boolean | null
          net_days: number
          term_code: string
          term_name: string
        }
        Update: {
          created_at?: string | null
          discount_days?: number | null
          discount_percent?: number | null
          id?: string
          is_active?: boolean | null
          net_days?: number
          term_code?: string
          term_name?: string
        }
        Relationships: []
      }
      permissions: {
        Row: {
          created_at: string | null
          description: string | null
          id: string
          name: string
        }
        Insert: {
          created_at?: string | null
          description?: string | null
          id?: string
          name: string
        }
        Update: {
          created_at?: string | null
          description?: string | null
          id?: string
          name?: string
        }
        Relationships: []
      }
      persons_responsible: {
        Row: {
          company_code: string | null
          email: string | null
          id: string
          name: string
          role: string
        }
        Insert: {
          company_code?: string | null
          email?: string | null
          id?: string
          name: string
          role: string
        }
        Update: {
          company_code?: string | null
          email?: string | null
          id?: string
          name?: string
          role?: string
        }
        Relationships: []
      }
      planned_procurement_docs: {
        Row: {
          conversion_status: string | null
          converted_document_id: string | null
          created_at: string | null
          estimated_cost: number | null
          id: string
          material_code: string
          planned_date: string
          planned_doc_number: string
          planned_doc_type: string
          planned_quantity: number
          procurement_type: string
          source_demand_header_id: string
          unit_of_measure: string
        }
        Insert: {
          conversion_status?: string | null
          converted_document_id?: string | null
          created_at?: string | null
          estimated_cost?: number | null
          id?: string
          material_code: string
          planned_date: string
          planned_doc_number: string
          planned_doc_type: string
          planned_quantity: number
          procurement_type: string
          source_demand_header_id: string
          unit_of_measure: string
        }
        Update: {
          conversion_status?: string | null
          converted_document_id?: string | null
          created_at?: string | null
          estimated_cost?: number | null
          id?: string
          material_code?: string
          planned_date?: string
          planned_doc_number?: string
          planned_doc_type?: string
          planned_quantity?: number
          procurement_type?: string
          source_demand_header_id?: string
          unit_of_measure?: string
        }
        Relationships: [
          {
            foreignKeyName: "planned_procurement_docs_source_demand_header_id_fkey"
            columns: ["source_demand_header_id"]
            isOneToOne: false
            referencedRelation: "demand_headers"
            referencedColumns: ["id"]
          },
        ]
      }
      plant_stock_thresholds: {
        Row: {
          created_at: string | null
          id: string
          low_stock_threshold: number
          material_category: string
          normal_stock_threshold: number
          plant_id: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          low_stock_threshold: number
          material_category: string
          normal_stock_threshold: number
          plant_id: string
        }
        Update: {
          created_at?: string | null
          id?: string
          low_stock_threshold?: number
          material_category?: string
          normal_stock_threshold?: number
          plant_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "plant_stock_thresholds_plant_id_fkey"
            columns: ["plant_id"]
            isOneToOne: false
            referencedRelation: "plants"
            referencedColumns: ["id"]
          },
        ]
      }
      plants: {
        Row: {
          address: string | null
          company_code: string | null
          company_code_id: string | null
          id: string
          is_active: boolean | null
          plant_code: string
          plant_name: string
          plant_type: string | null
          project_id: string | null
        }
        Insert: {
          address?: string | null
          company_code?: string | null
          company_code_id?: string | null
          id?: string
          is_active?: boolean | null
          plant_code: string
          plant_name: string
          plant_type?: string | null
          project_id?: string | null
        }
        Update: {
          address?: string | null
          company_code?: string | null
          company_code_id?: string | null
          id?: string
          is_active?: boolean | null
          plant_code?: string
          plant_name?: string
          plant_type?: string | null
          project_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "plants_company_code_fkey"
            columns: ["company_code"]
            isOneToOne: false
            referencedRelation: "company_codes"
            referencedColumns: ["company_code"]
          },
          {
            foreignKeyName: "plants_company_code_fkey"
            columns: ["company_code"]
            isOneToOne: false
            referencedRelation: "v_companies_with_names"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "plants_company_code_id_fkey"
            columns: ["company_code_id"]
            isOneToOne: false
            referencedRelation: "company_codes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "plants_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "plants_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "plants_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "plants_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
        ]
      }
      po_approval_history: {
        Row: {
          action: string | null
          approval_level: number | null
          approver_id: string | null
          comments: string | null
          created_at: string | null
          id: string
          route_id: string | null
        }
        Insert: {
          action?: string | null
          approval_level?: number | null
          approver_id?: string | null
          comments?: string | null
          created_at?: string | null
          id?: string
          route_id?: string | null
        }
        Update: {
          action?: string | null
          approval_level?: number | null
          approver_id?: string | null
          comments?: string | null
          created_at?: string | null
          id?: string
          route_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "po_approval_history_route_id_fkey"
            columns: ["route_id"]
            isOneToOne: false
            referencedRelation: "po_approval_routes"
            referencedColumns: ["id"]
          },
        ]
      }
      po_approval_policies: {
        Row: {
          amount_max: number | null
          amount_min: number | null
          approval_level: number
          approver_role: string
          company_code: string | null
          created_at: string | null
          id: string
          is_active: boolean | null
          policy_name: string
        }
        Insert: {
          amount_max?: number | null
          amount_min?: number | null
          approval_level: number
          approver_role: string
          company_code?: string | null
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          policy_name: string
        }
        Update: {
          amount_max?: number | null
          amount_min?: number | null
          approval_level?: number
          approver_role?: string
          company_code?: string | null
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          policy_name?: string
        }
        Relationships: []
      }
      po_approval_routes: {
        Row: {
          completed_at: string | null
          created_at: string | null
          created_by: string | null
          current_level: number | null
          id: string
          po_number: string
          policy_id: string | null
          status: string | null
          total_levels: number | null
        }
        Insert: {
          completed_at?: string | null
          created_at?: string | null
          created_by?: string | null
          current_level?: number | null
          id?: string
          po_number: string
          policy_id?: string | null
          status?: string | null
          total_levels?: number | null
        }
        Update: {
          completed_at?: string | null
          created_at?: string | null
          created_by?: string | null
          current_level?: number | null
          id?: string
          po_number?: string
          policy_id?: string | null
          status?: string | null
          total_levels?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "po_approval_routes_policy_id_fkey"
            columns: ["policy_id"]
            isOneToOne: false
            referencedRelation: "po_approval_policies"
            referencedColumns: ["id"]
          },
        ]
      }
      po_lines: {
        Row: {
          boq_item_id: string | null
          delivery_date: string | null
          description: string
          id: string
          line_number: number
          line_total: number | null
          pending_quantity: number | null
          po_id: string
          quantity: number
          received_quantity: number | null
          specification: string | null
          unit: string
          unit_rate: number
        }
        Insert: {
          boq_item_id?: string | null
          delivery_date?: string | null
          description: string
          id?: string
          line_number: number
          line_total?: number | null
          pending_quantity?: number | null
          po_id: string
          quantity: number
          received_quantity?: number | null
          specification?: string | null
          unit: string
          unit_rate: number
        }
        Update: {
          boq_item_id?: string | null
          delivery_date?: string | null
          description?: string
          id?: string
          line_number?: number
          line_total?: number | null
          pending_quantity?: number | null
          po_id?: string
          quantity?: number
          received_quantity?: number | null
          specification?: string | null
          unit?: string
          unit_rate?: number
        }
        Relationships: [
          {
            foreignKeyName: "po_lines_boq_item_id_fkey"
            columns: ["boq_item_id"]
            isOneToOne: false
            referencedRelation: "boq_items"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "po_lines_po_id_fkey"
            columns: ["po_id"]
            isOneToOne: false
            referencedRelation: "purchase_orders"
            referencedColumns: ["id"]
          },
        ]
      }
      posting_key_mapping: {
        Row: {
          created_at: string | null
          debit_credit: string
          event_type: string
          gl_account_type: string
          id: string
          is_active: boolean | null
          posting_key: string
          posting_key_description: string | null
        }
        Insert: {
          created_at?: string | null
          debit_credit: string
          event_type: string
          gl_account_type: string
          id?: string
          is_active?: boolean | null
          posting_key: string
          posting_key_description?: string | null
        }
        Update: {
          created_at?: string | null
          debit_credit?: string
          event_type?: string
          gl_account_type?: string
          id?: string
          is_active?: boolean | null
          posting_key?: string
          posting_key_description?: string | null
        }
        Relationships: []
      }
      pr_lines: {
        Row: {
          cost_object_id: string | null
          description: string
          estimated_total_cost: number | null
          estimated_unit_cost: number | null
          id: string
          line_number: number
          pr_id: string
          preferred_vendor_id: string | null
          quantity: number
          specification: string | null
          unit: string
          urgency_level: number | null
        }
        Insert: {
          cost_object_id?: string | null
          description: string
          estimated_total_cost?: number | null
          estimated_unit_cost?: number | null
          id?: string
          line_number: number
          pr_id: string
          preferred_vendor_id?: string | null
          quantity: number
          specification?: string | null
          unit: string
          urgency_level?: number | null
        }
        Update: {
          cost_object_id?: string | null
          description?: string
          estimated_total_cost?: number | null
          estimated_unit_cost?: number | null
          id?: string
          line_number?: number
          pr_id?: string
          preferred_vendor_id?: string | null
          quantity?: number
          specification?: string | null
          unit?: string
          urgency_level?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "pr_lines_cost_object_id_fkey"
            columns: ["cost_object_id"]
            isOneToOne: false
            referencedRelation: "cost_objects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "pr_lines_pr_id_fkey"
            columns: ["pr_id"]
            isOneToOne: false
            referencedRelation: "purchase_requisitions"
            referencedColumns: ["id"]
          },
        ]
      }
      profit_centers: {
        Row: {
          company_code: string | null
          company_code_id: string
          controlling_area_code: string | null
          created_at: string | null
          id: string
          is_active: boolean | null
          profit_center_code: string
          profit_center_name: string
          profit_center_type: string | null
          responsible_person: string | null
          valid_from: string | null
          valid_to: string | null
        }
        Insert: {
          company_code?: string | null
          company_code_id: string
          controlling_area_code?: string | null
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          profit_center_code: string
          profit_center_name: string
          profit_center_type?: string | null
          responsible_person?: string | null
          valid_from?: string | null
          valid_to?: string | null
        }
        Update: {
          company_code?: string | null
          company_code_id?: string
          controlling_area_code?: string | null
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          profit_center_code?: string
          profit_center_name?: string
          profit_center_type?: string | null
          responsible_person?: string | null
          valid_from?: string | null
          valid_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "profit_centers_company_code_fkey"
            columns: ["company_code"]
            isOneToOne: false
            referencedRelation: "company_codes"
            referencedColumns: ["company_code"]
          },
          {
            foreignKeyName: "profit_centers_company_code_fkey"
            columns: ["company_code"]
            isOneToOne: false
            referencedRelation: "v_companies_with_names"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "profit_centers_company_code_id_fkey"
            columns: ["company_code_id"]
            isOneToOne: false
            referencedRelation: "company_codes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "profit_centers_controlling_area_code_fkey"
            columns: ["controlling_area_code"]
            isOneToOne: false
            referencedRelation: "controlling_areas"
            referencedColumns: ["cocarea_code"]
          },
        ]
      }
      project_billing: {
        Row: {
          billing_amount: number
          billing_date: string
          billing_type: string | null
          created_at: string | null
          description: string | null
          id: string
          invoice_number: string | null
          project_id: string
          status: string | null
        }
        Insert: {
          billing_amount: number
          billing_date: string
          billing_type?: string | null
          created_at?: string | null
          description?: string | null
          id?: string
          invoice_number?: string | null
          project_id: string
          status?: string | null
        }
        Update: {
          billing_amount?: number
          billing_date?: string
          billing_type?: string | null
          created_at?: string | null
          description?: string | null
          id?: string
          invoice_number?: string | null
          project_id?: string
          status?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "project_billing_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "project_billing_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "project_billing_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "project_billing_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
        ]
      }
      project_categories: {
        Row: {
          category_code: string
          category_name: string
          company_code: string
          cost_ownership: string | null
          created_at: string | null
          created_by: string | null
          id: number
          is_active: boolean | null
          mobile_enabled: boolean | null
          posting_logic: string | null
          profitability_analysis: boolean | null
          real_time_posting: boolean | null
          sort_order: number | null
          template_id: number | null
          updated_at: string | null
        }
        Insert: {
          category_code: string
          category_name: string
          company_code: string
          cost_ownership?: string | null
          created_at?: string | null
          created_by?: string | null
          id?: number
          is_active?: boolean | null
          mobile_enabled?: boolean | null
          posting_logic?: string | null
          profitability_analysis?: boolean | null
          real_time_posting?: boolean | null
          sort_order?: number | null
          template_id?: number | null
          updated_at?: string | null
        }
        Update: {
          category_code?: string
          category_name?: string
          company_code?: string
          cost_ownership?: string | null
          created_at?: string | null
          created_by?: string | null
          id?: number
          is_active?: boolean | null
          mobile_enabled?: boolean | null
          posting_logic?: string | null
          profitability_analysis?: boolean | null
          real_time_posting?: boolean | null
          sort_order?: number | null
          template_id?: number | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "project_categories_template_id_fkey"
            columns: ["template_id"]
            isOneToOne: false
            referencedRelation: "project_category_templates"
            referencedColumns: ["id"]
          },
        ]
      }
      project_category_templates: {
        Row: {
          created_at: string | null
          description: string | null
          id: number
          industry: string
          is_active: boolean | null
          template_code: string
          template_name: string
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          description?: string | null
          id?: number
          industry: string
          is_active?: boolean | null
          template_code: string
          template_name: string
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          description?: string | null
          id?: number
          industry?: string
          is_active?: boolean | null
          template_code?: string
          template_name?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      project_gl_determination: {
        Row: {
          company_code: string | null
          created_at: string | null
          debit_credit: string
          event_type: string
          gl_account_type: string
          id: string
          is_active: boolean | null
          posting_key: string
          project_category: string
          updated_at: string | null
        }
        Insert: {
          company_code?: string | null
          created_at?: string | null
          debit_credit: string
          event_type: string
          gl_account_type: string
          id?: string
          is_active?: boolean | null
          posting_key: string
          project_category: string
          updated_at?: string | null
        }
        Update: {
          company_code?: string | null
          created_at?: string | null
          debit_credit?: string
          event_type?: string
          gl_account_type?: string
          id?: string
          is_active?: boolean | null
          posting_key?: string
          project_category?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      project_indirect_costs: {
        Row: {
          actual_amount: number | null
          allocation_method:
            | Database["public"]["Enums"]["indirect_allocation_method"]
            | null
          allocation_percentage: number | null
          cost_category: string
          created_at: string | null
          description: string
          expense_date: string | null
          id: string
          is_active: boolean | null
          planned_amount: number | null
          project_id: string
          updated_at: string | null
        }
        Insert: {
          actual_amount?: number | null
          allocation_method?:
            | Database["public"]["Enums"]["indirect_allocation_method"]
            | null
          allocation_percentage?: number | null
          cost_category: string
          created_at?: string | null
          description: string
          expense_date?: string | null
          id?: string
          is_active?: boolean | null
          planned_amount?: number | null
          project_id: string
          updated_at?: string | null
        }
        Update: {
          actual_amount?: number | null
          allocation_method?:
            | Database["public"]["Enums"]["indirect_allocation_method"]
            | null
          allocation_percentage?: number | null
          cost_category?: string
          created_at?: string | null
          description?: string
          expense_date?: string | null
          id?: string
          is_active?: boolean | null
          planned_amount?: number | null
          project_id?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "project_indirect_costs_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "project_indirect_costs_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "project_indirect_costs_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "project_indirect_costs_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
        ]
      }
      project_number_reservations: {
        Row: {
          company_code: string
          entity_type: string
          expires_at: string | null
          id: string
          is_consumed: boolean | null
          pattern: string
          reserved_at: string | null
          reserved_code: string
          reserved_number: number
          session_id: string
        }
        Insert: {
          company_code: string
          entity_type: string
          expires_at?: string | null
          id?: string
          is_consumed?: boolean | null
          pattern: string
          reserved_at?: string | null
          reserved_code: string
          reserved_number: number
          session_id: string
        }
        Update: {
          company_code?: string
          entity_type?: string
          expires_at?: string | null
          id?: string
          is_consumed?: boolean | null
          pattern?: string
          reserved_at?: string | null
          reserved_code?: string
          reserved_number?: number
          session_id?: string
        }
        Relationships: []
      }
      project_numbering_rules: {
        Row: {
          company_code: string | null
          created_at: string | null
          description: string | null
          entity_type: string
          id: string
          is_active: boolean | null
          pattern: string
          updated_at: string | null
        }
        Insert: {
          company_code?: string | null
          created_at?: string | null
          description?: string | null
          entity_type: string
          id?: string
          is_active?: boolean | null
          pattern: string
          updated_at?: string | null
        }
        Update: {
          company_code?: string | null
          created_at?: string | null
          description?: string | null
          entity_type?: string
          id?: string
          is_active?: boolean | null
          pattern?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      project_types: {
        Row: {
          category_code: string
          company_code: string | null
          created_at: string | null
          description: string | null
          gl_posting_variant: string | null
          id: string
          is_active: boolean | null
          sort_order: number | null
          type_code: string
          type_name: string
          updated_at: string | null
        }
        Insert: {
          category_code: string
          company_code?: string | null
          created_at?: string | null
          description?: string | null
          gl_posting_variant?: string | null
          id?: string
          is_active?: boolean | null
          sort_order?: number | null
          type_code: string
          type_name: string
          updated_at?: string | null
        }
        Update: {
          category_code?: string
          company_code?: string | null
          created_at?: string | null
          description?: string | null
          gl_posting_variant?: string | null
          id?: string
          is_active?: boolean | null
          sort_order?: number | null
          type_code?: string
          type_name?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      project_workflows: {
        Row: {
          company_code: string | null
          created_at: string | null
          description: string | null
          id: string
          is_active: boolean | null
          status: string | null
          steps: number | null
          updated_at: string | null
          workflow_name: string
          workflow_type: string
        }
        Insert: {
          company_code?: string | null
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
          status?: string | null
          steps?: number | null
          updated_at?: string | null
          workflow_name: string
          workflow_type: string
        }
        Update: {
          company_code?: string | null
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
          status?: string | null
          steps?: number | null
          updated_at?: string | null
          workflow_name?: string
          workflow_type?: string
        }
        Relationships: []
      }
      projects: {
        Row: {
          actual_end_date: string | null
          budget: number
          category_code: string
          client_id: string | null
          code: string
          company_code: string | null
          company_code_id: string | null
          cost_center_id: string | null
          created_at: string | null
          created_by: string | null
          description: string | null
          end_date: string | null
          holidays: string[] | null
          id: string
          indirect_cost_allocation_method:
            | Database["public"]["Enums"]["indirect_allocation_method"]
            | null
          location: string | null
          name: string
          person_responsible_id: string | null
          planned_end_date: string
          plant_id: string | null
          profit_center_id: string | null
          project_direct_cost_total: number | null
          project_indirect_cost_actual: number | null
          project_indirect_cost_plan: number | null
          project_manager_id: string | null
          project_type: Database["public"]["Enums"]["project_type"]
          purchasing_org_id: string | null
          site_code: string | null
          site_name: string | null
          start_date: string
          status: Database["public"]["Enums"]["project_status"]
          updated_at: string | null
          working_days: number[] | null
        }
        Insert: {
          actual_end_date?: string | null
          budget: number
          category_code: string
          client_id?: string | null
          code: string
          company_code?: string | null
          company_code_id?: string | null
          cost_center_id?: string | null
          created_at?: string | null
          created_by?: string | null
          description?: string | null
          end_date?: string | null
          holidays?: string[] | null
          id?: string
          indirect_cost_allocation_method?:
            | Database["public"]["Enums"]["indirect_allocation_method"]
            | null
          location?: string | null
          name: string
          person_responsible_id?: string | null
          planned_end_date: string
          plant_id?: string | null
          profit_center_id?: string | null
          project_direct_cost_total?: number | null
          project_indirect_cost_actual?: number | null
          project_indirect_cost_plan?: number | null
          project_manager_id?: string | null
          project_type: Database["public"]["Enums"]["project_type"]
          purchasing_org_id?: string | null
          site_code?: string | null
          site_name?: string | null
          start_date: string
          status?: Database["public"]["Enums"]["project_status"]
          updated_at?: string | null
          working_days?: number[] | null
        }
        Update: {
          actual_end_date?: string | null
          budget?: number
          category_code?: string
          client_id?: string | null
          code?: string
          company_code?: string | null
          company_code_id?: string | null
          cost_center_id?: string | null
          created_at?: string | null
          created_by?: string | null
          description?: string | null
          end_date?: string | null
          holidays?: string[] | null
          id?: string
          indirect_cost_allocation_method?:
            | Database["public"]["Enums"]["indirect_allocation_method"]
            | null
          location?: string | null
          name?: string
          person_responsible_id?: string | null
          planned_end_date?: string
          plant_id?: string | null
          profit_center_id?: string | null
          project_direct_cost_total?: number | null
          project_indirect_cost_actual?: number | null
          project_indirect_cost_plan?: number | null
          project_manager_id?: string | null
          project_type?: Database["public"]["Enums"]["project_type"]
          purchasing_org_id?: string | null
          site_code?: string | null
          site_name?: string | null
          start_date?: string
          status?: Database["public"]["Enums"]["project_status"]
          updated_at?: string | null
          working_days?: number[] | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_projects_cost_center"
            columns: ["cost_center_id"]
            isOneToOne: false
            referencedRelation: "cost_centers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_projects_person_responsible"
            columns: ["person_responsible_id"]
            isOneToOne: false
            referencedRelation: "persons_responsible"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_projects_plant"
            columns: ["plant_id"]
            isOneToOne: false
            referencedRelation: "plants"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_projects_profit_center"
            columns: ["profit_center_id"]
            isOneToOne: false
            referencedRelation: "profit_centers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "projects_category_code_fkey"
            columns: ["category_code"]
            isOneToOne: false
            referencedRelation: "project_categories"
            referencedColumns: ["category_code"]
          },
          {
            foreignKeyName: "projects_company_code_fkey"
            columns: ["company_code"]
            isOneToOne: false
            referencedRelation: "company_codes"
            referencedColumns: ["company_code"]
          },
          {
            foreignKeyName: "projects_company_code_fkey"
            columns: ["company_code"]
            isOneToOne: false
            referencedRelation: "v_companies_with_names"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "projects_company_code_id_fkey"
            columns: ["company_code_id"]
            isOneToOne: false
            referencedRelation: "company_codes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "projects_plant_id_fkey"
            columns: ["plant_id"]
            isOneToOne: false
            referencedRelation: "plants"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "projects_profit_center_id_fkey"
            columns: ["profit_center_id"]
            isOneToOne: false
            referencedRelation: "profit_centers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "projects_purchasing_org_id_fkey"
            columns: ["purchasing_org_id"]
            isOneToOne: false
            referencedRelation: "purchasing_organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      purchase_order_items: {
        Row: {
          account_assignment_category: string | null
          account_assignment_object: string | null
          base_unit: string | null
          cgst_amount: number | null
          cgst_rate: number | null
          cost_center: string | null
          created_at: string | null
          delivery_date: string | null
          discount_amount: number | null
          discount_percent: number | null
          gl_account: string | null
          id: string
          igst_amount: number | null
          igst_rate: number | null
          invoiced_quantity: number | null
          item_number: number
          item_status: string | null
          material_code: string | null
          material_description: string | null
          material_id: string | null
          net_amount: number | null
          plant_code: string | null
          po_id: string | null
          profit_center: string | null
          quantity: number
          received_quantity: number | null
          sgst_amount: number | null
          sgst_rate: number | null
          storage_location: string | null
          tax_amount: number | null
          tax_code: string | null
          tax_rate: number | null
          total_price: number
          total_tax_amount: number | null
          unit: string | null
          unit_price: number
          wbs_element: string | null
        }
        Insert: {
          account_assignment_category?: string | null
          account_assignment_object?: string | null
          base_unit?: string | null
          cgst_amount?: number | null
          cgst_rate?: number | null
          cost_center?: string | null
          created_at?: string | null
          delivery_date?: string | null
          discount_amount?: number | null
          discount_percent?: number | null
          gl_account?: string | null
          id?: string
          igst_amount?: number | null
          igst_rate?: number | null
          invoiced_quantity?: number | null
          item_number: number
          item_status?: string | null
          material_code?: string | null
          material_description?: string | null
          material_id?: string | null
          net_amount?: number | null
          plant_code?: string | null
          po_id?: string | null
          profit_center?: string | null
          quantity: number
          received_quantity?: number | null
          sgst_amount?: number | null
          sgst_rate?: number | null
          storage_location?: string | null
          tax_amount?: number | null
          tax_code?: string | null
          tax_rate?: number | null
          total_price: number
          total_tax_amount?: number | null
          unit?: string | null
          unit_price: number
          wbs_element?: string | null
        }
        Update: {
          account_assignment_category?: string | null
          account_assignment_object?: string | null
          base_unit?: string | null
          cgst_amount?: number | null
          cgst_rate?: number | null
          cost_center?: string | null
          created_at?: string | null
          delivery_date?: string | null
          discount_amount?: number | null
          discount_percent?: number | null
          gl_account?: string | null
          id?: string
          igst_amount?: number | null
          igst_rate?: number | null
          invoiced_quantity?: number | null
          item_number?: number
          item_status?: string | null
          material_code?: string | null
          material_description?: string | null
          material_id?: string | null
          net_amount?: number | null
          plant_code?: string | null
          po_id?: string | null
          profit_center?: string | null
          quantity?: number
          received_quantity?: number | null
          sgst_amount?: number | null
          sgst_rate?: number | null
          storage_location?: string | null
          tax_amount?: number | null
          tax_code?: string | null
          tax_rate?: number | null
          total_price?: number
          total_tax_amount?: number | null
          unit?: string | null
          unit_price?: number
          wbs_element?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "purchase_order_items_material_id_fkey"
            columns: ["material_id"]
            isOneToOne: false
            referencedRelation: "materials"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "purchase_order_items_po_id_fkey"
            columns: ["po_id"]
            isOneToOne: false
            referencedRelation: "purchase_orders"
            referencedColumns: ["id"]
          },
        ]
      }
      purchase_orders: {
        Row: {
          approval_route_id: string | null
          approval_status: string | null
          approved_at: string | null
          approved_by: string | null
          approved_date: string | null
          budget_code: string | null
          cost_center: string | null
          created_at: string | null
          created_by: string
          currency: string | null
          current_approval_level: number | null
          delivery_address: string | null
          delivery_date: string
          delivery_terms: string | null
          department: string | null
          discount_amount: number | null
          grand_total: number | null
          id: string
          issue_date: string
          net_amount: number | null
          notes: string | null
          payment_terms: string | null
          po_date: string | null
          po_number: string
          po_type: Database["public"]["Enums"]["po_type"]
          priority: string | null
          project_code: string | null
          project_id: string
          purchasing_org_id: string | null
          remarks: string | null
          status: Database["public"]["Enums"]["po_status"]
          tax_amount: number | null
          terms_conditions: string | null
          total_amount: number
          updated_at: string | null
          vendor_code: string | null
          vendor_id: string
        }
        Insert: {
          approval_route_id?: string | null
          approval_status?: string | null
          approved_at?: string | null
          approved_by?: string | null
          approved_date?: string | null
          budget_code?: string | null
          cost_center?: string | null
          created_at?: string | null
          created_by: string
          currency?: string | null
          current_approval_level?: number | null
          delivery_address?: string | null
          delivery_date: string
          delivery_terms?: string | null
          department?: string | null
          discount_amount?: number | null
          grand_total?: number | null
          id?: string
          issue_date: string
          net_amount?: number | null
          notes?: string | null
          payment_terms?: string | null
          po_date?: string | null
          po_number: string
          po_type?: Database["public"]["Enums"]["po_type"]
          priority?: string | null
          project_code?: string | null
          project_id: string
          purchasing_org_id?: string | null
          remarks?: string | null
          status?: Database["public"]["Enums"]["po_status"]
          tax_amount?: number | null
          terms_conditions?: string | null
          total_amount: number
          updated_at?: string | null
          vendor_code?: string | null
          vendor_id: string
        }
        Update: {
          approval_route_id?: string | null
          approval_status?: string | null
          approved_at?: string | null
          approved_by?: string | null
          approved_date?: string | null
          budget_code?: string | null
          cost_center?: string | null
          created_at?: string | null
          created_by?: string
          currency?: string | null
          current_approval_level?: number | null
          delivery_address?: string | null
          delivery_date?: string
          delivery_terms?: string | null
          department?: string | null
          discount_amount?: number | null
          grand_total?: number | null
          id?: string
          issue_date?: string
          net_amount?: number | null
          notes?: string | null
          payment_terms?: string | null
          po_date?: string | null
          po_number?: string
          po_type?: Database["public"]["Enums"]["po_type"]
          priority?: string | null
          project_code?: string | null
          project_id?: string
          purchasing_org_id?: string | null
          remarks?: string | null
          status?: Database["public"]["Enums"]["po_status"]
          tax_amount?: number | null
          terms_conditions?: string | null
          total_amount?: number
          updated_at?: string | null
          vendor_code?: string | null
          vendor_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "purchase_orders_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "purchase_orders_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "purchase_orders_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "purchase_orders_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "purchase_orders_purchasing_org_id_fkey"
            columns: ["purchasing_org_id"]
            isOneToOne: false
            referencedRelation: "purchasing_organizations"
            referencedColumns: ["id"]
          },
        ]
      }
      purchase_requisitions: {
        Row: {
          approved_by: string | null
          approved_date: string | null
          created_at: string | null
          department: string | null
          id: string
          justification: string | null
          priority: number | null
          project_id: string
          rejection_reason: string | null
          requested_by: string
          required_date: string
          requisition_number: string
          status: Database["public"]["Enums"]["requisition_status"] | null
          total_estimated_cost: number | null
          updated_at: string | null
        }
        Insert: {
          approved_by?: string | null
          approved_date?: string | null
          created_at?: string | null
          department?: string | null
          id?: string
          justification?: string | null
          priority?: number | null
          project_id: string
          rejection_reason?: string | null
          requested_by: string
          required_date: string
          requisition_number: string
          status?: Database["public"]["Enums"]["requisition_status"] | null
          total_estimated_cost?: number | null
          updated_at?: string | null
        }
        Update: {
          approved_by?: string | null
          approved_date?: string | null
          created_at?: string | null
          department?: string | null
          id?: string
          justification?: string | null
          priority?: number | null
          project_id?: string
          rejection_reason?: string | null
          requested_by?: string
          required_date?: string
          requisition_number?: string
          status?: Database["public"]["Enums"]["requisition_status"] | null
          total_estimated_cost?: number | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "purchase_requisitions_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "purchase_requisitions_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "purchase_requisitions_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "purchase_requisitions_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
        ]
      }
      purchasing_organizations: {
        Row: {
          company_code: string | null
          company_code_id: string
          currency: string | null
          id: string
          is_active: boolean | null
          porg_code: string
          porg_name: string
        }
        Insert: {
          company_code?: string | null
          company_code_id: string
          currency?: string | null
          id?: string
          is_active?: boolean | null
          porg_code: string
          porg_name: string
        }
        Update: {
          company_code?: string | null
          company_code_id?: string
          currency?: string | null
          id?: string
          is_active?: boolean | null
          porg_code?: string
          porg_name?: string
        }
        Relationships: [
          {
            foreignKeyName: "porg_company_code_fkey"
            columns: ["company_code"]
            isOneToOne: false
            referencedRelation: "company_codes"
            referencedColumns: ["company_code"]
          },
          {
            foreignKeyName: "porg_company_code_fkey"
            columns: ["company_code"]
            isOneToOne: false
            referencedRelation: "v_companies_with_names"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "purchasing_organizations_company_code_fkey"
            columns: ["company_code"]
            isOneToOne: false
            referencedRelation: "company_codes"
            referencedColumns: ["company_code"]
          },
          {
            foreignKeyName: "purchasing_organizations_company_code_fkey"
            columns: ["company_code"]
            isOneToOne: false
            referencedRelation: "v_companies_with_names"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "purchasing_organizations_company_code_id_fkey"
            columns: ["company_code_id"]
            isOneToOne: false
            referencedRelation: "company_codes"
            referencedColumns: ["id"]
          },
        ]
      }
      responsibility_assignments: {
        Row: {
          approval_limit: number | null
          employee_id: string
          id: string
          is_active: boolean | null
          responsibility_type: string
          responsibility_value: string
        }
        Insert: {
          approval_limit?: number | null
          employee_id: string
          id?: string
          is_active?: boolean | null
          responsibility_type: string
          responsibility_value: string
        }
        Update: {
          approval_limit?: number | null
          employee_id?: string
          id?: string
          is_active?: boolean | null
          responsibility_type?: string
          responsibility_value?: string
        }
        Relationships: []
      }
      role_assignments: {
        Row: {
          employee_id: string
          id: string
          is_active: boolean | null
          role_code: string
          scope_type: string | null
          scope_value: string | null
        }
        Insert: {
          employee_id: string
          id?: string
          is_active?: boolean | null
          role_code: string
          scope_type?: string | null
          scope_value?: string | null
        }
        Update: {
          employee_id?: string
          id?: string
          is_active?: boolean | null
          role_code?: string
          scope_type?: string | null
          scope_value?: string | null
        }
        Relationships: []
      }
      role_authorization_mapping: {
        Row: {
          auth_object_name: string
          created_at: string | null
          field_values: Json
          id: string
          role_name: string
        }
        Insert: {
          auth_object_name: string
          created_at?: string | null
          field_values: Json
          id?: string
          role_name: string
        }
        Update: {
          auth_object_name?: string
          created_at?: string | null
          field_values?: Json
          id?: string
          role_name?: string
        }
        Relationships: []
      }
      role_authorization_objects: {
        Row: {
          auth_object_id: string
          created_at: string | null
          field_values: Json
          id: string
          inherited_from: string | null
          is_active: boolean | null
          module_full_access: boolean | null
          object_full_access: boolean | null
          role_id: string
          valid_from: string | null
          valid_to: string | null
        }
        Insert: {
          auth_object_id: string
          created_at?: string | null
          field_values: Json
          id?: string
          inherited_from?: string | null
          is_active?: boolean | null
          module_full_access?: boolean | null
          object_full_access?: boolean | null
          role_id: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Update: {
          auth_object_id?: string
          created_at?: string | null
          field_values?: Json
          id?: string
          inherited_from?: string | null
          is_active?: boolean | null
          module_full_access?: boolean | null
          object_full_access?: boolean | null
          role_id?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "role_authorization_objects_auth_object_id_fkey"
            columns: ["auth_object_id"]
            isOneToOne: false
            referencedRelation: "authorization_objects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "role_authorization_objects_role_id_fkey"
            columns: ["role_id"]
            isOneToOne: false
            referencedRelation: "roles"
            referencedColumns: ["id"]
          },
        ]
      }
      role_permissions: {
        Row: {
          created_at: string | null
          id: string
          permission_id: string
          role_id: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          permission_id: string
          role_id: string
        }
        Update: {
          created_at?: string | null
          id?: string
          permission_id?: string
          role_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "role_permissions_permission_id_fkey"
            columns: ["permission_id"]
            isOneToOne: false
            referencedRelation: "permissions"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "role_permissions_role_id_fkey"
            columns: ["role_id"]
            isOneToOne: false
            referencedRelation: "roles"
            referencedColumns: ["id"]
          },
        ]
      }
      roles: {
        Row: {
          created_at: string | null
          description: string | null
          id: string
          is_active: boolean | null
          name: string
          permissions: Json | null
        }
        Insert: {
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
          name: string
          permissions?: Json | null
        }
        Update: {
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
          name?: string
          permissions?: Json | null
        }
        Relationships: []
      }
      service_lines: {
        Row: {
          activity_id: string
          actual_amount: number | null
          actual_quantity: number | null
          amount: number | null
          created_at: string | null
          id: string
          line_description: string
          quantity: number
          rate: number
          uom: string
          updated_at: string | null
        }
        Insert: {
          activity_id: string
          actual_amount?: number | null
          actual_quantity?: number | null
          amount?: number | null
          created_at?: string | null
          id?: string
          line_description: string
          quantity: number
          rate: number
          uom: string
          updated_at?: string | null
        }
        Update: {
          activity_id?: string
          actual_amount?: number | null
          actual_quantity?: number | null
          amount?: number | null
          created_at?: string | null
          id?: string
          line_description?: string
          quantity?: number
          rate?: number
          uom?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "service_lines_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "service_lines_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activity_variance"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "service_lines_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "mv_activities_resource_status"
            referencedColumns: ["activity_id"]
          },
        ]
      }
      step_agents: {
        Row: {
          agent_rule: string
          agent_sequence: number | null
          created_at: string | null
          id: string
          is_required: boolean | null
          workflow_step_id: string
        }
        Insert: {
          agent_rule: string
          agent_sequence?: number | null
          created_at?: string | null
          id?: string
          is_required?: boolean | null
          workflow_step_id: string
        }
        Update: {
          agent_rule?: string
          agent_sequence?: number | null
          created_at?: string | null
          id?: string
          is_required?: boolean | null
          workflow_step_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "step_agents_workflow_step_id_fkey"
            columns: ["workflow_step_id"]
            isOneToOne: false
            referencedRelation: "workflow_steps"
            referencedColumns: ["id"]
          },
        ]
      }
      step_completion_status: {
        Row: {
          approved_count: number | null
          completed_at: string | null
          completion_rule: string
          id: string
          is_completed: boolean | null
          min_approvals: number | null
          pending_count: number | null
          rejected_count: number | null
          step_sequence: number
          total_agents: number
          workflow_instance_id: string
          workflow_step_id: string
        }
        Insert: {
          approved_count?: number | null
          completed_at?: string | null
          completion_rule: string
          id?: string
          is_completed?: boolean | null
          min_approvals?: number | null
          pending_count?: number | null
          rejected_count?: number | null
          step_sequence: number
          total_agents: number
          workflow_instance_id: string
          workflow_step_id: string
        }
        Update: {
          approved_count?: number | null
          completed_at?: string | null
          completion_rule?: string
          id?: string
          is_completed?: boolean | null
          min_approvals?: number | null
          pending_count?: number | null
          rejected_count?: number | null
          step_sequence?: number
          total_agents?: number
          workflow_instance_id?: string
          workflow_step_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "step_completion_status_workflow_instance_id_fkey"
            columns: ["workflow_instance_id"]
            isOneToOne: false
            referencedRelation: "workflow_instances"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "step_completion_status_workflow_step_id_fkey"
            columns: ["workflow_step_id"]
            isOneToOne: false
            referencedRelation: "workflow_steps"
            referencedColumns: ["id"]
          },
        ]
      }
      step_instances: {
        Row: {
          assigned_agent_id: string | null
          assigned_agent_name: string | null
          assigned_agent_role: string | null
          comments: string | null
          created_at: string | null
          decided_at: string | null
          decision: string | null
          id: string
          is_step_completed: boolean | null
          status: string | null
          step_agent_id: string | null
          step_sequence: number
          timeout_at: string | null
          workflow_instance_id: string
          workflow_step_id: string
        }
        Insert: {
          assigned_agent_id?: string | null
          assigned_agent_name?: string | null
          assigned_agent_role?: string | null
          comments?: string | null
          created_at?: string | null
          decided_at?: string | null
          decision?: string | null
          id?: string
          is_step_completed?: boolean | null
          status?: string | null
          step_agent_id?: string | null
          step_sequence: number
          timeout_at?: string | null
          workflow_instance_id: string
          workflow_step_id: string
        }
        Update: {
          assigned_agent_id?: string | null
          assigned_agent_name?: string | null
          assigned_agent_role?: string | null
          comments?: string | null
          created_at?: string | null
          decided_at?: string | null
          decision?: string | null
          id?: string
          is_step_completed?: boolean | null
          status?: string | null
          step_agent_id?: string | null
          step_sequence?: number
          timeout_at?: string | null
          workflow_instance_id?: string
          workflow_step_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "step_instances_step_agent_id_fkey"
            columns: ["step_agent_id"]
            isOneToOne: false
            referencedRelation: "step_agents"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "step_instances_workflow_instance_id_fkey"
            columns: ["workflow_instance_id"]
            isOneToOne: false
            referencedRelation: "workflow_instances"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "step_instances_workflow_step_id_fkey"
            columns: ["workflow_step_id"]
            isOneToOne: false
            referencedRelation: "workflow_steps"
            referencedColumns: ["id"]
          },
        ]
      }
      stock_balances: {
        Row: {
          account_assignment: string | null
          available_quantity: number | null
          average_cost: number | null
          cost_center: string | null
          current_quantity: number | null
          id: string
          last_movement_date: string | null
          material_code: string | null
          project_code: string | null
          reserved_quantity: number | null
          stock_item_id: string
          stock_type: string | null
          storage_location_id: string
          total_value: number | null
          wbs_element: string | null
        }
        Insert: {
          account_assignment?: string | null
          available_quantity?: number | null
          average_cost?: number | null
          cost_center?: string | null
          current_quantity?: number | null
          id?: string
          last_movement_date?: string | null
          material_code?: string | null
          project_code?: string | null
          reserved_quantity?: number | null
          stock_item_id: string
          stock_type?: string | null
          storage_location_id: string
          total_value?: number | null
          wbs_element?: string | null
        }
        Update: {
          account_assignment?: string | null
          available_quantity?: number | null
          average_cost?: number | null
          cost_center?: string | null
          current_quantity?: number | null
          id?: string
          last_movement_date?: string | null
          material_code?: string | null
          project_code?: string | null
          reserved_quantity?: number | null
          stock_item_id?: string
          stock_type?: string | null
          storage_location_id?: string
          total_value?: number | null
          wbs_element?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_stock_balances_material"
            columns: ["material_code"]
            isOneToOne: false
            referencedRelation: "material_master_view"
            referencedColumns: ["material_code"]
          },
          {
            foreignKeyName: "fk_stock_balances_material"
            columns: ["material_code"]
            isOneToOne: false
            referencedRelation: "materials"
            referencedColumns: ["material_code"]
          },
          {
            foreignKeyName: "stock_balances_stock_item_id_fkey"
            columns: ["stock_item_id"]
            isOneToOne: false
            referencedRelation: "global_materials"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "stock_balances_stock_item_id_fkey"
            columns: ["stock_item_id"]
            isOneToOne: false
            referencedRelation: "project_materials"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "stock_balances_stock_item_id_fkey"
            columns: ["stock_item_id"]
            isOneToOne: false
            referencedRelation: "stock_items"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "stock_balances_storage_location_id_fkey"
            columns: ["storage_location_id"]
            isOneToOne: false
            referencedRelation: "storage_locations"
            referencedColumns: ["id"]
          },
        ]
      }
      stock_fifo_layers: {
        Row: {
          batch_reference: string
          created_at: string | null
          grn_line_id: string | null
          id: string
          original_quantity: number
          receipt_date: string
          remaining_quantity: number
          stock_item_id: string
          store_id: string
          unit_cost: number
        }
        Insert: {
          batch_reference: string
          created_at?: string | null
          grn_line_id?: string | null
          id?: string
          original_quantity: number
          receipt_date: string
          remaining_quantity: number
          stock_item_id: string
          store_id: string
          unit_cost: number
        }
        Update: {
          batch_reference?: string
          created_at?: string | null
          grn_line_id?: string | null
          id?: string
          original_quantity?: number
          receipt_date?: string
          remaining_quantity?: number
          stock_item_id?: string
          store_id?: string
          unit_cost?: number
        }
        Relationships: [
          {
            foreignKeyName: "stock_fifo_layers_grn_line_id_fkey"
            columns: ["grn_line_id"]
            isOneToOne: false
            referencedRelation: "grn_lines"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "stock_fifo_layers_stock_item_id_fkey"
            columns: ["stock_item_id"]
            isOneToOne: false
            referencedRelation: "global_materials"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "stock_fifo_layers_stock_item_id_fkey"
            columns: ["stock_item_id"]
            isOneToOne: false
            referencedRelation: "project_materials"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "stock_fifo_layers_stock_item_id_fkey"
            columns: ["stock_item_id"]
            isOneToOne: false
            referencedRelation: "stock_items"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "stock_fifo_layers_store_id_fkey"
            columns: ["store_id"]
            isOneToOne: false
            referencedRelation: "stores"
            referencedColumns: ["id"]
          },
        ]
      }
      stock_items: {
        Row: {
          category: string | null
          created_at: string | null
          description: string
          id: string
          is_active: boolean | null
          item_code: string
          material_type_id: string | null
          maximum_level: number | null
          minimum_level: number | null
          project_id: string | null
          reorder_level: number | null
          unit: string
          updated_at: string | null
          valuation_class_id: string | null
        }
        Insert: {
          category?: string | null
          created_at?: string | null
          description: string
          id?: string
          is_active?: boolean | null
          item_code: string
          material_type_id?: string | null
          maximum_level?: number | null
          minimum_level?: number | null
          project_id?: string | null
          reorder_level?: number | null
          unit: string
          updated_at?: string | null
          valuation_class_id?: string | null
        }
        Update: {
          category?: string | null
          created_at?: string | null
          description?: string
          id?: string
          is_active?: boolean | null
          item_code?: string
          material_type_id?: string | null
          maximum_level?: number | null
          minimum_level?: number | null
          project_id?: string | null
          reorder_level?: number | null
          unit?: string
          updated_at?: string | null
          valuation_class_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "stock_items_material_type_id_fkey"
            columns: ["material_type_id"]
            isOneToOne: false
            referencedRelation: "material_types"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "stock_items_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "stock_items_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "stock_items_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "stock_items_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
        ]
      }
      stock_items_backup: {
        Row: {
          category: string | null
          created_at: string | null
          description: string | null
          id: string | null
          is_active: boolean | null
          item_code: string | null
          material_type_id: string | null
          maximum_level: number | null
          minimum_level: number | null
          project_id: string | null
          reorder_level: number | null
          unit: string | null
          updated_at: string | null
          valuation_class_id: string | null
        }
        Insert: {
          category?: string | null
          created_at?: string | null
          description?: string | null
          id?: string | null
          is_active?: boolean | null
          item_code?: string | null
          material_type_id?: string | null
          maximum_level?: number | null
          minimum_level?: number | null
          project_id?: string | null
          reorder_level?: number | null
          unit?: string | null
          updated_at?: string | null
          valuation_class_id?: string | null
        }
        Update: {
          category?: string | null
          created_at?: string | null
          description?: string | null
          id?: string | null
          is_active?: boolean | null
          item_code?: string | null
          material_type_id?: string | null
          maximum_level?: number | null
          minimum_level?: number | null
          project_id?: string | null
          reorder_level?: number | null
          unit?: string | null
          updated_at?: string | null
          valuation_class_id?: string | null
        }
        Relationships: []
      }
      stock_levels: {
        Row: {
          available_stock: number | null
          current_stock: number | null
          id: string
          last_updated: string | null
          material_id: string | null
          reserved_stock: number | null
          storage_location: string | null
        }
        Insert: {
          available_stock?: number | null
          current_stock?: number | null
          id?: string
          last_updated?: string | null
          material_id?: string | null
          reserved_stock?: number | null
          storage_location?: string | null
        }
        Update: {
          available_stock?: number | null
          current_stock?: number | null
          id?: string
          last_updated?: string | null
          material_id?: string | null
          reserved_stock?: number | null
          storage_location?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "stock_levels_material_id_fkey"
            columns: ["material_id"]
            isOneToOne: false
            referencedRelation: "materials"
            referencedColumns: ["id"]
          },
        ]
      }
      stock_movements: {
        Row: {
          account_assignment: string | null
          cost_center: string | null
          created_at: string | null
          created_by: string
          id: string
          movement_date: string
          movement_type: Database["public"]["Enums"]["movement_type"]
          notes: string | null
          project_code: string | null
          quantity: number
          reference_id: string | null
          reference_number: string
          reference_type: string
          stock_item_id: string
          store_id: string
          total_cost: number | null
          unit_cost: number
          wbs_element: string | null
        }
        Insert: {
          account_assignment?: string | null
          cost_center?: string | null
          created_at?: string | null
          created_by: string
          id?: string
          movement_date: string
          movement_type: Database["public"]["Enums"]["movement_type"]
          notes?: string | null
          project_code?: string | null
          quantity: number
          reference_id?: string | null
          reference_number: string
          reference_type: string
          stock_item_id: string
          store_id: string
          total_cost?: number | null
          unit_cost: number
          wbs_element?: string | null
        }
        Update: {
          account_assignment?: string | null
          cost_center?: string | null
          created_at?: string | null
          created_by?: string
          id?: string
          movement_date?: string
          movement_type?: Database["public"]["Enums"]["movement_type"]
          notes?: string | null
          project_code?: string | null
          quantity?: number
          reference_id?: string | null
          reference_number?: string
          reference_type?: string
          stock_item_id?: string
          store_id?: string
          total_cost?: number | null
          unit_cost?: number
          wbs_element?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "stock_movements_stock_item_id_fkey"
            columns: ["stock_item_id"]
            isOneToOne: false
            referencedRelation: "global_materials"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "stock_movements_stock_item_id_fkey"
            columns: ["stock_item_id"]
            isOneToOne: false
            referencedRelation: "project_materials"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "stock_movements_stock_item_id_fkey"
            columns: ["stock_item_id"]
            isOneToOne: false
            referencedRelation: "stock_items"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "stock_movements_store_id_fkey"
            columns: ["store_id"]
            isOneToOne: false
            referencedRelation: "stores"
            referencedColumns: ["id"]
          },
        ]
      }
      storage_locations: {
        Row: {
          id: string
          is_active: boolean | null
          location_type: string | null
          plant_code: string | null
          plant_id: string
          sloc_code: string
          sloc_name: string
        }
        Insert: {
          id?: string
          is_active?: boolean | null
          location_type?: string | null
          plant_code?: string | null
          plant_id: string
          sloc_code: string
          sloc_name: string
        }
        Update: {
          id?: string
          is_active?: boolean | null
          location_type?: string | null
          plant_code?: string | null
          plant_id?: string
          sloc_code?: string
          sloc_name?: string
        }
        Relationships: [
          {
            foreignKeyName: "storage_locations_plant_code_fkey"
            columns: ["plant_code"]
            isOneToOne: false
            referencedRelation: "plants"
            referencedColumns: ["plant_code"]
          },
          {
            foreignKeyName: "storage_locations_plant_id_fkey"
            columns: ["plant_id"]
            isOneToOne: false
            referencedRelation: "plants"
            referencedColumns: ["id"]
          },
        ]
      }
      stores: {
        Row: {
          auto_delete_when_empty: boolean | null
          code: string
          created_at: string | null
          id: string
          is_active: boolean | null
          is_auto_created: boolean | null
          location: string | null
          name: string
          project_id: string
          site_code: string | null
          storage_location_id: string | null
          store_keeper_id: string | null
          updated_at: string | null
        }
        Insert: {
          auto_delete_when_empty?: boolean | null
          code: string
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          is_auto_created?: boolean | null
          location?: string | null
          name: string
          project_id: string
          site_code?: string | null
          storage_location_id?: string | null
          store_keeper_id?: string | null
          updated_at?: string | null
        }
        Update: {
          auto_delete_when_empty?: boolean | null
          code?: string
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          is_auto_created?: boolean | null
          location?: string | null
          name?: string
          project_id?: string
          site_code?: string | null
          storage_location_id?: string | null
          store_keeper_id?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "stores_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "stores_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "stores_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "stores_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "stores_storage_location_id_fkey"
            columns: ["storage_location_id"]
            isOneToOne: false
            referencedRelation: "storage_locations"
            referencedColumns: ["id"]
          },
        ]
      }
      subcontract_milestones: {
        Row: {
          actual_completion_date: string | null
          completion_percentage: number | null
          description: string | null
          id: string
          is_completed: boolean | null
          milestone_name: string
          milestone_value: number
          planned_completion_date: string
          sequence_order: number
          subcontract_id: string
        }
        Insert: {
          actual_completion_date?: string | null
          completion_percentage?: number | null
          description?: string | null
          id?: string
          is_completed?: boolean | null
          milestone_name: string
          milestone_value: number
          planned_completion_date: string
          sequence_order: number
          subcontract_id: string
        }
        Update: {
          actual_completion_date?: string | null
          completion_percentage?: number | null
          description?: string | null
          id?: string
          is_completed?: boolean | null
          milestone_name?: string
          milestone_value?: number
          planned_completion_date?: string
          sequence_order?: number
          subcontract_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "subcontract_milestones_subcontract_id_fkey"
            columns: ["subcontract_id"]
            isOneToOne: false
            referencedRelation: "subcontract_orders"
            referencedColumns: ["id"]
          },
        ]
      }
      subcontract_orders: {
        Row: {
          advance_percentage: number | null
          approved_by: string | null
          approved_date: string | null
          completion_date: string
          contract_value: number
          created_at: string | null
          created_by: string
          id: string
          payment_terms: string | null
          performance_bond_required: boolean | null
          project_id: string
          retention_percentage: number | null
          start_date: string
          status: Database["public"]["Enums"]["subcontract_status"] | null
          subcontract_number: string
          updated_at: string | null
          vendor_id: string
          work_description: string
        }
        Insert: {
          advance_percentage?: number | null
          approved_by?: string | null
          approved_date?: string | null
          completion_date: string
          contract_value: number
          created_at?: string | null
          created_by: string
          id?: string
          payment_terms?: string | null
          performance_bond_required?: boolean | null
          project_id: string
          retention_percentage?: number | null
          start_date: string
          status?: Database["public"]["Enums"]["subcontract_status"] | null
          subcontract_number: string
          updated_at?: string | null
          vendor_id: string
          work_description: string
        }
        Update: {
          advance_percentage?: number | null
          approved_by?: string | null
          approved_date?: string | null
          completion_date?: string
          contract_value?: number
          created_at?: string | null
          created_by?: string
          id?: string
          payment_terms?: string | null
          performance_bond_required?: boolean | null
          project_id?: string
          retention_percentage?: number | null
          start_date?: string
          status?: Database["public"]["Enums"]["subcontract_status"] | null
          subcontract_number?: string
          updated_at?: string | null
          vendor_id?: string
          work_description?: string
        }
        Relationships: [
          {
            foreignKeyName: "subcontract_orders_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "subcontract_orders_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "subcontract_orders_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "subcontract_orders_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
        ]
      }
      subcontractor_rates: {
        Row: {
          created_at: string | null
          effective_from: string
          effective_to: string | null
          id: string
          is_active: boolean | null
          project_id: string | null
          subcontractor_id: string
          unit_rate: number
          unit_type: string
          work_type: string
        }
        Insert: {
          created_at?: string | null
          effective_from: string
          effective_to?: string | null
          id?: string
          is_active?: boolean | null
          project_id?: string | null
          subcontractor_id: string
          unit_rate: number
          unit_type?: string
          work_type: string
        }
        Update: {
          created_at?: string | null
          effective_from?: string
          effective_to?: string | null
          id?: string
          is_active?: boolean | null
          project_id?: string | null
          subcontractor_id?: string
          unit_rate?: number
          unit_type?: string
          work_type?: string
        }
        Relationships: [
          {
            foreignKeyName: "subcontractor_rates_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "subcontractor_rates_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "subcontractor_rates_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "subcontractor_rates_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
        ]
      }
      subcontractors: {
        Row: {
          created_at: string | null
          id: string
          insurance_expiry: string | null
          insurance_policy: string | null
          license_expiry: string | null
          license_number: string | null
          performance_bond_required: boolean | null
          safety_rating: number | null
          updated_at: string | null
          vendor_id: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          insurance_expiry?: string | null
          insurance_policy?: string | null
          license_expiry?: string | null
          license_number?: string | null
          performance_bond_required?: boolean | null
          safety_rating?: number | null
          updated_at?: string | null
          vendor_id: string
        }
        Update: {
          created_at?: string | null
          id?: string
          insurance_expiry?: string | null
          insurance_policy?: string | null
          license_expiry?: string | null
          license_number?: string | null
          performance_bond_required?: boolean | null
          safety_rating?: number | null
          updated_at?: string | null
          vendor_id?: string
        }
        Relationships: []
      }
      tasks: {
        Row: {
          activity_id: string | null
          assigned_to: string | null
          checklist_item: boolean | null
          completion_date: string | null
          created_at: string | null
          created_by: string | null
          daily_logs: string | null
          description: string | null
          id: string
          material_usage: Json | null
          name: string
          photos: string[] | null
          priority: Database["public"]["Enums"]["task_priority"]
          progress_percentage: number | null
          project_id: string
          qa_notes: string | null
          safety_notes: string | null
          status: Database["public"]["Enums"]["task_status"]
          updated_at: string | null
          wbs_node_id: string | null
        }
        Insert: {
          activity_id?: string | null
          assigned_to?: string | null
          checklist_item?: boolean | null
          completion_date?: string | null
          created_at?: string | null
          created_by?: string | null
          daily_logs?: string | null
          description?: string | null
          id?: string
          material_usage?: Json | null
          name: string
          photos?: string[] | null
          priority?: Database["public"]["Enums"]["task_priority"]
          progress_percentage?: number | null
          project_id: string
          qa_notes?: string | null
          safety_notes?: string | null
          status?: Database["public"]["Enums"]["task_status"]
          updated_at?: string | null
          wbs_node_id?: string | null
        }
        Update: {
          activity_id?: string | null
          assigned_to?: string | null
          checklist_item?: boolean | null
          completion_date?: string | null
          created_at?: string | null
          created_by?: string | null
          daily_logs?: string | null
          description?: string | null
          id?: string
          material_usage?: Json | null
          name?: string
          photos?: string[] | null
          priority?: Database["public"]["Enums"]["task_priority"]
          progress_percentage?: number | null
          project_id?: string
          qa_notes?: string | null
          safety_notes?: string | null
          status?: Database["public"]["Enums"]["task_status"]
          updated_at?: string | null
          wbs_node_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "tasks_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "tasks_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activity_variance"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "tasks_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "mv_activities_resource_status"
            referencedColumns: ["activity_id"]
          },
          {
            foreignKeyName: "tasks_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "tasks_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "tasks_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "tasks_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "tasks_wbs_node_id_fkey"
            columns: ["wbs_node_id"]
            isOneToOne: false
            referencedRelation: "wbs_nodes"
            referencedColumns: ["id"]
          },
        ]
      }
      tax_codes: {
        Row: {
          is_active: boolean | null
          tax_code: string
          tax_name: string
          tax_rate: number
        }
        Insert: {
          is_active?: boolean | null
          tax_code: string
          tax_name: string
          tax_rate: number
        }
        Update: {
          is_active?: boolean | null
          tax_code?: string
          tax_name?: string
          tax_rate?: number
        }
        Relationships: []
      }
      tile_workflow_status: {
        Row: {
          context_data: Json | null
          id: string
          last_updated: string | null
          pending_count: number | null
          status: string
          tile_id: string
          user_id: string
        }
        Insert: {
          context_data?: Json | null
          id?: string
          last_updated?: string | null
          pending_count?: number | null
          status?: string
          tile_id: string
          user_id: string
        }
        Update: {
          context_data?: Json | null
          id?: string
          last_updated?: string | null
          pending_count?: number | null
          status?: string
          tile_id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "tile_workflow_status_tile_id_fkey"
            columns: ["tile_id"]
            isOneToOne: false
            referencedRelation: "tiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "tile_workflow_status_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      tiles: {
        Row: {
          auth_object: string | null
          color: string | null
          construction_action: string | null
          created_at: string | null
          icon: string
          id: string
          is_active: boolean | null
          module_code: string | null
          roles: string[]
          route: string
          sequence_order: number | null
          subtitle: string | null
          tile_category: string | null
          title: string
          updated_at: string | null
        }
        Insert: {
          auth_object?: string | null
          color?: string | null
          construction_action?: string | null
          created_at?: string | null
          icon: string
          id?: string
          is_active?: boolean | null
          module_code?: string | null
          roles?: string[]
          route: string
          sequence_order?: number | null
          subtitle?: string | null
          tile_category?: string | null
          title: string
          updated_at?: string | null
        }
        Update: {
          auth_object?: string | null
          color?: string | null
          construction_action?: string | null
          created_at?: string | null
          icon?: string
          id?: string
          is_active?: boolean | null
          module_code?: string | null
          roles?: string[]
          route?: string
          sequence_order?: number | null
          subtitle?: string | null
          tile_category?: string | null
          title?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      timesheet_cost_allocations: {
        Row: {
          allocation_date: string
          allocation_method: string | null
          cost_object_id: string
          cost_type: string | null
          created_at: string | null
          created_by: string | null
          id: string
          labor_cost: number
          labor_hours: number
          timesheet_line_id: string
        }
        Insert: {
          allocation_date: string
          allocation_method?: string | null
          cost_object_id: string
          cost_type?: string | null
          created_at?: string | null
          created_by?: string | null
          id?: string
          labor_cost: number
          labor_hours: number
          timesheet_line_id: string
        }
        Update: {
          allocation_date?: string
          allocation_method?: string | null
          cost_object_id?: string
          cost_type?: string | null
          created_at?: string | null
          created_by?: string | null
          id?: string
          labor_cost?: number
          labor_hours?: number
          timesheet_line_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "timesheet_cost_allocations_cost_object_id_fkey"
            columns: ["cost_object_id"]
            isOneToOne: false
            referencedRelation: "cost_objects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "timesheet_cost_allocations_timesheet_line_id_fkey"
            columns: ["timesheet_line_id"]
            isOneToOne: false
            referencedRelation: "timesheet_lines"
            referencedColumns: ["id"]
          },
        ]
      }
      timesheet_lines: {
        Row: {
          activity_id: string | null
          break_minutes: number | null
          cost_object_id: string | null
          created_at: string | null
          end_time: string | null
          equipment_used: string | null
          hourly_rate: number
          id: string
          line_cost: number | null
          materials_used: string | null
          overtime_hours: number | null
          regular_hours: number
          remarks: string | null
          start_time: string | null
          task_id: string | null
          timesheet_id: string
          weather_conditions: string | null
          work_description: string
          work_location: string | null
        }
        Insert: {
          activity_id?: string | null
          break_minutes?: number | null
          cost_object_id?: string | null
          created_at?: string | null
          end_time?: string | null
          equipment_used?: string | null
          hourly_rate: number
          id?: string
          line_cost?: number | null
          materials_used?: string | null
          overtime_hours?: number | null
          regular_hours?: number
          remarks?: string | null
          start_time?: string | null
          task_id?: string | null
          timesheet_id: string
          weather_conditions?: string | null
          work_description: string
          work_location?: string | null
        }
        Update: {
          activity_id?: string | null
          break_minutes?: number | null
          cost_object_id?: string | null
          created_at?: string | null
          end_time?: string | null
          equipment_used?: string | null
          hourly_rate?: number
          id?: string
          line_cost?: number | null
          materials_used?: string | null
          overtime_hours?: number | null
          regular_hours?: number
          remarks?: string | null
          start_time?: string | null
          task_id?: string | null
          timesheet_id?: string
          weather_conditions?: string | null
          work_description?: string
          work_location?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "timesheet_lines_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "timesheet_lines_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activity_variance"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "timesheet_lines_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "mv_activities_resource_status"
            referencedColumns: ["activity_id"]
          },
          {
            foreignKeyName: "timesheet_lines_cost_object_id_fkey"
            columns: ["cost_object_id"]
            isOneToOne: false
            referencedRelation: "cost_objects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "timesheet_lines_task_id_fkey"
            columns: ["task_id"]
            isOneToOne: false
            referencedRelation: "tasks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "timesheet_lines_timesheet_id_fkey"
            columns: ["timesheet_id"]
            isOneToOne: false
            referencedRelation: "daily_timesheets"
            referencedColumns: ["id"]
          },
        ]
      }
      transaction_keys: {
        Row: {
          description: string
          transaction_key: string
          transaction_type: string
        }
        Insert: {
          description: string
          transaction_key: string
          transaction_type: string
        }
        Update: {
          description?: string
          transaction_key?: string
          transaction_type?: string
        }
        Relationships: []
      }
      universal_journal: {
        Row: {
          asset_number: string | null
          company_amount: number
          company_code: string
          company_currency: string
          contract_number: string | null
          cost_center: string | null
          created_at: string | null
          created_by: string | null
          customer_code: string | null
          debit_credit: string
          document_date: string
          employee_id: string | null
          event_id: string
          event_timestamp: string
          event_type: string
          fiscal_year: number
          fx_rate_source: string | null
          fx_rate_timestamp: string | null
          fx_rate_transaction_to_company: number | null
          fx_rate_transaction_to_group: number | null
          gl_account: string
          group_amount: number | null
          group_currency: string | null
          id: string
          is_reversal: boolean | null
          ledger: string
          maintenance_order: string | null
          material_number: string | null
          period: number
          posting_date: string
          posting_key: string
          production_order: string | null
          profit_center: string | null
          project_code: string | null
          real_estate_object: string | null
          reversal_of_event_id: string | null
          reversal_reason: string | null
          source_document_id: string | null
          source_document_type: string | null
          source_system: string
          supplier_code: string | null
          tax_code: string | null
          transaction_amount: number
          transaction_currency: string
          treasury_instrument: string | null
          wbs_element: string | null
        }
        Insert: {
          asset_number?: string | null
          company_amount: number
          company_code: string
          company_currency: string
          contract_number?: string | null
          cost_center?: string | null
          created_at?: string | null
          created_by?: string | null
          customer_code?: string | null
          debit_credit: string
          document_date: string
          employee_id?: string | null
          event_id: string
          event_timestamp: string
          event_type: string
          fiscal_year: number
          fx_rate_source?: string | null
          fx_rate_timestamp?: string | null
          fx_rate_transaction_to_company?: number | null
          fx_rate_transaction_to_group?: number | null
          gl_account: string
          group_amount?: number | null
          group_currency?: string | null
          id?: string
          is_reversal?: boolean | null
          ledger: string
          maintenance_order?: string | null
          material_number?: string | null
          period: number
          posting_date: string
          posting_key: string
          production_order?: string | null
          profit_center?: string | null
          project_code?: string | null
          real_estate_object?: string | null
          reversal_of_event_id?: string | null
          reversal_reason?: string | null
          source_document_id?: string | null
          source_document_type?: string | null
          source_system: string
          supplier_code?: string | null
          tax_code?: string | null
          transaction_amount: number
          transaction_currency: string
          treasury_instrument?: string | null
          wbs_element?: string | null
        }
        Update: {
          asset_number?: string | null
          company_amount?: number
          company_code?: string
          company_currency?: string
          contract_number?: string | null
          cost_center?: string | null
          created_at?: string | null
          created_by?: string | null
          customer_code?: string | null
          debit_credit?: string
          document_date?: string
          employee_id?: string | null
          event_id?: string
          event_timestamp?: string
          event_type?: string
          fiscal_year?: number
          fx_rate_source?: string | null
          fx_rate_timestamp?: string | null
          fx_rate_transaction_to_company?: number | null
          fx_rate_transaction_to_group?: number | null
          gl_account?: string
          group_amount?: number | null
          group_currency?: string | null
          id?: string
          is_reversal?: boolean | null
          ledger?: string
          maintenance_order?: string | null
          material_number?: string | null
          period?: number
          posting_date?: string
          posting_key?: string
          production_order?: string | null
          profit_center?: string | null
          project_code?: string | null
          real_estate_object?: string | null
          reversal_of_event_id?: string | null
          reversal_reason?: string | null
          source_document_id?: string | null
          source_document_type?: string | null
          source_system?: string
          supplier_code?: string | null
          tax_code?: string | null
          transaction_amount?: number
          transaction_currency?: string
          treasury_instrument?: string | null
          wbs_element?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_company_code"
            columns: ["company_code"]
            isOneToOne: false
            referencedRelation: "company_codes"
            referencedColumns: ["company_code"]
          },
          {
            foreignKeyName: "fk_company_code"
            columns: ["company_code"]
            isOneToOne: false
            referencedRelation: "v_companies_with_names"
            referencedColumns: ["code"]
          },
        ]
      }
      uom_groups: {
        Row: {
          base_uom: string
          created_at: string | null
          dimension: string | null
          id: string
          is_active: boolean | null
          uom_name: string
        }
        Insert: {
          base_uom: string
          created_at?: string | null
          dimension?: string | null
          id?: string
          is_active?: boolean | null
          uom_name: string
        }
        Update: {
          base_uom?: string
          created_at?: string | null
          dimension?: string | null
          id?: string
          is_active?: boolean | null
          uom_name?: string
        }
        Relationships: []
      }
      user_authorizations: {
        Row: {
          auth_object_id: string
          created_at: string | null
          field_values: Json
          id: string
          user_id: string
          valid_from: string | null
          valid_to: string | null
        }
        Insert: {
          auth_object_id: string
          created_at?: string | null
          field_values: Json
          id?: string
          user_id: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Update: {
          auth_object_id?: string
          created_at?: string | null
          field_values?: Json
          id?: string
          user_id?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "user_authorizations_auth_object_id_fkey"
            columns: ["auth_object_id"]
            isOneToOne: false
            referencedRelation: "authorization_objects"
            referencedColumns: ["id"]
          },
        ]
      }
      user_project_access: {
        Row: {
          access_level: string
          assigned_date: string | null
          id: string
          is_active: boolean | null
          project_id: string
          user_id: string
        }
        Insert: {
          access_level?: string
          assigned_date?: string | null
          id?: string
          is_active?: boolean | null
          project_id: string
          user_id: string
        }
        Update: {
          access_level?: string
          assigned_date?: string | null
          id?: string
          is_active?: boolean | null
          project_id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_project_access_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "user_project_access_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "user_project_access_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "user_project_access_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_project_access_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      user_roles: {
        Row: {
          created_at: string | null
          id: string
          is_active: boolean | null
          role_id: string
          user_id: string
          valid_from: string | null
          valid_to: string | null
        }
        Insert: {
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          role_id: string
          user_id: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Update: {
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          role_id?: string
          user_id?: string
          valid_from?: string | null
          valid_to?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "user_roles_role_id_fkey"
            columns: ["role_id"]
            isOneToOne: false
            referencedRelation: "roles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_roles_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      users: {
        Row: {
          created_at: string | null
          department: string | null
          email: string
          employee_code: string | null
          first_name: string | null
          id: string
          is_active: boolean | null
          last_name: string | null
          role_id: string | null
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          department?: string | null
          email: string
          employee_code?: string | null
          first_name?: string | null
          id: string
          is_active?: boolean | null
          last_name?: string | null
          role_id?: string | null
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          department?: string | null
          email?: string
          employee_code?: string | null
          first_name?: string | null
          id?: string
          is_active?: boolean | null
          last_name?: string | null
          role_id?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "users_role_id_fkey"
            columns: ["role_id"]
            isOneToOne: false
            referencedRelation: "roles"
            referencedColumns: ["id"]
          },
        ]
      }
      valuation_classes: {
        Row: {
          class_code: string
          class_name: string
          created_at: string | null
          description: string | null
          id: string
          is_active: boolean | null
        }
        Insert: {
          class_code: string
          class_name: string
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
        }
        Update: {
          class_code?: string
          class_name?: string
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
        }
        Relationships: []
      }
      vendor_categories: {
        Row: {
          category_code: string
          category_name: string
          created_at: string | null
          description: string | null
          id: string
          is_active: boolean | null
        }
        Insert: {
          category_code: string
          category_name: string
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
        }
        Update: {
          category_code?: string
          category_name?: string
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
        }
        Relationships: []
      }
      vendor_quotations: {
        Row: {
          created_at: string | null
          delivery_days: number | null
          id: string
          is_selected: boolean | null
          pr_line_id: string
          quotation_number: string | null
          quoted_price: number
          terms_conditions: string | null
          validity_date: string | null
          vendor_id: string
        }
        Insert: {
          created_at?: string | null
          delivery_days?: number | null
          id?: string
          is_selected?: boolean | null
          pr_line_id: string
          quotation_number?: string | null
          quoted_price: number
          terms_conditions?: string | null
          validity_date?: string | null
          vendor_id: string
        }
        Update: {
          created_at?: string | null
          delivery_days?: number | null
          id?: string
          is_selected?: boolean | null
          pr_line_id?: string
          quotation_number?: string | null
          quoted_price?: number
          terms_conditions?: string | null
          validity_date?: string | null
          vendor_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "vendor_quotations_pr_line_id_fkey"
            columns: ["pr_line_id"]
            isOneToOne: false
            referencedRelation: "pr_lines"
            referencedColumns: ["id"]
          },
        ]
      }
      vendors: {
        Row: {
          address: string | null
          contact_person: string | null
          created_at: string | null
          email: string | null
          id: string
          is_active: boolean | null
          payment_terms_id: string | null
          phone: string | null
          vendor_category_id: string | null
          vendor_code: string
          vendor_name: string
        }
        Insert: {
          address?: string | null
          contact_person?: string | null
          created_at?: string | null
          email?: string | null
          id?: string
          is_active?: boolean | null
          payment_terms_id?: string | null
          phone?: string | null
          vendor_category_id?: string | null
          vendor_code: string
          vendor_name: string
        }
        Update: {
          address?: string | null
          contact_person?: string | null
          created_at?: string | null
          email?: string | null
          id?: string
          is_active?: boolean | null
          payment_terms_id?: string | null
          phone?: string | null
          vendor_category_id?: string | null
          vendor_code?: string
          vendor_name?: string
        }
        Relationships: [
          {
            foreignKeyName: "vendors_payment_terms_id_fkey"
            columns: ["payment_terms_id"]
            isOneToOne: false
            referencedRelation: "payment_terms"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "vendors_vendor_category_id_fkey"
            columns: ["vendor_category_id"]
            isOneToOne: false
            referencedRelation: "vendor_categories"
            referencedColumns: ["id"]
          },
        ]
      }
      wbs_elements: {
        Row: {
          company_code: string
          created_at: string | null
          id: string
          is_active: boolean | null
          parent_wbs: string | null
          profit_center_code: string | null
          project_code: string
          project_end_date: string | null
          project_manager: string | null
          project_start_date: string | null
          updated_at: string | null
          wbs_description: string
          wbs_element: string
          wbs_level: number | null
        }
        Insert: {
          company_code: string
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          parent_wbs?: string | null
          profit_center_code?: string | null
          project_code: string
          project_end_date?: string | null
          project_manager?: string | null
          project_start_date?: string | null
          updated_at?: string | null
          wbs_description: string
          wbs_element: string
          wbs_level?: number | null
        }
        Update: {
          company_code?: string
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          parent_wbs?: string | null
          profit_center_code?: string | null
          project_code?: string
          project_end_date?: string | null
          project_manager?: string | null
          project_start_date?: string | null
          updated_at?: string | null
          wbs_description?: string
          wbs_element?: string
          wbs_level?: number | null
        }
        Relationships: []
      }
      wbs_nodes: {
        Row: {
          budget_allocation: number | null
          code: string
          created_at: string | null
          description: string | null
          end_date: string | null
          id: string
          is_active: boolean | null
          level: number
          name: string
          node_type: Database["public"]["Enums"]["wbs_node_type"]
          parent_id: string | null
          planned_hours: number | null
          project_id: string
          responsible_user_id: string | null
          sequence_order: number
          start_date: string | null
          updated_at: string | null
          wbs_direct_cost_total: number | null
          wbs_indirect_cost_allocated: number | null
          wbs_total_cost: number | null
        }
        Insert: {
          budget_allocation?: number | null
          code: string
          created_at?: string | null
          description?: string | null
          end_date?: string | null
          id?: string
          is_active?: boolean | null
          level: number
          name: string
          node_type: Database["public"]["Enums"]["wbs_node_type"]
          parent_id?: string | null
          planned_hours?: number | null
          project_id: string
          responsible_user_id?: string | null
          sequence_order: number
          start_date?: string | null
          updated_at?: string | null
          wbs_direct_cost_total?: number | null
          wbs_indirect_cost_allocated?: number | null
          wbs_total_cost?: number | null
        }
        Update: {
          budget_allocation?: number | null
          code?: string
          created_at?: string | null
          description?: string | null
          end_date?: string | null
          id?: string
          is_active?: boolean | null
          level?: number
          name?: string
          node_type?: Database["public"]["Enums"]["wbs_node_type"]
          parent_id?: string | null
          planned_hours?: number | null
          project_id?: string
          responsible_user_id?: string | null
          sequence_order?: number
          start_date?: string | null
          updated_at?: string | null
          wbs_direct_cost_total?: number | null
          wbs_indirect_cost_allocated?: number | null
          wbs_total_cost?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "wbs_nodes_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "wbs_nodes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "wbs_nodes_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "wbs_nodes_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "wbs_nodes_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "wbs_nodes_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
        ]
      }
      workflow_definitions: {
        Row: {
          created_at: string | null
          description: string | null
          id: string
          is_active: boolean | null
          object_type: string
          workflow_code: string
          workflow_name: string
        }
        Insert: {
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
          object_type: string
          workflow_code: string
          workflow_name: string
        }
        Update: {
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
          object_type?: string
          workflow_code?: string
          workflow_name?: string
        }
        Relationships: []
      }
      workflow_instances: {
        Row: {
          completed_at: string | null
          context_data: Json | null
          created_at: string | null
          current_step_sequence: number | null
          id: string
          object_id: string
          object_type: string
          requester_id: string
          status: string | null
          workflow_id: string
        }
        Insert: {
          completed_at?: string | null
          context_data?: Json | null
          created_at?: string | null
          current_step_sequence?: number | null
          id?: string
          object_id: string
          object_type: string
          requester_id: string
          status?: string | null
          workflow_id: string
        }
        Update: {
          completed_at?: string | null
          context_data?: Json | null
          created_at?: string | null
          current_step_sequence?: number | null
          id?: string
          object_id?: string
          object_type?: string
          requester_id?: string
          status?: string | null
          workflow_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "workflow_instances_workflow_id_fkey"
            columns: ["workflow_id"]
            isOneToOne: false
            referencedRelation: "workflow_definitions"
            referencedColumns: ["id"]
          },
        ]
      }
      workflow_start_conditions: {
        Row: {
          condition_operator: string
          condition_type: string
          condition_value: Json
          id: string
          is_active: boolean | null
          priority: number | null
          workflow_id: string
        }
        Insert: {
          condition_operator: string
          condition_type: string
          condition_value: Json
          id?: string
          is_active?: boolean | null
          priority?: number | null
          workflow_id: string
        }
        Update: {
          condition_operator?: string
          condition_type?: string
          condition_value?: Json
          id?: string
          is_active?: boolean | null
          priority?: number | null
          workflow_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "workflow_start_conditions_workflow_id_fkey"
            columns: ["workflow_id"]
            isOneToOne: false
            referencedRelation: "workflow_definitions"
            referencedColumns: ["id"]
          },
        ]
      }
      workflow_steps: {
        Row: {
          activation_condition: Json | null
          agent_rule: string
          completion_rule: string | null
          id: string
          is_active: boolean | null
          min_approvals: number | null
          step_code: string
          step_name: string
          step_sequence: number
          step_type: string
          timeout_hours: number | null
          workflow_id: string
        }
        Insert: {
          activation_condition?: Json | null
          agent_rule: string
          completion_rule?: string | null
          id?: string
          is_active?: boolean | null
          min_approvals?: number | null
          step_code: string
          step_name: string
          step_sequence: number
          step_type: string
          timeout_hours?: number | null
          workflow_id: string
        }
        Update: {
          activation_condition?: Json | null
          agent_rule?: string
          completion_rule?: string | null
          id?: string
          is_active?: boolean | null
          min_approvals?: number | null
          step_code?: string
          step_name?: string
          step_sequence?: number
          step_type?: string
          timeout_hours?: number | null
          workflow_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "workflow_steps_workflow_id_fkey"
            columns: ["workflow_id"]
            isOneToOne: false
            referencedRelation: "workflow_definitions"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      activity_variance: {
        Row: {
          code: string | null
          duration_variance_days: number | null
          end_date_variance_days: number | null
          id: string | null
          name: string | null
          schedule_status: string | null
          start_date_variance_days: number | null
        }
        Insert: {
          code?: string | null
          duration_variance_days?: never
          end_date_variance_days?: never
          id?: string | null
          name?: string | null
          schedule_status?: never
          start_date_variance_days?: never
        }
        Update: {
          code?: string | null
          duration_variance_days?: never
          end_date_variance_days?: never
          id?: string | null
          name?: string | null
          schedule_status?: never
          start_date_variance_days?: never
        }
        Relationships: []
      }
      authorization_monitoring: {
        Row: {
          auth_object_name: string | null
          denied_access: number | null
          hour: string | null
          successful_access: number | null
          total_attempts: number | null
          unique_users: number | null
        }
        Relationships: []
      }
      ctc_calculations: {
        Row: {
          avg_progress: number | null
          calculation_date: string | null
          forecast_at_completion: number | null
          project_id: string | null
          project_name: string | null
          total_actual_cost: number | null
          total_budget: number | null
          total_budget_cost: number | null
          total_committed: number | null
          total_ctc: number | null
        }
        Relationships: []
      }
      data_integrity_monitor: {
        Row: {
          details: string | null
          issue_count: number | null
          issue_type: string | null
          table_name: string | null
        }
        Relationships: []
      }
      document_reversal_status: {
        Row: {
          document_number: string | null
          document_type: string | null
          is_reversed: boolean | null
          posting_date: string | null
          reversal_date: string | null
          reversal_document: string | null
          reversal_reason: string | null
          status: string | null
          total_amount: number | null
        }
        Insert: {
          document_number?: string | null
          document_type?: string | null
          is_reversed?: boolean | null
          posting_date?: string | null
          reversal_date?: string | null
          reversal_document?: string | null
          reversal_reason?: string | null
          status?: never
          total_amount?: number | null
        }
        Update: {
          document_number?: string | null
          document_type?: string | null
          is_reversed?: boolean | null
          posting_date?: string | null
          reversal_date?: string | null
          reversal_document?: string | null
          reversal_reason?: string | null
          status?: never
          total_amount?: number | null
        }
        Relationships: []
      }
      evm_calculations: {
        Row: {
          actual_cost: number | null
          budget_at_completion: number | null
          cost_performance_index: number | null
          cost_variance: number | null
          earned_value: number | null
          estimate_at_completion: number | null
          estimate_to_complete: number | null
          percent_complete: number | null
          percent_spent: number | null
          planned_value: number | null
          project_id: string | null
          project_name: string | null
          schedule_performance_index: number | null
          schedule_variance: number | null
          status_date: string | null
          total_budget: number | null
        }
        Relationships: []
      }
      global_materials: {
        Row: {
          category: string | null
          created_at: string | null
          description: string | null
          id: string | null
          is_active: boolean | null
          item_code: string | null
          maximum_level: number | null
          minimum_level: number | null
          project_id: string | null
          reorder_level: number | null
          unit: string | null
          updated_at: string | null
        }
        Insert: {
          category?: string | null
          created_at?: string | null
          description?: string | null
          id?: string | null
          is_active?: boolean | null
          item_code?: string | null
          maximum_level?: number | null
          minimum_level?: number | null
          project_id?: string | null
          reorder_level?: number | null
          unit?: string | null
          updated_at?: string | null
        }
        Update: {
          category?: string | null
          created_at?: string | null
          description?: string | null
          id?: string | null
          is_active?: boolean | null
          item_code?: string | null
          maximum_level?: number | null
          minimum_level?: number | null
          project_id?: string | null
          reorder_level?: number | null
          unit?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "stock_items_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "stock_items_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "stock_items_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "stock_items_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
        ]
      }
      margin_analysis: {
        Row: {
          actual_cost: number | null
          actual_margin: number | null
          actual_margin_percent: number | null
          analysis_date: string | null
          contract_value: number | null
          earned_revenue: number | null
          estimated_margin: number | null
          estimated_margin_percent: number | null
          forecast_cost: number | null
          planned_cost: number | null
          planned_margin: number | null
          planned_margin_percent: number | null
          project_id: string | null
          project_name: string | null
          projected_margin: number | null
          projected_margin_percent: number | null
          total_billed: number | null
          unbilled_revenue: number | null
        }
        Relationships: []
      }
      material_master_view: {
        Row: {
          base_uom: string | null
          category: string | null
          category_name: string | null
          created_at: string | null
          description: string | null
          group_name: string | null
          is_active: boolean | null
          material_code: string | null
          material_group: string | null
          material_name: string | null
          material_type: string | null
          plant_count: number | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_materials_category"
            columns: ["category"]
            isOneToOne: false
            referencedRelation: "material_categories"
            referencedColumns: ["category_code"]
          },
          {
            foreignKeyName: "fk_materials_group"
            columns: ["material_group"]
            isOneToOne: false
            referencedRelation: "material_groups"
            referencedColumns: ["group_code"]
          },
        ]
      }
      mv_activities_resource_status: {
        Row: {
          activity_id: string | null
          code: string | null
          equipment_count: number | null
          has_equipment: boolean | null
          has_manpower: boolean | null
          has_materials: boolean | null
          has_services: boolean | null
          has_subcontractors: boolean | null
          manpower_count: number | null
          material_count: number | null
          name: string | null
          planned_end_date: string | null
          planned_start_date: string | null
          priority: string | null
          project_id: string | null
          resource_status: string | null
          services_count: number | null
          status: string | null
          subcontractor_count: number | null
          time_priority: string | null
          wbs_node_id: string | null
        }
        Relationships: [
          {
            foreignKeyName: "activities_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "activities_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "activities_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "activities_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activities_wbs_node_id_fkey"
            columns: ["wbs_node_id"]
            isOneToOne: false
            referencedRelation: "wbs_nodes"
            referencedColumns: ["id"]
          },
        ]
      }
      mv_approval_field_cache: {
        Row: {
          approval_field_options: Json | null
          customer_id: string | null
          display_order: number | null
          field_category: string | null
          field_label: string | null
          field_name: string | null
          field_type: string | null
          id: string | null
        }
        Relationships: []
      }
      project_line_items: {
        Row: {
          amount: number | null
          cost_element_code: string | null
          document_number: string | null
          id: string | null
          posting_date: string | null
          project_code: string | null
          wbs_element: string | null
        }
        Relationships: []
      }
      project_materials: {
        Row: {
          category: string | null
          created_at: string | null
          description: string | null
          id: string | null
          is_active: boolean | null
          item_code: string | null
          maximum_level: number | null
          minimum_level: number | null
          project_id: string | null
          reorder_level: number | null
          unit: string | null
          updated_at: string | null
        }
        Insert: {
          category?: string | null
          created_at?: string | null
          description?: string | null
          id?: string | null
          is_active?: boolean | null
          item_code?: string | null
          maximum_level?: number | null
          minimum_level?: number | null
          project_id?: string | null
          reorder_level?: number | null
          unit?: string | null
          updated_at?: string | null
        }
        Update: {
          category?: string | null
          created_at?: string | null
          description?: string | null
          id?: string | null
          is_active?: boolean | null
          item_code?: string | null
          maximum_level?: number | null
          minimum_level?: number | null
          project_id?: string | null
          reorder_level?: number | null
          unit?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "stock_items_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "ctc_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "stock_items_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "evm_calculations"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "stock_items_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "margin_analysis"
            referencedColumns: ["project_id"]
          },
          {
            foreignKeyName: "stock_items_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
        ]
      }
      project_stock_overview: {
        Row: {
          account_assignment: string | null
          available_stock: number | null
          cost_center: string | null
          current_stock: number | null
          id: string | null
          project_code: string | null
          project_name: string | null
          stock_type: string | null
          stock_value: number | null
          wbs_description: string | null
          wbs_element: string | null
          wbs_name: string | null
        }
        Relationships: []
      }
      v_approval_performance_stats: {
        Row: {
          active_rows: number | null
          avg_specificity: number | null
          customers: number | null
          object_types: number | null
          table_name: string | null
          total_rows: number | null
        }
        Relationships: []
      }
      v_companies_with_names: {
        Row: {
          code: string | null
          country: string | null
          currency: string | null
          employee_count: number | null
          is_active: boolean | null
          legal_entity_name: string | null
          name: string | null
        }
        Relationships: []
      }
    }
    Functions: {
      allocate_indirect_costs: {
        Args: { p_project_id: string }
        Returns: undefined
      }
      analyze_resource_planning_performance: {
        Args: never
        Returns: {
          metric: string
          value: string
        }[]
      }
      apply_approval_template: {
        Args: {
          p_config_name: string
          p_customer_id: string
          p_document_type: string
          p_template_id: string
        }
        Returns: string
      }
      assign_all_objects_to_role: {
        Args: { target_role_id: string; template_type?: string }
        Returns: number
      }
      assign_cascading_authorization: {
        Args: {
          access_level?: string
          cascade_level?: string
          target_module?: string
          target_object_id?: string
          target_role_id: string
        }
        Returns: number
      }
      assign_role_authorizations: {
        Args: { p_role_name: string; p_user_id: string }
        Returns: undefined
      }
      calculate_ctc_with_burn_rate: {
        Args: { p_analysis_period_days?: number; p_project_id: string }
        Returns: {
          burn_rate_ctc: number
          confidence_level: string
          current_ctc: number
          project_id: string
          recommended_ctc: number
          trend_ctc: number
        }[]
      }
      calculate_project_ctc: {
        Args: { p_project_id: string }
        Returns: {
          budget_variance: number
          calculation_date: string
          forecast_at_completion: number
          progress_percentage: number
          project_id: string
          project_name: string
          total_actual: number
          total_budget: number
          total_committed: number
          total_ctc: number
        }[]
      }
      calculate_task_ctc: {
        Args: { p_task_id: string }
        Returns: {
          actual_amount: number
          budget_amount: number
          ctc_amount: number
          progress_percentage: number
          remaining_work: number
          task_id: string
          task_name: string
        }[]
      }
      calculate_usage_percentage: {
        Args: {
          p_current_number: number
          p_from_number: number
          p_to_number: number
        }
        Returns: number
      }
      can_reverse_document: { Args: { p_doc_number: string }; Returns: Json }
      check_circular_dependency: {
        Args: { p_activity_id: string; p_predecessor_id: string }
        Returns: boolean
      }
      check_construction_authorization:
        | {
            Args: {
              p_action: string
              p_auth_object: string
              p_context?: Json
              p_user_id: string
            }
            Returns: boolean
          }
        | {
            Args: { p_auth_object_name: string; p_user_id: string }
            Returns: boolean
          }
      check_construction_authorization_with_audit: {
        Args: {
          p_auth_object_name: string
          p_ip_address?: unknown
          p_session_id?: string
          p_user_agent?: string
          p_user_id: string
        }
        Returns: boolean
      }
      check_construction_authorization_with_context: {
        Args: {
          p_auth_object_name: string
          p_project_id?: string
          p_user_id: string
        }
        Returns: boolean
      }
      check_user_multi_role_authorization: {
        Args: { auth_object: string; check_fields: Json; input_user_id: string }
        Returns: boolean
      }
      cleanup_test_data: { Args: never; Returns: string }
      consume_reserved_project_number: {
        Args: { p_reserved_code: string; p_session_id: string }
        Returns: boolean
      }
      copy_project_master_data: {
        Args: { source_company_code: string; target_company_code: string }
        Returns: string
      }
      count_activities_needing_resources: {
        Args: {
          p_date_from?: string
          p_date_to?: string
          p_project_id?: string
        }
        Returns: number
      }
      create_stock_movement_with_fifo: {
        Args: {
          p_created_by: string
          p_movement_date: string
          p_movement_type: Database["public"]["Enums"]["movement_type"]
          p_notes?: string
          p_quantity: number
          p_reference_id: string
          p_reference_number: string
          p_reference_type: string
          p_stock_item_id: string
          p_store_id: string
          p_unit_cost: number
        }
        Returns: string
      }
      enforce_capital_goods_itc: {
        Args: {
          p_company_code: string
          p_material_code: string
          p_purchase_document: string
          p_total_tax_amount: number
        }
        Returns: {
          deferred_itc: number
          gl_account: string
          immediate_itc: number
        }[]
      }
      generate_approval_flow: {
        Args: {
          p_approval_object_document_type: string
          p_approval_object_type: string
          p_company_code: string
          p_country_code: string
          p_currency?: string
          p_customer_id: string
          p_department_code: string
          p_document_id: string
          p_document_value?: number
          p_plant_code?: string
          p_project_code?: string
          p_requestor_user_id: string
        }
        Returns: {
          approval_steps: Json
          audit_explanation: Json
          instance_id: string
          pattern: string
          strategy: string
        }[]
      }
      generate_document_number: { Args: { doc_type: string }; Returns: string }
      generate_project_number_with_pattern: {
        Args: {
          p_company_code: string
          p_entity_type: string
          p_pattern: string
        }
        Returns: string
      }
      get_activities_needing_resources: {
        Args: {
          p_date_from?: string
          p_date_to?: string
          p_limit?: number
          p_offset?: number
          p_project_id?: string
        }
        Returns: {
          activity_code: string
          activity_id: string
          activity_name: string
          end_date: string
          material_count: number
          priority: string
          resource_status: string
          start_date: string
          status: string
          time_priority: string
        }[]
      }
      get_approval_path: {
        Args: {
          p_amount: number
          p_customer_id: string
          p_document_type: string
        }
        Returns: {
          approval_type: string
          approver_role: string
          is_required: boolean
          level_name: string
          level_number: number
        }[]
      }
      get_approval_policies_paginated:
        | {
            Args: {
              p_customer_id: string
              p_document_type?: string
              p_limit?: number
              p_object_type?: string
              p_offset?: number
            }
            Returns: {
              approval_object_document_type: string
              approval_object_type: string
              approval_strategy: string
              context_specificity: number
              created_at: string
              id: string
              is_active: boolean
              object_category: string
              policy_name: string
              selected_countries: Json
              selected_departments: Json
              selected_plants: Json
              selected_projects: Json
              selected_purchase_orgs: Json
              selected_storage_locations: Json
            }[]
          }
        | {
            Args: {
              p_customer_id: string
              p_limit?: number
              p_object_type?: string
              p_offset?: number
            }
            Returns: {
              approval_object_document_type: string
              approval_object_type: string
              approval_strategy: string
              context_specificity: number
              created_at: string
              id: string
              is_active: boolean
              object_category: string
              policy_name: string
              selected_countries: Json
              selected_departments: Json
              selected_plants: Json
              selected_projects: Json
              selected_purchase_orgs: Json
              selected_storage_locations: Json
            }[]
          }
      get_evm_trend: {
        Args: {
          p_end_date?: string
          p_project_id: string
          p_start_date?: string
        }
        Returns: {
          actual_cost: number
          earned_value: number
          planned_value: number
          trend_date: string
        }[]
      }
      get_gl_account_for_posting: {
        Args: {
          p_company_code: string
          p_event_type: string
          p_gl_account_type: string
          p_project_category: string
        }
        Returns: string
      }
      get_matching_policies: {
        Args: {
          p_country?: string
          p_customer_id: string
          p_department?: string
          p_document_type?: string
          p_object_type: string
          p_plant?: string
        }
        Returns: {
          context_specificity: number
          match_score: number
          policy_id: string
          policy_name: string
        }[]
      }
      get_material_info: {
        Args: { p_material_code: string }
        Returns: {
          base_unit: string
          description: string
          standard_price: number
        }[]
      }
      get_next_number: {
        Args: {
          p_company_code: string
          p_document_type: string
          p_fiscal_year?: string
        }
        Returns: string
      }
      get_number_range_statistics: {
        Args: { p_company_code?: string }
        Returns: {
          company_code: string
          days_since_last_use: number
          document_type: string
          estimated_days_remaining: number
          numbers_used: number
          status: string
          total_capacity: number
          usage_percentage: number
        }[]
      }
      get_profit_loss: {
        Args: {
          p_company_code: string
          p_from_date?: string
          p_to_date?: string
        }
        Returns: {
          account_name: string
          account_number: string
          amount: number
          section: string
        }[]
      }
      get_project_categories: {
        Args: { p_company_code: string }
        Returns: {
          category_code: string
          category_name: string
          is_active: boolean
          posting_logic: string
        }[]
      }
      get_project_evm: {
        Args: { p_project_id: string }
        Returns: {
          actual_cost: number
          budget_at_completion: number
          cost_performance_index: number
          cost_variance: number
          earned_value: number
          estimate_at_completion: number
          estimate_to_complete: number
          percent_complete: number
          percent_spent: number
          planned_value: number
          project_id: string
          project_name: string
          schedule_performance_index: number
          schedule_variance: number
          status_date: string
          to_complete_performance_index: number
          variance_at_completion: number
        }[]
      }
      get_smart_approval_path: {
        Args: {
          p_amount: number
          p_customer_id: string
          p_department_code?: string
          p_document_type: string
          p_project_code?: string
        }
        Returns: {
          approver_role: string
          level_name: string
          level_number: number
          routing_reason: string
          scope_type: string
        }[]
      }
      get_step_status_counts: {
        Args: { p_workflow_instance_id: string; p_workflow_step_id: string }
        Returns: {
          approved_count: number
          pending_count: number
          rejected_count: number
          total_agents: number
        }[]
      }
      get_task_evm: {
        Args: { p_task_id: string }
        Returns: {
          actual_cost: number
          cost_performance_index: number
          earned_value: number
          planned_value: number
          schedule_performance_index: number
          task_id: string
          task_name: string
        }[]
      }
      get_tax_gl_account: {
        Args: {
          p_company_code: string
          p_country_code: string
          p_input_output: string
          p_tax_type: string
        }
        Returns: string
      }
      get_trial_balance:
        | {
            Args: {
              p_company_code: string
              p_from_date?: string
              p_to_date?: string
            }
            Returns: {
              account_name: string
              account_number: string
              account_type: string
              credit_balance: number
              debit_balance: number
              first_posting_date: string
              last_posting_date: string
              net_balance: number
              transaction_count: number
            }[]
          }
        | {
            Args: {
              p_company_code: string
              p_ledger: string
              p_posting_date: string
            }
            Returns: {
              account_name: string
              account_type: string
              credit_balance: number
              debit_balance: number
              gl_account: string
              net_balance: number
            }[]
          }
      get_user_authorized_tiles: {
        Args: { p_user_id: string }
        Returns: {
          color: string
          construction_action: string
          has_authorization: boolean
          icon: string
          module_code: string
          route: string
          subtitle: string
          tile_category: string
          tile_id: string
          title: string
        }[]
      }
      get_user_authorized_tiles_with_workflow: {
        Args: { p_user_id: string }
        Returns: {
          auth_object: string
          color: string
          construction_action: string
          context_data: Json
          has_authorization: boolean
          icon: string
          module_code: string
          pending_count: number
          route: string
          sequence_order: number
          subtitle: string
          tile_category: string
          tile_id: string
          title: string
          workflow_status: string
        }[]
      }
      get_user_combined_permissions: {
        Args: { input_user_id: string }
        Returns: {
          combined_field_values: Json
          object_name: string
        }[]
      }
      get_user_module_access: {
        Args: { p_user_id: string }
        Returns: {
          actions: string[]
          auth_objects: string[]
          module_code: string
          module_name: string
        }[]
      }
      initiate_po_approval: {
        Args: { p_amount: number; p_created_by: string; p_po_number: string }
        Returns: string
      }
      post_goods_issue: {
        Args: {
          p_cost_center?: string
          p_material_code: string
          p_posting_date?: string
          p_project_code: string
          p_quantity: number
          p_user_id?: string
          p_wbs_element: string
        }
        Returns: Json
      }
      post_goods_receipt: {
        Args: {
          p_material_code: string
          p_po_number: string
          p_posting_date?: string
          p_project_code?: string
          p_quantity: number
          p_unit_price: number
          p_user_id?: string
          p_vendor_id: string
          p_wbs_element?: string
        }
        Returns: Json
      }
      post_labor_cost: {
        Args: {
          p_cost_center?: string
          p_employee_id: string
          p_hourly_rate: number
          p_hours: number
          p_posting_date?: string
          p_project_code: string
          p_user_id?: string
          p_wbs_element: string
        }
        Returns: Json
      }
      preview_project_number_with_pattern: {
        Args: {
          p_company_code: string
          p_entity_type: string
          p_pattern: string
        }
        Returns: string
      }
      process_fifo_issue: {
        Args: {
          p_issue_quantity: number
          p_stock_item_id: string
          p_store_id: string
        }
        Returns: {
          layer_id: string
          quantity_used: number
          total_cost: number
          unit_cost: number
        }[]
      }
      process_po_approval: {
        Args: {
          p_action: string
          p_approver_id: string
          p_comments?: string
          p_po_number: string
        }
        Returns: boolean
      }
      refresh_approval_field_cache: {
        Args: { p_customer_id?: string }
        Returns: undefined
      }
      refresh_resource_status: { Args: never; Returns: undefined }
      release_project_number_reservation: {
        Args: { p_session_id: string }
        Returns: undefined
      }
      remove_module_assignments: {
        Args: { target_module: string; target_role_id: string }
        Returns: number
      }
      reserve_project_number_with_pattern: {
        Args: {
          p_company_code: string
          p_entity_type: string
          p_pattern: string
          p_session_id: string
        }
        Returns: string
      }
      reverse_document: {
        Args: {
          p_original_doc_number: string
          p_reversal_date?: string
          p_reversal_reason: string
          p_user_id?: string
        }
        Returns: Json
      }
      reverse_stock_movements: {
        Args: {
          p_original_doc_id: string
          p_reversal_date: string
          p_reversal_doc_id: string
          p_user_id: string
        }
        Returns: undefined
      }
      run_number_range_alert_check: { Args: never; Returns: undefined }
      test_approval_engine: {
        Args: never
        Returns: {
          result: Json
          test_case: string
        }[]
      }
      update_wbs_direct_costs: {
        Args: { p_project_id: string }
        Returns: undefined
      }
      validate_approval_config: {
        Args: { config_id: string }
        Returns: {
          is_valid: boolean
          validation_errors: string[]
        }[]
      }
      validate_data_integrity: {
        Args: never
        Returns: {
          details: string
          issue_count: number
          issue_type: string
          table_name: string
        }[]
      }
    }
    Enums: {
      activity_type: "INTERNAL" | "EXTERNAL" | "SERVICE"
      cost_status: "planned" | "committed" | "actual" | "accrued"
      cost_type:
        | "labor"
        | "material"
        | "equipment"
        | "subcontractor"
        | "overhead"
        | "other"
      dependency_type:
        | "finish_to_start"
        | "start_to_start"
        | "finish_to_finish"
        | "start_to_finish"
      entry_type: "regular" | "overtime" | "holiday" | "sick_leave" | "vacation"
      indirect_allocation_method:
        | "percentage_of_direct"
        | "duration_based"
        | "area_based"
        | "headcount_based"
        | "fixed_amount"
      movement_type:
        | "receipt"
        | "issue"
        | "return"
        | "transfer"
        | "adjustment"
        | "write_off"
      po_status:
        | "draft"
        | "pending_approval"
        | "approved"
        | "sent"
        | "acknowledged"
        | "partially_received"
        | "fully_received"
        | "cancelled"
      po_type: "standard" | "blanket" | "contract" | "emergency"
      project_status:
        | "planning"
        | "active"
        | "on_hold"
        | "completed"
        | "cancelled"
      project_type:
        | "residential"
        | "commercial"
        | "infrastructure"
        | "industrial"
      quality_status: "pending" | "passed" | "failed" | "conditional"
      receipt_status:
        | "pending"
        | "received"
        | "partially_received"
        | "rejected"
        | "returned"
      requisition_status:
        | "draft"
        | "submitted"
        | "approved"
        | "rejected"
        | "converted_to_po"
      subcontract_status:
        | "draft"
        | "pending_approval"
        | "approved"
        | "active"
        | "completed"
        | "terminated"
      task_priority: "low" | "medium" | "high" | "critical"
      task_status:
        | "not_started"
        | "in_progress"
        | "on_hold"
        | "completed"
        | "cancelled"
      timesheet_status: "draft" | "submitted" | "approved" | "rejected"
      vendor_status: "active" | "inactive" | "blacklisted"
      wbs_node_type: "project" | "phase" | "deliverable" | "work_package"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      activity_type: ["INTERNAL", "EXTERNAL", "SERVICE"],
      cost_status: ["planned", "committed", "actual", "accrued"],
      cost_type: [
        "labor",
        "material",
        "equipment",
        "subcontractor",
        "overhead",
        "other",
      ],
      dependency_type: [
        "finish_to_start",
        "start_to_start",
        "finish_to_finish",
        "start_to_finish",
      ],
      entry_type: ["regular", "overtime", "holiday", "sick_leave", "vacation"],
      indirect_allocation_method: [
        "percentage_of_direct",
        "duration_based",
        "area_based",
        "headcount_based",
        "fixed_amount",
      ],
      movement_type: [
        "receipt",
        "issue",
        "return",
        "transfer",
        "adjustment",
        "write_off",
      ],
      po_status: [
        "draft",
        "pending_approval",
        "approved",
        "sent",
        "acknowledged",
        "partially_received",
        "fully_received",
        "cancelled",
      ],
      po_type: ["standard", "blanket", "contract", "emergency"],
      project_status: [
        "planning",
        "active",
        "on_hold",
        "completed",
        "cancelled",
      ],
      project_type: [
        "residential",
        "commercial",
        "infrastructure",
        "industrial",
      ],
      quality_status: ["pending", "passed", "failed", "conditional"],
      receipt_status: [
        "pending",
        "received",
        "partially_received",
        "rejected",
        "returned",
      ],
      requisition_status: [
        "draft",
        "submitted",
        "approved",
        "rejected",
        "converted_to_po",
      ],
      subcontract_status: [
        "draft",
        "pending_approval",
        "approved",
        "active",
        "completed",
        "terminated",
      ],
      task_priority: ["low", "medium", "high", "critical"],
      task_status: [
        "not_started",
        "in_progress",
        "on_hold",
        "completed",
        "cancelled",
      ],
      timesheet_status: ["draft", "submitted", "approved", "rejected"],
      vendor_status: ["active", "inactive", "blacklisted"],
      wbs_node_type: ["project", "phase", "deliverable", "work_package"],
    },
  },
} as const
