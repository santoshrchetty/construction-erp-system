-- Standardize module names to lowercase friendly format
-- Current: MM, PS, Finance, ADMIN, etc. (18 modules)
-- Target: materials, projects, finance, admin, etc.

UPDATE authorization_objects SET module = 'materials' WHERE module IN ('MM', 'materials');
UPDATE authorization_objects SET module = 'projects' WHERE module = 'PS';
UPDATE authorization_objects SET module = 'finance' WHERE module IN ('Finance', 'FI');
UPDATE authorization_objects SET module = 'admin' WHERE module = 'ADMIN';
UPDATE authorization_objects SET module = 'warehouse' WHERE module = 'WM';
UPDATE authorization_objects SET module = 'quality' WHERE module = 'QM';
UPDATE authorization_objects SET module = 'hr' WHERE module = 'HR';
UPDATE authorization_objects SET module = 'safety' WHERE module = 'EH';
UPDATE authorization_objects SET module = 'documents' WHERE module = 'DOCS';
UPDATE authorization_objects SET module = 'configuration' WHERE module IN ('configuration', 'CG');

-- Verify - should show 18 modules with lowercase names
SELECT module, COUNT(*) as count FROM authorization_objects GROUP BY module ORDER BY count DESC;
