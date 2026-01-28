-- Populate Material Categories ONLY
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

SELECT category_code, category_name FROM material_categories ORDER BY category_code;
