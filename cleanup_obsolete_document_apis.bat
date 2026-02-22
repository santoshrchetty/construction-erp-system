@echo off
echo Removing obsolete document governance APIs and components...

REM Remove the main document-governance API route (contains obsolete endpoints)
if exist "app\api\document-governance\route.ts" (
    del "app\api\document-governance\route.ts"
    echo Removed: app\api\document-governance\route.ts
)

REM Remove obsolete component files
if exist "components\features\document-governance\ContractManagement.tsx" (
    del "components\features\document-governance\ContractManagement.tsx"
    echo Removed: components\features\document-governance\ContractManagement.tsx
)

if exist "components\features\document-governance\RFIManagement.tsx" (
    del "components\features\document-governance\RFIManagement.tsx"
    echo Removed: components\features\document-governance\RFIManagement.tsx
)

if exist "components\features\document-governance\index.ts" (
    del "components\features\document-governance\index.ts"
    echo Removed: components\features\document-governance\index.ts
)

REM Remove the entire document-governance components directory if empty
if exist "components\features\document-governance" (
    rmdir "components\features\document-governance" 2>nul
    if not exist "components\features\document-governance" (
        echo Removed: components\features\document-governance directory
    )
)

echo.
echo Cleanup completed. The following obsolete files have been removed:
echo - Obsolete document-governance API routes
echo - Contract management components  
echo - RFI management components
echo - Document governance component index
echo.
echo The unified document system (records API and forms) remains intact.

pause