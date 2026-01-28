import { NextRequest, NextResponse } from 'next/server'
import { getMaterialCategories, getMaterialGroups, getMaterialPlantData } from '@/domains/materials/materialMasterService'
import { createServiceClient } from '@/lib/supabase/server'

/**
 * Master data endpoint - Returns reference data for materials module
 * Requires authentication but no specific permission (read-only master data)
 */
export async function GET(request: NextRequest) {
  try {
    // Verify user is authenticated
    const supabase = await createServiceClient()
    const { data: { user }, error: authError } = await supabase.auth.getUser()

    if (authError || !user) {
      return NextResponse.json(
        { success: false, error: 'Unauthorized' },
        { status: 401 }
      )
    }

    const { searchParams } = new URL(request.url)
    const type = searchParams.get('type')
    const category = searchParams.get('category')
    const materialCode = searchParams.get('material_code')
    const plantCode = searchParams.get('plant_code')

    // Handle categories request
    if (type === 'categories') {
      try {
        const data = await getMaterialCategories()
        return NextResponse.json({
          success: true,
          data: data || []
        })
      } catch (err) {
        console.error('Error fetching material categories:', err instanceof Error ? err.message : err)
        return NextResponse.json({
          success: false,
          error: 'Failed to fetch categories',
          details: err instanceof Error ? err.message : String(err),
          data: []
        }, { status: 500 })
      }
    }

    // Handle groups request
    if (type === 'groups') {
      try {
        const data = await getMaterialGroups(category || undefined)
        return NextResponse.json({
          success: true,
          data: data || []
        })
      } catch (err) {
        console.error('Error fetching material groups:', err)
        return NextResponse.json({
          success: false,
          error: 'Failed to fetch groups',
          data: []
        }, { status: 500 })
      }
    }

    // Handle plant parameters request
    if (type === 'plant-parameters') {
      if (!materialCode) {
        return NextResponse.json({
          success: false,
          error: 'material_code parameter required for plant-parameters'
        }, { status: 400 })
      }
      try {
        const data = await getMaterialPlantData(materialCode, plantCode || undefined)
        return NextResponse.json({
          success: true,
          data: data || []
        })
      } catch (err) {
        console.error('Error fetching plant data:', err)
        return NextResponse.json({
          success: false,
          error: 'Failed to fetch plant parameters',
          data: []
        }, { status: 500 })
      }
    }

    // Handle materials types request
    if (type === 'material-types') {
      try {
        const { data, error } = await supabase
          .from('material_types')
          .select('*')
          .eq('is_active', true)
          .order('material_type_name')

        if (error) throw error
        return NextResponse.json({
          success: true,
          data: data || []
        })
      } catch (err) {
        console.error('Error fetching material types:', err)
        return NextResponse.json({
          success: false,
          error: 'Failed to fetch material types',
          data: []
        }, { status: 500 })
      }
    }

    // Handle valuation classes request
    if (type === 'valuation-classes') {
      try {
        const { data, error } = await supabase
          .from('valuation_classes')
          .select('*')
          .eq('is_active', true)
          .order('class_name')

        if (error) throw error
        return NextResponse.json({
          success: true,
          data: data || []
        })
      } catch (err) {
        console.error('Error fetching valuation classes:', err)
        return NextResponse.json({
          success: false,
          error: 'Failed to fetch valuation classes',
          data: []
        }, { status: 500 })
      }
    }

    return NextResponse.json({
      success: false,
      error: 'Invalid request parameters. Supported types: categories, groups, plant-parameters, material-types, valuation-classes'
    }, { status: 400 })

  } catch (error) {
    console.error('Master data request error:', error)
    return NextResponse.json({
      success: false,
      error: 'Master data request failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}