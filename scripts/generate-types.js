const { execSync } = require('child_process');

try {
  console.log('Generating database types...');
  execSync('npx supabase gen types typescript --project-id $NEXT_PUBLIC_SUPABASE_PROJECT_ID > types/database.ts', {
    stdio: 'inherit',
    env: { ...process.env }
  });
  console.log('✅ Database types generated successfully');
} catch (error) {
  console.error('❌ Failed to generate types:', error.message);
  process.exit(1);
}