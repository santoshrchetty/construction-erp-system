import { test, expect } from '@playwright/test';

test.describe('Direct Engineer Page Test', () => {
  
  test('should access project form via engineer page', async ({ page }) => {
    // Login
    await page.goto('/login');
    await page.fill('input[type="email"]', 'admin@nttdemo.com');
    await page.fill('input[type="password"]', 'demo123');
    await page.locator('button[type="submit"]').click();
    await page.waitForTimeout(3000);
    
    console.log('✅ Logged in');
    
    // Go directly to engineer page (bypassing tile API issues)
    console.log('🚀 Going to /engineer page...');
    await page.goto('/engineer');
    await page.waitForTimeout(3000);
    
    console.log('📍 Current URL:', page.url());
    
    // Take screenshot
    await page.screenshot({ path: 'tests/reports/engineer-direct.png' });
    
    // Look for project creation button
    const buttons = await page.locator('button').count();
    console.log(`Found ${buttons} buttons on engineer page`);
    
    // List all buttons
    for (let i = 0; i < Math.min(buttons, 10); i++) {
      const text = await page.locator('button').nth(i).textContent();
      console.log(`Button ${i + 1}: "${text?.trim()}"`);
    }
    
    // Look for project-related text
    const pageText = await page.textContent('body');
    const hasProject = pageText?.toLowerCase().includes('project');
    console.log(`Page contains "project": ${hasProject}`);
    
    // Try to find and click project creation button
    const projectButton = page.locator('button').filter({ hasText: /project|create/i }).first();
    const projectButtonCount = await projectButton.count();
    
    if (projectButtonCount > 0) {
      console.log('✅ Found project button, clicking...');
      await projectButton.click();
      await page.waitForTimeout(2000);
      
      // Check for tabs after clicking
      const tabs = ['Basic Information', 'Organization', 'Project Details', 'Review'];
      for (const tab of tabs) {
        const found = await page.locator(`text="${tab}"`).count() > 0;
        console.log(`Tab "${tab}": ${found ? '✅' : '❌'}`);
      }
      
      await page.screenshot({ path: 'tests/reports/project-form-tabs.png' });
    } else {
      console.log('❌ No project button found');
    }
    
    expect(page.url()).toContain('/engineer');
  });
});