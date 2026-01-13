import { test, expect } from '@playwright/test';

test.describe('Project Form Structure Analysis', () => {
  
  test('should analyze project form structure and tabs', async ({ page }) => {
    // Go to project creation form
    await page.goto('/projects/new');
    
    // Check if login is required
    const pageContent = await page.textContent('body');
    console.log('Page content preview:', pageContent?.slice(0, 200));
    
    if (pageContent?.includes('Sign in') || pageContent?.includes('Login')) {
      console.log('🔐 Login required - analyzing login form');
      
      // Try to find login fields
      const emailField = page.locator('input[type="email"]').or(page.locator('input[name="email"]')).first();
      const passwordField = page.locator('input[type="password"]').first();
      
      if (await emailField.count() > 0 && await passwordField.count() > 0) {
        console.log('📧 Login form found - attempting test login');
        
        // Try common test credentials
        await emailField.fill('test@example.com');
        await passwordField.fill('password');
        
        const loginButton = page.locator('button[type="submit"]')
          .or(page.locator('button:has-text("Sign In")'))
          .or(page.locator('button:has-text("Login")'))
          .first();
        
        if (await loginButton.count() > 0) {
          await loginButton.click();
          await page.waitForTimeout(2000);
        }
      }
    }
    
    // Now analyze the current page
    const currentUrl = page.url();
    console.log('Current URL:', currentUrl);
    
    // Look for form elements
    const formElements = await page.locator('form, [role="form"], .form').count();
    console.log('Form elements found:', formElements);
    
    // Look for tab-like elements
    const tabSelectors = [
      '[role="tab"]',
      '.tab',
      '[data-tab]',
      'button:has-text("Basic")',
      'button:has-text("Organization")',
      'button:has-text("Details")',
      'button:has-text("Review")',
      'li:has-text("Basic")',
      'div:has-text("Basic Information")',
    ];
    
    console.log('\n🔍 Searching for tabs...');
    for (const selector of tabSelectors) {
      const count = await page.locator(selector).count();
      if (count > 0) {
        console.log(`✅ Found ${count} elements matching: ${selector}`);
        
        // Get text content of found elements
        const elements = page.locator(selector);
        for (let i = 0; i < Math.min(count, 3); i++) {
          const text = await elements.nth(i).textContent();
          console.log(`   - Element ${i + 1}: "${text?.trim()}"`);
        }
      }
    }
    
    // Look for input fields
    const inputFields = await page.locator('input, select, textarea').count();
    console.log(`\n📝 Found ${inputFields} input fields`);
    
    if (inputFields > 0) {
      console.log('Input field details:');
      const inputs = page.locator('input, select, textarea');
      for (let i = 0; i < Math.min(inputFields, 10); i++) {
        const input = inputs.nth(i);
        const name = await input.getAttribute('name') || 'no-name';
        const type = await input.getAttribute('type') || 'text';
        const placeholder = await input.getAttribute('placeholder') || '';
        console.log(`   - ${type}: name="${name}" placeholder="${placeholder}"`);
      }
    }
    
    // Look for buttons
    const buttons = await page.locator('button').count();
    console.log(`\n🔘 Found ${buttons} buttons`);
    
    if (buttons > 0) {
      const buttonElements = page.locator('button');
      for (let i = 0; i < Math.min(buttons, 5); i++) {
        const text = await buttonElements.nth(i).textContent();
        console.log(`   - Button: "${text?.trim()}"`);
      }
    }
    
    // Take screenshot for manual analysis
    await page.screenshot({ 
      path: 'tests/reports/project-form-analysis.png',
      fullPage: true 
    });
    
    console.log('\n📸 Screenshot saved: tests/reports/project-form-analysis.png');
    
    // Get full page HTML for analysis
    const html = await page.content();
    console.log('\nPage title:', await page.title());
    console.log('HTML length:', html.length);
    
    // Look for specific project-related text
    const projectKeywords = ['project', 'basic', 'organization', 'details', 'review', 'submit'];
    console.log('\n🔍 Project-related content:');
    
    for (const keyword of projectKeywords) {
      if (pageContent?.toLowerCase().includes(keyword)) {
        console.log(`✅ Found keyword: "${keyword}"`);
      }
    }
  });
  
  test('should try different project creation routes', async ({ page }) => {
    const routes = [
      '/projects/new',
      '/projects/create', 
      '/project/new',
      '/project/create',
      '/dashboard/projects/new',
      '/create-project'
    ];
    
    console.log('🔍 Testing different project creation routes...');
    
    for (const route of routes) {
      try {
        await page.goto(route);
        await page.waitForTimeout(1000);
        
        const title = await page.title();
        const url = page.url();
        const hasForm = await page.locator('form, input').count() > 0;
        
        console.log(`\n📍 Route: ${route}`);
        console.log(`   Title: ${title}`);
        console.log(`   Final URL: ${url}`);
        console.log(`   Has form elements: ${hasForm}`);
        
        if (hasForm) {
          console.log(`✅ ${route} has form elements - potential project creation page`);
        }
        
      } catch (error) {
        console.log(`❌ ${route} - Error: ${error}`);
      }
    }
  });
});