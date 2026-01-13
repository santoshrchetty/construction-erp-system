-- Query 3: Test Chart of Accounts authorization
SELECT 
    t.title,
    t.auth_object,
    t.is_active,
    check_construction_authorization(
        '70f8baa8-27b8-4061-84c4-6dd027d6b89f'::uuid,
        t.auth_object,
        'DISPLAY'
    ) as has_access
FROM tiles t
WHERE t.title = 'Chart of Accounts' AND t.tile_category = 'Finance';