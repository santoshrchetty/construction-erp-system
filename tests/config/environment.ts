export interface TestEnvironment {
  name: 'DEV' | 'MAIN' | 'PROD';
  supabaseUrl: string;
  supabaseAnonKey: string;
  baseUrl: string;
  allowAutomation: boolean;
}

export const environments: Record<string, TestEnvironment> = {
  DEV: {
    name: 'DEV',
    supabaseUrl: process.env.NEXT_PUBLIC_SUPABASE_URL!,
    supabaseAnonKey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    baseUrl: process.env.PLAYWRIGHT_BASE_URL || 'http://localhost:3000',
    allowAutomation: true,
  },
  MAIN: {
    name: 'MAIN',
    supabaseUrl: process.env.NEXT_PUBLIC_SUPABASE_URL!,
    supabaseAnonKey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    baseUrl: process.env.PLAYWRIGHT_BASE_URL || 'http://localhost:3000',
    allowAutomation: process.env.ALLOW_MAIN_DB_TESTING === 'true',
  },
  PROD: {
    name: 'PROD',
    supabaseUrl: process.env.PROD_SUPABASE_URL!,
    supabaseAnonKey: process.env.PROD_SUPABASE_ANON_KEY!,
    baseUrl: process.env.PROD_BASE_URL!,
    allowAutomation: false, // CRITICAL: Never allow PROD automation
  },
};

export function getTestEnvironment(): TestEnvironment {
  const envName = process.env.TEST_ENV || 'MAIN'; // Default to MAIN instead of DEV
  
  // Handle environment name variations
  const normalizedEnvName = envName.trim().toUpperCase();
  const env = environments[normalizedEnvName];
  
  if (!env) {
    console.log('Available environments:', Object.keys(environments));
    console.log('Requested environment:', envName);
    throw new Error(`Invalid TEST_ENV: ${envName}`);
  }
  
  if (!env.allowAutomation) {
    throw new Error(`Automation not allowed in ${env.name} environment`);
  }
  
  return env;
}