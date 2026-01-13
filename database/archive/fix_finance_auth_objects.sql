-- Check Missing Finance Authorization Objects
-- ==========================================

-- Check which Finance tiles are NOT being returned by API
SELECT 'Finance Tiles NOT in API Response' as check_type;
SELECT t.title, t.auth_object, 
       CASE WHEN ua.user_id IS NULL THEN 'NO USER AUTH' ELSE 'HAS USER AUTH' END as auth_status
FROM tiles t
LEFT JOIN authorization_objects ao ON t.auth_object = ao.object_name
LEFT JOIN user_authorizations ua ON ao.id = ua.auth_object_id 
    AND ua.user_id = (SELECT id FROM users WHERE email LIKE '%@nttdemo.com' LIMIT 1)
WHERE t.tile_category = 'Finance'
  AND t.auth_object NOT IN ('FI_CST_REVIEW', 'CO_BDG_MODIFY', 'CO_CTC_ANALYZE')
ORDER BY t.title;

-- Add missing authorization objects if they don't exist
INSERT INTO authorization_objects (object_name, description, module, is_active)
VALUES 
('FI_GL_DISP', 'FI GL Account Display', 'FI', true),
('FI_GL_POST', 'FI GL Posting', 'FI', true),
('FI_DOC_DIS', 'FI Document Display', 'FI', true),
('FI_DOC_REV', 'FI Document Reversal', 'FI', true),
('FI_PER_CLO', 'FI Period Closing', 'FI', true),
('FI_REPORTS', 'FI Reporting', 'FI', true),
('FI_CASHFLO', 'FI Cash Flow', 'FI', true),
('CO_PRJ_DIS', 'CO Project Display', 'CO', true),
('CO_CST_ELE', 'CO Cost Element', 'CO', true),
('CO_PRJ_BUD', 'CO Project Budget', 'CO', true),
('CO_ALLOCAT', 'CO Allocation', 'CO', true),
('CO_VARIANC', 'CO Variance Analysis', 'CO', true),
('CO_SETTLEM', 'CO Settlement', 'CO', true),
('CO_PROFITA', 'CO Profitability', 'CO', true)
ON CONFLICT (object_name) DO NOTHING;

-- Add user authorizations for ALL Finance auth objects
INSERT INTO user_authorizations (user_id, auth_object_id, field_values, valid_from)
SELECT u.id, ao.id, '{"ACTION": ["DISPLAY", "CREATE", "CHANGE", "EXECUTE"]}'::jsonb, CURRENT_DATE
FROM users u
CROSS JOIN authorization_objects ao
WHERE ao.object_name IN (
    'FI_GL_DISP', 'FI_GL_POST', 'FI_DOC_DIS', 'FI_DOC_REV', 
    'FI_PER_CLO', 'FI_REPORTS', 'FI_CASHFLO',
    'CO_PRJ_DIS', 'CO_CST_ELE', 'CO_PRJ_BUD', 'CO_ALLOCAT', 
    'CO_VARIANC', 'CO_SETTLEM', 'CO_PROFITA'
)
ON CONFLICT (user_id, auth_object_id) DO NOTHING;

-- Verify all Finance tiles now have user authorization
SELECT 'Final Finance Authorization Check' as check_type;
SELECT t.title, t.auth_object,
       check_construction_authorization(
           (SELECT id FROM users WHERE email LIKE '%@nttdemo.com' LIMIT 1),
           t.auth_object,
           'DISPLAY'
       ) as has_access
FROM tiles t
WHERE t.tile_category = 'Finance'
ORDER BY t.title;