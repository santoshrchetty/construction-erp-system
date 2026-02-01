const fs = require('fs');
const path = require('path');

const apiDir = path.join(__dirname, 'app', 'api');

function fixCookies(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  
  // Pattern 1: get(name) => cookieStore.get(name)?.value
  content = content.replace(
    /get\(name: string\) \{\s*return cookieStore\.get\(name\)\?\.value/g,
    'getAll: () => cookieStore.getAll(),\n          setAll: (cookiesToSet) => {\n            cookiesToSet.forEach(({ name, value, options }) => cookieStore.set(name, value, options))\n          }'
  );
  
  // Pattern 2: get: (name) => cookieStore.get(name)?.value
  content = content.replace(
    /get: \(name\) => cookieStore\.get\(name\)\?\.value,\s*set: \(name, value, options\) => cookieStore\.set\(name, value, options\),\s*remove: \(name, options\) => cookieStore\.delete\(name\),/g,
    'getAll: () => cookieStore.getAll(),\n          setAll: (cookiesToSet) => {\n            cookiesToSet.forEach(({ name, value, options }) => cookieStore.set(name, value, options))\n          },'
  );
  
  fs.writeFileSync(filePath, content, 'utf8');
}

function walkDir(dir) {
  const files = fs.readdirSync(dir);
  files.forEach(file => {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);
    if (stat.isDirectory()) {
      walkDir(filePath);
    } else if (file === 'route.ts') {
      console.log('Fixing:', filePath);
      fixCookies(filePath);
    }
  });
}

walkDir(apiDir);
console.log('Done!');
