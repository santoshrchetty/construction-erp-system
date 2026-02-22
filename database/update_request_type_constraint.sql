-- Update request_type constraint to include all MR types
-- First, drop the constraint (don't validate existing rows)
ALTER TABLE material_requests DROP CONSTRAINT IF EXISTS material_requests_request_type_check;

-- Fix any invalid existing values
UPDATE material_requests 
SET request_type = 'GENERAL' 
WHERE request_type NOT IN ('PROJECT', 'MAINTENANCE', 'OFFICE', 'SAFETY', 'EQUIPMENT', 'GENERAL', 'PRODUCTION', 'QUALITY', 'ASSET')
   OR request_type IS NULL;

-- Now add the new constraint
ALTER TABLE material_requests ADD CONSTRAINT material_requests_request_type_check 
CHECK (request_type IN ('PROJECT', 'MAINTENANCE', 'OFFICE', 'SAFETY', 'EQUIPMENT', 'GENERAL', 'PRODUCTION', 'QUALITY', 'ASSET'));
