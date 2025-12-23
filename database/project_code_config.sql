-- Project Code Configuration (SAP-style)
CREATE TABLE project_code_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_category VARCHAR(50) NOT NULL,
    code_prefix VARCHAR(10) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default project code templates
INSERT INTO project_code_templates (project_category, code_prefix, description) VALUES
('Airport', 'AIR', 'Airport construction projects'),
('Bridge', 'BRD', 'Bridge and overpass projects'),
('Building', 'BLD', 'Commercial and residential buildings'),
('Highway', 'HWY', 'Highway and road construction'),
('Railway', 'RLY', 'Railway and metro projects'),
('Port', 'PRT', 'Port and marine infrastructure'),
('Industrial', 'IND', 'Industrial facilities'),
('Residential', 'RES', 'Residential complexes'),
('Commercial', 'COM', 'Commercial complexes'),
('Infrastructure', 'INF', 'General infrastructure');

-- Function to generate next project code
CREATE OR REPLACE FUNCTION generate_project_code(p_category VARCHAR)
RETURNS VARCHAR AS $$
DECLARE
    prefix VARCHAR(10);
    year_suffix VARCHAR(2);
    next_number INTEGER;
    new_code VARCHAR(50);
BEGIN
    -- Get prefix for category
    SELECT code_prefix INTO prefix 
    FROM project_code_templates 
    WHERE project_category = p_category AND is_active = true
    LIMIT 1;
    
    IF prefix IS NULL THEN
        prefix := 'PRJ'; -- Default prefix
    END IF;
    
    -- Get current year suffix (last 2 digits)
    year_suffix := RIGHT(EXTRACT(YEAR FROM NOW())::TEXT, 2);
    
    -- Get next sequential number for this prefix and year
    SELECT COALESCE(MAX(
        CASE 
            WHEN code ~ ('^' || prefix || '-' || year_suffix || '-[0-9]+$')
            THEN CAST(RIGHT(code, LENGTH(code) - LENGTH(prefix || '-' || year_suffix || '-')) AS INTEGER)
            ELSE 0
        END
    ), 0) + 1 INTO next_number
    FROM projects 
    WHERE code LIKE prefix || '-' || year_suffix || '-%';
    
    -- Format: PREFIX-YY-NN (e.g., AIR-24-01)
    new_code := prefix || '-' || year_suffix || '-' || LPAD(next_number::TEXT, 2, '0');
    
    RETURN new_code;
END;
$$ LANGUAGE plpgsql;