import { DatabaseConnection } from '../../database/DatabaseConnection';

export interface IntegratedPurchaseOrder {
  id?: number;
  po_number: string;
  vendor_code: string;
  project_code: string;
  po_date: string;
  delivery_date?: string;
  total_amount: number;
  tax_amount: number;
  net_amount: number;
  currency: string;
  payment_terms: string;
  delivery_address?: string;
  terms_conditions?: string;
  remarks?: string;
  status: 'DRAFT' | 'PENDING_APPROVAL' | 'APPROVED' | 'REJECTED' | 'SENT' | 'RECEIVED';
  priority: 'LOW' | 'NORMAL' | 'HIGH' | 'URGENT';
  department?: string;
  cost_center?: string;
  budget_code?: string;
  approval_route_id?: string;
  current_approval_level: number;
  approval_status: string;
  created_by: string;
  created_at?: string;
}

class IntegratedPOService {
  private db = new DatabaseConnection();

  async createPO(po: Omit<IntegratedPurchaseOrder, 'id' | 'created_at'>): Promise<IntegratedPurchaseOrder> {
    // Create PO
    const query = `
      INSERT INTO purchase_orders (
        po_number, vendor_code, project_code, po_date, delivery_date,
        total_amount, tax_amount, net_amount, currency, payment_terms,
        delivery_address, terms_conditions, remarks, status, priority,
        department, cost_center, budget_code, created_by
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19)
      RETURNING *
    `;
    const values = [
      po.po_number, po.vendor_code, po.project_code, po.po_date, po.delivery_date,
      po.total_amount, po.tax_amount, po.net_amount, po.currency, po.payment_terms,
      po.delivery_address, po.terms_conditions, po.remarks, po.status, po.priority,
      po.department, po.cost_center, po.budget_code, po.created_by
    ];
    const result = await this.db.query(query, values);
    const createdPO = result[0];

    // Initiate approval workflow if amount > 0
    if (po.total_amount > 0) {
      await this.initiateApproval(createdPO);
    }

    return createdPO;
  }

  async initiateApproval(po: IntegratedPurchaseOrder): Promise<string> {
    const query = `
      SELECT initiate_po_approval($1, $2, $3, $4, $5, $6) as route_id
    `;
    const result = await this.db.query(query, [
      po.po_number, po.total_amount, po.vendor_code, 
      po.department, po.priority, po.created_by
    ]);
    return result[0].route_id;
  }

  async approvePO(poNumber: string, approverId: string, comments?: string): Promise<void> {
    // Get current approval route
    const routeQuery = `
      SELECT ar.id, ar.current_level, ar.total_levels
      FROM approval_routes ar
      JOIN purchase_orders po ON po.approval_route_id = ar.id
      WHERE po.po_number = $1
    `;
    const routeResult = await this.db.query(routeQuery, [poNumber]);
    const route = routeResult[0];

    // Record approval in approval_history
    await this.db.query(`
      INSERT INTO approval_history (
        route_id, approver_id, approval_level, action, comments
      ) VALUES ($1, $2, $3, 'APPROVED', $4)
    `, [route.id, approverId, route.current_level, comments]);

    // Check if final approval
    if (route.current_level >= route.total_levels) {
      // Final approval - update PO status
      await this.db.query(`
        UPDATE purchase_orders 
        SET approval_status = 'APPROVED', status = 'APPROVED'
        WHERE po_number = $1
      `, [poNumber]);

      await this.db.query(`
        UPDATE approval_routes 
        SET status = 'APPROVED', completed_at = CURRENT_TIMESTAMP
        WHERE id = $1
      `, [route.id]);
    } else {
      // Move to next level
      await this.db.query(`
        UPDATE approval_routes 
        SET current_level = current_level + 1
        WHERE id = $1
      `, [route.id]);

      await this.db.query(`
        UPDATE purchase_orders 
        SET current_approval_level = current_approval_level + 1
        WHERE po_number = $1
      `, [poNumber]);
    }
  }

  async rejectPO(poNumber: string, approverId: string, comments: string): Promise<void> {
    const routeQuery = `
      SELECT ar.id, ar.current_level
      FROM approval_routes ar
      JOIN purchase_orders po ON po.approval_route_id = ar.id
      WHERE po.po_number = $1
    `;
    const routeResult = await this.db.query(routeQuery, [poNumber]);
    const route = routeResult[0];

    // Record rejection
    await this.db.query(`
      INSERT INTO approval_history (
        route_id, approver_id, approval_level, action, comments
      ) VALUES ($1, $2, $3, 'REJECTED', $4)
    `, [route.id, approverId, route.current_level, comments]);

    // Update PO and route status
    await this.db.query(`
      UPDATE purchase_orders 
      SET approval_status = 'REJECTED', status = 'REJECTED'
      WHERE po_number = $1
    `, [poNumber]);

    await this.db.query(`
      UPDATE approval_routes 
      SET status = 'REJECTED', completed_at = CURRENT_TIMESTAMP
      WHERE id = $1
    `, [route.id]);
  }

  async getPendingApprovals(approverId: string): Promise<any[]> {
    const query = `
      SELECT 
        po.po_number, po.total_amount, po.vendor_code, po.created_by,
        ar.current_level, ar.total_levels, v.vendor_name
      FROM purchase_orders po
      JOIN approval_routes ar ON po.approval_route_id = ar.id
      JOIN approval_policies ap ON ar.policy_id = ap.id
      LEFT JOIN vendors v ON po.vendor_code = v.vendor_code
      WHERE ar.status = 'PENDING'
        AND ap.approver_role IN (
          SELECT role_name FROM user_roles WHERE user_id = $1
        )
        AND ar.current_level = ap.approver_level
    `;
    return await this.db.query(query, [approverId]);
  }

  // Standard CRUD operations
  async getAllPOs(): Promise<IntegratedPurchaseOrder[]> {
    const query = `
      SELECT po.*, v.vendor_name, p.project_name, ar.status as route_status
      FROM purchase_orders po
      LEFT JOIN vendors v ON po.vendor_code = v.vendor_code
      LEFT JOIN projects p ON po.project_code = p.project_code
      LEFT JOIN approval_routes ar ON po.approval_route_id = ar.id
      ORDER BY po.created_at DESC
    `;
    return await this.db.query(query);
  }

  async getMaterials(): Promise<any[]> {
    return await this.db.query('SELECT material_code, description, base_unit FROM material_master ORDER BY description');
  }

  async getVendors(): Promise<any[]> {
    return await this.db.query('SELECT vendor_code as code, vendor_name as name FROM vendors ORDER BY vendor_name');
  }

  async getProjects(): Promise<any[]> {
    return await this.db.query('SELECT project_code, project_name FROM projects ORDER BY project_name');
  }
}

export const integratedPOService = new IntegratedPOService();