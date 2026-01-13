-- Fix the numbering system by resetting counter to match actual projects
UPDATE project_numbering_rules 
SET current_number = (
  SELECT COALESCE(
    MAX(CAST(SUBSTRING(code FROM 'HW-(\d+)') AS INTEGER)), 
    0
  )
  FROM projects 
  WHERE code ~ '^HW-\d+$'
)
WHERE pattern = 'HW-{####}';

-- Verify the fix
SELECT 
  pattern,
  current_number,
  (SELECT COUNT(*) FROM projects WHERE code LIKE 'HW-%') as actual_projects
FROM project_numbering_rules 
WHERE pattern = 'HW-{####}';