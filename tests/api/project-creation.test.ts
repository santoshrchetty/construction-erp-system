import { test, expect } from '@playwright/test';
import { ERPTestUtils } from '../utils/erp-utils';

test.describe('Project Creation API', () => {
  let erpUtils: ERPTestUtils;
  
  test.beforeEach(async () => {
    erpUtils = new ERPTestUtils();
  });
  
  test('should create project with WBS structure', async ({ request }) => {
    // Create test project
    const projectData = {
      project_code: 'P001',
      project_name: 'Test Construction Project',
      project_type: 'CONSTRUCTION',
      company_code: 'TEST',
      status: 'ACTIVE',
    };
    
    const project = await erpUtils.createTestProject(projectData);
    expect(project.project_code).toContain('TEST-');
    
    // Verify project creation via API
    const response = await request.get(`/api/projects/${project.id}`);
    expect(response.ok()).toBeTruthy();
    
    const apiProject = await response.json();
    expect(apiProject.project_name).toBe(projectData.project_name);
  });
  
  test('should handle project financial postings', async ({ request }) => {
    // Create test project and material
    const project = await erpUtils.createTestProject({
      project_code: 'P002',
      project_name: 'Financial Test Project',
      project_type: 'CONSTRUCTION',
      company_code: 'TEST',
    });
    
    // Post material transaction
    const journalEntry = {
      company_code: 'TEST',
      project_code: project.project_code,
      gl_account: '520000',
      debit_credit: 'D',
      company_amount: 1000.00,
      event_type: 'MATERIAL_ISSUED_TO_PRODUCTION',
    };
    
    const posting = await erpUtils.postTestTransaction(journalEntry);
    expect(posting.company_amount).toBe(1000.00);
    
    // Verify via API
    const response = await request.get(`/api/projects/${project.id}/financials`);
    expect(response.ok()).toBeTruthy();
  });
});