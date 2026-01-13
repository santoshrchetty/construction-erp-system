import { chromium, FullConfig } from '@playwright/test';
import { createClient } from '@supabase/supabase-js';
import { getTestEnvironment } from './environment';
import { randomUUID } from 'crypto';

async function globalSetup(config: FullConfig) {
  const env = getTestEnvironment();
  const testRunId = randomUUID();
  
  // Store test run ID for cleanup
  process.env.TEST_RUN_ID = testRunId;
  
  const supabase = createClient(env.supabaseUrl, env.supabaseAnonKey);
  
  // Create test users with limited permissions
  await createTestUsers(supabase, testRunId);
  
  // Verify database is in safe state
  await verifyDatabaseSafety(supabase);
  
  console.log(`Test run ${testRunId} initialized in ${env.name} environment`);
}

async function createTestUsers(supabase: any, testRunId: string) {
  const testUsers = [
    {
      email: `test-manager-${testRunId}@example.com`,
      role: 'manager',
      company_code: 'TEST',
    },
    {
      email: `test-engineer-${testRunId}@example.com`,
      role: 'engineer',
      company_code: 'TEST',
    },
  ];
  
  for (const user of testUsers) {
    await supabase.from('test_users').insert({
      ...user,
      test_run_id: testRunId,
      created_at: new Date().toISOString(),
    });
  }
}

async function verifyDatabaseSafety(supabase: any) {
  // Ensure we're not in production
  const { data: config } = await supabase
    .from('system_config')
    .select('environment')
    .single();
    
  if (config?.environment === 'PROD') {
    throw new Error('CRITICAL: Cannot run tests against production database');
  }
}

export default globalSetup;