import { supabase } from '@/lib/supabase/client'
import { ProjectsRepository } from '@/types/repositories/projects.repository'
import { WBSRepository } from '@/types/repositories/wbs.repository'
// import { BOQRepository } from '@/types/repositories/boq.repository' // ARCHIVED
import { TasksRepository } from '@/types/repositories/tasks.repository'
// import { TimesheetsRepository } from '@/types/repositories/timesheets.repository' // ARCHIVED
import { ProcurementRepository } from '@/types/repositories/procurement.repository'
import { StoresRepository } from '@/types/repositories/stores.repository'
// import { ActivitiesRepository } from '@/types/repositories/activities.repository' // Doesn't exist

export const repositories = {
  projects: new ProjectsRepository(supabase),
  wbs: new WBSRepository(supabase),
  // boq: new BOQRepository(supabase), // ARCHIVED
  tasks: new TasksRepository(supabase),
  // timesheets: new TimesheetsRepository(supabase), // ARCHIVED
  procurement: new ProcurementRepository(supabase),
  stores: new StoresRepository(supabase),
  // activities: new ActivitiesRepository(supabase), // Doesn't exist
}