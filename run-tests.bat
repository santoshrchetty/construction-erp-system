@echo off
echo Running tests against TEST Supabase environment...

REM Set environment variables
set TEST_ENV=TEST
set TEST_SUPABASE_URL=https://tozgoiwobgdscplxdgbv.supabase.co
set TEST_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRvemdvaXdvYmdkc2NwbHhkZ2J2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc3ODc4MTgsImV4cCI6MjA4MzM2MzgxOH0.mxCS2VfY74qCiGNnhmcx0N9aX_nTi6yujzVk44lti9E
set TEST_BASE_URL=http://localhost:3000

REM Run API tests first
echo Running API tests...
npx playwright test --project=api-tests

REM Run E2E tests
echo Running E2E tests...
npx playwright test --project=e2e-critical

echo Tests complete! View report with: npm run test:report