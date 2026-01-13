// domains/purchase-orders/poServices.ts
import { supabase } from '../../lib/supabase-client';

export interface PurchaseOrder {
  id?: string;
  po_number: string;
  vendor_code: string;
  project_code: string;
  po_date: string;
  delivery_date: string;
  status: string;
  total_amount: number;
  tax_amount: number;
  net_amount: number;
  items: POItem[];
}

export interface POItem {
  id?: string;
  material_code: string;
  material_description: string;
  quantity: number;
  unit: string;
  unit_price: number;
  line_total: number;
  tax_code: string;
  tax_amount: number;
  net_amount: number;
  account_assignment_category: string;
  account_assignment_object: string;
}

export const poServices = {
  // Get vendors
  async getVendors() {
    const { data, error } = await supabase
      .from('vendors')
      .select('vendor_code, vendor_name')
      .eq('is_active', true);
    
    if (error) throw error;
    return data;
  },

  // Get projects
  async getProjects() {
    const { data, error } = await supabase
      .from('projects')
      .select('project_code, project_name')
      .eq('is_active', true);
    
    if (error) throw error;
    return data;
  },

  // Get materials
  async getMaterials() {
    const { data, error } = await supabase
      .from('material_master_view')
      .select('material_code, description, base_uom, standard_price')
      .limit(100);
    
    if (error) throw error;
    return data;
  },

  // Get tax codes
  async getTaxCodes() {
    const { data, error } = await supabase
      .from('tax_codes')
      .select('tax_code, tax_name, tax_rate')
      .eq('is_active', true);
    
    if (error) throw error;
    return data;
  },

  // Get cost centers
  async getCostCenters() {
    const { data, error } = await supabase
      .from('cost_centers')
      .select('cost_center, cost_center_name')
      .eq('is_active', true);
    
    if (error) throw error;
    return data;
  },

  // Create purchase order
  async createPO(po: PurchaseOrder) {
    // Insert PO header
    const { data: poData, error: poError } = await supabase
      .from('purchase_orders')
      .insert({
        po_number: po.po_number,
        vendor_code: po.vendor_code,
        project_code: po.project_code,
        po_date: po.po_date,
        delivery_date: po.delivery_date,
        status: 'DRAFT',
        total_amount: po.total_amount,
        tax_amount: po.tax_amount,
        net_amount: po.net_amount
      })
      .select()
      .single();

    if (poError) throw poError;

    // Insert PO items
    const itemsToInsert = po.items.map(item => ({
      po_id: poData.id,
      material_code: item.material_code,
      material_description: item.material_description,
      quantity: item.quantity,
      unit: item.unit,
      unit_price: item.unit_price,
      line_total: item.line_total,
      tax_code: item.tax_code,
      tax_amount: item.tax_amount,
      net_amount: item.net_amount,
      account_assignment_category: item.account_assignment_category,
      account_assignment_object: item.account_assignment_object
    }));

    const { error: itemsError } = await supabase
      .from('purchase_order_items')
      .insert(itemsToInsert);

    if (itemsError) throw itemsError;

    return poData;
  }
};