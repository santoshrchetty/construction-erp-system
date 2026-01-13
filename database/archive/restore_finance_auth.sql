-- Restore Proper Finance Authorization
-- ====================================

-- Restore proper auth_object for Finance tiles
UPDATE tiles SET auth_object = 'FI_GL_DISP' WHERE title = 'Chart of Accounts' AND tile_category = 'Finance';
UPDATE tiles SET auth_object = 'FI_GL_POST' WHERE title = 'Create Journal Entry' AND tile_category = 'Finance';
UPDATE tiles SET auth_object = 'FI_DOC_DIS' WHERE title = 'Document Display' AND tile_category = 'Finance';
UPDATE tiles SET auth_object = 'FI_DOC_REV' WHERE title = 'Document Reversal' AND tile_category = 'Finance';
UPDATE tiles SET auth_object = 'FI_GL_DISP' WHERE title = 'Trial Balance' AND tile_category = 'Finance';
UPDATE tiles SET auth_object = 'FI_PER_CLO' WHERE title = 'Period End Closing' AND tile_category = 'Finance';
UPDATE tiles SET auth_object = 'FI_REPORTS' WHERE title = 'Financial Statements' AND tile_category = 'Finance';
UPDATE tiles SET auth_object = 'FI_CASHFLO' WHERE title = 'Cash Flow Report' AND tile_category = 'Finance';

UPDATE tiles SET auth_object = 'CO_PRJ_DIS' WHERE title = 'Project Cost Analysis' AND tile_category = 'Finance';
UPDATE tiles SET auth_object = 'CO_CST_ELE' WHERE title = 'Cost Element Master' AND tile_category = 'Finance';
UPDATE tiles SET auth_object = 'CO_PRJ_BUD' WHERE title = 'Project Budget' AND tile_category = 'Finance';
UPDATE tiles SET auth_object = 'CO_ALLOCAT' WHERE title = 'Overhead Allocation' AND tile_category = 'Finance';
UPDATE tiles SET auth_object = 'CO_VARIANC' WHERE title = 'Variance Analysis' AND tile_category = 'Finance';
UPDATE tiles SET auth_object = 'CO_SETTLEM' WHERE title = 'Cost Settlement' AND tile_category = 'Finance';
UPDATE tiles SET auth_object = 'CO_PROFITA' WHERE title = 'Project Profitability' AND tile_category = 'Finance';

-- Ensure all Finance authorization objects exist
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

-- Grant all users access to Finance authorization objects
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

-- Force cache refresh
UPDATE tiles SET updated_at = NOW() WHERE tile_category = 'Finance';

-- Verify proper authorization is restored
SELECT 'Finance Tiles with Proper Auth' as check_type;
SELECT title, auth_object, is_active
FROM tiles 
WHERE tile_category = 'Finance'
ORDER BY 
    CASE WHEN auth_object LIKE 'FI_%' THEN 1 WHEN auth_object LIKE 'CO_%' THEN 2 ELSE 3 END,
    title;