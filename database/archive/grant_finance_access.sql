-- Check User Finance Permissions
-- ===============================

-- Check current users
SELECT 'Current Users' as check_type;
SELECT * FROM users ORDER BY created_at DESC LIMIT 5;