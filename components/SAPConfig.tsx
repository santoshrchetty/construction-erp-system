'use client';

import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase-simple';

export default function SAPConfig() {
  const [activeTab, setActiveTab] = useState('company');
  const [companyCodes, setCompanyCodes] = useState<any[]>([]);
  const [controllingAreas, setControllingAreas] = useState<any[]>([]);
  const [costCenters, setCostCenters] = useState<any[]>([]);
  const [profitCenters, setProfitCenters] = useState<any[]>([]);
  const [purchasingOrgs, setPurchasingOrgs] = useState<any[]>([]);
  const [plants, setPlants] = useState<any[]>([]);
  const [storageLocations, setStorageLocations] = useState<any[]>([]);

  useEffect(() => {
    fetchAllData();
  }, []);

  const fetchAllData = async () => {
    const [companies, controlling, costs, profits, purchasing, plantsData, storageData] = await Promise.all([
      supabase.from('company_codes').select('*').order('company_code'),
      supabase.from('controlling_areas').select('*').order('cocarea_code'),
      supabase.from('cost_centers').select('*, company:company_codes(company_name)').order('cost_center_code'),
      supabase.from('profit_centers').select('*, controlling_area:controlling_areas(cocarea_name)').order('profit_center_code'),
      supabase.from('purchasing_organizations').select('*, company:company_codes(company_name)').order('porg_code'),
      supabase.from('plants').select('*, company:company_codes!company_code_id(company_code, company_name)').order('plant_code'),
      supabase.from('storage_locations').select('*, plant:plants(plant_name)').order('storage_location_code')
    ]);

    if (companies.data) setCompanyCodes(companies.data);
    if (controlling.data) setControllingAreas(controlling.data);
    if (costs.data) setCostCenters(costs.data);
    if (profits.data) setProfitCenters(profits.data);
    if (purchasing.data) setPurchasingOrgs(purchasing.data);
    if (plantsData.data) setPlants(plantsData.data);
    if (storageData.data) setStorageLocations(storageData.data);
  };

  const tabs = [
    { id: 'company', name: 'Company Codes', icon: '🏢' },
    { id: 'controlling', name: 'Controlling Areas', icon: '📊' },
    { id: 'cost', name: 'Cost Centers', icon: '💰' },
    { id: 'profit', name: 'Profit Centers', icon: '📈' },
    { id: 'purchasing', name: 'Purchasing Orgs', icon: '🛒' },
    { id: 'plants', name: 'Plants', icon: '🏭' },
    { id: 'storage', name: 'Storage Locations', icon: '📦' },
    { id: 'assignments', name: 'Assignments', icon: '🔗' }
  ];

  const renderCompanyCodes = () => (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold">Company Codes (Legal Entities)</h3>
        <button className="bg-blue-600 text-white px-4 py-2 rounded text-sm">Add Company</button>
      </div>
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left">Code</th>
              <th className="px-4 py-3 text-left">Company Name</th>
              <th className="px-4 py-3 text-left">Legal Entity</th>
              <th className="px-4 py-3 text-left">Currency</th>
              <th className="px-4 py-3 text-left">Status</th>
            </tr>
          </thead>
          <tbody>
            {companyCodes.map((company) => (
              <tr key={company.id} className="border-t">
                <td className="px-4 py-3 font-mono text-sm font-bold">{company.company_code}</td>
                <td className="px-4 py-3">{company.company_name}</td>
                <td className="px-4 py-3 text-sm">{company.legal_entity_name}</td>
                <td className="px-4 py-3">{company.currency}</td>
                <td className="px-4 py-3">
                  <span className={`px-2 py-1 rounded text-xs ${
                    company.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                  }`}>
                    {company.is_active ? 'Active' : 'Inactive'}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );

  const renderControllingAreas = () => (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold">Controlling Areas (CO)</h3>
        <button className="bg-blue-600 text-white px-4 py-2 rounded text-sm">Add Controlling Area</button>
      </div>
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left">Code</th>
              <th className="px-4 py-3 text-left">Name</th>
              <th className="px-4 py-3 text-left">Currency</th>
              <th className="px-4 py-3 text-left">Fiscal Year</th>
              <th className="px-4 py-3 text-left">Status</th>
            </tr>
          </thead>
          <tbody>
            {controllingAreas.map((area) => (
              <tr key={area.id} className="border-t">
                <td className="px-4 py-3 font-mono text-sm font-bold">{area.cocarea_code}</td>
                <td className="px-4 py-3">{area.cocarea_name}</td>
                <td className="px-4 py-3">{area.currency}</td>
                <td className="px-4 py-3">{area.fiscal_year_variant}</td>
                <td className="px-4 py-3">
                  <span className={`px-2 py-1 rounded text-xs ${
                    area.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                  }`}>
                    {area.is_active ? 'Active' : 'Inactive'}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );

  const renderCostCenters = () => (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold">Cost Centers</h3>
        <button className="bg-blue-600 text-white px-4 py-2 rounded text-sm">Add Cost Center</button>
      </div>
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left">Code</th>
              <th className="px-4 py-3 text-left">Name</th>
              <th className="px-4 py-3 text-left">Company</th>
              <th className="px-4 py-3 text-left">Category</th>
              <th className="px-4 py-3 text-left">Responsible</th>
              <th className="px-4 py-3 text-left">Status</th>
            </tr>
          </thead>
          <tbody>
            {costCenters.map((center) => (
              <tr key={center.id} className="border-t">
                <td className="px-4 py-3 font-mono text-sm font-bold">{center.cost_center_code}</td>
                <td className="px-4 py-3">{center.cost_center_name}</td>
                <td className="px-4 py-3 text-sm">{center.company?.company_name}</td>
                <td className="px-4 py-3">
                  <span className="px-2 py-1 bg-blue-100 text-blue-800 rounded text-xs">
                    {center.cost_center_category}
                  </span>
                </td>
                <td className="px-4 py-3 text-sm">{center.responsible_person || '-'}</td>
                <td className="px-4 py-3">
                  <span className={`px-2 py-1 rounded text-xs ${
                    center.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                  }`}>
                    {center.is_active ? 'Active' : 'Inactive'}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );

  const renderProfitCenters = () => (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold">Profit Centers</h3>
        <button className="bg-blue-600 text-white px-4 py-2 rounded text-sm">Add Profit Center</button>
      </div>
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left">Code</th>
              <th className="px-4 py-3 text-left">Name</th>
              <th className="px-4 py-3 text-left">Controlling Area</th>
              <th className="px-4 py-3 text-left">Group</th>
              <th className="px-4 py-3 text-left">Responsible</th>
              <th className="px-4 py-3 text-left">Status</th>
            </tr>
          </thead>
          <tbody>
            {profitCenters.map((center) => (
              <tr key={center.id} className="border-t">
                <td className="px-4 py-3 font-mono text-sm font-bold">{center.profit_center_code}</td>
                <td className="px-4 py-3">{center.profit_center_name}</td>
                <td className="px-4 py-3 text-sm">{center.controlling_area?.cocarea_name}</td>
                <td className="px-4 py-3 text-sm">{center.profit_center_group || '-'}</td>
                <td className="px-4 py-3 text-sm">{center.responsible_person || '-'}</td>
                <td className="px-4 py-3">
                  <span className={`px-2 py-1 rounded text-xs ${
                    center.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                  }`}>
                    {center.is_active ? 'Active' : 'Inactive'}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );

  const renderPlants = () => (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold">Plants (Production/Logistics Units)</h3>
        <button className="bg-blue-600 text-white px-4 py-2 rounded text-sm">Add Plant</button>
      </div>
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left">Plant Code</th>
              <th className="px-4 py-3 text-left">Plant Name</th>
              <th className="px-4 py-3 text-left">Company</th>
              <th className="px-4 py-3 text-left">Address</th>
              <th className="px-4 py-3 text-left">Status</th>
            </tr>
          </thead>
          <tbody>
            {plants.map((plant) => (
              <tr key={plant.id} className="border-t">
                <td className="px-4 py-3 font-mono text-sm font-bold">{plant.plant_code}</td>
                <td className="px-4 py-3">{plant.plant_name}</td>
                <td className="px-4 py-3 text-sm">{plant.company?.company_name}</td>
                <td className="px-4 py-3 text-sm">{plant.address || '-'}</td>
                <td className="px-4 py-3">
                  <span className={`px-2 py-1 rounded text-xs ${
                    plant.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                  }`}>
                    {plant.is_active ? 'Active' : 'Inactive'}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );

  const renderStorageLocations = () => (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold">Storage Locations</h3>
        <button className="bg-blue-600 text-white px-4 py-2 rounded text-sm">Add Storage Location</button>
      </div>
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left">SLoc Code</th>
              <th className="px-4 py-3 text-left">Description</th>
              <th className="px-4 py-3 text-left">Plant</th>
              <th className="px-4 py-3 text-left">Type</th>
              <th className="px-4 py-3 text-left">Status</th>
            </tr>
          </thead>
          <tbody>
            {storageLocations.map((sloc) => (
              <tr key={sloc.id} className="border-t">
                <td className="px-4 py-3 font-mono text-sm font-bold">{sloc.storage_location_code}</td>
                <td className="px-4 py-3">{sloc.storage_location_name}</td>
                <td className="px-4 py-3 text-sm">{sloc.plant?.plant_name}</td>
                <td className="px-4 py-3">
                  <span className="px-2 py-1 bg-purple-100 text-purple-800 rounded text-xs">
                    {sloc.storage_type || 'Standard'}
                  </span>
                </td>
                <td className="px-4 py-3">
                  <span className={`px-2 py-1 rounded text-xs ${
                    sloc.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                  }`}>
                    {sloc.is_active ? 'Active' : 'Inactive'}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );

  const renderAssignments = () => (
    <div className="space-y-6">
      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="text-lg font-semibold mb-4">Organizational Assignments</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <h4 className="font-medium mb-3">Company Code → Controlling Area</h4>
            <div className="space-y-2">
              {companyCodes.map((company) => (
                <div key={company.id} className="flex justify-between items-center p-2 bg-gray-50 rounded">
                  <span className="font-mono text-sm">{company.company_code}</span>
                  <span className="text-sm text-gray-600">→</span>
                  <span className="font-mono text-sm">{company.controlling_area_code || 'Not Assigned'}</span>
                </div>
              ))}
            </div>
          </div>
          <div>
            <h4 className="font-medium mb-3">Plant → Company Code</h4>
            <div className="space-y-2">
              {plants.map((plant) => (
                <div key={plant.id} className="flex justify-between items-center p-2 bg-gray-50 rounded">
                  <span className="font-mono text-sm">{plant.plant_code}</span>
                  <span className="text-sm text-gray-600">→</span>
                  <span className="font-mono text-sm">{plant.company?.company_code || 'Not Assigned'}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <h4 className="font-medium text-blue-900 mb-2">SAP Organizational Structure:</h4>
        <p className="text-sm text-blue-800">
          Company Code (Legal Entity) → Controlling Area (CO) → Cost/Profit Centers
        </p>
        <p className="text-sm text-blue-800">
          Company Code → Plant (Logistics) → Storage Locations → Material Master
        </p>
        <p className="text-sm text-blue-800">
          Company Code → Purchasing Organization → Purchase Orders
        </p>
      </div>
    </div>
  );

  const renderPurchasingOrgs = () => (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold">Purchasing Organizations</h3>
        <button className="bg-blue-600 text-white px-4 py-2 rounded text-sm">Add Purchasing Org</button>
      </div>
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left">Code</th>
              <th className="px-4 py-3 text-left">Name</th>
              <th className="px-4 py-3 text-left">Company</th>
              <th className="px-4 py-3 text-left">Currency</th>
              <th className="px-4 py-3 text-left">Status</th>
            </tr>
          </thead>
          <tbody>
            {purchasingOrgs.map((org) => (
              <tr key={org.id} className="border-t">
                <td className="px-4 py-3 font-mono text-sm font-bold">{org.porg_code}</td>
                <td className="px-4 py-3">{org.porg_name}</td>
                <td className="px-4 py-3 text-sm">{org.company?.company_name}</td>
                <td className="px-4 py-3">{org.currency}</td>
                <td className="px-4 py-3">
                  <span className={`px-2 py-1 rounded text-xs ${
                    org.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                  }`}>
                    {org.is_active ? 'Active' : 'Inactive'}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );

  const renderContent = () => {
    switch (activeTab) {
      case 'company': return renderCompanyCodes();
      case 'controlling': return renderControllingAreas();
      case 'cost': return renderCostCenters();
      case 'profit': return renderProfitCenters();
      case 'purchasing': return renderPurchasingOrgs();
      case 'plants': return renderPlants();
      case 'storage': return renderStorageLocations();
      case 'assignments': return renderAssignments();
      default: return renderCompanyCodes();
    }
  };

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold">SAP Configuration</h1>
        <p className="text-gray-600">Organizational structure setup for Finance, Controlling, and Logistics</p>
      </div>

      <div className="flex space-x-1 mb-6 bg-gray-100 p-1 rounded-lg">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            className={`flex items-center space-x-2 px-4 py-2 rounded-md text-sm font-medium transition-colors ${
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