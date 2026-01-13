-- Create Finance Authorization for Users
-- ======================================

-- Create user_authorizations table if it doesn't exist
CREATE TABLE IF NOT EXISTS user_authorizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    auth_object_id UUID NOT NULL REFERENCES authorization_objects(id),
    field_values JSONB NOT NULL DEFAULT '{}'::jsonb,
    valid_from DATE NOT NULL DEFAULT CURRENT_DATE,
    valid_to DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, auth_object_id)
);

-- Grant Finance access to all users
INSERT INTO user_authorizations (user_id, auth_object_id, field_values)
SELECT u.id, ao.id, '{"ACTION": ["DISPLAY", "CREATE", "CHANGE", "EXECUTE"]}'::jsonb
FROM users u
CROSS JOIN authorization_objects ao
WHERE ao.module IN ('FI', 'CO')
ON CONFLICT (user_id, auth_object_id) 
DO UPDATE SET field_values = '{"ACTION": ["DISPLAY", "CREATE", "CHANGE", "EXECUTE"]}'::jsonb;

-- Test authorization again
SELECT 'Test Finance Access' as check_type;
SELECT u.email, 
       check_construction_authorization(u.id, 'FI_GL_DISP', 'DISPLAY') as has_finance_display,
       check_construction_authorization(u.id, 'CO_PRJ_DIS', 'DISPLAY') as has_controlling_display
FROM users u
ORDER BY u.created_at DESC LIMIT 3;

-- Verify user authorizations
SELECT 'User Authorizations' as check_type;
SELECT u.email, ao.object_name, ua.field_values
FROM user_authorizations ua
JOIN users u ON ua.user_id = u.id
JOIN authorization_objects ao ON ua.auth_object_id = ao.id
WHERE ao.module IN ('FI', 'CO')
ORDER BY u.email, ao.object_name;