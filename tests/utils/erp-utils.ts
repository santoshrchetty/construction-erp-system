import { createClient } from '@supabase/supabase-js';
import { getTestEnvironment } from '../config/environment';
import { randomUUID } from 'crypto';

export class ERPTestUtils {
  private supabase: any;
  private testRunId: string;
  
  constructor() {
    const env = getTestEnvironment();
    this.supabase = createClient(env.supabaseUrl, env.supabaseAnonKey);
    this.testRunId = process.env.TEST_RUN_ID || randomUUID();
  }
  
  async createTestProject(projectData: any) {
    const project = {
      ...projectData,
      project_code: `TEST-${this.testRunId.slice(0, 8)}-${projectData.project_code}`,
      test_run_id: this.testRunId,
      created_at: new Date().toISOString(),
    };
    
    const { data, error } = await this.supabase
      .from('projects')
      .insert(project)
      .select()
      .single();
      
    if (error) throw error;
    return data;
  }
  
  async createTestMaterial(materialData: any) {
    const material = {
      ...materialData,
      material_code: `TEST-${this.testRunId.slice(0, 8)}-${materialData.material_code}`,
      test_run_id: this.testRunId,
    };
    
    const { data, error } = await this.supabase
      .from('materials')
      .insert(material)
      .select()
      .single();
      
    if (error) throw error;
    return data;
  }
  
  async postTestTransaction(journalEntry: any) {
    const entry = {
      ...journalEntry,
      test_run_id: this.testRunId,
      posting_date: new Date().toISOString(),
    };
    
    const { data, error } = await this.supabase
      .from('universal_journal')
      .insert(entry)
      .select()
      .single();
      
    if (error) throw error;
    return data;
  }
  
  async getTestUser(role: string) {
    const { data } = await this.supabase
      .from('test_users')
      .select('*')
      .eq('test_run_id', this.testRunId)
      .eq('role', role)
      .single();
      
    return data;
  }
}