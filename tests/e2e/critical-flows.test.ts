import { test, expect } from '@playwright/test';
import { ERPTestUtils } from '../utils/erp-utils';

test.describe('Critical User Flows', () => {
  let erpUtils: ERPTestUtils;
  
  test.beforeEach(async ({ page }) => {
    erpUtils = new ERPTestUtils();
    
    // Login with test user
    const testUser = await erpUtils.getTestUser('manager');
    await page.goto('/login');
    await page.fill('[data-testid="email"]', testUser.email);
    await page.fill('[data-testid="password"]', 'test-password');
    await page.click('[data-testid="login-button"]');
    
    // Wait for dashboard
    await expect(page.locator('[data-testid="dashboard"]')).toBeVisible();
  });
  
  test('should complete project creation flow', async ({ page }) => {
    // Navigate to project creation
    await page.click('[data-testid="create-project-tile"]');
    await expect(page.locator('[data-testid="project-form"]')).toBeVisible();
    
    // Fill project form
    await page.fill('[data-testid="project-name"]', 'E2E Test Project');
    await page.selectOption('[data-testid="project-type"]', 'CONSTRUCTION');
    await page.fill('[data-testid="project-description"]', 'Automated test project');
    
    // Submit form
    await page.click('[data-testid="submit-project"]');
    
    // Verify success
    await expect(page.locator('[data-testid="success-message"]')).toBeVisible();
    await expect(page.locator('[data-testid="project-code"]')).toContainText('TEST-');
  });
  
  test('should handle WIP module gracefully', async ({ page }) => {
    // Navigate to WIP module
    await page.click('[data-testid="wip-module-tile"]');
    
    // Should show WIP message, not crash
    await expect(page.locator('[data-testid="wip-message"]')).toBeVisible();
    await expect(page.locator('[data-testid="wip-message"]')).toContainText('Work in Progress');
  });
});