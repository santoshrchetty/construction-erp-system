'use client';

import React, { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase/client';

export default function SAPConfig() {
  const [activeTab, setActiveTab] = useState('manage');
  const [selectedObjectType, setSelectedObjectType] = useState('company');
  const [showModal, setShowModal] = useState(false);
  const [editingItem, setEditingItem] = useState(null);
  const [companyCodes, setCompanyCodes] = useState<any[]>([]);
  const [controllingAreas, setControllingAreas] = useState<any[]>([]);
  const [costCenters, setCostCenters] = useState<any[]>([]);
  const [profitCenters, setProfitCenters] = useState<any[]>([]);
  const [purchasingOrgs, setPurchasingOrgs] = useState<any[]>([]);
  const [plants, setPlants] = useState<any[]>([]);
  const [storageLocations, setStorageLocations] = useState<any[]>([]);
  const [departments, setDepartments] = useState<any[]>([]);
  const [currencies, setCurrencies] = useState<any[]>([]);
  const [countries, setCountries] = useState<any[]>([]);
  const [fiscalYearVariants, setFiscalYearVariants] = useState<any[]>([]);
  const [selectedCompanyForDepts, setSelectedCompanyForDepts] = useState('C001');
  const [showDepartmentModal, setShowDepartmentModal] = useState(false);
  const [editingDepartment, setEditingDepartment] = useState<any>(null);
  const [showControllingAreaModal, setShowControllingAreaModal] = useState(false);
  const [editingControllingArea, setEditingControllingArea] = useState<any>(null);

  useEffect(() => {
    fetchAllData();
  }, []);

  const fetchAllData = async () => {
    try {
      console.log('Fetching all data...');
      
      // Batch all queries using Promise.allSettled for better error handling
      const queries = [
        supabase.from('company_codes').select('*').order('company_code'),
        supabase.from('controlling_areas').select('*').order('cocarea_code'),
        supabase.from('cost_centers').select('*').order('cost_center_code'),
        supabase.from('profit_centers').select('*, controlling_area:controlling_areas(cocarea_name)').order('profit_center_code'),
        supabase.from('purchasing_organizations').select('*').order('porg_code'),
        supabase.from('plants').select('*').order('plant_code'),
        supabase.from('storage_locations').select('*'),
        supabase.from('departments').select('*, company:company_codes(company_name)').order('name'),
        supabase.from('currencies').select('*').order('currency_code'),
        supabase.from('countries').select('*').order('country_name'),
        supabase.from('fiscal_year_variants').select('*').order('variant_code')
      ];
      
      const results = await Promise.allSettled(queries);
      
      // Process results with error handling
      const [companies, controlling, costs, profits, purchasing, plantsData, storageData, departmentsData, currenciesData, countriesData, fiscalVariantsData] = results;
      
      // Set state with data or empty arrays on error
      setCompanyCodes(companies.status === 'fulfilled' && companies.value.data ? companies.value.data : []);
      setControllingAreas(controlling.status === 'fulfilled' && controlling.value.data ? controlling.value.data : []);
      setCostCenters(costs.status === 'fulfilled' && costs.value.data ? costs.value.data : []);
      setProfitCenters(profits.status === 'fulfilled' && profits.value.data ? profits.value.data : []);
      setPurchasingOrgs(purchasing.status === 'fulfilled' && purchasing.value.data ? purchasing.value.data : []);
      setPlants(plantsData.status === 'fulfilled' && plantsData.value.data ? plantsData.value.data : []);
      setStorageLocations(storageData.status === 'fulfilled' && storageData.value.data ? storageData.value.data : []);
      setDepartments(departmentsData.status === 'fulfilled' && departmentsData.value.data ? departmentsData.value.data : []);
      setCurrencies(currenciesData.status === 'fulfilled' && currenciesData.value.data ? currenciesData.value.data : []);
      setCountries(countriesData.status === 'fulfilled' && countriesData.value.data ? countriesData.value.data : []);
      setFiscalYearVariants(fiscalVariantsData.status === 'fulfilled' && fiscalVariantsData.value.data ? fiscalVariantsData.value.data : []);
      
      console.log('Data fetch complete');
    } catch (error) {
      console.error('Error fetching data:', error);
    }
  };

  const tabs = [
    { id: 'manage', name: 'Manage Objects', icon: '🏗️', description: 'Create and manage organizational objects' },
    { id: 'hierarchy', name: 'View Hierarchy', icon: '🌳', description: 'Organizational structure' },
    { id: 'assignments', name: 'Assignments', icon: '🔗', description: 'Object relationships' }
  ];

  const objectTypes = [
    { id: 'company', name: 'Company Codes', icon: '🏢', table: 'company_codes' },
    { id: 'controlling', name: 'Controlling Areas', icon: '📊', table: 'controlling_areas' },
    { id: 'plant', name: 'Plants', icon: '🏭', table: 'plants' },
    { id: 'cost_center', name: 'Cost Centers', icon: '💰', table: 'cost_centers' },
    { id: 'profit_center', name: 'Profit Centers', icon: '📈', table: 'profit_centers' },
    { id: 'storage', name: 'Storage Locations', icon: '📦', table: 'storage_locations' },
    { id: 'purchasing', name: 'Purchasing Orgs', icon: '🛒', table: 'purchasing_organizations' },
    { id: 'department', name: 'Departments', icon: '🏛️', table: 'departments' },
    { id: 'currency', name: 'Currencies', icon: '💱', table: 'currencies' },
    { id: 'country', name: 'Countries', icon: '🌍', table: 'countries' },
    { id: 'fiscal_variant', name: 'Fiscal Year Variants', icon: '📅', table: 'fiscal_year_variants' }
  ];

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
        
        <ObjectList objectType={selectedObjectType} onEdit={(item) => {
          setEditingItem(item);
          setShowModal(true);
        }} />
      </div>
    </div>
  );

  // Remove unused AssignmentCard reference
  const renderAssignObjects = () => (
    <div className="space-y-6">
      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="font-semibold mb-4">Organizational Assignments</h3>
        <p className="text-sm text-gray-600">This tab has been replaced by the enhanced Assignments tab.</p>
      </div>
    </div>
  );

  // Tab 1: Manage Objects (CRUD)
  const renderManageObjects = () => (
    <div className="flex flex-col lg:flex-row gap-6">
      {/* Object Type Selector - Mobile: Dropdown, Desktop: Side Panel */}
      <div className="lg:w-48">
        {/* Mobile Dropdown */}
        <div className="lg:hidden">
          <label className="block text-sm font-medium mb-2">Select Object Type</label>
          <select
            value={selectedObjectType}
            onChange={(e) => setSelectedObjectType(e.target.value)}
            className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
          >
            {objectTypes.map(type => (
              <option key={type.id} value={type.id}>
                {type.icon} {type.name}
              </option>
            ))}
          </select>
        </div>

        {/* Desktop Side Panel */}
        <div className="hidden lg:block">
          <h3 className="font-semibold mb-4 text-gray-900">Object Types</h3>
          <div className="space-y-1 max-h-96 overflow-y-auto pr-2">
            {objectTypes.map(type => (
              <button
                key={type.id}
                onClick={() => setSelectedObjectType(type.id)}
                className={`w-full text-left px-3 py-2 rounded-lg transition-colors flex items-center space-x-3 ${
                  selectedObjectType === type.id
                    ? 'bg-blue-100 text-blue-700 border border-blue-300'
                    : 'text-gray-700 hover:bg-gray-100'
                }`}
              >
                <span className="text-lg">{type.icon}</span>
                <span className="text-sm font-medium">{type.name}</span>
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* CRUD Interface */}
      <div className="flex-1">
        <div className="bg-white rounded-lg shadow">
          <div className="p-4 border-b flex justify-between items-center">
            <h3 className="font-semibold">
              {objectTypes.find(t => t.id === selectedObjectType)?.name || 'Objects'}
            </h3>
            <button
              onClick={() => {
                if (selectedObjectType === 'department') {
                  setEditingDepartment(null);
                  setShowDepartmentModal(true);
                } else if (selectedObjectType === 'controlling') {
                  setEditingControllingArea(null);
                  setShowControllingAreaModal(true);
                } else {
                  setEditingItem(null);
                  setShowModal(true);
                }
              }}
              className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 flex items-center"
            >
              <Icons.Plus className="w-4 h-4 mr-2" />
              Add New
            </button>
          </div>
          
          <ObjectList objectType={selectedObjectType} onEdit={(item) => {
            if (selectedObjectType === 'department') {
              setEditingDepartment(item);
              setShowDepartmentModal(true);
            } else if (selectedObjectType === 'controlling') {
              setEditingControllingArea(item);
              setShowControllingAreaModal(true);
            } else {
              setEditingItem(item);
              setShowModal(true);
            }
          }} />
        </div>
      </div>
    </div>
  );

  const buildOrgTree = () => {
    return companyCodes.map(company => ({
      id: company.company_code,
      name: `${company.company_code} - ${company.company_name}`,
      type: 'company',
      data: company,
      children: [
        // Controlling Area
        ...(company.controlling_area_code ? [{
          id: `${company.company_code}-ca`,
          name: `Controlling: ${company.controlling_area_code}`,
          type: 'controlling_area',
          data: controllingAreas.find(ca => ca.cocarea_code === company.controlling_area_code),
          children: [
            // Cost Centers
            ...costCenters
              .filter(cc => cc.controlling_area_code === company.controlling_area_code)
              .map(cc => ({
                id: cc.cost_center_code,
                name: `${cc.cost_center_code} - ${cc.cost_center_name}`,
                type: 'cost_center',
                data: cc
              })),
            // Profit Centers
            ...profitCenters
              .filter(pc => pc.controlling_area_code === company.controlling_area_code)
              .map(pc => ({
                id: pc.profit_center_code,
                name: `${pc.profit_center_code} - ${pc.profit_center_name}`,
                type: 'profit_center',
                data: pc
              }))
          ]
        }] : []),
        
        // Departments (at company level)
        ...departments
          .filter(dept => dept.company_code === company.company_code)
          .map(dept => ({
            id: dept.id,
            name: `${dept.code} - ${dept.name}`,
            type: 'department',
            data: dept
          })),
        
        // Plants
        ...plants
          .filter(plant => plant.company_code === company.company_code)
          .map(plant => ({
            id: plant.plant_code,
            name: `${plant.plant_code} - ${plant.plant_name}`,
            type: 'plant',
            data: plant,
            children: [
              // Storage Locations
              ...storageLocations
                .filter(sl => sl.plant_code === plant.plant_code)
                .map(sl => ({
                  id: sl.sloc_code + '-' + sl.id,
                  name: `${sl.sloc_code} - ${sl.sloc_name}`,
                  type: 'storage_location',
                  data: sl
                }))
            ]
          }))
      ]
    }));
  };

  const HierarchyNode = ({ node, level }) => {
    const [expanded, setExpanded] = useState(true);
    
    return (
      <div>
        <div 
          className="flex items-center p-2 rounded transition-colors hover:bg-gray-100"
          style={{ paddingLeft: `${level * 20 + 8}px` }}
        >
          {node.children?.length > 0 && (
            <button 
              onClick={() => setExpanded(!expanded)}
              className="mr-2 text-gray-500 hover:text-gray-700"
            >
              {expanded ? '▼' : '▶'}
            </button>
          )}
          <span className="text-sm flex-1">{node.name}</span>
          <span className="text-xs text-gray-400 ml-2">{node.type}</span>
        </div>
        
        {expanded && node.children?.map(child => (
          <HierarchyNode key={child.id} node={child} level={level + 1} />
        ))}
      </div>
    );
  };

  // Missing state variables
  const [selectedNode, setSelectedNode] = useState(null);
  const [createObjectType, setCreateObjectType] = useState('');
  const [showCreateModal, setShowCreateModal] = useState(false);

  // Missing Icons component
  const Icons = {
    Plus: () => <span>+</span>
  };

  // Missing components
  const ObjectList = ({ objectType, onEdit }) => {
    const getDataForType = () => {
      switch (objectType) {
        case 'company': return companyCodes;
        case 'controlling': return controllingAreas;
        case 'plant': return plants;
        case 'cost_center': return costCenters;
        case 'profit_center': return profitCenters;
        case 'storage': return storageLocations;
        case 'purchasing': return purchasingOrgs;
        case 'department': return departments;
        case 'currency': return currencies;
        case 'country': return countries;
        case 'fiscal_variant': return fiscalYearVariants;
        default: return [];
      }
    };

    const data = getDataForType();
    console.log(`ObjectList for ${objectType}:`, data);
    
    if (!data || data.length === 0) {
      return (
        <div className="p-8 text-center text-gray-500">
          <p>No {objectTypes.find(t => t.id === objectType)?.name || 'items'} found.</p>
          <p className="text-sm mt-2">Click "Add New" to create the first entry.</p>
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
                  {selectedObjectType === 'department' ? item.code :
                   selectedObjectType === 'currency' ? item.currency_code :
                   selectedObjectType === 'country' ? item.country_code :
                   selectedObjectType === 'fiscal_variant' ? item.variant_code :
                   selectedObjectType === 'storage' ? item.sloc_code :
                   (item.company_code || item.cocarea_code || item.plant_code || item.cost_center_code || 
                    item.profit_center_code || item.porg_code)}
                </td>
                <td className="px-4 py-3">
                  {selectedObjectType === 'department' ? item.name : 
                   selectedObjectType === 'currency' ? `${item.currency_name} (${item.currency_symbol})` :
                   selectedObjectType === 'country' ? `${item.country_name} (${item.region})` :
                   selectedObjectType === 'fiscal_variant' ? `${item.variant_name} (${item.description})` :
                   selectedObjectType === 'storage' ? item.sloc_name :
                   (item.company_name || item.cocarea_name || item.plant_name || item.cost_center_name || 
                    item.profit_center_name || item.porg_name)}
                </td>
                <td className="px-4 py-3">
                  <button onClick={() => onEdit(item)} className="text-blue-600 hover:text-blue-800">
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

  const AssignmentSection = ({ title, description, icon, parentData, childData, parentKey, childKey, assignmentField, parentLabel, childLabel, onAssign, table, idField }) => {
    const [selectedParent, setSelectedParent] = useState('');
    const [selectedChild, setSelectedChild] = useState('');
    const [isAssigning, setIsAssigning] = useState(false);
    const [selectedBulkChild, setSelectedBulkChild] = useState('');
    const [showBulkAssign, setShowBulkAssign] = useState(false);

    const getItemName = (item, keyField) => {
      // Map field names to their corresponding name fields
      const nameFieldMap = {
        'company_code': 'company_name',
        'plant_code': 'plant_name', 
        'sloc_code': 'sloc_name',
        'cocarea_code': 'cocarea_name',
        'cost_center_code': 'cost_center_name',
        'profit_center_code': 'profit_center_name',
        'porg_code': 'porg_name',
        'code': 'name'
      };
      
      const nameField = nameFieldMap[keyField];
      return item[nameField] || item.name || '';
    };

    const handleSingleAssign = async () => {
      if (!selectedParent || !selectedChild) return;
      
      setIsAssigning(true);
      try {
        await onAssign(table, selectedParent, assignmentField, selectedChild);
        setSelectedParent('');
        setSelectedChild('');
      } catch (error) {
        console.error('Assignment error:', error);
      } finally {
        setIsAssigning(false);
      }
    };

    const unassignedItems = parentData.filter(item => !item[assignmentField]);
    const assignedItems = parentData.filter(item => item[assignmentField]);

    return (
      <div className="border rounded-lg p-6 bg-gray-50">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h4 className="font-semibold text-gray-900 flex items-center">
              <span className="mr-2 text-lg">{icon}</span>
              {title}
            </h4>
            <p className="text-sm text-gray-600 mt-1">{description}</p>
          </div>
          <div className="flex items-center space-x-2">
            <span className="bg-red-100 text-red-800 px-2 py-1 rounded text-xs font-medium">
              {unassignedItems.length} unassigned
            </span>
            <span className="bg-green-100 text-green-800 px-2 py-1 rounded text-xs font-medium">
              {assignedItems.length} assigned
            </span>
          </div>
        </div>

        {/* Quick Assignment */}
        <div className="bg-white rounded-lg p-4 mb-4 border">
          <h5 className="font-medium mb-3 text-gray-800">Quick Assignment</h5>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
            <select
              value={selectedParent}
              onChange={(e) => setSelectedParent(e.target.value)}
              className="px-3 py-2 border rounded focus:ring-2 focus:ring-blue-500 text-sm"
            >
              <option value="">Select {parentLabel}...</option>
              {unassignedItems.map(item => (
                <option key={item[parentKey]} value={item[parentKey]}>
                  {item[parentKey]} - {getItemName(item, parentKey)}
                </option>
              ))}
            </select>
            
            <select
              value={selectedChild}
              onChange={(e) => setSelectedChild(e.target.value)}
              className="px-3 py-2 border rounded focus:ring-2 focus:ring-blue-500 text-sm"
            >
              <option value="">Select {childLabel}...</option>
              {childData.map(item => (
                <option key={item[childKey]} value={item[childKey]}>
                  {item[childKey]} - {getItemName(item, childKey)}
                </option>
              ))}
            </select>
            
            <button
              onClick={handleSingleAssign}
              disabled={!selectedParent || !selectedChild || isAssigning}
              className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 disabled:bg-gray-300 text-sm font-medium"
            >
              {isAssigning ? 'Assigning...' : 'Assign'}
            </button>
          </div>
        </div>

        {/* Assignment List */}
        <div className="bg-white rounded-lg border">
          <div className="p-4 border-b flex justify-between items-center">
            <h5 className="font-medium text-gray-800">Current Assignments</h5>
            <button
              onClick={() => setShowBulkAssign(!showBulkAssign)}
              className="text-blue-600 hover:text-blue-800 text-sm font-medium"
            >
              {showBulkAssign ? 'Hide' : 'Show'} Bulk Actions
            </button>
          </div>
          
          <div className="max-h-64 overflow-y-auto">
            {parentData.length === 0 ? (
              <div className="p-4 text-center text-gray-500 text-sm">
                No {parentLabel.toLowerCase()}s available
              </div>
            ) : (
              <div className="divide-y">
                {parentData.map((item) => (
                  <div key={item[parentKey]} className="p-3 flex items-center justify-between hover:bg-gray-50">
                    <div className="flex-1">
                      <span className="font-mono text-sm font-medium">{item[parentKey]}</span>
                      <span className="text-gray-600 text-sm ml-2">
                        {getItemName(item, parentKey)}
                      </span>
                    </div>
                    <div className="flex items-center space-x-2">
                      <span className="text-gray-400 text-sm">→</span>
                      <div className="min-w-0 flex-1">
                        {item[assignmentField] ? (
                          <span className="bg-green-100 text-green-800 px-2 py-1 rounded text-xs font-medium">
                            {item[assignmentField]}
                          </span>
                        ) : (
                          <span className="bg-red-100 text-red-800 px-2 py-1 rounded text-xs">
                            Unassigned
                          </span>
                        )}
                      </div>
                      {item[assignmentField] && (
                        <button
                          onClick={() => onAssign(table, item[parentKey], assignmentField, null)}
                          className="text-red-600 hover:text-red-800 text-xs"
                          title="Remove assignment"
                        >
                          ×
                        </button>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Bulk Assignment (when enabled) */}
        {showBulkAssign && (
          <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mt-4">
            <h5 className="font-medium text-yellow-800 mb-3">Bulk Assignment</h5>
            <div className="flex items-center space-x-3">
              <select 
                value={selectedBulkChild}
                onChange={(e) => setSelectedBulkChild(e.target.value)}
                className="px-3 py-2 border rounded focus:ring-2 focus:ring-yellow-500 text-sm"
              >
                <option value="">Select {childLabel} for all unassigned...</option>
                {childData.map(item => (
                  <option key={item[childKey]} value={item[childKey]}>
                    {item[childKey]} - {getItemName(item, childKey)}
                  </option>
                ))}
              </select>
              <button 
                onClick={async () => {
                  if (!selectedBulkChild) return;
                  setIsAssigning(true);
                  try {
                    for (const item of unassignedItems) {
                      await onAssign(table, item[parentKey], assignmentField, selectedBulkChild);
                    }
                    setSelectedBulkChild('');
                  } catch (error) {
                    console.error('Bulk assignment error:', error);
                  } finally {
                    setIsAssigning(false);
                  }
                }}
                disabled={!selectedBulkChild || isAssigning}
                className="bg-yellow-600 text-white px-4 py-2 rounded hover:bg-yellow-700 disabled:bg-gray-300 text-sm font-medium"
              >
                {isAssigning ? 'Assigning...' : `Assign All (${unassignedItems.length})`}
              </button>
            </div>
          </div>
        )}
      </div>
    );
  };

  const renderHierarchy = () => (
    <div className="bg-white rounded-lg shadow p-6">
      <h3 className="font-semibold mb-4">Organizational Structure</h3>
      <div className="space-y-1">
        {buildOrgTree().map(company => (
          <OrgTreeNode 
            key={company.id} 
            node={company} 
            level={0}
            onSelect={setSelectedNode}
            selectedNode={selectedNode}
          />
        ))}
      </div>
    </div>
  );
  const handleAssignment = async (table: string, objectId: string, field: string, value: string) => {
    try {
      const idFieldMap = {
        'company_codes': 'company_code',
        'plants': 'plant_code',
        'cost_centers': 'cost_center_code',
        'profit_centers': 'profit_center_code',
        'storage_locations': 'sloc_code',
        'departments': 'code'
      };
      
      const idField = idFieldMap[table];
      if (!idField) {
        throw new Error(`Unknown table: ${table}`);
      }
      
      const { error } = await supabase
        .from(table)
        .update({ [field]: value })
        .eq(idField, objectId);
      
      if (error) throw error;
      
      // Refresh data
      await fetchAllData();
      
    } catch (error) {
      console.error('Assignment error:', error);
      alert('Failed to update assignment: ' + error.message);
    }
  };

  // Tree Node Component
  const OrgTreeNode = ({ node, level, onSelect, selectedNode }) => {
    const [expanded, setExpanded] = useState(true);
    const isSelected = selectedNode?.id === node.id;
    
    return (
      <div>
        <div 
          className={`flex items-center p-2 cursor-pointer rounded transition-colors ${
            isSelected ? 'bg-blue-100 border-blue-300' : 'hover:bg-gray-100'
          }`}
          style={{ paddingLeft: `${level * 20 + 8}px` }}
          onClick={() => onSelect(node)}
        >
          {node.children?.length > 0 && (
            <button 
              onClick={(e) => {
                e.stopPropagation();
                setExpanded(!expanded);
              }}
              className="mr-2 text-gray-500 hover:text-gray-700"
            >
              {expanded ? '▼' : '▶'}
            </button>
          )}
          <span className="text-sm flex-1">{node.name}</span>
          <span className="text-xs text-gray-400 ml-2">{node.type}</span>
        </div>
        
        {expanded && node.children?.map(child => (
          <OrgTreeNode 
            key={child.id} 
            node={child} 
            level={level + 1}
            onSelect={onSelect}
            selectedNode={selectedNode}
          />
        ))}
      </div>
    );
  };

  const renderControllingAreas = () => (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold">Controlling Areas (CO)</h3>
        <button className="bg-blue-600 text-white px-4 py-2 rounded text-sm" onClick={() => setShowControllingAreaModal(true)}>Add Controlling Area</button>
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
      {/* Assignment Overview Cards */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-lg font-semibold mb-4 text-blue-900">📊 Financial Structure</h3>
          <div className="space-y-3">
            <div className="flex items-center justify-between p-3 bg-blue-50 rounded">
              <span className="text-sm font-medium">Company Codes</span>
              <span className="bg-blue-100 text-blue-800 px-2 py-1 rounded text-xs">{companyCodes.length}</span>
            </div>
            <div className="flex items-center justify-between p-3 bg-blue-50 rounded">
              <span className="text-sm font-medium">Controlling Areas</span>
              <span className="bg-blue-100 text-blue-800 px-2 py-1 rounded text-xs">{controllingAreas.length}</span>
            </div>
            <div className="flex items-center justify-between p-3 bg-blue-50 rounded">
              <span className="text-sm font-medium">Cost Centers</span>
              <span className="bg-blue-100 text-blue-800 px-2 py-1 rounded text-xs">{costCenters.length}</span>
            </div>
            <div className="flex items-center justify-between p-3 bg-blue-50 rounded">
              <span className="text-sm font-medium">Profit Centers</span>
              <span className="bg-blue-100 text-blue-800 px-2 py-1 rounded text-xs">{profitCenters.length}</span>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-lg font-semibold mb-4 text-green-900">🏭 Logistics Structure</h3>
          <div className="space-y-3">
            <div className="flex items-center justify-between p-3 bg-green-50 rounded">
              <span className="text-sm font-medium">Plants</span>
              <span className="bg-green-100 text-green-800 px-2 py-1 rounded text-xs">{plants.length}</span>
            </div>
            <div className="flex items-center justify-between p-3 bg-green-50 rounded">
              <span className="text-sm font-medium">Storage Locations</span>
              <span className="bg-green-100 text-green-800 px-2 py-1 rounded text-xs">{storageLocations.length}</span>
            </div>
            <div className="flex items-center justify-between p-3 bg-green-50 rounded">
              <span className="text-sm font-medium">Purchasing Orgs</span>
              <span className="bg-green-100 text-green-800 px-2 py-1 rounded text-xs">{purchasingOrgs.length}</span>
            </div>
            <div className="flex items-center justify-between p-3 bg-green-50 rounded">
              <span className="text-sm font-medium">Departments</span>
              <span className="bg-green-100 text-green-800 px-2 py-1 rounded text-xs">{departments.length}</span>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-lg font-semibold mb-4 text-purple-900">⚠️ Assignment Status</h3>
          <div className="space-y-3">
            <div className="flex items-center justify-between p-3 bg-red-50 rounded">
              <span className="text-sm font-medium">Unassigned Companies</span>
              <span className="bg-red-100 text-red-800 px-2 py-1 rounded text-xs">
                {companyCodes.filter(c => !c.controlling_area_code).length}
              </span>
            </div>
            <div className="flex items-center justify-between p-3 bg-yellow-50 rounded">
              <span className="text-sm font-medium">Unassigned Plants</span>
              <span className="bg-yellow-100 text-yellow-800 px-2 py-1 rounded text-xs">
                {plants.filter(p => !p.company_code).length}
              </span>
            </div>
            <div className="flex items-center justify-between p-3 bg-orange-50 rounded">
              <span className="text-sm font-medium">Unassigned Cost Centers</span>
              <span className="bg-orange-100 text-orange-800 px-2 py-1 rounded text-xs">
                {costCenters.filter(cc => !cc.controlling_area_code).length}
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Assignment Interface */}
      <div className="bg-white rounded-lg shadow">
        <div className="border-b p-6">
          <h3 className="text-lg font-semibold text-gray-900">Organizational Assignments</h3>
          <p className="text-sm text-gray-600 mt-1">Manage relationships between organizational units</p>
        </div>

        <div className="p-6">
          <div className="grid grid-cols-1 xl:grid-cols-2 gap-8">
            {/* Company → Controlling Area Assignment */}
            <AssignmentSection
              title="Company → Controlling Area"
              description="Assign companies to controlling areas for financial reporting"
              icon="🏢→📊"
              parentData={companyCodes}
              childData={controllingAreas}
              parentKey="company_code"
              childKey="cocarea_code"
              assignmentField="controlling_area_code"
              parentLabel="Company"
              childLabel="Controlling Area"
              onAssign={handleAssignment}
              table="company_codes"
              idField="company_code"
            />

            {/* Plant → Company Assignment */}
            <AssignmentSection
              title="Plant → Company"
              description="Assign plants to company codes for logistics operations"
              icon="🏭→🏢"
              parentData={plants}
              childData={companyCodes}
              parentKey="plant_code"
              childKey="company_code"
              assignmentField="company_code"
              parentLabel="Plant"
              childLabel="Company"
              onAssign={handleAssignment}
              table="plants"
              idField="plant_code"
            />

            {/* Cost Center → Controlling Area Assignment */}
            <AssignmentSection
              title="Cost Center → Controlling Area"
              description="Assign cost centers to controlling areas for cost accounting"
              icon="💰→📊"
              parentData={costCenters}
              childData={controllingAreas}
              parentKey="cost_center_code"
              childKey="cocarea_code"
              assignmentField="controlling_area_code"
              parentLabel="Cost Center"
              childLabel="Controlling Area"
              onAssign={handleAssignment}
              table="cost_centers"
              idField="cost_center_code"
            />

            {/* Storage Location → Plant Assignment */}
            <AssignmentSection
              title="Storage Location → Plant"
              description="Assign storage locations to plants for inventory management"
              icon="📦→🏭"
              parentData={storageLocations}
              childData={plants}
              parentKey="sloc_code"
              childKey="plant_code"
              assignmentField="plant_code"
              parentLabel="Storage Location"
              childLabel="Plant"
              onAssign={handleAssignment}
              table="storage_locations"
              idField="sloc_code"
            />

            {/* Profit Center → Controlling Area Assignment */}
            <AssignmentSection
              title="Profit Center → Controlling Area"
              description="Assign profit centers to controlling areas for profitability analysis"
              icon="📈→📊"
              parentData={profitCenters}
              childData={controllingAreas}
              parentKey="profit_center_code"
              childKey="cocarea_code"
              assignmentField="controlling_area_code"
              parentLabel="Profit Center"
              childLabel="Controlling Area"
              onAssign={handleAssignment}
              table="profit_centers"
              idField="profit_center_code"
            />

            {/* Department → Company Assignment */}
            <AssignmentSection
              title="Department → Company"
              description="Assign departments to companies for organizational structure"
              icon="🏛️→🏢"
              parentData={departments}
              childData={companyCodes}
              parentKey="code"
              childKey="company_code"
              assignmentField="company_code"
              parentLabel="Department"
              childLabel="Company"
              onAssign={handleAssignment}
              table="departments"
              idField="code"
            />
          </div>
        </div>
      </div>

      {/* SAP Best Practices Guide */}
      <div className="bg-gradient-to-r from-blue-50 to-indigo-50 border border-blue-200 rounded-lg p-6">
        <h4 className="font-semibold text-blue-900 mb-3 flex items-center">
          <span className="mr-2">📋</span>
          SAP Organizational Structure Best Practices
        </h4>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
          <div className="bg-white p-4 rounded border border-blue-100">
            <h5 className="font-medium text-blue-800 mb-2">Financial Hierarchy</h5>
            <p className="text-blue-700">Company Code → Controlling Area → Cost/Profit Centers</p>
          </div>
          <div className="bg-white p-4 rounded border border-blue-100">
            <h5 className="font-medium text-blue-800 mb-2">Logistics Hierarchy</h5>
            <p className="text-blue-700">Company Code → Plant → Storage Locations</p>
          </div>
          <div className="bg-white p-4 rounded border border-blue-100">
            <h5 className="font-medium text-blue-800 mb-2">Procurement Hierarchy</h5>
            <p className="text-blue-700">Company Code → Purchasing Organization</p>
          </div>
        </div>
      </div>
    </div>
  );

  const handleSaveDepartment = async (departmentData: any) => {
    try {
      if (editingDepartment) {
        // Update existing department
        const { error } = await supabase
          .from('departments')
          .update(departmentData)
          .eq('id', editingDepartment.id);
        if (error) throw error;
      } else {
        // Create new department
        const { error } = await supabase
          .from('departments')
          .insert([departmentData]);
        if (error) throw error;
      }
      
      // Refresh departments list
      const { data } = await supabase.from('departments').select('*').order('name');
      if (data) setDepartments(data);
      
      setShowDepartmentModal(false);
      setEditingDepartment(null);
    } catch (error) {
      console.error('Error saving department:', error);
      alert('Error saving department: ' + error.message);
    }
  };

  const handleDeleteDepartment = async (departmentId: string) => {
    if (!confirm('Are you sure you want to deactivate this department?')) return;
    
    try {
      const { error } = await supabase
        .from('departments')
        .update({ is_active: false })
        .eq('id', departmentId);
      
      if (error) throw error;
      
      // Refresh departments list
      const { data } = await supabase.from('departments').select('*').order('name');
      if (data) setDepartments(data);
    } catch (error) {
      console.error('Error deactivating department:', error);
      alert('Error deactivating department: ' + error.message);
    }
  };

  const renderDepartments = () => (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <div>
          <h3 className="text-lg font-semibold">Departments (Authorization DEPT Field)</h3>
          <p className="text-sm text-gray-600">Manage departments for user assignment and authorization control</p>
        </div>
        <button 
          onClick={() => {
            setEditingDepartment(null);
            setShowDepartmentModal(true);
          }}
          className="bg-blue-600 text-white px-4 py-2 rounded text-sm hover:bg-blue-700"
        >
          Add Department
        </button>
      </div>
      
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left">Code</th>
              <th className="px-4 py-3 text-left">Department Name</th>
              <th className="px-4 py-3 text-left">Description</th>
              <th className="px-4 py-3 text-left">Status</th>
              <th className="px-4 py-3 text-left">Actions</th>
            </tr>
          </thead>
          <tbody>
            {departments.map((dept) => (
              <tr key={dept.id} className="border-t hover:bg-gray-50">
                <td className="px-4 py-3 font-mono text-sm font-bold">{dept.code}</td>
                <td className="px-4 py-3">{dept.name}</td>
                <td className="px-4 py-3 text-sm text-gray-600">{dept.description}</td>
                <td className="px-4 py-3">
                  <span className={`px-2 py-1 rounded text-xs ${
                    dept.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                  }`}>
                    {dept.is_active ? 'Active' : 'Inactive'}
                  </span>
                </td>
                <td className="px-4 py-3">
                  <div className="flex space-x-2">
                    <button 
                      onClick={() => {
                        setEditingDepartment(dept);
                        setShowDepartmentModal(true);
                      }}
                      className="text-blue-600 hover:text-blue-800 text-sm"
                    >
                      Edit
                    </button>
                    {dept.is_active && (
                      <button 
                        onClick={() => handleDeleteDepartment(dept.id)}
                        className="text-red-600 hover:text-red-800 text-sm"
                      >
                        Deactivate
                      </button>
                    )}
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      
      <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
        <h4 className="font-medium text-yellow-900 mb-2">⚠️ Authorization Impact:</h4>
        <p className="text-sm text-yellow-800">
          Department codes are used in authorization objects DEPT field. Changes affect user access permissions.
        </p>
        <p className="text-sm text-yellow-800">
          Deactivating departments will not affect existing users but prevents new assignments.
        </p>
      </div>
    </div>
  );

  const DepartmentModal = () => {
    const [formData, setFormData] = useState({
      name: editingDepartment?.name || '',
      code: editingDepartment?.code || '',
      description: editingDepartment?.description || '',
      is_active: editingDepartment?.is_active ?? true
    });

    const handleSubmit = (e: React.FormEvent) => {
      e.preventDefault();
      if (!formData.name || !formData.code) {
        alert('Name and Code are required');
        return;
      }
      handleSaveDepartment(formData);
    };

    if (!showDepartmentModal) return null;

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg p-6 w-full max-w-md">
          <h3 className="text-lg font-semibold mb-4">
            {editingDepartment ? 'Edit Department' : 'Add New Department'}
          </h3>
          
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-1">Department Name *</label>
              <input
                type="text"
                value={formData.name}
                onChange={(e) => setFormData({...formData, name: e.target.value})}
                className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-blue-500"
                placeholder="e.g., Engineering"
                required
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium mb-1">Department Code *</label>
              <input
                type="text"
                value={formData.code}
                onChange={(e) => setFormData({...formData, code: e.target.value.toUpperCase()})}
                className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-blue-500 font-mono"
                placeholder="e.g., STRUCTURAL-ENGINEERING"
                maxLength={31}
                required
              />
              <p className="text-xs text-gray-500 mt-1">Used in authorization DEPT field</p>
            </div>
            
            <div>
              <label className="block text-sm font-medium mb-1">Description</label>
              <textarea
                value={formData.description}
                onChange={(e) => setFormData({...formData, description: e.target.value})}
                className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-blue-500"
                rows={3}
                placeholder="Department description..."
              />
            </div>
            
            <div className="flex items-center">
              <input
                type="checkbox"
                id="is_active"
                checked={formData.is_active}
                onChange={(e) => setFormData({...formData, is_active: e.target.checked})}
                className="mr-2"
              />
              <label htmlFor="is_active" className="text-sm">Active</label>
            </div>
            
            <div className="flex space-x-3 pt-4">
              <button
                type="submit"
                className="flex-1 bg-blue-600 text-white py-2 rounded hover:bg-blue-700"
              >
                {editingDepartment ? 'Update' : 'Create'}
              </button>
              <button
                type="button"
                onClick={() => {
                  setShowDepartmentModal(false);
                  setEditingDepartment(null);
                }}
                className="flex-1 bg-gray-500 text-white py-2 rounded hover:bg-gray-600"
              >
                Cancel
              </button>
            </div>
          </form>
        </div>
      </div>
    );
  };

  const handleSaveItem = async (itemData: any) => {
    try {
      const tableMap = {
        company: 'company_codes',
        plant: 'plants',
        cost_center: 'cost_centers',
        profit_center: 'profit_centers',
        storage: 'storage_locations',
        purchasing: 'purchasing_organizations',
        currency: 'currencies',
        country: 'countries',
        fiscal_variant: 'fiscal_year_variants'
      };
      
      const table = tableMap[selectedObjectType];
      if (!table) return;
      
      // Add default values for required fields
      const dataToSave = {
        ...itemData,
        is_active: itemData.is_active ?? true
      };
      
      if (editingItem) {
        const { error } = await supabase
          .from(table)
          .update(dataToSave)
          .eq('id', editingItem.id);
        if (error) throw error;
      } else {
        const { error } = await supabase
          .from(table)
          .insert([dataToSave]);
        if (error) throw error;
      }
      
      fetchAllData();
      setShowModal(false);
      setEditingItem(null);
    } catch (error) {
      console.error('Error saving item:', error);
      alert('Error saving item: ' + error.message);
    }
  };

  const GenericModal = () => {
    const [formData, setFormData] = useState({});
    
    useEffect(() => {
      if (selectedObjectType && showModal) {
        setFormData(editingItem || {});
      }
    }, [selectedObjectType, showModal, editingItem]);

    const handleSubmit = (e: React.FormEvent) => {
      e.preventDefault();
      
      // Remove plant-specific validation since we now support 31 characters
      handleSaveItem(formData);
    };

    if (!showModal) return null;

    const getFields = () => {
      switch (selectedObjectType) {
        case 'company':
          return [
            { key: 'company_code', label: 'Company Code', type: 'text', required: true, maxLength: 31 },
            { key: 'company_name', label: 'Company Name', type: 'text', required: true, maxLength: 240 },
            { key: 'legal_entity_name', label: 'Legal Entity Name', type: 'text', required: true, maxLength: 240 },
            { key: 'currency', label: 'Currency', type: 'select', options: currencies.map(c => c.currency_code) },
            { key: 'country_code', label: 'Country', type: 'select', options: countries.map(c => ({ value: c.country_code, label: `${c.country_name} (${c.country_code})` })) }
          ];
        case 'plant':
          return [
            { key: 'plant_code', label: 'Plant Code', type: 'text', required: true, maxLength: 31 },
            { key: 'plant_name', label: 'Plant Name', type: 'text', required: true, maxLength: 240 },
            { key: 'address', label: 'Address', type: 'textarea' }
          ];
        case 'cost_center':
          return [
            { key: 'cost_center_code', label: 'Cost Center Code', type: 'text', required: true, maxLength: 31 },
            { key: 'cost_center_name', label: 'Cost Center Name', type: 'text', required: true, maxLength: 240 },
            { key: 'cost_center_type', label: 'Cost Center Type', type: 'select', options: ['PROJECT', 'OVERHEAD', 'PRODUCTION', 'SERVICE'] },
            { key: 'controlling_area_code', label: 'Controlling Area', type: 'select', options: controllingAreas.map(ca => ({ value: ca.cocarea_code, label: `${ca.cocarea_code} - ${ca.cocarea_name}` })) },
            { key: 'company_code', label: 'Company', type: 'select', options: companyCodes.map(c => ({ value: c.company_code, label: `${c.company_code} - ${c.company_name}` })) },
            { key: 'responsible_person', label: 'Responsible Person', type: 'text', maxLength: 255 }
          ];
        case 'profit_center':
          return [
            { key: 'profit_center_code', label: 'Profit Center Code', type: 'text', required: true, maxLength: 31 },
            { key: 'profit_center_name', label: 'Profit Center Name', type: 'text', required: true, maxLength: 240 },
            { key: 'controlling_area_code', label: 'Controlling Area', type: 'select', options: controllingAreas.map(ca => ({ value: ca.cocarea_code, label: `${ca.cocarea_code} - ${ca.cocarea_name}` })) },
            { key: 'company_code', label: 'Company', type: 'select', options: companyCodes.map(c => ({ value: c.company_code, label: `${c.company_code} - ${c.company_name}` })) },
            { key: 'responsible_person', label: 'Responsible Person', type: 'text', maxLength: 255 }
          ];
        case 'storage':
          return [
            { key: 'sloc_code', label: 'Storage Location Code', type: 'text', required: true, maxLength: 31 },
            { key: 'sloc_name', label: 'Storage Location Name', type: 'text', required: true, maxLength: 240 },
            { key: 'location_type', label: 'Storage Type', type: 'select', options: ['WAREHOUSE', 'YARD', 'Raw Materials', 'Finished Goods', 'Work in Process', 'Spare Parts', 'Consumables', 'Project Store'] }
          ];
        case 'purchasing':
          return [
            { key: 'porg_code', label: 'Purchasing Org Code', type: 'text', required: true, maxLength: 31 },
            { key: 'porg_name', label: 'Purchasing Org Name', type: 'text', required: true, maxLength: 240 },
            { key: 'currency', label: 'Currency', type: 'select', options: ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY', 'INR', 'BRL', 'MXN', 'ZAR', 'SGD', 'HKD', 'NOK', 'SEK', 'DKK', 'PLN', 'CZK', 'HUF', 'RUB', 'TRY', 'KRW', 'THB', 'MYR', 'IDR', 'PHP', 'VND', 'EGP', 'SAR', 'AED', 'QAR', 'KWD', 'BHD', 'OMR', 'JOD', 'LBP', 'ILS', 'CLP', 'PEN', 'COP', 'ARS', 'UYU'] }
          ];
        case 'currency':
          return [
            { key: 'currency_code', label: 'Currency Code', type: 'text', required: true, maxLength: 3 },
            { key: 'currency_name', label: 'Currency Name', type: 'text', required: true },
            { key: 'currency_symbol', label: 'Symbol', type: 'text', maxLength: 10 },
            { key: 'decimal_places', label: 'Decimal Places', type: 'number', min: 0, max: 4 }
          ];
        case 'country':
          return [
            { key: 'country_code', label: 'Country Code', type: 'text', required: true, maxLength: 2 },
            { key: 'country_name', label: 'Country Name', type: 'text', required: true },
            { key: 'country_code_3', label: '3-Letter Code', type: 'text', maxLength: 3 },
            { key: 'region', label: 'Region', type: 'select', options: ['Americas', 'Europe', 'Asia-Pacific', 'Middle East & Africa'] }
          ];
        case 'fiscal_variant':
          return [
            { key: 'variant_code', label: 'Variant Code', type: 'text', required: true, maxLength: 2 },
            { key: 'variant_name', label: 'Variant Name', type: 'text', required: true },
            { key: 'description', label: 'Description', type: 'textarea' },
            { key: 'start_month', label: 'Start Month', type: 'number', required: true, min: 1, max: 12 },
            { key: 'start_day', label: 'Start Day', type: 'number', required: true, min: 1, max: 31 },
            { key: 'periods', label: 'Number of Periods', type: 'number', min: 1, max: 52 }
          ];
        default:
          return [];
      }
    };

    const fields = getFields();
    const objectName = objectTypes.find(t => t.id === selectedObjectType)?.name || 'Object';

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg p-6 w-full max-w-md">
          <h3 className="text-lg font-semibold mb-4">
            {editingItem ? `Edit ${objectName}` : `Add New ${objectName}`}
          </h3>
          
          <form onSubmit={handleSubmit} className="space-y-4">
            {fields.map(field => (
              <div key={field.key}>
                <label className="block text-sm font-medium mb-1">
                  {field.label} {field.required && '*'}
                </label>
                {field.type === 'textarea' ? (
                  <textarea
                    value={formData[field.key] || ''}
                    onChange={(e) => setFormData({...formData, [field.key]: e.target.value})}
                    className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-blue-500"
                    rows={3}
                    required={field.required}
                  />
                ) : field.type === 'select' ? (
                  <select
                    value={formData[field.key] || ''}
                    onChange={(e) => setFormData({...formData, [field.key]: e.target.value})}
                    className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-blue-500"
                    required={field.required}
                  >
                    <option value="">Select...</option>
                    {Array.isArray(field.options) && field.options.map(option => {
                      if (typeof option === 'object' && option.value && option.label) {
                        return <option key={option.value} value={option.value}>{option.label}</option>;
                      }
                      return <option key={option} value={option}>{option}</option>;
                    })}
                  </select>
                ) : field.type === 'number' ? (
                  <input
                    type="number"
                    value={formData[field.key] || ''}
                    onChange={(e) => setFormData({...formData, [field.key]: parseInt(e.target.value) || 0})}
                    className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-blue-500"
                    min={field.min}
                    max={field.max}
                    required={field.required}
                  />
                ) : (
                  <input
                    type="text"
                    value={formData[field.key] || ''}
                    onChange={(e) => {
                      let value = field.maxLength ? e.target.value.toUpperCase() : e.target.value;
                      setFormData({...formData, [field.key]: value});
                    }}
                    className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-blue-500"
                    maxLength={field.maxLength}
                    required={field.required}
                    pattern={field.key === 'plant_code' ? '.{6}' : undefined}
                    title={field.key === 'plant_code' ? 'Plant code must be exactly 6 characters' : undefined}
                  />
                )}
              </div>
            ))}
            
            <div className="flex items-center">
              <input
                type="checkbox"
                id="generic_is_active"
                checked={formData.is_active ?? true}
                onChange={(e) => setFormData({...formData, is_active: e.target.checked})}
                className="mr-2"
              />
              <label htmlFor="generic_is_active" className="text-sm">Active</label>
            </div>
            
            <div className="flex space-x-3 pt-4">
              <button
                type="submit"
                className="flex-1 bg-blue-600 text-white py-2 rounded hover:bg-blue-700"
              >
                {editingItem ? 'Update' : 'Create'}
              </button>
              <button
                type="button"
                onClick={() => {
                  setShowModal(false);
                  setEditingItem(null);
                }}
                className="flex-1 bg-gray-500 text-white py-2 rounded hover:bg-gray-600"
              >
                Cancel
              </button>
            </div>
          </form>
        </div>
      </div>
    );
  };
  const handleSaveControllingArea = async (areaData: any) => {
    try {
      if (editingControllingArea) {
        const { error } = await supabase
          .from('controlling_areas')
          .update(areaData)
          .eq('id', editingControllingArea.id);
        if (error) throw error;
      } else {
        const { error } = await supabase
          .from('controlling_areas')
          .insert([areaData]);
        if (error) throw error;
      }
      
      fetchAllData();
      setShowControllingAreaModal(false);
      setEditingControllingArea(null);
    } catch (error) {
      console.error('Error saving controlling area:', error);
      alert('Error saving controlling area: ' + error.message);
    }
  };

  const ControllingAreaModal = () => {
    const [formData, setFormData] = useState({
      cocarea_code: editingControllingArea?.cocarea_code || '',
      cocarea_name: editingControllingArea?.cocarea_name || '',
      currency: editingControllingArea?.currency || 'USD',
      fiscal_year_variant: editingControllingArea?.fiscal_year_variant || 'K4',
      is_active: editingControllingArea?.is_active ?? true
    });

    const handleSubmit = (e: React.FormEvent) => {
      e.preventDefault();
      if (!formData.cocarea_code || !formData.cocarea_name) {
        alert('Code and Name are required');
        return;
      }
      handleSaveControllingArea(formData);
    };

    if (!showControllingAreaModal) return null;

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg p-6 w-full max-w-md">
          <h3 className="text-lg font-semibold mb-4">
            {editingControllingArea ? 'Edit Controlling Area' : 'Add New Controlling Area'}
          </h3>
          
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-1">Controlling Area Code *</label>
              <input
                type="text"
                value={formData.cocarea_code}
                onChange={(e) => setFormData({...formData, cocarea_code: e.target.value.toUpperCase()})}
                className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-blue-500 font-mono"
                placeholder="e.g., MAIN-CONTROLLING-AREA"
                maxLength={31}
                required
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium mb-1">Controlling Area Name *</label>
              <input
                type="text"
                value={formData.cocarea_name}
                onChange={(e) => setFormData({...formData, cocarea_name: e.target.value})}
                className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-blue-500"
                placeholder="e.g., Main Controlling Area for Operations"
                maxLength={240}
                required
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium mb-1">Currency</label>
              <select
                value={formData.currency}
                onChange={(e) => setFormData({...formData, currency: e.target.value})}
                className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Select Currency...</option>
                {currencies.map(currency => (
                  <option key={currency.currency_code} value={currency.currency_code}>
                    {currency.currency_code} - {currency.currency_name}
                  </option>
                ))}
              </select>
            </div>
            
            <div>
              <label className="block text-sm font-medium mb-1">Fiscal Year Variant</label>
              <select
                value={formData.fiscal_year_variant}
                onChange={(e) => setFormData({...formData, fiscal_year_variant: e.target.value})}
                className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Select Fiscal Year...</option>
                {fiscalYearVariants.map(variant => (
                  <option key={variant.variant_code} value={variant.variant_code}>
                    {variant.variant_code} - {variant.variant_name}
                  </option>
                ))}
              </select>
            </div>
            
            <div className="flex items-center">
              <input
                type="checkbox"
                id="ca_is_active"
                checked={formData.is_active}
                onChange={(e) => setFormData({...formData, is_active: e.target.checked})}
                className="mr-2"
              />
              <label htmlFor="ca_is_active" className="text-sm">Active</label>
            </div>
            
            <div className="flex space-x-3 pt-4">
              <button
                type="submit"
                className="flex-1 bg-blue-600 text-white py-2 rounded hover:bg-blue-700"
              >
                {editingControllingArea ? 'Update' : 'Create'}
              </button>
              <button
                type="button"
                onClick={() => {
                  setShowControllingAreaModal(false);
                  setEditingControllingArea(null);
                }}
                className="flex-1 bg-gray-500 text-white py-2 rounded hover:bg-gray-600"
              >
                Cancel
              </button>
            </div>
          </form>
        </div>
      </div>
    );
  };

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
      case 'manage': return renderManageObjects();
      case 'hierarchy': return renderHierarchy();
      case 'assignments': return renderAssignments();
      default: return renderManageObjects();
    }
  };

  return (
    <>
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
      <DepartmentModal />
      <ControllingAreaModal />
      <GenericModal />
    </>
  );
}