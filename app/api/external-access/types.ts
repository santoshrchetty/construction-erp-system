// ==================== ORGANIZATIONS ====================

export type OrgType = 'CUSTOMER' | 'VENDOR' | 'CONTRACTOR' | 'CONSULTANT' | 'REGULATORY' | 'OTHER'

export interface ExternalOrganization {
  external_org_id: string
  tenant_id: string
  name: string
  org_type: OrgType
  is_internal: boolean
  contact_email?: string
  contact_phone?: string
  address?: string
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface ExternalOrgUser {
  org_user_id: string
  external_org_id: string
  user_id: string
  role: string
  is_active: boolean
  invited_by?: string
  invited_at?: string
  created_at: string
  updated_at: string
}

export interface ExternalOrgRelationship {
  relationship_id: string
  tenant_id: string
  parent_org_id: string
  child_org_id: string
  relationship_type: 'SUBCONTRACTOR' | 'SUPPLIER' | 'PARTNER'
  is_active: boolean
  created_at: string
}

// ==================== RESOURCE ACCESS ====================

export type ResourceType = 'PROJECT' | 'DRAWING' | 'DOCUMENT' | 'FACILITY' | 'EQUIPMENT' | 'FOLDER'
export type AccessLevel = 'VIEW' | 'COMMENT' | 'EDIT' | 'ADMIN'

export interface ResourceAccess {
  access_id: string
  tenant_id: string
  external_org_id: string
  resource_type: ResourceType
  resource_id: string
  access_level: AccessLevel
  access_start_date?: string
  access_end_date?: string
  is_active: boolean
  granted_by: string
  granted_at: string
  notes?: string
}

// ==================== DRAWINGS ====================

export type DrawingStatus = 'DRAFT' | 'UNDER_REVIEW' | 'APPROVED' | 'RELEASED' | 'SUPERSEDED' | 'VOID'
export type DrawingCategory = 'CONSTRUCTION' | 'MAINTENANCE' | 'AS_BUILT' | 'SHOP_DRAWING' | 'SUBMITTAL'
export type RACIRole = 'R' | 'A' | 'C' | 'I'

export interface Drawing {
  id: string
  tenant_id: string
  project_id: string
  drawing_number: string
  title: string
  discipline?: string
  status: DrawingStatus
  current_revision?: string
  
  // External access fields
  drawing_category?: DrawingCategory
  is_released: boolean
  released_date?: string
  released_by?: string
  requires_customer_approval: boolean
  parent_drawing_id?: string
  facility_id?: string
  equipment_id?: string
  system_tag?: string
  location?: string
  external_reference?: string
  
  created_at: string
  updated_at: string
}

export interface DrawingRACI {
  raci_id: string
  tenant_id: string
  drawing_id: string
  external_org_id: string
  raci_role: RACIRole
  assigned_by: string
  assigned_at: string
  notes?: string
}

export interface DrawingCustomerApproval {
  approval_id: string
  tenant_id: string
  drawing_id: string
  external_org_id: string
  approval_status: 'PENDING' | 'APPROVED' | 'REJECTED' | 'APPROVED_WITH_COMMENTS'
  approved_by?: string
  approved_at?: string
  comments?: string
  created_at: string
}

// ==================== FACILITIES & EQUIPMENT ====================

export interface Facility {
  facility_id: string
  tenant_id: string
  project_id: string
  facility_code: string
  name: string
  facility_type?: string
  location?: string
  description?: string
  commissioned_date?: string
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface Equipment {
  equipment_id: string
  tenant_id: string
  project_id: string
  facility_id?: string
  tag_number: string
  description: string
  equipment_type?: string
  manufacturer?: string
  model?: string
  serial_number?: string
  installation_date?: string
  warranty_expiry?: string
  is_active: boolean
  created_at: string
  updated_at: string
}

// ==================== VENDOR PROGRESS ====================

export interface VendorProgressUpdate {
  update_id: string
  tenant_id: string
  drawing_id: string
  external_org_id: string
  progress_percentage: number
  status: 'NOT_STARTED' | 'IN_PROGRESS' | 'COMPLETED' | 'ON_HOLD'
  notes?: string
  submitted_by: string
  submitted_at: string
  created_at: string
}

// ==================== FIELD SERVICE ====================

export type TicketPriority = 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL'
export type TicketStatus = 'OPEN' | 'ASSIGNED' | 'IN_PROGRESS' | 'RESOLVED' | 'CLOSED'

export interface FieldServiceTicket {
  ticket_id: string
  tenant_id: string
  facility_id?: string
  equipment_id?: string
  assigned_external_org_id?: string
  title: string
  description?: string
  priority: TicketPriority
  status: TicketStatus
  reported_by: string
  reported_at: string
  assigned_at?: string
  resolved_at?: string
  resolution_notes?: string
  created_at: string
  updated_at: string
}

// ==================== API REQUEST/RESPONSE TYPES ====================

export interface ApiResponse<T = any> {
  success: boolean
  data?: T
  error?: string
}

export interface ListOrganizationsParams {
  tenant_id: string
  is_internal?: boolean
  org_type?: OrgType
}

export interface GrantAccessParams {
  tenant_id: string
  external_org_id: string
  resource_type: ResourceType
  resource_id: string
  access_level: AccessLevel
  access_start_date?: string
  access_end_date?: string
  granted_by: string
  notes?: string
}

export interface InviteUserParams {
  email: string
  external_org_id: string
  role: string
  invited_by: string
}

export interface ReleaseDrawingParams {
  id: string
  released_by: string
}
