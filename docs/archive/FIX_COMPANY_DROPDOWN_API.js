// Fix for GL Posting Company Dropdown - Updated API Route
// This replaces the incorrect organizational_hierarchy query with proper company_codes query

// BEFORE (Incorrect - in /app/api/tiles/route.ts):
/*
if (category === 'finance' && action === 'companies') {
  const { data, error } = await supabase
    .from('organizational_hierarchy')  // ❌ WRONG TABLE
    .select('company_code')
    .not('company_code', 'is', null)
    .order('company_code')

  const companies = [...new Set(data?.map(row => row.company_code))].map(code => ({
    code,
    name: code  // ❌ USING CODE AS NAME
  }))
}
*/

// AFTER (Correct - Replace the above code with this):
if (category === 'finance' && action === 'companies') {
  const { data, error } = await supabase
    .from('company_codes')  // ✅ CORRECT TABLE
    .select('company_code, company_name, is_active')
    .eq('is_active', true)
    .order('company_code')

  if (error) {
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 })
  }

  const companies = data?.map(company => ({
    code: company.company_code,
    name: `${company.company_code} - ${company.company_name}`  // ✅ PROPER DISPLAY
  })) || []

  return NextResponse.json({
    success: true,
    data: companies
  })
}

// Alternative: Use the new view for even better data
/*
if (category === 'finance' && action === 'companies') {
  const { data, error } = await supabase
    .from('v_companies_with_names')  // ✅ ENHANCED VIEW
    .select('code, name, employee_count')
    .order('code')

  if (error) {
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 })
  }

  const companies = data?.map(company => ({
    code: company.code,
    name: `${company.code} - ${company.name} (${company.employee_count} employees)`
  })) || []

  return NextResponse.json({
    success: true,
    data: companies
  })
}
*/