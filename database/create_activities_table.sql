-- Drop tasks table if it exists
DROP TABLE IF EXISTS public.tasks CASCADE;

-- Create activities table
CREATE TABLE IF NOT EXISTS public.activities (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  project_code character varying(20) NOT NULL,
  wbs_element character varying(24) NOT NULL,
  code character varying(20) NOT NULL,
  name character varying(100) NOT NULL,
  description text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  tenant_id uuid NOT NULL DEFAULT '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid,
  CONSTRAINT activities_pkey PRIMARY KEY (id),
  CONSTRAINT activities_project_code_code_key UNIQUE (project_code, code)
);

-- Remove all activities except those with code starting with P
DELETE FROM public.activities WHERE code NOT LIKE 'P%';

-- Insert sample activities for WBS elements
INSERT INTO public.activities (project_code, wbs_element, code, name, description) VALUES
  ('P100', 'P100.1', 'P100.1-A01', 'Site Survey', 'Conduct detailed site survey and measurements'),
  ('P100', 'P100.1', 'P100.1-A02', 'Soil Testing', 'Perform soil analysis and testing'),
  ('P100', 'P100.2', 'P100.2-A01', 'Foundation Excavation', 'Excavate foundation area'),
  ('P100', 'P100.2', 'P100.2-A02', 'Concrete Pouring', 'Pour concrete for foundation'),
  ('P100', 'P100.3', 'P100.3-A01', 'Steel Erection', 'Erect steel framework'),
  ('P100', 'P100.3', 'P100.3-A02', 'Welding Work', 'Weld steel connections');

-- Add activity_code column to project_tasks table
ALTER TABLE public.project_tasks ADD COLUMN IF NOT EXISTS activity_code character varying(20);

-- Insert sample tasks for activities
-- Get project_id for P100 first, then insert tasks
INSERT INTO public.project_tasks (tenant_id, project_id, activity_code, task_name, description, status) 
SELECT 
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid as tenant_id,
  p.id as project_id,
  tasks.activity_code,
  tasks.task_name,
  tasks.description,
  tasks.status
FROM projects p,
(VALUES 
  ('P100.1-A01', 'Setup survey equipment', 'Setup and calibrate survey equipment', 'pending'),
  ('P100.1-A01', 'Measure site boundaries', 'Measure and mark site boundaries', 'pending'),
  ('P100.1-A02', 'Collect soil samples', 'Collect soil samples from designated points', 'pending'),
  ('P100.1-A02', 'Laboratory analysis', 'Send samples for laboratory analysis', 'pending'),
  ('P100.2-A01', 'Mark excavation area', 'Mark foundation excavation boundaries', 'pending'),
  ('P100.2-A01', 'Excavate foundation', 'Excavate to required depth and dimensions', 'pending'),
  ('P100.2-A02', 'Prepare concrete mix', 'Prepare concrete according to specifications', 'pending'),
  ('P100.2-A02', 'Pour foundation concrete', 'Pour and level foundation concrete', 'pending'),
  ('P100.3-A01', 'Position steel beams', 'Position main steel beams according to plan', 'pending'),
  ('P100.3-A01', 'Check alignment', 'Verify steel beam alignment and level', 'pending'),
  ('P100.3-A02', 'Weld main connections', 'Weld primary structural connections', 'pending'),
  ('P100.3-A02', 'Quality inspection', 'Inspect weld quality and certification', 'pending')
) AS tasks(activity_code, task_name, description, status)
WHERE p.project_code = 'P100';