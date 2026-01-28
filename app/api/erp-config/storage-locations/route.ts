import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url);
    const plantCode = searchParams.get('plantCode');
    
    let query = supabase
      .from('storage_locations')
      .select('id, sloc_code, sloc_name, location_type, plant_code')
      .eq('is_active', true);
    
    if (plantCode) {
      query = query.eq('plant_code', plantCode);
    }
    
    const { data, error } = await query.order('sloc_code');

    if (error) throw error;

    return NextResponse.json({ success: true, data });
  } catch (error: any) {
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}
