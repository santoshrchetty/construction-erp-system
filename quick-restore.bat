@echo off
echo 🔄 Construction App - Quick Restore
echo ===================================

REM Create immediate backup
echo Creating backup before restore...
node -e "const {restoreManager} = require('./lib/restorePoint'); console.log('Backup ID:', restoreManager.autoBackup())"

echo.
echo Available restore points:
node -e "const {restoreManager} = require('./lib/restorePoint'); const points = restoreManager.listRestorePoints(); points.forEach((p,i) => console.log(`${i+1}. ${p.description} (${new Date(p.timestamp).toLocaleString()})`));"

echo.
set /p choice="Enter number to restore (or 0 to cancel): "

if "%choice%"=="0" (
    echo Cancelled.
    goto :end
)

node -e "const {restoreManager} = require('./lib/restorePoint'); const points = restoreManager.listRestorePoints(); const index = %choice% - 1; if(points[index]) { const success = restoreManager.restoreFromPoint(points[index].id); console.log(success ? '✅ Restore completed' : '❌ Restore failed'); } else { console.log('❌ Invalid selection'); }"

:end
pause