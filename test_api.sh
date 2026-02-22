#!/bin/bash
# External Access API Test Script
# Run with: bash test_api.sh

BASE_URL="http://localhost:3000/api/external-access"

echo "🚀 External Access API Tests"
echo "=============================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
PASSED=0
FAILED=0

# Helper function to test API
test_api() {
  local test_name=$1
  local method=$2
  local action=$3
  local data=$4
  
  echo -e "${BLUE}TEST: ${test_name}${NC}"
  
  if [ "$method" = "GET" ] || [ "$method" = "DELETE" ]; then
    response=$(curl -s -X $method "${BASE_URL}?action=${action}${data}")
  else
    response=$(curl -s -X $method "${BASE_URL}?action=${action}" \
      -H "Content-Type: application/json" \
      -d "$data")
  fi
  
  if echo "$response" | grep -q '"success":true'; then
    echo -e "${GREEN}✅ PASS${NC}"
    PASSED=$((PASSED + 1))
  else
    echo -e "${RED}❌ FAIL${NC}"
    echo "Response: $response"
    FAILED=$((FAILED + 1))
  fi
  echo ""
}

# ==================== TESTS ====================

# TEST 1: List Organizations
test_api "List Organizations" "GET" "list-organizations" "&tenant_id=00000000-0000-0000-0000-000000000000"

# TEST 2: Create Organization
test_api "Create Organization" "POST" "create-organization" '{
  "tenant_id": "00000000-0000-0000-0000-000000000000",
  "name": "Test Contractor",
  "org_type": "CONTRACTOR",
  "is_internal": false,
  "contact_email": "test@contractor.com"
}'

# TEST 3: List Resource Access
test_api "List Resource Access" "GET" "list-resource-access" ""

# TEST 4: List Drawings
test_api "List Drawings" "GET" "list-drawings" ""

# TEST 5: List Facilities
test_api "List Facilities" "GET" "list-facilities" ""

# TEST 6: List Equipment
test_api "List Equipment" "GET" "list-equipment" ""

# TEST 7: List Approvals
test_api "List Approvals" "GET" "list-approvals" ""

# TEST 8: List Progress Updates
test_api "List Progress Updates" "GET" "list-progress" ""

# TEST 9: List Tickets
test_api "List Tickets" "GET" "list-tickets" ""

# TEST 10: List Organization Users
test_api "List Organization Users" "GET" "list-org-users" "&external_org_id=00000000-0000-0000-0000-000000000000"

# ==================== SUMMARY ====================
echo "=============================="
echo "📊 TEST SUMMARY"
echo "=============================="
echo -e "✅ Passed: ${GREEN}${PASSED}${NC}"
echo -e "❌ Failed: ${RED}${FAILED}${NC}"
echo "📈 Total:  $((PASSED + FAILED))"

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}🎉 All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}⚠️  Some tests failed${NC}"
  exit 1
fi
