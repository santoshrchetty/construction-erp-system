'use client';

import React, { useState, useEffect, useRef } from 'react';
import { CheckSquare, Search, X, User } from 'lucide-react';

interface Project {
  id: string;
  code: string;
  name: string;
  status: string;
}

interface ActivityData {
  id: string;
  code: string;
  name: string;
}

interface TaskData {
  id: string;
  name: string;
  status: string;
  priority: string;
  activity_id: string;
  assigned_to?: string;
  checklist_item: boolean;
  activities?: { code: string; name: string };
}

export default function TasksManagementWithSelector() {
  const [projects, setProjects] = useState<Project[]>([]);
  const [selectedProjectId, setSelectedProjectId] = useState<string>('');
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [showDropdown, setShowDropdown] = useState(false);
  const [searchExpanded, setSearchExpanded] = useState(false);
  const searchRef = useRef<HTMLDivElement>(null);

  // Tasks state
  const [tasks, setTasks] = useState<TaskData[]>([]);
  const [activities, setActivities] = useState<ActivityData[]>([]);
  const [taskSearch, setTaskSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [activityFilter, setActivityFilter] = useState('all');
  const [myTasksOnly, setMyTasksOnly] = useState(false);
  const [loadingTasks, setLoadingTasks] = useState(false);

  useEffect(() => {
    loadProjects();
  }, []);

  useEffect(() => {
    if (selectedProjectId) {
      loadTasks();
      loadActivities();
    }
  }, [selectedProjectId]);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (searchRef.current && !searchRef.current.contains(event.target as Node)) {
        setShowDropdown(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const loadProjects = async () => {
    const res = await fetch('/api/projects');
    const { projects } = await res.json();
    if (projects) {
      setProjects(projects);
      if (projects.length === 1) {
        setSelectedProjectId(projects[0].id);
      }
    }
    setLoading(false);
  };

  const loadTasks = async () => {
    setLoadingTasks(true);
    const res = await fetch(`/api/tasks?projectId=${selectedProjectId}`);
    const { tasks } = await res.json();
    if (tasks) {
      setTasks(tasks);
    }
    setLoadingTasks(false);
  };

  const loadActivities = async () => {
    const res = await fetch(`/api/activities?projectId=${selectedProjectId}`);
    const { activities } = await res.json();
    if (activities) {
      setActivities(activities);
    }
  };

  const filteredProjects = projects.filter(p => 
    p.code.toLowerCase().includes(searchQuery.toLowerCase()) ||
    p.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const filteredTasks = tasks.filter(task => {
    const matchesSearch = taskSearch === '' || 
      task.name.toLowerCase().includes(taskSearch.toLowerCase());
    
    const matchesStatus = statusFilter === 'all' || task.status === statusFilter;
    const matchesActivity = activityFilter === 'all' || task.activity_id === activityFilter;
    // TODO: Implement myTasksOnly filter when user assignment is available
    // const matchesUser = !myTasksOnly || task.assigned_to === currentUserId;

    return matchesSearch && matchesStatus && matchesActivity;
  });

  const handleSelectProject = (projectId: string) => {
    setSelectedProjectId(projectId);
    setSearchQuery('');
    setShowDropdown(false);
    setSearchExpanded(false);
  };

  const getStatusColor = (status: string) => {
    const colors: Record<string, string> = {
      'not_started': 'bg-gray-100 text-gray-800',
      'in_progress': 'bg-blue-100 text-blue-800',
      'completed': 'bg-green-100 text-green-800',
      'blocked': 'bg-red-100 text-red-800',
    };
    return colors[status] || 'bg-gray-100 text-gray-800';
  };

  const getPriorityColor = (priority: string) => {
    const colors: Record<string, string> = {
      'low': 'text-gray-600',
      'medium': 'text-blue-600',
      'high': 'text-orange-600',
      'critical': 'text-red-600',
    };
    return colors[priority] || 'text-gray-600';
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (!selectedProjectId) {
    return (
      <div className="h-screen flex flex-col">
        <div className="bg-white border-b px-4 py-3" ref={searchRef}>
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => {
                setSearchQuery(e.target.value);
                setShowDropdown(true);
              }}
              onFocus={() => setShowDropdown(true)}
              placeholder="Search projects to begin..."
              className="w-full pl-10 pr-10 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm"
            />
            {searchQuery && (
              <button
                onClick={() => {
                  setSearchQuery('');
                  setShowDropdown(false);
                }}
                className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
              >
                <X className="w-4 h-4" />
              </button>
            )}
            
            {showDropdown && filteredProjects.length > 0 && (
              <div className="absolute z-50 w-full mt-1 bg-white border border-gray-200 rounded-lg shadow-lg max-h-64 overflow-y-auto">
                {filteredProjects.map((project) => (
                  <button
                    key={project.id}
                    onClick={() => handleSelectProject(project.id)}
                    className="w-full px-4 py-3 text-left hover:bg-gray-50 border-b last:border-b-0"
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex-1 min-w-0">
                        <div className="font-medium text-sm text-gray-900">{project.code}</div>
                        <div className="text-xs text-gray-600 truncate">{project.name}</div>
                      </div>
                    </div>
                  </button>
                ))}
              </div>
            )}
          </div>
        </div>
        
        <div className="flex-1 flex items-center justify-center bg-[#F7F7F7] p-6">
          <div className="text-center max-w-md">
            <CheckSquare className="w-16 h-16 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Select a Project</h3>
            <p className="text-gray-600 mb-4">
              Use the search box above to find and select a project to manage its tasks
            </p>
            {projects.length === 0 && (
              <p className="text-sm text-gray-500 mt-4">
                No projects available. Create a project first.
              </p>
            )}
          </div>
        </div>
      </div>
    );
  }

  const selectedProject = projects.find(p => p.id === selectedProjectId);

  return (
    <div className="h-screen flex flex-col bg-[#F7F7F7]">
      {/* Project Selector Header */}
      {!searchExpanded ? (
        <div className="bg-white border-b px-4 py-2 flex items-center justify-between min-h-[44px]">
          <div className="flex items-center space-x-2 flex-1 min-w-0">
            <CheckSquare className="w-4 h-4 text-blue-600 flex-shrink-0" />
            <div className="flex-1 min-w-0">
              <div className="text-sm font-semibold text-gray-900 truncate">
                {selectedProject?.code} • {selectedProject?.name}
              </div>
            </div>
          </div>
          <button
            onClick={() => setSearchExpanded(true)}
            className="p-2 hover:bg-gray-100 rounded flex-shrink-0"
            title="Switch project"
          >
            <Search className="w-4 h-4 text-gray-600" />
          </button>
        </div>
      ) : (
        <div className="bg-white border-b px-4 py-3" ref={searchRef}>
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => {
                setSearchQuery(e.target.value);
                setShowDropdown(true);
              }}
              onFocus={() => setShowDropdown(true)}
              placeholder="Search projects..."
              className="w-full pl-10 pr-10 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm"
            />
            {searchQuery && (
              <button
                onClick={() => {
                  setSearchQuery('');
                  setShowDropdown(false);
                }}
                className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
              >
                <X className="w-4 h-4" />
              </button>
            )}
            
            {showDropdown && filteredProjects.length > 0 && (
              <div className="absolute z-50 w-full mt-1 bg-white border border-gray-200 rounded-lg shadow-lg max-h-64 overflow-y-auto">
                {filteredProjects.map((project) => (
                  <button
                    key={project.id}
                    onClick={() => handleSelectProject(project.id)}
                    className={`w-full px-4 py-3 text-left hover:bg-gray-50 border-b last:border-b-0 ${
                      project.id === selectedProjectId ? 'bg-blue-50' : ''
                    }`}
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex-1 min-w-0">
                        <div className="font-medium text-sm text-gray-900">{project.code}</div>
                        <div className="text-xs text-gray-600 truncate">{project.name}</div>
                      </div>
                      {project.id === selectedProjectId && (
                        <span className="text-blue-600 ml-2">✓</span>
                      )}
                    </div>
                  </button>
                ))}
              </div>
            )}
          </div>
        </div>
      )}

      {/* Tasks Search and Filters */}
      <div className="bg-white border-b px-4 py-3 space-y-3">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input
            type="text"
            value={taskSearch}
            onChange={(e) => setTaskSearch(e.target.value)}
            placeholder="Search tasks..."
            className="w-full pl-10 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm"
          />
        </div>
        
        <div className="flex flex-wrap gap-2">
          <button
            onClick={() => setMyTasksOnly(!myTasksOnly)}
            className={`px-3 py-1.5 text-sm rounded-lg flex items-center gap-1 transition-colors ${
              myTasksOnly 
                ? 'bg-blue-600 text-white' 
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
            }`}
          >
            <User className="w-3.5 h-3.5" />
            My Tasks
          </button>
          
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="px-3 py-1.5 text-sm border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="all">All Status</option>
            <option value="not_started">Not Started</option>
            <option value="in_progress">In Progress</option>
            <option value="completed">Completed</option>
            <option value="blocked">Blocked</option>
          </select>
          
          <select
            value={activityFilter}
            onChange={(e) => setActivityFilter(e.target.value)}
            className="px-3 py-1.5 text-sm border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="all">All Activities</option>
            {activities.map(activity => (
              <option key={activity.id} value={activity.id}>{activity.code}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Tasks List */}
      <div className="flex-1 overflow-auto p-4">
        {loadingTasks ? (
          <div className="flex items-center justify-center h-64">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
          </div>
        ) : filteredTasks.length === 0 ? (
          <div className="text-center py-12">
            <CheckSquare className="w-12 h-12 text-gray-400 mx-auto mb-3" />
            <p className="text-gray-600">No tasks found</p>
          </div>
        ) : (
          <div className="space-y-3">
            {filteredTasks.map((task) => (
              <div key={task.id} className="bg-white rounded-lg border border-gray-200 p-4 hover:shadow-md transition-shadow">
                <div className="flex items-start gap-3">
                  <div className="flex-shrink-0 mt-1">
                    <div className={`w-5 h-5 rounded border-2 flex items-center justify-center ${
                      task.status === 'completed' 
                        ? 'bg-green-500 border-green-500' 
                        : 'border-gray-300'
                    }`}>
                      {task.status === 'completed' && (
                        <svg className="w-3 h-3 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                        </svg>
                      )}
                    </div>
                  </div>
                  
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-1">
                      <span className={`text-xs px-2 py-0.5 rounded-full ${getStatusColor(task.status)}`}>
                        {task.status.replace('_', ' ')}
                      </span>
                      {task.checklist_item && (
                        <span className="text-xs text-gray-500">✓ Checklist</span>
                      )}
                    </div>
                    <h3 className="font-medium text-gray-900">{task.name}</h3>
                    {task.activities && (
                      <div className="text-xs text-gray-600 mt-1">
                        Activity: {task.activities.code} - {task.activities.name}
                      </div>
                    )}
                  </div>
                  
                  <span className={`text-xs font-medium uppercase flex-shrink-0 ${getPriorityColor(task.priority)}`}>
                    {task.priority}
                  </span>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
