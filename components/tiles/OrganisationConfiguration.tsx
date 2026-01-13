'use client'

import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'

export default function OrganisationConfiguration() {
  const [activeTab, setActiveTab] = useState('manage')
  const [selectedObjectType, setSelectedObjectType] = useState('company')
  const [data, setData] = useState({
    companyCodes: [],
    controllingAreas: [],
    plants: [],
    costCenters: [],
    profitCenters: [],
    purchasingOrgs: [],
    storageLocations: [],
    departments: []
  })
  const [loading, setLoading] = useState(true)

  const tabs = [
    { id: 'manage', name: 'Manage Objects', icon: '🏗️' },
    { id: 'hierarchy', name: 'View Hierarchy', icon: '🌳' },
    { id: 'assignments', name: 'Assignments', icon: '🔗' }
  ]

  const objectTypes = [
    { id: 'company', name: 'Company Codes', icon: '🏢' },
    { id: 'controlling', name: 'Controlling Areas', icon: '📊' },
    { id: 'plant', name: 'Plants', icon: '🏭' },
    { id: 'cost_center', name: 'Cost Centers', icon: '💰' },
    { id: 'profit_center', name: 'Profit Centers', icon: '📈' },
    { id: 'storage', name: 'Storage Locations', icon: '📦' },
    { id: 'purchasing', name: 'Purchasing Orgs', icon: '🛒' },
    { id: 'department', name: 'Departments', icon: '🏛️' }
  ]

  useEffect(() => {
    fetchOrganisationData()
  }, [])

  // Layer 2: API Communication following proper SAP config architecture
  const fetchOrganisationData = async () => {
    setLoading(true)
    try {
      const response = await fetch('/api/org-config')
      const result = await response.json()
      if (result.success) {
        setData(result.data)
      }
    } catch (error) {
      console.error('Error fetching organisation data:', error)
    } finally {
      setLoading(false)
    }
  }

  const getDataForType = (type: string) => {
    switch (type) {
      case 'company': return data.companyCodes
      case 'controlling': return data.controllingAreas
      case 'plant': return data.plants
      case 'cost_center': return data.costCenters
      case 'profit_center': return data.profitCenters
      case 'storage': return data.storageLocations
      case 'purchasing': return data.purchasingOrgs
      case 'department': return data.departments
      default: return []
    }
  }

  const renderManageObjects = () => (
    <div className="flex flex-col lg:flex-row gap-6">
      <div className="lg:w-48">
        <div className="lg:hidden">
          <select
            value={selectedObjectType}
            onChange={(e) => setSelectedObjectType(e.target.value)}
            className="w-full px-3 py-2 border rounded-lg"
          >
            {objectTypes.map(type => (
              <option key={type.id} value={type.id}>
                {type.icon} {type.name}
              </option>
            ))}
          </select>
        </div>

        <div className="hidden lg:block">
          <h3 className="font-semibold mb-4">Object Types</h3>
          <div className="space-y-1">
            {objectTypes.map(type => (
              <button
                key={type.id}
                onClick={() => setSelectedObjectType(type.id)}
                className={`w-full text-left px-3 py-2 rounded-lg flex items-center space-x-3 ${
                  selectedObjectType === type.id
                    ? 'bg-blue-100 text-blue-700'
                    : 'hover:bg-gray-100'
                }`}
              >
                <span>{type.icon}</span>
                <span className="text-sm">{type.name}</span>
              </button>
            ))}
          </div>
        </div>
      </div>

      <div className="flex-1">
        <div className="bg-white rounded-lg shadow">
          <div className="p-4 border-b flex justify-between items-center">
            <h3 className="font-semibold">
              {objectTypes.find(t => t.id === selectedObjectType)?.name}
            </h3>
            <button
              className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
              disabled={loading}
            >
              Add New
            </button>
          </div>
          
          <div className="p-4">
            {loading ? (
              <div className="text-center py-8">Loading...</div>
            ) : (
              <ObjectTable 
                data={getDataForType(selectedObjectType)}
                objectType={selectedObjectType}
              />
            )}
          </div>
        </div>
      </div>
    </div>
  )

  const renderContent = () => {
    switch (activeTab) {
      case 'manage': return renderManageObjects()
      case 'assignments': return <div className="p-8 text-center text-gray-500">Assignments functionality</div>
      default: return renderManageObjects()
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading Organisation Configuration...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="container mx-auto px-4 py-6">
        <div className="flex space-x-1 mb-6 bg-gray-100 p-1 rounded-lg">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`flex items-center space-x-2 px-4 py-2 rounded-md text-sm font-medium ${
                activeTab === tab.id
                  ? 'bg-white text-blue-600 shadow-sm'
                  : 'text-gray-600 hover:text-gray-900'
              }`}
            >
              <span>{tab.icon}</span>
              <span>{tab.name}</span>
            </button>
          ))}
        </div>

        {renderContent()}
      </div>
    </div>
  )
}

const ObjectTable = ({ data, objectType }) => {
  if (!data || data.length === 0) {
    return (
      <div className="text-center py-8 text-gray-500">
        <p>No items found.</p>
      </div>
    )
  }

  return (
    <div className="overflow-x-auto">
      <table className="w-full">
        <thead className="bg-gray-50">
          <tr>
            <th className="px-4 py-3 text-left">Code</th>
            <th className="px-4 py-3 text-left">Name</th>
            <th className="px-4 py-3 text-left">Actions</th>
          </tr>
        </thead>
        <tbody>
          {data.map((item, index) => (
            <tr key={item.id || index} className="border-t hover:bg-gray-50">
              <td className="px-4 py-3 font-mono text-sm">
                {getItemCode(item, objectType)}
              </td>
              <td className="px-4 py-3">
                {getItemName(item, objectType)}
              </td>
              <td className="px-4 py-3">
                <button className="text-blue-600 hover:text-blue-800">
                  Edit
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}

function getItemCode(item: any, objectType: string) {
  const codeMap = {
    company: 'company_code',
    plant: 'plant_code',
    storage: 'sloc_code',
    controlling: 'cocarea_code',
    cost_center: 'cost_center_code',
    profit_center: 'profit_center_code',
    purchasing: 'porg_code',
    department: 'code'
  }
  return item[codeMap[objectType]] || ''
}

function getItemName(item: any, objectType: string) {
  const nameMap = {
    company: 'company_name',
    plant: 'plant_name',
    storage: 'sloc_name',
    controlling: 'cocarea_name',
    cost_center: 'cost_center_name',
    profit_center: 'profit_center_name',
    purchasing: 'porg_name',
    department: 'name'
  }
  return item[nameMap[objectType]] || ''
}