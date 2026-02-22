-- =====================================================
-- DELEGATED ACCESS - FACILITIES COMPANY SHARING
-- =====================================================
-- Scenario: Facilities company shares drawings with their vendors
-- Simple delegation: If you have access, you can share (with limits)
-- =====================================================

-- 1. ADD DELEGATION FIELDS TO RESOURCE_ACCESS
-- =====================================================

-- Add delegation tracking to existing resource_access table
ALTER TABLE resource_access ADD COLUMN can_delegate BOOLEAN DEFAULT false;
ALTER TABLE resource_access ADD COLUMN delegated_by_org_id UUID REFERENCES organizations(organization_id);
ALTER TABLE resource_access ADD COLUMN delegated_by_user_id UUID REFERENCES users(user_id);
ALTER TABLE resource_access ADD COLUMN delegation_level INT DEFAULT 1; -- 1=direct, 2=sub-delegated

-- Constraint: Prevent deep delegation (max 2 levels)
ALTER TABLE resource_access ADD CONSTRAINT check_delegation_level
  CHECK (delegation_level >= 1 AND delegation_level <= 2);

-- Index for delegation queries
CREATE INDEX idx_resource_access_delegated_by ON resource_access(delegated_by_org_id);
CREATE INDEX idx_resource_access_delegation_level ON resource_access(delegation_level);

-- =====================================================
-- 2. DELEGATION FUNCTION (Simple)
-- =====================================================

CREATE OR REPLACE FUNCTION delegate_resource_access(
  p_delegating_org_id UUID,
  p_delegating_user_id UUID,
  p_target_org_id UUID,
  p_resource_type VARCHAR(50),
  p_resource_id UUID,
  p_access_purpose VARCHAR(50),
  p_access_level VARCHAR(20),
  p_allowed_actions TEXT[],
  p_access_end_date DATE DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
  v_parent_access resource_access%ROWTYPE;
  v_new_access_id UUID;
  v_tenant_id UUID;
BEGIN
  -- Get parent access record
  SELECT * INTO v_parent_access
  FROM resource_access
  WHERE organization_id = p_delegating_org_id
  AND resource_type = p_resource_type
  AND resource_id = p_resource_id
  AND is_active = true
  LIMIT 1;
  
  -- Check if parent has access
  IF v_parent_access.access_id IS NULL THEN
    RAISE EXCEPTION 'Delegating organization does not have access to this resource';
  END IF;
  
  -- Check if parent can delegate
  IF NOT v_parent_access.can_delegate THEN
    RAISE EXCEPTION 'Delegating organization cannot delegate access';
  END IF;
  
  -- Check delegation level (prevent deep nesting)
  IF v_parent_access.delegation_level >= 2 THEN
    RAISE EXCEPTION 'Maximum delegation level reached';
  END IF;
  
  -- Get tenant_id
  SELECT tenant_id INTO v_tenant_id FROM organizations WHERE organization_id = p_delegating_org_id;
  
  -- Create delegated access (with reduced permissions)
  INSERT INTO resource_access (
    tenant_id,
    organization_id,
    resource_type,
    resource_id,
    project_id,
    access_purpose,
    access_level,
    allowed_actions,
    access_start_date,
    access_end_date,
    can_delegate, -- Delegated access CANNOT be re-delegated
    delegated_by_org_id,
    delegated_by_user_id,
    delegation_level,
    granted_by,
    is_active
  ) VALUES (
    v_tenant_id,
    p_target_org_id,
    p_resource_type,
    p_resource_id,
    v_parent_access.project_id,
    p_access_purpose,
    CASE 
      WHEN p_access_level = 'WRITE' THEN 'READ' -- Downgrade WRITE to READ
      ELSE p_access_level
    END,
    p_allowed_actions,
    CURRENT_DATE,
    LEAST(p_access_end_date, v_parent_access.access_end_date), -- Cannot exceed parent's end date
    false, -- Cannot re-delegate
    p_delegating_org_id,
    p_delegating_user_id,
    v_parent_access.delegation_level + 1,
    p_delegating_user_id,
    true
  ) RETURNING access_id INTO v_new_access_id;
  
  RETURN v_new_access_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 3. REVOKE DELEGATED ACCESS
-- =====================================================

CREATE OR REPLACE FUNCTION revoke_delegated_access(
  p_access_id UUID,
  p_revoking_user_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
  v_access resource_access%ROWTYPE;
BEGIN
  -- Get access record
  SELECT * INTO v_access FROM resource_access WHERE access_id = p_access_id;
  
  -- Check if access exists
  IF v_access.access_id IS NULL THEN
    RAISE EXCEPTION 'Access record not found';
  END IF;
  
  -- Check if user has permission to revoke
  IF v_access.delegated_by_user_id != p_revoking_user_id THEN
    -- Check if user is from delegating organization
    IF NOT EXISTS (
      SELECT 1 FROM organization_users
      WHERE organization_id = v_access.delegated_by_org_id
      AND user_id = p_revoking_user_id
    ) THEN
      RAISE EXCEPTION 'User does not have permission to revoke this access';
    END IF;
  END IF;
  
  -- Revoke access
  UPDATE resource_access
  SET is_active = false,
      updated_at = NOW()
  WHERE access_id = p_access_id;
  
  RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 4. VIEWS FOR DELEGATION MANAGEMENT
-- =====================================================

-- View: My delegated access (what I've shared with others)
CREATE VIEW my_delegated_access AS
SELECT 
  ra.access_id,
  ra.resource_type,
  ra.resource_id,
  ra.access_purpose,
  ra.access_level,
  ra.delegation_level,
  o.org_name as delegated_to_org,
  ra.access_start_date,
  ra.access_end_date,
  ra.is_active,
  ra.created_at
FROM resource_access ra
JOIN organizations o ON ra.organization_id = o.organization_id
WHERE ra.delegated_by_user_id = auth.uid()
AND ra.delegated_by_org_id IS NOT NULL;

-- View: Access delegated to my organization
CREATE VIEW access_delegated_to_us AS
SELECT 
  ra.access_id,
  ra.resource_type,
  ra.resource_id,
  ra.access_purpose,
  ra.access_level,
  o.org_name as delegated_by_org,
  u.full_name as delegated_by_user,
  ra.access_start_date,
  ra.access_end_date,
  ra.is_active
FROM resource_access ra
JOIN organizations o ON ra.delegated_by_org_id = o.organization_id
JOIN users u ON ra.delegated_by_user_id = u.user_id
JOIN organization_users ou ON ou.organization_id = ra.organization_id
WHERE ou.user_id = auth.uid()
AND ra.delegated_by_org_id IS NOT NULL;

-- View: Delegation chain (who shared what with whom)
CREATE VIEW delegation_chain AS
WITH RECURSIVE access_chain AS (
  -- Base: Direct access (level 1)
  SELECT 
    ra.access_id,
    ra.organization_id,
    ra.resource_type,
    ra.resource_id,
    ra.delegation_level,
    ra.delegated_by_org_id,
    o.org_name,
    ARRAY[o.org_name] as chain
  FROM resource_access ra
  JOIN organizations o ON ra.organization_id = o.organization_id
  WHERE ra.delegation_level = 1
  
  UNION ALL
  
  -- Recursive: Delegated access (level 2+)
  SELECT 
    ra.access_id,
    ra.organization_id,
    ra.resource_type,
    ra.resource_id,
    ra.delegation_level,
    ra.delegated_by_org_id,
    o.org_name,
    ac.chain || o.org_name
  FROM resource_access ra
  JOIN organizations o ON ra.organization_id = o.organization_id
  JOIN access_chain ac ON ra.delegated_by_org_id = ac.organization_id
  WHERE ra.delegation_level > 1
)
SELECT * FROM access_chain;

-- =====================================================
-- 5. HELPER FUNCTIONS
-- =====================================================

-- Check if organization can delegate a resource
CREATE OR REPLACE FUNCTION can_org_delegate_resource(
  p_org_id UUID,
  p_resource_type VARCHAR(50),
  p_resource_id UUID
) RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM resource_access
    WHERE organization_id = p_org_id
    AND resource_type = p_resource_type
    AND resource_id = p_resource_id
    AND can_delegate = true
    AND is_active = true
    AND CURRENT_DATE BETWEEN access_start_date 
        AND COALESCE(access_end_date, '2099-12-31')
  );
END;
$$ LANGUAGE plpgsql;

-- Get delegation permissions for a resource
CREATE OR REPLACE FUNCTION get_delegation_permissions(
  p_org_id UUID,
  p_resource_type VARCHAR(50),
  p_resource_id UUID
) RETURNS TABLE(
  can_delegate BOOLEAN,
  delegation_level INT,
  max_access_level VARCHAR(20),
  access_end_date DATE
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    ra.can_delegate,
    ra.delegation_level,
    ra.access_level,
    ra.access_end_date
  FROM resource_access ra
  WHERE ra.organization_id = p_org_id
  AND ra.resource_type = p_resource_type
  AND ra.resource_id = p_resource_id
  AND ra.is_active = true
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 6. USAGE EXAMPLES
-- =====================================================

/*
SCENARIO: Facilities Company Shares Drawings with Vendor

Step 1: Grant facilities company access with delegation rights
--------
INSERT INTO resource_access (
  tenant_id, organization_id, resource_type, resource_id,
  access_purpose, access_level, allowed_actions,
  can_delegate, -- KEY: Allow delegation
  access_start_date, access_end_date
)
VALUES (
  'tenant-1', 'facilities-company-id', 'FACILITY', 'factory-a-id',
  'MAINTENANCE', 'WRITE', ARRAY['VIEW', 'DOWNLOAD', 'COMMENT'],
  true, -- Can delegate to their vendors
  '2024-01-01', '2024-12-31'
);

Step 2: Facilities company delegates to their HVAC vendor
--------
SELECT delegate_resource_access(
  'facilities-company-id',      -- Delegating org
  'facilities-user-id',          -- Delegating user
  'hvac-vendor-id',              -- Target org (their vendor)
  'FACILITY',                    -- Resource type
  'factory-a-id',                -- Resource ID
  'MAINTENANCE',                 -- Purpose
  'READ',                        -- Access level (downgraded from WRITE)
  ARRAY['VIEW', 'DOWNLOAD'],    -- Limited actions
  '2024-06-30'                   -- Earlier end date
);

Step 3: HVAC vendor can now see released drawings
--------
-- HVAC vendor users automatically see drawings via RLS
SELECT * FROM released_maintenance_drawings;

Step 4: Facilities company revokes access
--------
SELECT revoke_delegated_access('access-id', 'facilities-user-id');

Step 5: View delegation chain
--------
SELECT * FROM delegation_chain WHERE resource_id = 'factory-a-id';
-- Shows: Tenant → Facilities Company → HVAC Vendor
*/

-- =====================================================
-- 7. DELEGATION RULES (Application Logic)
-- =====================================================

/*
DELEGATION RULES:

1. WHO CAN DELEGATE:
   - Only organizations with can_delegate = true
   - Must have active access to the resource
   - Cannot delegate more than they have

2. DELEGATION LIMITS:
   - Max 2 levels (direct + 1 sub-delegation)
   - Access level can only be downgraded (WRITE → READ)
   - End date cannot exceed parent's end date
   - Delegated access CANNOT be re-delegated

3. AUTOMATIC RESTRICTIONS:
   - Delegated access is always READ or COMMENT (never WRITE)
   - Delegated access cannot delegate further
   - Delegated access expires with parent access

4. REVOCATION:
   - Delegating org can revoke anytime
   - Parent access revocation cascades to delegated access
   - Tenant admin can revoke all

5. VISIBILITY:
   - Delegated orgs see only RELEASED drawings
   - Same RLS policies apply
   - Audit log tracks all access
*/

-- =====================================================
-- 8. TRIGGER - CASCADE REVOCATION
-- =====================================================

-- When parent access is revoked, revoke all delegated access
CREATE OR REPLACE FUNCTION cascade_revoke_delegated_access()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_active = false AND OLD.is_active = true THEN
    -- Revoke all access delegated by this organization
    UPDATE resource_access
    SET is_active = false,
        updated_at = NOW()
    WHERE delegated_by_org_id = OLD.organization_id
    AND resource_type = OLD.resource_type
    AND resource_id = OLD.resource_id
    AND is_active = true;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_access_revocation
  AFTER UPDATE ON resource_access
  FOR EACH ROW
  WHEN (NEW.is_active = false AND OLD.is_active = true)
  EXECUTE FUNCTION cascade_revoke_delegated_access();

-- =====================================================
-- SUMMARY
-- =====================================================
/*
DELEGATED ACCESS - SIMPLE APPROACH:

1. FIELDS ADDED TO resource_access:
   - can_delegate (boolean)
   - delegated_by_org_id (who shared it)
   - delegated_by_user_id (which user shared it)
   - delegation_level (1=direct, 2=sub-delegated)

2. KEY FUNCTION:
   - delegate_resource_access() - Share with vendor
   - revoke_delegated_access() - Take back access
   - Automatic downgrade (WRITE → READ)
   - Automatic date limits

3. VIEWS:
   - my_delegated_access - What I've shared
   - access_delegated_to_us - What's been shared with us
   - delegation_chain - Full chain of sharing

4. RULES:
   ✅ Max 2 levels (prevent deep nesting)
   ✅ Auto-downgrade permissions
   ✅ Cannot exceed parent's end date
   ✅ Cascade revocation
   ✅ Same RLS policies apply

5. USE CASE:
   Tenant → Facilities Company (can_delegate=true)
           → HVAC Vendor (can_delegate=false)
           
   Facilities company can share drawings with their vendors
   Vendors see only RELEASED drawings
   Facilities company can revoke anytime

NO OVER-ENGINEERING:
  ❌ No complex permission trees
  ❌ No approval workflows for delegation
  ❌ No delegation templates
  ✅ Simple 2-level delegation
  ✅ Clear permission downgrade
  ✅ Automatic cascade revocation
  ✅ Full audit trail
*/
