@echo off
echo Running Resource Planning Migration...
echo.
echo Please run this SQL file in your Supabase SQL Editor:
echo database/00-resource-planning-complete.sql
echo.
echo After running the migration, execute:
echo npx supabase gen types typescript --project-id tpngnqukhvgrkokleirx ^> types/supabase/database.types.ts
echo.
echo Then rebuild: npm run build
pause
