-- Create test drawings for OMEGA-DEV
INSERT INTO drawings (
  tenant_id, 
  drawing_number, 
  title, 
  revision, 
  discipline, 
  drawing_type,
  status, 
  created_by
)
VALUES
  ('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 'A-001', 'Site Plan', 'A', 'Architectural', 'Site Plan', 'Approved', '2d17fcf3-d4f0-4308-a2f4-2e97205a3765'),
  ('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 'A-101', 'Ground Floor Plan', 'B', 'Architectural', 'Floor Plan', 'Approved', '2d17fcf3-d4f0-4308-a2f4-2e97205a3765'),
  ('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 'S-201', 'Foundation Plan', 'A', 'Structural', 'Foundation', 'Under Review', '2d17fcf3-d4f0-4308-a2f4-2e97205a3765'),
  ('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 'E-301', 'Electrical Single Line Diagram', 'C', 'Electrical', 'Schematic', 'Draft', '2d17fcf3-d4f0-4308-a2f4-2e97205a3765'),
  ('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 'M-401', 'HVAC Layout - Level 1', 'A', 'Mechanical', 'Layout', 'Approved', '2d17fcf3-d4f0-4308-a2f4-2e97205a3765');

-- Verify
SELECT 
  drawing_number,
  title,
  revision,
  discipline,
  status,
  created_at
FROM drawings
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
ORDER BY drawing_number;
