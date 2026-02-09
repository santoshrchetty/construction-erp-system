-- Check what data exists in document_number_ranges table
SELECT * FROM public.document_number_ranges LIMIT 5;

-- Create a simpler version of the function that handles all data types properly
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
  v_current_number integer;
  v_next_number integer;
  v_formatted_number text;
  v_tenant_id uuid := '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid;
BEGIN
  -- Lock the row to prevent concurrent access - cast all text fields explicitly
  SELECT current_number INTO v_current_number
  FROM public.document_number_ranges
  WHERE company_code::text = p_company_code::text
    AND document_type::text = p_document_type::text
    AND number_range_group::text = p_number_range_group::text
    AND fiscal_year::text = p_fiscal_year::text
    AND tenant_id = v_tenant_id
  FOR UPDATE;
  
  -- If no record exists, create one
  IF v_current_number IS NULL THEN
    INSERT INTO public.document_number_ranges (
      company_code, 
      document_type, 
      number_range_group, 
      fiscal_year, 
      current_number,
      tenant_id
    ) VALUES (
      p_company_code, 
      p_document_type, 
      p_number_range_group, 
      p_fiscal_year, 
      1,
      v_tenant_id
    );
    v_next_number := 1;
  ELSE
    -- Increment the current number
    v_next_number := v_current_number + 1;
    
    -- Update the current number
    UPDATE public.document_number_ranges
    SET current_number = v_next_number,
        updated_at = now()
    WHERE company_code::text = p_company_code::text
      AND document_type::text = p_document_type::text
      AND number_range_group::text = p_number_range_group::text
      AND fiscal_year::text = p_fiscal_year::text
      AND tenant_id = v_tenant_id;
  END IF;
  
  -- Format the number with leading zeros (6 digits)
  v_formatted_number := lpad(v_next_number::text, 6, '0');
  
  -- Return the complete document number
  RETURN p_document_type || '-' || p_number_range_group || '-' || p_fiscal_year || '-' || v_formatted_number;
END;
$$;