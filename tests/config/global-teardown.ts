import { createClient } from '@supabase/supabase-js';
import { getTestEnvironment } from './environment';

async function globalTeardown() {
  const env = getTestEnvironment();
  const testRunId = process.env.TEST_RUN_ID;
  
  if (!testRunId) {
    console.warn('No TEST_RUN_ID found for cleanup');
    return;
  }
  
  const supabase = createClient(env.supabaseUrl, env.supabaseAnonKey);
  
  // Clean up all test data
  await cleanupTestData(supabase, testRunId);
  
  console.log(`Test run ${testRunId} cleaned up successfully`);
}

async function cleanupTestData(supabase: any, testRunId: string) {
  const tables = [
    'universal_journal',
    'projects',
    'wbs_elements',
    'materials',
    'purchase_orders',
    'test_users',
  ];
  
  for (const table of tables) {
    try {
      await supabase
        .from(table)
        .delete()
        .eq('test_run_id', testRunId);
        
      console.log(`Cleaned ${table} for test run ${testRunId}`);
    } catch (error) {
      console.warn(`Failed to clean ${table}:`, error);
    }
  }
}

export default globalTeardown;