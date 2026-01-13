import { NextRequest, NextResponse } from 'next/server'
import { withAuth, AuthContext } from '@/lib/authMiddleware'
import { getAuthorizedTiles } from '@/domains/tiles/tilesService'

async function tilesHandler(request: NextRequest, context: AuthContext) {
  const { user, profile, authorizedObjects, isAdmin } = context
  
  try {
    const tiles = await getAuthorizedTiles(authorizedObjects, isAdmin)

    return NextResponse.json({
      success: true,
      tiles,
      count: tiles.length,
      userRole: profile?.roles?.name || 'Employee',
      userId: user.id,
      sessionValid: true,
      profileLoaded: !!profile
    })

  } catch (error) {
    if (process.env.NODE_ENV === 'development') {
      console.error('API error:', error)
    }
    
    const errorResponse = process.env.NODE_ENV === 'development' 
      ? { 
          error: 'Internal server error',
          details: error instanceof Error ? error.message : 'Unknown error'
        }
      : { error: 'Internal server error' }
    
    return NextResponse.json(errorResponse, { status: 500 })
  }
}

export const GET = withAuth(tilesHandler)