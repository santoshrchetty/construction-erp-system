const { createClient } = require('@supabase/supabase-js')

const supabaseUrl = 'https://tpngnqukhvgrkokleirx.supabase.co'
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRwbmducXVraHZncmtva2xlaXJ4Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDI1NTkyMSwiZXhwIjoyMDc5ODMxOTIxfQ.FZ40QjefSjc83JAs30llsLqNh7upRRrDAEef2AobBvg'

const supabase = createClient(supabaseUrl, supabaseServiceKey)

async function createDemoManager() {
  try {
    // 1. Get Manager role ID
    const { data: roles, error: roleError } = await supabase
      .from('roles')
      .select('id, name')
    
    if (roleError) {
      throw new Error(`Role query failed: ${roleError.message}`)
    }
    
    console.log('Available roles:', roles)
    const managerRole = roles.find(r => r.name === 'Manager')
    
    if (!managerRole) {
      throw new Error('Manager role not found')
    }
    
    console.log('Manager role ID:', managerRole.id)
    
    // 2. Create auth user
    const { data: authData, error: authError } = await supabase.auth.admin.createUser({
      email: 'manager@nttdemo.com',
      password: 'demo123',
      email_confirm: true
    })
    
    if (authError) {
      console.log('Auth error:', authError)
      // If user already exists, try to get the existing user
      if (authError.message.includes('already registered')) {
        console.log('User already exists in auth, continuing...')
        // We'll handle this in the next step
      } else {
        throw authError
      }
    } else {
      console.log('Auth user created:', authData.user.id)
    }
    
    // 3. Try to create user profile (will fail if already exists)
    const userId = authData?.user?.id || '867a5b42-a26c-4ec4-89dc-cdf8e7b45af7' // Use the ID from previous creation
    
    const { data: profile, error: profileError } = await supabase
      .from('users')
      .upsert({
        id: userId,
        email: 'manager@nttdemo.com',
        first_name: 'Demo',
        last_name: 'Manager',
        employee_code: 'MGR-001',
        department: 'Management',
        role_id: managerRole.id,
        is_active: true
      }, {
        onConflict: 'id'
      })
      .select()
    
    if (profileError) {
      console.log('Profile error:', profileError)
    } else {
      console.log('Profile created/updated')
    }
    
    console.log('✅ Demo manager setup complete!')
    console.log('Email: manager@nttdemo.com')
    console.log('Password: demo123')
    
  } catch (error) {
    console.error('❌ Error:', error.message)
  }
}

createDemoManager()