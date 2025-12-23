-- Add Account Assignment Category support
ALTER TABLE movement_types ADD COLUMN IF NOT EXISTS account_assignment_category VARCHAR(1);
ALTER TABLE movement_types ADD COLUMN IF NOT EXISTS wbs_mandatory BOOLEAN DEFAULT false;

-- Update movement types with account assignment categories
UPDATE movement_types SET 
    account_assignment_category = CASE 
        WHEN movement_type = '101' THEN NULL  -- Standard GR (no assignment)
        WHEN movement_type = '261' THEN 'P'   -- Issue to Project (WBS mandatory)
        WHEN movement_type = '201' THEN 'K'   -- Issue to Cost Center
        ELSE NULL
    END,
    wbs_mandatory = CASE 
        WHEN movement_type = '261' THEN true  -- Project movements require WBS
        ELSE false
    END;

-- Add WBS element reference to material movements
ALTER TABLE material_movements ADD COLUMN IF NOT EXISTS wbs_element_id UUID REFERENCES wbs_nodes(id);
ALTER TABLE material_movements ADD COLUMN IF NOT EXISTS cost_center_id UUID;
ALTER TABLE material_movements ADD COLUMN IF NOT EXISTS account_assignment_category VARCHAR(1);

-- Create project-specific movement types
INSERT INTO movement_types (movement_type, movement_name, movement_indicator, description, account_assignment_category, wbs_mandatory) VALUES
('Q01', 'GR to Project Stock', '+', 'Goods Receipt directly to Project Stock', 'P', true),
('Q02', 'Issue from Project Stock', '-', 'Issue from Project Stock to WBS', 'P', true),
('411', 'Transfer to Project Stock', '=', 'Transfer from Unrestricted to Project Stock', 'P', true),
('412', 'Transfer from Project Stock', '=', 'Transfer from Project Stock to Unrestricted', 'P', true)
ON CONFLICT (movement_type) DO UPDATE SET
    account_assignment_category = EXCLUDED.account_assignment_category,
    wbs_mandatory = EXCLUDED.wbs_mandatory;

-- Show movement types with account assignment
SELECT 
    movement_type,
    movement_name,
    movement_indicator,
    account_assignment_category,
    wbs_mandatory,
    CASE 
        WHEN account_assignment_category = 'P' THEN 'Project (WBS Element)'
        WHEN account_assignment_category = 'K' THEN 'Cost Center'
        WHEN account_assignment_category IS NULL THEN 'No Assignment'
        ELSE account_assignment_category
    END as assignment_description
FROM movement_types 
ORDER BY movement_type;