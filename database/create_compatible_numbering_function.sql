-- Create function that works with the existing table structure
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
  v_prefix text;
BEGIN
  -- Lock the row to prevent concurrent access
  SELECT current_number::bigint, prefix INTO v_current_number, v_prefix
  FROM public.document_number_ranges
  WHERE company_code = p_company_code
    AND document_type = p_document_type
    AND number_range_group = p_number_range_group
    AND fiscal_year = p_fiscal_year::integer
    AND tenant_id = v_tenant_id
    AND status = 'ACTIVE'
  FOR UPDATE;
  
  -- If no record exists, create a simple one for MR
  IF v_current_number IS NULL AND p_document_type = 'MR' THEN
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
      description
    ) VALUES (
      p_company_code, 
      p_document_type, 
      p_number_range_group, 
      p_fiscal_year::integer,
      '000001',
      '999999', 
      '000001',
      1,
      999999,
      'ACTIVE',
      p_document_type,
      v_tenant_id,
      1,
      'Material Request Numbers'
    );
    v_next_number := 1;
    v_prefix := p_document_type;
  ELSE
    -- Increment the current number
    v_next_number := v_current_number + 1;
    
    -- Update the current number
    UPDATE public.document_number_ranges
    SET current_number = v_next_number::text,
        modified_at = now()
    WHERE company_code = p_company_code
      AND document_type = p_document_type
      AND number_range_group = p_number_range_group
      AND fiscal_year = p_fiscal_year::integer
      AND tenant_id = v_tenant_id;
  END IF;
  
  -- Format the number with leading zeros (6 digits)
  v_formatted_number := lpad(v_next_number::text, 6, '0');
  
  -- Return the complete document number
  RETURN p_document_type || '-' || p_number_range_group || '-' || p_fiscal_year || '-' || v_formatted_number;
END;
$$;