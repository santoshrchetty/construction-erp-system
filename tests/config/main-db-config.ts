// Configuration for running tests on main database
export const MAIN_DB_CONFIG = {
  // Use your main database credentials
  supabaseUrl: process.env.NEXT_PUBLIC_SUPABASE_URL!,
  supabaseAnonKey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
  
  // CRITICAL SAFETY MEASURES
  safetyChecks: {
    // Only allow if explicitly enabled
    allowMainDbTesting: process.env.ALLOW_MAIN_DB_TESTING === 'true',
    
    // Require test data tagging
    requireTestRunId: true,
    
    // Limit test data creation
    maxTestRecords: 10,
    
    // Auto-cleanup after tests
    autoCleanup: true,
    
    // Prevent production data modification
    readOnlyMode: false, // Set to true for read-only tests
  }
};

export function validateMainDbTesting() {
  if (!MAIN_DB_CONFIG.safetyChecks.allowMainDbTesting) {
    throw new Error('Main database testing not enabled. Set ALLOW_MAIN_DB_TESTING=true');
  }
  
  // Check environment is not production
  if (process.env.NODE_ENV === 'production') {
    throw new Error('Cannot run tests against main database in production');
  }
  
  // Verify test run ID is set
  if (MAIN_DB_CONFIG.safetyChecks.requireTestRunId && !process.env.TEST_RUN_ID) {
    throw new Error('TEST_RUN_ID required for main database testing');
  }
}