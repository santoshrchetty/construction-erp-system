import { NextRequest, NextResponse } from 'next/server'
import { withAuth, AuthContext } from '@/lib/authMiddleware'

async function availableModulesHandler(request: NextRequest, context: AuthContext) {
  try {
    const { searchParams } = new URL(request.url)
    const roleName = searchParams.get('role')
    
    if (!roleName) {
      return NextResponse.json({ 
        success: false, 
        error: 'Role name is required' 
      }, { status: 400 })
    }

    const moduleData = await context.authService.getUserModules(roleName)

    return NextResponse.json({
      success: true,
      data: moduleData
    })
  } catch (error) {
    if (process.env.NODE_ENV === 'development') {
      console.error('Available modules API error:', error)
    }
    return NextResponse.json({ 
      success: false, 
      error: 'Failed to fetch modules' 
    }, { status: 500 })
  }
}

export const GET = withAuth(availableModulesHandler)