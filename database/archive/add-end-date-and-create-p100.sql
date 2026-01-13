-- Add end_date column to projects table for baseline management
ALTER TABLE projects ADD COLUMN IF NOT EXISTS end_date DATE;

-- Create Project P100 with proper baseline dates
INSERT INTO projects (
    code, name, description, status, budget, start_date, end_date, project_type, planned_end_date
) VALUES (
    'P100',
    'Office Building Construction',
    'Modern office building construction project with 10 floors and underground parking',
    'active',
    5000000.00,
    '2024-01-15',
    '2024-12-31',
    'commercial',
    '2024-12-31'
) ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    status = EXCLUDED.status,
    budget = EXCLUDED.budget,
    start_date = EXCLUDED.start_date,
    end_date = EXCLUDED.end_date,
    project_type = EXCLUDED.project_type,
    planned_end_date = EXCLUDED.planned_end_date;

-- Verify creation
SELECT code, name, status, budget, start_date, end_date FROM projects WHERE code = 'P100';