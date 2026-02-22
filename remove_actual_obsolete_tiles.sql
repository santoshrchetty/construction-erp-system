-- Remove obsolete document tiles (keeping core document management)
DELETE FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' 
AND id IN (
  'd45e0f3a-6c7f-46ee-9ac1-dd084430f47a', -- Contract Amendments
  '730a2176-f7cd-4147-ac06-342456f592fb', -- Create Contract
  'b975bad2-07a8-4824-80cb-640f62a2a27a', -- Create Specification
  '318a41c4-2646-4571-9c45-d8174aad675b', -- Respond to RFIs
  '36711f92-fe0c-4320-9f0b-24a07e009e12', -- Review Submittals
  '31b03a7b-b205-47dc-9334-b87945d1d1ce', -- Create Inspection
  '8db6a71f-1900-47de-9a5c-0da49e766710'  -- Quality Inspections
);

-- Verify remaining document tiles (should only show core ones)
SELECT 
  title, 
  subtitle, 
  route, 
  auth_object, 
  is_active
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' 
AND (
  title ILIKE '%document%' 
  OR title ILIKE '%contract%' 
  OR title ILIKE '%rfi%' 
  OR title ILIKE '%spec%' 
  OR title ILIKE '%submittal%'
)
ORDER BY title;