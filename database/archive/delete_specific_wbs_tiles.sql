-- Delete specific WBS Management tiles by ID
-- ============================================

DELETE FROM tiles 
WHERE id IN (
  'c0b56116-8bde-4d9c-8c24-6ee324ade567',
  '59b31c87-d1b0-4723-9cd2-2e795bcfef3f'
);

-- Verify only WBS Editor remains
SELECT id, title, auth_object, is_active
FROM tiles 
WHERE title ILIKE '%WBS%'
ORDER BY title, auth_object;