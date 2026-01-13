export async function getActiveProjects() {
  return []
}

export async function createProject(payload: any, userId: string) {
  return { id: '1', ...payload }
}

export async function getProjectCostAnalysis(projectId: string) {
  return { projectId, costs: [] }
}

export async function createWBSNode(payload: any, userId: string) {
  return { id: '1', ...payload }
}

export async function getWBSNodes(projectId: string) {
  return []
}