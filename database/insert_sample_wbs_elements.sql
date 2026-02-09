-- Insert sample WBS elements for project HW-0001
INSERT INTO public.wbs_elements (
  company_code,
  project_code,
  wbs_element,
  wbs_description,
  wbs_level,
  parent_wbs,
  is_active
) VALUES
  ('1000', 'HW-0001', 'HW-0001.01', 'Site Preparation', 1, NULL, true),
  ('1000', 'HW-0001', 'HW-0001.02', 'Foundation Work', 1, NULL, true),
  ('1000', 'HW-0001', 'HW-0001.03', 'Structural Work', 1, NULL, true),
  ('1000', 'HW-0001', 'HW-0001.01.01', 'Site Clearing', 2, 'HW-0001.01', true),
  ('1000', 'HW-0001', 'HW-0001.01.02', 'Excavation', 2, 'HW-0001.01', true),
  ('1000', 'HW-0001', 'HW-0001.02.01', 'Concrete Foundation', 2, 'HW-0001.02', true),
  ('1000', 'HW-0001', 'HW-0001.03.01', 'Steel Framework', 2, 'HW-0001.03', true);