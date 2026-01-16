-- Industry-Grade RLS: Allow anon + authenticated access
-- This is the proper fix for your "Failed to fetch" error

ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE wbs_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Projects policies
CREATE POLICY "public_read_projects" ON projects FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "auth_write_projects" ON projects FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- WBS policies
CREATE POLICY "public_read_wbs" ON wbs_nodes FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "auth_write_wbs" ON wbs_nodes FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Activities policies
CREATE POLICY "public_read_activities" ON activities FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "auth_write_activities" ON activities FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Tasks policies
CREATE POLICY "public_read_tasks" ON tasks FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "auth_write_tasks" ON tasks FOR ALL TO authenticated USING (true) WITH CHECK (true);

SELECT 'RLS enabled with anon + authenticated access' as status;
