import { test, expect } from '@playwright/test';

test.describe('Find Project Creation Route', () => {
  
  test('should login and find project creation functionality', async ({ page }) => {
    console.log('🔐 Logging in...');
    
    // Login
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@nttdemo.com');
    await page.fill('input[type="password"]', 'demo123');
    await page.locator('button[type="submit"]').click();
    await page.waitForTimeout(3000);
    
    console.log('✅ Logged in, redirected to:', page.url());
    
    // Take screenshot of dashboard
    await page.screenshot({ path: 'tests/reports/dashboard-after-login.png' });
    
    console.log('🔍 Exploring dashboard for project creation...');
    
    // Look for project-related links/buttons
    const projectSelectors = [
      'text=Project',
      'text=Create Project',
      'text=New Project',
      'text=Add Project',
      '[href*="project"]',
      'button:has-text("Project")',
      'a:has-text("Project")'
    ];
    
    console.log('\n📋 Looking for project-related elements...');
    
    for (const selector of projectSelectors) {
      try {
        const count = await page.locator(selector).count();
        if (count > 0) {
          console.log(`✅ Found ${count} elements matching: ${selector}`);
          
          for (let i = 0; i < Math.min(count, 3); i++) {
            const element = page.locator(selector).nth(i);
            const text = await element.textContent();
            const href = await element.getAttribute('href');
            console.log(`   - Text: "${text?.trim()}" Href: "${href || 'no-href'}"`);
          }
        }
      } catch (e) {
        // Skip invalid selectors
      }
    }
    
    console.log('\n🔍 Looking for navigation menu...');
    
    // Look for navigation menus
    const navSelectors = [
      'nav',
      '.navigation',
      '.menu',
      '.sidebar',
      'ul li a',
      '[role="navigation"]'
    ];
    
    for (const selector of navSelectors) {
      const count = await page.locator(selector).count();
      if (count > 0) {
        console.log(`✅ Found ${count} navigation elements: ${selector}`);
      }
    }
    
    console.log('\n🔍 Checking all links on page...');
    
    // Get all links
    const links = await page.locator('a[href]').count();
    console.log(`Found ${links} links total`);
    
    if (links > 0) {
      console.log('First 15 links:');
      for (let i = 0; i < Math.min(links, 15); i++) {
        const link = page.locator('a[href]').nth(i);
        const href = await link.getAttribute('href');
        const text = await link.textContent();
        console.log(`  ${i + 1}. "${text?.trim()}" -> ${href}`);
      }
    }
    
    console.log('\n🔍 Testing common project routes...');
    
    // Test different project routes
    const routes = [
      '/projects',
      '/project',
      '/dashboard/projects',
      '/erp-modules/projects',
      '/admin/projects'
    ];
    
    for (const route of routes) {
      try {
        console.log(`\n📍 Testing route: ${route}`);
        await page.goto(route, { timeout: 10000 });
        
        const finalUrl = page.url();
        const title = await page.title();
        const hasForm = await page.locator('form, input').count() > 0;
        
        console.log(`   Final URL: ${finalUrl}`);
        console.log(`   Title: ${title}`);
        console.log(`   Has forms: ${hasForm}`);
        
        if (hasForm) {
          console.log(`✅ ${route} has form elements!`);
          await page.screenshot({ path: `tests/reports/route-${route.replace(/\//g, '-')}.png` });
        }
        
      } catch (error) {
        console.log(`   ❌ Error accessing ${route}: ${error}`);
      }
    }
    
    console.log('\n🔍 Searching page content for "Basic Information"...');
    
    // Go back to dashboard and search for tab content
    await page.goto('/erp-modules');
    const bodyText = await page.textContent('body');
    
    if (bodyText?.includes('Basic Information')) {
      console.log('✅ Found "Basic Information" on current page');
    } else {
      console.log('❌ "Basic Information" not found on current page');
    }
    
    // Search for any forms on the current page
    const currentForms = await page.locator('form, input, select, textarea').count();
    console.log(`Current page has ${currentForms} form elements`);
  });
});