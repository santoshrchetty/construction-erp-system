// WBS API Client - replaces direct Supabase calls
export const wbsApi = {
  async getNodes(projectId: string) {
    const res = await fetch(`/api/wbs?action=nodes&projectId=${projectId}`);
    const json = await res.json();
    return json.data;
  },

  async createNode(data: any) {
    const res = await fetch('/api/wbs?action=nodes', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    const json = await res.json();
    return json.data;
  },

  async updateNode(id: string, data: any) {
    const res = await fetch('/api/wbs?action=nodes', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id, ...data })
    });
    const json = await res.json();
    return json.data;
  },

  async deleteNode(id: string) {
    const res = await fetch('/api/wbs?action=delete', {
      method: 'DELETE',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ type: 'node', id })
    });
    return res.json();
  },

  async getActivities(projectId: string, wbsNodeId?: string) {
    const url = wbsNodeId 
      ? `/api/wbs?action=activities&projectId=${projectId}&wbsNodeId=${wbsNodeId}`
      : `/api/wbs?action=activities&projectId=${projectId}`;
    const res = await fetch(url);
    const json = await res.json();
    return json.data;
  },

  async createActivity(data: any) {
    const res = await fetch('/api/wbs?action=activities', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    const json = await res.json();
    return json.data;
  },

  async updateActivity(id: string, data: any) {
    const res = await fetch('/api/wbs?action=activities', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id, ...data })
    });
    const json = await res.json();
    return json.data;
  },

  async deleteActivity(id: string) {
    const res = await fetch('/api/wbs?action=delete', {
      method: 'DELETE',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ type: 'activity', id })
    });
    return res.json();
  },

  async getTasks(projectId: string, activityId?: string) {
    const url = activityId
      ? `/api/wbs?action=tasks&projectId=${projectId}&activityId=${activityId}`
      : `/api/wbs?action=tasks&projectId=${projectId}`;
    const res = await fetch(url);
    const json = await res.json();
    return json.data;
  },

  async createTask(data: any) {
    const res = await fetch('/api/wbs?action=tasks', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    const json = await res.json();
    return json.data;
  },

  async updateTask(id: string, data: any) {
    const res = await fetch('/api/wbs?action=tasks', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id, ...data })
    });
    const json = await res.json();
    return json.data;
  },

  async getVendors() {
    const res = await fetch('/api/wbs?action=vendors');
    const json = await res.json();
    return json.data;
  }
};
