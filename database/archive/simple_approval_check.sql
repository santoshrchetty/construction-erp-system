-- SIMPLE CHECK OF APPROVAL_POLICIES COLUMNS
SELECT * FROM approval_policies LIMIT 1;

-- If that fails, try this
SELECT column_name FROM information_schema.columns WHERE table_name = 'approval_policies';