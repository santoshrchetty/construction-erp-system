-- Fix the audit trigger function that's causing UUID errors
CREATE OR REPLACE FUNCTION audit_number_range_changes()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO num_range_usg_hist (
    tenant_id,
    company_code,
    document_type,
    document_number,
    used_by,
    created_at
  ) VALUES (
    NEW.tenant_id,
    NEW.company_code,
    NEW.document_type,
    NEW.current_number::text,
    COALESCE(NEW.modified_by, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid),
    NOW()
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Now update the document_number_ranges table
UPDATE public.document_number_ranges 
SET 
  created_by = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid,
  modified_by = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid,
  tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid
WHERE company_code = 'C001' AND document_type = 'MR';