# Database Schema

## Current Production Schema
- **`current_schema.sql`** - Latest production database schema (v4.0)
  - Single source of truth for database structure
  - Includes all organizational field migrations
  - Matches actual Supabase database

## Archive
- **`archive/`** - Historical migration files and old schemas
  - Contains 500+ migration scripts from development
  - Kept for reference and rollback purposes
  - Not needed for current development

## Usage
Use `current_schema.sql` for:
- New environment setup
- Schema reference
- Database documentation
- Fresh installations

The archive folder contains historical context but is not required for day-to-day development.