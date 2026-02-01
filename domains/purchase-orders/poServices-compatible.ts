import { DatabaseConnection } from '../../database/DatabaseConnection';

export interface PurchaseOrder {
  id?: number;
  po_number: string;
  vendor_code: string;
  project_code: string;
  po_date: string;
  delivery_date?: string;
  total_amount: number;
  tax_amount?: number;
  discount_amount?: number;
  net_amount?: number;
  currency?: string;
  payment_terms?: string;
  delivery_address?: string;
  terms_conditions?: string;
  remarks?: string;
  status: 'DRAFT' | 'APPROVED' | 'SENT' | 'RECEIVED';
  created_by: string;
  approved_by?: string;
  approved_at?: string;
  created_at?: string;
}

export interface PurchaseOrderItem {
  id?: number;
  po_id: number;
  material_code: string;
  description: string;
  quantity: number;
  unit: string;
  unit_price: number;
  line_total: number;
  tax_code?: string;
  tax_rate?: number;
  tax_amount?: number;
  discount_percent?: number;
  discount_amount?: number;
  net_amount?: number;
  delivery_date?: string;
  plant_code?: string;
  storage_location?: string;
}

class PurchaseOrderService {
  private db = new DatabaseConnection();

  async getAllPOs(): Promise<PurchaseOrder[]> {
    const query = `
      SELECT po.*, v.vendor_name, p.project_name
      FROM purchase_orders po
      LEFT JOIN vendors v ON po.vendor_code = v.vendor_code
      LEFT JOIN projects p ON po.project_code = p.project_code
      ORDER BY po.created_at DESC
    `;
    return await this.db.query(query);
  }

  async createPO(po: Omit<PurchaseOrder, 'id' | 'created_at'>): Promise<PurchaseOrder> {
    const query = `
      INSERT INTO purchase_orders (po_number, vendor_code, project_code, po_date, total_amount, status, created_by)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *
    `;
    const values = [po.po_number, po.vendor_code, po.project_code, po.po_date, po.total_amount, po.status, po.created_by];
    const result = await this.db.query(query, values);
    
    // Initiate approval workflow if amount > 0
    if (po.total_amount > 0) {
      await this.db.query(
        'SELECT initiate_po_approval($1, $2, $3)',
        [po.po_number, po.total_amount, po.created_by]
      );
    }
    
    return result[0];
  }

  async getPOItems(poId: number): Promise<PurchaseOrderItem[]> {
    const query = 'SELECT * FROM purchase_order_items WHERE po_id = $1 ORDER BY id';
    return await this.db.query(query, [poId]);
  }

  async addPOItem(item: Omit<PurchaseOrderItem, 'id'>): Promise<PurchaseOrderItem> {
    const query = `
      INSERT INTO purchase_order_items (po_id, material_code, description, quantity, unit_price, line_total)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *
    `;
    const values = [item.po_id, item.material_code, item.description, item.quantity, item.unit_price, item.line_total];
    const result = await this.db.query(query, values);
    return result[0];
  }

  async getVendors(): Promise<any[]> {
    const query = 'SELECT vendor_code as code, vendor_name as name FROM vendors ORDER BY vendor_name';
    return await this.db.query(query);
  }

  async getMaterials(): Promise<any[]> {
    const query = 'SELECT material_code, description, base_unit FROM material_master ORDER BY description';
    return await this.db.query(query);
  }

  async getProjects(): Promise<any[]> {
    const query = 'SELECT project_code, project_name FROM projects ORDER BY project_name';
    return await this.db.query(query);
  }

  async approvePO(poNumber: string, approverId: string, comments?: string): Promise<boolean> {
    const query = 'SELECT process_po_approval($1, $2, $3, $4)';
    const result = await this.db.query(query, [poNumber, approverId, 'APPROVED', comments]);
    return result[0]?.process_po_approval || false;
  }

  async rejectPO(poNumber: string, approverId: string, comments?: string): Promise<boolean> {
    const query = 'SELECT process_po_approval($1, $2, $3, $4)';
    const result = await this.db.query(query, [poNumber, approverId, 'REJECTED', comments]);
    return result[0]?.process_po_approval || false;
  }

  async getPendingApprovals(approverId: string): Promise<any[]> {
    const query = `
      SELECT po.*, ar.id as request_id, ar.status as approval_status,
             ap.policy_name, ap.approval_strategy
      FROM purchase_orders po
      JOIN approval_requests ar ON po.approval_request_id = ar.id
      JOIN approval_policies ap ON ar.object_type = ap.approval_object_type
      WHERE ar.status IN ('PENDING', 'IN_PROGRESS')
        AND EXISTS (
          SELECT 1 FROM approval_levels al
          WHERE al.policy_id = ap.id
            AND al.approver_role IN (
              SELECT role FROM user_roles WHERE user_id = $1
            )
        )
    `;
    return await this.db.query(query, [approverId]);
  }
}

export const purchaseOrderService = new PurchaseOrderService();