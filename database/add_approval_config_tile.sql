-- Add Approval Configuration Tile
INSERT INTO tiles (title, subtitle, icon, module_code, construction_action, route, tile_category, auth_object) VALUES
('Approval Configuration', 'Configure flexible approval workflows for MR/PR/PO', 'settings', 'AD', 'approval-configuration', '/admin/approval-config', 'Administration', 'ADMIN_APPROVAL_CONFIG')
ON CONFLICT (construction_action) DO UPDATE SET
  title = EXCLUDED.title,
  subtitle = EXCLUDED.subtitle,
  icon = EXCLUDED.icon,
  updated_at = NOW();

-- Verify the tile was added
SELECT 'Approval Configuration Tile Added:' as info;
SELECT title, subtitle, construction_action, auth_object, tile_category
FROM tiles 
WHERE construction_action = 'approval-configuration';