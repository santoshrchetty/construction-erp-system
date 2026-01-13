export async function getEmployeeOverview() {
  return { employees: [], totalCount: 0 }
}

export async function createEmployee(data: any) {
  return { success: true, data }
}

export async function getTimesheetOverview() {
  return { timesheets: [], totalHours: 0 }
}