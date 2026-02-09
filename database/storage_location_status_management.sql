-- Storage Location Status Management
-- Enhanced schema to handle many locations over time

-- Update storage_locations table with status and lifecycle fields
ALTER TABLE storage_locations 
ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'ACTIVE' 
    CHECK (status IN ('ACTIVE', 'INACTIVE', 'CLOSED', 'ARCHIVED', 'PLANNED')),
ADD COLUMN IF NOT EXISTS project_code VARCHAR(50), -- Link to project if site-specific
ADD COLUMN IF NOT EXISTS start_date DATE,
ADD COLUMN IF NOT EXISTS end_date DATE,
ADD COLUMN IF NOT EXISTS can_receive BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS can_issue BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS is_default_location BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS sort_order INTEGER DEFAULT 999,
ADD COLUMN IF NOT EXISTS last_activity_date DATE,
ADD COLUMN IF NOT EXISTS created_by VARCHAR(50),
ADD COLUMN IF NOT EXISTS updated_by VARCHAR(50),
ADD COLUMN IF NOT EXISTS notes TEXT;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_storage_locations_status ON storage_locations(status);
CREATE INDEX IF NOT EXISTS idx_storage_locations_type ON storage_locations(location_type);
CREATE INDEX IF NOT EXISTS idx_storage_locations_project ON storage_locations(project_code);
CREATE INDEX IF NOT EXISTS idx_storage_locations_active ON storage_locations(plant_code, status) WHERE status = 'ACTIVE';

-- Storage location lifecycle management
CREATE TABLE IF NOT EXISTS storage_location_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plant_code VARCHAR(4) NOT NULL,
    sloc_code VARCHAR(31) NOT NULL,
    old_status VARCHAR(20),
    new_status VARCHAR(20),
    change_reason VARCHAR(100),
    changed_by VARCHAR(50),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

-- Function to update storage location status
CREATE OR REPLACE FUNCTION update_storage_location_status(
    p_plant_code VARCHAR(4),
    p_sloc_code VARCHAR(31),
    p_new_status VARCHAR(20),
    p_reason VARCHAR(100),
    p_user VARCHAR(50)
) RETURNS VOID AS $$
DECLARE
    v_old_status VARCHAR(20);
BEGIN
    -- Get current status
    SELECT status INTO v_old_status
    FROM storage_locations
    WHERE plant_code = p_plant_code 
    AND sloc_code = p_sloc_code;
    
    -- Update status
    UPDATE storage_locations
    SET status = p_new_status,
        updated_by = p_user,
        end_date = CASE WHEN p_new_status IN ('CLOSED', 'ARCHIVED') THEN CURRENT_DATE ELSE end_date END
    WHERE plant_code = p_plant_code 
    AND sloc_code = p_sloc_code;
    
    -- Log history
    INSERT INTO storage_location_history (
        plant_code, sloc_code, old_status, new_status, 
        change_reason, changed_by
    ) VALUES (
        p_plant_code, p_sloc_code, v_old_status, p_new_status,
        p_reason, p_user
    );
END;
$$ LANGUAGE plpgsql;

-- View for active storage locations (for dropdowns)
CREATE OR REPLACE VIEW active_storage_locations AS
SELECT 
    sl.plant_code,
    sl.sloc_code,
    sl.sloc_name,
    sl.location_type,
    sl.status,
    sl.project_code,
    p.name as project_name,
    sl.can_receive,
    sl.can_issue,
    sl.is_default_location,
    sl.sort_order,
    sl.last_activity_date,
    CASE 
        WHEN sl.project_code IS NOT NULL AND p.status = 'ACTIVE' THEN 'PROJECT_ACTIVE'
        WHEN sl.project_code IS NOT NULL AND p.status != 'ACTIVE' THEN 'PROJECT_INACTIVE'
        ELSE 'GENERAL'
    END as location_group
FROM storage_locations sl
LEFT JOIN projects p ON sl.project_code = p.code
WHERE sl.is_active = true
ORDER BY 
    sl.is_default_location DESC,
    location_group,
    sl.sort_order,
    sl.sloc_name;

-- Function to get filtered storage locations for dropdown
CREATE OR REPLACE FUNCTION get_storage_locations_for_dropdown(
    p_plant_code VARCHAR(4) DEFAULT NULL,
    p_include_inactive BOOLEAN DEFAULT false,
    p_location_type VARCHAR(20) DEFAULT NULL,
    p_project_code VARCHAR(50) DEFAULT NULL
) RETURNS TABLE (
    plant_code VARCHAR(4),
    sloc_code VARCHAR(31),
    sloc_name VARCHAR(240),
    location_type VARCHAR(20),
    status VARCHAR(20),
    project_name VARCHAR(100),
    display_text VARCHAR(300),
    is_default BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        sl.plant_code,
        sl.sloc_code,
        sl.sloc_name,
        sl.location_type,
        sl.status,
        COALESCE(p.name, '') as project_name,
        CASE 
            WHEN sl.project_code IS NOT NULL THEN 
                sl.sloc_name || ' (' || COALESCE(p.name, 'Unknown Project') || ')'
            ELSE 
                sl.sloc_name
        END as display_text,
        sl.is_default_location
    FROM storage_locations sl
    LEFT JOIN projects p ON sl.project_code = p.code
    WHERE 
        (p_plant_code IS NULL OR sl.plant_code = p_plant_code)
        AND (p_include_inactive = true OR sl.is_active = true)
        AND (p_location_type IS NULL OR sl.location_type = p_location_type)
        AND (p_project_code IS NULL OR sl.project_code = p_project_code OR sl.project_code IS NULL)
        AND sl.can_receive = true
    ORDER BY 
        sl.is_default_location DESC,
        CASE 
            WHEN sl.project_code IS NOT NULL AND p.status = 'ACTIVE' THEN 1
            WHEN sl.project_code IS NULL THEN 2
            ELSE 3
        END,
        sl.sort_order,
        sl.sloc_name;
END;
$$ LANGUAGE plpgsql;

-- Example usage queries
-- Get active locations for dropdown
SELECT * FROM get_storage_locations_for_dropdown('P001');

-- Get only warehouse locations
SELECT * FROM get_storage_locations_for_dropdown('P001', false, 'WAREHOUSE');

-- Get locations for specific project
SELECT * FROM get_storage_locations_for_dropdown('P001', false, NULL, 'PRJ001');

-- Close a storage location
SELECT update_storage_location_status('P001', 'SL01', 'CLOSED', 'Project completed', 'USER123');