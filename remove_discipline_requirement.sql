-- Make discipline and project_code columns nullable
ALTER TABLE documents ALTER COLUMN discipline DROP NOT NULL;
ALTER TABLE documents ALTER COLUMN project_code DROP NOT NULL;

-- Update create_document_with_lifecycle function to not require discipline
CREATE OR REPLACE FUNCTION create_document_with_lifecycle(
  p_tenant_id UUID,
  p_document_type VARCHAR,
  p_title VARCHAR,
  p_description TEXT DEFAULT NULL,
  p_document_subtype VARCHAR DEFAULT NULL,
  p_part_number VARCHAR DEFAULT NULL,
  p_parent_document_id UUID DEFAULT NULL,
  p_created_by UUID DEFAULT NULL
) RETURNS TABLE(document_id UUID, document_number VARCHAR) AS $$
DECLARE
  v_document_id UUID;
  v_document_number VARCHAR;
  v_document_level INTEGER := 1;
BEGIN
  -- Generate stable document number
  v_document_number := generate_stable_document_number(p_tenant_id, p_document_type);
  
  -- Calculate document level if parent exists
  IF p_parent_document_id IS NOT NULL THEN
    SELECT document_level + 1 INTO v_document_level
    FROM documents WHERE id = p_parent_document_id;
  END IF;
  
  -- Create document without discipline
  INSERT INTO documents (
    tenant_id, document_number, document_type, title, description,
    document_subtype, part_number, parent_document_id, document_level, created_by
  ) VALUES (
    p_tenant_id, v_document_number, p_document_type, p_title, p_description,
    p_document_subtype, p_part_number, p_parent_document_id, v_document_level, p_created_by
  ) RETURNING id INTO v_document_id;
  
  -- Create initial lifecycle
  INSERT INTO document_lifecycle (
    document_id, version, status, created_by, is_current
  ) VALUES (
    v_document_id, '0.1', 'DRAFT', p_created_by, true
  );
  
  -- Create parent relationship if parent exists
  IF p_parent_document_id IS NOT NULL THEN
    INSERT INTO document_relationships (
      document_id, related_document_id, relationship_type, is_primary, created_by
    ) VALUES (
      p_parent_document_id, v_document_id, 'PARENT_OF', true, p_created_by
    );
  END IF;
  
  RETURN QUERY SELECT v_document_id, v_document_number;
END;
$$ LANGUAGE plpgsql;