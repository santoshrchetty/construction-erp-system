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
      activities: {
        Row: {
          activity_type: Database["public"]["Enums"]["activity_type"] | null
          actual_end_date: string | null
          actual_start_date: string | null
          assigned_internal_team: string[] | null
          assigned_resources: string[] | null
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
          actual_end_date?: string | null
          actual_start_date?: string | null
          assigned_internal_team?: string[] | null
          assigned_resources?: string[] | null
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
          actual_end_date?: string | null
          actual_start_date?: string | null
          assigned_internal_team?: string[] | null
          assigned_resources?: string[] | null
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
            foreignKeyName: "activity_dependencies_successor_activity_id_fkey"
            columns: ["successor_activity_id"]
            isOneToOne: false
            referencedRelation: "activities"
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
          {
            foreignKeyName: "daily_timesheets_vendor_id_fkey"
            columns: ["vendor_id"]
            isOneToOne: false
            referencedRelation: "vendors"
            referencedColumns: ["id"]
          },
        ]
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
          {
            foreignKeyName: "goods_receipts_vendor_id_fkey"
            columns: ["vendor_id"]
            isOneToOne: false
            referencedRelation: "vendors"
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
          {
            foreignKeyName: "pr_lines_preferred_vendor_id_fkey"
            columns: ["preferred_vendor_id"]
            isOneToOne: false
            referencedRelation: "vendors"
            referencedColumns: ["id"]
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
      projects: {
        Row: {
          actual_end_date: string | null
          budget: number
          client_id: string | null
          code: string
          created_at: string | null
          created_by: string | null
          description: string | null
          holidays: string[] | null
          id: string
          indirect_cost_allocation_method:
            | Database["public"]["Enums"]["indirect_allocation_method"]
            | null
          location: string | null
          name: string
          planned_end_date: string
          project_direct_cost_total: number | null
          project_indirect_cost_actual: number | null
          project_indirect_cost_plan: number | null
          project_manager_id: string | null
          project_type: Database["public"]["Enums"]["project_type"]
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
          client_id?: string | null
          code: string
          created_at?: string | null
          created_by?: string | null
          description?: string | null
          holidays?: string[] | null
          id?: string
          indirect_cost_allocation_method?:
            | Database["public"]["Enums"]["indirect_allocation_method"]
            | null
          location?: string | null
          name: string
          planned_end_date: string
          project_direct_cost_total?: number | null
          project_indirect_cost_actual?: number | null
          project_indirect_cost_plan?: number | null
          project_manager_id?: string | null
          project_type: Database["public"]["Enums"]["project_type"]
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
          client_id?: string | null
          code?: string
          created_at?: string | null
          created_by?: string | null
          description?: string | null
          holidays?: string[] | null
          id?: string
          indirect_cost_allocation_method?:
            | Database["public"]["Enums"]["indirect_allocation_method"]
            | null
          location?: string | null
          name?: string
          planned_end_date?: string
          project_direct_cost_total?: number | null
          project_indirect_cost_actual?: number | null
          project_indirect_cost_plan?: number | null
          project_manager_id?: string | null
          project_type?: Database["public"]["Enums"]["project_type"]
          site_code?: string | null
          site_name?: string | null
          start_date?: string
          status?: Database["public"]["Enums"]["project_status"]
          updated_at?: string | null
          working_days?: number[] | null
        }
        Relationships: []
      }
      purchase_orders: {
        Row: {
          approved_by: string | null
          approved_date: string | null
          created_at: string | null
          created_by: string
          delivery_date: string
          delivery_terms: string | null
          grand_total: number | null
          id: string
          issue_date: string
          notes: string | null
          payment_terms: string | null
          po_number: string
          po_type: Database["public"]["Enums"]["po_type"]
          project_id: string
          status: Database["public"]["Enums"]["po_status"]
          tax_amount: number | null
          total_amount: number
          updated_at: string | null
          vendor_id: string
        }
        Insert: {
          approved_by?: string | null
          approved_date?: string | null
          created_at?: string | null
          created_by: string
          delivery_date: string
          delivery_terms?: string | null
          grand_total?: number | null
          id?: string
          issue_date: string
          notes?: string | null
          payment_terms?: string | null
          po_number: string
          po_type?: Database["public"]["Enums"]["po_type"]
          project_id: string
          status?: Database["public"]["Enums"]["po_status"]
          tax_amount?: number | null
          total_amount: number
          updated_at?: string | null
          vendor_id: string
        }
        Update: {
          approved_by?: string | null
          approved_date?: string | null
          created_at?: string | null
          created_by?: string
          delivery_date?: string
          delivery_terms?: string | null
          grand_total?: number | null
          id?: string
          issue_date?: string
          notes?: string | null
          payment_terms?: string | null
          po_number?: string
          po_type?: Database["public"]["Enums"]["po_type"]
          project_id?: string
          status?: Database["public"]["Enums"]["po_status"]
          tax_amount?: number | null
          total_amount?: number
          updated_at?: string | null
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
            foreignKeyName: "purchase_orders_vendor_id_fkey"
            columns: ["vendor_id"]
            isOneToOne: false
            referencedRelation: "vendors"
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
        ]
      }
      stock_balances: {
        Row: {
          available_quantity: number | null
          average_cost: number | null
          current_quantity: number | null
          id: string
          last_movement_date: string | null
          reserved_quantity: number | null
          stock_item_id: string
          store_id: string
          total_value: number | null
        }
        Insert: {
          available_quantity?: number | null
          average_cost?: number | null
          current_quantity?: number | null
          id?: string
          last_movement_date?: string | null
          reserved_quantity?: number | null
          stock_item_id: string
          store_id: string
          total_value?: number | null
        }
        Update: {
          available_quantity?: number | null
          average_cost?: number | null
          current_quantity?: number | null
          id?: string
          last_movement_date?: string | null
          reserved_quantity?: number | null
          stock_item_id?: string
          store_id?: string
          total_value?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "stock_balances_stock_item_id_fkey"
            columns: ["stock_item_id"]
            isOneToOne: false
            referencedRelation: "stock_items"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "stock_balances_store_id_fkey"
            columns: ["store_id"]
            isOneToOne: false
            referencedRelation: "stores"
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
          maximum_level: number | null
          minimum_level: number | null
          reorder_level: number | null
          unit: string
          updated_at: string | null
        }
        Insert: {
          category?: string | null
          created_at?: string | null
          description: string
          id?: string
          is_active?: boolean | null
          item_code: string
          maximum_level?: number | null
          minimum_level?: number | null
          reorder_level?: number | null
          unit: string
          updated_at?: string | null
        }
        Update: {
          category?: string | null
          created_at?: string | null
          description?: string
          id?: string
          is_active?: boolean | null
          item_code?: string
          maximum_level?: number | null
          minimum_level?: number | null
          reorder_level?: number | null
          unit?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      stock_movements: {
        Row: {
          created_at: string | null
          created_by: string
          id: string
          movement_date: string
          movement_type: Database["public"]["Enums"]["movement_type"]
          notes: string | null
          quantity: number
          reference_id: string | null
          reference_number: string
          reference_type: string
          stock_item_id: string
          store_id: string
          total_cost: number | null
          unit_cost: number
        }
        Insert: {
          created_at?: string | null
          created_by: string
          id?: string
          movement_date: string
          movement_type: Database["public"]["Enums"]["movement_type"]
          notes?: string | null
          quantity: number
          reference_id?: string | null
          reference_number: string
          reference_type: string
          stock_item_id: string
          store_id: string
          total_cost?: number | null
          unit_cost: number
        }
        Update: {
          created_at?: string | null
          created_by?: string
          id?: string
          movement_date?: string
          movement_type?: Database["public"]["Enums"]["movement_type"]
          notes?: string | null
          quantity?: number
          reference_id?: string | null
          reference_number?: string
          reference_type?: string
          stock_item_id?: string
          store_id?: string
          total_cost?: number | null
          unit_cost?: number
        }
        Relationships: [
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
          {
            foreignKeyName: "subcontract_orders_vendor_id_fkey"
            columns: ["vendor_id"]
            isOneToOne: false
            referencedRelation: "vendors"
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
          {
            foreignKeyName: "subcontractor_rates_subcontractor_id_fkey"
            columns: ["subcontractor_id"]
            isOneToOne: false
            referencedRelation: "vendors"
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
        Relationships: [
          {
            foreignKeyName: "subcontractors_vendor_id_fkey"
            columns: ["vendor_id"]
            isOneToOne: false
            referencedRelation: "vendors"
            referencedColumns: ["id"]
          },
        ]
      }
      task_dependencies: {
        Row: {
          created_at: string | null
          dependency_type: Database["public"]["Enums"]["dependency_type"]
          id: string
          lag_days: number | null
          predecessor_task_id: string
          successor_task_id: string
        }
        Insert: {
          created_at?: string | null
          dependency_type?: Database["public"]["Enums"]["dependency_type"]
          id?: string
          lag_days?: number | null
          predecessor_task_id: string
          successor_task_id: string
        }
        Update: {
          created_at?: string | null
          dependency_type?: Database["public"]["Enums"]["dependency_type"]
          id?: string
          lag_days?: number | null
          predecessor_task_id?: string
          successor_task_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "task_dependencies_predecessor_task_id_fkey"
            columns: ["predecessor_task_id"]
            isOneToOne: false
            referencedRelation: "tasks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "task_dependencies_successor_task_id_fkey"
            columns: ["successor_task_id"]
            isOneToOne: false
            referencedRelation: "tasks"
            referencedColumns: ["id"]
          },
        ]
      }
      tasks: {
        Row: {
          activity_id: string | null
          actual_end_date: string | null
          actual_start_date: string | null
          assigned_to: string | null
          checklist_item: boolean | null
          completion_date: string | null
          created_at: string | null
          created_by: string
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
          actual_end_date?: string | null
          actual_start_date?: string | null
          assigned_to?: string | null
          checklist_item?: boolean | null
          completion_date?: string | null
          created_at?: string | null
          created_by: string
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
          actual_end_date?: string | null
          actual_start_date?: string | null
          assigned_to?: string | null
          checklist_item?: boolean | null
          completion_date?: string | null
          created_at?: string | null
          created_by?: string
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
          {
            foreignKeyName: "vendor_quotations_vendor_id_fkey"
            columns: ["vendor_id"]
            isOneToOne: false
            referencedRelation: "vendors"
            referencedColumns: ["id"]
          },
        ]
      }
      vendors: {
        Row: {
          address: string | null
          code: string
          contact_person: string | null
          created_at: string | null
          credit_limit: number | null
          email: string | null
          id: string
          name: string
          payment_terms: string | null
          phone: string | null
          rating: number | null
          specializations: string[] | null
          status: Database["public"]["Enums"]["vendor_status"]
          tax_id: string | null
          updated_at: string | null
        }
        Insert: {
          address?: string | null
          code: string
          contact_person?: string | null
          created_at?: string | null
          credit_limit?: number | null
          email?: string | null
          id?: string
          name: string
          payment_terms?: string | null
          phone?: string | null
          rating?: number | null
          specializations?: string[] | null
          status?: Database["public"]["Enums"]["vendor_status"]
          tax_id?: string | null
          updated_at?: string | null
        }
        Update: {
          address?: string | null
          code?: string
          contact_person?: string | null
          created_at?: string | null
          credit_limit?: number | null
          email?: string | null
          id?: string
          name?: string
          payment_terms?: string | null
          phone?: string | null
          rating?: number | null
          specializations?: string[] | null
          status?: Database["public"]["Enums"]["vendor_status"]
          tax_id?: string | null
          updated_at?: string | null
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
    }
    Views: {
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
      stock_balances_fifo: {
        Row: {
          available_quantity: number | null
          current_quantity: number | null
          fifo_average_cost: number | null
          fifo_total_value: number | null
          last_movement_date: string | null
          reserved_quantity: number | null
          stock_item_id: string | null
          store_id: string | null
        }
        Insert: {
          available_quantity?: number | null
          current_quantity?: number | null
          fifo_average_cost?: never
          fifo_total_value?: never
          last_movement_date?: string | null
          reserved_quantity?: number | null
          stock_item_id?: string | null
          store_id?: string | null
        }
        Update: {
          available_quantity?: number | null
          current_quantity?: number | null
          fifo_average_cost?: never
          fifo_total_value?: never
          last_movement_date?: string | null
          reserved_quantity?: number | null
          stock_item_id?: string | null
          store_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "stock_balances_stock_item_id_fkey"
            columns: ["stock_item_id"]
            isOneToOne: false
            referencedRelation: "stock_items"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "stock_balances_store_id_fkey"
            columns: ["store_id"]
            isOneToOne: false
            referencedRelation: "stores"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Functions: {
      allocate_indirect_costs: {
        Args: { p_project_id: string }
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
      check_circular_dependency: {
        Args: { p_activity_id: string; p_predecessor_id: string }
        Returns: boolean
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
      update_wbs_direct_costs: {
        Args: { p_project_id: string }
        Returns: undefined
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
