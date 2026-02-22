-- 🔄 MIGRATION SCRIPT: Hierarchical → Graph-based Document System

-- STEP 1: Backup existing data
CREATE TABLE document_records_backup AS SELECT * FROM document_records;

-- STEP 2: Migrate documents to new stable identity model
INSERT INTO documents (
  id,
  tenant_id,
  document_number,
  document_type,
  title,
  description,
  discipline,
  project_code,
  created_by,
  created_at,
  updated_at
)
SELECT 
  id,
  tenant_id,
  -- Generate new stable document numbers (remove hierarchy encoding)
  CASE 
    WHEN document_type IN ('DRAWING', 'DRW') THEN 'DRW-' || LPAD((EXTRACT(YEAR FROM created_at) % 100)::TEXT, 2, '0') || '-' || LPAD(ROW_NUMBER() OVER (PARTITION BY document_type ORDER BY created_at)::TEXT, 4, '0')
    WHEN document_type IN ('SPECIFICATION', 'SPE') THEN 'SPE-' || LPAD((EXTRACT(YEAR FROM created_at) % 100)::TEXT, 2, '0') || '-' || LPAD(ROW_NUMBER() OVER (PARTITION BY document_type ORDER BY created_at)::TEXT, 4, '0')
    WHEN document_type IN ('CONTRACT', 'CNT') THEN 'CNT-' || LPAD((EXTRACT(YEAR FROM created_at) % 100)::TEXT, 2, '0') || '-' || LPAD(ROW_NUMBER() OVER (PARTITION BY document_type ORDER BY created_at)::TEXT, 4, '0')
    WHEN document_type = 'RFI' THEN 'RFI-' || LPAD((EXTRACT(YEAR FROM created_at) % 100)::TEXT, 2, '0') || '-' || LPAD(ROW_NUMBER() OVER (PARTITION BY document_type ORDER BY created_at)::TEXT, 4, '0')
    WHEN document_type IN ('SUBMITTAL', 'SUB') THEN 'SUB-' || LPAD((EXTRACT(YEAR FROM created_at) % 100)::TEXT, 2, '0') || '-' || LPAD(ROW_NUMBER() OVER (PARTITION BY document_type ORDER BY created_at)::TEXT, 4, '0')
    WHEN document_type IN ('CHANGE_ORDER', 'CHG') THEN 'CHG-' || LPAD((EXTRACT(YEAR FROM created_at) % 100)::TEXT, 2, '0') || '-' || LPAD(ROW_NUMBER() OVER (PARTITION BY document_type ORDER BY created_at)::TEXT, 4, '0')
    ELSE 'DOC-' || LPAD((EXTRACT(YEAR FROM created_at) % 100)::TEXT, 2, '0') || '-' || LPAD(ROW_NUMBER() OVER (PARTITION BY document_type ORDER BY created_at)::TEXT, 4, '0')
  END as document_number,
  -- Map old document types to 3-letter codes
  CASE 
    WHEN document_type = 'DRAWING' THEN 'DRW'
    WHEN document_type = 'SPECIFICATION' THEN 'SPE'
    WHEN document_type = 'CONTRACT' THEN 'CNT'
    WHEN document_type = 'RFI' THEN 'RFI'
    WHEN document_type = 'SUBMITTAL' THEN 'SUB'
    WHEN document_type = 'CHANGE_ORDER' THEN 'CHG'
    WHEN document_type = 'OTHER' THEN 'DOC'
    WHEN document_type = 'DRW' THEN 'DRW'
    WHEN document_type = 'SPE' THEN 'SPE'
    WHEN document_type = 'CNT' THEN 'CNT'
    WHEN document_type = 'SUB' THEN 'SUB'
    WHEN document_type = 'CHG' THEN 'CHG'
    WHEN document_type = 'DOC' THEN 'DOC'
    ELSE 'DOC'
  END as document_type,
  title,
  description,
  COALESCE(project_code, 'UNKNOWN') as discipline, -- Map to discipline
  COALESCE(project_code, 'PROJ-000') as project_code,
  created_by,
  created_at,
  updated_at
FROM document_records;

-- STEP 3: Migrate lifecycle data
INSERT INTO document_lifecycle (
  document_id,
  version,
  revision,
  status,
  effective_date,
  created_by,
  created_at,
  is_current
)
SELECT 
  id,
  COALESCE(version, '1.0'),
  revision,
  CASE 
    WHEN status = 'DRAFT' THEN 'DRAFT'
    WHEN status = 'UNDER_REVIEW' THEN 'IFR'
    WHEN status = 'APPROVED' THEN 'IFC'
    WHEN status = 'REJECTED' THEN 'VOID'
    WHEN status = 'SUPERSEDED' THEN 'VOID'
    ELSE 'DRAFT'
  END,
  created_at::DATE,
  created_by,
  created_at,
  true -- All current records are current
FROM document_records;

-- STEP 4: Convert hierarchical part_number relationships to graph relationships
INSERT INTO document_relationships (
  document_id,
  related_document_id,
  relationship_type,
  is_primary,
  created_by,
  created_at
)
SELECT DISTINCT
  child.id as document_id,
  parent.id as related_document_id,
  'PARENT_OF' as relationship_type,
  true as is_primary,
  child.created_by,
  child.created_at
FROM document_records child
JOIN document_records parent ON (
  -- Extract parent part number from hierarchical part_number
  CASE 
    WHEN child.part_number ~ '^[0-9]{3}\.[0-9]{3}$' THEN 
      SUBSTRING(child.part_number FROM '^([0-9]{3})')
    WHEN child.part_number ~ '^[0-9]{3}\.[0-9]{3}\.[0-9]{3}$' THEN 
      SUBSTRING(child.part_number FROM '^([0-9]{3}\.[0-9]{3})')
  END = parent.part_number
)
WHERE child.part_number IS NOT NULL 
AND parent.part_number IS NOT NULL
AND child.id != parent.id;

-- STEP 5: Migrate WBS links (create financial ownership)
INSERT INTO document_wbs_links (
  document_id,
  wbs_id,
  is_financial_owner,
  created_by,
  created_at
)
SELECT 
  id,
  -- Generate UUID for WBS (you'll need to map to actual WBS system)
  gen_random_uuid(),
  true, -- First WBS link is financial owner
  created_by,
  created_at
FROM document_records
WHERE wbs_element IS NOT NULL;

-- STEP 6: Migrate object links
INSERT INTO document_object_links (
  document_id,
  object_type,
  object_id,
  created_by,
  created_at
)
SELECT id, 'MATERIAL', material_number, created_by, created_at
FROM document_records WHERE material_number IS NOT NULL
UNION ALL
SELECT id, 'VENDOR', vendor_name, created_by, created_at
FROM document_records WHERE vendor_name IS NOT NULL
UNION ALL
SELECT id, 'CONTRACT', contract_number, created_by, created_at
FROM document_records WHERE contract_number IS NOT NULL
UNION ALL
SELECT id, 'COST_CENTER', cost_center, created_by, created_at
FROM document_records WHERE cost_center IS NOT NULL;

-- STEP 7: Update document sequences for future numbering
INSERT INTO document_sequences (tenant_id, document_type, year, last_sequence)
SELECT 
  tenant_id,
  document_type,
  EXTRACT(YEAR FROM NOW()) % 100,
  COUNT(*)
FROM documents
GROUP BY tenant_id, document_type
ON CONFLICT (tenant_id, document_type, year) DO UPDATE SET
  last_sequence = EXCLUDED.last_sequence;

-- STEP 8: Verification queries
SELECT 'MIGRATION SUMMARY' as check_type;

SELECT 'Documents migrated' as metric, COUNT(*) as count FROM documents;
SELECT 'Lifecycle records created' as metric, COUNT(*) as count FROM document_lifecycle;
SELECT 'Relationships created' as metric, COUNT(*) as count FROM document_relationships;
SELECT 'WBS links created' as metric, COUNT(*) as count FROM document_wbs_links;
SELECT 'Object links created' as metric, COUNT(*) as count FROM document_object_links;

-- Test hierarchical view
SELECT 'Hierarchy test' as test_type;
SELECT * FROM get_document_hierarchy((SELECT id FROM documents LIMIT 1));

-- STEP 9: Drop old tables (UNCOMMENT WHEN READY)
-- DROP TABLE document_records_backup;
-- DROP TABLE document_records;
-- DROP FUNCTION IF EXISTS generate_part_number(UUID, UUID);
-- DROP FUNCTION IF EXISTS update_document_level();

COMMENT ON SCHEMA public IS 'Migration completed: Hierarchical → Graph-based Document System';