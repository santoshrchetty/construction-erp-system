import { createServiceClient } from '@/lib/supabase/server'

type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE'

export async function handleExternalAccess(action: string, params: any, method: HttpMethod) {
  const supabase = await createServiceClient()

  switch (action) {
    // ==================== ORGANIZATIONS ====================
    case 'list-organizations':
      return listOrganizations(supabase, params)
    case 'get-organization':
      return getOrganization(supabase, params)
    case 'create-organization':
      return createOrganization(supabase, params)
    case 'update-organization':
      return updateOrganization(supabase, params)
    case 'deactivate-organization':
      return deactivateOrganization(supabase, params)

    // ==================== ORGANIZATION USERS ====================
    case 'list-org-users':
      return listOrgUsers(supabase, params)
    case 'invite-user':
      return inviteUser(supabase, params)
    case 'activate-user':
      return activateUser(supabase, params)
    case 'deactivate-user':
      return deactivateUser(supabase, params)

    // ==================== RESOURCE ACCESS ====================
    case 'list-resource-access':
      return listResourceAccess(supabase, params)
    case 'grant-access':
      return grantAccess(supabase, params)
    case 'revoke-access':
      return revokeAccess(supabase, params)
    case 'update-access':
      return updateAccess(supabase, params)

    // ==================== DRAWINGS ====================
    case 'list-drawings':
      return listDrawings(supabase, params)
    case 'get-drawing':
      return getDrawing(supabase, params)
    case 'release-drawing':
      return releaseDrawing(supabase, params)

    // ==================== FACILITIES ====================
    case 'list-facilities':
      return listFacilities(supabase, params)
    case 'get-facility':
      return getFacility(supabase, params)

    // ==================== EQUIPMENT ====================
    case 'list-equipment':
      return listEquipment(supabase, params)
    case 'get-equipment':
      return getEquipment(supabase, params)

    // ==================== APPROVALS ====================
    case 'submit-approval':
      return submitApproval(supabase, params)
    case 'list-approvals':
      return listApprovals(supabase, params)

    // ==================== VENDOR PROGRESS ====================
    case 'submit-progress':
      return submitProgress(supabase, params)
    case 'list-progress':
      return listProgress(supabase, params)

    // ==================== FIELD SERVICE ====================
    case 'create-ticket':
      return createTicket(supabase, params)
    case 'list-tickets':
      return listTickets(supabase, params)
    case 'update-ticket':
      return updateTicket(supabase, params)

    default:
      throw new Error(`Unknown action: ${action}`)
  }
}

// ==================== ORGANIZATIONS ====================

async function listOrganizations(supabase: any, params: any) {
  const { tenant_id, is_internal } = params
  
  let query = supabase
    .from('external_organizations')
    .select('*')
    .order('org_name')

  if (tenant_id) query = query.eq('tenant_id', tenant_id)
  if (is_internal !== undefined) query = query.eq('is_internal', is_internal)

  const { data, error } = await query
  if (error) throw error
  return data
}

async function getOrganization(supabase: any, params: any) {
  const { external_org_id } = params
  
  const { data, error } = await supabase
    .from('external_organizations')
    .select('*')
    .eq('external_org_id', external_org_id)
    .single()

  if (error) throw error
  return data
}

async function createOrganization(supabase: any, params: any) {
  const { tenant_id, name, org_type, is_internal, contact_email, contact_phone, address } = params
  
  const { data, error } = await supabase
    .from('external_organizations')
    .insert({
      tenant_id,
      org_code: org_type || 'EXT',
      org_name: name,
      is_internal: is_internal || false
    })
    .select()
    .single()

  if (error) throw error
  return data
}

async function updateOrganization(supabase: any, params: any) {
  const { external_org_id, name, ...updates } = params
  
  const updateData: any = { ...updates }
  if (name) updateData.org_name = name
  
  const { data, error } = await supabase
    .from('external_organizations')
    .update(updateData)
    .eq('external_org_id', external_org_id)
    .select()
    .single()

  if (error) throw error
  return data
}

async function deactivateOrganization(supabase: any, params: any) {
  const { external_org_id } = params
  
  const { data, error } = await supabase
    .from('external_organizations')
    .update({ is_active: false })
    .eq('external_org_id', external_org_id)
    .select()
    .single()

  if (error) throw error
  return data
}

// ==================== ORGANIZATION USERS ====================

async function listOrgUsers(supabase: any, params: any) {
  const { external_org_id } = params
  
  const { data, error } = await supabase
    .from('external_org_users')
    .select('*')
    .eq('external_org_id', external_org_id)
    .order('created_at', { ascending: false })

  if (error) throw error
  return data
}

async function inviteUser(supabase: any, params: any) {
  const { email, external_org_id, role, invited_by } = params
  
  // Create user invitation (simplified - actual implementation would send email)
  const { data: user, error: userError } = await supabase
    .from('users')
    .insert({ email, is_external: true })
    .select()
    .single()

  if (userError) throw userError

  const { data, error } = await supabase
    .from('external_org_users')
    .insert({
      external_org_id,
      user_id: user.id,
      role,
      invited_by,
      is_active: false // Activated when user accepts invitation
    })
    .select()
    .single()

  if (error) throw error
  return { user, org_user: data }
}

async function activateUser(supabase: any, params: any) {
  const { org_user_id } = params
  
  const { data, error } = await supabase
    .from('external_org_users')
    .update({ is_active: true })
    .eq('org_user_id', org_user_id)
    .select()
    .single()

  if (error) throw error
  return data
}

async function deactivateUser(supabase: any, params: any) {
  const { org_user_id } = params
  
  const { data, error } = await supabase
    .from('external_org_users')
    .update({ is_active: false })
    .eq('org_user_id', org_user_id)
    .select()
    .single()

  if (error) throw error
  return data
}

// ==================== RESOURCE ACCESS ====================

async function listResourceAccess(supabase: any, params: any) {
  const { external_org_id, resource_type, resource_id } = params
  
  let query = supabase
    .from('resource_access')
    .select('*')
    .order('created_at', { ascending: false })

  if (external_org_id) query = query.eq('external_org_id', external_org_id)
  if (resource_type) query = query.eq('resource_type', resource_type)
  if (resource_id) query = query.eq('resource_id', resource_id)

  const { data, error } = await query
  if (error) throw error
  return data
}

async function grantAccess(supabase: any, params: any) {
  const { data, error } = await supabase
    .from('resource_access')
    .insert(params)
    .select()
    .single()

  if (error) throw error
  return data
}

async function revokeAccess(supabase: any, params: any) {
  const { access_id } = params
  
  const { data, error } = await supabase
    .from('resource_access')
    .update({ is_active: false })
    .eq('access_id', access_id)
    .select()
    .single()

  if (error) throw error
  return data
}

async function updateAccess(supabase: any, params: any) {
  const { access_id, ...updates } = params
  
  const { data, error } = await supabase
    .from('resource_access')
    .update(updates)
    .eq('access_id', access_id)
    .select()
    .single()

  if (error) throw error
  return data
}

// ==================== DRAWINGS ====================

async function listDrawings(supabase: any, params: any) {
  const { project_id, drawing_category } = params
  
  let query = supabase
    .from('drawings')
    .select('*')
    .order('drawing_number')

  if (project_id) query = query.eq('project_id', project_id)
  if (drawing_category) query = query.eq('drawing_category', drawing_category)

  const { data, error } = await query
  if (error) throw error
  return data
}

async function getDrawing(supabase: any, params: any) {
  const { id } = params
  
  const { data, error } = await supabase
    .from('drawings')
    .select('*')
    .eq('id', id)
    .single()

  if (error) throw error
  return data
}

async function releaseDrawing(supabase: any, params: any) {
  const { id, released_by } = params
  
  const { data, error } = await supabase
    .from('drawings')
    .update({ 
      is_released: true,
      released_date: new Date().toISOString(),
      released_by
    })
    .eq('id', id)
    .select()
    .single()

  if (error) throw error
  return data
}

// ==================== FACILITIES ====================

async function listFacilities(supabase: any, params: any) {
  const { project_id } = params
  
  let query = supabase
    .from('facilities')
    .select('*')
    .order('facility_code')

  if (project_id) query = query.eq('project_id', project_id)

  const { data, error } = await query
  if (error) throw error
  return data
}

async function getFacility(supabase: any, params: any) {
  const { facility_id } = params
  
  const { data, error } = await supabase
    .from('facilities')
    .select('*')
    .eq('facility_id', facility_id)
    .single()

  if (error) throw error
  return data
}

// ==================== EQUIPMENT ====================

async function listEquipment(supabase: any, params: any) {
  const { facility_id, project_id } = params
  
  let query = supabase
    .from('equipment_register')
    .select('*')
    .order('tag_number')

  if (facility_id) query = query.eq('facility_id', facility_id)
  if (project_id) query = query.eq('project_id', project_id)

  const { data, error } = await query
  if (error) throw error
  return data
}

async function getEquipment(supabase: any, params: any) {
  const { equipment_id } = params
  
  const { data, error } = await supabase
    .from('equipment_register')
    .select('*')
    .eq('equipment_id', equipment_id)
    .single()

  if (error) throw error
  return data
}

// ==================== APPROVALS ====================

async function submitApproval(supabase: any, params: any) {
  const { data, error } = await supabase
    .from('drawing_customer_approvals')
    .insert(params)
    .select()
    .single()

  if (error) throw error
  return data
}

async function listApprovals(supabase: any, params: any) {
  const { drawing_id, external_org_id } = params
  
  let query = supabase
    .from('drawing_customer_approvals')
    .select('*')
    .order('created_at', { ascending: false })

  if (drawing_id) query = query.eq('drawing_id', drawing_id)
  if (external_org_id) query = query.eq('external_org_id', external_org_id)

  const { data, error } = await query
  if (error) throw error
  return data
}

// ==================== VENDOR PROGRESS ====================

async function submitProgress(supabase: any, params: any) {
  const { data, error } = await supabase
    .from('vendor_progress_updates')
    .insert(params)
    .select()
    .single()

  if (error) throw error
  return data
}

async function listProgress(supabase: any, params: any) {
  const { drawing_id, external_org_id } = params
  
  let query = supabase
    .from('vendor_progress_updates')
    .select('*')
    .order('created_at', { ascending: false })

  if (drawing_id) query = query.eq('drawing_id', drawing_id)
  if (external_org_id) query = query.eq('external_org_id', external_org_id)

  const { data, error } = await query
  if (error) throw error
  return data
}

// ==================== FIELD SERVICE ====================

async function createTicket(supabase: any, params: any) {
  const insertData = {
    ...params,
    reported_at: new Date().toISOString()
  }
  
  const { data, error } = await supabase
    .from('field_service_tickets')
    .insert(insertData)
    .select()
    .single()

  if (error) throw error
  return data
}

async function listTickets(supabase: any, params: any) {
  const { data, error } = await supabase
    .from('field_service_tickets')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) throw error
  return data
}

async function updateTicket(supabase: any, params: any) {
  const { ticket_id, ...updates } = params
  
  const { data, error } = await supabase
    .from('field_service_tickets')
    .update(updates)
    .eq('ticket_id', ticket_id)
    .select()
    .single()

  if (error) throw error
  return data
}
