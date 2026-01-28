const { execSync } = require('child_process');

console.log('🔍 Inspecting current database schema...');

try {
  // Generate current types from database
  console.log('Generating types from current database...');
  execSync('npx supabase gen types typescript --project-id $NEXT_PUBLIC_SUPABASE_PROJECT_ID > types/database-current.ts', {
    stdio: 'inherit',
    env: { ...process.env }
  });
  
  console.log('✅ Current database types generated');
  console.log('📁 Check types/database-current.ts to see actual schema');
  console.log('🔧 Compare with component expectations before making changes');
  
} catch (error) {
  console.error('❌ Failed to generate types:', error.message);
  console.log('💡 Alternative: Check schema manually with:');
  console.log('   \\d material_requests');
  process.exit(1);
}