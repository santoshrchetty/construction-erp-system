import { NextRequest, NextResponse } from 'next/server'
import { withAuth } from '@/lib/withAuth'
import { Module, Permission } from '@/lib/permissions/types'
import { createServerClient } from '@supabase/ssr'
import { getStockOverview } from '@/domains/materials/materialServices'
import { withMediumRiskRecovery, withHighRiskRecovery } from '@/lib/errorRecovery'

// Protected GET with auto-backup
export const GET = withMediumRiskRecovery(async (request: NextRequest) => {
  try {
    const { searchParams } = new URL(request.url)
    const category = searchParams.get('category')
    const action = searchParams.get('action')
    const companyCode = searchParams.get('company_code')
    const search = searchParams.get('search')
    const accountType = searchParams.get('account_type')
    
    // Add RBAC check for tile access
    const authContext = await withAuth(request, Module.COSTING, Permission.VIEW)
    
    // Handle Materials Stock Overview
    if (category === 'materials' && action === 'stock-overview') {
      const { getStockOverviewERP } = await import('@/domains/materials/materialMasterService')
      
      const filters = {
        material_category: searchParams.get('material_category'),
        stock_status: searchParams.get('stock_status')
      }
      
      const data = await getStockOverviewERP(companyCode, filters)
      
      return NextResponse.json({
        success: true,
        data: data
      })
    }
    
    // Handle Material Plant Parameters
    if (category === 'materials' && action === 'plant-parameters') {
      const { getMaterialPlantData } = await import('@/domains/materials/materialMasterService')
      
      const materialCode = searchParams.get('material_code')
      const plantCode = searchParams.get('plant_code')
      
      if (!materialCode) {
        return NextResponse.json({
          success: false,
          error: 'Material code required'
        }, { status: 400 })
      }
      
      const data = await getMaterialPlantData(materialCode, plantCode || undefined)
      
      return NextResponse.json({
        success: true,
        data
      })
    }
    
    // Handle Material Master Display
    if (category === 'materials' && action === 'material-master') {
      const { getMaterialMaster } = await import('@/domains/materials/materialMasterService')
      
      // Get additional search parameters
      const materialCategory = searchParams.get('material_category')
      const materialType = searchParams.get('material_type')
      
      const data = await getMaterialMaster(undefined, search || undefined, {
        category: materialCategory,
        material_type: materialType
      })
      
      return NextResponse.json({
        success: true,
        data: { materials: data }
      })
    }
    
    // Handle Chart of Accounts - FIXED: Should use Service layer
    if (category === 'finance' && action === 'chart_of_accounts') {
      // TODO: Create FinanceService to handle chart of accounts
      // For now, keeping direct Supabase call as temporary solution
      const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        {
          cookies: {
            get(name: string) {
              return request.cookies.get(name)?.value
            },
            set() {},
            remove() {}
          }
        }
      )

      let query = supabase
        .from('chart_of_accounts')
        .select('*')
        .eq('company_code', companyCode)
        .order('account_code')

      // Apply search filter
      if (search) {
        query = query.or(`account_code.ilike.%${search}%,account_name.ilike.%${search}%`)
      }

      // Apply account type filter
      if (accountType && accountType !== 'ALL') {
        query = query.eq('account_type', accountType)
      }

      const { data: accounts, error } = await query

      if (error) {
        return NextResponse.json({
          success: false,
          error: error.message
        }, { status: 500 })
      }

      // Group accounts by type for grouped view
      const grouped = (accounts || []).reduce((acc, account) => {
        if (!acc[account.account_type]) {
          acc[account.account_type] = []
        }
        acc[account.account_type].push(account)
        return acc
      }, {} as Record<string, typeof accounts>)

      return NextResponse.json({
        success: true,
        data: {
          accounts: accounts || [],
          grouped: grouped
        }
      })
    }
    
    // Handle Companies from company_codes table
    if (category === 'finance' && action === 'companies') {
      const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        {
          cookies: {
            get(name: string) {
              return request.cookies.get(name)?.value
            },
            set() {},
            remove() {}
          }
        }
      )

      const { data, error } = await supabase
        .from('company_codes')
        .select('company_code, company_name, is_active')
        .eq('is_active', true)
        .order('company_code')

      if (error) {
        return NextResponse.json({
          success: false,
          error: error.message
        }, { status: 500 })
      }

      const companies = data?.map(company => ({
        code: company.company_code,
        name: `${company.company_code} - ${company.company_name}`
      })) || []

      return NextResponse.json({
        success: true,
        data: companies
      })
    }
    
    // Handle Organisation Configuration
    if (category === 'organisation' && action === 'organisation-config') {
      const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        {
          cookies: {
            get(name: string) {
              return request.cookies.get(name)?.value
            },
            set() {},
            remove() {}
          }
        }
      )

      const [
        companyCodes,
        controllingAreas,
        plants,
        costCenters,
        profitCenters,
        purchasingOrgs,
        storageLocations,
        departments
      ] = await Promise.all([
        supabase.from('company_codes').select('*').order('company_code'),
        supabase.from('controlling_areas').select('*').order('cocarea_code'),
        supabase.from('plants').select('*').order('plant_code'),
        supabase.from('cost_centers').select('*').order('cost_center_code'),
        supabase.from('profit_centers').select('*').order('profit_center_code'),
        supabase.from('purchasing_organizations').select('*').order('porg_code'),
        supabase.from('storage_locations').select('*').order('sloc_code'),
        supabase.from('departments').select('*').order('name')
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
    }
    
    return NextResponse.json({
      success: true,
      category,
      action,
      userRole: authContext.userRole,
      data: { message: `${category}/${action} functionality available` }
    })

  } catch (error) {
    if (error instanceof Error && (error.message === 'Unauthorized' || error.message === 'Forbidden')) {
      return NextResponse.json({ error: error.message }, { status: error.message === 'Unauthorized' ? 401 : 403 })
    }
    
    return NextResponse.json({
      error: 'Tile execution failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
})

// Protected POST with auto-backup and rollback
export const POST = withHighRiskRecovery(async (request: NextRequest) => {
  try {
    const { searchParams } = new URL(request.url)
    const category = searchParams.get('category')
    const action = searchParams.get('action')
    
    console.log('POST request - category:', category, 'action:', action) // Debug log
    
    const authContext = await withAuth(request, Module.COSTING, Permission.CREATE)
    const body = await request.json()
    
    console.log('POST request body:', body) // Debug log
    
    if (category === 'finance' && action === 'chart_of_accounts') {
      // TODO: Create FinanceService to handle chart of accounts operations
      // For now, keeping direct Supabase call as temporary solution
      const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        {
          cookies: {
            get(name: string) {
              return request.cookies.get(name)?.value
            },
            set() {},
            remove() {}
          }
        }
      )

      const { data, error } = await supabase
        .from('chart_of_accounts')
        .insert([body])
        .select()
        .single()

      if (error) {
        return NextResponse.json({
          success: false,
          error: error.message
        }, { status: 500 })
      }

      return NextResponse.json({
        success: true,
        data: { account: data }
      })
    }
    
    // Handle Approval Configuration - FIXED: Only call Service layer
    if (category === 'approval' && action === 'configuration') {
      const { ApprovalService } = await import('@/domains/approval/ApprovalService')
      
      if (body.action === 'get-field-definitions') {
        const result = await ApprovalService.getFieldDefinitions(body.customer_id)
        return NextResponse.json(result)
      }
      
      if (body.action === 'get-document-types') {
        const result = await ApprovalService.getDocumentTypes(body.customer_id)
        return NextResponse.json(result)
      }
      
      if (body.action === 'create-policy') {
        const result = await ApprovalService.createPolicy(body.policy)
        return NextResponse.json(result)
      }
      
      if (body.action === 'get-policies') {
        const result = await ApprovalService.getApprovalPoliciesPaginated(body.filters)
        return NextResponse.json(result)
      }
      
      if (body.action === 'get-approvers') {
        const result = await ApprovalService.getApprovers(body.filters)
        return NextResponse.json(result)
      }
      
      if (body.action === 'generate-flow') {
        const result = await ApprovalService.generateUniversalFlow(body.request)
        return NextResponse.json(result)
      }
    }
    
    // Handle Chart of Accounts Operations
    if (body.action === 'copyChartOfAccounts' || (category === 'finance' && action === 'copy_chart') || body.action === 'copy_chart') {
      const { FinanceService } = await import('@/domains/finance/FinanceService')
      const financeService = new FinanceService()
      
      const result = await financeService.copyChartOfAccounts(
        body.source_company,
        body.target_company
      )
      
      return NextResponse.json({
        success: true,
        data: {
          count: result.count,
          recordsCopied: result.count
        }
      })
    }
    
    // Handle Finance Master Data requests
    if (category === 'finance') {
      const { FinanceService } = await import('@/domains/finance/FinanceService')
      const financeService = new FinanceService()
      
      if (action === 'cost_centers') {
        const data = await financeService.getCostCenters(body.company_code)
        return NextResponse.json({ success: true, data })
      }
      
      if (action === 'wbs_elements') {
        const data = await financeService.getWBSElements(body.company_code)
        return NextResponse.json({ success: true, data })
      }
      
      if (action === 'profit_centers') {
        const data = await financeService.getProfitCenters(body.company_code)
        return NextResponse.json({ success: true, data })
      }
      
      if (action === 'companies') {
        const data = await financeService.getCompanies()
        return NextResponse.json({ success: true, data })
      }
    }
    
    // Handle Material Master Operations
    if (body.category === 'materials') {
      const { createMaterialMaster, getMaterialMaster, updateMaterialMaster, extendMaterialToPlant } = await import('@/domains/materials/materialMasterService')
      const { unifiedMaterialRequestService } = await import('@/domains/materials/unifiedMaterialRequestService')

      // Unified Material Request handlers
      if (body.action === 'unified-material-request') {
        const data = await unifiedMaterialRequestService.createMaterialRequest(body.payload, authContext.userId)
        return NextResponse.json(data)
      }

      if (body.action === 'material-request-list') {
        const data = await unifiedMaterialRequestService.getMaterialRequests(body.payload || {})
        return NextResponse.json(data)
      }

      if (body.action === 'approve-material-request') {
        const data = await unifiedMaterialRequestService.updateRequestStatus(
          body.payload.request_id,
          body.payload.status,
          authContext.userId,
          body.payload.comments
        )
        return NextResponse.json(data)
      }

      // Flexible Approval System handlers
      if (body.action === 'get-approval-templates') {
        const { flexibleApprovalService } = await import('@/domains/materials/flexibleApprovalService')
        const data = await flexibleApprovalService.getApprovalTemplates(body.payload?.customer_type, body.payload?.industry_type)
        return NextResponse.json(data)
      }

      if (body.action === 'apply-approval-template') {
        const { flexibleApprovalService } = await import('@/domains/materials/flexibleApprovalService')
        const data = await flexibleApprovalService.applyApprovalTemplate(
          body.payload.customer_id,
          body.payload.document_type,
          body.payload.template_id,
          body.payload.config_name
        )
        return NextResponse.json(data)
      }

      if (body.action === 'get-approval-levels') {
        const { flexibleApprovalService } = await import('@/domains/materials/flexibleApprovalService')
        const data = await flexibleApprovalService.getCustomerApprovalLevels(
          body.payload.customer_id,
          body.payload.document_type
        )
        return NextResponse.json(data)
      }

      if (body.action === 'create-approval-level') {
        const { flexibleApprovalService } = await import('@/domains/materials/flexibleApprovalService')
        const data = await flexibleApprovalService.createCustomApprovalLevel(
          body.payload.customer_id,
          body.payload.document_type,
          body.payload.level_data
        )
        return NextResponse.json(data)
      }

      if (body.action === 'get-approval-path') {
        const { flexibleApprovalService } = await import('@/domains/materials/flexibleApprovalService')
        const data = await flexibleApprovalService.getApprovalPath(
          body.payload.customer_id,
          body.payload.document_type,
          body.payload.amount,
          body.payload.category,
          body.payload.department
        )
        return NextResponse.json(data)
      }

      if (body.action === 'create-material') {
        const data = await createMaterialMaster(body.payload, authContext.userId)
        
        return NextResponse.json({
          success: true,
          data: { material: data }
        })
      }

      if (body.action === 'maintain-material') {
        console.log('Maintain material request:', body.payload) // Debug log
        
        if (body.payload.material_id && !body.payload.material_name) {
          // Search for material
          console.log('Searching for material:', body.payload.material_id) // Debug log
          const materials = await getMaterialMaster(body.payload.material_id)
          console.log('Materials found:', materials) // Debug log
          const material = materials[0]
          
          if (!material) {
            console.log('Material not found in database') // Debug log
            return NextResponse.json({
              success: false,
              error: 'Material not found'
            }, { status: 404 })
          }

          return NextResponse.json({
            success: true,
            data: { material }
          })
        } else {
          // Update material
          const data = await updateMaterialMaster(
            body.payload.material_id,
            {
              material_name: body.payload.material_name,
              description: body.payload.description
            },
            authContext.userId
          )

          return NextResponse.json({
            success: true,
            data: { material: data }
          })
        }
      }

      if (body.action === 'extend-to-plant') {
        // Get material and plant IDs first
        const supabase = createServerClient(
          process.env.NEXT_PUBLIC_SUPABASE_URL!,
          process.env.SUPABASE_SERVICE_ROLE_KEY!,
          {
            cookies: {
              get(name: string) {
                return request.cookies.get(name)?.value
              },
              set() {},
              remove() {}
            }
          }
        )
        
        const { data: material } = await supabase
          .from('materials')
          .select('id')
          .eq('material_code', body.payload.material_code)
          .single()
          
        const { data: plant } = await supabase
          .from('plants')
          .select('id')
          .eq('plant_code', body.payload.plant_code)
          .single()
          
        if (!material || !plant) {
          return NextResponse.json({
            success: false,
            error: 'Material or Plant not found'
          }, { status: 404 })
        }
        
        const extendData = {
          ...body.payload,
          material_id: material.id,
          plant_id: plant.id,
          plant_status: 'ACTIVE',
          is_active: true
        }
        
        const data = await extendMaterialToPlant(extendData, authContext.userId)
        
        return NextResponse.json({
          success: true,
          data: { extension: data }
        })
      }
    }
    
    return NextResponse.json({
      success: true,
      data: { message: 'Created successfully' }
    })
  } catch (error) {
    return NextResponse.json({
      error: 'Creation failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
})

export async function PUT(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const category = searchParams.get('category')
    const action = searchParams.get('action')
    const id = searchParams.get('id')
    
    const authContext = await withAuth(request, Module.COSTING, Permission.EDIT)
    const body = await request.json()
    
    if (category === 'finance' && action === 'chart_of_accounts' && id) {
      const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.SUPABASE_SERVICE_ROLE_KEY!,
        {
          cookies: {
            get(name: string) {
              return request.cookies.get(name)?.value
            },
            set() {},
            remove() {}
          }
        }
      )

      const { data, error } = await supabase
        .from('chart_of_accounts')
        .update(body)
        .eq('id', id)
        .select()
        .single()

      if (error) {
        return NextResponse.json({
          success: false,
          error: error.message
        }, { status: 500 })
      }

      return NextResponse.json({
        success: true,
        data: { account: data }
      })
    }
    
    return NextResponse.json({
      success: true,
      data: { message: 'Updated successfully' }
    })
  } catch (error) {
    return NextResponse.json({
      error: 'Update failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const category = searchParams.get('category')
    const action = searchParams.get('action')
    const id = searchParams.get('id')
    
    const authContext = await withAuth(request, Module.COSTING, Permission.DELETE)
    
    if (category === 'finance' && action === 'chart_of_accounts' && id) {
      const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.SUPABASE_SERVICE_ROLE_KEY!,
        {
          cookies: {
            get(name: string) {
              return request.cookies.get(name)?.value
            },
            set() {},
            remove() {}
          }
        }
      )

      const { error } = await supabase
        .from('chart_of_accounts')
        .delete()
        .eq('id', id)

      if (error) {
        return NextResponse.json({
          success: false,
          error: error.message
        }, { status: 500 })
      }

      return NextResponse.json({
        success: true,
        data: { message: `Account deleted successfully` }
      })
    }
    
    return NextResponse.json({
      success: true,
      data: { message: 'Deleted successfully' }
    })
  } catch (error) {
    return NextResponse.json({
      error: 'Deletion failed',
      details: error instanceof Error ? error.message : 'Unknown error'
    }, { status: 500 })
  }
}