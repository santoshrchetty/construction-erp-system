'use client';

import React, { useState } from 'react';
import ProtectedRoute from '../../components/auth/ProtectedRoute';
import { useAuth } from '@/lib/contexts/AuthContext';
import ProjectDashboard from '../../components/ProjectDashboard';
import TaskBoard from '../../components/TaskBoard';
import ProjectForm from '../../components/ProjectForm';
import WBSBuilder from '../../components/WBSBuilder';
import ActivityManager from '../../components/ActivityManager';
import TaskManager from '../../components/TaskManager';
import SchedulingManager from '../../components/SchedulingManager';
import CostManager from '../../components/CostManager';

export default function EngineerDashboard() {
  const [activeTab, setActiveTab] = useState('projects');
  const [selectedProjectId, setSelectedProjectId] = useState<string>('');
  const [selectedProjectName, setSelectedProjectName] = useState<string>('');
  const [showProjectForm, setShowProjectForm] = useState(false);
  const { user, profile, signOut } = useAuth();

  const tabs = [
    { key: 'projects', label: 'Projects', icon: '📋' },
    { key: 'wbs', label: 'WBS', icon: '🏗️' },
    { key: 'activities', label: 'Activities', icon: '⚙️' },
    { key: 'tasks', label: 'Tasks', icon: '✅' },
    { key: 'schedule', label: 'Schedule', icon: '📅' },
    { key: 'costs', label: 'Costs', icon: '💰' },
    { key: 'reports', label: 'Reports', icon: '📊' }
  ];

  const handleProjectRefresh = () => {
    window.location.reload();
  };

  const handleProjectSelect = (projectId: string, projectName: string) => {
    setSelectedProjectId(projectId);
    setSelectedProjectName(projectName);
    setActiveTab('wbs'); // Auto-switch to WBS tab after selection
  };

  const handleNewProject = () => {
    setShowProjectForm(true);
  };



  const handleLogout = async () => {
    await signOut();
  };

  return (
    <ProtectedRoute allowedRoles={['Engineer', 'Admin']}>
      <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow">
        <div className="px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Engineer Dashboard</h1>
              <p className="text-gray-600">Welcome back, {user?.email}</p>
            </div>
            <div className="flex items-center space-x-4">
              <span className="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm font-medium">
                {profile?.roles?.name || 'Engineer'}
              </span>
              <button
                onClick={handleLogout}
                className="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700"
              >
                Logout
              </button>
            </div>
          </div>
        </div>
      </div>

      <nav className="bg-white border-b">
        <div className="px-4">
          <div className="flex justify-between items-center">
            <div className="flex space-x-6">
              {tabs.map((tab) => (
                <button
                  key={tab.key}
                  onClick={() => setActiveTab(tab.key)}
                  className={`py-3 px-2 border-b-2 font-medium text-sm flex items-center space-x-2 ${
                    activeTab === tab.key
                      ? 'border-blue-500 text-blue-600'
                      : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                  }`}
                >
                  <span>{tab.icon}</span>
                  <span>{tab.label}</span>
                </button>
              ))}
            </div>
            <div className="flex items-center space-x-3">
              {selectedProjectName && (
                <span className="text-sm text-gray-600 bg-gray-100 px-2 py-1 rounded">
                  {selectedProjectName}
                </span>
              )}
              {activeTab === 'projects' && (
                <button 
                  onClick={() => setShowProjectForm(true)}
                  className="bg-blue-600 text-white px-3 py-1.5 rounded text-sm hover:bg-blue-700 flex items-center space-x-1"
                >
                  <span>+</span>
                  <span>New</span>
                </button>
              )}
            </div>
          </div>
        </div>
      </nav>

      <main className="flex-1">
        {activeTab === 'projects' && (
          <ProjectDashboard 
            onProjectSelect={handleProjectSelect}
            onNewProject={handleNewProject}
          />
        )}
        {activeTab === 'wbs' && (
          <div>
            {selectedProjectId ? (
              <div>

                <WBSBuilder projectId={selectedProjectId} />
              </div>
            ) : (
              <div className="p-6 text-center py-12">
                <p className="text-gray-500 mb-4">Select a project to manage WBS</p>
                <button 
                  onClick={() => setActiveTab('projects')}
                  className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
                >
                  Go to Projects
                </button>
              </div>
            )}
          </div>
        )}
        {activeTab === 'activities' && (
          <div>
            {selectedProjectId ? (
              <div>

                <ActivityManager projectId={selectedProjectId} />
              </div>
            ) : (
              <div className="p-6 text-center py-12">
                <p className="text-gray-500 mb-4">Select a project to manage activities</p>
                <button 
                  onClick={() => setActiveTab('projects')}
                  className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
                >
                  Go to Projects
                </button>
              </div>
            )}
          </div>
        )}
        {activeTab === 'tasks' && (
          <div>
            {selectedProjectId ? (
              <div>

                <TaskManager projectId={selectedProjectId} />
              </div>
            ) : (
              <div className="p-6 text-center py-12">
                <p className="text-gray-500 mb-4">Select a project to manage tasks</p>
                <button 
                  onClick={() => setActiveTab('projects')}
                  className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
                >
                  Go to Projects
                </button>
              </div>
            )}
          </div>
        )}
        {activeTab === 'schedule' && (
          <div>
            {selectedProjectId ? (
              <div>

                <SchedulingManager projectId={selectedProjectId} />
              </div>
            ) : (
              <div className="p-6 text-center py-12">
                <p className="text-gray-500 mb-4">Select a project to manage schedule</p>
                <button 
                  onClick={() => setActiveTab('projects')}
                  className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
                >
                  Go to Projects
                </button>
              </div>
            )}
          </div>
        )}
        {activeTab === 'costs' && (
          <div>
            {selectedProjectId ? (
              <div>

                <CostManager projectId={selectedProjectId} />
              </div>
            ) : (
              <div className="p-6 text-center py-12">
                <p className="text-gray-500 mb-4">Select a project to manage costs</p>
                <button 
                  onClick={() => setActiveTab('projects')}
                  className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
                >
                  Go to Projects
                </button>
              </div>
            )}
          </div>
        )}
        {activeTab === 'reports' && (
          <div className="p-6">
            <div className="bg-white rounded-lg shadow p-8 text-center">
              <h3 className="text-lg font-medium mb-2">Reports & Analytics</h3>
              <p className="text-gray-600 mb-4">Progress reports coming soon</p>
            </div>
          </div>
        )}
      </main>

      {showProjectForm && (
        <ProjectForm
          onClose={() => setShowProjectForm(false)}
          onSuccess={handleProjectRefresh}
        />
      )}
      </div>
    </ProtectedRoute>
  );
}