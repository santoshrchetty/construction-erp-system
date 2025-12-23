// Database Types
export * from './supabase/database.types'

// Zod Schemas
export * from './schemas/projects.schema'
export * from './schemas/wbs.schema'
export * from './schemas/tasks.schema'
export * from './schemas/procurement.schema'
export * from './schemas/stores.schema'
export * from './schemas/timesheets.schema'

// Repositories
export * from './repositories/base.repository'
export * from './repositories/projects.repository'
export * from './repositories/wbs.repository'
export * from './repositories/tasks.repository'
export * from './repositories/procurement.repository'
export * from './repositories/stores.repository'
export * from './repositories/timesheets.repository'

// Common Types
export interface ApiResponse<T> {
  data: T | null
  error: string | null
  success: boolean
}

export interface PaginatedResponse<T> {
  data: T[]
  count: number
  page: number
  pageSize: number
  totalPages: number
}

export interface FilterOptions {
  page?: number
  pageSize?: number
  sortBy?: string
  sortOrder?: 'asc' | 'desc'
  search?: string
}

// Repository Factory
export interface RepositoryFactory {
  projects: ProjectsRepository
  wbs: WBSRepository
  activities: ActivitiesRepository
  tasks: TasksRepository
  vendors: VendorsRepository
  purchaseOrders: PurchaseOrdersRepository
  stores: StoresRepository
  stockItems: StockItemsRepository
  stockBalances: StockBalancesRepository
  stockMovements: StockMovementsRepository
  timesheets: TimesheetsRepository
  timesheetEntries: TimesheetEntriesRepository
}

import { SupabaseClient } from '@supabase/supabase-js'
import { Database } from './supabase/database.types'
import {
  ProjectsRepository,
  WBSRepository,
  ActivitiesRepository,
  TasksRepository,
  VendorsRepository,
  PurchaseOrdersRepository,
  StoresRepository,
  StockItemsRepository,
  StockBalancesRepository,
  StockMovementsRepository,
  TimesheetsRepository,
  TimesheetEntriesRepository
} from './repositories'

export function createRepositoryFactory(supabase: SupabaseClient<Database>): RepositoryFactory {
  return {
    projects: new ProjectsRepository(supabase),
    wbs: new WBSRepository(supabase),
    activities: new ActivitiesRepository(supabase),
    tasks: new TasksRepository(supabase),
    vendors: new VendorsRepository(supabase),
    purchaseOrders: new PurchaseOrdersRepository(supabase),
    stores: new StoresRepository(supabase),
    stockItems: new StockItemsRepository(supabase),
    stockBalances: new StockBalancesRepository(supabase),
    stockMovements: new StockMovementsRepository(supabase),
    timesheets: new TimesheetsRepository(supabase),
    timesheetEntries: new TimesheetEntriesRepository(supabase)
  }
}