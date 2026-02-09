-- Map SAP module codes to friendly names for UI display
-- Current: PS, MM, etc.
-- Target: projects, materials, procurement, etc.

UPDATE authorization_objects SET module = 'projects' WHERE module = 'PS';
UPDATE authorization_objects SET module = 'materials' WHERE module = 'MM';
UPDATE authorization_objects SET module = 'finance' WHERE module = 'FI';
UPDATE authorization_objects SET module = 'procurement' WHERE module IN ('MM', 'PO');
UPDATE authorization_objects SET module = 'hr' WHERE module = 'HR';
UPDATE authorization_objects SET module = 'admin' WHERE module IN ('AD', 'ADMIN');
UPDATE authorization_objects SET module = 'warehouse' WHERE module = 'WM';
UPDATE authorization_objects SET module = 'quality' WHERE module = 'QM';
UPDATE authorization_objects SET module = 'maintenance' WHERE module = 'PM';

-- Verify
SELECT module, COUNT(*) as count FROM authorization_objects GROUP BY module ORDER BY count DESC;
