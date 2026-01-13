# Playwright Test Automation Strategy

## Directory Structure
```
tests/
├── e2e/                    # End-to-end UI tests (minimal)
├── api/                    # API integration tests (primary)
├── fixtures/               # Test data and setup
├── utils/                  # Test utilities and helpers
├── config/                 # Environment configurations
└── reports/               # Test execution reports
```

## Environment Strategy
- DEV: Current Supabase project (with test data tagging)
- TEST: Dedicated Supabase project (future)
- PROD: No automation allowed

## Test Data Strategy
- All test data tagged with `test_run_id`
- Automatic cleanup after test completion
- Isolated test users with limited permissions