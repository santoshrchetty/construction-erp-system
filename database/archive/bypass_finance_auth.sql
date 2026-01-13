-- Simple Finance Tiles Fix - Remove Authorization Requirement
-- ===========================================================

-- Remove auth_object requirement from Finance tiles to make them visible
UPDATE tiles 
SET auth_object = NULL 
WHERE tile_category = 'Finance'
  AND auth_object IN (
    'FI_GL_DISP', 'FI_GL_POST', 'FI_DOC_DIS', 'FI_DOC_REV', 
    'FI_PER_CLO', 'FI_REPORTS', 'FI_CASHFLO',
    'CO_PRJ_DIS', 'CO_CST_ELE', 'CO_PRJ_BUD', 'CO_ALLOCAT', 
    'CO_VARIANC', 'CO_SETTLEM', 'CO_PROFITA'
  );

-- Force cache refresh
UPDATE tiles 
SET updated_at = NOW() 
WHERE tile_category = 'Finance';

-- Verify Finance tiles
SELECT 'Finance Tiles Status' as check_type;
SELECT title, auth_object, is_active
FROM tiles 
WHERE tile_category = 'Finance'
ORDER BY title;