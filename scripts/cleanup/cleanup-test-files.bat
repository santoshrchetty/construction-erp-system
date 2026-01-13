@echo off
echo Cleaning up test and debug files...

REM Move test files to archive
move "test-copy-chart.js" "docs\archive\"
move "test-copy-direct.js" "docs\archive\"
move "test-copy.html" "docs\archive\"
move "FIX_COMPANY_DROPDOWN_API.js" "docs\archive\"
move "restore-cli.js" "docs\archive\"

REM Remove test results directory (can be regenerated)
rmdir /s /q "test-results"

echo Cleanup complete!