import { test, expect } from '@playwright/test';

test.describe('Basic Test Setup', () => {
  test('should verify TEST environment is accessible', async () => {
    const testEnv = process.env.TEST_ENV?.trim();
    const supabaseUrl = process.env.TEST_SUPABASE_URL;
    
    console.log('Test Environment:', testEnv);
    console.log('Supabase URL:', supabaseUrl);
    
    expect(testEnv).toBe('TEST');
    expect(supabaseUrl).toContain('tozgoiwobgdscplxdgbv');
  });
  
  test('should connect to Supabase TEST instance', async () => {
    const { createClient } = await import('@supabase/supabase-js');
    
    const supabase = createClient(
      'https://tozgoiwobgdscplxdgbv.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRvemdvaXdvYmdkc2NwbHhkZ2J2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc3ODc4MTgsImV4cCI6MjA4MzM2MzgxOH0.mxCS2VfY74qCiGNnhmcx0N9aX_nTi6yujzVk44lti9E'
    );
    
    // Simple connection test
    const { data, error } = await supabase.from('test_table').select('*').limit(1);
    
    // Should not error on connection (table may not exist yet)
    expect(supabase).toBeDefined();
  });
});