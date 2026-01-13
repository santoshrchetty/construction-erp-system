import { NextRequest, NextResponse } from 'next/server'
import { withAuth } from '@/lib/withAuth'
import { Module, Permission } from '@/lib/permissions/types'
import { getMaterialCategories, getMaterialGroups, getMaterialPlantData } from '@/domains/materials/materialMasterService'

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const type = searchParams.get('type')
    const category = searchParams.get('category')
    const materialCode = searchParams.get('material_code')
    const plantCode = searchParams.get('plant_code')
    
    const authContext = await withAuth(request, Module.MM, Permission.VIEW)
    
    if (type === 'categories') {
      const data = await getMaterialCategories()
      return NextResponse.json({
        success: true,
        data
      })
    }
    
    if (type === 'groups') {
      const data = await getMaterialGroups(category || undefined)
      return NextResponse.json({
        success: true,
        data
      })
    }
    
    if (type === 'plant-parameters' && materialCode) {
      const data = await getMaterialPlantData(materialCode, plantCode || undefined)
      return NextResponse.json({
        success: true,
        data
      })
    }
    
    return NextResponse.json({
      success: false,
      error: 'Invalid request parameters'
    }, { status: 400 })
    
  } catch (error) {
    if (error instanceof Error && (error.message === 'Unauthorized' || error.message === 'Forbidden')) {
      return NextResponse.json({ error: error.message }, { status: error.message === 'Unauthorized' ? 401 : 403 })
    }
    
    return NextResponse.json({
      error: 'Master data request failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}