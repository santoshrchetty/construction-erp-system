// Restore Point System for Construction App
const { writeFileSync, readFileSync, existsSync, mkdirSync } = require('fs')
const { join } = require('path')

class RestorePointManager {
  constructor() {
    this.restoreDir = join(process.cwd(), '.restore-points')
    if (!existsSync(this.restoreDir)) {
      mkdirSync(this.restoreDir, { recursive: true })
    }
  }

  // Create restore point
  createRestorePoint(description, filePaths) {
    const id = `rp_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
    const files = {}
    
    // Capture current state of files
    filePaths.forEach(path => {
      try {
        if (existsSync(path)) {
          files[path] = readFileSync(path, 'utf8')
        }
      } catch (error) {
        console.warn(`Could not backup file: ${path}`)
      }
    })

    const restorePoint = {
      id,
      timestamp: new Date().toISOString(),
      description,
      files,
      metadata: {
        version: '1.0.0',
        lastWorkingState: true
      }
    }

    writeFileSync(
      join(this.restoreDir, `${id}.json`),
      JSON.stringify(restorePoint, null, 2)
    )

    console.log(`✅ Restore point created: ${id} - ${description}`)
    return id
  }

  // List all restore points
  listRestorePoints() {
    try {
      const fs = require('fs')
      const files = fs.readdirSync(this.restoreDir)
      return files
        .filter(f => f.endsWith('.json'))
        .map(f => {
          const content = readFileSync(join(this.restoreDir, f), 'utf8')
          return JSON.parse(content)
        })
        .sort((a, b) => 
          new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime()
        )
    } catch {
      return []
    }
  }

  // Restore from point
  restoreFromPoint(restorePointId) {
    try {
      const restoreFile = join(this.restoreDir, `${restorePointId}.json`)
      if (!existsSync(restoreFile)) {
        console.error(`❌ Restore point not found: ${restorePointId}`)
        return false
      }

      const restorePoint = JSON.parse(readFileSync(restoreFile, 'utf8'))
      
      // Restore files
      Object.entries(restorePoint.files).forEach(([path, content]) => {
        try {
          writeFileSync(path, content)
          console.log(`✅ Restored: ${path}`)
        } catch (error) {
          console.error(`❌ Failed to restore: ${path}`, error)
        }
      })

      console.log(`🔄 Restored from: ${restorePoint.description}`)
      return true
    } catch (error) {
      console.error('❌ Restore failed:', error)
      return false
    }
  }

  // Auto-create restore points for critical files
  autoBackup() {
    const criticalFiles = [
      'app/api/tiles/route.ts',
      'components/tiles/approval-configuration.tsx',
      'domains/approval/ApprovalService.ts',
      'data/ApprovalRepository.ts',
      'conversation.md'
    ].map(f => join(process.cwd(), f))

    return this.createRestorePoint('Auto-backup - 4-layer architecture compliance', criticalFiles)
  }
}

// Global instance
const restoreManager = new RestorePointManager()

// CLI Helper functions
const createBackup = (description) => {
  return restoreManager.autoBackup()
}

const listBackups = () => {
  const points = restoreManager.listRestorePoints()
  console.log('\n📋 Available Restore Points:')
  points.forEach(p => {
    console.log(`${p.id} - ${p.description} (${new Date(p.timestamp).toLocaleString()})`)
  })
  return points
}

const restoreBackup = (id) => {
  return restoreManager.restoreFromPoint(id)
}

module.exports = { RestorePointManager, restoreManager, createBackup, listBackups, restoreBackup }