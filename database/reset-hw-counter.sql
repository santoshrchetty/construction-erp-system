-- Reset HW pattern counter to start from 1
UPDATE project_numbering_rules 
SET current_number = 0 
WHERE pattern = 'HW-{####}';

-- Verify the reset
SELECT pattern, current_number FROM project_numbering_rules WHERE pattern = 'HW-{####}';