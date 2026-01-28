-- =====================================================
-- COMPLETE MATERIAL SETUP SCRIPT (Updated Schema)
-- Run this script to populate categories AND groups
-- =====================================================

-- STEP 1: Populate Material Categories
INSERT INTO material_categories (category_code, category_name, description, is_active)
VALUES
    ('CEMENT', 'Cement Products', 'Portland cement and cement-based products', true),
    ('AGGREGATE', 'Aggregates', 'Sand, gravel, and stone aggregates', true),
    ('STEEL', 'Steel Products', 'Steel bars, sections, and structural steel', true),
    ('CONCRETE', 'Concrete Products', 'Ready-mix concrete and concrete products', true),
    ('BRICK', 'Bricks & Blocks', 'Bricks, blocks, and masonry units', true),
    ('ELECTRICAL', 'Electrical Materials', 'Wiring, cables, switches, and electrical equipment', true),
    ('PLUMBING', 'Plumbing Materials', 'Pipes, fittings, and sanitary fixtures', true),
    ('PAINTS', 'Paints & Coatings', 'Paints, varnishes, and protective coatings', true),
    ('TIMBER', 'Timber & Wood', 'Wooden materials and lumber', true),
    ('HARDWARE', 'Hardware & Fasteners', 'Bolts, nuts, screws, and hardware', true),
    ('TILES', 'Tiles & Flooring', 'Ceramic, vitrified, and floor tiles', true),
    ('GLASS', 'Glass & Glazing', 'Glass panes, windows, and glazing materials', true),
    ('MARBLE', 'Marble & Stones', 'Marble, granite, and natural stone', true),
    ('SANITARY', 'Sanitary Fixtures', 'Bathtubs, basins, and sanitary ware', true),
    ('DOORS', 'Doors & Frames', 'Doors, frames, and door hardware', true),
    ('HVAC', 'HVAC Equipment', 'Heating, ventilation, and air conditioning equipment', true),
    ('INSULATION', 'Insulation Materials', 'Thermal and acoustic insulation', true),
    ('DAMP_PROOF', 'Damp Proof Materials', 'Waterproofing and damp-proof materials', true),
    ('CONSUMABLE', 'Consumables', 'Consumable items and supplies', true),
    ('OTHER', 'Other Materials', 'Other miscellaneous materials', true)
ON CONFLICT (category_code) DO NOTHING;

-- STEP 2: Populate Material Groups
INSERT INTO material_groups (group_code, group_name, category_code, description, is_active)
VALUES
    ('CEMENT-OPC', 'Ordinary Portland Cement', 'CEMENT', 'OPC cement grades', true),
    ('CEMENT-PPC', 'Portland Pozzolana Cement', 'CEMENT', 'PPC cement', true),
    ('CEMENT-PSC', 'Portland Slag Cement', 'CEMENT', 'PSC cement', true),
    ('STEEL-REBAR', 'Reinforcement Bars', 'STEEL', 'TMT bars and rebars', true),
    ('STEEL-STRUCT', 'Structural Steel', 'STEEL', 'Beams, columns, channels', true),
    ('STEEL-SHEET', 'Steel Sheets', 'STEEL', 'Steel sheets and plates', true),
    ('STEEL-WIRE', 'Steel Wire', 'STEEL', 'Binding wire and mesh', true),
    ('AGG-SAND', 'Sand', 'AGGREGATE', 'River sand, M-sand', true),
    ('AGG-GRAVEL', 'Gravel', 'AGGREGATE', 'Coarse aggregates', true),
    ('AGG-STONE', 'Stone Aggregates', 'AGGREGATE', 'Crushed stone', true),
    ('CONC-RMC', 'Ready Mix Concrete', 'CONCRETE', 'RMC various grades', true),
    ('CONC-BLOCKS', 'Concrete Blocks', 'CONCRETE', 'Precast blocks', true),
    ('BRICK-RED', 'Red Bricks', 'BRICK', 'Clay bricks', true),
    ('BRICK-FLY', 'Fly Ash Bricks', 'BRICK', 'Fly ash bricks', true),
    ('BRICK-AAC', 'AAC Blocks', 'BRICK', 'Autoclaved aerated concrete', true),
    ('ELEC-WIRE', 'Electrical Wires', 'ELECTRICAL', 'Copper wires and cables', true),
    ('ELEC-SWITCH', 'Switches & Sockets', 'ELECTRICAL', 'Electrical fittings', true),
    ('ELEC-CONDUIT', 'Conduits', 'ELECTRICAL', 'PVC conduits', true),
    ('PLUMB-PIPE', 'Pipes', 'PLUMBING', 'PVC, CPVC, GI pipes', true),
    ('PLUMB-FITTING', 'Pipe Fittings', 'PLUMBING', 'Elbows, tees, couplings', true),
    ('PLUMB-VALVE', 'Valves', 'PLUMBING', 'Gate valves, ball valves', true),
    ('PAINT-EMUL', 'Emulsion Paints', 'PAINTS', 'Water-based paints', true),
    ('PAINT-ENAMEL', 'Enamel Paints', 'PAINTS', 'Oil-based paints', true),
    ('PAINT-PRIMER', 'Primers', 'PAINTS', 'Base coats', true),
    ('TIMBER-HARD', 'Hardwood', 'TIMBER', 'Teak, oak timber', true),
    ('TIMBER-SOFT', 'Softwood', 'TIMBER', 'Pine, fir timber', true),
    ('TIMBER-PLY', 'Plywood', 'TIMBER', 'Plywood sheets', true),
    ('HARD-BOLT', 'Bolts & Nuts', 'HARDWARE', 'Fasteners', true),
    ('HARD-NAIL', 'Nails & Screws', 'HARDWARE', 'Fixing materials', true),
    ('TILE-FLOOR', 'Floor Tiles', 'TILES', 'Vitrified floor tiles', true),
    ('TILE-WALL', 'Wall Tiles', 'TILES', 'Ceramic wall tiles', true),
    ('SAN-WC', 'Water Closets', 'SANITARY', 'Toilets', true),
    ('SAN-BASIN', 'Wash Basins', 'SANITARY', 'Basins and sinks', true),
    ('SAN-BATH', 'Bath Fittings', 'SANITARY', 'Taps and showers', true)
ON CONFLICT (group_code) DO NOTHING;

-- STEP 3: Populate Categories in Materials Table
UPDATE materials SET category = 'CEMENT' WHERE category IS NULL AND (LOWER(description) LIKE '%cement%' OR LOWER(material_name) LIKE '%cement%' OR LOWER(description) LIKE '%portland%');
UPDATE materials SET category = 'STEEL' WHERE category IS NULL AND (LOWER(description) LIKE '%steel%' OR LOWER(material_name) LIKE '%steel%' OR LOWER(description) LIKE '%rebar%' OR LOWER(description) LIKE '%tmt%');
UPDATE materials SET category = 'AGGREGATE' WHERE category IS NULL AND (LOWER(description) LIKE '%sand%' OR LOWER(description) LIKE '%gravel%' OR LOWER(description) LIKE '%aggregate%');
UPDATE materials SET category = 'CONCRETE' WHERE category IS NULL AND (LOWER(description) LIKE '%concrete%' OR LOWER(description) LIKE '%ready mix%');
UPDATE materials SET category = 'BRICK' WHERE category IS NULL AND (LOWER(description) LIKE '%brick%' OR LOWER(description) LIKE '%block%');
UPDATE materials SET category = 'ELECTRICAL' WHERE category IS NULL AND (LOWER(description) LIKE '%wire%' OR LOWER(description) LIKE '%cable%' OR LOWER(description) LIKE '%switch%');
UPDATE materials SET category = 'PLUMBING' WHERE category IS NULL AND (LOWER(description) LIKE '%pipe%' OR LOWER(description) LIKE '%valve%' OR LOWER(description) LIKE '%plumbing%');
UPDATE materials SET category = 'PAINTS' WHERE category IS NULL AND (LOWER(description) LIKE '%paint%' OR LOWER(description) LIKE '%primer%');
UPDATE materials SET category = 'TIMBER' WHERE category IS NULL AND (LOWER(description) LIKE '%timber%' OR LOWER(description) LIKE '%wood%' OR LOWER(description) LIKE '%plywood%');
UPDATE materials SET category = 'HARDWARE' WHERE category IS NULL AND (LOWER(description) LIKE '%bolt%' OR LOWER(description) LIKE '%screw%' OR LOWER(description) LIKE '%nail%');
UPDATE materials SET category = 'TILES' WHERE category IS NULL AND (LOWER(description) LIKE '%tile%' OR LOWER(description) LIKE '%flooring%');
UPDATE materials SET category = 'SANITARY' WHERE category IS NULL AND (LOWER(description) LIKE '%basin%' OR LOWER(description) LIKE '%toilet%' OR LOWER(description) LIKE '%tap%');
UPDATE materials SET category = 'OTHER' WHERE category IS NULL;

-- STEP 4: Populate Groups in Materials Table
UPDATE materials SET material_group = 'CEMENT-OPC' WHERE category = 'CEMENT' AND material_group IS NULL AND (LOWER(description) LIKE '%opc%' OR LOWER(material_name) LIKE '%opc%');
UPDATE materials SET material_group = 'CEMENT-PPC' WHERE category = 'CEMENT' AND material_group IS NULL AND (LOWER(description) LIKE '%ppc%' OR LOWER(description) LIKE '%pozzolana%');
UPDATE materials SET material_group = 'STEEL-REBAR' WHERE category = 'STEEL' AND material_group IS NULL AND (LOWER(description) LIKE '%rebar%' OR LOWER(material_name) LIKE '%rebar%' OR LOWER(description) LIKE '%tmt%');
UPDATE materials SET material_group = 'STEEL-STRUCT' WHERE category = 'STEEL' AND material_group IS NULL AND (LOWER(description) LIKE '%beam%' OR LOWER(description) LIKE '%structural%');
UPDATE materials SET material_group = 'AGG-SAND' WHERE category = 'AGGREGATE' AND material_group IS NULL AND (LOWER(description) LIKE '%sand%' OR LOWER(material_name) LIKE '%sand%');
UPDATE materials SET material_group = 'AGG-GRAVEL' WHERE category = 'AGGREGATE' AND material_group IS NULL AND (LOWER(description) LIKE '%gravel%' OR LOWER(description) LIKE '%coarse%');
UPDATE materials SET material_group = 'CONC-RMC' WHERE category = 'CONCRETE' AND material_group IS NULL AND (LOWER(description) LIKE '%ready mix%' OR LOWER(description) LIKE '%rmc%');
UPDATE materials SET material_group = 'BRICK-RED' WHERE category = 'BRICK' AND material_group IS NULL AND (LOWER(description) LIKE '%red brick%' OR LOWER(description) LIKE '%clay%');
UPDATE materials SET material_group = 'BRICK-AAC' WHERE category = 'BRICK' AND material_group IS NULL AND (LOWER(description) LIKE '%aac%' OR LOWER(description) LIKE '%autoclaved%');
UPDATE materials SET material_group = 'ELEC-WIRE' WHERE category = 'ELECTRICAL' AND material_group IS NULL AND (LOWER(description) LIKE '%wire%' OR LOWER(description) LIKE '%cable%');
UPDATE materials SET material_group = 'ELEC-SWITCH' WHERE category = 'ELECTRICAL' AND material_group IS NULL AND (LOWER(description) LIKE '%switch%' OR LOWER(description) LIKE '%socket%');
UPDATE materials SET material_group = 'PLUMB-PIPE' WHERE category = 'PLUMBING' AND material_group IS NULL AND (LOWER(description) LIKE '%pipe%' OR LOWER(material_name) LIKE '%pipe%');
UPDATE materials SET material_group = 'PLUMB-VALVE' WHERE category = 'PLUMBING' AND material_group IS NULL AND (LOWER(description) LIKE '%valve%' OR LOWER(description) LIKE '%tap%');
UPDATE materials SET material_group = 'PAINT-EMUL' WHERE category = 'PAINTS' AND material_group IS NULL AND (LOWER(description) LIKE '%emulsion%');
UPDATE materials SET material_group = 'PAINT-PRIMER' WHERE category = 'PAINTS' AND material_group IS NULL AND (LOWER(description) LIKE '%primer%' OR LOWER(material_name) LIKE '%primer%');
UPDATE materials SET material_group = 'TIMBER-PLY' WHERE category = 'TIMBER' AND material_group IS NULL AND (LOWER(description) LIKE '%plywood%' OR LOWER(material_name) LIKE '%plywood%');
UPDATE materials SET material_group = 'HARD-BOLT' WHERE category = 'HARDWARE' AND material_group IS NULL AND (LOWER(description) LIKE '%bolt%' OR LOWER(description) LIKE '%nut%');
UPDATE materials SET material_group = 'HARD-NAIL' WHERE category = 'HARDWARE' AND material_group IS NULL AND (LOWER(description) LIKE '%nail%' OR LOWER(description) LIKE '%screw%');
UPDATE materials SET material_group = 'TILE-FLOOR' WHERE category = 'TILES' AND material_group IS NULL AND (LOWER(description) LIKE '%floor%' OR LOWER(description) LIKE '%vitrified%');
UPDATE materials SET material_group = 'SAN-WC' WHERE category = 'SANITARY' AND material_group IS NULL AND (LOWER(description) LIKE '%toilet%' OR LOWER(description) LIKE '%wc%');
UPDATE materials SET material_group = 'SAN-BASIN' WHERE category = 'SANITARY' AND material_group IS NULL AND (LOWER(description) LIKE '%basin%' OR LOWER(description) LIKE '%sink%');

-- Verification
SELECT 'Categories populated' as step, COUNT(*) as total, COUNT(CASE WHEN category IS NOT NULL THEN 1 END) as with_category FROM materials
UNION ALL
SELECT 'Groups populated' as step, COUNT(*) as total, COUNT(CASE WHEN material_group IS NOT NULL THEN 1 END) as with_group FROM materials;
