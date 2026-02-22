import { NextRequest, NextResponse } from 'next/server'
import { accountAssignmentService } from '@/domains/administration/accountAssignmentService'
import { ERPConfigService } from '@/domains/administration/erpConfigService'

const erpConfigService = new ERPConfigService()

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const mrType = searchParams.get('mrType')
    const action = searchParams.get('action')

    if (action === 'types') {
      const types = await erpConfigService.getAccountAssignmentTypes()
      return NextResponse.json({ success: true, data: types })
    }

    if (action === 'mrTypes') {
      const mrTypes = [
        { code: 'PROJECT', name: 'Project Materials' },
        { code: 'MAINTENANCE', name: 'Maintenance' },
        { code: 'GENERAL', name: 'General Supplies' },
        { code: 'ASSET', name: 'Asset Purchase' },
        { code: 'OFFICE', name: 'Office Supplies' },
        { code: 'SAFETY', name: 'Safety Equipment' },
        { code: 'EQUIPMENT', name: 'Equipment' },
        { code: 'PRODUCTION', name: 'Production Order' },
        { code: 'QUALITY', name: 'Quality Order' }
      ]
      return NextResponse.json({ success: true, data: mrTypes })
    }

    if (mrType) {
      const allowed = await erpConfigService.getAllowedAccountAssignments(mrType)
      return NextResponse.json({ success: true, data: allowed })
    }

    const types = await erpConfigService.getAccountAssignmentTypes()
    return NextResponse.json({ success: true, data: types })

  } catch (error) {
    console.error('Account assignment API error:', error)
    return NextResponse.json(
      { success: false, message: error instanceof Error ? error.message : 'Unknown error' },
      { status: 500 }
    )
  }
}
