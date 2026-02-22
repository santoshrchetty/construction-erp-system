-- 🔧 SERVICE LAYER FUNCTIONS

-- 📝 CREATE DOCUMENT WITH LIFECYCLE
CREATE OR REPLACE FUNCTION create_document_with_lifecycle(
  p_tenant_id UUID,
  p_document_type VARCHAR,
  p_title VARCHAR,
  p_discipline VARCHAR,
  p_project_code VARCHAR,
  p_description TEXT DEFAULT NULL,
  p_created_by UUID DEFAULT NULL
) RETURNS TABLE(document_id UUID, document_number VARCHAR) AS $$
DECLARE
  v_document_id UUID;
  v_document_number VARCHAR;
BEGIN
  -- Generate stable document number
  v_document_number := generate_stable_document_number(p_tenant_id, p_document_type);
  
  -- Create document
  INSERT INTO documents (
    tenant_id, document_number, document_type, title, discipline, 
    project_code, description, created_by
  ) VALUES (
    p_tenant_id, v_document_number, p_document_type, p_title, p_discipline,
    p_project_code, p_description, p_created_by
  ) RETURNING id INTO v_document_id;
  
  -- Create initial lifecycle
  INSERT INTO document_lifecycle (
    document_id, version, status, created_by, is_current
  ) VALUES (
    v_document_id, '0.1', 'DRAFT', p_created_by, true
  );
  
  RETURN QUERY SELECT v_document_id, v_document_number;
END;
$$ LANGUAGE plpgsql;

-- 🔄 ISSUE REVISION (COST IMPACT TRIGGER)
CREATE OR REPLACE FUNCTION issue_document_revision(
  p_document_id UUID,
  p_new_revision VARCHAR,
  p_new_status VARCHAR,
  p_issued_by UUID
) RETURNS BOOLEAN AS $$
DECLARE
  v_current_lifecycle_id UUID;
  v_wbs_id UUID;
  v_old_status VARCHAR;
BEGIN
  -- Get current lifecycle
  SELECT id, status INTO v_current_lifecycle_id, v_old_status
  FROM document_lifecycle 
  WHERE document_id = p_document_id AND is_current = true;
  
  -- Mark current as not current
  UPDATE document_lifecycle SET is_current = false WHERE id = v_current_lifecycle_id;
  
  -- Create new lifecycle record
  INSERT INTO document_lifecycle (
    document_id, version, revision, status, effective_date, created_by, is_current
  ) VALUES (
    p_document_id, '1.0', p_new_revision, p_new_status, CURRENT_DATE, p_issued_by, true
  );
  
  -- 💰 COST IMPACT GOVERNANCE TRIGGER
  IF p_new_status IN ('IFC', 'AS_BUILT') AND v_old_status != p_new_status THEN
    -- Get financial owner WBS
    SELECT wbs_id INTO v_wbs_id
    FROM document_wbs_links 
    WHERE document_id = p_document_id AND is_financial_owner = true;
    
    IF v_wbs_id IS NOT NULL THEN
      -- Log cost impact event
      INSERT INTO document_cost_impacts (
        document_id, lifecycle_id, wbs_id, impact_type, requires_approval
      ) VALUES (
        p_document_id, v_current_lifecycle_id, v_wbs_id, 'REVISION_ISSUED', true
      );
      
      -- TODO: Trigger cost plan version creation
      -- TODO: Flag related activities
      -- TODO: Require approval workflow
    END IF;
  END IF;
  
  RETURN true;
END;
$$ LANGUAGE plpgsql;

-- 🔗 ADD DOCUMENT RELATIONSHIP
CREATE OR REPLACE FUNCTION add_document_relationship(
  p_document_id UUID,
  p_related_document_id UUID,
  p_relationship_type VARCHAR,
  p_is_primary BOOLEAN DEFAULT false,
  p_created_by UUID DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
  v_relationship_id UUID;
BEGIN
  INSERT INTO document_relationships (
    document_id, related_document_id, relationship_type, is_primary, created_by
  ) VALUES (
    p_document_id, p_related_document_id, p_relationship_type, p_is_primary, p_created_by
  ) RETURNING id INTO v_relationship_id;
  
  RETURN v_relationship_id;
END;
$$ LANGUAGE plpgsql;

-- 🏗️ LINK WBS (WITH FINANCIAL OWNER VALIDATION)
CREATE OR REPLACE FUNCTION link_document_wbs(
  p_document_id UUID,
  p_wbs_id UUID,
  p_is_financial_owner BOOLEAN DEFAULT false,
  p_created_by UUID DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
  v_link_id UUID;
BEGIN
  -- Validate: only one financial owner allowed
  IF p_is_financial_owner = true THEN
    IF EXISTS (
      SELECT 1 FROM document_wbs_links 
      WHERE document_id = p_document_id AND is_financial_owner = true
    ) THEN
      RAISE EXCEPTION 'Document already has a financial owner WBS';
    END IF;
  END IF;
  
  INSERT INTO document_wbs_links (
    document_id, wbs_id, is_financial_owner, created_by
  ) VALUES (
    p_document_id, p_wbs_id, p_is_financial_owner, p_created_by
  ) RETURNING id INTO v_link_id;
  
  RETURN v_link_id;
END;
$$ LANGUAGE plpgsql;

-- Drop existing function first
DROP FUNCTION IF EXISTS get_document_hierarchy(UUID);

-- 📊 FETCH HIERARCHICAL VIEW (CALCULATED)
CREATE OR REPLACE FUNCTION get_document_hierarchy(p_root_document_id UUID)
RETURNS TABLE(
  document_id UUID,
  document_number VARCHAR,
  title VARCHAR,
  level_depth INTEGER,
  relationship_path VARCHAR[]
) AS $$
BEGIN
  RETURN QUERY
  WITH RECURSIVE hierarchy AS (
    -- Root level
    SELECT 
      d.id as document_id,
      d.document_number,
      d.title,
      1 as level_depth,
      ARRAY[d.document_number]::VARCHAR[] as relationship_path
    FROM documents d
    WHERE d.id = p_root_document_id
    
    UNION ALL
    
    -- Recursive children
    SELECT 
      d.id,
      d.document_number,
      d.title,
      h.level_depth + 1,
      h.relationship_path || d.document_number::VARCHAR
    FROM documents d
    JOIN document_relationships dr ON d.id = dr.related_document_id
    JOIN hierarchy h ON dr.document_id = h.document_id
    WHERE dr.relationship_type = 'PARENT_OF'
  )
  SELECT * FROM hierarchy ORDER BY level_depth, document_number;
END;
$$ LANGUAGE plpgsql;

-- 💰 FETCH FINANCIAL OWNERSHIP
CREATE OR REPLACE FUNCTION get_document_financial_ownership(p_document_id UUID)
RETURNS TABLE(
  document_id UUID,
  document_number VARCHAR,
  wbs_id UUID,
  financial_owner BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    d.id,
    d.document_number,
    dwl.wbs_id,
    dwl.is_financial_owner
  FROM documents d
  JOIN document_wbs_links dwl ON d.id = dwl.document_id
  WHERE d.id = p_document_id AND dwl.is_financial_owner = true;
END;
$$ LANGUAGE plpgsql;