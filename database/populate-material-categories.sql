-- =====================================================
-- POPULATE NULL MATERIAL CATEGORIES (FIXED)
-- Based on description keywords and material names
-- =====================================================

-- First, ensure we have all standard construction material categories
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

-- Populate NULL categories (NO updated_at)
UPDATE materials SET category = 'CEMENT'
WHERE category IS NULL AND (LOWER(description) LIKE '%cement%' OR LOWER(material_name) LIKE '%cement%' OR LOWER(description) LIKE '%portland%');

UPDATE materials SET category = 'AGGREGATE'
WHERE category IS NULL AND (LOWER(description) LIKE '%aggregate%' OR LOWER(material_name) LIKE '%aggregate%' OR LOWER(description) LIKE '%sand%' OR LOWER(description) LIKE '%gravel%' OR LOWER(description) LIKE '%stone%');

UPDATE materials SET category = 'STEEL'
WHERE category IS NULL AND (LOWER(description) LIKE '%steel%' OR LOWER(material_name) LIKE '%steel%' OR LOWER(description) LIKE '%iron%' OR LOWER(description) LIKE '%rod%' OR LOWER(description) LIKE '%bar%' OR LOWER(description) LIKE '%rebar%' OR LOWER(description) LIKE '%structural%');

UPDATE materials SET category = 'CONCRETE'
WHERE category IS NULL AND (LOWER(description) LIKE '%concrete%' OR LOWER(material_name) LIKE '%concrete%' OR LOWER(description) LIKE '%ready-mix%' OR LOWER(description) LIKE '%ready mix%');

UPDATE materials SET category = 'BRICK'
WHERE category IS NULL AND (LOWER(description) LIKE '%brick%' OR LOWER(material_name) LIKE '%brick%' OR LOWER(description) LIKE '%block%' OR LOWER(description) LIKE '%masonry%');

UPDATE materials SET category = 'ELECTRICAL'
WHERE category IS NULL AND (LOWER(description) LIKE '%electrical%' OR LOWER(material_name) LIKE '%electrical%' OR LOWER(description) LIKE '%wire%' OR LOWER(description) LIKE '%cable%' OR LOWER(description) LIKE '%switch%' OR LOWER(description) LIKE '%breaker%' OR LOWER(description) LIKE '%conduit%');

UPDATE materials SET category = 'PLUMBING'
WHERE category IS NULL AND (LOWER(description) LIKE '%plumbing%' OR LOWER(material_name) LIKE '%plumbing%' OR LOWER(description) LIKE '%pipe%' OR LOWER(description) LIKE '%fitting%' OR LOWER(description) LIKE '%valve%' OR LOWER(description) LIKE '%tap%');

UPDATE materials SET category = 'PAINTS'
WHERE category IS NULL AND (LOWER(description) LIKE '%paint%' OR LOWER(material_name) LIKE '%paint%' OR LOWER(description) LIKE '%varnish%' OR LOWER(description) LIKE '%coating%' OR LOWER(description) LIKE '%primer%');

UPDATE materials SET category = 'TIMBER'
WHERE category IS NULL AND (LOWER(description) LIKE '%timber%' OR LOWER(material_name) LIKE '%timber%' OR LOWER(description) LIKE '%wood%' OR LOWER(description) LIKE '%lumber%' OR LOWER(description) LIKE '%plywood%');

UPDATE materials SET category = 'HARDWARE'
WHERE category IS NULL AND (LOWER(description) LIKE '%hardware%' OR LOWER(material_name) LIKE '%hardware%' OR LOWER(description) LIKE '%bolt%' OR LOWER(description) LIKE '%nut%' OR LOWER(description) LIKE '%screw%' OR LOWER(description) LIKE '%fastener%');

UPDATE materials SET category = 'TILES'
WHERE category IS NULL AND (LOWER(description) LIKE '%tile%' OR LOWER(material_name) LIKE '%tile%' OR LOWER(description) LIKE '%ceramic%' OR LOWER(description) LIKE '%vitrified%' OR LOWER(description) LIKE '%flooring%');

UPDATE materials SET category = 'GLASS'
WHERE category IS NULL AND (LOWER(description) LIKE '%glass%' OR LOWER(material_name) LIKE '%glass%' OR LOWER(description) LIKE '%window%' OR LOWER(description) LIKE '%glazing%');

UPDATE materials SET category = 'MARBLE'
WHERE category IS NULL AND (LOWER(description) LIKE '%marble%' OR LOWER(material_name) LIKE '%marble%' OR LOWER(description) LIKE '%granite%' OR LOWER(description) LIKE '%stone%');

UPDATE materials SET category = 'SANITARY'
WHERE category IS NULL AND (LOWER(description) LIKE '%sanitary%' OR LOWER(material_name) LIKE '%sanitary%' OR LOWER(description) LIKE '%basin%' OR LOWER(description) LIKE '%bathtub%' OR LOWER(description) LIKE '%fixture%' OR LOWER(description) LIKE '%toilet%');

UPDATE materials SET category = 'DOORS'
WHERE category IS NULL AND (LOWER(description) LIKE '%door%' OR LOWER(material_name) LIKE '%door%' OR LOWER(description) LIKE '%frame%' OR LOWER(description) LIKE '%shutter%');

UPDATE materials SET category = 'HVAC'
WHERE category IS NULL AND (LOWER(description) LIKE '%hvac%' OR LOWER(material_name) LIKE '%hvac%' OR LOWER(description) LIKE '%air conditioning%' OR LOWER(description) LIKE '%ac unit%');

UPDATE materials SET category = 'INSULATION'
WHERE category IS NULL AND (LOWER(description) LIKE '%insulation%' OR LOWER(material_name) LIKE '%insulation%' OR LOWER(description) LIKE '%thermal%' OR LOWER(description) LIKE '%acoustic%');

UPDATE materials SET category = 'DAMP_PROOF'
WHERE category IS NULL AND (LOWER(description) LIKE '%waterproof%' OR LOWER(material_name) LIKE '%waterproof%' OR LOWER(description) LIKE '%damp proof%' OR LOWER(description) LIKE '%dampproof%' OR LOWER(description) LIKE '%sealant%');

UPDATE materials SET category = 'CONSUMABLE'
WHERE category IS NULL AND (LOWER(description) LIKE '%consumable%' OR LOWER(material_name) LIKE '%consumable%' OR LOWER(description) LIKE '%supply%' OR LOWER(description) LIKE '%material supply%');

-- Set remaining NULL categories to 'OTHER'
UPDATE materials SET category = 'OTHER' WHERE category IS NULL;

-- Verify results
SELECT category, COUNT(*) as material_count
FROM materials
GROUP BY category
ORDER BY category;als
WHERE category IS NOT NULL
GROUP BY category
ORDER BY count DESC;

-- Show any materials that still might need manual review
SELECT 
    id,
    material_code,
    material_name,
    description,
    category
FROM materials
WHERE category = 'OTHER'
ORDER BY material_name;
