import { createServiceClient } from '@/lib/supabase'
import { ProjectsRepository } from '@/types/repositories/projects.repository'
import { WBSRepository } from '@/types/repositories/wbs.repository'
import { BOQRepository } from '@/types/repositories/boq.repository'
import { TasksRepository } from '@/types/repositories/tasks.repository'
import { TimesheetsRepository } from '@/types/repositories/timesheets.repository'
import { ProcurementRepository } from '@/types/repositories/procurement.repository'
import { StoresRepository } from '@/types/repositories/stores.repository'

const supabase = createServiceClient()

export const repositories = {
  projects: new ProjectsRepository(supabase),
  wbs: new WBSRepository(supabase),
  boq: new BOQRepository(supabase),
  tasks: new TasksRepository(supabase),
  timesheets: new TimesheetsRepository(supabase),
  procurement: new ProcurementRepository(supabase),
  stores: new StoresRepository(supabase),
}