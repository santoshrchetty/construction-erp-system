-- =====================================================
-- DATA INTEGRITY FIX AND PREVENTION
-- =====================================================

-- 1. Fix current broken relationships
-- Update plant N00101 to reference correct company
UPDATE plants 
SET company_code_id = (SELECT id FROM company_codes WHERE company_code = 'N001')
WHERE plant_code = 'N00101' AND company_code_id IS NULL;

-- 2. Add missing foreign key constraints if not exist
DO $$ 
BEGIN
    -- Check and add plants -> company_codes constraint
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'plants_company_code_id_fkey'
    ) THEN
        ALTER TABLE plants 
        ADD CONSTRAINT plants_company_code_id_fkey 
        FOREIGN KEY (company_code_id) REFERENCES company_codes(id) 
        ON DELETE RESTRICT ON UPDATE CASCADE;
    END IF;

    -- Check and add storage_locations -> plants constraint
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'storage_locations_plant_id_fkey'
    ) THEN
        ALTER TABLE storage_locations 
        ADD CONSTRAINT storage_locations_plant_id_fkey 
        FOREIGN KEY (plant_id) REFERENCES plants(id) 
        ON DELETE RESTRICT ON UPDATE CASCADE;
    END IF;

    -- Check and add stock_balances -> storage_locations constraint
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'stock_balances_storage_location_id_fkey'
    ) THEN
        ALTER TABLE stock_balances 
        ADD CONSTRAINT stock_balances_storage_location_id_fkey 
        FOREIGN KEY (storage_location_id) REFERENCES storage_locations(id) 
        ON DELETE RESTRICT ON UPDATE CASCADE;
    END IF;

    -- Check and add stock_balances -> stock_items constraint
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'stock_balances_stock_item_id_fkey'
    ) THEN
        ALTER TABLE stock_balances 
        ADD CONSTRAINT stock_balances_stock_item_id_fkey 
        FOREIGN KEY (stock_item_id) REFERENCES stock_items(id) 
        ON DELETE RESTRICT ON UPDATE CASCADE;
    END IF;
END $$;

-- 3. Create data integrity validation function
CREATE OR REPLACE FUNCTION validate_data_integrity()
RETURNS TABLE(
    table_name TEXT,
    issue_type TEXT,
    issue_count BIGINT,
    details TEXT
) AS $$
BEGIN
    -- Check orphaned plants
    RETURN QUERY
    SELECT 
        'plants'::TEXT,
        'orphaned_records'::TEXT,
        COUNT(*)::BIGINT,
        'Plants without valid company references'::TEXT
    FROM plants p 
    LEFT JOIN company_codes c ON p.company_code_id = c.id 
    WHERE c.id IS NULL AND p.company_code_id IS NOT NULL;

    -- Check orphaned storage locations
    RETURN QUERY
    SELECT 
        'storage_locations'::TEXT,
        'orphaned_records'::TEXT,
        COUNT(*)::BIGINT,
        'Storage locations without valid plant references'::TEXT
    FROM storage_locations sl 
    LEFT JOIN plants p ON sl.plant_id = p.id 
    WHERE p.id IS NULL AND sl.plant_id IS NOT NULL;

    -- Check orphaned stock balances
    RETURN QUERY
    SELECT 
        'stock_balances'::TEXT,
        'orphaned_records'::TEXT,
        COUNT(*)::BIGINT,
        'Stock balances without valid storage location references'::TEXT
    FROM stock_balances sb 
    LEFT JOIN storage_locations sl ON sb.storage_location_id = sl.id 
    WHERE sl.id IS NULL AND sb.storage_location_id IS NOT NULL;

    RETURN QUERY
    SELECT 
        'stock_balances'::TEXT,
        'orphaned_items'::TEXT,
        COUNT(*)::BIGINT,
        'Stock balances without valid stock item references'::TEXT
    FROM stock_balances sb 
    LEFT JOIN stock_items si ON sb.stock_item_id = si.id 
    WHERE si.id IS NULL AND sb.stock_item_id IS NOT NULL;
END;
$$ LANGUAGE plpgsql;

-- 4. Create monitoring view for data integrity
CREATE OR REPLACE VIEW data_integrity_monitor AS
SELECT * FROM validate_data_integrity();

-- 5. Run validation to check current state
SELECT 'Data Integrity Check Results:' as status;
SELECT * FROM data_integrity_monitor;