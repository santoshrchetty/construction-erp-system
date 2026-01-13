# ERP Transport Strategy

## Environment Landscape
```
DEV → TEST → PROD
```

## Transport Process

### 1. Development Phase (DEV)
- All development happens in DEV environment
- Playwright tests run against DEV Supabase project
- Test data tagged with `test_run_id` for isolation
- Automatic cleanup after each test run

### 2. Quality Assurance (TEST)
- Dedicated TEST Supabase project (future)
- Same Playwright tests, different environment variables
- No code changes required - only configuration
- Controlled test data sets

### 3. Production (PROD)
- NO automation allowed
- Manual verification only
- Separate Supabase project
- Full audit trail

## Transport Objects

### Code Changes
- Next.js application code
- Database schema changes
- Configuration updates

### Test Artifacts
- Playwright test suites
- Test data fixtures
- Environment configurations

## Promotion Process

1. **DEV → TEST**
   - Git branch merge to `test` branch
   - Update TEST environment variables
   - Run full test suite in TEST environment
   - Validate all critical flows

2. **TEST → PROD**
   - Git tag for release version
   - Manual deployment to PROD
   - No automated tests in PROD
   - Manual smoke testing only

## Audit Requirements

- All test runs logged with timestamps
- Test data lifecycle tracked
- Environment access controlled
- Change history maintained