-- Create minimal Project P100 for testing
INSERT INTO projects (
    code, name, status, budget, start_date
) VALUES (
    'P100',
    'Office Building Construction',
    'active',
    5000000.00,
    '2024-01-15'
) ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    status = EXCLUDED.status,
    budget = EXCLUDED.budget;

-- Verify creation
SELECT code, name, status, budget FROM projects WHERE code = 'P100';