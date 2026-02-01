import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

export async function GET(req: NextRequest) {
  const subdomain = req.headers.get('x-subdomain')
  
  if (!subdomain) {
    return NextResponse.json({ error: 'No subdomain provided' }, { status: 400 })
  }
  
  const { data: tenant, error } = await supabase
    .from('tenants')
    .select('id, tenant_code, tenant_name, subdomain')
    .eq('subdomain', subdomain)
    .eq('is_active', true)
    .single()
  
  if (error || !tenant) {
    return NextResponse.json({ error: 'Tenant not found' }, { status: 404 })
  }
  
  return NextResponse.json(tenant)
}
