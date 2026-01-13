#!/usr/bin/env node

/**
 * Architecture Compliance Checker
 * 
 * Validates that code follows 4-layer architecture standards
 * Usage: node scripts/check-architecture.js
 */

const fs = require('fs')
const path = require('path')

class ArchitectureChecker {
  constructor() {
    this.violations = []
    this.warnings = []
  }

  checkAll() {
    console.log('🔍 Checking 4-Layer Architecture Compliance...\n')
    
    this.checkLayerSeparation()
    this.checkNamingConventions()
    this.checkImportRules()
    this.checkServiceImplementations()
    
    this.reportResults()
  }

  checkLayerSeparation() {
    console.log('📋 Checking Layer Separation...')
    
    // Check for direct repository usage in components
    const componentFiles = this.getFiles('components', '.tsx')
    componentFiles.forEach(file => {
      const content = fs.readFileSync(file, 'utf8')
      if (content.includes('from \'@/lib/repositories\'') || content.includes('repositories.')) {
        this.violations.push(`❌ ${file}: Component directly accessing repositories (should use services)`)
      }
    })

    // Check for UI imports in services
    const serviceFiles = this.getFiles('domains', '.ts')
    serviceFiles.forEach(file => {
      const content = fs.readFileSync(file, 'utf8')
      if (content.includes('from \'@/components\'')) {
        this.violations.push(`❌ ${file}: Service importing UI components (layer violation)`)
      }
    })
  }

  checkNamingConventions() {
    console.log('📋 Checking Naming Conventions...')
    
    // Check service file naming
    const serviceFiles = this.getFiles('domains', '.ts')
    serviceFiles.forEach(file => {
      const fileName = path.basename(file)
      if (!fileName.endsWith('Service.ts') && !fileName.endsWith('Services.ts') && fileName !== 'index.ts') {
        this.warnings.push(`⚠️  ${file}: Service file should end with 'Service.ts'`)
      }
    })

    // Check repository file naming
    const repoFiles = this.getFiles('types/repositories', '.ts')
    repoFiles.forEach(file => {
      const fileName = path.basename(file)
      if (!fileName.endsWith('.repository.ts') && fileName !== 'index.ts' && fileName !== 'base.repository.ts') {
        this.warnings.push(`⚠️  ${file}: Repository file should end with '.repository.ts'`)
      }
    })
  }

  checkImportRules() {
    console.log('📋 Checking Import Rules...')
    
    // Check repository imports in repositories (circular dependency)
    const repoFiles = this.getFiles('types/repositories', '.ts')
    repoFiles.forEach(file => {
      if (file.includes('base.repository.ts')) return
      
      const content = fs.readFileSync(file, 'utf8')
      if (content.includes('from \'@/lib/repositories\'')) {
        this.violations.push(`❌ ${file}: Repository importing repository factory (circular dependency)`)
      }
    })
  }

  checkServiceImplementations() {
    console.log('📋 Checking Service Implementations...')
    
    const serviceFiles = this.getFiles('domains', 'Service.ts')
    serviceFiles.forEach(file => {
      const content = fs.readFileSync(file, 'utf8')
      
      // Check for mock implementations
      if (content.includes('return []') || content.includes('return {}') || content.includes('return { id: \'1\'')) {
        this.warnings.push(`⚠️  ${file}: Contains mock implementations (needs real logic)`)
      }
      
      // Check for proper error handling
      if (!content.includes('try') && !content.includes('catch')) {
        this.warnings.push(`⚠️  ${file}: Missing error handling`)
      }
    })
  }

  getFiles(dir, extension) {
    const files = []
    
    function traverse(currentDir) {
      if (!fs.existsSync(currentDir)) return
      
      const items = fs.readdirSync(currentDir)
      items.forEach(item => {
        const fullPath = path.join(currentDir, item)
        const stat = fs.statSync(fullPath)
        
        if (stat.isDirectory()) {
          traverse(fullPath)
        } else if (fullPath.endsWith(extension)) {
          files.push(fullPath)
        }
      })
    }
    
    traverse(dir)
    return files
  }

  reportResults() {
    console.log('\n📊 Architecture Compliance Report')
    console.log('================================')
    
    if (this.violations.length === 0 && this.warnings.length === 0) {
      console.log('✅ All checks passed! Architecture is compliant.')
      return
    }
    
    if (this.violations.length > 0) {
      console.log(`\n❌ VIOLATIONS (${this.violations.length}):`)
      this.violations.forEach(violation => console.log(violation))
    }
    
    if (this.warnings.length > 0) {
      console.log(`\n⚠️  WARNINGS (${this.warnings.length}):`)
      this.warnings.forEach(warning => console.log(warning))
    }
    
    console.log(`\n📈 Summary: ${this.violations.length} violations, ${this.warnings.length} warnings`)
    
    if (this.violations.length > 0) {
      console.log('\n🚫 Architecture compliance FAILED. Fix violations before proceeding.')
      process.exit(1)
    } else {
      console.log('\n✅ Architecture compliance PASSED with warnings.')
    }
  }
}

const checker = new ArchitectureChecker()
checker.checkAll()