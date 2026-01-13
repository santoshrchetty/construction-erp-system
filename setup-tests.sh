#!/bin/bash

echo "Setting up Playwright Test Environment..."

# Install Playwright
npm install @playwright/test @supabase/supabase-js uuid @types/uuid --save-dev

# Install Playwright browsers
npx playwright install

# Run database migration for test tagging
echo "Running database migration..."
# You'll need to run this in your Supabase SQL editor:
# database/add_test_data_tagging.sql

# Copy environment template
cp .env.test .env.test.local

echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Update .env.test.local with your Supabase credentials"
echo "2. Run: npm run test:api"
echo "3. Run: npm run test:e2e"