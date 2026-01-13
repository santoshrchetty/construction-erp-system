import { z } from 'zod';
import { ConstructionAction, ModuleCode } from './construction-authorization';

// Enhanced Tile with Construction Authorization
export const EnhancedTileSchema = z.object({
  id: z.string().uuid(),
  title: z.string(),
  subtitle: z.string(),
  icon: z.string(),
  color: z.string(),
  route: z.string(),
  module_code: z.nativeEnum(ModuleCode),
  tile_category: z.string(),
  construction_action: z.nativeEnum(ConstructionAction),
  auth_object: z.string().optional(),
  has_authorization: z.boolean(),
  sequence_order: z.number()
});

// Tile Category
export const TileCategorySchema = z.object({
  id: z.string().uuid(),
  category_name: z.string(),
  module_code: z.nativeEnum(ModuleCode),
  description: z.string(),
  icon: z.string(),
  color: z.string(),
  sequence_order: z.number()
});

// Tile Group (organized by category)
export const TileGroupSchema = z.object({
  category: z.infer<typeof TileCategorySchema>,
  tiles: z.array(EnhancedTileSchema)
});

export type EnhancedTile = z.infer<typeof EnhancedTileSchema>;
export type TileCategory = z.infer<typeof TileCategorySchema>;
export type TileGroup = z.infer<typeof TileGroupSchema>;

// Construction Action Icons
export const ACTION_ICONS = {
  [ConstructionAction.INITIATE]: 'plus-circle',
  [ConstructionAction.MODIFY]: 'edit-3',
  [ConstructionAction.REVIEW]: 'eye',
  [ConstructionAction.EXECUTE]: 'play-circle',
  [ConstructionAction.APPROVE]: 'check-circle',
  [ConstructionAction.ANALYZE]: 'bar-chart-3'
} as const;

// Construction Action Colors
export const ACTION_COLORS = {
  [ConstructionAction.INITIATE]: 'bg-green-500',
  [ConstructionAction.MODIFY]: 'bg-blue-500',
  [ConstructionAction.REVIEW]: 'bg-gray-500',
  [ConstructionAction.EXECUTE]: 'bg-emerald-500',
  [ConstructionAction.APPROVE]: 'bg-orange-500',
  [ConstructionAction.ANALYZE]: 'bg-purple-500'
} as const;

// Module Colors
export const MODULE_COLORS = {
  [ModuleCode.PS]: 'bg-blue-500',
  [ModuleCode.MM]: 'bg-orange-500',
  [ModuleCode.PP]: 'bg-violet-500',
  [ModuleCode.QM]: 'bg-red-500',
  [ModuleCode.FI]: 'bg-green-700',
  [ModuleCode.CO]: 'bg-purple-700',
  [ModuleCode.HR]: 'bg-indigo-600',
  [ModuleCode.WM]: 'bg-stone-600'
} as const;

// Helper functions
export function getTilesByModule(tiles: EnhancedTile[], moduleCode: ModuleCode): EnhancedTile[] {
  return tiles.filter(tile => tile.module_code === moduleCode);
}

export function getTilesByAction(tiles: EnhancedTile[], action: ConstructionAction): EnhancedTile[] {
  return tiles.filter(tile => tile.construction_action === action);
}

export function getAuthorizedTiles(tiles: EnhancedTile[]): EnhancedTile[] {
  return tiles.filter(tile => tile.has_authorization);
}

export function groupTilesByCategory(tiles: EnhancedTile[]): Record<string, EnhancedTile[]> {
  return tiles.reduce((groups, tile) => {
    const category = tile.tile_category;
    if (!groups[category]) {
      groups[category] = [];
    }
    groups[category].push(tile);
    return groups;
  }, {} as Record<string, EnhancedTile[]>);
}