-- Test if the RPC function exists and works
SELECT public.get_next_document_number('1000', 'MR', '01', '2026');

-- Check if document_number_ranges table exists and has data
SELECT * FROM public.document_number_ranges 
WHERE document_type = 'MR' AND fiscal_year = '2026';

-- If no data exists, insert initial record
INSERT INTO public.document_number_ranges (
  company_code, document_type, number_range_group, fiscal_year, current_number, tenant_id
) VALUES 
  ('1000', 'MR', '01', '2026', 0, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid)
ON CONFLICT (company_code, document_type, number_range_group, fiscal_year, tenant_id) 
DO NOTHING;

-- Test the function again
SELECT public.get_next_document_number('1000', 'MR', '01', '2026');