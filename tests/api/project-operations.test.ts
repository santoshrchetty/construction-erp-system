import { test, expect } from '@playwright/test';
import { createClient } from '@supabase/supabase-js';
import { randomUUID } from 'crypto';

test.describe('Project API Tests', () => {
  let supabase: any;
  let testRunId: string;
  
  test.beforeAll(async () => {
    supabase = createClient(
      'https://tozgoiwobgdscplxdgbv.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRvemdvaXdvYmdkc2NwbHhkZ2J2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc3ODc4MTgsImV4cCI6MjA4MzM2MzgxOH0.mxCS2VfY74qCiGNnhmcx0N9aX_nTi6yujzVk44lti9E'
    );
    testRunId = randomUUID();
  });
  
  test.afterAll(async () => {
    // Cleanup test data
    await supabase.from('projects').delete().eq('test_run_id', testRunId);
    await supabase.from('universal_journal').delete().eq('test_run_id', testRunId);
  });
  
  test('should create project via database', async () => {
    const projectData = {
      project_code: `TEST-${testRunId.slice(0, 8)}`,
      project_name: 'API Test Project',
      project_type: 'CONSTRUCTION',
      company_code: 'TEST',
      test_run_id: testRunId,
    };
    
    const { data, error } = await supabase
      .from('projects')
      .insert(projectData)
      .select()
      .single();
      
    expect(error).toBeNull();
    expect(data.project_name).toBe('API Test Project');
    expect(data.project_code).toContain('TEST-');
  });
  
  test('should post financial transaction', async () => {
    const journalEntry = {
      company_code: 'TEST',
      project_code: `TEST-${testRunId.slice(0, 8)}`,
      gl_account: '520000',
      debit_credit: 'D',
      company_amount: 1000.00,
      event_type: 'MATERIAL_COST',
      test_run_id: testRunId,
    };
    
    const { data, error } = await supabase
      .from('universal_journal')
      .insert(journalEntry)
      .select()
      .single();
      
    expect(error).toBeNull();
    expect(data.company_amount).toBe(1000.00);
    expect(data.debit_credit).toBe('D');
  });
  
  test('should retrieve project data', async () => {
    const { data, error } = await supabase
      .from('projects')
      .select('*')
      .eq('test_run_id', testRunId);
      
    expect(error).toBeNull();
    expect(data.length).toBeGreaterThan(0);
  });
});