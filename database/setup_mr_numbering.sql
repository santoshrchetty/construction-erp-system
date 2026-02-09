-- Check existing MR record for C001
SELECT * FROM public.document_number_ranges 
WHERE company_code = 'C001' AND document_type = 'MR';

-- Update existing record to proper values
UPDATE public.document_number_ranges 
SET 
  number_range_group = '01',
  fiscal_year = 2026,
  range_from = '000001',
  range_to = '999999',
  current_number = '000001',
  from_number = 1,
  to_number = 999999,
  status = 'ACTIVE',
  prefix = 'MR',
  interval_size = 1,
  description = 'MR Numbers',
  number_range_object = 'MAT_REQ',
  modified_at = now()
WHERE company_code = 'C001' AND document_type = 'MR';

-- Create simplified function that only updates existing records
CREATE OR REPLACE FUNCTION public.get_next_document_number(
  p_company_code text,
  p_document_type text,
  p_number_range_group text,
  p_fiscal_year text
) RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_current_number bigint;
  v_next_number bigint;
  v_formatted_number text;
  v_tenant_id uuid := '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid;
BEGIN
  -- Lock and get current number
  SELECT current_number::bigint INTO v_current_number
  FROM public.document_number_ranges
  WHERE company_code = p_company_code
    AND document_type = p_document_type
    AND number_range_group = p_number_range_group
    AND fiscal_year = p_fiscal_year::integer
    AND tenant_id = v_tenant_id
    AND status = 'ACTIVE'
  FOR UPDATE;
  
  -- If record exists, increment and update
  IF v_current_number IS NOT NULL THEN
    v_next_number := v_current_number + 1;
    
    UPDATE public.document_number_ranges
    SET current_number = v_next_number::text,
        modified_at = now()
    WHERE company_code = p_company_code
      AND document_type = p_document_type
      AND number_range_group = p_number_range_group
      AND fiscal_year = p_fiscal_year::integer
      AND tenant_id = v_tenant_id;
    
    -- Format and return
    v_formatted_number := lpad(v_next_number::text, 6, '0');
    RETURN p_document_type || '-' || p_number_range_group || '-' || p_fiscal_year || '-' || v_formatted_number;
  ELSE
    -- No record found, return null to trigger fallback
    RETURN NULL;
  END IF;
END;
$$;