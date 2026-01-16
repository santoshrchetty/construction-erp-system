// Restore Point System for Construction App
import { readdirSync, writeFileSync, readFileSync, existsSync, mkdirSync } from 'fs'
import { join } from 'path'

interface RestorePoint {
  id: string
  timestamp: string
  description: string
  files: { [path: string]: string }
  metadata: {
    version: string
    branch?: string
    lastWorkingState: boolean
  }
}

export class RestorePointManager {
  private restoreDir = join(process.cwd(), '.restore-points')
  
  constructor() {
    if (!existsSync(this.restoreDir)) {
      mkdirSync(this.restoreDir, { recursive: true })
    }
  }

  // Create restore point
  createRestorePoint(description: string, filePaths: string[]): string {
    const id = `rp_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
    const files: { [path: string]: string } = {}
    
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

    const restorePoint: RestorePoint = {
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
  listRestorePoints(): RestorePoint[] {
    try {
      const files = readdirSync(this.restoreDir)
      return files
        .filter((f: string) => f.endsWith('.json'))
        .map((f: string) => {
          const content = readFileSync(join(this.restoreDir, f), 'utf8')
          return JSON.parse(content)
        })
        .sort((a: RestorePoint, b: RestorePoint) => 
          new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime()
        )
    } catch {
      return []
    }
  }

  // Restore from point
  restoreFromPoint(restorePointId: string): boolean {
    try {
      const restoreFile = join(this.restoreDir, `${restorePointId}.json`)
      if (!existsSync(restoreFile)) {
        console.error(`❌ Restore point not found: ${restorePointId}`)
        return false
      }

      const restorePoint: RestorePoint = JSON.parse(readFileSync(restoreFile, 'utf8'))
      
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
  autoBackup(): string {
    const criticalFiles = [
      'app/api/tiles/route.ts',
      'components/tiles/approval-configuration.tsx',
      'domains/approval/ApprovalService.ts',
      'data/ApprovalRepository.ts',
      'conversation.md'
    ].map(f => join(process.cwd(), f))

    return this.createRestorePoint('Auto-backup before changes', criticalFiles)
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

export { RestorePointManager, restoreManager, createBackup, listBackups, restoreBackup }