'use client';

import React, { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase/client';
import * as Icons from 'lucide-react';

export default function SAPOrganizationalConfig() {
  const [activeTab, setActiveTab] = useState('define');
  const [selectedObjectType, setSelectedObjectType] = useState('company');
  const [showModal, setShowModal] = useState(false);
  const [editingItem, setEditingItem] = useState(null);
  
  // Data states
  const [companyCodes, setCompanyCodes] = useState([]);
  const [controllingAreas, setControllingAreas] = useState([]);
  const [plants, setPlants] = useState([]);
  const [costCenters, setCostCenters] = useState([]);
  const [profitCenters, setProfitCenters] = useState([]);
  const [storageLocations, setStorageLocations] = useState([]);
  const [departments, setDepartments] = useState([]);

  const tabs = [
    { id: 'define', name: 'Define Objects', icon: '🏗️', description: 'Create organizational objects' },
    { id: 'assign', name: 'Assign Objects', icon: '🔗', description: 'Link objects together' },
    { id: 'hierarchy', name: 'View Hierarchy', icon: '🌳', description: 'Organizational structure' }
  ];

  const objectTypes = [
    { id: 'company', name: 'Company Codes', icon: '🏢', table: 'company_codes' },
    { id: 'controlling', name: 'Controlling Areas', icon: '📊', table: 'controlling_areas' },
    { id: 'plant', name: 'Plants', icon: '🏭', table: 'plants' },
    { id: 'cost_center', name: 'Cost Centers', icon: '💰', table: 'cost_centers' },
    { id: 'profit_center', name: 'Profit Centers', icon: '📈', table: 'profit_centers' },
    { id: 'storage', name: 'Storage Locations', icon: '📦', table: 'storage_locations' },
    { id: 'department', name: 'Departments', icon: '🏛️', table: 'departments' }
  ];

  useEffect(() => {
    fetchAllData();
  }, []);

  const fetchAllData = async () => {
    const [companies, controlling, plantsData, costs, profits, storageData, departmentsData] = await Promise.all([
      supabase.from('company_codes').select('*').order('company_code'),
      supabase.from('controlling_areas').select('*').order('cocarea_code'),
      supabase.from('plants').select('*').order('plant_code'),
      supabase.from('cost_centers').select('*').order('cost_center_code'),
      supabase.from('profit_centers').select('*').order('profit_center_code'),
      supabase.from('storage_locations').select('*').order('sloc_code'),
      supabase.from('departments').select('*').order('name')
    ]);

    if (companies.data) setCompanyCodes(companies.data);
    if (controlling.data) setControllingAreas(controlling.data);
    if (plantsData.data) setPlants(plantsData.data);
    if (costs.data) setCostCenters(costs.data);
    if (profits.data) setProfitCenters(profits.data);
    if (storageData.data) setStorageLocations(storageData.data);
    if (departmentsData.data) setDepartments(departmentsData.data);
  };

  // Tab 1: Define Objects
  const renderDefineObjects = () => (
    <div className="space-y-6">
      {/* Object Type Selector */}
      <div className="bg-white rounded-lg shadow p-4">
        <h3 className="font-semibold mb-4">Select Object Type</h3>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          {objectTypes.map(type => (
            <button
              key={type.id}
              onClick={() => setSelectedObjectType(type.id)}
              className={`p-3 rounded-lg border text-center transition-colors ${
                selectedObjectType === type.id
                  ? 'bg-blue-100 border-blue-300 text-blue-700'
                  : 'bg-gray-50 border-gray-200 hover:bg-gray-100'
              }`}
            >
              <div className="text-2xl mb-1">{type.icon}</div>
              <div className="text-sm font-medium">{type.name}</div>
            </button>
          ))}
        </div>
      </div>

      {/* CRUD Interface */}
      <div className="bg-white rounded-lg shadow">
        <div className="p-4 border-b flex justify-between items-center">
          <h3 className="font-semibold">
            {objectTypes.find(t => t.id === selectedObjectType)?.name || 'Objects'}
          </h3>
          <button
            onClick={() => {
              setEditingItem(null);
              setShowModal(true);
            }}
            className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 flex items-center"
          >
            <Icons.Plus className="w-4 h-4 mr-2" />
            Add New
          </button>
        </div>
        
        <ObjectList objectType={selectedObjectType} />
      </div>
    </div>
  );

  // Tab 2: Assign Objects
  const renderAssignObjects = () => (
    <div className="space-y-6">
      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="font-semibold mb-4">Organizational Assignments</h3>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Company → Controlling Area */}
          <div className="border rounded-lg p-4">
            <h4 className="font-medium mb-2">Company → Controlling Area</h4>
            <p className="text-sm text-gray-600 mb-4">Assign companies to controlling areas</p>
            <div className="space-y-2">
              {companyCodes.map(company => (
                <div key={company.company_code} className="flex items-center justify-between p-2 bg-gray-50 rounded">
                  <span className="text-sm">{company.company_code} - {company.company_name}</span>
                  <select 
                    className="text-sm border rounded px-2 py-1"
                    value={company.controlling_area_code || ''}
                    onChange={(e) => handleAssignment('company_codes', 'company_code', company.company_code, 'controlling_area_code', e.target.value)}
                  >
                    <option value="">Select...</option>
                    {controllingAreas.map(ca => (
                      <option key={ca.cocarea_code} value={ca.cocarea_code}>
                        {ca.cocarea_code} - {ca.cocarea_name}
                      </option>
                    ))}
                  </select>
                </div>
              ))}
            </div>
          </div>

          {/* Plant → Company */}
          <div className="border rounded-lg p-4">
            <h4 className="font-medium mb-2">Plant → Company</h4>
            <p className="text-sm text-gray-600 mb-4">Assign plants to companies</p>
            <div className="space-y-2">
              {plants.map(plant => (
                <div key={plant.plant_code} className="flex items-center justify-between p-2 bg-gray-50 rounded">
                  <span className="text-sm">{plant.plant_code} - {plant.plant_name}</span>
                  <select 
                    className="text-sm border rounded px-2 py-1"
                    value={plant.company_code || ''}
                    onChange={(e) => handleAssignment('plants', 'plant_code', plant.plant_code, 'company_code', e.target.value)}
                  >
                    <option value="">Select...</option>
                    {companyCodes.map(company => (
                      <option key={company.company_code} value={company.company_code}>
                        {company.company_code} - {company.company_name}
                      </option>
                    ))}
                  </select>
                </div>
              ))}
            </div>
          </div>

          {/* Department → Company */}
          <div className="border rounded-lg p-4">
            <h4 className="font-medium mb-2">Department → Company</h4>
            <p className="text-sm text-gray-600 mb-4">Assign departments to companies</p>
            <div className="space-y-2">
              {departments.map(dept => (
                <div key={dept.id} className="flex items-center justify-between p-2 bg-gray-50 rounded">
                  <span className="text-sm">{dept.code} - {dept.name}</span>
                  <select 
                    className="text-sm border rounded px-2 py-1"
                    value={dept.company_code || ''}
                    onChange={(e) => handleAssignment('departments', 'id', dept.id, 'company_code', e.target.value)}
                  >
                    <option value="">Select...</option>
                    {companyCodes.map(company => (
                      <option key={company.company_code} value={company.company_code}>
                        {company.company_code} - {company.company_name}
                      </option>
                    ))}
                  </select>
                </div>
              ))}
            </div>
          </div>

          {/* Storage Location → Plant */}
          <div className="border rounded-lg p-4">
            <h4 className="font-medium mb-2">Storage Location → Plant</h4>
            <p className="text-sm text-gray-600 mb-4">Assign storage locations to plants</p>
            <div className="space-y-2">
              {storageLocations.map(storage => (
                <div key={storage.id} className="flex items-center justify-between p-2 bg-gray-50 rounded">
                  <span className="text-sm">{storage.sloc_code} - {storage.sloc_name}</span>
                  <select 
                    className="text-sm border rounded px-2 py-1"
                    value={storage.plant_code || ''}
                    onChange={(e) => handleAssignment('storage_locations', 'id', storage.id, 'plant_code', e.target.value)}
                  >
                    <option value="">Select...</option>
                    {plants.map(plant => (
                      <option key={plant.plant_code} value={plant.plant_code}>
                        {plant.plant_code} - {plant.plant_name}
                      </option>
                    ))}
                  </select>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );

  // Tab 3: View Hierarchy
  const renderViewHierarchy = () => (
    <div className="bg-white rounded-lg shadow p-6">
      <h3 className="font-semibold mb-4">Organizational Hierarchy</h3>
      <div className="space-y-2">
        {companyCodes.map(company => (
          <HierarchyNode key={company.company_code} company={company} />
        ))}
      </div>
    </div>
  );

  const ObjectList = ({ objectType }) => {
    const getData = () => {
      switch (objectType) {
        case 'company': return companyCodes;
        case 'controlling': return controllingAreas;
        case 'plant': return plants;
        case 'cost_center': return costCenters;
        case 'profit_center': return profitCenters;
        case 'storage': return storageLocations;
        case 'department': return departments;
        default: return [];
      }
    };

    const data = getData();

    return (
      <div className="divide-y">
        {data.map((item, index) => (
          <div key={index} className="p-4 hover:bg-gray-50 flex justify-between items-center">
            <div>
              <div className="font-medium">
                {item.company_code || item.cocarea_code || item.plant_code || item.cost_center_code || item.profit_center_code || item.sloc_code || item.code}
                {' - '}
                {item.company_name || item.cocarea_name || item.plant_name || item.cost_center_name || item.profit_center_name || item.sloc_name || item.name}
              </div>
              <div className="text-sm text-gray-600">
                {item.currency || item.fiscal_year_variant || item.address || item.cost_center_category || item.description}
              </div>
            </div>
            <div className="flex space-x-2">
              <button 
                onClick={() => {
                  setEditingItem(item);
                  setShowModal(true);
                }}
                className="text-blue-600 hover:text-blue-800"
              >
                <Icons.Edit className="w-4 h-4" />
              </button>
              <button className="text-red-600 hover:text-red-800">
                <Icons.Trash2 className="w-4 h-4" />
              </button>
            </div>
          </div>
        ))}
      </div>
    );
  };

  const HierarchyNode = ({ company }) => (
    <div className="border rounded-lg p-3">
      <div className="font-medium text-blue-700">
        🏢 {company.company_code} - {company.company_name}
      </div>
      {company.controlling_area_code && (
        <div className="ml-4 mt-2 text-sm">
          📊 Controlling Area: {company.controlling_area_code}
        </div>
      )}
      <div className="ml-4 mt-2 space-y-1">
        {plants.filter(p => p.company_code === company.company_code).map(plant => (
          <div key={plant.plant_code} className="text-sm">
            🏭 {plant.plant_code} - {plant.plant_name}
            <div className="ml-4 space-y-1">
              {storageLocations.filter(sl => sl.plant_code === plant.plant_code).map(storage => (
                <div key={storage.id} className="text-xs text-gray-600">
                  📦 {storage.sloc_code} - {storage.sloc_name}
                </div>
              ))}
            </div>
          </div>
        ))}
        {departments.filter(d => d.company_code === company.company_code).map(dept => (
          <div key={dept.id} className="text-sm">
            🏛️ {dept.code} - {dept.name}
          </div>
        ))}
      </div>
    </div>
  );

  const handleAssignment = async (table, idField, idValue, assignField, assignValue) => {
    try {
      const { error } = await supabase
        .from(table)
        .update({ [assignField]: assignValue })
        .eq(idField, idValue);
      
      if (error) throw error;
      await fetchAllData();
    } catch (error) {
      console.error('Assignment error:', error);
      alert('Failed to update assignment');
    }
  };

  const renderContent = () => {
    switch (activeTab) {
      case 'define': return renderDefineObjects();
      case 'assign': return renderAssignObjects();
      case 'hierarchy': return renderViewHierarchy();
      default: return renderDefineObjects();
    }
  };

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold">SAP Organizational Configuration</h1>
        <p className="text-gray-600">Define, assign, and view your organizational structure</p>
      </div>

      {/* Tab Navigation */}
      <div className="flex space-x-1 mb-6 bg-gray-100 p-1 rounded-lg">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            className={`flex-1 flex items-center justify-center space-x-2 px-4 py-3 rounded-md text-sm font-medium transition-colors ${
              activeTab === tab.id
                ? 'bg-white text-blue-600 shadow-sm'
                : 'text-gray-600 hover:text-gray-900'
            }`}
          >
            <span>{tab.icon}</span>
            <div className="text-left">
              <div>{tab.name}</div>
              <div className="text-xs text-gray-500">{tab.description}</div>
            </div>
          </button>
        ))}
      </div>

      {renderContent()}
    </div>
  );
}