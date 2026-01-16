'use client';

import React, { useState, useEffect, useRef } from 'react';
import { Activity, Search, X, Filter } from 'lucide-react';

interface Project {
  id: string;
  code: string;
  name: string;
  status: string;
}

interface WBSNode {
  id: string;
  code: string;
  name: string;
}

interface ActivityData {
  id: string;
  code: string;
  name: string;
  activity_type: string;
  status: string;
  priority: string;
  wbs_node_id: string;
  duration_days: number;
  planned_start_date: string;
  planned_end_date: string;
  actual_start_date: string;
  actual_end_date: string;
  progress_percentage: number;
  budget_amount: number;
  wbs_nodes?: { code: string; name: string };
}

export default function ActivitiesManagementWithSelector() {
  const [projects, setProjects] = useState<Project[]>([]);
  const [selectedProjectId, setSelectedProjectId] = useState<string>('');
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [showDropdown, setShowDropdown] = useState(false);
  const [searchExpanded, setSearchExpanded] = useState(false);
  const searchRef = useRef<HTMLDivElement>(null);

  // Activities state
  const [activities, setActivities] = useState<ActivityData[]>([]);
  const [wbsNodes, setWBSNodes] = useState<WBSNode[]>([]);
  const [activitySearch, setActivitySearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [priorityFilter, setPriorityFilter] = useState('all');
  const [wbsFilter, setWBSFilter] = useState('all');
  const [loadingActivities, setLoadingActivities] = useState(false);

  useEffect(() => {
    loadProjects();
  }, []);

  useEffect(() => {
    if (selectedProjectId) {
      loadActivities();
      loadWBSNodes();
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

  const loadActivities = async () => {
    setLoadingActivities(true);
    const res = await fetch(`/api/activities?projectId=${selectedProjectId}`);
    const { activities } = await res.json();
    if (activities) {
      setActivities(activities);
    }
    setLoadingActivities(false);
  };

  const loadWBSNodes = async () => {
    const res = await fetch(`/api/wbs?action=nodes&projectId=${selectedProjectId}`);
    const json = await res.json();
    if (json.success && json.data) {
      setWBSNodes(json.data);
    }
  };

  const filteredProjects = projects.filter(p => 
    p.code.toLowerCase().includes(searchQuery.toLowerCase()) ||
    p.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const filteredActivities = activities.filter(activity => {
    const matchesSearch = activitySearch === '' || 
      activity.code.toLowerCase().includes(activitySearch.toLowerCase()) ||
      activity.name.toLowerCase().includes(activitySearch.toLowerCase());
    
    const matchesStatus = statusFilter === 'all' || activity.status === statusFilter;
    const matchesPriority = priorityFilter === 'all' || activity.priority === priorityFilter;
    const matchesWBS = wbsFilter === 'all' || activity.wbs_node_id === wbsFilter;

    return matchesSearch && matchesStatus && matchesPriority && matchesWBS;
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
      'on_hold': 'bg-yellow-100 text-yellow-800',
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
            <Activity className="w-16 h-16 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Select a Project</h3>
            <p className="text-gray-600 mb-4">
              Use the search box above to find and select a project to manage its activities
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
            <Activity className="w-4 h-4 text-blue-600 flex-shrink-0" />
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

      {/* Activities Search and Filters */}
      <div className="bg-white border-b px-4 py-3 space-y-3">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input
            type="text"
            value={activitySearch}
            onChange={(e) => setActivitySearch(e.target.value)}
            placeholder="Search activities..."
            className="w-full pl-10 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm"
          />
        </div>
        
        <div className="flex flex-wrap gap-2">
          <select
            value={wbsFilter}
            onChange={(e) => setWBSFilter(e.target.value)}
            className="px-3 py-1.5 text-sm border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="all">All WBS</option>
            {wbsNodes.map(node => (
              <option key={node.id} value={node.id}>{node.code}</option>
            ))}
          </select>
          
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="px-3 py-1.5 text-sm border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="all">All Status</option>
            <option value="not_started">Not Started</option>
            <option value="in_progress">In Progress</option>
            <option value="completed">Completed</option>
            <option value="on_hold">On Hold</option>
          </select>
          
          <select
            value={priorityFilter}
            onChange={(e) => setPriorityFilter(e.target.value)}
            className="px-3 py-1.5 text-sm border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          >
            <option value="all">All Priority</option>
            <option value="low">Low</option>
            <option value="medium">Medium</option>
            <option value="high">High</option>
            <option value="critical">Critical</option>
          </select>
        </div>
      </div>

      {/* Activities List */}
      <div className="flex-1 overflow-auto p-4">
        {loadingActivities ? (
          <div className="flex items-center justify-center h-64">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
          </div>
        ) : filteredActivities.length === 0 ? (
          <div className="text-center py-12">
            <Activity className="w-12 h-12 text-gray-400 mx-auto mb-3" />
            <p className="text-gray-600">No activities found</p>
          </div>
        ) : (
          <div className="space-y-3">
            {filteredActivities.map((activity) => (
              <div key={activity.id} className="bg-white rounded-lg border border-gray-200 p-4 hover:shadow-md transition-shadow">
                <div className="flex items-start justify-between mb-3">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <span className="text-xs font-mono text-gray-500">{activity.code}</span>
                      <span className={`text-xs px-2 py-0.5 rounded-full ${getStatusColor(activity.status)}`}>
                        {activity.status.replace('_', ' ')}
                      </span>
                      <span className={`text-xs font-medium uppercase ${getPriorityColor(activity.priority)}`}>
                        {activity.priority}
                      </span>
                    </div>
                    <h3 className="font-semibold text-gray-900 mb-2">{activity.name}</h3>
                    
                    {/* PM Fields Grid */}
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-3 text-xs">
                      <div>
                        <div className="text-gray-500">Duration</div>
                        <div className="font-medium text-gray-900">{activity.duration_days || 0} days</div>
                      </div>
                      <div>
                        <div className="text-gray-500">Start Date</div>
                        <div className="font-medium text-gray-900">
                          {activity.planned_start_date ? new Date(activity.planned_start_date).toLocaleDateString() : '-'}
                        </div>
                      </div>
                      <div>
                        <div className="text-gray-500">Progress</div>
                        <div className="font-medium text-gray-900">{activity.progress_percentage || 0}%</div>
                      </div>
                      <div>
                        <div className="text-gray-500">Budget</div>
                        <div className="font-medium text-gray-900">
                          ${(activity.budget_amount || 0).toLocaleString()}
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                
                {activity.wbs_nodes && (
                  <div className="text-xs text-gray-600 mt-2 pt-2 border-t">
                    WBS: {activity.wbs_nodes.code} - {activity.wbs_nodes.name}
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
