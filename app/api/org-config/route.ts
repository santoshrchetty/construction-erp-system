import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/server'

export async function GET() {
  try {
    const supabase = await createServiceClient()
    
    const [companyCodes, controllingAreas, plants, costCenters, profitCenters, purchasingOrgs, storageLocations, departments] = await Promise.all([
      supabase.from('company_codes').select('*'),
      supabase.from('controlling_areas').select('*'),
      supabase.from('plants').select('*'),
      supabase.from('cost_centers').select('*'),
      supabase.from('profit_centers').select('*'),
      supabase.from('purchasing_organizations').select('*'),
      supabase.from('storage_locations').select('*'),
      supabase.from('departments').select('*')
    ])

    return NextResponse.json({
      success: true,
      data: {
        companyCodes: companyCodes.data || [],
        controllingAreas: controllingAreas.data || [],
        plants: plants.data || [],
        costCenters: costCenters.data || [],
        profitCenters: profitCenters.data || [],
        purchasingOrgs: purchasingOrgs.data || [],
        storageLocations: storageLocations.data || [],
        departments: departments.data || []
      }
    })
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}