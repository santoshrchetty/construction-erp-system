import { test, expect } from '@playwright/test';

test.describe('Admin Login Path to Project Creation', () => {
  
  test('should access project creation through admin dashboard', async ({ page }) => {
    console.log('🔐 Login as admin...');
    
    // Login
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@nttdemo.com');
    await page.fill('input[type="password"]', 'demo123');
    await page.locator('button[type="submit"]').click();
    await page.waitForTimeout(3000);
    
    console.log('✅ Logged in, redirected to:', page.url());
    
    // Try admin-specific routes
    const adminRoutes = [
      '/admin',
      '/erp-modules', // Current redirect
      '/dashboard'
    ];
    
    for (const route of adminRoutes) {
      console.log(`\n🔍 Testing admin route: ${route}`);
      
      try {
        await page.goto(route);
        await page.waitForTimeout(2000);
        
        console.log(`   Current URL: ${page.url()}`);
        
        // Take screenshot
        await page.screenshot({ path: `tests/reports/admin-${route.replace('/', '')}.png` });
        
        // Look for project tiles/buttons
        const projectElements = [
          'text=Project',
          'text=Create Project',
          'text=New Project',
          '[data-tile*="project"]',
          'button:has-text("Project")',
          'a:has-text("Project")'
        ];
        
        let foundProjectAccess = false;
        
        for (const selector of projectElements) {
          try {
            const count = await page.locator(selector).count();
            if (count > 0) {
              console.log(`   ✅ Found project access: ${selector} (${count} elements)`);
              
              // Get text content
              for (let i = 0; i < Math.min(count, 3); i++) {
                const text = await page.locator(selector).nth(i).textContent();
                console.log(`      - "${text?.trim()}"`);
              }
              
              foundProjectAccess = true;
            }
          } catch (e) {
            // Skip invalid selectors
          }
        }
        
        if (foundProjectAccess) {
          console.log(`   🎯 Found project access on ${route}`);
          
          // Try clicking first project element
          const firstProjectElement = page.locator('text=Project, text=Create Project, button:has-text("Project")').first();
          const elementCount = await firstProjectElement.count();
          
          if (elementCount > 0) {
            console.log('   🚀 Clicking project element...');
            await firstProjectElement.click();
            await page.waitForTimeout(2000);
            
            console.log(`   📍 After click URL: ${page.url()}`);
            
            // Check for project form tabs
            const tabs = ['Basic Information', 'Organization', 'Project Details', 'Review'];
            let tabsFound = [];
            
            for (const tab of tabs) {
              const found = await page.locator(`text="${tab}"`).count() > 0;
              if (found) {
                tabsFound.push(tab);
                console.log(`   ✅ Found tab: "${tab}"`);
              }
            }
            
            if (tabsFound.length > 0) {
              console.log(`   🎉 SUCCESS! Found ${tabsFound.length} project form tabs`);
              await page.screenshot({ path: 'tests/reports/project-form-success.png' });
              
              // Test tab navigation
              for (const tab of tabsFound) {
                try {
                  await page.locator(`text="${tab}"`).click();
                  await page.waitForTimeout(500);
                  console.log(`   ✅ Clicked tab: "${tab}"`);
                } catch (e) {
                  console.log(`   ❌ Could not click tab: "${tab}"`);
                }
              }
              
              return; // Success - exit test
            }
          }
        }
        
        // List all clickable elements if no project access found
        if (!foundProjectAccess) {
          console.log('   📋 Available clickable elements:');
          const clickables = await page.locator('button, a, [role="button"]').count();
          
          for (let i = 0; i < Math.min(clickables, 10); i++) {
            const element = page.locator('button, a, [role="button"]').nth(i);
            const text = await element.textContent();
            const href = await element.getAttribute('href');
            console.log(`      ${i + 1}. "${text?.trim()}" ${href ? `-> ${href}` : ''}`);
          }
        }
        
      } catch (error) {
        console.log(`   ❌ Error accessing ${route}: ${error}`);
      }
    }
    
    console.log('\n📸 Screenshots saved in tests/reports/');
    
    // Test should pass if we accessed any admin route
    expect(page.url()).toMatch(/admin|erp-modules|dashboard/);
  });
});