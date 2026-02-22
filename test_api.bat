@echo off
REM External Access API Test Script for Windows
REM Run with: test_api.bat

setlocal enabledelayedexpansion
set BASE_URL=http://localhost:3000/api/external-access
set PASSED=0
set FAILED=0

echo ========================================
echo    External Access API Tests
echo ========================================
echo.

REM TEST 1: List Organizations
echo [TEST 1] List Organizations
curl -s -X GET "%BASE_URL%?action=list-organizations" > temp.json
findstr /C:"success" temp.json >nul
if !errorlevel! equ 0 (
    echo [PASS] List Organizations
    set /a PASSED+=1
) else (
    echo [FAIL] List Organizations
    type temp.json
    set /a FAILED+=1
)
echo.

REM TEST 2: List Drawings
echo [TEST 2] List Drawings
curl -s -X GET "%BASE_URL%?action=list-drawings" > temp.json
findstr /C:"success" temp.json >nul
if !errorlevel! equ 0 (
    echo [PASS] List Drawings
    set /a PASSED+=1
) else (
    echo [FAIL] List Drawings
    type temp.json
    set /a FAILED+=1
)
echo.

REM TEST 3: List Facilities
echo [TEST 3] List Facilities
curl -s -X GET "%BASE_URL%?action=list-facilities" > temp.json
findstr /C:"success" temp.json >nul
if !errorlevel! equ 0 (
    echo [PASS] List Facilities
    set /a PASSED+=1
) else (
    echo [FAIL] List Facilities
    type temp.json
    set /a FAILED+=1
)
echo.

REM TEST 4: List Equipment
echo [TEST 4] List Equipment
curl -s -X GET "%BASE_URL%?action=list-equipment" > temp.json
findstr /C:"success" temp.json >nul
if !errorlevel! equ 0 (
    echo [PASS] List Equipment
    set /a PASSED+=1
) else (
    echo [FAIL] List Equipment
    type temp.json
    set /a FAILED+=1
)
echo.

REM TEST 5: List Resource Access
echo [TEST 5] List Resource Access
curl -s -X GET "%BASE_URL%?action=list-resource-access" > temp.json
findstr /C:"success" temp.json >nul
if !errorlevel! equ 0 (
    echo [PASS] List Resource Access
    set /a PASSED+=1
) else (
    echo [FAIL] List Resource Access
    type temp.json
    set /a FAILED+=1
)
echo.

REM Cleanup
del temp.json 2>nul

REM Summary
echo ========================================
echo           TEST SUMMARY
echo ========================================
echo Passed: !PASSED!
echo Failed: !FAILED!
set /a TOTAL=!PASSED!+!FAILED!
echo Total:  !TOTAL!
echo ========================================

if !FAILED! equ 0 (
    echo All tests passed!
    exit /b 0
) else (
    echo Some tests failed
    exit /b 1
)
