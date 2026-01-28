const fs = require('fs');
const path = require('path');

/**
 * VARCHAR Codes Compliance Checker
 * Ensures all database types use VARCHAR codes, not UUID foreign keys
 */

const FORBIDDEN_PATTERNS = [
  /_id:/,           // company_code_id, plant_code_id, etc.
  /Id:/,            // companyId, plantId, etc.
  /ID:/             // companyID, plantID, etc.
];

const REQUIRED_PATTERNS = [
  /company_code:/,
  /plant_code:/,
  /project_code:/,
  /cost_center:/
];

function checkVarcharCompliance() {
  const typesPath = path.join(__dirname, '../types/database.ts');
  
  if (!fs.existsSync(typesPath)) {
    console.error('❌ Database types file not found');
    process.exit(1);
  }
  
  const content = fs.readFileSync(typesPath, 'utf8');
  const lines = content.split('\n');
  
  let violations = [];
  let missing = [];
  
  // Check for forbidden UUID foreign key patterns
  lines.forEach((line, index) => {
    FORBIDDEN_PATTERNS.forEach(pattern => {
      if (pattern.test(line)) {
        violations.push({
          line: index + 1,
          content: line.trim(),
          issue: 'UUID foreign key detected (FORBIDDEN)'
        });
      }
    });
  });
  
  // Check for required VARCHAR code patterns
  REQUIRED_PATTERNS.forEach(pattern => {
    if (!pattern.test(content)) {
      missing.push({
        pattern: pattern.source,
        issue: 'Required VARCHAR code field missing'
      });
    }
  });
  
  // Report results
  if (violations.length === 0 && missing.length === 0) {
    console.log('✅ VARCHAR codes compliance check PASSED');
    console.log('✅ All business entities use VARCHAR codes');
    console.log('✅ No UUID foreign keys detected');
    return true;
  }
  
  console.log('❌ VARCHAR codes compliance check FAILED');
  
  if (violations.length > 0) {
    console.log('\n🚫 FORBIDDEN UUID foreign keys detected:');
    violations.forEach(v => {
      console.log(`   Line ${v.line}: ${v.content}`);
      console.log(`   Issue: ${v.issue}`);
    });
  }
  
  if (missing.length > 0) {
    console.log('\n⚠️  Required VARCHAR code fields missing:');
    missing.forEach(m => {
      console.log(`   Pattern: ${m.pattern}`);
      console.log(`   Issue: ${m.issue}`);
    });
  }
  
  console.log('\n📋 Required Actions:');
  console.log('1. Update database schema to use VARCHAR codes only');
  console.log('2. Run: npm run generate-types');
  console.log('3. Verify all _id fields are removed');
  console.log('4. Ensure all business codes use VARCHAR fields');
  
  process.exit(1);
}

if (require.main === module) {
  checkVarcharCompliance();
}

module.exports = { checkVarcharCompliance };