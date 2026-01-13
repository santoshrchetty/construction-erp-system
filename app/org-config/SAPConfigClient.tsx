'use client';

import React, { useState } from 'react';

// Layer 1: Presentation Layer - Client Component
export default function OrganisationConfigClient({ initialData, user }) {
  const [activeTab, setActiveTab] = useState('manage');
  const [selectedObjectType, setSelectedObjectType] = useState('company');
  const [data, setData] = useState(initialData);
  const [loading, setLoading] = useState(false);

  const tabs = [
    { id: 'manage', name: 'Manage Objects', icon: '🏗️' },
    { id: 'hierarchy', name: 'View Hierarchy', icon: '🌳' },
    { id: 'assignments', name: 'Assignments', icon: '🔗' }
  ];

  const objectTypes = [
    { id: 'company', name: 'Company Codes', icon: '🏢' },
    { id: 'controlling', name: 'Controlling Areas', icon: '📊' },
    { id: 'plant', name: 'Plants', icon: '🏭' },
    { id: 'cost_center', name: 'Cost Centers', icon: '💰' },
    { id: 'profit_center', name: 'Profit Centers', icon: '📈' },
    { id: 'storage', name: 'Storage Locations', icon: '📦' },
    { id: 'purchasing', name: 'Purchasing Orgs', icon: '🛒' },
    { id: 'department', name: 'Departments', icon: '🏛️' }
  ];

  // Layer 2: API Communication
  const refreshData = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/sap-config');
      const result = await response.json();
      if (result.success) {
        setData(result.data);
      }
    } catch (error) {
      console.error('Error refreshing data:', error);
    } finally {
      setLoading(false);
    }
  };

  const createObject = async (objectType: string, objectData: any) => {
    setLoading(true);
    try {
      const response = await fetch('/api/sap-config', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'create',
          objectType,
          data: objectData
        })
      });
      
      const result = await response.json();
      if (result.success) {
        await refreshData();
        return result.data;
      } else {
        throw new Error(result.error);
      }
    } catch (error) {
      console.error('Error creating object:', error);
      throw error;
    } finally {
      setLoading(false);
    }
  };

  const updateObject = async (objectType: string, objectData: any) => {
    setLoading(true);
    try {
      const response = await fetch('/api/sap-config', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'update',
          objectType,
          data: objectData
        })
      });
      
      const result = await response.json();
      if (result.success) {
        await refreshData();
        return result.data;
      } else {
        throw new Error(result.error);
      }
    } catch (error) {
      console.error('Error updating object:', error);
      throw error;
    } finally {
      setLoading(false);
    }
  };

  const assignObjects = async (assignmentData: any) => {
    setLoading(true);
    try {
      const response = await fetch('/api/sap-config', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'assign',
          data: assignmentData
        })
      });
      
      const result = await response.json();
      if (result.success) {
        await refreshData();
        return result.data;
      } else {
        throw new Error(result.error);
      }
    } catch (error) {
      console.error('Error assigning objects:', error);
      throw error;
    } finally {
      setLoading(false);
    }
  };

  const getDataForType = (type: string) => {
    switch (type) {
      case 'company': return data.companyCodes;
      case 'controlling': return data.controllingAreas;
      case 'plant': return data.plants;
      case 'cost_center': return data.costCenters;
      case 'profit_center': return data.profitCenters;
      case 'storage': return data.storageLocations;
      case 'purchasing': return data.purchasingOrgs;
      case 'department': return data.departments;
      default: return [];
    }
  };

  const renderManageObjects = () => (
    <div className="flex flex-col lg:flex-row gap-6">
      {/* Object Type Selector */}
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

      {/* Object List */}
      <div className="flex-1">
        <div className="bg-white rounded-lg shadow">
          <div className="p-4 border-b flex justify-between items-center">
            <h3 className="font-semibold">
              {objectTypes.find(t => t.id === selectedObjectType)?.name}
            </h3>
            <button
              onClick={() => {/* Handle add new */}}
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
                onEdit={(item) => {/* Handle edit */}}
              />
            )}
          </div>
        </div>
      </div>
    </div>
  );

  const renderAssignments = () => (
    <div className="space-y-6">
      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="text-lg font-semibold mb-4">Organizational Assignments</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <AssignmentCard
            title="Company → Controlling Area"
            parentData={data.companyCodes}
            childData={data.controllingAreas}
            onAssign={assignObjects}
          />
          <AssignmentCard
            title="Plant → Company"
            parentData={data.plants}
            childData={data.companyCodes}
            onAssign={assignObjects}
          />
        </div>
      </div>
    </div>
  );

  const renderContent = () => {
    switch (activeTab) {
      case 'manage': return renderManageObjects();
      case 'assignments': return renderAssignments();
      default: return renderManageObjects();
    }
  };

  return (
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
  );
}

// Helper Components
const ObjectTable = ({ data, objectType, onEdit }) => {
  if (!data || data.length === 0) {
    return (
      <div className="text-center py-8 text-gray-500">
        <p>No items found.</p>
      </div>
    );
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
                <button 
                  onClick={() => onEdit(item)}
                  className="text-blue-600 hover:text-blue-800"
                >
                  Edit
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

const AssignmentCard = ({ title, parentData, childData, onAssign }) => (
  <div className="border rounded-lg p-4">
    <h4 className="font-medium mb-2">{title}</h4>
    <div className="space-y-2 max-h-40 overflow-y-auto">
      {parentData.slice(0, 5).map(item => (
        <div key={item.id} className="flex justify-between items-center text-sm">
          <span>{getItemCode(item, 'company')}</span>
          <span>→</span>
          <span>Assigned</span>
        </div>
      ))}
    </div>
  </div>
);

// Helper functions
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
  };
  return item[codeMap[objectType]] || '';
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
  };
  return item[nameMap[objectType]] || '';
}