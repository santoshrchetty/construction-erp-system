import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const companyCode = searchParams.get('companyCode');
    
    let query = supabase
      .from('plants')
      .select('id, plant_code, plant_name, plant_type, company_code')
      .eq('is_active', true);
    
    if (companyCode) {
      query = query.eq('company_code', companyCode);
    }
    
    const { data, error } = await query.order('plant_code');

    if (error) throw error;

    return NextResponse.json({ success: true, data });
  } catch (error: any) {
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}
