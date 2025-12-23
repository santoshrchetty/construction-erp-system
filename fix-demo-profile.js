const { createClient } = require('@supabase/supabase-js')

const supabaseUrl = 'https://tpngnqukhvgrkokleirx.supabase.co'
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRwbmducXVraHZncmtva2xlaXJ4Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDI1NTkyMSwiZXhwIjoyMDc5ODMxOTIxfQ.FZ40QjefSjc83JAs30llsLqNh7upRRrDAEef2AobBvg'

const supabase = createClient(supabaseUrl, supabaseServiceKey)

async function fixDemoProfile() {
  try {
    // Get Manager role ID
    const { data: managerRole } = await supabase
      .from('roles')
      .select('id')
      .eq('name', 'Manager')
      .single()
    
    console.log('Manager role ID:', managerRole.id)
    
    // Use the known user ID from the previous creation
    const userId = '867a5b42-a26c-4ec4-89dc-cdf8e7b45af7'
    
    // Update the user profile with correct email
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
      console.error('Profile error:', profileError)
    } else {
      console.log('✅ Profile updated successfully!')
    }
    
    // Verify the profile
    const { data: verification } = await supabase
      .from('users')
      .select('*, roles(name)')
      .eq('id', userId)
      .single()
    
    console.log('Verification:', verification)
    
  } catch (error) {
    console.error('❌ Error:', error.message)
  }
}

fixDemoProfile()