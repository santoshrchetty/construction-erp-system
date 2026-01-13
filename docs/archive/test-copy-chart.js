// Test Chart of Accounts Copy Function
// Source: C001 -> Destination: B001

const testCopyChart = async () => {
  try {
    console.log('Testing Chart of Accounts copy from C001 to B001...');
    
    const response = await fetch('/api/tiles', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        action: 'copyChartOfAccounts',
        sourceCompany: 'C001',
        destinationCompany: 'B001'
      })
    });

    const result = await response.json();
    
    console.log('Response Status:', response.status);
    console.log('Response Data:', result);
    
    if (result.success) {
      console.log('✅ Copy operation successful');
      console.log('Records copied:', result.recordsCopied || 'Unknown');
    } else {
      console.log('❌ Copy operation failed');
      console.log('Error:', result.error || result.message);
    }
    
  } catch (error) {
    console.error('❌ Test failed with error:', error);
  }
};

// Run the test
testCopyChart();