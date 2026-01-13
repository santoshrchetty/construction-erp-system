# Archived Test Files

This directory contains test files that are no longer used but kept for reference.

## Files

- `setup-test-database.sql.archived` - Previously used to set up separate TEST database. Now we test against main database with safety measures.

## Why Archived

We simplified the test environment strategy to use only:
- **DEV**: Local development testing
- **MAIN**: Main database testing with safety controls (`ALLOW_MAIN_DB_TESTING=true`)
- **PROD**: Production (automation disabled)

The separate TEST database was redundant since main DB testing with `test_run_id` isolation provides better real-world testing conditions.