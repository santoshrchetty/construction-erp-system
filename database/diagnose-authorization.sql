-- Step 1: Check if roles table has data
SELECT * FROM roles ORDER BY name;

-- Step 2: Check if authorization_objects table has data
SELECT * FROM authorization_objects ORDER BY module, object_name;

-- Step 3: Check if role_authorization_objects table has data
SELECT 
  r.name as role_name,
  ao.module,
  ao.object_name,
  rao.is_active
FROM role_authorization_objects rao
JOIN roles r ON rao.role_id = r.id
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
ORDER BY r.name, ao.module;

-- Step 4: Check if users have roles assigned
SELECT 
  u.id,
  u.email,
  r.name as role_name
FROM users u
LEFT JOIN roles r ON u.role_id = r.id
ORDER BY u.email;

-- Step 5: Check if tiles have module_code assigned
SELECT 
  id,
  title,
  module_code,
  is_active
FROM tiles
ORDER BY id;
