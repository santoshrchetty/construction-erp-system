import { UserRole, Module, Permission, PermissionMatrix } from './types'

export const PERMISSION_MATRIX: PermissionMatrix = {
  [UserRole.ADMIN]: {
    [Module.PROJECTS]: [Permission.CREATE, Permission.EDIT, Permission.DELETE, Permission.VIEW, Permission.APPROVE],
    [Module.WBS]: [Permission.CREATE, Permission.EDIT, Permission.DELETE, Permission.VIEW],
    [Module.BOQ]: [Permission.CREATE, Permission.EDIT, Permission.DELETE, Permission.VIEW],
    [Module.TASKS]: [Permission.CREATE, Permission.EDIT, Permission.DELETE, Permission.VIEW],
    [Module.TIMESHEETS]: [Permission.CREATE, Permission.EDIT, Permission.DELETE, Permission.VIEW, Permission.APPROVE],
    [Module.PROCUREMENT]: [Permission.CREATE, Permission.EDIT, Permission.DELETE, Permission.VIEW, Permission.APPROVE],
    [Module.PURCHASE_ORDERS]: [Permission.CREATE, Permission.EDIT, Permission.DELETE, Permission.VIEW, Permission.APPROVE],
    [Module.GOODS_RECEIPTS]: [Permission.CREATE, Permission.EDIT, Permission.DELETE, Permission.VIEW],
    [Module.STORES]: [Permission.CREATE, Permission.EDIT, Permission.DELETE, Permission.VIEW],
    [Module.COSTING]: [Permission.CREATE, Permission.EDIT, Permission.DELETE, Permission.VIEW],
    [Module.CTC]: [Permission.CREATE, Permission.EDIT, Permission.DELETE, Permission.VIEW],
    [Module.PROGRESS]: [Permission.CREATE, Permission.EDIT, Permission.DELETE, Permission.VIEW],
    [Module.REPORTING]: [Permission.CREATE, Permission.EDIT, Permission.DELETE, Permission.VIEW],
    [Module.VENDORS]: [Permission.CREATE, Permission.EDIT, Permission.DELETE, Permission.VIEW],
    [Module.EMPLOYEES]: [Permission.CREATE, Permission.EDIT, Permission.DELETE, Permission.VIEW],
    [Module.USERS]: [Permission.CREATE, Permission.EDIT, Permission.DELETE, Permission.VIEW]
  },

  [UserRole.MANAGER]: {
    [Module.PROJECTS]: [Permission.CREATE, Permission.EDIT, Permission.VIEW],
    [Module.WBS]: [Permission.CREATE, Permission.EDIT, Permission.VIEW],
    [Module.BOQ]: [Permission.CREATE, Permission.EDIT, Permission.VIEW],
    [Module.TASKS]: [Permission.CREATE, Permission.EDIT, Permission.VIEW],
    [Module.TIMESHEETS]: [Permission.VIEW, Permission.APPROVE],
    [Module.PROCUREMENT]: [Permission.VIEW, Permission.APPROVE],
    [Module.PURCHASE_ORDERS]: [Permission.VIEW, Permission.APPROVE],
    [Module.CTC]: [Permission.CREATE, Permission.EDIT, Permission.VIEW],
    [Module.PROGRESS]: [Permission.CREATE, Permission.EDIT, Permission.VIEW],
    [Module.REPORTING]: [Permission.VIEW],
    [Module.VENDORS]: [Permission.VIEW],
    [Module.EMPLOYEES]: [Permission.VIEW]
  },

  [UserRole.PROCUREMENT]: {
    [Module.PROJECTS]: [Permission.VIEW],
    [Module.BOQ]: [Permission.VIEW],
    [Module.PROCUREMENT]: [Permission.CREATE, Permission.EDIT, Permission.VIEW, Permission.SUBMIT],
    [Module.PURCHASE_ORDERS]: [Permission.CREATE, Permission.EDIT, Permission.VIEW, Permission.SUBMIT],
    [Module.VENDORS]: [Permission.CREATE, Permission.EDIT, Permission.VIEW],
    [Module.STORES]: [Permission.VIEW]
  },

  [UserRole.STOREKEEPER]: {
    [Module.PROJECTS]: [Permission.VIEW],
    [Module.PURCHASE_ORDERS]: [Permission.VIEW],
    [Module.GOODS_RECEIPTS]: [Permission.CREATE, Permission.EDIT, Permission.VIEW],
    [Module.STORES]: [Permission.CREATE, Permission.EDIT, Permission.VIEW],
    [Module.VENDORS]: [Permission.VIEW]
  },

  [UserRole.ENGINEER]: {
    [Module.PROJECTS]: [Permission.VIEW],
    [Module.WBS]: [Permission.VIEW],
    [Module.BOQ]: [Permission.VIEW],
    [Module.TASKS]: [Permission.EDIT, Permission.VIEW],
    [Module.PROCUREMENT]: [Permission.CREATE, Permission.VIEW],
    [Module.PROGRESS]: [Permission.CREATE, Permission.EDIT, Permission.VIEW],
    [Module.STORES]: [Permission.VIEW]
  },

  [UserRole.FINANCE]: {
    [Module.PROJECTS]: [Permission.VIEW],
    [Module.BOQ]: [Permission.VIEW],
    [Module.PURCHASE_ORDERS]: [Permission.VIEW, Permission.APPROVE],
    [Module.COSTING]: [Permission.CREATE, Permission.EDIT, Permission.VIEW],
    [Module.CTC]: [Permission.CREATE, Permission.EDIT, Permission.VIEW],
    [Module.PROGRESS]: [Permission.VIEW],
    [Module.REPORTING]: [Permission.VIEW]
  },

  [UserRole.HR]: {
    [Module.PROJECTS]: [Permission.VIEW],
    [Module.TIMESHEETS]: [Permission.VIEW, Permission.APPROVE],
    [Module.EMPLOYEES]: [Permission.CREATE, Permission.EDIT, Permission.VIEW],
    [Module.USERS]: [Permission.VIEW]
  },

  [UserRole.EMPLOYEE]: {
    [Module.PROJECTS]: [Permission.VIEW],
    [Module.TASKS]: [Permission.VIEW],
    [Module.TIMESHEETS]: [Permission.CREATE, Permission.EDIT, Permission.VIEW, Permission.SUBMIT]
  }
}