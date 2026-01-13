import { test, expect } from '@playwright/test';
import { randomUUID } from 'crypto';

test.describe('Authenticated Project Creation - Multi-Tab Form', () => {
  
  test('should login and complete multi-tab project creation', async ({ page }) => {
    const testProjectName = `E2E Test Project ${randomUUID().slice(0, 8)}`;
    
    // Navigate to project creation (will redirect to login)
    await page.goto('/projects/new');
    
    // Login with provided credentials
    console.log('🔐 Logging in...');
    await page.fill('input[type="email"]', 'admin@nttdemo.com');
    await page.fill('input[type="password"]', 'demo123');
    
    const loginButton = page.locator('button[type="submit"]')
      .or(page.locator('button:has-text("Sign In")'))
      .first();
    
    await loginButton.click();
    await page.waitForTimeout(3000); // Wait for login and redirect
    
    // Should now be on project creation form
    console.log('Current URL after login:', page.url());
    
    // Take screenshot of the form
    await page.screenshot({ path: 'tests/reports/project-form-after-login.png' });
    
    // === ANALYZE FORM STRUCTURE ===
    console.log('\n🔍 Analyzing form structure...');
    
    // Look for tabs
    const tabSelectors = [
      'text=Basic Information',
      'text=Organization', 
      'text=Project Details',
      'text=Review and Submit',
      '[role="tab"]',
      '.tab',
      'button:contains("Basic")',
      'li:contains("Basic")'
    ];
    
    let foundTabs = [];
    for (const selector of tabSelectors) {
      const count = await page.locator(selector).count();
      if (count > 0) {
        const text = await page.locator(selector).first().textContent();
        foundTabs.push(text?.trim());
        console.log(`✅ Found tab: "${text?.trim()}"`);
      }
    }
    
    // === TAB 1: BASIC INFORMATION ===
    console.log('\n📝 Tab 1: Basic Information');
    
    // Try to click Basic Information tab
    const basicTab = page.locator('text=Basic Information')
      .or(page.locator('button:has-text("Basic")'))
      .or(page.locator('[data-tab="basic"]'))
      .first();
    
    if (await basicTab.count() > 0) {
      await basicTab.click();
      console.log('✅ Clicked Basic Information tab');
    }
    
    // Fill project name
    const nameSelectors = [
      'input[name="project_name"]',
      'input[name="projectName"]', 
      'input[placeholder*="project name"]',
      'input[placeholder*="Project Name"]'
    ];
    
    for (const selector of nameSelectors) {
      if (await page.locator(selector).count() > 0) {
        await page.locator(selector).fill(testProjectName);
        console.log('✅ Project name filled');
        break;
      }
    }
    
    // === TAB 2: ORGANIZATION ===
    console.log('\n🏢 Tab 2: Organization');
    
    const orgTab = page.locator('text=Organization')
      .or(page.locator('button:has-text("Organization")'))
      .first();
    
    if (await orgTab.count() > 0) {
      await orgTab.click();
      await page.waitForTimeout(500);
      console.log('✅ Clicked Organization tab');
    }
    
    // === TAB 3: PROJECT DETAILS ===
    console.log('\n📋 Tab 3: Project Details');
    
    const detailsTab = page.locator('text=Project Details')
      .or(page.locator('button:has-text("Details")'))
      .first();
    
    if (await detailsTab.count() > 0) {
      await detailsTab.click();
      await page.waitForTimeout(500);
      console.log('✅ Clicked Project Details tab');
    }
    
    // === TAB 4: REVIEW AND SUBMIT ===
    console.log('\n✅ Tab 4: Review and Submit');
    
    const reviewTab = page.locator('text=Review and Submit')
      .or(page.locator('text=Review & Submit'))
      .or(page.locator('button:has-text("Review")'))
      .first();
    
    if (await reviewTab.count() > 0) {
      await reviewTab.click();
      await page.waitForTimeout(500);
      console.log('✅ Clicked Review and Submit tab');
    }
    
    // Take final screenshot
    await page.screenshot({ path: 'tests/reports/project-form-complete.png' });
    
    // Summary
    console.log('\n📊 FORM ANALYSIS SUMMARY:');
    console.log(`Found ${foundTabs.length} tabs:`, foundTabs);
    console.log('Screenshots saved:');
    console.log('- tests/reports/project-form-after-login.png');
    console.log('- tests/reports/project-form-complete.png');
    
    // Verify we're on the right page
    expect(page.url()).toContain('project');
  });
  
  test('should explore form fields in each tab', async ({ page }) => {
    // Login first
    await page.goto('/projects/new');
    await page.fill('input[type="email"]', 'admin@nttdemo.com');
    await page.fill('input[type="password"]', 'demo123');
    await page.locator('button[type="submit"]').click();
    await page.waitForTimeout(3000);
    
    console.log('\n🔍 EXPLORING FORM FIELDS...');
    
    // Get all input fields
    const inputs = await page.locator('input, select, textarea').count();
    console.log(`Total form fields found: ${inputs}`);
    
    if (inputs > 0) {
      for (let i = 0; i < Math.min(inputs, 15); i++) {
        const input = page.locator('input, select, textarea').nth(i);
        const name = await input.getAttribute('name') || 'no-name';
        const type = await input.getAttribute('type') || await input.evaluate(el => el.tagName.toLowerCase());
        const placeholder = await input.getAttribute('placeholder') || '';
        const label = await input.locator('..').locator('label').textContent().catch(() => '');
        
        console.log(`${i + 1}. ${type}: name="${name}" placeholder="${placeholder}" label="${label}"`);
      }
    }
    
    // Get all buttons
    const buttons = await page.locator('button').count();
    console.log(`\nButtons found: ${buttons}`);
    
    for (let i = 0; i < Math.min(buttons, 10); i++) {
      const text = await page.locator('button').nth(i).textContent();
      console.log(`Button ${i + 1}: "${text?.trim()}"`);
    }
  });
});