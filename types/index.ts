// Database Types
export * from './supabase/database.types'

// Zod Schemas - COMMENTED OUT (Zod not installed)
// export * from './schemas/projects.schema'
// export * from './schemas/wbs.schema'
// export * from './schemas/tasks.schema'
// export * from './schemas/procurement.schema'
// export * from './schemas/stores.schema'
// export * from './schemas/timesheets.schema'

// Repositories
export * from './repositories/base.repository'
export * from './repositories/projects.repository'
export * from './repositories/wbs.repository'
export * from './repositories/tasks.repository'
export * from './repositories/procurement.repository'
export * from './repositories/stores.repository'
// export * from './repositories/timesheets.repository' // COMMENTED OUT - table doesn't exist

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
  tasks: TasksRepository
  vendor: VendorRepository
  stores: StoresRepository
}

import { SupabaseClient } from '@supabase/supabase-js'
import { Database } from './supabase/database.types'
import {
  ProjectsRepository,
  WBSRepository,
  TasksRepository,
  VendorRepository,
  StoresRepository
} from './repositories'

export function createRepositoryFactory(supabase: SupabaseClient<Database>): RepositoryFactory {
  return {
    projects: new ProjectsRepository(supabase),
    wbs: new WBSRepository(supabase),
    tasks: new TasksRepository(supabase),
    vendor: new VendorRepository(supabase),
    stores: new StoresRepository(supabase)
  }
}