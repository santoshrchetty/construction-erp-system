import { NextRequest, NextResponse } from 'next/server';
import { createServiceClient } from '@/lib/supabase/server';

export async function GET(request: NextRequest) {
  try {
    const url = new URL(request.url);
    const projectId = url.searchParams.get('projectId');

    const supabase = await createServiceClient();
    
    let query = supabase
      .from('activities')
      .select('*, wbs_nodes(code, name)')
      .order('code');

    if (projectId) {
      query = query.eq('project_id', projectId);
    }

    const { data, error } = await query;

    if (error) throw error;

    return NextResponse.json({ activities: data });
  } catch (error) {
    console.error('Activities API error:', error);
    return NextResponse.json({ error: 'Failed to fetch activities' }, { status: 500 });
  }
}
