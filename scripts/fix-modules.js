const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: '.env.local' });

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
);

async function diagnoseAndFix() {
  console.log('🔍 Checking module status...\n');
  
  // Check current status
  const { data: objects, error } = await supabase
    .from('authorization_objects')
    .select('id, object_name, module');
  
  if (error) {
    console.error('❌ Error:', error);
    return;
  }
  
  const nullEmpty = objects.filter(o => !o.module || o.module.trim() === '');
  console.log(`Total objects: ${objects.length}`);
  console.log(`NULL/Empty modules: ${nullEmpty.length}\n`);
  
  if (nullEmpty.length === 0) {
    console.log('✅ All objects have modules assigned!');
    
    // Show distribution
    const distribution = {};
    objects.forEach(o => {
      distribution[o.module] = (distribution[o.module] || 0) + 1;
    });
    console.log('\n📊 Module distribution:');
    Object.entries(distribution).sort((a, b) => b[1] - a[1]).forEach(([mod, count]) => {
      console.log(`  ${mod}: ${count}`);
    });
    return;
  }
  
  console.log('🔧 Fixing NULL/empty modules...\n');
  
  // Fix based on patterns
  const updates = [];
  nullEmpty.forEach(obj => {
    let module = 'admin'; // default
    
    if (obj.object_name.startsWith('MAT_')) module = 'materials';
    else if (obj.object_name.startsWith('PO_') || obj.object_name.startsWith('PR_') || obj.object_name.startsWith('MR_')) module = 'procurement';
    else if (obj.object_name.startsWith('PROJ_')) module = 'projects';
    else if (obj.object_name.startsWith('FI_')) module = 'finance';
    else if (obj.object_name.startsWith('HR_')) module = 'hr';
    else if (obj.object_name.startsWith('INV_')) module = 'inventory';
    else if (obj.object_name.startsWith('WH_')) module = 'warehouse';
    else if (obj.object_name.startsWith('QM_')) module = 'quality';
    else if (obj.object_name.startsWith('PM_')) module = 'maintenance';
    
    updates.push({ id: obj.id, module });
  });
  
  // Apply updates
  for (const update of updates) {
    const { error: updateError } = await supabase
      .from('authorization_objects')
      .update({ module: update.module })
      .eq('id', update.id);
    
    if (updateError) {
      console.error(`❌ Failed to update ${update.id}:`, updateError);
    }
  }
  
  console.log(`✅ Updated ${updates.length} objects\n`);
  
  // Verify
  const { data: updated } = await supabase
    .from('authorization_objects')
    .select('module');
  
  const distribution = {};
  updated.forEach(o => {
    distribution[o.module] = (distribution[o.module] || 0) + 1;
  });
  
  console.log('📊 Final module distribution:');
  Object.entries(distribution).sort((a, b) => b[1] - a[1]).forEach(([mod, count]) => {
    console.log(`  ${mod}: ${count}`);
  });
}

diagnoseAndFix().catch(console.error);
