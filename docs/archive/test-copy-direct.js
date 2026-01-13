// Direct API test for copy function
// Open browser console and paste this code

fetch('/api/tiles', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    category: 'finance',
    action: 'copy_chart',
    source_company: 'C001',
    target_company: 'B001'
  })
})
.then(response => {
  console.log('Response status:', response.status);
  return response.json();
})
.then(data => {
  console.log('Full API Response:', JSON.stringify(data, null, 2));
  if (data.success) {
    console.log('✅ Copy successful:', data.data);
  } else {
    console.log('❌ Copy failed:', data.error || data.details);
  }
})
.catch(error => {
  console.error('❌ Request failed:', error);
});