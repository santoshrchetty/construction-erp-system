# Quick Setup Guide

## 1. Install Dependencies
```bash
npm install
```

## 2. Database Setup
1. Go to your Supabase project: https://tpngnqukhvgrkokleirx.supabase.co
2. Navigate to SQL Editor
3. Copy and paste the entire content from `database/schema.sql`
4. Run the SQL to create all tables, enums, indexes, and triggers

## 3. Get API Keys
1. In Supabase dashboard, go to Settings → API
2. Copy your `anon/public` key and `service_role` key
3. Update `.env.local` with your keys:

```env
NEXT_PUBLIC_SUPABASE_URL=https://tpngnqukhvgrkokleirx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_actual_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_actual_service_role_key
```

## 4. Test Connection
```typescript
import { repositories } from './lib/repositories'

// Test creating a project
const project = await repositories.projects.create({
  name: 'Test Project',
  code: 'TEST-001',
  project_type: 'commercial',
  start_date: '2024-01-01',
  planned_end_date: '2024-12-31',
  budget: 1000000
})
```

## 5. Row Level Security (Optional)
Enable RLS in Supabase dashboard for production security:
- Go to Authentication → Policies
- Enable RLS on all tables
- Create policies based on user roles