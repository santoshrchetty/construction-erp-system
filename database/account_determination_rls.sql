-- Enable RLS and create policy for account_determination table

-- Enable RLS on account_determination table
ALTER TABLE public.account_determination ENABLE ROW LEVEL SECURITY;

-- Create policy to allow authenticated users to read account_determination
CREATE POLICY "Allow authenticated users to read account_determination" ON public.account_determination
FOR SELECT TO authenticated
USING (true);

-- Create policy to allow admin users to modify account_determination  
CREATE POLICY "Allow admin users to modify account_determination" ON public.account_determination
FOR ALL TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.users u 
    JOIN public.roles r ON u.role_id = r.id 
    WHERE u.id = auth.uid() AND r.name = 'admin'
  )
);

-- Verify policies were created
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'account_determination';