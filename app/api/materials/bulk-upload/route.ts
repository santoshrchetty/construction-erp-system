import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'
import { withAuth } from '@/lib/authMiddleware'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

export const POST = withAuth(async (request: NextRequest, context) => {
  try {
    const { materials } = await request.json()
    
    if (!materials || !Array.isArray(materials)) {
      return NextResponse.json({ 
        success: false, 
        error: 'Invalid materials data' 
      }, { status: 400 })
    }

    const results = []
    let successful = 0
    let failed = 0

    for (const material of materials) {
      try {
        // Validate required fields
        if (!material.material_code || !material.material_name) {
          results.push({
            line: material.line,
            status: 'failed',
            error: 'Missing required fields: material_code or material_name'
          })
          failed++
          continue
        }

        // Check if material already exists
        const { data: existing } = await supabase
          .from('materials')
          .select('id')
          .eq('material_code', material.material_code)
          .single()

        if (existing) {
          results.push({
            line: material.line,
            status: 'failed',
            error: 'Material code already exists'
          })
          failed++
          continue
        }

        // Insert material master
        const materialData = {
          material_code: material.material_code,
          material_name: material.material_name,
          description: material.material_name,
          category: material.category,
          base_uom: material.base_uom,
          material_type: 'FERT',
          is_active: true,
          created_by: context.userId
        }

        const { data: newMaterial, error: materialError } = await supabase
          .from('materials')
          .insert(materialData)
          .select()
          .single()

        if (materialError) {
          results.push({
            line: material.line,
            status: 'failed',
            error: materialError.message
          })
          failed++
          continue
        }

        // If plant data provided, create plant extension
        if (material.plant_code && newMaterial) {
          const { data: plant } = await supabase
            .from('plants')
            .select('id')
            .eq('plant_code', material.plant_code)
            .single()

          if (plant) {
            const plantData = {
              material_id: newMaterial.id,
              plant_id: plant.id,
              plant_status: 'ACTIVE',
              reorder_level: material.reorder_level || 0,
              safety_stock: material.safety_stock || 0,
              standard_price: material.standard_price || 0,
              price_unit: 1,
              is_active: true
            }

            await supabase
              .from('material_plant_data')
              .insert(plantData)
          }

          // If storage location data provided, create storage data
          if (material.sloc_code) {
            const { data: sloc } = await supabase
              .from('storage_locations')
              .select('id')
              .eq('sloc_code', material.sloc_code)
              .eq('plant_id', plant?.id)
              .single()

            if (sloc) {
              const storageData = {
                material_id: newMaterial.id,
                storage_location_id: sloc.id,
                current_stock: material.current_stock || 0,
                reserved_stock: 0,
                available_stock: material.current_stock || 0,
                last_updated: new Date().toISOString()
              }

              await supabase
                .from('material_storage_data')
                .insert(storageData)
            }
          }
        }

        results.push({
          line: material.line,
          status: 'success',
          material_code: material.material_code
        })
        successful++

      } catch (error) {
        results.push({
          line: material.line,
          status: 'failed',
          error: error instanceof Error ? error.message : 'Unknown error'
        })
        failed++
      }
    }

    return NextResponse.json({
      success: true,
      data: {
        successful,
        failed,
        total: materials.length,
        results
      }
    })

  } catch (error) {
    return NextResponse.json({ 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }, { status: 500 })
  }
}, ['MATERIAL_MASTER_WRITE'])