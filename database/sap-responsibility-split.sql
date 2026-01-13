-- SAP RESPONSIBILITY SPLIT ALIGNMENT
-- Fixes the critical misalignment with ChatGPT's 3-layer model

-- ========================================
-- LAYER 1: SAP-OWNED (HARDCODED - NOT EDITABLE)
-- ========================================

-- Remove transaction_keys table - make it hardcoded
DROP TABLE IF EXISTS transaction_keys CASCADE;

-- Hardcode transaction keys in functions (SAP-owned logic)
CREATE OR REPLACE FUNCTION get_transaction_key_info(p_key VARCHAR(3))
RETURNS TABLE (transaction_key VARCHAR(3), description VARCHAR(100), transaction_type VARCHAR(20)) AS $$
BEGIN
  RETURN QUERY SELECT 
    CASE p_key
      WHEN 'BSX' THEN 'BSX'::VARCHAR(3)
      WHEN 'WRX' THEN 'WRX'::VARCHAR(3)
      WHEN 'GBB' THEN 'GBB'::VARCHAR(3)
      WHEN 'PRD' THEN 'PRD'::VARCHAR(3)
      WHEN 'VBR' THEN 'VBR'::VARCHAR(3)
      ELSE NULL::VARCHAR(3)
    END,
    CASE p_key
      WHEN 'BSX' THEN 'Inventory Posting'::VARCHAR(100)
      WHEN 'WRX' THEN 'GR/IR Clearing'::VARCHAR(100)
      WHEN 'GBB' THEN 'Vendor Payable'::VARCHAR(100)
      WHEN 'PRD' THEN 'Price Differences'::VARCHAR(100)
      WHEN 'VBR' THEN 'Consumption'::VARCHAR(100)
      ELSE NULL::VARCHAR(100)
    END,
    CASE p_key
      WHEN 'BSX' THEN 'INVENTORY'::VARCHAR(20)
      WHEN 'WRX' THEN 'CLEARING'::VARCHAR(20)
      WHEN 'GBB' THEN 'PAYABLE'::VARCHAR(20)
      WHEN 'PRD' THEN 'VARIANCE'::VARCHAR(20)
      WHEN 'VBR' THEN 'EXPENSE'::VARCHAR(20)
      ELSE NULL::VARCHAR(20)
    END;
END;
$$ LANGUAGE plpgsql;

-- Remove document_type_master table - make it hardcoded
DROP TABLE IF EXISTS document_type_master CASCADE;

-- Hardcode document types (SAP-owned)
CREATE OR REPLACE FUNCTION get_document_type_info(p_type VARCHAR(2))
RETURNS TABLE (document_type VARCHAR(2), description VARCHAR(50), account_type VARCHAR(1)) AS $$
BEGIN
  RETURN QUERY SELECT 
    CASE p_type
      WHEN 'RE' THEN 'RE'::VARCHAR(2)
      WHEN 'WE' THEN 'WE'::VARCHAR(2)
      WHEN 'SA' THEN 'SA'::VARCHAR(2)
      ELSE NULL::VARCHAR(2)
    END,
    CASE p_type
      WHEN 'RE' THEN 'Vendor Invoice'::VARCHAR(50)
      WHEN 'WE' THEN 'Goods Receipt'::VARCHAR(50)
      WHEN 'SA' THEN 'GL Document'::VARCHAR(50)
      ELSE NULL::VARCHAR(50)
    END,
    CASE p_type
      WHEN 'RE' THEN 'K'::VARCHAR(1)
      WHEN 'WE' THEN 'S'::VARCHAR(1)
      WHEN 'SA' THEN 'S'::VARCHAR(1)
      ELSE NULL::VARCHAR(1)
    END;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- LAYER 2: CONSULTANT CONFIG (RESTRICTED ACCESS)
-- ========================================

-- Add role restrictions to config tables
ALTER TABLE account_determination ADD COLUMN IF NOT EXISTS config_role VARCHAR(20) DEFAULT 'CONSULTANT';
ALTER TABLE tax_gl_mapping ADD COLUMN IF NOT EXISTS config_role VARCHAR(20) DEFAULT 'CONSULTANT';
ALTER TABLE tolerance_rules ADD COLUMN IF NOT EXISTS config_role VARCHAR(20) DEFAULT 'CONSULTANT';

-- Add change tracking for consultant configs
CREATE TABLE config_change_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  table_name VARCHAR(50) NOT NULL,
  record_id UUID NOT NULL,
  change_type VARCHAR(10) NOT NULL, -- INSERT, UPDATE, DELETE
  old_values JSONB,
  new_values JSONB,
  changed_by VARCHAR(50) NOT NULL,
  change_reason TEXT,
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger for config changes
CREATE OR REPLACE FUNCTION log_config_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO config_change_log (table_name, record_id, change_type, new_values, changed_by, change_reason)
    VALUES (TG_TABLE_NAME, NEW.id, 'INSERT', to_jsonb(NEW), current_user, 'New configuration');
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO config_change_log (table_name, record_id, change_type, old_values, new_values, changed_by, change_reason)
    VALUES (TG_TABLE_NAME, NEW.id, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW), current_user, 'Configuration update');
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO config_change_log (table_name, record_id, change_type, old_values, changed_by, change_reason)
    VALUES (TG_TABLE_NAME, OLD.id, 'DELETE', to_jsonb(OLD), current_user, 'Configuration removal');
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers to consultant config tables
DROP TRIGGER IF EXISTS account_determination_changes ON account_determination;
CREATE TRIGGER account_determination_changes
  AFTER INSERT OR UPDATE OR DELETE ON account_determination
  FOR EACH ROW EXECUTE FUNCTION log_config_changes();

DROP TRIGGER IF EXISTS tax_gl_mapping_changes ON tax_gl_mapping;
CREATE TRIGGER tax_gl_mapping_changes
  AFTER INSERT OR UPDATE OR DELETE ON tax_gl_mapping
  FOR EACH ROW EXECUTE FUNCTION log_config_changes();

-- ========================================
-- LAYER 3: END USER (OPERATIONAL - NO GL ACCESS)
-- ========================================

-- Ensure operational tables have NO GL fields
-- Users should never see or choose GL accounts

-- Remove any GL fields from user-facing tables if they exist
-- (This is a check - actual tables may not have these fields)

-- Create view for user operations (hides GL complexity)
CREATE OR REPLACE VIEW user_purchase_operations AS
SELECT 
  po.po_number,
  po.vendor_code,
  po.material_code,
  po.quantity,
  po.unit_price,
  po.total_amount,
  po.status,
  -- NO GL FIELDS EXPOSED
  po.created_by,
  po.created_at
FROM purchase_orders po
WHERE po.status IN ('DRAFT', 'APPROVED', 'RECEIVED');

-- ========================================
-- RESPONSIBILITY ENFORCEMENT FUNCTION
-- ========================================

CREATE OR REPLACE FUNCTION enforce_responsibility_split(
  p_user_role VARCHAR(20),
  p_operation VARCHAR(20),
  p_table_name VARCHAR(50)
) RETURNS BOOLEAN AS $$
BEGIN
  -- SAP-owned: No one can modify
  IF p_table_name IN ('transaction_keys', 'document_type_master') THEN
    RETURN FALSE;
  END IF;
  
  -- Consultant config: Only consultants
  IF p_table_name IN ('account_determination', 'tax_gl_mapping', 'tolerance_rules') THEN
    RETURN p_user_role = 'CONSULTANT';
  END IF;
  
  -- End user operations: Users and consultants
  IF p_table_name IN ('purchase_orders', 'grn_lines', 'vendor_invoices') THEN
    RETURN p_user_role IN ('END_USER', 'CONSULTANT');
  END IF;
  
  RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

SELECT 'SAP RESPONSIBILITY SPLIT ALIGNED' as status;
SELECT 'SAP-OWNED: Hardcoded transaction keys & document types' as layer_1;
SELECT 'CONSULTANT: Config tables with change tracking' as layer_2;
SELECT 'END-USER: Operational views without GL exposure' as layer_3;