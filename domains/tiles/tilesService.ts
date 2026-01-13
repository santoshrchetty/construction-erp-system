import { createServiceClient } from '@/lib/supabase/server'

export interface TileData {
  id: string
  title: string
  auth_object: string
  tile_category: string
  is_active: boolean
  has_authorization?: boolean
}

export async function getAuthorizedTiles(authorizedObjects: Set<string>, isAdmin: boolean): Promise<TileData[]> {
  const supabase = await createServiceClient()
  
  if (isAdmin) {
    const { data, error } = await supabase
      .from('tiles')
      .select('*')
      .eq('is_active', true)
      .order('tile_category')
    
    if (error) throw error
    return (data || []).map(tile => ({ ...tile, has_authorization: true }))
  }
  
  const { data, error } = await supabase
    .from('tiles')
    .select('*')
    .eq('is_active', true)
    .in('auth_object', Array.from(authorizedObjects))
    .order('tile_category')
  
  if (error) throw error
  return (data || []).map(tile => ({ ...tile, has_authorization: true }))
}