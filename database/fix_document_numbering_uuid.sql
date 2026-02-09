-- Fix UUID issue in document_number_ranges table
-- Check current data
SELECT company_code, document_type, created_by, modified_by, tenant_id 
FROM public.document_number_ranges 
WHERE company_code = 'C001' AND document_type = 'MR';

-- Update SYSTEM string to proper UUID
UPDATE public.document_number_ranges 
SET 
  created_by = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid,
  modified_by = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid,
  tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid
WHERE company_code = 'C001' AND document_type = 'MR';

-- Verify fix
SELECT company_code, document_type, created_by, modified_by, tenant_id 
FROM public.document_number_ranges 
WHERE company_code = 'C001' AND document_type = 'MR';