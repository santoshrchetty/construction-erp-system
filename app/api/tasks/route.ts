import { NextRequest, NextResponse } from 'next/server';
import { createServiceClient } from '@/lib/supabase/server';

export async function GET(request: NextRequest) {
  try {
    const url = new URL(request.url);
    const projectId = url.searchParams.get('projectId');

    const supabase = await createServiceClient();
    
    let query = supabase
      .from('tasks')
      .select('*, activities(code, name)')
      .order('created_at', { ascending: false });

    if (projectId) {
      query = query.eq('project_id', projectId);
    }

    const { data, error } = await query;

    if (error) throw error;

    return NextResponse.json({ tasks: data });
  } catch (error) {
    console.error('Tasks API error:', error);
    return NextResponse.json({ error: 'Failed to fetch tasks' }, { status: 500 });
  }
}
