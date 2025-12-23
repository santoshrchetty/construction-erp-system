const { createClient } = require('@supabase/supabase-js')

const supabaseUrl = 'https://tpngnqukhvgrkokleirx.supabase.co'
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRwbmducXVraHZncmtva2xlaXJ4Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDI1NTkyMSwiZXhwIjoyMDc5ODMxOTIxfQ.FZ40QjefSjc83JAs30llsLqNh7upRRrDAEef2AobBvg'

const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
})

async function createManagerUser() {
  try {
    console.log('Creating manager user...')
    
    // 1. Get Manager role ID
    const { data: managerRole, error: roleError } = await supabase
      .from('roles')
      .select('id')
      .eq('name', 'Manager')
      .single()
    
    if (roleError || !managerRole) {
      throw new Error('Manager role not found')
    }
    
    console.log('Manager role ID:', managerRole.id)
    
    // 2. Create auth user
    const { data: authUser, error: authError } = await supabase.auth.admin.createUser({
      email: 'demo@nttdemo.com',
      password: 'demo123',
      email_confirm: true
    })
    
    if (authError) {
      throw new Error(`Auth user creation failed: ${authError.message}`)
    }
    
    console.log('Auth user created:', authUser.user.id)
    
    // 3. Create user profile
    const { data: userProfile, error: profileError } = await supabase
      .from('users')
      .insert({
        id: authUser.user.id,
        email: 'demo@nttdemo.com',
        first_name: 'Demo',
        last_name: 'Manager',
        employee_code: 'MGR-001',
        department: 'Management',
        role_id: managerRole.id,
        is_active: true
      })
      .select()
      .single()
    
    if (profileError) {
      throw new Error(`User profile creation failed: ${profileError.message}`)
    }
    
    console.log('✅ Manager user created successfully!')
    console.log('Email: demo@nttdemo.com')
    console.log('Password: demo123')
    console.log('Role: Manager')
    
  } catch (error) {
    console.error('❌ Error creating manager user:', error.message)
  }
}

createManagerUser()