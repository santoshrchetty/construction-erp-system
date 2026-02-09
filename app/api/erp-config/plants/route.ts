import { NextResponse } from 'next/server';
import { ERPConfigService } from '@/domains/administration/erpConfigService';

const erpConfigService = new ERPConfigService();

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const companyCode = searchParams.get('companyCode');
    
    const data = await erpConfigService.getPlants(companyCode || undefined);
    return NextResponse.json({ success: true, data });
  } catch (error: any) {
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}
