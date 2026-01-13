'use client';

import React, { useState } from 'react';
import { Settings, Database, Users, Shield, FileText, BarChart3 } from 'lucide-react';
import { NumberRangeMaintenance } from '../../components/tiles/NumberRangeMaintenance';

const ERPConfigurationPage: React.FC = () => {
  const [activeModule, setActiveModule] = useState('number-ranges');

  const configModules = [
    {
      id: 'number-ranges',
      name: 'Number Range Maintenance',
      description: 'Configure document number ranges and monitor usage',
      icon: Database,
      component: NumberRangeMaintenance
    },
    {
      id: 'master-data',
      name: 'Master Data Configuration',
      description: 'Manage cost centers, profit centers, and organizational units',
      icon: FileText,
      component: () => <div className="p-8 text-center text-gray-500">Master Data Configuration - Coming Soon</div>
    },
    {
      id: 'user-management',
      name: 'User & Role Management',
      description: 'Configure user access and authorization objects',
      icon: Users,
      component: () => <div className="p-8 text-center text-gray-500">User Management - Coming Soon</div>
    },
    {
      id: 'security',
      name: 'Security Configuration',
      description: 'Manage security policies and access controls',
      icon: Shield,
      component: () => <div className="p-8 text-center text-gray-500">Security Configuration - Coming Soon</div>
    },
    {
      id: 'reporting',
      name: 'Reporting Configuration',
      description: 'Configure financial reports and analytics',
      icon: BarChart3,
      component: () => <div className="p-8 text-center text-gray-500">Reporting Configuration - Coming Soon</div>
    }
  ];

  const ActiveComponent = configModules.find(module => module.id === activeModule)?.component || (() => null);

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center space-x-3">
              <Settings className="w-8 h-8 text-blue-600" />
              <div>
                <h1 className="text-xl font-semibold text-gray-900">ERP Configuration</h1>
                <p className="text-sm text-gray-500">Enterprise Resource Planning System Configuration</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        <div className="flex flex-col lg:flex-row gap-6">
          {/* Sidebar Navigation */}
          <div className="lg:w-64 flex-shrink-0">
            <div className="bg-white rounded-lg shadow-sm border border-gray-200">
              <div className="p-4 border-b border-gray-200">
                <h3 className="text-sm font-medium text-gray-900">Configuration Modules</h3>
              </div>
              <nav className="p-2">
                {configModules.map((module) => {
                  const Icon = module.icon;
                  return (
                    <button
                      key={module.id}
                      onClick={() => setActiveModule(module.id)}
                      className={`w-full text-left p-3 rounded-md transition-colors mb-1 ${
                        activeModule === module.id
                          ? 'bg-blue-50 text-blue-700 border-l-4 border-blue-600'
                          : 'text-gray-700 hover:bg-gray-50'
                      }`}
                    >
                      <div className="flex items-center space-x-3">
                        <Icon className={`w-5 h-5 ${activeModule === module.id ? 'text-blue-600' : 'text-gray-400'}`} />
                        <div className="flex-1 min-w-0">
                          <p className="text-sm font-medium truncate">{module.name}</p>
                          <p className="text-xs text-gray-500 truncate">{module.description}</p>
                        </div>
                      </div>
                    </button>
                  );
                })}
              </nav>
            </div>
          </div>

          {/* Main Content */}
          <div className="flex-1">
            <ActiveComponent />
          </div>
        </div>
      </div>
    </div>
  );
};

export default ERPConfigurationPage;