import { NextResponse } from 'next/server';
import { ERPConfigService } from '@/domains/administration/erpConfigService';

const erpConfigService = new ERPConfigService();

export async function GET() {
  try {
    const data = await erpConfigService.getCompanies();
    return NextResponse.json({ success: true, data });
  } catch (error: any) {
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}
