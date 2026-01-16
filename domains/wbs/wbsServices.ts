import { WBSRepository } from './repositories/wbsRepository';

export interface WBSNode {
  id: string;
  project_id: string;
  code: string;
  name: string;
  node_type: string;
  level: number;
  sequence_order: number;
  parent_id?: string;
  created_at?: string;
  updated_at?: string;
}

export interface Activity {
  id: string;
  project_id: string;
  wbs_node_id: string;
  code: string;
  name: string;
  activity_type: string;
  status: string;
  priority: string;
  duration_days?: number;
  budget_amount?: number;
  actual_cost?: number;
  planned_start_date?: string;
  planned_end_date?: string;
  actual_start_date?: string;
  actual_end_date?: string;
  progress_percentage?: number;
  assigned_to?: string;
  vendor_id?: string;
  dependencies?: string;
  notes?: string;
  created_at?: string;
  updated_at?: string;
}

export interface Task {
  id: string;
  project_id: string;
  activity_id: string;
  name: string;
  status: string;
  priority: string;
  checklist_item: boolean;
  assigned_to?: string;
  due_date?: string;
  completed_date?: string;
  notes?: string;
  created_at?: string;
  updated_at?: string;
}

export class WBSService {
  private repository: WBSRepository;

  constructor() {
    this.repository = new WBSRepository();
  }

  // WBS Node Services
  async getWBSNodes(projectId: string): Promise<WBSNode[]> {
    return this.repository.getWBSNodes(projectId);
  }

  async createWBSNode(data: Omit<WBSNode, 'id' | 'created_at' | 'updated_at'>): Promise<WBSNode> {
    const code = await this.generateWBSCode(data.project_id, data.parent_id, data.level);
    return this.repository.createWBSNode({ ...data, code });
  }

  async updateWBSNode(id: string, data: Partial<WBSNode>): Promise<WBSNode> {
    return this.repository.updateWBSNode(id, data);
  }

  async deleteWBSNode(id: string): Promise<void> {
    return this.repository.deleteWBSNode(id);
  }

  // Activity Services
  async getActivities(projectId: string, wbsNodeId?: string): Promise<Activity[]> {
    if (wbsNodeId) {
      return this.repository.getActivitiesByWBSNode(wbsNodeId);
    }
    return this.repository.getActivities(projectId);
  }

  async createActivity(data: Omit<Activity, 'id' | 'created_at' | 'updated_at' | 'code'>): Promise<Activity> {
    const code = await this.generateActivityCode(data.project_id, data.wbs_node_id);
    return this.repository.createActivity({ ...data, code });
  }

  async updateActivity(id: string, data: Partial<Activity>): Promise<Activity> {
    return this.repository.updateActivity(id, data);
  }

  async deleteActivity(id: string): Promise<void> {
    return this.repository.deleteActivity(id);
  }

  // Task Services
  async getTasks(projectId: string, activityId?: string): Promise<Task[]> {
    return this.repository.getTasks(projectId, activityId);
  }

  async createTask(data: Omit<Task, 'id' | 'created_at' | 'updated_at'>): Promise<Task> {
    return this.repository.createTask(data);
  }

  async updateTask(id: string, data: Partial<Task>): Promise<Task> {
    return this.repository.updateTask(id, data);
  }

  async deleteTask(id: string): Promise<void> {
    return this.repository.deleteTask(id);
  }

  // Helper Services
  async getVendors() {
    return this.repository.getVendors();
  }

  // Code Generation Logic
  private async generateWBSCode(projectId: string, parentId: string | undefined, level: number): Promise<string> {
    const projectCode = await this.repository.getProjectCode(projectId);
    
    if (!parentId) {
      // Root level node
      const siblings = await this.repository.getWBSNodesByParent(projectId, null);
      const nextSequence = siblings.length + 1;
      return `${projectCode}.${String(nextSequence).padStart(2, '0')}`;
    }

    // Child node
    const parent = await this.repository.getWBSNodeById(parentId);
    if (!parent) throw new Error('Parent node not found');
    
    const siblings = await this.repository.getWBSNodesByParent(projectId, parentId);
    const nextSequence = siblings.length + 1;
    return `${parent.code}.${String(nextSequence).padStart(2, '0')}`;
  }

  private async generateActivityCode(projectId: string, wbsNodeId: string): Promise<string> {
    const wbsNode = await this.repository.getWBSNodeById(wbsNodeId);
    if (!wbsNode) throw new Error('WBS node not found');
    
    const activities = await this.repository.getActivitiesByWBSNode(wbsNodeId);
    const nextSequence = activities.length + 1;
    return `${wbsNode.code}-A${String(nextSequence).padStart(2, '0')}`;
  }
}
