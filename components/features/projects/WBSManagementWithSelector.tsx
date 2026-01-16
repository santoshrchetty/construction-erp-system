'use client';

import React, { useState, useEffect, useRef } from 'react';
import { Building, Search, X, Menu } from 'lucide-react';
import WBSBuilder from './WBSBuilder';
import { createClient } from '@/lib/supabase/client';

interface Project {
  id: string;
  code: string;
  name: string;
  status: string;
}

export default function WBSManagementWithSelector() {
  const [projects, setProjects] = useState<Project[]>([]);
  const [selectedProjectId, setSelectedProjectId] = useState<string>('');
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [showDropdown, setShowDropdown] = useState(false);
  const [searchExpanded, setSearchExpanded] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);
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

  const loadProjects = async () => {
    const supabase = createClient();
    const { data, error } = await supabase
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

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (!selectedProjectId) {
    // Show WBS Builder with empty state instead of separate selector screen
    return (
      <div className="h-screen flex flex-col">
        {/* Collapsible Search Header */}
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
            
            {/* Dropdown */}
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
        
        {/* Empty State */}
        <div className="flex-1 flex items-center justify-center bg-[#F7F7F7] p-6">
          <div className="text-center max-w-md">
            <Building className="w-16 h-16 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-semibold text-gray-900 mb-2">Select a Project</h3>
            <p className="text-gray-600 mb-4">
              Use the search box above to find and select a project to manage its WBS structure
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
    <div className="h-screen flex flex-col">
      {/* Mobile Navigation Drawer */}
      {menuOpen && (
        <>
          <div 
            className="fixed inset-0 bg-black bg-opacity-50 z-40 md:hidden"
            onClick={() => setMenuOpen(false)}
          ></div>
          <div className="fixed inset-y-0 left-0 w-64 bg-white shadow-xl z-50 md:hidden">
            <div className="p-4 border-b">
              <div className="flex items-center justify-between">
                <h2 className="text-lg font-semibold text-gray-900">Menu</h2>
                <button
                  onClick={() => setMenuOpen(false)}
                  className="p-2 hover:bg-gray-100 rounded"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>
            </div>
            <nav className="p-4">
              <a href="/dashboard" className="block py-3 px-4 text-gray-700 hover:bg-gray-100 rounded mb-1">
                🏠 Dashboard
              </a>
              <a href="/erp-modules" className="block py-3 px-4 text-gray-700 hover:bg-gray-100 rounded mb-1">
                📋 Projects
              </a>
              <div className="block py-3 px-4 bg-blue-50 text-blue-700 rounded mb-1 font-medium">
                🏭 WBS Management
              </div>
              <a href="/erp-modules" className="block py-3 px-4 text-gray-700 hover:bg-gray-100 rounded mb-1">
                ⚙️ Settings
              </a>
            </nav>
          </div>
        </>
      )}

      {/* Collapsible Search Header */}
      {!searchExpanded && selectedProjectId ? (
        /* Collapsed: Compact project info with menu and search icons */
        <div className="bg-white border-b px-4 py-2 flex items-center justify-between min-h-[44px]">
          <div className="flex items-center space-x-2 flex-1 min-w-0">
            <button
              onClick={() => setMenuOpen(true)}
              className="md:hidden p-2 hover:bg-gray-100 rounded flex-shrink-0"
              title="Menu"
            >
              <Menu className="w-5 h-5 text-gray-700" />
            </button>
            <Building className="w-4 h-4 text-blue-600 flex-shrink-0" />
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
        /* Expanded: Full search box and project info */
        <>
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
              
              {/* Dropdown */}
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
          
          {/* Selected Project Info */}
          {selectedProjectId && (
            <div className="bg-white border-b px-4 py-2 flex items-center justify-between">
              <div className="flex items-center space-x-2 md:space-x-3 flex-1 min-w-0">
                <Building className="w-4 h-4 md:w-5 md:h-5 text-blue-600 flex-shrink-0" />
                <div className="flex-1 min-w-0">
                  <div className="text-sm md:text-base font-semibold text-gray-900 truncate">
                    {selectedProject?.code}
                  </div>
                  <div className="text-xs md:text-sm text-gray-600 truncate">
                    {selectedProject?.name}
                  </div>
                </div>
              </div>
              <div className="flex-shrink-0">
                <span className="px-2 py-1 rounded-full text-xs font-medium capitalize bg-blue-100 text-blue-800">
                  {selectedProject?.status}
                </span>
              </div>
            </div>
          )}
        </>
      )}
      
      <div className="flex-1 overflow-hidden">
        <WBSBuilder projectId={selectedProjectId} />
      </div>
    </div>
  );
}
