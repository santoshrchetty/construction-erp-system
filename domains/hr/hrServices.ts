export async function getEmployeeOverview() {
  return { employees: [], totalCount: 0 }
}

export async function getEmployeeList() {
  return { employees: [], totalCount: 0 }
}

export async function createEmployee(data: any) {
  return { success: true, data }
}

export async function getTimesheetOverview() {
  return { timesheets: [], totalHours: 0 }
}

export async function getTimesheetApprovals(userId: string) {
  return { timesheets: [], pending: 0 }
}

export async function getLeaveRequests() {
  return { requests: [], pending: 0 }
}