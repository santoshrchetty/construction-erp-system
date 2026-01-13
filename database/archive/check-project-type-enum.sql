-- Check valid project_type enum values
SELECT enumlabel as valid_project_types 
FROM pg_enum 
WHERE enumtypid = (SELECT oid FROM pg_type WHERE typname = 'project_type');