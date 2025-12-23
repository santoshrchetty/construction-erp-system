const { createClient } = require('@supabase/supabase-js')

const supabaseUrl = 'https://tpngnqukhvgrkokleirx.supabase.co'
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRwbmducXVraHZncmtva2xlaXJ4Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDI1NTkyMSwiZXhwIjoyMDc5ODMxOTIxfQ.FZ40QjefSjc83JAs30llsLqNh7upRRrDAEef2AobBvg'

const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
})

async function fixManagerUser() {
  try {
    console.log('Checking manager user...')
    
    // 1. Get auth users with demo@nttdemo.com
    const { data: authUsers, error: authError } = await supabase.auth.admin.listUsers()
    
    if (authError) {
      throw new Error(`Failed to list auth users: ${authError.message}`)
    }
    
    const demoUser = authUsers.users.find(u => u.email === 'demo@nttdemo.com')
    if (!demoUser) {
      throw new Error('Auth user demo@nttdemo.com not found')
    }
    
    console.log('Auth user found:', demoUser.id)
    
    // 2. Check if user exists in users table
    const { data: existingUser, error: userError } = await supabase
      .from('users')
      .select('*')
      .eq('id', demoUser.id)
      .single()
    
    if (userError && userError.code !== 'PGRST116') {
      throw new Error(`Error checking user: ${userError.message}`)
    }
    
    if (existingUser) {
      console.log('User already exists in users table')
      return
    }
    
    // 3. Get Manager role ID
    const { data: managerRole, error: roleError } = await supabase
      .from('roles')
      .select('id')
      .eq('name', 'Manager')
      .single()
    
    if (roleError || !managerRole) {
      throw new Error('Manager role not found')
    }
    
    console.log('Manager role ID:', managerRole.id)
    
    // 4. Create user profile
    const { data: userProfile, error: profileError } = await supabase
      .from('users')
      .insert({
        id: demoUser.id,
        email: 'demo@nttdemo.com',
        first_name: 'Demo',
        last_name: 'Manager',
        employee_code: 'MGR-001',
        department: 'Management',
        role_id: managerRole.id,
        is_active: true
      })
      .select()
    
    if (profileError) {
      throw new Error(`User profile creation failed: ${profileError.message}`)
    }
    
    console.log('✅ Manager user profile created successfully!')
    console.log('Email: demo@nttdemo.com')
    console.log('Password: demo123')
    console.log('Role: Manager')
    
  } catch (error) {
    console.error('❌ Error fixing manager user:', error.message)
  }
}

fixManagerUser()