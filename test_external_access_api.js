/**
 * External Access API Test Suite
 * Run with: node test_external_access_api.js
 */

const BASE_URL = 'http://localhost:3000/api/external-access';

// Test data - replace with actual IDs from your database
let testData = {
  tenant_id: null,
  user_id: null,
  external_org_id: null,
  drawing_id: null,
  facility_id: null,
  equipment_id: null,
  access_id: null
};

// Helper function to make API calls
async function apiCall(action, method = 'GET', body = null) {
  const url = method === 'GET' || method === 'DELETE' 
    ? `${BASE_URL}?action=${action}${body ? '&' + new URLSearchParams(body).toString() : ''}`
    : `${BASE_URL}?action=${action}`;
  
  const options = {
    method,
    headers: { 'Content-Type': 'application/json' }
  };
  
  if (body && (method === 'POST' || method === 'PUT')) {
    options.body = JSON.stringify(body);
  }
  
  try {
    const response = await fetch(url, options);
    const result = await response.json();
    return result;
  } catch (error) {
    return { success: false, error: error.message };
  }
}

// Test runner
async function runTests() {
  console.log('🚀 Starting External Access API Tests\n');
  
  let passed = 0;
  let failed = 0;
  
  // ==================== TEST 1: List Organizations ====================
  console.log('📋 TEST 1: List Organizations');
  try {
    const result = await apiCall('list-organizations', 'GET', { 
      tenant_id: testData.tenant_id 
    });
    
    if (result.success && Array.isArray(result.data)) {
      console.log('✅ PASS - Found', result.data.length, 'organizations');
      if (result.data.length > 0) {
        testData.external_org_id = result.data[0].external_org_id;
        console.log('   Using org:', result.data[0].name);
      }
      passed++;
    } else {
      console.log('❌ FAIL -', result.error);
      failed++;
    }
  } catch (error) {
    console.log('❌ FAIL -', error.message);
    failed++;
  }
  console.log();
  
  // ==================== TEST 2: Get Organization ====================
  if (testData.external_org_id) {
    console.log('📋 TEST 2: Get Organization');
    try {
      const result = await apiCall('get-organization', 'GET', { 
        external_org_id: testData.external_org_id 
      });
      
      if (result.success && result.data) {
        console.log('✅ PASS - Got organization:', result.data.name);
        passed++;
      } else {
        console.log('❌ FAIL -', result.error);
        failed++;
      }
    } catch (error) {
      console.log('❌ FAIL -', error.message);
      failed++;
    }
    console.log();
  }
  
  // ==================== TEST 3: Create Organization ====================
  console.log('📋 TEST 3: Create Organization');
  try {
    const result = await apiCall('create-organization', 'POST', {
      tenant_id: testData.tenant_id,
      name: 'Test Contractor Inc',
      org_type: 'CONTRACTOR',
      is_internal: false,
      contact_email: 'test@contractor.com'
    });
    
    if (result.success && result.data) {
      console.log('✅ PASS - Created organization:', result.data.external_org_id);
      passed++;
    } else {
      console.log('❌ FAIL -', result.error);
      failed++;
    }
  } catch (error) {
    console.log('❌ FAIL -', error.message);
    failed++;
  }
  console.log();
  
  // ==================== TEST 4: List Resource Access ====================
  console.log('📋 TEST 4: List Resource Access');
  try {
    const result = await apiCall('list-resource-access', 'GET', {
      external_org_id: testData.external_org_id
    });
    
    if (result.success && Array.isArray(result.data)) {
      console.log('✅ PASS - Found', result.data.length, 'access grants');
      if (result.data.length > 0) {
        testData.access_id = result.data[0].access_id;
        testData.drawing_id = result.data[0].resource_id;
      }
      passed++;
    } else {
      console.log('❌ FAIL -', result.error);
      failed++;
    }
  } catch (error) {
    console.log('❌ FAIL -', error.message);
    failed++;
  }
  console.log();
  
  // ==================== TEST 5: Grant Access ====================
  if (testData.drawing_id) {
    console.log('📋 TEST 5: Grant Access');
    try {
      const result = await apiCall('grant-access', 'POST', {
        tenant_id: testData.tenant_id,
        external_org_id: testData.external_org_id,
        resource_type: 'DRAWING',
        resource_id: testData.drawing_id,
        access_level: 'VIEW',
        granted_by: testData.user_id
      });
      
      if (result.success && result.data) {
        console.log('✅ PASS - Granted access:', result.data.access_id);
        passed++;
      } else {
        console.log('❌ FAIL -', result.error);
        failed++;
      }
    } catch (error) {
      console.log('❌ FAIL -', error.message);
      failed++;
    }
    console.log();
  }
  
  // ==================== TEST 6: List Drawings ====================
  console.log('📋 TEST 6: List Drawings');
  try {
    const result = await apiCall('list-drawings', 'GET', {});
    
    if (result.success && Array.isArray(result.data)) {
      console.log('✅ PASS - Found', result.data.length, 'drawings');
      if (result.data.length > 0 && !testData.drawing_id) {
        testData.drawing_id = result.data[0].id;
      }
      passed++;
    } else {
      console.log('❌ FAIL -', result.error);
      failed++;
    }
  } catch (error) {
    console.log('❌ FAIL -', error.message);
    failed++;
  }
  console.log();
  
  // ==================== TEST 7: Get Drawing ====================
  if (testData.drawing_id) {
    console.log('📋 TEST 7: Get Drawing');
    try {
      const result = await apiCall('get-drawing', 'GET', { 
        id: testData.drawing_id 
      });
      
      if (result.success && result.data) {
        console.log('✅ PASS - Got drawing:', result.data.drawing_number);
        passed++;
      } else {
        console.log('❌ FAIL -', result.error);
        failed++;
      }
    } catch (error) {
      console.log('❌ FAIL -', error.message);
      failed++;
    }
    console.log();
  }
  
  // ==================== TEST 8: List Facilities ====================
  console.log('📋 TEST 8: List Facilities');
  try {
    const result = await apiCall('list-facilities', 'GET', {});
    
    if (result.success && Array.isArray(result.data)) {
      console.log('✅ PASS - Found', result.data.length, 'facilities');
      if (result.data.length > 0) {
        testData.facility_id = result.data[0].facility_id;
      }
      passed++;
    } else {
      console.log('❌ FAIL -', result.error);
      failed++;
    }
  } catch (error) {
    console.log('❌ FAIL -', error.message);
    failed++;
  }
  console.log();
  
  // ==================== TEST 9: List Equipment ====================
  console.log('📋 TEST 9: List Equipment');
  try {
    const result = await apiCall('list-equipment', 'GET', {});
    
    if (result.success && Array.isArray(result.data)) {
      console.log('✅ PASS - Found', result.data.length, 'equipment');
      if (result.data.length > 0) {
        testData.equipment_id = result.data[0].equipment_id;
      }
      passed++;
    } else {
      console.log('❌ FAIL -', result.error);
      failed++;
    }
  } catch (error) {
    console.log('❌ FAIL -', error.message);
    failed++;
  }
  console.log();
  
  // ==================== TEST 10: Submit Approval ====================
  if (testData.drawing_id && testData.external_org_id) {
    console.log('📋 TEST 10: Submit Approval');
    try {
      const result = await apiCall('submit-approval', 'POST', {
        tenant_id: testData.tenant_id,
        drawing_id: testData.drawing_id,
        external_org_id: testData.external_org_id,
        approval_status: 'APPROVED',
        approved_by: testData.user_id,
        comments: 'Test approval'
      });
      
      if (result.success && result.data) {
        console.log('✅ PASS - Submitted approval:', result.data.approval_id);
        passed++;
      } else {
        console.log('❌ FAIL -', result.error);
        failed++;
      }
    } catch (error) {
      console.log('❌ FAIL -', error.message);
      failed++;
    }
    console.log();
  }
  
  // ==================== TEST 11: List Approvals ====================
  console.log('📋 TEST 11: List Approvals');
  try {
    const result = await apiCall('list-approvals', 'GET', {
      external_org_id: testData.external_org_id
    });
    
    if (result.success && Array.isArray(result.data)) {
      console.log('✅ PASS - Found', result.data.length, 'approvals');
      passed++;
    } else {
      console.log('❌ FAIL -', result.error);
      failed++;
    }
  } catch (error) {
    console.log('❌ FAIL -', error.message);
    failed++;
  }
  console.log();
  
  // ==================== TEST 12: Submit Progress ====================
  if (testData.drawing_id && testData.external_org_id) {
    console.log('📋 TEST 12: Submit Progress');
    try {
      const result = await apiCall('submit-progress', 'POST', {
        tenant_id: testData.tenant_id,
        drawing_id: testData.drawing_id,
        external_org_id: testData.external_org_id,
        progress_percentage: 50,
        status: 'IN_PROGRESS',
        notes: 'Test progress update',
        submitted_by: testData.user_id
      });
      
      if (result.success && result.data) {
        console.log('✅ PASS - Submitted progress:', result.data.update_id);
        passed++;
      } else {
        console.log('❌ FAIL -', result.error);
        failed++;
      }
    } catch (error) {
      console.log('❌ FAIL -', error.message);
      failed++;
    }
    console.log();
  }
  
  // ==================== TEST 13: Create Ticket ====================
  if (testData.facility_id) {
    console.log('📋 TEST 13: Create Field Service Ticket');
    try {
      const result = await apiCall('create-ticket', 'POST', {
        tenant_id: testData.tenant_id,
        facility_id: testData.facility_id,
        title: 'Test Ticket',
        description: 'Test ticket description',
        priority: 'MEDIUM',
        status: 'OPEN',
        reported_by: testData.user_id
      });
      
      if (result.success && result.data) {
        console.log('✅ PASS - Created ticket:', result.data.ticket_id);
        passed++;
      } else {
        console.log('❌ FAIL -', result.error);
        failed++;
      }
    } catch (error) {
      console.log('❌ FAIL -', error.message);
      failed++;
    }
    console.log();
  }
  
  // ==================== TEST 14: List Tickets ====================
  console.log('📋 TEST 14: List Field Service Tickets');
  try {
    const result = await apiCall('list-tickets', 'GET', {});
    
    if (result.success && Array.isArray(result.data)) {
      console.log('✅ PASS - Found', result.data.length, 'tickets');
      passed++;
    } else {
      console.log('❌ FAIL -', result.error);
      failed++;
    }
  } catch (error) {
    console.log('❌ FAIL -', error.message);
    failed++;
  }
  console.log();
  
  // ==================== SUMMARY ====================
  console.log('═══════════════════════════════════════');
  console.log('📊 TEST SUMMARY');
  console.log('═══════════════════════════════════════');
  console.log(`✅ Passed: ${passed}`);
  console.log(`❌ Failed: ${failed}`);
  console.log(`📈 Total:  ${passed + failed}`);
  console.log(`🎯 Success Rate: ${((passed / (passed + failed)) * 100).toFixed(1)}%`);
  console.log('═══════════════════════════════════════\n');
  
  if (failed === 0) {
    console.log('🎉 All tests passed!');
  } else {
    console.log('⚠️  Some tests failed. Check the output above.');
  }
}

// Run tests
console.log('⚙️  Make sure your Next.js dev server is running on http://localhost:3000\n');
runTests().catch(console.error);
