'use client';

import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';

interface Task {
  id: string;
  name: string;
  status: string;
  priority: string;
  progress_percentage: number;
  assigned_to?: string;
  activity_id: string;
  activity_name?: string;
  activity_code?: string;
  checklist_item: boolean;
  completion_date?: string;
  daily_logs?: string;
  qa_notes?: string;
  safety_notes?: string;
  due_date?: string;
  estimated_hours?: number;
  actual_hours?: number;
}

interface TeamMember {
  id: string;
  name: string;
  email: string;
  role: string;
}

interface Activity {
  id: string;
  name: string;
  code: string;
}

export default function TaskManager({ projectId }: { projectId: string }) {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [activities, setActivities] = useState<Activity[]>([]);
  const [teamMembers, setTeamMembers] = useState<TeamMember[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [editingTask, setEditingTask] = useState<Task | null>(null);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState<{show: boolean, task: Task | null}>({show: false, task: null});
  const [loading, setLoading] = useState(true);
  const [formData, setFormData] = useState({
    name: '',
    activity_id: '',
    priority: 'medium',
    assigned_to: '',
    checklist_item: false,
    due_date: '',
    estimated_hours: 0,
    daily_logs: '',
    qa_notes: '',
    safety_notes: ''
  });
  const [workingCalendar, setWorkingCalendar] = useState({
    workingDays: [1, 2, 3, 4, 5], // Monday to Friday (0=Sunday, 6=Saturday)
    holidays: [] as string[]
  });
  const [showCalendarSettings, setShowCalendarSettings] = useState(false);

  const isWorkingDay = (date: Date) => {
    const dayOfWeek = date.getDay();
    const dateString = date.toISOString().split('T')[0];
    return workingCalendar.workingDays.includes(dayOfWeek) && 
           !workingCalendar.holidays.includes(dateString);
  };

  const calculateWorkingDays = (startDate: string, endDate: string) => {
    if (!startDate || !endDate) return { calendar: 0, working: 0 };
    
    const start = new Date(startDate);
    const end = new Date(endDate);
    
    if (start > end) return { calendar: 0, working: 0 };
    
    let calendarDays = 0;
    let workingDays = 0;
    const current = new Date(start);
    
    while (current <= end) {
      calendarDays++;
      if (isWorkingDay(current)) {
        workingDays++;
      }
      current.setDate(current.getDate() + 1);
    }
    
    return { calendar: calendarDays, working: workingDays };
  };

  const calculateEndDateFromWorkingDays = (startDate: string, workingDays: number) => {
    if (!startDate || workingDays <= 0) return '';
    
    const start = new Date(startDate);
    let current = new Date(start);
    let remainingDays = workingDays;
    
    while (remainingDays > 0) {
      if (isWorkingDay(current)) {
        remainingDays--;
      }
      if (remainingDays > 0) {
        current.setDate(current.getDate() + 1);
      }
    }
    
    return current.toISOString().split('T')[0];
  };

  useEffect(() => {
    fetchTasks();
    fetchActivities();
    fetchTeamMembers();
    fetchProjectCalendar();
  }, [projectId]);

  const fetchProjectCalendar = async () => {
    const { data } = await supabase
      .from('projects')
      .select('working_days, holidays')
      .eq('id', projectId)
      .single();

    if (data) {
      setWorkingCalendar({
        workingDays: data.working_days || [1, 2, 3, 4, 5],
        holidays: data.holidays || []
      });
    }
  };

  const fetchTasks = async () => {
    const { data } = await supabase
      .from('tasks')
      .select(`
        *, 
        activities(name, code)
      `)
      .eq('project_id', projectId)
      .order('created_at', { ascending: false });

    if (data) {
      const tasksWithActivity = data.map(task => ({
        ...task,
        activity_name: task.activities?.name || 'No Activity',
        activity_code: task.activities?.code || ''
      }));
      setTasks(tasksWithActivity);
    }
    setLoading(false);
  };

  const fetchTeamMembers = async () => {
    const { data } = await supabase
      .from('users')
      .select('id, name, email, role')
      .eq('role', 'engineer');
    
    if (data) setTeamMembers(data);
  };

  const fetchActivities = async () => {
    const { data, error } = await supabase
      .from('activities')
      .select('id, name, code')
      .eq('project_id', projectId);

    if (data) setActivities(data);
  };

  const saveTask = async (e: React.FormEvent) => {
    e.preventDefault();
    
    const { data: user } = await supabase.auth.getUser();
    
    const taskData = {
      project_id: projectId,
      name: formData.name,
      activity_id: formData.activity_id,
      priority: formData.priority,
      assigned_to: formData.assigned_to || null,
      checklist_item: formData.checklist_item,
      due_date: formData.due_date || null,
      estimated_hours: formData.estimated_hours,
      daily_logs: formData.daily_logs,
      qa_notes: formData.qa_notes,
      safety_notes: formData.safety_notes,
      status: 'not_started',
      progress_percentage: 0,
      created_by: user.user?.id
    };

    let error;
    if (editingTask) {
      const { error: updateError } = await supabase
        .from('tasks')
        .update(taskData)
        .eq('id', editingTask.id);
      error = updateError;
    } else {
      const { error: insertError } = await supabase
        .from('tasks')
        .insert(taskData);
      error = insertError;
    }

    if (!error) {
      resetForm();
      fetchTasks();
    }
  };

  const editTask = (task: Task) => {
    setEditingTask(task);
    setFormData({
      name: task.name,
      activity_id: task.activity_id,
      priority: task.priority,
      assigned_to: task.assigned_to || '',
      checklist_item: task.checklist_item,
      due_date: task.due_date || '',
      estimated_hours: task.estimated_hours || 0,
      daily_logs: task.daily_logs || '',
      qa_notes: task.qa_notes || '',
      safety_notes: task.safety_notes || ''
    });
    setShowForm(true);
  };

  const deleteTask = async (taskId: string) => {
    const { error } = await supabase
      .from('tasks')
      .delete()
      .eq('id', taskId);

    if (!error) {
      setShowDeleteConfirm({show: false, task: null});
      fetchTasks();
    }
  };

  const resetForm = () => {
    setShowForm(false);
    setEditingTask(null);
    setFormData({
      name: '',
      activity_id: '',
      priority: 'medium',
      assigned_to: '',
      checklist_item: false,
      due_date: '',
      estimated_hours: 0,
      daily_logs: '',
      qa_notes: '',
      safety_notes: ''
    });
  };

  const updateTaskProgress = async (taskId: string, progress: number) => {
    const status = progress === 0 ? 'not_started' : 
                  progress === 100 ? 'completed' : 'in_progress';

    const { error } = await supabase
      .from('tasks')
      .update({ 
        progress_percentage: progress,
        status: status
      })
      .eq('id', taskId);

    if (!error) fetchTasks();
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed': return 'bg-green-500';
      case 'in_progress': return 'bg-blue-500';
      case 'on_hold': return 'bg-yellow-500';
      default: return 'bg-gray-300';
    }
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'critical': return 'text-red-600 bg-red-50';
      case 'high': return 'text-orange-600 bg-orange-50';
      case 'medium': return 'text-blue-600 bg-blue-50';
      default: return 'text-gray-600 bg-gray-50';
    }
  };

  const getTaskIcon = (task: Task) => {
    if (task.checklist_item) return task.status === 'completed' ? '✅' : '☐';
    return task.status === 'completed' ? '📋✓' : '📋';
  };

  const getAssignedMemberName = (memberId: string) => {
    const member = teamMembers.find(m => m.id === memberId);
    return member ? member.name : 'Unassigned';
  };

  if (loading) return <div className="p-6">Loading tasks...</div>;

  return (
    <div className="p-6">
      <div className="bg-white rounded-lg shadow">
        <div className="p-4 border-b">
          <div className="flex justify-between items-center">
            <div>
              <h2 className="text-lg font-bold">Task Management</h2>
              <p className="text-sm text-gray-600">Track and manage project tasks</p>
            </div>
            <button
              onClick={() => setShowForm(true)}
              className="bg-purple-600 text-white px-4 py-2 rounded hover:bg-purple-700 flex items-center space-x-2"
            >
              <span>📝</span>
              <span>Add Task</span>
            </button>
          </div>
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Task</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Activity</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Assigned To</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Priority</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Progress</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Due Date</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {tasks.map((task) => (
                <tr key={task.id} className="hover:bg-gray-50">
                  <td className="px-4 py-3">
                    <div className="flex items-center space-x-2">
                      <span className="text-lg">{getTaskIcon(task)}</span>
                      <div>
                        <div className="font-medium text-sm">{task.name}</div>
                        <div className="text-xs text-gray-500">
                          {task.checklist_item ? 'Checklist Item' : 'Task'}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <div>
                      <div className="text-sm">{task.activity_name}</div>
                      <div className="text-xs text-gray-500">{task.activity_code}</div>
                    </div>
                  </td>
                  <td className="px-4 py-3 text-sm">{getAssignedMemberName(task.assigned_to || '')}</td>
                  <td className="px-4 py-3">
                    <div className="flex items-center">
                      <div className={`w-3 h-3 rounded-full ${getStatusColor(task.status)} mr-2`}></div>
                      <span className="text-sm capitalize">{task.status?.replace('_', ' ')}</span>
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-1 rounded text-xs ${getPriorityColor(task.priority)}`}>
                      {task.priority}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center space-x-2">
                      <div className="w-16 h-2 bg-gray-200 rounded-full overflow-hidden">
                        <div 
                          className="h-full bg-purple-500 transition-all duration-300"
                          style={{ width: `${task.progress_percentage}%` }}
                        ></div>
                      </div>
                      <span className="text-xs text-gray-500">{task.progress_percentage}%</span>
                    </div>
                  </td>
                  <td className="px-4 py-3 text-sm">
                    {task.due_date ? new Date(task.due_date).toLocaleDateString() : 'No due date'}
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex space-x-2">
                      <button 
                        onClick={() => editTask(task)}
                        className="text-blue-600 hover:text-blue-800 text-sm"
                        title="Edit Task"
                      >
                        ✏️
                      </button>
                      <button 
                        onClick={() => setShowDeleteConfirm({show: true, task})}
                        className="text-red-600 hover:text-red-800 text-sm"
                        title="Delete Task"
                      >
                        🗑️
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {tasks.length === 0 && (
          <div className="text-center py-12">
            <p className="text-gray-500 mb-4">No tasks found. Create tasks to get started.</p>
            <button
              onClick={() => setShowForm(true)}
              className="bg-purple-600 text-white px-4 py-2 rounded hover:bg-purple-700"
            >
              Create First Task
            </button>
          </div>
        )}
      </div>

      {showForm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
            <h3 className="text-lg font-bold mb-4">{editingTask ? 'Edit Task' : 'Add Task'}</h3>
            <form onSubmit={saveTask} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Task Name</label>
                  <input
                    type="text"
                    value={formData.name}
                    onChange={(e) => setFormData({...formData, name: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                    placeholder="Install electrical outlets"
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Activity</label>
                  <select
                    value={formData.activity_id}
                    onChange={(e) => setFormData({...formData, activity_id: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                    required
                  >
                    <option value="">Select Activity</option>
                    {activities.map((activity) => (
                      <option key={activity.id} value={activity.id}>
                        {activity.code} - {activity.name}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
              
              <div className="grid grid-cols-3 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Priority</label>
                  <select
                    value={formData.priority}
                    onChange={(e) => setFormData({...formData, priority: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  >
                    <option value="low">Low</option>
                    <option value="medium">Medium</option>
                    <option value="high">High</option>
                    <option value="critical">Critical</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Due Date</label>
                  <input
                    type="date"
                    value={formData.due_date}
                    onChange={(e) => setFormData({...formData, due_date: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Estimated Hours</label>
                  <input
                    type="number"
                    min="0"
                    step="0.5"
                    value={formData.estimated_hours}
                    onChange={(e) => setFormData({...formData, estimated_hours: parseFloat(e.target.value) || 0})}
                    className="w-full border rounded px-3 py-2"
                  />
                </div>
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Assign To</label>
                <select
                  value={formData.assigned_to}
                  onChange={(e) => setFormData({...formData, assigned_to: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                >
                  <option value="">Unassigned</option>
                  {teamMembers.map((member) => (
                    <option key={member.id} value={member.id}>
                      {member.name} ({member.role})
                    </option>
                  ))}
                </select>
              </div>
              
              <div>
                <label className="flex items-center space-x-2">
                  <input
                    type="checkbox"
                    checked={formData.checklist_item}
                    onChange={(e) => setFormData({...formData, checklist_item: e.target.checked})}
                    className="rounded"
                  />
                  <span className="text-sm font-medium">Simple Checklist Item</span>
                </label>
                <p className="text-xs text-gray-500 mt-1">Check if this is a simple yes/no checklist item</p>
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Daily Logs</label>
                <textarea
                  value={formData.daily_logs}
                  onChange={(e) => setFormData({...formData, daily_logs: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                  rows={2}
                  placeholder="Daily progress notes..."
                />
              </div>
              
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">QA/QC Notes</label>
                  <textarea
                    value={formData.qa_notes}
                    onChange={(e) => setFormData({...formData, qa_notes: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                    rows={2}
                    placeholder="Quality control notes..."
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Safety Notes</label>
                  <textarea
                    value={formData.safety_notes}
                    onChange={(e) => setFormData({...formData, safety_notes: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                    rows={2}
                    placeholder="Safety observations..."
                  />
                </div>
              </div>
              
              <div className="flex justify-end space-x-3 pt-4 border-t">
                <button
                  type="button"
                  onClick={resetForm}
                  className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-purple-600 text-white rounded hover:bg-purple-700"
                >
                  {editingTask ? 'Update Task' : 'Create Task'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {showDeleteConfirm.show && showDeleteConfirm.task && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-bold mb-4 text-red-600">Delete Task</h3>
            <p className="mb-4">
              Are you sure you want to delete <strong>{showDeleteConfirm.task.name}</strong>?
            </p>
            <p className="text-sm text-gray-600 mb-6">
              This action cannot be undone.
            </p>
            <div className="flex justify-end space-x-3">
              <button
                onClick={() => setShowDeleteConfirm({show: false, task: null})}
                className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                onClick={() => deleteTask(showDeleteConfirm.task!.id)}
                className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700"
              >
                Delete Task
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}