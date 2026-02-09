-- Delete all data from material_requests table
DELETE FROM public.material_requests;

-- Delete all data from material_request_items table
DELETE FROM public.material_request_items;

-- Delete all MR records from document_number_ranges
DELETE FROM public.document_number_ranges 
WHERE document_type = 'MR';

-- Insert fresh MR record for C001
INSERT INTO public.document_number_ranges (
  company_code, 
  document_type, 
  number_range_group, 
  fiscal_year, 
  range_from,
  range_to,
  current_number,
  from_number,
  to_number,
  status,
  prefix,
  tenant_id,
  interval_size,
  description,
  number_range_object
) VALUES (
  'C001', 
  'MR', 
  '01', 
  2026,
  '000001',
  '999999', 
  '000001',
  1,
  999999,
  'ACTIVE',
  'MR',
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid,
  1,
  'MR Numbers',
  'MAT_REQ'
);

-- Verify the insert
SELECT * FROM public.document_number_ranges 
WHERE company_code = 'C001' AND document_type = 'MR';