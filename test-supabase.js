// Test Supabase connection
const { createClient } = require('@supabase/supabase-js')

const supabaseUrl = 'https://tpngnqukhvgrkokleirx.supabase.co'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRwbmducXVraHZncmtva2xlaXJ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQyNTU5MjEsImV4cCI6MjA3OTgzMTkyMX0.GWOMo5VY1FkEG6h3pZe6kfJM4gpzGdIai1DokKqHTHs'

const supabase = createClient(supabaseUrl, supabaseAnonKey)

async function testConnection() {
  try {
    console.log('Testing Supabase connection...')
    const { data, error } = await supabase.from('roles').select('*').limit(1)
    
    if (error) {
      console.error('Supabase error:', error)
    } else {
      console.log('Connection successful:', data)
    }
  } catch (err) {
    console.error('Network error:', err)
  }
}

testConnection()