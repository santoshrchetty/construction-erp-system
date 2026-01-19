-- Fix FK constraint: Point to subcontractors instead of vendors

-- 1. Drop the incorrect FK constraint
ALTER TABLE activity_subcontractors 
DROP CONSTRAINT IF EXISTS activity_subcontractors_subcontractor_id_fkey;

-- 2. Rename vendors back to subcontractors (if it was renamed)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'vendors' AND table_schema = 'public') THEN
        ALTER TABLE vendors RENAME TO subcontractors;
        RAISE NOTICE 'Renamed vendors to subcontractors';
    END IF;
END $$;

-- 3. Add correct FK constraint pointing to subcontractors
ALTER TABLE activity_subcontractors 
ADD CONSTRAINT activity_subcontractors_subcontractor_id_fkey 
FOREIGN KEY (subcontractor_id) REFERENCES subcontractors(id);

-- 4. Verify
SELECT 
    tc.constraint_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'activity_subcontractors'
  AND tc.constraint_type = 'FOREIGN KEY'
  AND kcu.column_name = 'subcontractor_id';

COMMENT ON TABLE subcontractors IS 'Subcontractors Master - Work execution contractors (separate from vendors/suppliers)';
