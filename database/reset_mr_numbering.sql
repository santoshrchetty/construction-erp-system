-- Check current document number ranges
SELECT * FROM public.document_number_ranges 
WHERE document_type = 'MR' AND fiscal_year = '2026';

-- Reset MR numbering to start from 0 (next number will be 1)
UPDATE public.document_number_ranges 
SET current_number = 0 
WHERE company_code = '1000' 
  AND document_type = 'MR' 
  AND number_range_group = '01' 
  AND fiscal_year = '2026';

-- Test the RPC function
SELECT public.get_next_number_by_group('1000', 'MR', '01', '2026');