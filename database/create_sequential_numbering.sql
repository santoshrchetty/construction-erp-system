-- Create document number ranges table
CREATE TABLE IF NOT EXISTS public.document_number_ranges (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  company_code character varying(4) NOT NULL,
  document_type character varying(10) NOT NULL,
  number_range_group character varying(10) NOT NULL,
  fiscal_year character varying(4) NOT NULL,
  current_number integer NOT NULL DEFAULT 0,
  from_number integer NOT NULL DEFAULT 1,
  to_number integer NOT NULL DEFAULT 999999,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  tenant_id uuid NOT NULL DEFAULT '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid,
  CONSTRAINT document_number_ranges_pkey PRIMARY KEY (id),
  CONSTRAINT document_number_ranges_unique UNIQUE (company_code, document_type, number_range_group, fiscal_year, tenant_id)
);

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_document_number_ranges_lookup 
ON public.document_number_ranges (company_code, document_type, number_range_group, fiscal_year, tenant_id);

-- Create RPC function to get next sequential number
CREATE OR REPLACE FUNCTION public.get_next_number_by_group(
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
  -- Lock the row to prevent concurrent access
  SELECT current_number INTO v_current_number
  FROM public.document_number_ranges
  WHERE company_code = p_company_code
    AND document_type = p_document_type
    AND number_range_group = p_number_range_group
    AND fiscal_year = p_fiscal_year
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
    WHERE company_code = p_company_code
      AND document_type = p_document_type
      AND number_range_group = p_number_range_group
      AND fiscal_year = p_fiscal_year
      AND tenant_id = v_tenant_id;
  END IF;
  
  -- Format the number with leading zeros (6 digits)
  v_formatted_number := lpad(v_next_number::text, 6, '0');
  
  -- Return the complete document number
  RETURN p_document_type || '-' || p_number_range_group || '-' || p_fiscal_year || '-' || v_formatted_number;
END;
$$;

-- Initialize number ranges for common document types
INSERT INTO public.document_number_ranges (
  company_code, document_type, number_range_group, fiscal_year, current_number, tenant_id
) VALUES 
  ('1000', 'MR', '01', '2026', 0, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid),
  ('1000', 'PR', '01', '2026', 0, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid),
  ('1000', 'PO', '01', '2026', 0, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid)
ON CONFLICT (company_code, document_type, number_range_group, fiscal_year, tenant_id) 
DO NOTHING;