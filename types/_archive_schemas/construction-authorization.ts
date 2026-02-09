// import { z } from 'zod'; // Removed - not using Zod validation

// Construction Action Framework
export enum ConstructionAction {
  INITIATE = 'INITIATE',
  MODIFY = 'MODIFY',
  REVIEW = 'REVIEW',
  EXECUTE = 'EXECUTE',
  APPROVE = 'APPROVE',
  ANALYZE = 'ANALYZE'
}

// Construction Module Codes
export enum ModuleCode {
  PS = 'PS', // Project System
  MM = 'MM', // Materials Management
  PP = 'PP', // Production Planning
  QM = 'QM', // Quality Management
  FI = 'FI', // Financial Accounting
  CO = 'CO', // Controlling
  HR = 'HR', // Human Resources
  WM = 'WM'  // Warehouse Management
}

// Construction Authorization Objects
export const CONSTRUCTION_AUTH_OBJECTS = {
  // Project System
  PROJECT_INITIATE: 'PS_PRJ_INITIATE',
  PROJECT_MODIFY: 'PS_PRJ_MODIFY',
  PROJECT_REVIEW: 'PS_PRJ_REVIEW',
  WBS_CREATE: 'PS_WBS_CREATE',
  WBS_MODIFY: 'PS_WBS_MODIFY',

  // Materials Management
  PO_CREATE: 'MM_PO_CREATE',
  PO_MODIFY: 'MM_PO_MODIFY',
  PO_APPROVE: 'MM_PO_APPROVE',
  GRN_EXECUTE: 'MM_GRN_EXECUTE',
  MATERIAL_MASTER: 'MM_MAT_MASTER',
  VENDOR_MANAGE: 'MM_VEN_MANAGE',

  // Production Planning
  ACTIVITY_SCHEDULE: 'PP_ACT_SCHEDULE',
  ACTIVITY_EXECUTE: 'PP_ACT_EXECUTE',
  TASK_ASSIGN: 'PP_TSK_ASSIGN',
  TASK_UPDATE: 'PP_TSK_UPDATE',

  // Quality Management
  BOQ_REVIEW: 'QM_BOQ_REVIEW',
  BOQ_MODIFY: 'QM_BOQ_MODIFY',
  QC_EXECUTE: 'QM_QC_EXECUTE',

  // Financial/Controlling
  COST_REVIEW: 'FI_CST_REVIEW',
  BUDGET_MODIFY: 'CO_BDG_MODIFY',
  CTC_ANALYZE: 'CO_CTC_ANALYZE',

  // Human Resources
  TIMESHEET_EXECUTE: 'HR_TMS_EXECUTE',
  TIMESHEET_APPROVE: 'HR_TMS_APPROVE',
  EMPLOYEE_MANAGE: 'HR_EMP_MANAGE',

  // Warehouse Management
  STOCK_REVIEW: 'WM_STK_REVIEW',
  STOCK_TRANSFER: 'WM_STK_TRANSFER',
  STORE_MANAGE: 'WM_STR_MANAGE'
} as const;

// Construction Authorization Check Request
export const ConstructionAuthCheckSchema = z.object({
  user_id: z.string().uuid(),
  object_name: z.string(),
  action: z.nativeEnum(ConstructionAction),
  field_values: z.record(z.string()).optional()
});

// Module Access Summary
export const ModuleAccessSchema = z.object({
  module_code: z.nativeEnum(ModuleCode),
  module_name: z.string(),
  auth_objects: z.array(z.string()),
  actions: z.array(z.nativeEnum(ConstructionAction))
});

export type ConstructionAuthCheck = z.infer<typeof ConstructionAuthCheckSchema>;
export type ModuleAccess = z.infer<typeof ModuleAccessSchema>;

// Helper function to get module from auth object
export function getModuleFromAuthObject(authObject: string): ModuleCode | null {
  const moduleCode = authObject.substring(0, 2) as ModuleCode;
  return Object.values(ModuleCode).includes(moduleCode) ? moduleCode : null;
}

// Helper function to get action description
export function getActionDescription(action: ConstructionAction): string {
  switch (action) {
    case ConstructionAction.INITIATE: return 'Start/Create new items';
    case ConstructionAction.MODIFY: return 'Change existing items';
    case ConstructionAction.REVIEW: return 'View/Display items';
    case ConstructionAction.EXECUTE: return 'Perform work/operations';
    case ConstructionAction.APPROVE: return 'Authorize/Sign-off';
    case ConstructionAction.ANALYZE: return 'Analyze/Report on data';
    default: return 'Unknown action';
  }
}