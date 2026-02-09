// Updated Database Types for Material Request System
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
      // Existing tables...
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
      
      // Updated Material Requests table
      material_requests: {
        Row: {
          id: string
          request_number: string
          mr_type: 'PROJECT' | 'MAINTENANCE' | 'OFFICE' | 'SAFETY' | 'EQUIPMENT' | 'GENERAL'
          request_type: 'RESERVATION' | 'PURCHASE_REQ' | 'MATERIAL_REQ'
          status: 'DRAFT' | 'SUBMITTED' | 'APPROVED' | 'REJECTED' | 'CONVERTED' | 'FULFILLED' | 'CANCELLED'
          priority: 'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT'
          requested_by: string
          requested_date: string
          required_date: string
          company_code: string
          plant_code: string | null
          cost_center: string | null
          department_code: string | null
          wbs_element: string | null
          project_code: string | null
          activity_code: string | null
          storage_location: string | null
          delivery_location: string | null
          purpose: string | null
          justification: string | null
          notes: string | null
          total_value: number | null
          currency: string | null
          approval_workflow_id: string | null
          approved_by: string | null
          approved_date: string | null
          rejection_reason: string | null
          created_at: string
          updated_at: string
          created_by: string
          updated_by: string | null
        }
        Insert: {
          id?: string
          request_number: string
          mr_type: 'PROJECT' | 'MAINTENANCE' | 'OFFICE' | 'SAFETY' | 'EQUIPMENT' | 'GENERAL'
          request_type: 'RESERVATION' | 'PURCHASE_REQ' | 'MATERIAL_REQ'
          status?: 'DRAFT' | 'SUBMITTED' | 'APPROVED' | 'REJECTED' | 'CONVERTED' | 'FULFILLED' | 'CANCELLED'
          priority?: 'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT'
          requested_by: string
          requested_date?: string
          required_date: string
          company_code: string
          plant_code?: string | null
          cost_center?: string | null
          department_code?: string | null
          wbs_element?: string | null
          project_code?: string | null
          activity_code?: string | null
          storage_location?: string | null
          delivery_location?: string | null
          purpose?: string | null
          justification?: string | null
          notes?: string | null
          total_value?: number | null
          currency?: string | null
          approval_workflow_id?: string | null
          created_by: string
        }
        Update: {
          mr_type?: 'PROJECT' | 'MAINTENANCE' | 'OFFICE' | 'SAFETY' | 'EQUIPMENT' | 'GENERAL'
          request_type?: 'RESERVATION' | 'PURCHASE_REQ' | 'MATERIAL_REQ'
          status?: 'DRAFT' | 'SUBMITTED' | 'APPROVED' | 'REJECTED' | 'CONVERTED' | 'FULFILLED' | 'CANCELLED'
          priority?: 'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT'
          required_date?: string
          cost_center?: string | null
          department_code?: string | null
          wbs_element?: string | null
          project_code?: string | null
          activity_code?: string | null
          storage_location?: string | null
          delivery_location?: string | null
          purpose?: string | null
          justification?: string | null
          notes?: string | null
          total_value?: number | null
          currency?: string | null
          approval_workflow_id?: string | null
          approved_by?: string | null
          approved_date?: string | null
          rejection_reason?: string | null
          updated_by?: string | null
        }
      }

      // Material Request Items table (Updated with org units and account assignment)
      material_request_items: {
        Row: {
          id: string
          material_request_id: string
          line_number: number
          material_code: string
          material_description: string | null
          quantity: number
          unit_of_measure: string
          standard_price: number | null
          total_line_value: number | null
          available_stock: number | null
          reserved_quantity: number
          issued_quantity: number
          status: 'PENDING' | 'RESERVED' | 'PARTIALLY_ISSUED' | 'FULLY_ISSUED' | 'CANCELLED'
          storage_location: string | null
          batch_number: string | null
          serial_number: string | null
          notes: string | null
          
          // Organizational Units
          company_code: string | null
          plant_code: string | null
          purchasing_group: string | null
          purchasing_organization: string | null
          
          // Account Assignment Fields
          account_assignment_category: 'K' | 'P' | 'A' | 'F' | 'O' | 'N' | 'S' | 'U' | null // K=Cost Center, P=Project, A=Asset, F=Order, O=Sales Order, N=Network, S=Cost Object, U=Unknown
          cost_center: string | null
          project_code: string | null
          wbs_element: string | null
          activity_code: string | null
          internal_order: string | null
          asset_number: string | null
          sales_order: string | null
          sales_order_item: string | null
          network_number: string | null
          network_activity: string | null
          profit_center: string | null
          gl_account: string | null
          
          // PR-specific fields
          material_group: string | null
          supplier_code: string | null
          purchase_info_record: string | null
          delivery_date: string | null
          price_per_unit: number | null
          price_unit: number | null
          currency: string | null
          tax_code: string | null
          delivery_address: string | null
          requisitioner: string | null
          tracking_number: string | null
          
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          material_request_id: string
          line_number: number
          material_code: string
          material_description?: string | null
          quantity: number
          unit_of_measure: string
          standard_price?: number | null
          total_line_value?: number | null
          available_stock?: number | null
          reserved_quantity?: number
          issued_quantity?: number
          status?: 'PENDING' | 'RESERVED' | 'PARTIALLY_ISSUED' | 'FULLY_ISSUED' | 'CANCELLED'
          storage_location?: string | null
          batch_number?: string | null
          serial_number?: string | null
          notes?: string | null
          
          // Organizational Units
          company_code?: string | null
          plant_code?: string | null
          purchasing_group?: string | null
          purchasing_organization?: string | null
          
          // Account Assignment Fields
          account_assignment_category?: 'K' | 'P' | 'A' | 'F' | 'O' | 'N' | 'S' | 'U' | null
          cost_center?: string | null
          project_code?: string | null
          wbs_element?: string | null
          activity_code?: string | null
          internal_order?: string | null
          asset_number?: string | null
          sales_order?: string | null
          sales_order_item?: string | null
          network_number?: string | null
          network_activity?: string | null
          profit_center?: string | null
          gl_account?: string | null
          
          // PR-specific fields
          material_group?: string | null
          supplier_code?: string | null
          purchase_info_record?: string | null
          delivery_date?: string | null
          price_per_unit?: number | null
          price_unit?: number | null
          currency?: string | null
          tax_code?: string | null
          delivery_address?: string | null
          requisitioner?: string | null
          tracking_number?: string | null
        }
        Update: {
          material_description?: string | null
          quantity?: number
          standard_price?: number | null
          total_line_value?: number | null
          available_stock?: number | null
          reserved_quantity?: number
          issued_quantity?: number
          status?: 'PENDING' | 'RESERVED' | 'PARTIALLY_ISSUED' | 'FULLY_ISSUED' | 'CANCELLED'
          storage_location?: string | null
          batch_number?: string | null
          serial_number?: string | null
          notes?: string | null
          
          // Organizational Units
          company_code?: string | null
          plant_code?: string | null
          purchasing_group?: string | null
          purchasing_organization?: string | null
          
          // Account Assignment Fields
          account_assignment_category?: 'K' | 'P' | 'A' | 'F' | 'O' | 'N' | 'S' | 'U' | null
          cost_center?: string | null
          project_code?: string | null
          wbs_element?: string | null
          activity_code?: string | null
          internal_order?: string | null
          asset_number?: string | null
          sales_order?: string | null
          sales_order_item?: string | null
          network_number?: string | null
          network_activity?: string | null
          profit_center?: string | null
          gl_account?: string | null
          
          // PR-specific fields
          material_group?: string | null
          supplier_code?: string | null
          purchase_info_record?: string | null
          delivery_date?: string | null
          price_per_unit?: number | null
          price_unit?: number | null
          currency?: string | null
          tax_code?: string | null
          delivery_address?: string | null
          requisitioner?: string | null
          tracking_number?: string | null
        }
      }

      // Materials Master table
      materials: {
        Row: {
          id: string
          material_code: string
          material_description: string
          material_type: 'RAW_MATERIAL' | 'FINISHED_GOODS' | 'SEMI_FINISHED' | 'CONSUMABLE' | 'SPARE_PARTS' | 'TOOLS' | 'PPE'
          base_unit_of_measure: string
          standard_price: number | null
          currency: string | null
          valuation_method: 'STANDARD_PRICE' | 'MOVING_AVERAGE' | 'FIFO' | 'LIFO'
          procurement_type: 'PURCHASE' | 'MANUFACTURE' | 'BOTH'
          material_group: string | null
          is_active: boolean
          created_at: string
          updated_at: string
          created_by: string
          updated_by: string | null
        }
        Insert: {
          id?: string
          material_code: string
          material_description: string
          material_type: 'RAW_MATERIAL' | 'FINISHED_GOODS' | 'SEMI_FINISHED' | 'CONSUMABLE' | 'SPARE_PARTS' | 'TOOLS' | 'PPE'
          base_unit_of_measure: string
          standard_price?: number | null
          currency?: string | null
          valuation_method?: 'STANDARD_PRICE' | 'MOVING_AVERAGE' | 'FIFO' | 'LIFO'
          procurement_type?: 'PURCHASE' | 'MANUFACTURE' | 'BOTH'
          material_group?: string | null
          is_active?: boolean
          created_by: string
        }
        Update: {
          material_description?: string
          material_type?: 'RAW_MATERIAL' | 'FINISHED_GOODS' | 'SEMI_FINISHED' | 'CONSUMABLE' | 'SPARE_PARTS' | 'TOOLS' | 'PPE'
          base_unit_of_measure?: string
          standard_price?: number | null
          currency?: string | null
          valuation_method?: 'STANDARD_PRICE' | 'MOVING_AVERAGE' | 'FIFO' | 'LIFO'
          procurement_type?: 'PURCHASE' | 'MANUFACTURE' | 'BOTH'
          material_group?: string | null
          is_active?: boolean
          updated_by?: string | null
        }
      }

      // Inventory Stock table
      inventory_stock: {
        Row: {
          id: string
          material_code: string
          storage_location: string
          batch_number: string | null
          quantity_on_hand: number
          quantity_reserved: number
          quantity_available: number
          unit_cost: number | null
          total_value: number | null
          last_movement_date: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          material_code: string
          storage_location: string
          batch_number?: string | null
          quantity_on_hand?: number
          quantity_reserved?: number
          unit_cost?: number | null
          last_movement_date?: string | null
        }
        Update: {
          quantity_on_hand?: number
          quantity_reserved?: number
          unit_cost?: number | null
          last_movement_date?: string | null
        }
      }

      // Material Reservations table
      material_reservations: {
        Row: {
          id: string
          reservation_number: string
          material_request_id: string
          material_request_item_id: string
          material_code: string
          storage_location: string
          reserved_quantity: number
          consumed_quantity: number
          remaining_quantity: number
          reservation_date: string
          expiry_date: string | null
          status: 'ACTIVE' | 'PARTIALLY_CONSUMED' | 'FULLY_CONSUMED' | 'EXPIRED' | 'CANCELLED'
          project_code: string | null
          activity_code: string | null
          cost_center: string | null
          created_at: string
          updated_at: string
          created_by: string
        }
        Insert: {
          id?: string
          reservation_number: string
          material_request_id: string
          material_request_item_id: string
          material_code: string
          storage_location: string
          reserved_quantity: number
          consumed_quantity?: number
          reservation_date: string
          expiry_date?: string | null
          status?: 'ACTIVE' | 'PARTIALLY_CONSUMED' | 'FULLY_CONSUMED' | 'EXPIRED' | 'CANCELLED'
          project_code?: string | null
          activity_code?: string | null
          cost_center?: string | null
          created_by: string
        }
        Update: {
          consumed_quantity?: number
          expiry_date?: string | null
          status?: 'ACTIVE' | 'PARTIALLY_CONSUMED' | 'FULLY_CONSUMED' | 'EXPIRED' | 'CANCELLED'
        }
      }

      // Departments table
      departments: {
        Row: {
          id: string
          department_code: string
          department_name: string
          description: string | null
          cost_center: string | null
          manager_id: string | null
          is_active: boolean
          created_at: string
        }
        Insert: {
          id?: string
          department_code: string
          department_name: string
          description?: string | null
          cost_center?: string | null
          manager_id?: string | null
          is_active?: boolean
        }
        Update: {
          department_name?: string
          description?: string | null
          cost_center?: string | null
          manager_id?: string | null
          is_active?: boolean
        }
      }

      // Cost Centers table
      cost_centers: {
        Row: {
          id: string
          cost_center_code: string
          cost_center_name: string
          description: string | null
          department_code: string | null
          budget_amount: number | null
          currency: string | null
          is_active: boolean
          created_at: string
        }
        Insert: {
          id?: string
          cost_center_code: string
          cost_center_name: string
          description?: string | null
          department_code?: string | null
          budget_amount?: number | null
          currency?: string | null
          is_active?: boolean
        }
        Update: {
          cost_center_name?: string
          description?: string | null
          department_code?: string | null
          budget_amount?: number | null
          currency?: string | null
          is_active?: boolean
        }
      }

      // Storage Locations table
      storage_locations: {
        Row: {
          id: string
          location_code: string
          location_name: string
          location_type: 'WAREHOUSE' | 'SITE' | 'YARD' | 'OFFICE' | 'VEHICLE' | null
          address: string | null
          site_code: string | null
          is_active: boolean
          created_at: string
        }
        Insert: {
          id?: string
          location_code: string
          location_name: string
          location_type?: 'WAREHOUSE' | 'SITE' | 'YARD' | 'OFFICE' | 'VEHICLE' | null
          address?: string | null
          site_code?: string | null
          is_active?: boolean
        }
        Update: {
          location_name?: string
          location_type?: 'WAREHOUSE' | 'SITE' | 'YARD' | 'OFFICE' | 'VEHICLE' | null
          address?: string | null
          site_code?: string | null
          is_active?: boolean
        }
      }

      // Purchase Requisitions table
      purchase_requisitions: {
        Row: {
          id: string
          pr_number: string
          pr_type: 'NB' | 'UB' | 'KB' | 'LB' // NB=Standard, UB=Stock Transfer, KB=Consignment, LB=Subcontracting
          status: 'OPEN' | 'RELEASED' | 'ORDERED' | 'CLOSED' | 'CANCELLED'
          priority: 'LOW' | 'NORMAL' | 'HIGH' | 'URGENT'
          created_from_mr: string | null
          company_code: string
          purchasing_organization: string
          purchasing_group: string | null
          requested_by: string
          created_date: string
          total_value: number | null
          currency: string | null
          approval_status: string | null
          notes: string | null
          created_at: string
          updated_at: string
          created_by: string
          updated_by: string | null
        }
        Insert: {
          id?: string
          pr_number: string
          pr_type?: 'NB' | 'UB' | 'KB' | 'LB'
          status?: 'OPEN' | 'RELEASED' | 'ORDERED' | 'CLOSED' | 'CANCELLED'
          priority?: 'LOW' | 'NORMAL' | 'HIGH' | 'URGENT'
          created_from_mr?: string | null
          company_code: string
          purchasing_organization: string
          purchasing_group?: string | null
          requested_by: string
          created_date?: string
          total_value?: number | null
          currency?: string | null
          approval_status?: string | null
          notes?: string | null
          created_by: string
        }
        Update: {
          pr_type?: 'NB' | 'UB' | 'KB' | 'LB'
          status?: 'OPEN' | 'RELEASED' | 'ORDERED' | 'CLOSED' | 'CANCELLED'
          priority?: 'LOW' | 'NORMAL' | 'HIGH' | 'URGENT'
          purchasing_group?: string | null
          total_value?: number | null
          currency?: string | null
          approval_status?: string | null
          notes?: string | null
          updated_by?: string | null
        }
      }

      // Purchase Requisition Items table
      purchase_requisition_items: {
        Row: {
          id: string
          pr_id: string
          pr_item_number: string
          material_request_item_id: string | null
          material_code: string
          short_text: string | null
          quantity: number
          unit_of_measure: string
          delivery_date: string
          plant_code: string | null
          storage_location: string | null
          material_group: string | null
          price_per_unit: number | null
          price_unit: number | null
          currency: string | null
          net_price: number | null
          account_assignment_category: 'K' | 'P' | 'A' | 'F' | 'O' | 'N' | 'S' | 'U' | null
          cost_center: string | null
          project_code: string | null
          wbs_element: string | null
          activity_code: string | null
          internal_order: string | null
          asset_number: string | null
          sales_order: string | null
          sales_order_item: string | null
          network_number: string | null
          network_activity: string | null
          profit_center: string | null
          gl_account: string | null
          supplier_code: string | null
          purchase_info_record: string | null
          tax_code: string | null
          delivery_address: string | null
          requisitioner: string | null
          tracking_number: string | null
          item_category: string | null
          status: 'OPEN' | 'ORDERED' | 'DELIVERED' | 'INVOICED' | 'CLOSED'
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          pr_id: string
          pr_item_number: string
          material_request_item_id?: string | null
          material_code: string
          short_text?: string | null
          quantity: number
          unit_of_measure: string
          delivery_date: string
          plant_code?: string | null
          storage_location?: string | null
          material_group?: string | null
          price_per_unit?: number | null
          price_unit?: number | null
          currency?: string | null
          account_assignment_category?: 'K' | 'P' | 'A' | 'F' | 'O' | 'N' | 'S' | 'U' | null
          cost_center?: string | null
          project_code?: string | null
          wbs_element?: string | null
          activity_code?: string | null
          internal_order?: string | null
          asset_number?: string | null
          sales_order?: string | null
          sales_order_item?: string | null
          network_number?: string | null
          network_activity?: string | null
          profit_center?: string | null
          gl_account?: string | null
          supplier_code?: string | null
          purchase_info_record?: string | null
          tax_code?: string | null
          delivery_address?: string | null
          requisitioner?: string | null
          tracking_number?: string | null
          item_category?: string | null
          status?: 'OPEN' | 'ORDERED' | 'DELIVERED' | 'INVOICED' | 'CLOSED'
        }
        Update: {
          short_text?: string | null
          quantity?: number
          delivery_date?: string
          plant_code?: string | null
          storage_location?: string | null
          material_group?: string | null
          price_per_unit?: number | null
          price_unit?: number | null
          currency?: string | null
          account_assignment_category?: 'K' | 'P' | 'A' | 'F' | 'O' | 'N' | 'S' | 'U' | null
          cost_center?: string | null
          project_code?: string | null
          wbs_element?: string | null
          activity_code?: string | null
          internal_order?: string | null
          asset_number?: string | null
          sales_order?: string | null
          sales_order_item?: string | null
          network_number?: string | null
          network_activity?: string | null
          profit_center?: string | null
          gl_account?: string | null
          supplier_code?: string | null
          purchase_info_record?: string | null
          tax_code?: string | null
          delivery_address?: string | null
          requisitioner?: string | null
          tracking_number?: string | null
          item_category?: string | null
          status?: 'OPEN' | 'ORDERED' | 'DELIVERED' | 'INVOICED' | 'CLOSED'
        }
      }
        Row: {
          id: string
          transfer_order_number: string
          material_request_id: string | null
          from_location: string
          to_location: string
          transfer_date: string
          status: 'CREATED' | 'IN_TRANSIT' | 'DELIVERED' | 'CANCELLED'
          transport_cost: number | null
          handling_cost: number | null
          total_transfer_cost: number | null
          vehicle_number: string | null
          driver_name: string | null
          notes: string | null
          created_at: string
          updated_at: string
          created_by: string
        }
        Insert: {
          id?: string
          transfer_order_number: string
          material_request_id?: string | null
          from_location: string
          to_location: string
          transfer_date: string
          status?: 'CREATED' | 'IN_TRANSIT' | 'DELIVERED' | 'CANCELLED'
          transport_cost?: number | null
          handling_cost?: number | null
          vehicle_number?: string | null
          driver_name?: string | null
          notes?: string | null
          created_by: string
        }
        Update: {
          status?: 'CREATED' | 'IN_TRANSIT' | 'DELIVERED' | 'CANCELLED'
          transport_cost?: number | null
          handling_cost?: number | null
          vehicle_number?: string | null
          driver_name?: string | null
          notes?: string | null
        }
      }
    }
  }
}

// Derived types for components
export type MaterialRequest = Database['public']['Tables']['material_requests']['Row']
export type MaterialRequestInsert = Database['public']['Tables']['material_requests']['Insert']
export type MaterialRequestUpdate = Database['public']['Tables']['material_requests']['Update']

export type MaterialRequestItem = Database['public']['Tables']['material_request_items']['Row']
export type MaterialRequestItemInsert = Database['public']['Tables']['material_request_items']['Insert']
export type MaterialRequestItemUpdate = Database['public']['Tables']['material_request_items']['Update']

export type Material = Database['public']['Tables']['materials']['Row']
export type MaterialInsert = Database['public']['Tables']['materials']['Insert']
export type MaterialUpdate = Database['public']['Tables']['materials']['Update']

export type InventoryStock = Database['public']['Tables']['inventory_stock']['Row']
export type InventoryStockInsert = Database['public']['Tables']['inventory_stock']['Insert']
export type InventoryStockUpdate = Database['public']['Tables']['inventory_stock']['Update']

export type MaterialReservation = Database['public']['Tables']['material_reservations']['Row']
export type MaterialReservationInsert = Database['public']['Tables']['material_reservations']['Insert']
export type MaterialReservationUpdate = Database['public']['Tables']['material_reservations']['Update']

export type Department = Database['public']['Tables']['departments']['Row']
export type DepartmentInsert = Database['public']['Tables']['departments']['Insert']
export type DepartmentUpdate = Database['public']['Tables']['departments']['Update']

export type CostCenter = Database['public']['Tables']['cost_centers']['Row']
export type CostCenterInsert = Database['public']['Tables']['cost_centers']['Insert']
export type CostCenterUpdate = Database['public']['Tables']['cost_centers']['Update']

export type StorageLocation = Database['public']['Tables']['storage_locations']['Row']
export type StorageLocationInsert = Database['public']['Tables']['storage_locations']['Insert']
export type StorageLocationUpdate = Database['public']['Tables']['storage_locations']['Update']

export type PurchaseRequisition = Database['public']['Tables']['purchase_requisitions']['Row']
export type PurchaseRequisitionInsert = Database['public']['Tables']['purchase_requisitions']['Insert']
export type PurchaseRequisitionUpdate = Database['public']['Tables']['purchase_requisitions']['Update']

export type PurchaseRequisitionItem = Database['public']['Tables']['purchase_requisition_items']['Row']
export type PurchaseRequisitionItemInsert = Database['public']['Tables']['purchase_requisition_items']['Insert']
export type PurchaseRequisitionItemUpdate = Database['public']['Tables']['purchase_requisition_items']['Update']

export type MaterialTransferOrder = Database['public']['Tables']['material_transfer_orders']['Row']
export type MaterialTransferOrderInsert = Database['public']['Tables']['material_transfer_orders']['Insert']
export type MaterialTransferOrderUpdate = Database['public']['Tables']['material_transfer_orders']['Update']