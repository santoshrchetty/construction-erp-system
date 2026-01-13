import { DatabaseConnection } from '../../database/DatabaseConnection';

export interface AccountAssignmentData {
  categories: AccountAssignmentCategory[];
  costCenters: CostCenter[];
  projects: Project[];
  assets: Asset[];
  internalOrders: InternalOrder[];
  profitCenters: ProfitCenter[];
}

export interface AccountAssignmentCategory {
  category_code: string;
  category_name: string;
  description: string;
}

export interface CostCenter {
  cost_center: string;
  cost_center_name: string;
  person_responsible: string;
}

export interface Project {
  wbs_element: string;
  wbs_description: string;
  project_code: string;
}

export interface Asset {
  asset_number: string;
  asset_description: string;
  asset_class: string;
  location: string;
}

export interface InternalOrder {
  order_number: string;
  order_description: string;
  order_type: string;
  responsible_person: string;
}

export interface ProfitCenter {
  profit_center: string;
  profit_center_name: string;
  person_responsible: string;
}

class AccountAssignmentService {
  private db = new DatabaseConnection();

  async getAccountAssignmentCategories(): Promise<AccountAssignmentCategory[]> {
    const query = 'SELECT category_code, category_name, description FROM account_assignment_categories WHERE is_active = true ORDER BY category_name';
    return await this.db.query(query);
  }

  async getCostCenters(companyCode: string = 'C001'): Promise<CostCenter[]> {
    const query = `
      SELECT cost_center, cost_center_name, person_responsible 
      FROM cost_centers 
      WHERE company_code = $1 AND is_active = true 
      AND CURRENT_DATE BETWEEN valid_from AND valid_to
      ORDER BY cost_center_name
    `;
    return await this.db.query(query, [companyCode]);
  }

  async getProjects(): Promise<Project[]> {
    const query = `
      SELECT wbs_element, wbs_description, project_code 
      FROM wbs_nodes 
      WHERE is_active = true 
      ORDER BY wbs_description
    `;
    return await this.db.query(query);
  }

  async getAssets(companyCode: string = 'C001'): Promise<Asset[]> {
    const query = `
      SELECT asset_number, asset_description, asset_class, location 
      FROM fixed_assets 
      WHERE company_code = $1 AND is_active = true 
      ORDER BY asset_description
    `;
    return await this.db.query(query, [companyCode]);
  }

  async getInternalOrders(companyCode: string = 'C001'): Promise<InternalOrder[]> {
    const query = `
      SELECT order_number, order_description, order_type, responsible_person 
      FROM internal_orders 
      WHERE company_code = $1 AND is_active = true 
      AND CURRENT_DATE BETWEEN valid_from AND valid_to
      ORDER BY order_description
    `;
    return await this.db.query(query, [companyCode]);
  }

  async getProfitCenters(companyCode: string = 'C001'): Promise<ProfitCenter[]> {
    const query = `
      SELECT profit_center, profit_center_name, person_responsible 
      FROM profit_centers 
      WHERE company_code = $1 AND is_active = true 
      AND CURRENT_DATE BETWEEN valid_from AND valid_to
      ORDER BY profit_center_name
    `;
    return await this.db.query(query, [companyCode]);
  }

  async getAllAccountAssignmentData(companyCode: string = 'C001'): Promise<AccountAssignmentData> {
    const [categories, costCenters, projects, assets, internalOrders, profitCenters] = await Promise.all([
      this.getAccountAssignmentCategories(),
      this.getCostCenters(companyCode),
      this.getProjects(),
      this.getAssets(companyCode),
      this.getInternalOrders(companyCode),
      this.getProfitCenters(companyCode)
    ]);

    return {
      categories,
      costCenters,
      projects,
      assets,
      internalOrders,
      profitCenters
    };
  }

  async validateAccountAssignment(category: string, object: string, companyCode: string = 'C001'): Promise<boolean> {
    const query = 'SELECT validate_account_assignment($1, $2, $3) as is_valid';
    const result = await this.db.query(query, [category, object, companyCode]);
    return result[0].is_valid;
  }

  async getObjectsByCategory(category: string, companyCode: string = 'C001'): Promise<any[]> {
    switch (category) {
      case 'K': return await this.getCostCenters(companyCode);
      case 'P': return await this.getProjects();
      case 'A': return await this.getAssets(companyCode);
      case 'O': return await this.getInternalOrders(companyCode);
      default: return [];
    }
  }
}

export const accountAssignmentService = new AccountAssignmentService();