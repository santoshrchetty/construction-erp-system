import { SupabaseClient } from '@supabase/supabase-js';
import { EnhancedTile, TileCategory, TileGroup } from '../enhanced-tiles';
import { ModuleCode, ConstructionAction } from '../construction-authorization';

export class EnhancedTileRepository {
  constructor(private supabase: SupabaseClient) {}

  // Get authorized tiles for user
  async getUserAuthorizedTiles(userId: string): Promise<EnhancedTile[]> {
    const { data, error } = await this.supabase
      .rpc('get_user_authorized_tiles', { p_user_id: userId });

    if (error) throw error;
    return data || [];
  }

  // Get tiles by module
  async getTilesByModule(userId: string, moduleCode: ModuleCode): Promise<EnhancedTile[]> {
    const allTiles = await this.getUserAuthorizedTiles(userId);
    return allTiles.filter(tile => 
      tile.module_code === moduleCode && tile.has_authorization
    );
  }

  // Get tiles by action
  async getTilesByAction(userId: string, action: ConstructionAction): Promise<EnhancedTile[]> {
    const allTiles = await this.getUserAuthorizedTiles(userId);
    return allTiles.filter(tile => 
      tile.construction_action === action && tile.has_authorization
    );
  }

  // Get tiles grouped by category
  async getTilesGroupedByCategory(userId: string): Promise<TileGroup[]> {
    const tiles = await this.getUserAuthorizedTiles(userId);
    const authorizedTiles = tiles.filter(tile => tile.has_authorization);
    
    // Get categories
    const { data: categories, error } = await this.supabase
      .from('tile_categories')
      .select('*')
      .order('sequence_order');

    if (error) throw error;

    // Group tiles by category
    const groups: TileGroup[] = [];
    for (const category of categories || []) {
      const categoryTiles = authorizedTiles.filter(
        tile => tile.tile_category === category.category_name
      );
      
      if (categoryTiles.length > 0) {
        groups.push({
          category,
          tiles: categoryTiles.sort((a, b) => a.sequence_order - b.sequence_order)
        });
      }
    }

    return groups;
  }

  // Get user's module access summary
  async getUserModuleAccess(userId: string): Promise<any[]> {
    const { data, error } = await this.supabase
      .rpc('get_user_module_access', { p_user_id: userId });

    if (error) throw error;
    return data || [];
  }

  // Get tile categories
  async getTileCategories(): Promise<TileCategory[]> {
    const { data, error } = await this.supabase
      .from('tile_categories')
      .select('*')
      .order('sequence_order');

    if (error) throw error;
    return data || [];
  }

  // Get dashboard summary for user
  async getDashboardSummary(userId: string): Promise<{
    totalTiles: number;
    moduleAccess: Record<string, number>;
    actionAccess: Record<string, number>;
    categories: string[];
  }> {
    const tiles = await this.getUserAuthorizedTiles(userId);
    const authorizedTiles = tiles.filter(tile => tile.has_authorization);

    // Count by module
    const moduleAccess = authorizedTiles.reduce((acc, tile) => {
      acc[tile.module_code] = (acc[tile.module_code] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    // Count by action
    const actionAccess = authorizedTiles.reduce((acc, tile) => {
      acc[tile.construction_action] = (acc[tile.construction_action] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    // Get unique categories
    const categories = [...new Set(authorizedTiles.map(tile => tile.tile_category))];

    return {
      totalTiles: authorizedTiles.length,
      moduleAccess,
      actionAccess,
      categories
    };
  }
}