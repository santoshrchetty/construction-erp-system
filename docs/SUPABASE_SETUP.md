# Supabase Setup Guide

## Quick Setup Steps

### 1. Create Supabase Project
1. Go to [https://supabase.com](https://supabase.com)
2. Sign up/Login and create a new project
3. Wait for the project to be ready (2-3 minutes)

### 2. Get Your Credentials
1. Go to **Settings** → **API** in your Supabase dashboard
2. Copy the **Project URL** and **anon public** key
3. Update `.env.local` with your actual values:

```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project-ref.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-actual-anon-key-here
```

### 3. Create Database Tables
1. Go to **SQL Editor** in your Supabase dashboard
2. Copy and paste the contents of `database/sap-config-schema.sql`
3. Click **Run** to create the tables and sample data

### 4. Test the Connection
1. Start your development server: `npm run dev`
2. Navigate to the SAP Config page
3. You should see the sample data loaded

## What's Included

- **Company Codes**: Legal entities for financial reporting
- **Controlling Areas**: Cost accounting organizational units
- **Cost Centers**: Overhead cost collection points
- **Profit Centers**: Profitability analysis units
- **Purchasing Organizations**: Procurement organizational units
- **Plants**: Physical locations/production facilities
- **Storage Locations**: Inventory storage areas

## Sample Data

The schema includes sample data to get you started:
- 2 Company Codes (1000, 2000)
- 2 Controlling Areas
- 3 Cost Centers
- 2 Profit Centers
- 2 Purchasing Organizations
- 2 Plants
- 3 Storage Locations

## Next Steps

Once setup is complete, you can:
1. Add/modify organizational units through the SAP Config interface
2. Integrate with the main construction management modules
3. Set up proper user authentication and authorization

## Troubleshooting

**Error: Missing Supabase environment variables**
- Make sure `.env.local` exists and has the correct values
- Restart your development server after updating environment variables

**Error: relation "company_codes" does not exist**
- Run the SQL schema in your Supabase SQL Editor
- Make sure all tables were created successfully

**Empty tables in the interface**
- Check that the sample data was inserted
- Verify your Supabase project is active and accessible