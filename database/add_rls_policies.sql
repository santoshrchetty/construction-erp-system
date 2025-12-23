-- Enable RLS on new tables
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;

-- Create policies for roles table
CREATE POLICY "Allow read access to roles" ON roles FOR SELECT USING (true);

-- Create policies for users table
CREATE POLICY "Users can read own data" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own data" ON users FOR UPDATE USING (auth.uid() = id);

-- Create policies for employees table
CREATE POLICY "Allow read access to employees" ON employees FOR SELECT USING (true);

SELECT 'RLS policies added successfully!' as status;