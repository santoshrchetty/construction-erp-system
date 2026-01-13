import { test, expect } from '@playwright/test';

test.describe('Login Debug', () => {
  
  test('should test login process step by step', async ({ page }) => {
    console.log('🔍 Testing login process...');
    
    // Go to login page
    await page.goto('/login');
    
    // Take screenshot before login
    await page.screenshot({ path: 'tests/reports/before-login.png' });
    
    // Fill credentials
    console.log('📧 Filling email: admin@nttdemo.com');
    await page.fill('input[type="email"]', 'admin@nttdemo.com');
    
    console.log('🔑 Filling password: demo123');
    await page.fill('input[type="password"]', 'demo123');
    
    // Take screenshot with filled form
    await page.screenshot({ path: 'tests/reports/login-filled.png' });
    
    // Click login button
    console.log('🚀 Clicking login button...');
    const loginButton = page.locator('button[type="submit"]').first();
    await loginButton.click();
    
    // Wait and check result
    await page.waitForTimeout(5000);
    
    const currentUrl = page.url();
    console.log('Current URL after login attempt:', currentUrl);
    
    // Take screenshot after login attempt
    await page.screenshot({ path: 'tests/reports/after-login-attempt.png' });
    
    // Check for error messages
    const errorSelectors = [
      'text=Invalid',
      'text=Error',
      'text=incorrect',
      'text=failed',
      '.error',
      '[role="alert"]'
    ];
    
    for (const selector of errorSelectors) {
      const count = await page.locator(selector).count();
      if (count > 0) {
        const text = await page.locator(selector).textContent();
        console.log(`❌ Error found: "${text}"`);
      }
    }
    
    // Check if we're still on login page
    if (currentUrl.includes('/login')) {
      console.log('❌ Still on login page - credentials may be incorrect');
      
      // Get page content to see what happened
      const pageText = await page.textContent('body');
      console.log('Page content preview:', pageText?.slice(0, 300));
    } else {
      console.log('✅ Login successful - redirected to:', currentUrl);
    }
  });
  
  test('should try to access project form directly', async ({ page }) => {
    console.log('🔍 Trying to access project form without login...');
    
    await page.goto('/projects/new');
    
    const url = page.url();
    console.log('Final URL:', url);
    
    if (url.includes('/login')) {
      console.log('✅ Correctly redirected to login (authentication required)');
    } else {
      console.log('ℹ️ No authentication required or different behavior');
      
      // Take screenshot of what we see
      await page.screenshot({ path: 'tests/reports/direct-access.png' });
      
      // Check for form elements
      const formCount = await page.locator('form, input').count();
      console.log(`Found ${formCount} form elements`);
    }
  });
});