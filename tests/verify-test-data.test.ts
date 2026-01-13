import { test, expect } from '@playwright/test';
import { createClient } from '@supabase/supabase-js';

test.describe('Verify Test Data', () => {
  let supabase: any;
  
  test.beforeAll(async () => {
    supabase = createClient(
      'https://tozgoiwobgdscplxdgbv.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRvemdvaXdvYmdkc2NwbHhkZ2J2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc3ODc4MTgsImV4cCI6MjA4MzM2MzgxOH0.mxCS2VfY74qCiGNnhmcx0N9aX_nTi6yujzVk44lti9E'
    );
  });
  
  test('should show all projects in TEST database', async () => {
    const { data: projects, error } = await supabase
      .from('projects')
      .select('*')
      .order('created_at', { ascending: false });
      
    console.log('=== ALL PROJECTS IN TEST DATABASE ===');
    console.log('Total projects found:', projects?.length || 0);
    
    if (projects && projects.length > 0) {
      projects.forEach((project: any, index: number) => {
        console.log(`\n--- Project ${index + 1} ---`);
        console.log('ID:', project.id);
        console.log('Code:', project.project_code);
        console.log('Name:', project.project_name);
        console.log('Type:', project.project_type);
        console.log('Company:', project.company_code);
        console.log('Test Run ID:', project.test_run_id || 'None');
        console.log('Created:', project.created_at);
      });
    } else {
      console.log('No projects found in database');
    }
    
    expect(error).toBeNull();
  });
  
  test('should show all financial postings', async () => {
    const { data: postings, error } = await supabase
      .from('universal_journal')
      .select('*')
      .order('created_at', { ascending: false });
      
    console.log('\n=== ALL FINANCIAL POSTINGS ===');
    console.log('Total postings found:', postings?.length || 0);
    
    if (postings && postings.length > 0) {
      postings.forEach((posting: any, index: number) => {
        console.log(`\n--- Posting ${index + 1} ---`);
        console.log('Project Code:', posting.project_code);
        console.log('GL Account:', posting.gl_account);
        console.log('Amount:', posting.company_amount);
        console.log('Debit/Credit:', posting.debit_credit);
        console.log('Event Type:', posting.event_type);
        console.log('Test Run ID:', posting.test_run_id || 'None');
        console.log('Created:', posting.created_at);
      });
    } else {
      console.log('No financial postings found');
    }
    
    expect(error).toBeNull();
  });
  
  test('should show test data with test_run_id', async () => {
    // Check for test data specifically
    const { data: testProjects } = await supabase
      .from('projects')
      .select('*')
      .not('test_run_id', 'is', null);
      
    const { data: testPostings } = await supabase
      .from('universal_journal')
      .select('*')
      .not('test_run_id', 'is', null);
      
    console.log('\n=== TEST DATA SUMMARY ===');
    console.log('Projects with test_run_id:', testProjects?.length || 0);
    console.log('Postings with test_run_id:', testPostings?.length || 0);
    
    if (testProjects && testProjects.length > 0) {
      console.log('\nTest Projects:');
      testProjects.forEach((p: any) => {
        console.log(`- ${p.project_code}: ${p.project_name} (${p.test_run_id})`);
      });
    }
  });
});