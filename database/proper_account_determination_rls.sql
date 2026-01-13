-- Create proper RLS policy for account_determination table

-- Enable RLS if not already enabled
ALTER TABLE public.account_determination ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Allow authenticated users to read account_determination" ON public.account_determination;
DROP POLICY IF EXISTS "Allow admin users to modify account_determination" ON public.account_determination;

-- Create policy to allow authenticated users to read account_determination
CREATE POLICY "authenticated_read_account_determination" ON public.account_determination
FOR SELECT TO authenticated
USING (true);

-- Create policy to allow authenticated users with admin role to modify
CREATE POLICY "admin_modify_account_determination" ON public.account_determination
FOR ALL TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.users u 
    JOIN public.roles r ON u.role_id = r.id 
    WHERE u.id = auth.uid() AND r.name = 'admin'
  )
);

-- Verify the policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'account_determination';