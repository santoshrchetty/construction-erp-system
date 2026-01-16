'use client';

import React, { useState, useEffect, useRef } from 'react';
import { Calendar, Search, X } from 'lucide-react';
import SchedulingManager from './SchedulingManager';
import { createClient } from '@/lib/supabase/client';

interface Project {
  id: string;
  code: string;
  name: string;
  status: string;
}

export default function ScheduleManagementWithSelector() {
  const [projects, setProjects] = useState<Project[]>([]);
  const [selectedProjectId, setSelectedProjectId] = useState<string>('');
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [showDropdown, setShowDropdown] = useState(false);
  const [searchExpanded, setSearchExpanded] = useState(false);
  const searchRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    loadProjects();
  }, []);

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
    const supabase = createClient();
    const { data } = await supabase
      .from('projects')
      .select('id, code, name, status')
      .order('created_at', { ascending: false });

    if (data) {
      setProjects(data);
      if (data.length === 1) {
        setSelectedProjectId(data[0].id);
      }
    }
    setLoading(false);
  };

  const filteredProjects = projects.filter(p => 
    p.code.toLowerCase().includes(searchQuery.toLowerCase()) ||
    p.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleSelectProject = (projectId: string) => {
    setSelectedProjectId(projectId);
    setSearchQuery('');
    setShowDropdown(false);
    setSearchExpanded(false);
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
            <Calendar className="w-16 h-16 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Select a Project</h3>
            <p className="text-gray-600 mb-4">
              Use the search box above to find and select a project to manage its schedule
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
      {!searchExpanded ? (
        <div className="bg-white border-b px-4 py-2 flex items-center justify-between min-h-[44px]">
          <div className="flex items-center space-x-2 flex-1 min-w-0">
            <Calendar className="w-4 h-4 text-blue-600 flex-shrink-0" />
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

      <div className="flex-1 overflow-hidden">
        <SchedulingManager projectId={selectedProjectId} />
      </div>
    </div>
  );
}
