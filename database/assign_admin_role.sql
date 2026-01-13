-- Assign admin role to admin@nttdemo.com user

-- First, check if admin role exists
INSERT INTO public.roles (name, description, is_active) 
VALUES ('admin', 'System Administrator', true)
ON CONFLICT (name) DO NOTHING;

-- Get the admin role ID
WITH admin_role AS (
  SELECT id FROM public.roles WHERE name = 'admin'
),
admin_user AS (
  SELECT id FROM auth.users WHERE email = 'admin@nttdemo.com'
)
-- Update user to have admin role
UPDATE public.users 
SET role_id = (SELECT id FROM admin_role)
WHERE id = (SELECT id FROM admin_user);

-- Also insert into public.users if not exists
INSERT INTO public.users (id, email, role_id, is_active)
SELECT au.id, au.email, r.id, true
FROM auth.users au
CROSS JOIN public.roles r
WHERE au.email = 'admin@nttdemo.com' 
  AND r.name = 'admin'
ON CONFLICT (id) DO UPDATE SET role_id = EXCLUDED.role_id;

-- Verify the assignment
SELECT u.email, r.name as role_name, u.is_active
FROM public.users u
JOIN public.roles r ON u.role_id = r.id
WHERE u.email = 'admin@nttdemo.com';