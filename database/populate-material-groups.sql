-- =====================================================
-- POPULATE MATERIAL GROUPS
-- Based on material descriptions and names
-- =====================================================

-- First, ensure material groups exist
INSERT INTO material_groups (group_code, group_name, category_code, description, is_active)
VALUES
    -- CEMENT Groups
    ('CEMENT-OPC', 'Ordinary Portland Cement', 'CEMENT', 'OPC cement grades', true),
    ('CEMENT-PPC', 'Portland Pozzolana Cement', 'CEMENT', 'PPC cement', true),
    ('CEMENT-PSC', 'Portland Slag Cement', 'CEMENT', 'PSC cement', true),
    
    -- STEEL Groups
    ('STEEL-REBAR', 'Reinforcement Bars', 'STEEL', 'TMT bars and rebars', true),
    ('STEEL-STRUCT', 'Structural Steel', 'STEEL', 'Beams, columns, channels', true),
    ('STEEL-SHEET', 'Steel Sheets', 'STEEL', 'Steel sheets and plates', true),
    ('STEEL-WIRE', 'Steel Wire', 'STEEL', 'Binding wire and mesh', true),
    
    -- AGGREGATE Groups
    ('AGG-SAND', 'Sand', 'AGGREGATE', 'River sand, M-sand', true),
    ('AGG-GRAVEL', 'Gravel', 'AGGREGATE', 'Coarse aggregates', true),
    ('AGG-STONE', 'Stone Aggregates', 'AGGREGATE', 'Crushed stone', true),
    
    -- CONCRETE Groups
    ('CONC-RMC', 'Ready Mix Concrete', 'CONCRETE', 'RMC various grades', true),
    ('CONC-BLOCKS', 'Concrete Blocks', 'CONCRETE', 'Precast blocks', true),
    
    -- BRICK Groups
    ('BRICK-RED', 'Red Bricks', 'BRICK', 'Clay bricks', true),
    ('BRICK-FLY', 'Fly Ash Bricks', 'BRICK', 'Fly ash bricks', true),
    ('BRICK-AAC', 'AAC Blocks', 'BRICK', 'Autoclaved aerated concrete', true),
    
    -- ELECTRICAL Groups
    ('ELEC-WIRE', 'Electrical Wires', 'ELECTRICAL', 'Copper wires and cables', true),
    ('ELEC-SWITCH', 'Switches & Sockets', 'ELECTRICAL', 'Electrical fittings', true),
    ('ELEC-CONDUIT', 'Conduits', 'ELECTRICAL', 'PVC conduits', true),
    
    -- PLUMBING Groups
    ('PLUMB-PIPE', 'Pipes', 'PLUMBING', 'PVC, CPVC, GI pipes', true),
    ('PLUMB-FITTING', 'Pipe Fittings', 'PLUMBING', 'Elbows, tees, couplings', true),
    ('PLUMB-VALVE', 'Valves', 'PLUMBING', 'Gate valves, ball valves', true),
    
    -- PAINTS Groups
    ('PAINT-EMUL', 'Emulsion Paints', 'PAINTS', 'Water-based paints', true),
    ('PAINT-ENAMEL', 'Enamel Paints', 'PAINTS', 'Oil-based paints', true),
    ('PAINT-PRIMER', 'Primers', 'PAINTS', 'Base coats', true),
    
    -- TIMBER Groups
    ('TIMBER-HARD', 'Hardwood', 'TIMBER', 'Teak, oak timber', true),
    ('TIMBER-SOFT', 'Softwood', 'TIMBER', 'Pine, fir timber', true),
    ('TIMBER-PLY', 'Plywood', 'TIMBER', 'Plywood sheets', true),
    
    -- HARDWARE Groups
    ('HARD-BOLT', 'Bolts & Nuts', 'HARDWARE', 'Fasteners', true),
    ('HARD-NAIL', 'Nails & Screws', 'HARDWARE', 'Fixing materials', true),
    
    -- TILES Groups
    ('TILE-FLOOR', 'Floor Tiles', 'TILES', 'Vitrified floor tiles', true),
    ('TILE-WALL', 'Wall Tiles', 'TILES', 'Ceramic wall tiles', true),
    
    -- SANITARY Groups
    ('SAN-WC', 'Water Closets', 'SANITARY', 'Toilets', true),
    ('SAN-BASIN', 'Wash Basins', 'SANITARY', 'Basins and sinks', true),
    ('SAN-BATH', 'Bath Fittings', 'SANITARY', 'Taps and showers', true)
ON CONFLICT (group_code) DO NOTHING;

-- =====================================================
-- POPULATE MATERIAL_GROUP COLUMN
-- =====================================================

-- CEMENT Groups
UPDATE materials SET material_group = 'CEMENT-OPC'
WHERE category = 'CEMENT' AND material_group IS NULL
AND (LOWER(description) LIKE '%opc%' OR LOWER(material_name) LIKE '%opc%' OR LOWER(description) LIKE '%ordinary portland%');

UPDATE materials SET material_group = 'CEMENT-PPC'
WHERE category = 'CEMENT' AND material_group IS NULL
AND (LOWER(description) LIKE '%ppc%' OR LOWER(material_name) LIKE '%ppc%' OR LOWER(description) LIKE '%pozzolana%');

UPDATE materials SET material_group = 'CEMENT-PSC'
WHERE category = 'CEMENT' AND material_group IS NULL
AND (LOWER(description) LIKE '%psc%' OR LOWER(material_name) LIKE '%psc%' OR LOWER(description) LIKE '%slag%');

-- STEEL Groups
UPDATE materials SET material_group = 'STEEL-REBAR'
WHERE category = 'STEEL' AND material_group IS NULL
AND (LOWER(description) LIKE '%rebar%' OR LOWER(material_name) LIKE '%rebar%' 
     OR LOWER(description) LIKE '%tmt%' OR LOWER(material_name) LIKE '%tmt%'
     OR LOWER(description) LIKE '%reinforcement%' OR LOWER(description) LIKE '%bar%');

UPDATE materials SET material_group = 'STEEL-STRUCT'
WHERE category = 'STEEL' AND material_group IS NULL
AND (LOWER(description) LIKE '%beam%' OR LOWER(description) LIKE '%column%' 
     OR LOWER(description) LIKE '%channel%' OR LOWER(description) LIKE '%angle%'
     OR LOWER(description) LIKE '%structural%');

UPDATE materials SET material_group = 'STEEL-SHEET'
WHERE category = 'STEEL' AND material_group IS NULL
AND (LOWER(description) LIKE '%sheet%' OR LOWER(description) LIKE '%plate%');

UPDATE materials SET material_group = 'STEEL-WIRE'
WHERE category = 'STEEL' AND material_group IS NULL
AND (LOWER(description) LIKE '%wire%' OR LOWER(description) LIKE '%mesh%' OR LOWER(description) LIKE '%binding%');

-- AGGREGATE Groups
UPDATE materials SET material_group = 'AGG-SAND'
WHERE category = 'AGGREGATE' AND material_group IS NULL
AND (LOWER(description) LIKE '%sand%' OR LOWER(material_name) LIKE '%sand%' 
     OR LOWER(description) LIKE '%m-sand%' OR LOWER(description) LIKE '%fine aggregate%');

UPDATE materials SET material_group = 'AGG-GRAVEL'
WHERE category = 'AGGREGATE' AND material_group IS NULL
AND (LOWER(description) LIKE '%gravel%' OR LOWER(description) LIKE '%coarse aggregate%'
     OR LOWER(description) LIKE '%20mm%' OR LOWER(description) LIKE '%40mm%');

UPDATE materials SET material_group = 'AGG-STONE'
WHERE category = 'AGGREGATE' AND material_group IS NULL
AND (LOWER(description) LIKE '%stone%' OR LOWER(description) LIKE '%crushed%');

-- CONCRETE Groups
UPDATE materials SET material_group = 'CONC-RMC'
WHERE category = 'CONCRETE' AND material_group IS NULL
AND (LOWER(description) LIKE '%ready mix%' OR LOWER(description) LIKE '%rmc%' 
     OR LOWER(description) LIKE '%m15%' OR LOWER(description) LIKE '%m20%' 
     OR LOWER(description) LIKE '%m25%' OR LOWER(description) LIKE '%m30%');

UPDATE materials SET material_group = 'CONC-BLOCKS'
WHERE category = 'CONCRETE' AND material_group IS NULL
AND (LOWER(description) LIKE '%block%' OR LOWER(description) LIKE '%precast%');

-- BRICK Groups
UPDATE materials SET material_group = 'BRICK-RED'
WHERE category = 'BRICK' AND material_group IS NULL
AND (LOWER(description) LIKE '%red brick%' OR LOWER(description) LIKE '%clay brick%');

UPDATE materials SET material_group = 'BRICK-FLY'
WHERE category = 'BRICK' AND material_group IS NULL
AND (LOWER(description) LIKE '%fly ash%' OR LOWER(material_name) LIKE '%fly ash%');

UPDATE materials SET material_group = 'BRICK-AAC'
WHERE category = 'BRICK' AND material_group IS NULL
AND (LOWER(description) LIKE '%aac%' OR LOWER(description) LIKE '%autoclaved%');

-- ELECTRICAL Groups
UPDATE materials SET material_group = 'ELEC-WIRE'
WHERE category = 'ELECTRICAL' AND material_group IS NULL
AND (LOWER(description) LIKE '%wire%' OR LOWER(description) LIKE '%cable%');

UPDATE materials SET material_group = 'ELEC-SWITCH'
WHERE category = 'ELECTRICAL' AND material_group IS NULL
AND (LOWER(description) LIKE '%switch%' OR LOWER(description) LIKE '%socket%');

UPDATE materials SET material_group = 'ELEC-CONDUIT'
WHERE category = 'ELECTRICAL' AND material_group IS NULL
AND (LOWER(description) LIKE '%conduit%' OR LOWER(description) LIKE '%duct%');

-- PLUMBING Groups
UPDATE materials SET material_group = 'PLUMB-PIPE'
WHERE category = 'PLUMBING' AND material_group IS NULL
AND (LOWER(description) LIKE '%pipe%' OR LOWER(material_name) LIKE '%pipe%');

UPDATE materials SET material_group = 'PLUMB-FITTING'
WHERE category = 'PLUMBING' AND material_group IS NULL
AND (LOWER(description) LIKE '%fitting%' OR LOWER(description) LIKE '%elbow%' 
     OR LOWER(description) LIKE '%tee%' OR LOWER(description) LIKE '%coupling%');

UPDATE materials SET material_group = 'PLUMB-VALVE'
WHERE category = 'PLUMBING' AND material_group IS NULL
AND (LOWER(description) LIKE '%valve%' OR LOWER(description) LIKE '%tap%');

-- PAINTS Groups
UPDATE materials SET material_group = 'PAINT-EMUL'
WHERE category = 'PAINTS' AND material_group IS NULL
AND (LOWER(description) LIKE '%emulsion%' OR LOWER(description) LIKE '%water based%');

UPDATE materials SET material_group = 'PAINT-ENAMEL'
WHERE category = 'PAINTS' AND material_group IS NULL
AND (LOWER(description) LIKE '%enamel%' OR LOWER(description) LIKE '%oil based%');

UPDATE materials SET material_group = 'PAINT-PRIMER'
WHERE category = 'PAINTS' AND material_group IS NULL
AND (LOWER(description) LIKE '%primer%' OR LOWER(material_name) LIKE '%primer%');

-- TIMBER Groups
UPDATE materials SET material_group = 'TIMBER-HARD'
WHERE category = 'TIMBER' AND material_group IS NULL
AND (LOWER(description) LIKE '%teak%' OR LOWER(description) LIKE '%oak%' OR LOWER(description) LIKE '%hardwood%');

UPDATE materials SET material_group = 'TIMBER-SOFT'
WHERE category = 'TIMBER' AND material_group IS NULL
AND (LOWER(description) LIKE '%pine%' OR LOWER(description) LIKE '%fir%' OR LOWER(description) LIKE '%softwood%');

UPDATE materials SET material_group = 'TIMBER-PLY'
WHERE category = 'TIMBER' AND material_group IS NULL
AND (LOWER(description) LIKE '%plywood%' OR LOWER(material_name) LIKE '%plywood%' OR LOWER(description) LIKE '%ply%');

-- HARDWARE Groups
UPDATE materials SET material_group = 'HARD-BOLT'
WHERE category = 'HARDWARE' AND material_group IS NULL
AND (LOWER(description) LIKE '%bolt%' OR LOWER(description) LIKE '%nut%');

UPDATE materials SET material_group = 'HARD-NAIL'
WHERE category = 'HARDWARE' AND material_group IS NULL
AND (LOWER(description) LIKE '%nail%' OR LOWER(description) LIKE '%screw%');

-- TILES Groups
UPDATE materials SET material_group = 'TILE-FLOOR'
WHERE category = 'TILES' AND material_group IS NULL
AND (LOWER(description) LIKE '%floor%' OR LOWER(description) LIKE '%vitrified%');

UPDATE materials SET material_group = 'TILE-WALL'
WHERE category = 'TILES' AND material_group IS NULL
AND (LOWER(description) LIKE '%wall%' OR LOWER(description) LIKE '%ceramic%');

-- SANITARY Groups
UPDATE materials SET material_group = 'SAN-WC'
WHERE category = 'SANITARY' AND material_group IS NULL
AND (LOWER(description) LIKE '%wc%' OR LOWER(description) LIKE '%toilet%' OR LOWER(description) LIKE '%water closet%');

UPDATE materials SET material_group = 'SAN-BASIN'
WHERE category = 'SANITARY' AND material_group IS NULL
AND (LOWER(description) LIKE '%basin%' OR LOWER(description) LIKE '%sink%');

UPDATE materials SET material_group = 'SAN-BATH'
WHERE category = 'SANITARY' AND material_group IS NULL
AND (LOWER(description) LIKE '%tap%' OR LOWER(description) LIKE '%faucet%' OR LOWER(description) LIKE '%shower%');

-- Verify results
SELECT 
    category,
    material_group,
    COUNT(*) as material_count
FROM materials
WHERE category IS NOT NULL
GROUP BY category, material_group
ORDER BY category, material_group;

-- Show materials without groups
SELECT 
    category,
    COUNT(*) as ungrouped_count
FROM materials
WHERE category IS NOT NULL AND material_group IS NULL
GROUP BY category
ORDER BY ungrouped_count DESC;
