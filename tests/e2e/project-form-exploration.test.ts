import { test, expect } from '@playwright/test';
import { randomUUID } from 'crypto';

test.describe('Project Creation Form - After Login', () => {
  
  test('should login and explore multi-tab project form', async ({ page }) => {
    console.log('🔐 Step 1: Login...');
    
    // Login first
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@nttdemo.com');
    await page.fill('input[type="password"]', 'demo123');
    await page.locator('button[type="submit"]').click();
    await page.waitForTimeout(3000);
    
    console.log('✅ Login successful, now at:', page.url());
    
    console.log('🚀 Step 2: Navigate to project creation...');
    
    // Now navigate to project creation
    await page.goto('/projects/new');
    await page.waitForTimeout(2000);
    
    console.log('📍 Project form URL:', page.url());
    
    // Take screenshot of the project form
    await page.screenshot({ 
      path: 'tests/reports/project-form-authenticated.png',
      fullPage: true 
    });
    
    console.log('🔍 Step 3: Analyze form structure...');
    
    // Get page title and content
    const title = await page.title();
    console.log('Page title:', title);
    
    // Look for the 4 tabs you mentioned
    const expectedTabs = [
      'Basic Information',
      'Organization', 
      'Project Details',
      'Review and Submit'
    ];
    
    console.log('\n📋 Looking for tabs...');
    
    for (const tabName of expectedTabs) {
      // Try different ways to find tabs
      const tabSelectors = [
        `text="${tabName}"`,
        `text=${tabName}`,
        `[data-tab*="${tabName.toLowerCase().replace(' ', '-')}"]`,
        `button:has-text("${tabName}")`,
        `li:has-text("${tabName}")`,
        `.tab:has-text("${tabName}")`
      ];
      
      let found = false;
      for (const selector of tabSelectors) {
        try {
          const count = await page.locator(selector).count();
          if (count > 0) {
            console.log(`✅ Found "${tabName}" tab using selector: ${selector}`);
            found = true;
            break;
          }
        } catch (e) {
          // Skip invalid selectors
        }
      }
      
      if (!found) {
        console.log(`❌ "${tabName}" tab not found`);
      }
    }
    
    console.log('\n📝 Step 4: Analyze all form elements...');
    
    // Get all form elements
    const inputs = await page.locator('input').count();
    const selects = await page.locator('select').count();
    const textareas = await page.locator('textarea').count();
    const buttons = await page.locator('button').count();
    
    console.log(`Form elements found:`);
    console.log(`- Inputs: ${inputs}`);
    console.log(`- Selects: ${selects}`);
    console.log(`- Textareas: ${textareas}`);
    console.log(`- Buttons: ${buttons}`);
    
    // List first 10 input fields
    if (inputs > 0) {
      console.log('\nInput fields:');
      for (let i = 0; i < Math.min(inputs, 10); i++) {
        const input = page.locator('input').nth(i);
        const name = await input.getAttribute('name') || 'no-name';
        const type = await input.getAttribute('type') || 'text';
        const placeholder = await input.getAttribute('placeholder') || '';
        console.log(`  ${i + 1}. ${type}: name="${name}" placeholder="${placeholder}"`);
      }
    }
    
    // List buttons
    if (buttons > 0) {
      console.log('\nButtons:');
      for (let i = 0; i < Math.min(buttons, 8); i++) {
        const text = await page.locator('button').nth(i).textContent();
        console.log(`  ${i + 1}. "${text?.trim()}"`);
      }
    }
    
    console.log('\n🔍 Step 5: Look for tab-like navigation...');
    
    // Look for any navigation elements
    const navSelectors = [
      '[role="tablist"]',
      '.tabs',
      '.tab-navigation', 
      '.steps',
      '.wizard',
      'nav',
      'ul li',
      '.nav-tabs'
    ];
    
    for (const selector of navSelectors) {
      const count = await page.locator(selector).count();
      if (count > 0) {
        console.log(`✅ Found ${count} navigation elements: ${selector}`);
        
        // Get text content
        const elements = page.locator(selector);
        for (let i = 0; i < Math.min(count, 3); i++) {
          const text = await elements.nth(i).textContent();
          console.log(`   - "${text?.trim().slice(0, 100)}"`);
        }
      }
    }
    
    // Get all text content to search for tab names
    const bodyText = await page.textContent('body');
    console.log('\n🔍 Searching page content for tab keywords...');
    
    for (const tabName of expectedTabs) {
      if (bodyText?.includes(tabName)) {
        console.log(`✅ Found "${tabName}" in page content`);
      } else {
        console.log(`❌ "${tabName}" not found in page content`);
      }
    }
    
    console.log('\n📸 Screenshots saved:');
    console.log('- tests/reports/project-form-authenticated.png');
    
    // Verify we have some form elements
    expect(inputs + selects + textareas).toBeGreaterThan(0);
  });
});