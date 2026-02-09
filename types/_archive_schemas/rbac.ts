import { SupabaseClient } from '@supabase/supabase-js';
import { User, Tile, CreateUser, CreateTile, UserRole } from '../types/rbac';

export class RBACRepository {
  constructor(private supabase: SupabaseClient) {}

  // User management
  async createUser(data: CreateUser): Promise<User> {
    const { data: user, error } = await this.supabase
      .from('users')
      .insert(data)
      .select()
      .single();
    
    if (error) throw error;
    return user;
  }

  async getUsersByRole(role: UserRole): Promise<User[]> {
    const { data, error } = await this.supabase
      .from('users')
      .select('*')
      .eq('role', role)
      .eq('is_active', true);
    
    if (error) throw error;
    return data || [];
  }

  // Tile management
  async getTilesForUser(userRole: UserRole): Promise<Tile[]> {
    const { data, error } = await this.supabase
      .from('tiles')
      .select('*')
      .contains('roles', [userRole])
      .eq('is_active', true)
      .order('sequence_order');
    
    if (error) throw error;
    return data || [];
  }

  async createTile(data: CreateTile): Promise<Tile> {
    const { data: tile, error } = await this.supabase
      .from('tiles')
      .insert(data)
      .select()
      .single();
    
    if (error) throw error;
    return tile;
  }

  // Project access control
  async assignUserToProject(userId: string, projectId: string, role: UserRole): Promise<void> {
    const { error } = await this.supabase
      .from('user_projects')
      .insert({ user_id: userId, project_id: projectId, role });
    
    if (error) throw error;
  }

  async getUserProjects(userId: string): Promise<any[]> {
    const { data, error } = await this.supabase
      .from('user_projects')
      .select('*, projects(*)')
      .eq('user_id', userId);
    
    if (error) throw error;
    return data || [];
  }
}