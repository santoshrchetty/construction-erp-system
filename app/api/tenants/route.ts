import { NextRequest, NextResponse } from 'next/server';
import { TenantService } from '@/lib/tenant-service';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const tenantCode = searchParams.get('code');
    const tenantId = searchParams.get('id');
    
    if (tenantCode) {
      // Get specific tenant by code
      const tenant = await TenantService.getTenantByCode(tenantCode);
      if (!tenant) {
        return NextResponse.json(
          { error: 'Tenant not found' },
          { status: 404 }
        );
      }
      return NextResponse.json(tenant);
    }
    
    if (tenantId) {
      // Get companies for specific tenant
      const companies = await TenantService.getTenantCompanies(tenantId);
      return NextResponse.json(companies);
    }
    
    // Get all tenants
    const tenants = await TenantService.getAllTenants();
    return NextResponse.json(tenants);
    
  } catch (error) {
    console.error('Error in tenants GET:', error);
    return NextResponse.json(
      { error: 'Failed to fetch tenants' },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { tenant_code, tenant_name } = body;
    
    if (!tenant_code || !tenant_name) {
      return NextResponse.json(
        { error: 'Tenant code and name are required' },
        { status: 400 }
      );
    }
    
    const tenantId = await TenantService.createTenant(tenant_code, tenant_name);
    
    return NextResponse.json(
      { id: tenantId, message: 'Tenant created successfully' },
      { status: 201 }
    );
    
  } catch (error) {
    console.error('Error in tenants POST:', error);
    return NextResponse.json(
      { error: 'Failed to create tenant' },
      { status: 500 }
    );
  }
}

export async function PUT(request: NextRequest) {
  try {
    const { tenantId, companyCode } = await TenantService.validateRequestTenant(
      request.headers
    );
    
    const body = await request.json();
    const { action } = body;
    
    if (action === 'validate') {
      // Validate tenant-company combination
      const isValid = await TenantService.validateTenantCompany(tenantId, companyCode);
      return NextResponse.json({ valid: isValid });
    }
    
    return NextResponse.json(
      { error: 'Invalid action' },
      { status: 400 }
    );
    
  } catch (error) {
    console.error('Error in tenants PUT:', error);
    return NextResponse.json(
      { error: 'Failed to process request' },
      { status: 500 }
    );
  }
}