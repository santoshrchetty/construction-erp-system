-- =====================================================
-- POPULATE REMAINING MATERIAL GROUPS
-- For specialty categories
-- =====================================================

-- Insert additional groups
INSERT INTO material_groups (group_code, group_name, category_code, description, is_active)
VALUES
    -- POWER Groups
    ('POWER-GEN', 'Generators', 'POWER', 'Power generators and equipment', true),
    ('POWER-DIST', 'Distribution', 'POWER', 'Power distribution equipment', true),
    
    -- SIGNAGE Groups
    ('SIGN-SAFETY', 'Safety Signage', 'SIGNAGE', 'Safety and warning signs', true),
    ('SIGN-INFO', 'Information Signage', 'SIGNAGE', 'Directional and info signs', true),
    
    -- ASPHALT Groups
    ('ASPH-MIX', 'Asphalt Mix', 'ASPHALT', 'Hot and cold asphalt mixes', true),
    ('ASPH-SEAL', 'Sealants', 'ASPHALT', 'Asphalt sealants and coatings', true),
    
    -- DRAINAGE Groups
    ('DRAIN-PIPE', 'Drainage Pipes', 'DRAINAGE', 'Drainage pipes and channels', true),
    ('DRAIN-GRATE', 'Grates & Covers', 'DRAINAGE', 'Drain covers and grates', true),
    
    -- SAFETY Groups
    ('SAFE-PPE', 'PPE', 'SAFETY', 'Personal protective equipment', true),
    ('SAFE-BARRIER', 'Barriers', 'SAFETY', 'Safety barriers and fencing', true),
    
    -- FINISHING Groups
    ('FINISH-PLASTER', 'Plaster', 'FINISHING', 'Plaster and finishing compounds', true),
    ('FINISH-PUTTY', 'Putty', 'FINISHING', 'Wall putty and fillers', true),
    
    -- CEMENT catch-all
    ('CEMENT-OTHER', 'Other Cement', 'CEMENT', 'Other cement products', true),
    
    -- CONCRETE catch-all
    ('CONC-OTHER', 'Other Concrete', 'CONCRETE', 'Other concrete products', true),
    
    -- PLUMBING catch-all
    ('PLUMB-OTHER', 'Other Plumbing', 'PLUMBING', 'Other plumbing materials', true),
    
    -- OTHER catch-all
    ('OTHER-MISC', 'Miscellaneous', 'OTHER', 'Other miscellaneous items', true)
ON CONFLICT (group_code) DO NOTHING;

-- =====================================================
-- POPULATE MATERIAL_GROUP FOR REMAINING MATERIALS
-- =====================================================

-- POWER Groups
UPDATE materials SET material_group = 'POWER-GEN'
WHERE category = 'POWER' AND material_group IS NULL
AND (LOWER(description) LIKE '%generator%' OR LOWER(material_name) LIKE '%generator%');

UPDATE materials SET material_group = 'POWER-DIST'
WHERE category = 'POWER' AND material_group IS NULL;

-- SIGNAGE Groups
UPDATE materials SET material_group = 'SIGN-SAFETY'
WHERE category = 'SIGNAGE' AND material_group IS NULL
AND (LOWER(description) LIKE '%safety%' OR LOWER(description) LIKE '%warning%');

UPDATE materials SET material_group = 'SIGN-INFO'
WHERE category = 'SIGNAGE' AND material_group IS NULL;

-- ASPHALT Groups
UPDATE materials SET material_group = 'ASPH-MIX'
WHERE category = 'ASPHALT' AND material_group IS NULL
AND (LOWER(description) LIKE '%mix%' OR LOWER(description) LIKE '%hot%' OR LOWER(description) LIKE '%cold%');

UPDATE materials SET material_group = 'ASPH-SEAL'
WHERE category = 'ASPHALT' AND material_group IS NULL;

-- DRAINAGE Groups
UPDATE materials SET material_group = 'DRAIN-PIPE'
WHERE category = 'DRAINAGE' AND material_group IS NULL
AND (LOWER(description) LIKE '%pipe%' OR LOWER(description) LIKE '%channel%');

UPDATE materials SET material_group = 'DRAIN-GRATE'
WHERE category = 'DRAINAGE' AND material_group IS NULL;

-- SAFETY Groups
UPDATE materials SET material_group = 'SAFE-PPE'
WHERE category = 'SAFETY' AND material_group IS NULL
AND (LOWER(description) LIKE '%helmet%' OR LOWER(description) LIKE '%glove%' 
     OR LOWER(description) LIKE '%vest%' OR LOWER(description) LIKE '%ppe%');

UPDATE materials SET material_group = 'SAFE-BARRIER'
WHERE category = 'SAFETY' AND material_group IS NULL;

-- FINISHING Groups
UPDATE materials SET material_group = 'FINISH-PLASTER'
WHERE category = 'FINISHING' AND material_group IS NULL
AND (LOWER(description) LIKE '%plaster%' OR LOWER(material_name) LIKE '%plaster%');

UPDATE materials SET material_group = 'FINISH-PUTTY'
WHERE category = 'FINISHING' AND material_group IS NULL
AND (LOWER(description) LIKE '%putty%' OR LOWER(material_name) LIKE '%putty%');

-- Catch-all for remaining ungrouped materials
UPDATE materials SET material_group = 'CEMENT-OTHER'
WHERE category = 'CEMENT' AND material_group IS NULL;

UPDATE materials SET material_group = 'CONC-OTHER'
WHERE category = 'CONCRETE' AND material_group IS NULL;

UPDATE materials SET material_group = 'PLUMB-OTHER'
WHERE category = 'PLUMBING' AND material_group IS NULL;

UPDATE materials SET material_group = 'OTHER-MISC'
WHERE category = 'OTHER' AND material_group IS NULL;

-- Verify results
SELECT 
    category,
    COUNT(*) as ungrouped_count
FROM materials
WHERE category IS NOT NULL AND material_group IS NULL
GROUP BY category
ORDER BY ungrouped_count DESC;
