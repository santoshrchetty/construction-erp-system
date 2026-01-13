# Project Numbering System - Reference Document

## Overview
Production-grade reservation-based project numbering system that ensures preview codes match saved codes, prevents race conditions, and handles similar patterns correctly.

## Architecture

### Tables
1. **`project_numbering_rules`** - Pattern definitions and counters
2. **`project_number_reservations`** - Temporary number reservations (30-minute expiry)

### Functions
1. **`reserve_project_number_with_pattern()`** - Reserves number during preview
2. **`consume_reserved_project_number()`** - Consumes reservation during save
3. **`release_project_number_reservation()`** - Releases unused reservations

## Key Features

### 1. Reservation-Based Preview
- **Preview**: Reserves actual number (e.g., HW-0001)
- **Save**: Uses exact same reserved number
- **Guarantee**: Preview code = Saved code

### 2. Race Condition Prevention
- Multiple users see different numbers
- Atomic reservation prevents conflicts
- 30-minute reservation timeout

### 3. Pattern Precision
- Exact pattern matching prevents cross-contamination
- `HW-{####}` vs `HW-COMM-{####}` maintain separate sequences
- Regex anchoring: `^pattern$` for precise matching

### 4. Self-Healing Logic
- Validates against existing projects
- Uses highest of: existing max, reserved max, counter
- Automatically syncs mismatched counters

## Pattern Examples

| Pattern | Generated Code | Regex Match |
|---------|---------------|-------------|
| `HW-{####}` | HW-0001 | `^HW-(\d{4})$` |
| `HW-COMM-{####}` | HW-COMM-0001 | `^HW-COMM-(\d{4})$` |
| `{COMPANY}-{YYYY}-{###}` | C001-2025-001 | `^C001-2025-(\d{3})$` |
| `INFRA-{YY}-{##}` | INFRA-25-01 | `^INFRA-25-(\d{2})$` |

## Implementation Flow

### Preview Phase
```sql
SELECT reserve_project_number_with_pattern(
    'PROJECT', 
    'C001', 
    'HW-{####}', 
    'session_12345'
);
-- Returns: HW-0001 (reserved for 30 minutes)
```

### Save Phase
```sql
SELECT consume_reserved_project_number(
    'session_12345',
    'HW-0001'
);
-- Returns: true (reservation consumed)
-- Project saved with code: HW-0001
```

### Cancel Phase
```sql
SELECT release_project_number_reservation('session_12345');
-- Releases HW-0001 for other users
```

## Database Schema

### project_number_reservations
```sql
CREATE TABLE project_number_reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL,
    company_code VARCHAR(10) NOT NULL,
    pattern VARCHAR(200) NOT NULL,
    reserved_number INTEGER NOT NULL,
    reserved_code VARCHAR(200) NOT NULL,
    session_id VARCHAR(100) NOT NULL,
    reserved_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '30 minutes'),
    is_consumed BOOLEAN DEFAULT false
);
```

## Service Integration

### ProjectCreationService Updates
```typescript
class ProjectCreationService {
  private reservedSessionId?: string
  private reservedCode?: string

  // Preview - reserves number
  async generateProjectNumberWithPattern(request) {
    const sessionId = `session_${Date.now()}_${Math.random()}`
    const data = await this.supabase.rpc('reserve_project_number_with_pattern', {
      p_entity_type: request.entity_type,
      p_company_code: request.company_code,
      p_pattern: request.pattern,
      p_session_id: sessionId
    })
    
    this.reservedSessionId = sessionId
    this.reservedCode = data
    return data
  }

  // Save - consumes reserved number
  async createProject(request) {
    // Use this.reservedCode as project code
    // Call consume_reserved_project_number()
  }
}
```

## Benefits

1. **Guaranteed Consistency**: Preview = Saved code
2. **Multi-user Safe**: No duplicate numbers
3. **Pattern Isolation**: Similar patterns don't interfere
4. **Self-healing**: Automatically fixes counter mismatches
5. **Timeout Protection**: Abandoned reservations auto-expire
6. **Production Ready**: Handles edge cases and race conditions

## Maintenance

### Cleanup Expired Reservations
```sql
-- Automatic cleanup runs on each reservation call
DELETE FROM project_number_reservations WHERE expires_at < NOW();
```

### Monitor Reservations
```sql
-- Check active reservations
SELECT pattern, reserved_code, session_id, expires_at 
FROM project_number_reservations 
WHERE expires_at > NOW() AND is_consumed = false;
```

### Reset Counter (if needed)
```sql
-- Sync counter with actual projects
UPDATE project_numbering_rules 
SET current_number = (
  SELECT COALESCE(MAX(CAST(SUBSTRING(code FROM 'HW-(\d+)') AS INTEGER)), 0)
  FROM projects WHERE code ~ '^HW-\d+$'
)
WHERE pattern = 'HW-{####}';
```

## Troubleshooting

### Issue: Counter Mismatch
**Symptom**: Counter shows 7, but no HW projects exist
**Solution**: Run counter reset SQL above

### Issue: Reservation Conflicts
**Symptom**: Multiple users get same preview code
**Solution**: Check session ID generation uniqueness

### Issue: Pattern Cross-contamination
**Symptom**: HW-COMM pattern affects HW pattern
**Solution**: Verify regex precision in reserve function

## Version History
- **v1.0**: Basic counter increment
- **v2.0**: Preview/Generate separation
- **v3.0**: Reservation-based system (current)
- **v3.1**: Pattern precision fixes