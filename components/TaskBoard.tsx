import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';

interface Task {
  id: string;
  name: string;
  status: string;
  priority: string;
  progress_percentage: number;
  planned_end_date: string;
  assigned_to: string;
  activity_name?: string;
}

const statusColumns = [
  { key: 'not_started', title: 'Not Started', color: 'bg-gray-50' },
  { key: 'in_progress', title: 'In Progress', color: 'bg-blue-50' },
  { key: 'completed', title: 'Completed', color: 'bg-green-50' }
];

export default function TaskBoard({ projectId }: { projectId: string }) {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (projectId) fetchTasks();
  }, [projectId]);

  const fetchTasks = async () => {
    try {
      const { data, error } = await supabase
        .from('tasks')
        .select(`
          id, name, status, priority, progress_percentage, 
          planned_end_date, assigned_to,
          activities(name)
        `)
        .eq('project_id', projectId);

      if (error) throw error;

      const tasksWithActivity = data?.map(task => ({
        ...task,
        activity_name: task.activities?.name || 'No Activity'
      })) || [];

      setTasks(tasksWithActivity);
    } catch (error) {
      console.error('Error fetching tasks:', error);
    } finally {
      setLoading(false);
    }
  };

  const updateTaskStatus = async (taskId: string, newStatus: string) => {
    try {
      const { error } = await supabase
        .from('tasks')
        .update({ 
          status: newStatus,
          progress_percentage: newStatus === 'completed' ? 100 : 
                              newStatus === 'in_progress' ? 50 : 0
        })
        .eq('id', taskId);

      if (error) throw error;
      fetchTasks();
    } catch (error) {
      console.error('Error updating task:', error);
    }
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'critical': return 'bg-red-100 text-red-800';
      case 'high': return 'bg-orange-100 text-orange-800';
      case 'medium': return 'bg-yellow-100 text-yellow-800';
      case 'low': return 'bg-green-100 text-green-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getTasksByStatus = (status: string) => {
    return tasks.filter(task => task.status === status);
  };

  if (loading) return <div className="p-6">Loading tasks...</div>;

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-xl font-bold">Task Board</h2>
        <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
          Add Task
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {statusColumns.map((column) => (
          <div key={column.key} className={`${column.color} rounded-lg p-4`}>
            <div className="flex justify-between items-center mb-4">
              <h3 className="font-semibold">{column.title}</h3>
              <span className="bg-white px-2 py-1 rounded-full text-sm">
                {getTasksByStatus(column.key).length}
              </span>
            </div>

            <div className="space-y-3">
              {getTasksByStatus(column.key).map((task) => (
                <div key={task.id} className="bg-white rounded-lg p-4 shadow-sm border">
                  <div className="flex justify-between items-start mb-2">
                    <h4 className="font-medium text-sm">{task.name}</h4>
                    <span className={`px-2 py-1 rounded-full text-xs ${getPriorityColor(task.priority)}`}>
                      {task.priority}
                    </span>
                  </div>

                  <p className="text-xs text-gray-600 mb-2">{task.activity_name}</p>

                  <div className="mb-3">
                    <div className="flex justify-between text-xs mb-1">
                      <span>Progress</span>
                      <span>{task.progress_percentage}%</span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-1">
                      <div 
                        className="bg-blue-600 h-1 rounded-full" 
                        style={{ width: `${task.progress_percentage}%` }}
                      ></div>
                    </div>
                  </div>

                  <div className="flex justify-between text-xs text-gray-500 mb-3">
                    <span>Due: {new Date(task.planned_end_date).toLocaleDateString()}</span>
                  </div>

                  <div className="flex space-x-1">
                    {statusColumns.map((status) => (
                      <button
                        key={status.key}
                        onClick={() => updateTaskStatus(task.id, status.key)}
                        className={`flex-1 py-1 px-2 text-xs rounded ${
                          task.status === status.key 
                            ? 'bg-blue-600 text-white' 
                            : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                        }`}
                        disabled={task.status === status.key}
                      >
                        {status.key === 'not_started' ? 'Start' : 
                         status.key === 'in_progress' ? 'Progress' : 'Complete'}
                      </button>
                    ))}
                  </div>
                </div>
              ))}

              {getTasksByStatus(column.key).length === 0 && (
                <div className="text-center py-8 text-gray-500 text-sm">
                  No tasks in {column.title.toLowerCase()}
                </div>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}