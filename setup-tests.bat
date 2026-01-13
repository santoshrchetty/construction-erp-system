@echo off
echo Setting up Playwright Test Environment...

REM Install dependencies
npm install @playwright/test @supabase/supabase-js uuid @types/uuid --save-dev

REM Install Playwright browsers
npx playwright install

REM Copy environment template
copy .env.test .env.test.local

echo Setup complete!
echo.
echo Next steps:
echo 1. Update .env.test.local with your Supabase credentials
echo 2. Run database migration: database/add_test_data_tagging.sql
echo 3. Run: npm run test:api
echo 4. Run: npm run test:e2e