# Flexible Workflow System - Implementation Guide

## Overview
SAP Fiori-style single-step-at-a-time approval system for Material Requests, Purchase Requisitions, and Purchase Orders.

## Architecture

### Core Components
1. **FlexibleApprovalService** (`domains/approval/FlexibleApprovalService.ts`)
   - Main orchestration layer
   - Workflow selection and initialization
   - Step progression logic

2. **WorkflowRepository** (`domains/workflow/workflowRepository.ts`)
   - Data access layer
   - Direct Supabase operations

### Database Tables

#### Workflow Configuration
- `workflow_definitions` - Workflow templates (MR_STANDARD, PR_STANDARD, etc.)
- `workflow_steps` - Step definitions with completion rules
- `agent_rules` - Agent resolution rules (HIERARCHY, ROLE, RESPONSIBILITY)
- `step_agents` - Links steps to agent rules

#### Runtime Tables
- `workflow_instances` - Active workflow instances
- `step_instances` - Current step assignments (one row per approver)

#### Master Data
- `org_hierarchy` - Employee hierarchy for HIERARCHY rule
- `role_assignments` - Role-based approvers for ROLE rule
- `responsibility_assignments` - Responsibility-based approvers for RESPONSIBILITY rule

## Workflow Flow

### 1. Submit Material Request
```typescript
// When user clicks Submit button
const result = await FlexibleApprovalService.createWorkflowInstance({
  object_type: 'MATERIAL_REQUEST',
  object_id: materialRequestId,
  requester_id: userId,
  context_data: {
    amount: totalAmount,
    plant_code: plantCode,
    department_code: deptCode,
    material_type: mrType
  }
});
```

### 2. Workflow Selection
- System finds matching workflow based on `object_type` and `activation_conditions`
- Creates `workflow_instance` with status='ACTIVE', current_step_sequence=1

### 3. Step Initialization
- Resolves agents for Step 1 using agent rules
- Creates `step_instances` for each approver (status='PENDING')
- Updates MR status to 'IN_APPROVAL'

### 4. Approval Action
```typescript
// When approver acts
await FlexibleApprovalService.processApproval(
  stepInstanceId,
  'APPROVE', // or 'REJECT'
  'Approved for procurement'
);
```

### 5. Step Completion Check
- Checks completion rule (ALL, ANY, MIN_N)
- If step complete, advances to next step
- If no more steps, marks workflow as COMPLETED
- Updates MR status to 'APPROVED' or 'REJECTED'

## Agent Resolution Rules

### HIERARCHY Rule
Resolves based on organizational hierarchy:
```json
{
  "rule_type": "HIERARCHY",
  "resolution_logic": {
    "level": "manager"
  }
}
```
Finds requester's direct manager from `org_hierarchy` table.

### ROLE Rule
Resolves based on role assignments:
```json
{
  "rule_type": "ROLE",
  "resolution_logic": {
    "role_code": "DEPT_HEAD",
    "scope_filter": {
      "department_code": "context.department_code"
    }
  }
}
```
Finds users with DEPT_HEAD role in requester's department.

### RESPONSIBILITY Rule
Resolves based on responsibility assignments:
```json
{
  "rule_type": "RESPONSIBILITY",
  "resolution_logic": {
    "responsibility_code": "SAFETY_OFFICER"
  }
}
```
Finds users with SAFETY_OFFICER responsibility.

## Completion Rules

- **ALL**: All approvers must approve
- **ANY**: Any one approver can approve/reject
- **MIN_N**: Minimum N approvers must approve (set `min_approvals`)

## Integration Points

### Material Request Submit
Update `handleSubmit` in display page:
```typescript
const handleSubmit = async () => {
  // 1. Update MR status to SUBMITTED
  await fetch(`/api/material-requests/${id}`, {
    method: 'PUT',
    body: JSON.stringify({ ...request, submit: true })
  });
  
  // 2. Create workflow instance
  await fetch('/api/workflows/create', {
    method: 'POST',
    body: JSON.stringify({
      object_type: 'MATERIAL_REQUEST',
      object_id: id,
      context_data: { /* MR details */ }
    })
  });
};
```

### Approval Inbox
Create new page `/approvals/inbox` to show pending approvals:
```typescript
const approvals = await FlexibleApprovalService.getPendingApprovals(userId);
```

### Approval Action
```typescript
await FlexibleApprovalService.processApproval(
  stepInstanceId,
  action,
  comments
);
```

## Next Steps

1. ✅ Run `create_flexible_workflow_schema.sql`
2. ✅ Run `cleanup_old_approval_approach.sql`
3. ⏳ Create workflow API endpoints (`/api/workflows/*`)
4. ⏳ Update MR submit to create workflow instance
5. ⏳ Create approval inbox UI
6. ⏳ Add approval action buttons
7. ⏳ Populate org_hierarchy with test data
8. ⏳ Test end-to-end flow

## Files Removed
- ❌ `materialRequestApprovalService.ts` - Replaced by FlexibleApprovalService
- ❌ `add_approval_columns_to_material_requests.sql` - Not needed
- ❌ Other approval service variants (Enhanced, SAP-aligned, etc.)
