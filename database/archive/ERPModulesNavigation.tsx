// DEPRECATED: This file is marked for removal - no active dependencies found
// TODO: Remove after confirming no imports
/*
'use client'

import React, { useState } from 'react'
import { Package, DollarSign, FolderTree, Users, Settings, Building, Database } from 'lucide-react'
import MaterialsManagementModule from './MaterialsManagementModule'
import MaterialManagementModuleImproved from './MaterialManagementModuleImproved'
import FinanceControllingModule from './FinanceControllingModule'
import ERPConfigurationModuleComplete from './ERPConfigurationModuleComplete'

interface Module {
  id: string
  name: string
  description: string
  icon: React.ComponentType<any>
  color: string
  available: boolean
}

export default function ERPModulesNavigation() {
  const [activeModule, setActiveModule] = useState<string | null>(null)

  const modules: Module[] = [
    {
      id: 'configuration',
      name: 'ERP Configuration',
      description: 'System Configuration & Reference Data',
      icon: Database,
      color: 'indigo',
      available: true
    },
    {
      id: 'materials',
      name: 'Material Management',
      description: 'Materials, Purchasing & Inventory',
      icon: Package,
      color: 'blue',
      available: true
    },
    {
      id: 'finance',
      name: 'Finance & Controlling',
      description: 'GL Accounts, Valuation & Cost Centers',
      icon: DollarSign,
      color: 'green',
      available: true
    },
    {
      id: 'projects',
      name: 'Project System',
      description: 'Project Management & WBS',
      icon: FolderTree,
      color: 'purple',
      available: false
    },
    {
      id: 'hr',
      name: 'Human Resources',
      description: 'Personnel & Payroll',
      icon: Users,
      color: 'orange',
      available: false
    },
    {
      id: 'organization',
      name: 'Organizational Structure',
      description: 'Company Codes, Plants & Storage',
      icon: Building,
      color: 'indigo',
      available: false
    }
  ]

  const getColorClasses = (color: string, available: boolean) => {
    if (!available) {
      return {
        bg: 'bg-gray-100',
        border: 'border-gray-200',
        text: 'text-gray-400',
        icon: 'text-gray-300',
        hover: 'cursor-not-allowed'
      }
    }

    const colorMap = {
      blue: {
        bg: 'bg-blue-50',
        border: 'border-blue-200',
        text: 'text-blue-900',
        icon: 'text-blue-600',
        hover: 'hover:bg-blue-100 cursor-pointer'
      },
      green: {
        bg: 'bg-green-50',
        border: 'border-green-200',
        text: 'text-green-900',
        icon: 'text-green-600',
        hover: 'hover:bg-green-100 cursor-pointer'
      },
      purple: {
        bg: 'bg-purple-50',
        border: 'border-purple-200',
        text: 'text-purple-900',
        icon: 'text-purple-600',
        hover: 'hover:bg-purple-100 cursor-pointer'
      },
      orange: {
        bg: 'bg-orange-50',
        border: 'border-orange-200',
        text: 'text-orange-900',
        icon: 'text-orange-600',
        hover: 'hover:bg-orange-100 cursor-pointer'
      },
      indigo: {
        bg: 'bg-indigo-50',
        border: 'border-indigo-200',
        text: 'text-indigo-900',
        icon: 'text-indigo-600',
        hover: 'hover:bg-indigo-100 cursor-pointer'
      },
      gray: {
        bg: 'bg-gray-50',
        border: 'border-gray-200',
        text: 'text-gray-900',
        icon: 'text-gray-600',
        hover: 'hover:bg-gray-100 cursor-pointer'
      }
    }

    return colorMap[color as keyof typeof colorMap] || colorMap.gray
  }

  const handleModuleClick = (moduleId: string, available: boolean) => {
    if (available) {
      setActiveModule(moduleId)
    }
  }

  const renderModuleContent = () => {
    switch (activeModule) {
      case 'configuration':
        return <ERPConfigurationModuleComplete />
      case 'materials':
        return <MaterialsManagementModule />
      case 'finance':
        return <FinanceControllingModule />
      default:
        return null
    }
  }

  if (activeModule) {
    return (
      <div>
        <div className="fixed top-4 left-4 z-50">
          <button
            onClick={() => setActiveModule(null)}
            className="px-4 py-2 bg-white border border-gray-300 rounded-lg shadow-sm hover:bg-gray-50 transition-colors"
          >
            ← Back
          </button>
        </div>
        {renderModuleContent()}
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-gray-100 p-4">
      <div className="max-w-6xl mx-auto">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">ERP System Modules</h1>
          <p className="text-xl text-gray-600">Select a module to access its functionality</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {modules.map((module) => {
            const Icon = module.icon
            const colors = getColorClasses(module.color, module.available)
            
            return (
              <div
                key={module.id}
                onClick={() => handleModuleClick(module.id, module.available)}
                className={`
                  relative p-6 rounded-xl border-2 transition-all duration-200 transform
                  ${colors.bg} ${colors.border} ${colors.hover}
                  ${module.available ? 'hover:scale-105 hover:shadow-lg' : ''}
                `}
              >
                {!module.available && (
                  <div className="absolute top-2 right-2">
                    <span className="px-2 py-1 bg-yellow-100 text-yellow-800 text-xs rounded-full">
                      Coming Soon
                    </span>
                  </div>
                )}
                
                <div className="flex items-center mb-4">
                  <Icon className={`w-8 h-8 ${colors.icon}`} />
                  <h3 className={`text-xl font-semibold ml-3 ${colors.text}`}>
                    {module.name}
                  </h3>
                </div>
                
                <p className={`${colors.text} opacity-80`}>
                  {module.description}
                </p>
                
                {module.available && (
                  <div className="mt-4 flex justify-end">
                    <span className={`text-sm font-medium ${colors.text}`}>
                      Click to access →
                    </span>
                  </div>
                )}
              </div>
            )
          })}
        </div>

        <div className="mt-12 text-center">
          <div className="bg-white rounded-lg shadow-sm border p-6">
            <h2 className="text-2xl font-semibold text-gray-900 mb-4">Module Status</h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
              <div className="flex items-center justify-center gap-2">
                <div className="w-3 h-3 bg-green-500 rounded-full"></div>
                <span>Available: {modules.filter(m => m.available).length} modules</span>
              </div>
              <div className="flex items-center justify-center gap-2">
                <div className="w-3 h-3 bg-yellow-500 rounded-full"></div>
                <span>Coming Soon: {modules.filter(m => !m.available).length} modules</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
*/