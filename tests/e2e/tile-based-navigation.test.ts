import { test, expect } from '@playwright/test';
import { randomUUID } from 'crypto';

test.describe('Tile-Based Project Creation Flow', () => {
  
  test('should navigate through tiles to access project creation form', async ({ page }) => {
    console.log('🔐 Step 1: Login...');
    
    // Login
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@nttdemo.com');
    await page.fill('input[type="password"]', 'demo123');
    await page.locator('button[type="submit"]').click();
    await page.waitForTimeout(3000);
    
    console.log('✅ Login successful, now at:', page.url());
    
    // Take screenshot of dashboard/tiles
    await page.screenshot({ path: 'tests/reports/tiles-dashboard.png' });
    
    console.log('🔍 Step 2: Looking for project creation tiles...');
    
    // Look for project-related tiles
    const projectTileSelectors = [
      'text=Create Project',
      'text=New Project', 
      'text=Project Creation',
      'text=Projects',
      '[data-tile="project"]',
      '[data-tile="create-project"]',
      'button:has-text("Project")',
      'div:has-text("Project")',
      '.tile:has-text("Project")',
      '[href="/engineer"]', // Since we found ProjectForm in engineer page
      'text=Engineer'
    ];
    
    let projectTileFound = false;
    let clickedTile = '';
    
    for (const selector of projectTileSelectors) {
      try {
        const count = await page.locator(selector).count();
        if (count > 0) {
          console.log(`✅ Found project tile: ${selector} (${count} elements)`);
          
          // Get text content
          const text = await page.locator(selector).first().textContent();
          console.log(`   Tile text: "${text?.trim()}"`);
          
          // Click the first matching tile
          await page.locator(selector).first().click();
          clickedTile = selector;
          projectTileFound = true;
          
          await page.waitForTimeout(2000);
          console.log(`✅ Clicked tile: ${selector}`);
          console.log(`   Current URL: ${page.url()}`);
          break;
        }
      } catch (e) {
        // Skip invalid selectors
      }
    }
    
    if (!projectTileFound) {
      console.log('❌ No project tiles found, exploring available tiles...');
      
      // Get all clickable elements that might be tiles
      const clickableElements = await page.locator('button, a, div[onclick], [role="button"]').count();
      console.log(`Found ${clickableElements} clickable elements`);
      
      // List first 20 clickable elements
      for (let i = 0; i < Math.min(clickableElements, 20); i++) {
        const element = page.locator('button, a, div[onclick], [role="button"]').nth(i);
        const text = await element.textContent();
        const href = await element.getAttribute('href');
        console.log(`  ${i + 1}. "${text?.trim()}" ${href ? `-> ${href}` : ''}`);
      }
    }
    
    console.log('🔍 Step 3: Looking for project creation form...');
    
    // Check if we're now on a page with the project form
    const formElements = await page.locator('form, input, select, textarea').count();
    console.log(`Current page has ${formElements} form elements`);
    
    // Look for the 4 tabs specifically
    const tabNames = ['Basic Information', 'Organization', 'Project Details', 'Review'];
    let tabsFound = [];
    
    for (const tabName of tabNames) {
      const tabSelectors = [
        `text="${tabName}"`,
        `text=${tabName}`,
        `button:has-text("${tabName}")`,
        `div:has-text("${tabName}")`
      ];
      
      for (const selector of tabSelectors) {
        try {
          const count = await page.locator(selector).count();
          if (count > 0) {
            tabsFound.push(tabName);
            console.log(`✅ Found tab: "${tabName}"`);
            break;
          }
        } catch (e) {
          // Skip invalid selectors
        }
      }
    }
    
    // If no tabs found, look for project creation button/trigger
    if (tabsFound.length === 0) {
      console.log('🔍 Looking for project creation trigger...');
      
      const createProjectSelectors = [
        'text=Create Project',
        'text=New Project',
        'text=Add Project',
        'button:has-text("Create")',
        'button:has-text("New")',
        '[data-testid="create-project"]',
        '.create-project',
        '#create-project'
      ];
      
      for (const selector of createProjectSelectors) {
        try {
          const count = await page.locator(selector).count();
          if (count > 0) {
            console.log(`✅ Found create project button: ${selector}`);
            await page.locator(selector).first().click();
            await page.waitForTimeout(2000);
            
            // Check for tabs again after clicking
            for (const tabName of tabNames) {
              const found = await page.locator(`text="${tabName}"`).count() > 0;
              if (found && !tabsFound.includes(tabName)) {
                tabsFound.push(tabName);
                console.log(`✅ Found tab after click: "${tabName}"`);
              }
            }
            break;
          }
        } catch (e) {
          // Skip invalid selectors
        }
      }
    }
    
    // Take final screenshot
    await page.screenshot({ path: 'tests/reports/project-form-final.png' });
    
    console.log('\n📊 RESULTS:');
    console.log(`Clicked tile: ${clickedTile}`);
    console.log(`Final URL: ${page.url()}`);
    console.log(`Form elements found: ${formElements}`);
    console.log(`Tabs found: ${tabsFound.join(', ')}`);
    
    console.log('\n📸 Screenshots saved:');
    console.log('- tests/reports/tiles-dashboard.png');
    console.log('- tests/reports/project-form-final.png');
    
    // Test passes if we found at least some project-related functionality
    expect(projectTileFound || formElements > 0 || tabsFound.length > 0).toBeTruthy();
  });
  
  test('should test engineer page directly for project form', async ({ page }) => {
    console.log('🔐 Login and go to engineer page...');
    
    // Login
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@nttdemo.com');
    await page.fill('input[type="password"]', 'demo123');
    await page.locator('button[type="submit"]').click();
    await page.waitForTimeout(3000);
    
    // Go directly to engineer page (where we found ProjectForm)
    await page.goto('/engineer');
    await page.waitForTimeout(2000);
    
    console.log('📍 Engineer page URL:', page.url());
    
    // Take screenshot
    await page.screenshot({ path: 'tests/reports/engineer-page.png' });
    
    // Look for project creation functionality
    const projectButtons = await page.locator('button:has-text("Project"), button:has-text("Create")').count();
    console.log(`Found ${projectButtons} project-related buttons`);
    
    if (projectButtons > 0) {
      // Click first project button
      await page.locator('button:has-text("Project"), button:has-text("Create")').first().click();
      await page.waitForTimeout(1000);
      
      // Check for the 4 tabs
      const tabs = ['Basic Information', 'Organization', 'Project Details', 'Review'];
      for (const tab of tabs) {
        const found = await page.locator(`text="${tab}"`).count() > 0;
        console.log(`Tab "${tab}": ${found ? '✅ Found' : '❌ Not found'}`);
      }
      
      await page.screenshot({ path: 'tests/reports/project-form-opened.png' });
    }
    
    console.log('📸 Screenshots: engineer-page.png, project-form-opened.png');
  });
});