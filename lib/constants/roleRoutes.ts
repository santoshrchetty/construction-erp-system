// Centralized role routing configuration
export const ROLE_ROUTES = {
  Admin: ['/admin'],
  Manager: ['/manager'],
  Procurement: ['/procurement'],
  Storekeeper: ['/storekeeper'],
  Engineer: ['/engineer'],
  Finance: ['/finance'],
  HR: ['/hr'],
  Employee: ['/employee'],
} as const

export const PROTECTED_ROUTES = [
  '/admin',
  '/manager',
  '/procurement',
  '/storekeeper',
  '/engineer',
  '/finance',
  '/hr',
  '/employee',
] as const

export type UserRole = keyof typeof ROLE_ROUTES