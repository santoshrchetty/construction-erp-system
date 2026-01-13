'use client';

import React, { useState } from 'react';

interface Task {
  id: string;
  title: string;
  description: string;
  status: 'completed' | 'in-progress' | 'pending';
  priority: 'high' | 'medium' | 'low';
  category: 'database' | 'frontend' | 'backend' | 'integration' | 'testing';
  completedAt?: string;
  estimatedHours?: number;
  actualHours?: number;
}

export default function DailyTaskPage() {
  const [tasks] = useState<Task[]>([
    {
      id: '1',
      title: 'ERP Integration Field Length Update',
      description: 'Updated all organizational code fields to maximum lengths (31 chars) and name fields (240 chars) for seamless integration with SAP, Oracle, Dynamics, and NetSuite',
      status: 'completed',
      priority: 'high',
      category: 'database',
      completedAt: new Date().toISOString().split('T')[0],
      estimatedHours: 2,
      actualHours: 1.5
    },
    {
      id: '2',
      title: 'Storage Locations Display Fix',
      description: 'Fixed storage locations not displaying in SAP Configuration by correcting field name mapping (sloc_code, sloc_name)',
      status: 'completed',
      priority: 'medium',
      category: 'frontend',
      completedAt: new Date().toISOString().split('T')[0],
      estimatedHours: 1,
      actualHours: 0.5
    },
    {
      id: '3',
      title: 'Plant Code Validation Enhancement',
      description: 'Updated plant code validation to support 31-character codes and removed restrictive 6-character validation',
      status: 'completed',
      priority: 'medium',
      category: 'frontend',
      completedAt: new Date().toISOString().split('T')[0],
      estimatedHours: 0.5,
      actualHours: 0.5
    },
    {
      id: '4',
      title: 'Define-Then-Assign Workflow Implementation',
      description: 'Made company_code_id nullable in plants table to support SAP standard define-then-assign organizational workflow',
      status: 'completed',
      priority: 'high',
      category: 'database',
      completedAt: new Date().toISOString().split('T')[0],
      estimatedHours: 1,
      actualHours: 0.5
    },
    {
      id: '5',
      title: 'Docker Implementation',
      description: 'Add Docker containerization for development and deployment consistency',
      status: 'pending',
      priority: 'high',
      category: 'backend',
      estimatedHours: 8
    },
    {
      id: '6',
      title: 'Master Data Sync Strategy',
      description: 'Implement master data import from customer ERPs for guaranteed integration compatibility',
      status: 'pending',
      priority: 'high',
      category: 'integration',
      estimatedHours: 16
    }
  ]);

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed': return 'bg-green-100 text-green-800';
      case 'in-progress': return 'bg-yellow-100 text-yellow-800';
      case 'pending': return 'bg-gray-100 text-gray-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'high': return 'bg-red-100 text-red-800';
      case 'medium': return 'bg-orange-100 text-orange-800';
      case 'low': return 'bg-blue-100 text-blue-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getCategoryIcon = (category: string) => {
    switch (category) {
      case 'database': return '🗄️';
      case 'frontend': return '🎨';
      case 'backend': return '⚙️';
      case 'integration': return '🔗';
      case 'testing': return '🧪';
      default: return '📋';
    }
  };

  const completedTasks = tasks.filter(task => task.status === 'completed');
  const inProgressTasks = tasks.filter(task => task.status === 'in-progress');
  const pendingTasks = tasks.filter(task => task.status === 'pending');

  const totalEstimatedHours = tasks.reduce((sum, task) => sum + (task.estimatedHours || 0), 0);
  const totalActualHours = tasks.reduce((sum, task) => sum + (task.actualHours || 0), 0);

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Daily Development Tasks</h1>
          <p className="text-gray-600">Construction App - ERP Integration Progress</p>
          <div className="mt-4 grid grid-cols-1 md:grid-cols-4 gap-4">
            <div className="bg-white p-4 rounded-lg shadow">
              <div className="text-2xl font-bold text-green-600">{completedTasks.length}</div>
              <div className="text-sm text-gray-600">Completed</div>
            </div>
            <div className="bg-white p-4 rounded-lg shadow">
              <div className="text-2xl font-bold text-yellow-600">{inProgressTasks.length}</div>
              <div className="text-sm text-gray-600">In Progress</div>
            </div>
            <div className="bg-white p-4 rounded-lg shadow">
              <div className="text-2xl font-bold text-gray-600">{pendingTasks.length}</div>
              <div className="text-sm text-gray-600">Pending</div>
            </div>
            <div className="bg-white p-4 rounded-lg shadow">
              <div className="text-2xl font-bold text-blue-600">{totalActualHours}h</div>
              <div className="text-sm text-gray-600">Hours Logged</div>
            </div>
          </div>
        </div>

        {/* Task Sections */}
        <div className="space-y-8">
          {/* Completed Tasks */}
          <section>
            <h2 className="text-xl font-semibold text-gray-900 mb-4 flex items-center">
              ✅ Completed Today ({completedTasks.length})
            </h2>
            <div className="space-y-4">
              {completedTasks.map(task => (
                <div key={task.id} className="bg-white rounded-lg shadow p-6 border-l-4 border-green-500">
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center space-x-3 mb-2">
                        <span className="text-lg">{getCategoryIcon(task.category)}</span>
                        <h3 className="text-lg font-semibold text-gray-900">{task.title}</h3>
                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(task.status)}`}>
                          {task.status}
                        </span>
                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${getPriorityColor(task.priority)}`}>
                          {task.priority}
                        </span>
                      </div>
                      <p className="text-gray-600 mb-3">{task.description}</p>
                      <div className="flex items-center space-x-4 text-sm text-gray-500">
                        <span>📅 {task.completedAt}</span>
                        <span>⏱️ {task.actualHours}h / {task.estimatedHours}h</span>
                        <span>📂 {task.category}</span>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </section>

          {/* In Progress Tasks */}
          {inProgressTasks.length > 0 && (
            <section>
              <h2 className="text-xl font-semibold text-gray-900 mb-4 flex items-center">
                🔄 In Progress ({inProgressTasks.length})
              </h2>
              <div className="space-y-4">
                {inProgressTasks.map(task => (
                  <div key={task.id} className="bg-white rounded-lg shadow p-6 border-l-4 border-yellow-500">
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <div className="flex items-center space-x-3 mb-2">
                          <span className="text-lg">{getCategoryIcon(task.category)}</span>
                          <h3 className="text-lg font-semibold text-gray-900">{task.title}</h3>
                          <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(task.status)}`}>
                            {task.status}
                          </span>
                          <span className={`px-2 py-1 rounded-full text-xs font-medium ${getPriorityColor(task.priority)}`}>
                            {task.priority}
                          </span>
                        </div>
                        <p className="text-gray-600 mb-3">{task.description}</p>
                        <div className="flex items-center space-x-4 text-sm text-gray-500">
                          <span>⏱️ Est: {task.estimatedHours}h</span>
                          <span>📂 {task.category}</span>
                        </div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </section>
          )}

          {/* Pending Tasks */}
          <section>
            <h2 className="text-xl font-semibold text-gray-900 mb-4 flex items-center">
              📋 Pending ({pendingTasks.length})
            </h2>
            <div className="space-y-4">
              {pendingTasks.map(task => (
                <div key={task.id} className="bg-white rounded-lg shadow p-6 border-l-4 border-gray-300">
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center space-x-3 mb-2">
                        <span className="text-lg">{getCategoryIcon(task.category)}</span>
                        <h3 className="text-lg font-semibold text-gray-900">{task.title}</h3>
                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(task.status)}`}>
                          {task.status}
                        </span>
                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${getPriorityColor(task.priority)}`}>
                          {task.priority}
                        </span>
                      </div>
                      <p className="text-gray-600 mb-3">{task.description}</p>
                      <div className="flex items-center space-x-4 text-sm text-gray-500">
                        <span>⏱️ Est: {task.estimatedHours}h</span>
                        <span>📂 {task.category}</span>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </section>
        </div>

        {/* Summary */}
        <div className="mt-8 bg-blue-50 rounded-lg p-6">
          <h3 className="text-lg font-semibold text-blue-900 mb-4">Today's Progress Summary</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
            <div>
              <h4 className="font-medium text-blue-800 mb-2">✅ Key Achievements:</h4>
              <ul className="space-y-1 text-blue-700">
                <li>• ERP integration field lengths updated for maximum compatibility</li>
                <li>• Storage locations display issue resolved</li>
                <li>• SAP define-then-assign workflow implemented</li>
                <li>• Plant code validation enhanced for flexibility</li>
              </ul>
            </div>
            <div>
              <h4 className="font-medium text-blue-800 mb-2">🎯 Next Priorities:</h4>
              <ul className="space-y-1 text-blue-700">
                <li>• Docker implementation for deployment consistency</li>
                <li>• Master data sync strategy for ERP integration</li>
                <li>• Testing with different ERP field length scenarios</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}