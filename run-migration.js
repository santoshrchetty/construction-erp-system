const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');

// Load environment variables
require('dotenv').config({ path: '.env.local' });

async function runMigration() {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

  if (!supabaseUrl || !supabaseKey) {
    console.error('Missing Supabase credentials in environment variables');
    process.exit(1);
  }

  const supabase = createClient(supabaseUrl, supabaseKey);

  try {
    // Read the migration file
    const migrationPath = path.join(__dirname, 'database', 'migrations', '01_fix_column_size.sql');
    const migrationSQL = fs.readFileSync(migrationPath, 'utf8');

    console.log('Running migration...');
    console.log('SQL:', migrationSQL);

    // Execute the migration
    const { data, error } = await supabase.rpc('exec_sql', { sql: migrationSQL });

    if (error) {
      console.error('Migration failed:', error);
      process.exit(1);
    }

    console.log('Migration completed successfully!');
    console.log('Result:', data);

  } catch (err) {
    console.error('Error running migration:', err);
    process.exit(1);
  }
}

runMigration();