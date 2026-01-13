import { DatabaseConnection } from '../../database/DatabaseConnection';

export interface CompletePurchaseOrder {
  id?: number;
  po_number: string;
  vendor_code: string;
  project_code: string;
  po_date: string;
  delivery_date?: string;
  total_amount: number;
  tax_amount: number;
  discount_amount: number;
  net_amount: number;
  currency: string;
  payment_terms: string;
  delivery_address?: string;
  terms_conditions?: string;
  remarks?: string;
  status: 'DRAFT' | 'APPROVED' | 'SENT' | 'RECEIVED' | 'CLOSED';
  priority: 'LOW' | 'NORMAL' | 'HIGH' | 'URGENT';
  department?: string;
  cost_center?: string;
  budget_code?: string;
  created_by: string;
  approved_by?: string;
  approved_at?: string;
  revision_number: number;
  created_at?: string;
}

export interface CompletePOItem {
  id?: number;
  po_id: number;
  material_code: string;
  description: string;
  quantity: number;
  unit: string;
  unit_price: number;
  line_total: number;
  tax_code: string;
  tax_rate: number;
  tax_amount: number;
  discount_percent: number;
  discount_amount: number;
  net_amount: number;
  delivery_date?: string;
  plant_code?: string;
  storage_location?: string;
  gl_account?: string;
  cost_center?: string;
  wbs_element?: string;
  received_quantity: number;
  invoiced_quantity: number;
  item_status: string;
}

class CompletePOService {
  private db = new DatabaseConnection();

  // PO CRUD Operations
  async getAllPOs(filters?: any): Promise<CompletePurchaseOrder[]> {
    let query = `
      SELECT po.*, v.vendor_name, p.project_name
      FROM purchase_orders po
      LEFT JOIN vendors v ON po.vendor_code = v.vendor_code
      LEFT JOIN projects p ON po.project_code = p.project_code
    `;
    const conditions = [];
    const params = [];

    if (filters?.status) {
      conditions.push(`po.status = $${params.length + 1}`);
      params.push(filters.status);
    }
    if (filters?.vendor_code) {
      conditions.push(`po.vendor_code = $${params.length + 1}`);
      params.push(filters.vendor_code);
    }
    if (filters?.date_from) {
      conditions.push(`po.po_date >= $${params.length + 1}`);
      params.push(filters.date_from);
    }

    if (conditions.length > 0) {
      query += ` WHERE ${conditions.join(' AND ')}`;
    }
    query += ` ORDER BY po.created_at DESC`;

    return await this.db.query(query, params);
  }

  async createPO(po: Omit<CompletePurchaseOrder, 'id' | 'created_at'>): Promise<CompletePurchaseOrder> {
    const query = `
      INSERT INTO purchase_orders (
        po_number, vendor_code, project_code, po_date, delivery_date,
        total_amount, tax_amount, discount_amount, net_amount, currency,
        payment_terms, delivery_address, terms_conditions, remarks,
        status, priority, department, cost_center, budget_code, created_by
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20)
      RETURNING *
    `;
    const values = [
      po.po_number, po.vendor_code, po.project_code, po.po_date, po.delivery_date,
      po.total_amount, po.tax_amount, po.discount_amount, po.net_amount, po.currency,
      po.payment_terms, po.delivery_address, po.terms_conditions, po.remarks,
      po.status, po.priority, po.department, po.cost_center, po.budget_code, po.created_by
    ];
    const result = await this.db.query(query, values);
    return result[0];
  }

  async updatePO(id: number, updates: Partial<CompletePurchaseOrder>): Promise<CompletePurchaseOrder> {
    const fields = Object.keys(updates).filter(key => key !== 'id');
    const setClause = fields.map((field, index) => `${field} = $${index + 2}`).join(', ');
    const values = [id, ...fields.map(field => updates[field as keyof CompletePurchaseOrder])];
    
    const query = `UPDATE purchase_orders SET ${setClause} WHERE id = $1 RETURNING *`;
    const result = await this.db.query(query, values);
    return result[0];
  }

  // Approval Workflow
  async submitForApproval(poId: number, approverId: string): Promise<void> {
    await this.db.query(`
      INSERT INTO po_approvals (po_id, approver_level, approver_id, approval_status)
      VALUES ($1, 1, $2, 'PENDING')
    `, [poId, approverId]);
    
    await this.updatePO(poId, { status: 'PENDING_APPROVAL' as any });
  }

  async approvePO(poId: number, approverId: string, comments?: string): Promise<void> {
    await this.db.query(`
      UPDATE po_approvals 
      SET approval_status = 'APPROVED', approved_at = CURRENT_TIMESTAMP, comments = $3
      WHERE po_id = $1 AND approver_id = $2
    `, [poId, approverId, comments]);
    
    await this.updatePO(poId, { 
      status: 'APPROVED' as any, 
      approved_by: approverId, 
      approved_at: new Date().toISOString() 
    });
  }

  // Material Integration
  async getMaterials(search?: string): Promise<any[]> {
    let query = 'SELECT material_code, description, base_unit, standard_price FROM material_master';
    const params = [];
    
    if (search) {
      query += ' WHERE description ILIKE $1 OR material_code ILIKE $1';
      params.push(`%${search}%`);
    }
    
    query += ' ORDER BY description LIMIT 50';
    return await this.db.query(query, params);
  }

  async getMaterialPrice(materialCode: string, vendorCode: string): Promise<number> {
    const query = `
      SELECT price FROM material_price_history 
      WHERE material_code = $1 AND vendor_code = $2 
      AND CURRENT_DATE BETWEEN valid_from AND valid_to
      ORDER BY created_at DESC LIMIT 1
    `;
    const result = await this.db.query(query, [materialCode, vendorCode]);
    return result[0]?.price || 0;
  }

  // Tax Calculations
  async calculateTax(items: CompletePOItem[]): Promise<{ totalTax: number; itemTaxes: number[] }> {
    const itemTaxes = items.map(item => {
      const taxAmount = (item.line_total * item.tax_rate) / 100;
      return taxAmount;
    });
    
    const totalTax = itemTaxes.reduce((sum, tax) => sum + tax, 0);
    return { totalTax, itemTaxes };
  }

  // Goods Receipt
  async createGoodsReceipt(grData: any): Promise<any> {
    const query = `
      INSERT INTO goods_receipts (gr_number, po_id, vendor_code, gr_date, delivery_note, total_amount, created_by)
      VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *
    `;
    const values = [grData.gr_number, grData.po_id, grData.vendor_code, grData.gr_date, 
                   grData.delivery_note, grData.total_amount, grData.created_by];
    const result = await this.db.query(query, values);
    return result[0];
  }

  // Budget Control
  async checkBudget(poId: number, budgetCode: string, amount: number): Promise<boolean> {
    const query = `
      SELECT available_amount FROM po_budget_control 
      WHERE budget_code = $1 AND available_amount >= $2
    `;
    const result = await this.db.query(query, [budgetCode, amount]);
    return result.length > 0;
  }

  // Reporting
  async getPOReport(filters: any): Promise<any[]> {
    const query = `
      SELECT 
        po.po_number, po.po_date, po.total_amount, po.status,
        v.vendor_name, p.project_name,
        COUNT(poi.id) as item_count
      FROM purchase_orders po
      LEFT JOIN vendors v ON po.vendor_code = v.vendor_code
      LEFT JOIN projects p ON po.project_code = p.project_code
      LEFT JOIN purchase_order_items poi ON po.id = poi.po_id
      WHERE po.po_date BETWEEN $1 AND $2
      GROUP BY po.id, v.vendor_name, p.project_name
      ORDER BY po.po_date DESC
    `;
    return await this.db.query(query, [filters.date_from, filters.date_to]);
  }

  // Master Data
  async getVendors(): Promise<any[]> {
    return await this.db.query('SELECT vendor_code as code, vendor_name as name FROM vendors ORDER BY vendor_name');
  }

  async getProjects(): Promise<any[]> {
    return await this.db.query('SELECT project_code, project_name FROM projects ORDER BY project_name');
  }

  async getPlants(): Promise<any[]> {
    return await this.db.query('SELECT plant_code, plant_name FROM plants ORDER BY plant_name');
  }

  async getStorageLocations(plantCode: string): Promise<any[]> {
    return await this.db.query('SELECT storage_location, description FROM storage_locations WHERE plant_code = $1', [plantCode]);
  }
}

export const completePOService = new CompletePOService();