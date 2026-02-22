-- =====================================================
-- EXTERNAL ACCESS - FINAL IMPLEMENTATION SUMMARY
-- =====================================================
-- Status: APPROVED FOR IMPLEMENTATION
-- Focus: Stable, core functionality only
-- Deferred: Delegation features (Phase 2)
-- =====================================================

-- =====================================================
-- PHASE 1: CORE IMPLEMENTATION (NOW)
-- =====================================================

/*
TABLES TO CREATE:

1. organizations (Already exists)
   - organization_id, tenant_id, org_code, org_name, is_internal, is_active

2. organization_relationships (Already exists)
   - relationship_id, tenant_id, source_org_id, target_org_id, relationship_type

3. organization_users (NEW)
   - Link users to organizations
   - org_user_id, tenant_id, organization_id, user_id, position_title, is_primary_contact

4. resource_access (NEW - Core access control)
   - Flexible resource-based access
   - access_id, tenant_id, organization_id
   - resource_type (PROJECT, DRAWING, DOCUMENT, EQUIPMENT, FACILITY)
   - resource_id, project_id (optional context)
   - access_purpose (APPROVAL, PRODUCTION, MAINTENANCE, REFERENCE)
   - access_level (READ, WRITE, COMMENT)
   - allowed_actions (array: VIEW, DOWNLOAD, COMMENT, APPROVE, EDIT)
   - access_start_date, access_end_date
   - is_active

5. facilities (NEW - For maintenance drawings)
   - facility_id, tenant_id, facility_code, facility_name, facility_type
   - operational_status, commissioned_date

6. equipment_register (NEW - Optional)
   - equipment_id, tenant_id, facility_id, equipment_tag, equipment_name
   - equipment_type, system_tag, location_reference

7. drawing_customer_approvals (NEW)
   - approval_id, tenant_id, drawing_id, organization_id, customer_user_id
   - approval_status, comments, attachments

8. vendor_progress_updates (NEW)
   - update_id, tenant_id, project_id, organization_id, vendor_user_id
   - progress_percentage, status, update_description

9. field_service_tickets (NEW)
   - ticket_id, tenant_id, project_id, ticket_number
   - assigned_organization_id, service_type, priority, status

10. external_access_audit_log (NEW)
    - log_id, tenant_id, user_id, organization_id
    - action_type, resource_type, resource_id

11. drawing_raci (NEW - Simple RACI)
    - raci_id, tenant_id, drawing_id
    - user_id OR organization_id
    - raci_role (RESPONSIBLE, ACCOUNTABLE, CONSULTED, INFORMED)
    - responsibility_area

FIELDS TO ADD TO EXISTING TABLES:

drawings table:
  - parent_drawing_id (hierarchy)
  - drawing_level (1-5)
  - drawing_path (breadcrumb)
  - is_assembly (boolean)
  - drawing_category (CONSTRUCTION, MAINTENANCE, AS_BUILT, OPERATIONS)
  - facility_id (link to facilities)
  - equipment_id (link to equipment)
  - system_tag (HVAC, ELECTRICAL, etc.)
  - location_reference (Building A, Floor 2)
  - is_released (boolean)
  - released_by (user_id)
  - released_at (timestamp)

drawing_revisions table:
  - is_released (boolean)
  - released_at (timestamp)

users table:
  - user_type (INTERNAL, EXTERNAL) - Optional, can use organization_users presence instead

KEY FUNCTIONS:

1. release_drawing(drawing_id, user_id)
   - Release a drawing for external access

2. user_has_resource_access(user_id, resource_type, resource_id, action)
   - Check if user can access a resource

3. get_drawing_hierarchy(drawing_id)
   - Get parent-child drawing tree

4. get_drawing_raci_with_inheritance(drawing_id)
   - Get RACI with parent inheritance

5. user_has_raci_role(user_id, drawing_id, raci_role)
   - Check RACI permission

RLS POLICIES:

1. drawings_external_user_access
   - Internal users: See ALL
   - External users: See only RELEASED drawings they have access to

2. drawing_revisions_external_access
   - External users: See only released revisions

3. drawing_comments_external_access
   - Can view/comment based on access level

4. vendor_progress_own_org
   - Can only see/edit own organization's updates

5. field_service_external_access
   - Can only see assigned tickets

VIEWS:

1. released_drawings
   - All released drawings

2. my_released_drawings
   - My accessible released drawings

3. facility_maintenance_drawings
   - All maintenance drawings for facilities

4. drawing_hierarchy_with_raci
   - Hierarchy with RACI summary

5. my_drawings_raci
   - Drawings where I have RACI role
*/

-- =====================================================
-- PHASE 2: DEFERRED FEATURES (LATER)
-- =====================================================

/*
DEFERRED TO PHASE 2:

1. DELEGATION FEATURES:
   - can_delegate field
   - delegated_by_org_id field
   - delegated_by_user_id field
   - delegation_level field
   - delegate_resource_access() function
   - revoke_delegated_access() function
   - Cascade revocation triggers
   - Delegation views

   REASON: Adds complexity, not critical for MVP
   WHEN: After core system is stable and tested

2. ADVANCED FEATURES:
   - User invitation system
   - Notification preferences
   - IP whitelisting
   - Download watermarking
   - Rate limiting
   - Advanced analytics

   REASON: Nice-to-have, not core functionality
   WHEN: Based on user feedback and requirements

3. TIER-BASED ACCESS:
   - tier_level field
   - access_granted_by_org_id field
   - Tier calculation functions
   - Subcontractor inheritance

   REASON: Over-engineering, simplified to direct access
   WHEN: Only if specific use case emerges
*/

-- =====================================================
-- IMPLEMENTATION PRIORITY
-- =====================================================

/*
WEEK 1-2: Foundation
  ✅ Create organizations table (if not exists)
  ✅ Create organization_relationships table (if not exists)
  ✅ Create organization_users table
  ✅ Create resource_access table
  ✅ Add fields to drawings table
  ✅ Add fields to drawing_revisions table

WEEK 3-4: Core Features
  ✅ Create facilities table
  ✅ Create equipment_register table
  ✅ Create drawing_raci table
  ✅ Add hierarchy fields to drawings
  ✅ Create release_drawing() function
  ✅ Create RLS policies for external users

WEEK 5-6: Module-Specific
  ✅ Create drawing_customer_approvals table
  ✅ Create vendor_progress_updates table
  ✅ Create field_service_tickets table
  ✅ Create external_access_audit_log table
  ✅ Create helper functions
  ✅ Create views

WEEK 7-8: Testing & Refinement
  ✅ Test RLS policies
  ✅ Test access control
  ✅ Test RACI inheritance
  ✅ Performance optimization
  ✅ Documentation
*/

-- =====================================================
-- KEY DESIGN DECISIONS
-- =====================================================

/*
1. SIMPLE HIERARCHY:
   - Parent-child only (no complex trees)
   - Max 5 levels
   - Simple path tracking

2. RESOURCE-BASED ACCESS:
   - One table for all resource types
   - Flexible, not rigid
   - Easy to extend

3. RELEASE CONTROL:
   - Simple boolean flag
   - External users see only RELEASED
   - No complex state machines

4. RACI:
   - At drawing level (not per revision)
   - Inheritance from parent
   - Four clear roles (R, A, C, I)

5. NO DELEGATION (Phase 1):
   - Direct access only
   - Tenant grants access to organizations
   - Organizations cannot re-share
   - Keeps system simple and stable

6. SAME DRAWING TABLE:
   - Construction and maintenance use same table
   - Differentiated by drawing_category
   - No duplicate systems
*/

-- =====================================================
-- SECURITY PRINCIPLES
-- =====================================================

/*
1. TENANT ISOLATION:
   - All tables have tenant_id
   - RLS enforces at database level
   - No cross-tenant data leakage

2. EXTERNAL USER RESTRICTIONS:
   - See only RELEASED drawings
   - Access controlled by resource_access
   - Time-bound access (start/end dates)
   - Audit all actions

3. ORGANIZATION-BASED:
   - Users belong to organizations
   - Access granted to organizations
   - Users inherit org access

4. LEAST PRIVILEGE:
   - Default: No access
   - Explicit grants required
   - Can only downgrade permissions
   - Automatic expiry

5. AUDIT TRAIL:
   - Log all external user actions
   - Track who accessed what when
   - Cannot be deleted (append-only)
*/

-- =====================================================
-- SUCCESS CRITERIA
-- =====================================================

/*
PHASE 1 IS SUCCESSFUL WHEN:

1. External organizations can be onboarded
2. Users can be linked to organizations
3. Access can be granted to:
   - Projects
   - Specific drawings
   - Facilities
   - Equipment
4. External users see only RELEASED drawings
5. RACI roles work with inheritance
6. Drawings support hierarchy (parent-child)
7. Maintenance drawings work same as construction
8. Customer approvals can be tracked
9. Vendor progress can be submitted
10. Field service tickets can be managed
11. All actions are audited
12. RLS policies enforce security
13. System is stable and performant

METRICS:
- External user login success rate > 95%
- Drawing access response time < 500ms
- Zero cross-tenant data leaks
- 100% audit coverage
- Zero security incidents
*/

-- =====================================================
-- FINAL CHECKLIST
-- =====================================================

/*
BEFORE DEPLOYMENT:

Database:
  [ ] All tables created
  [ ] All indexes created
  [ ] All constraints added
  [ ] All RLS policies enabled
  [ ] All functions tested
  [ ] All triggers tested
  [ ] Sample data loaded
  [ ] Performance tested

Application:
  [ ] API endpoints created
  [ ] Authentication working
  [ ] Authorization working
  [ ] File access secured
  [ ] Audit logging working
  [ ] Error handling complete

Testing:
  [ ] Unit tests pass
  [ ] Integration tests pass
  [ ] Security tests pass
  [ ] Performance tests pass
  [ ] User acceptance tests pass

Documentation:
  [ ] Database schema documented
  [ ] API documented
  [ ] User guides created
  [ ] Admin guides created
  [ ] Security policies documented

Deployment:
  [ ] Backup plan ready
  [ ] Rollback plan ready
  [ ] Monitoring configured
  [ ] Alerts configured
  [ ] Support team trained
*/

-- =====================================================
-- SUMMARY
-- =====================================================

/*
WHAT WE'RE BUILDING (PHASE 1):

✅ External organization management
✅ Resource-based access control
✅ Drawing hierarchy (parent-child)
✅ Simple RACI (R, A, C, I)
✅ Release control (DRAFT → RELEASED)
✅ Maintenance drawings support
✅ Customer approvals
✅ Vendor progress tracking
✅ Field service tickets
✅ Complete audit trail
✅ RLS security
✅ Time-bound access

WHAT WE'RE NOT BUILDING (PHASE 1):

❌ Delegation (facilities sharing with vendors)
❌ User invitations
❌ Notification preferences
❌ IP whitelisting
❌ Download watermarking
❌ Rate limiting
❌ Tier-based access
❌ Advanced analytics

RESULT:
- Stable, core system
- Proven patterns
- Easy to maintain
- Room to grow
- No over-engineering

ESTIMATED TIMELINE: 8 weeks
ESTIMATED TABLES: 11 new + 2 existing modified
ESTIMATED FUNCTIONS: 5 core functions
ESTIMATED RLS POLICIES: 10 policies
*/
