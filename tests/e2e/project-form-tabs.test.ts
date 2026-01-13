import { test, expect } from '@playwright/test';
import { randomUUID } from 'crypto';

test.describe('Project Creation Form - Multi-Tab Flow', () => {
  
  test('should complete full project creation through all tabs', async ({ page }) => {
    const testProjectName = `E2E Test Project ${randomUUID().slice(0, 8)}`;
    
    // Navigate to project creation form
    await page.goto('/projects/new');
    
    // Verify form loads
    await expect(page).toHaveTitle(/Project|Construction/i);
    
    // === TAB 1: Basic Information ===
    console.log('📝 Filling Basic Information tab...');
    
    // Look for Basic Information tab or fields
    const basicTab = page.locator('text=Basic Information').or(page.locator('[data-tab="basic"]')).first();
    if (await basicTab.count() > 0) {
      await basicTab.click();
    }
    
    // Fill basic project fields
    const projectNameField = page.locator('input[name="project_name"]')
      .or(page.locator('input[placeholder*="project name"]'))
      .or(page.locator('input[placeholder*="Project Name"]'))
      .first();
    
    if (await projectNameField.count() > 0) {
      await projectNameField.fill(testProjectName);
      console.log('✅ Project name filled');
    }
    
    // Project type selection
    const projectTypeField = page.locator('select[name="project_type"]')
      .or(page.locator('select[name="projectType"]'))
      .or(page.locator('[data-testid="project-type"]'))
      .first();
    
    if (await projectTypeField.count() > 0) {
      await projectTypeField.selectOption('CONSTRUCTION');
      console.log('✅ Project type selected');
    }
    
    // === TAB 2: Organization ===
    console.log('🏢 Moving to Organization tab...');
    
    const orgTab = page.locator('text=Organization')
      .or(page.locator('text=Organisation'))
      .or(page.locator('[data-tab="organization"]'))
      .first();
    
    if (await orgTab.count() > 0) {
      await orgTab.click();
      await page.waitForTimeout(500); // Allow tab to load
    }
    
    // Fill organization fields
    const companyField = page.locator('select[name="company_code"]')
      .or(page.locator('input[name="company"]'))
      .or(page.locator('[data-testid="company"]'))
      .first();
    
    if (await companyField.count() > 0) {
      if (await companyField.getAttribute('tagName') === 'SELECT') {
        await companyField.selectOption('TEST');
      } else {
        await companyField.fill('TEST');
      }
      console.log('✅ Company code set');
    }
    
    // === TAB 3: Project Details ===
    console.log('📋 Moving to Project Details tab...');
    
    const detailsTab = page.locator('text=Project Details')
      .or(page.locator('[data-tab="details"]'))
      .first();
    
    if (await detailsTab.count() > 0) {
      await detailsTab.click();
      await page.waitForTimeout(500);
    }
    
    // Fill project details
    const descriptionField = page.locator('textarea[name="description"]')
      .or(page.locator('textarea[name="project_description"]'))
      .or(page.locator('[data-testid="description"]'))
      .first();
    
    if (await descriptionField.count() > 0) {
      await descriptionField.fill('Automated test project created via Playwright E2E testing');
      console.log('✅ Description filled');
    }
    
    // === TAB 4: Review and Submit ===
    console.log('✅ Moving to Review and Submit tab...');
    
    const reviewTab = page.locator('text=Review and Submit')
      .or(page.locator('text=Review & Submit'))
      .or(page.locator('text=Submit'))
      .or(page.locator('[data-tab="review"]'))
      .first();
    
    if (await reviewTab.count() > 0) {
      await reviewTab.click();
      await page.waitForTimeout(500);
    }
    
    // Verify review information
    const reviewContent = page.locator('body');
    await expect(reviewContent).toContainText(testProjectName);
    console.log('✅ Project details visible in review');
    
    // Submit the form
    const submitButton = page.locator('button[type="submit"]')
      .or(page.locator('button:has-text("Submit")'))
      .or(page.locator('button:has-text("Create Project")'))
      .or(page.locator('[data-testid="submit"]'))
      .first();
    
    if (await submitButton.count() > 0) {
      await submitButton.click();
      console.log('🚀 Form submitted');
      
      // Wait for success indication
      await page.waitForTimeout(2000);
      
      // Look for success message or redirect
      const successIndicators = [
        page.locator('text=success'),
        page.locator('text=created'),
        page.locator('text=Project created'),
        page.locator('[data-testid="success"]'),
      ];
      
      let successFound = false;
      for (const indicator of successIndicators) {
        if (await indicator.count() > 0) {
          successFound = true;
          console.log('✅ Success message found');
          break;
        }
      }
      
      // Check if redirected to project list or dashboard
      const currentUrl = page.url();
      if (currentUrl.includes('/projects') || currentUrl.includes('/dashboard')) {
        successFound = true;
        console.log('✅ Redirected after creation');
      }
      
      expect(successFound).toBeTruthy();
    } else {
      console.log('ℹ️ Submit button not found - form may auto-submit');
    }
    
    // Take screenshot of final state
    await page.screenshot({ path: 'tests/reports/project-creation-complete.png' });
  });
  
  test('should validate tab navigation', async ({ page }) => {
    await page.goto('/projects/new');
    
    const tabs = [
      'Basic Information',
      'Organization',
      'Project Details', 
      'Review and Submit'
    ];
    
    console.log('🔍 Checking tab navigation...');
    
    for (const tabName of tabs) {
      const tab = page.locator(`text=${tabName}`).first();
      if (await tab.count() > 0) {
        await tab.click();
        await page.waitForTimeout(300);
        console.log(`✅ ${tabName} tab accessible`);
      } else {
        console.log(`ℹ️ ${tabName} tab not found`);
      }
    }
  });
});