# Restore Point System Documentation

## Overview
The Restore Point System provides automatic backup and recovery capabilities for the Construction App, preventing loss of program flow when errors occur.

## Quick Start

### Create Backup
```bash
# Manual backup
npm run backup

# Auto backup critical files  
npm run backup:auto
```

### List Backups
```bash
npm run restore:list
```

### Restore from Backup
```bash
# Interactive CLI
npm run restore:cli

# Quick restore (latest)
npm run restore:quick

# Windows batch script
quick-restore.bat
```

## System Components

### 1. RestorePointManager (`lib/restorePoint.ts`)
- Core backup/restore functionality
- Manages `.restore-points/` directory
- JSON-based storage format

### 2. Error Recovery Middleware (`lib/errorRecovery.ts`)
- Automatic backup before risky operations
- Auto-rollback on errors
- Risk-level configurations:
  - `withLowRiskRecovery`: No auto-backup
  - `withMediumRiskRecovery`: Auto-backup enabled
  - `withHighRiskRecovery`: Auto-backup + auto-rollback

### 3. CLI Tools
- `restore-cli.js`: Interactive restore management
- `quick-restore.bat`: Windows quick restore script

## Protected Files
The system automatically backs up these critical files:
- `app/api/tiles/route.ts`
- `components/tiles/approval-configuration.tsx`
- `domains/approval/ApprovalService.ts`
- `data/ApprovalRepository.ts`
- `conversation.md`

## Usage Examples

### In API Routes
```typescript
import { withHighRiskRecovery } from '@/lib/errorRecovery'

export const POST = withHighRiskRecovery(async (request) => {
  // Your risky operation here
  // Auto-backup created before execution
  // Auto-rollback on error
})
```

### Manual Backup Before Changes
```typescript
import { restoreManager } from '@/lib/restorePoint'

// Before making changes
const backupId = restoreManager.autoBackup()
console.log(`Backup created: ${backupId}`)

// If something goes wrong
restoreManager.restoreFromPoint(backupId)
```

## Recovery Scenarios

### 1. Code Comments Overflow
When comments fill up and program flow is lost:
```bash
# Quick restore to last working state
npm run restore:quick
```

### 2. API Route Corruption
When route.ts gets corrupted:
```bash
# Interactive restore
npm run restore:cli
# Select appropriate restore point
```

### 3. Component Conflicts
When duplicate components cause issues:
```bash
# Windows users
quick-restore.bat
# Select restore point before component changes
```

## Best Practices

1. **Create backups before major changes**
   ```bash
   npm run backup
   ```

2. **Use appropriate risk levels**
   - GET operations: `withMediumRiskRecovery`
   - POST/PUT/DELETE: `withHighRiskRecovery`

3. **Regular cleanup**
   - Restore points are stored in `.restore-points/`
   - Manually delete old points if needed

4. **Emergency recovery**
   - Use `quick-restore.bat` for immediate recovery
   - Always creates backup before restore

## File Structure
```
Construction_App/
├── .restore-points/          # Backup storage
│   ├── rp_1234567890_abc.json
│   └── rp_1234567891_def.json
├── lib/
│   ├── restorePoint.ts       # Core system
│   └── errorRecovery.ts      # Middleware
├── restore-cli.js            # Interactive CLI
├── quick-restore.bat         # Windows script
└── restore-scripts.json     # NPM scripts
```

## Troubleshooting

### Backup Creation Fails
- Check file permissions
- Ensure `.restore-points/` directory exists
- Verify file paths are correct

### Restore Fails
- Check if restore point file exists
- Verify target files are not locked
- Run as administrator if needed

### CLI Not Working
- Ensure Node.js is installed
- Check file paths in scripts
- Verify `lib/restorePoint.ts` is compiled