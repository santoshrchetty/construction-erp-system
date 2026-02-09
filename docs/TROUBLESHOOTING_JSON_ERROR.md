# Troubleshooting: "Unexpected token '<'" Error

## Problem
Console shows: `SyntaxError: Unexpected token '<', "<!DOCTYPE "... is not valid JSON`

## Cause
The API endpoint is returning HTML (likely a 404 error page) instead of JSON. This happens when Next.js hasn't picked up the new route file.

## Solution

### Option 1: Restart Next.js Dev Server (Recommended)
```bash
# Stop the dev server (Ctrl+C)
# Then restart:
npm run dev
```

### Option 2: Check Route File Exists
Verify the file exists at:
```
app/api/authorization-objects/fields/route.ts
```

### Option 3: Clear Next.js Cache
```bash
# Delete .next folder
rmdir /s /q .next

# Restart dev server
npm run dev
```

## Verification

After restarting, test the endpoint:

1. Open browser DevTools (F12)
2. Go to Network tab
3. Try adding a field
4. Check the request to `/api/authorization-objects/fields`
5. Should return JSON, not HTML

Expected response:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "auth_object_id": "uuid",
    "field_code": "ACTVT",
    "is_required": true,
    "tenant_id": "uuid"
  }
}
```

## If Still Not Working

Check these files exist:
- ✅ `app/api/authorization-objects/fields/route.ts`
- ✅ `app/api/authorization-objects/route.ts`
- ✅ Database table `authorization_object_fields` created

## Common Issues

1. **Route file in wrong location**
   - Must be: `app/api/authorization-objects/fields/route.ts`
   - Not: `app/api/authorization-objects/fields.ts`

2. **Missing export**
   - File must export: `export const POST`, `export const PUT`, `export const DELETE`

3. **TypeScript errors**
   - Check terminal for compilation errors
   - Fix any TypeScript errors before testing

4. **Port conflict**
   - Make sure dev server is running on correct port
   - Check `http://localhost:3000` (or your configured port)
