-- Check what modules exist in the system
SELECT DISTINCT module FROM authorization_objects WHERE is_active = true ORDER BY module;

-- Check what the "unknown Module" contains
SELECT * FROM authorization_objects WHERE module IS NULL OR module = '' OR module = 'unknown';

-- Update the material request permissions to use MM module instead
UPDATE authorization_objects 
SET module = 'MM' 
WHERE object_name IN ('MAT_REQ_READ', 'MAT_REQ_WRITE');