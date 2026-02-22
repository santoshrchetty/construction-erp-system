// =====================================================
// DOCUMENT GOVERNANCE API TEST SCRIPT
// =====================================================
// Run with: node database/test_api.js

const BASE_URL = 'http://localhost:3000';

async function testAPI() {
  console.log('🧪 Testing Document Governance API...\n');

  const tests = [
    { name: 'Drawings', endpoint: '/api/document-governance?resource=drawings' },
    { name: 'Contracts', endpoint: '/api/document-governance?resource=contracts' },
    { name: 'RFIs', endpoint: '/api/document-governance?resource=rfis' },
    { name: 'Specifications', endpoint: '/api/document-governance?resource=specifications' },
    { name: 'Submittals', endpoint: '/api/document-governance?resource=submittals' },
    { name: 'Change Orders', endpoint: '/api/document-governance?resource=change-orders' },
    { name: 'Master Data', endpoint: '/api/document-governance?resource=master-data' }
  ];

  for (const test of tests) {
    try {
      console.log(`Testing ${test.name}...`);
      const response = await fetch(`${BASE_URL}${test.endpoint}`);
      
      if (!response.ok) {
        console.log(`❌ ${test.name}: HTTP ${response.status}`);
        continue;
      }

      const data = await response.json();
      console.log(`✅ ${test.name}: ${data.length} records`);
      
      if (data.length > 0) {
        console.log(`   Sample: ${JSON.stringify(data[0]).substring(0, 100)}...`);
      }
    } catch (error) {
      console.log(`❌ ${test.name}: ${error.message}`);
    }
    console.log('');
  }

  console.log('✨ API testing complete!');
}

testAPI();
