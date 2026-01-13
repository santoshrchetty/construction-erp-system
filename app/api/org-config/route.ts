import { NextRequest, NextResponse } from 'next/server';
import { cookies } from 'next/headers';
import { createServerClient } from '@supabase/ssr';
import { withAuth } from '@/lib/withAuth';

// Layer 2: API Authentication & Route Handler
export async function GET(request: NextRequest) {
  return withAuth(async (user) => {
    try {
      // Layer 3: Business Logic - Organisation Configuration Data Retrieval
      const orgConfigData = await getOrganisationConfigurationData(user);
      
      return NextResponse.json({
        success: true,
        data: orgConfigData
      });
    } catch (error) {
      console.error('Organisation Configuration API Error:', error);
      return NextResponse.json(
        { success: false, error: 'Failed to fetch organisation configuration data' },
        { status: 500 }
      );
    }
  });
}

export async function POST(request: NextRequest) {
  return withAuth(async (user) => {
    try {
      const { action, objectType, data } = await request.json();
      
      // Layer 3: Business Logic - Organisation Configuration Operations
      let result;
      switch (action) {
        case 'create':
          result = await createOrganisationObject(user, objectType, data);
          break;
        case 'update':
          result = await updateOrganisationObject(user, objectType, data);
          break;
        case 'assign':
          result = await assignOrganisationObjects(user, data);
          break;
        default:
          throw new Error('Invalid action');
      }
      
      return NextResponse.json({
        success: true,
        data: result
      });
    } catch (error) {
      console.error('Organisation Configuration API Error:', error);
      return NextResponse.json(
        { success: false, error: error.message },
        { status: 500 }
      );
    }
  });
}

// Layer 3: Business Logic Functions
async function getOrganisationConfigurationData(user: any) {
  const cookieStore = await cookies();
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return cookieStore.get(name)?.value
        },
        set() {},
        remove() {}
      }
    }
  );
  
  // Layer 4: Data Access - Fetch all organizational data
  const [
    companyCodes,
    controllingAreas,
    costCenters,
    profitCenters,
    purchasingOrgs,
    plants,
    storageLocations,
    departments,
    currencies,
    countries,
    fiscalYearVariants
  ] = await Promise.all([
    supabase.from('company_codes').select('*').order('company_code'),
    supabase.from('controlling_areas').select('*').order('cocarea_code'),
    supabase.from('cost_centers').select('*').order('cost_center_code'),
    supabase.from('profit_centers').select('*').order('profit_center_code'),
    supabase.from('purchasing_organizations').select('*').order('porg_code'),
    supabase.from('plants').select('*').order('plant_code'),
    supabase.from('storage_locations').select('*').order('sloc_code'),
    supabase.from('departments').select('*').order('name'),
    supabase.from('currencies').select('*').order('currency_code'),
    supabase.from('countries').select('*').order('country_name'),
    supabase.from('fiscal_year_variants').select('*').order('variant_code')
  ]);
  
  return {
    companyCodes: companyCodes.data || [],
    controllingAreas: controllingAreas.data || [],
    costCenters: costCenters.data || [],
    profitCenters: profitCenters.data || [],
    purchasingOrgs: purchasingOrgs.data || [],
    plants: plants.data || [],
    storageLocations: storageLocations.data || [],
    departments: departments.data || [],
    currencies: currencies.data || [],
    countries: countries.data || [],
    fiscalYearVariants: fiscalYearVariants.data || []
  };
}

async function createOrganisationObject(user: any, objectType: string, data: any) {
  const cookieStore = await cookies();
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return cookieStore.get(name)?.value
        },
        set() {},
        remove() {}
      }
    }
  );
  
  const tableMap = {
    company: 'company_codes',
    plant: 'plants',
    cost_center: 'cost_centers',
    profit_center: 'profit_centers',
    storage: 'storage_locations',
    purchasing: 'purchasing_organizations',
    controlling: 'controlling_areas',
    department: 'departments'
  };
  
  const table = tableMap[objectType];
  if (!table) throw new Error('Invalid object type');
  
  const { data: result, error } = await supabase
    .from(table)
    .insert([{ ...data, is_active: true }])
    .select()
    .single();
  
  if (error) throw error;
  return result;
}

async function updateOrganisationObject(user: any, objectType: string, data: any) {
  const cookieStore = await cookies();
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return cookieStore.get(name)?.value
        },
        set() {},
        remove() {}
      }
    }
  );
  
  const tableMap = {
    company: 'company_codes',
    plant: 'plants',
    cost_center: 'cost_centers',
    profit_center: 'profit_centers',
    storage: 'storage_locations',
    purchasing: 'purchasing_organizations',
    controlling: 'controlling_areas',
    department: 'departments'
  };
  
  const table = tableMap[objectType];
  if (!table) throw new Error('Invalid object type');
  
  const { data: result, error } = await supabase
    .from(table)
    .update(data)
    .eq('id', data.id)
    .select()
    .single();
  
  if (error) throw error;
  return result;
}

async function assignOrganisationObjects(user: any, assignmentData: any) {
  const cookieStore = await cookies();
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return cookieStore.get(name)?.value
        },
        set() {},
        remove() {}
      }
    }
  );
  
  const { table, objectId, field, value, idField } = assignmentData;
  
  const { data: result, error } = await supabase
    .from(table)
    .update({ [field]: value })
    .eq(idField, objectId)
    .select()
    .single();
  
  if (error) throw error;
  return result;
}