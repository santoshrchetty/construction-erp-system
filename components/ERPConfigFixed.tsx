'use client';

import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase-simple';

export default function ERPConfigEnhanced() {
  const [activeTab, setActiveTab] = useState('material-groups');
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [modalType, setModalType] = useState<'create' | 'edit' | 'delete'>('create');
  const [selectedItem, setSelectedItem] = useState<any>(null);
  const [formData, setFormData] = useState<any>({});
  const [data, setData] = useState<any>({
    materialGroups: [],
    vendorCategories: [],
    paymentTerms: [],
    uomGroups: [],
    materialStatus: []
  });

  useEffect(() => {
    loadAllData();
  }, []);

  const loadAllData = async () => {
    try {
      setLoading(true);
      const [materialGroups, vendorCategories, paymentTerms, uomGroups, materialStatus] = await Promise.all([
        supabase.from('material_groups').select('*').order('group_code'),
        supabase.from('vendor_categories').select('*').order('category_code'),
        supabase.from('payment_terms').select('*').order('term_code'),
        supabase.from('uom_groups').select('*').order('base_uom'),
        supabase.from('material_status').select('*').order('status_code')
      ]);

      setData({
        materialGroups: materialGroups.data || [],
        vendorCategories: vendorCategories.data || [],
        paymentTerms: paymentTerms.data || [],
        uomGroups: uomGroups.data || [],
        materialStatus: materialStatus.data || []
      });
    } catch (error) {
      console.error('Error loading ERP config data:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleCreate = () => {
    setSelectedItem(null);
    setFormData({ is_active: true });
    setModalType('create');
    setShowModal(true);
  };

  const handleEdit = (item: any) => {
    setSelectedItem(item);
    setFormData(item);
    setModalType('edit');
    setShowModal(true);
  };

  const handleDelete = (item: any) => {
    setSelectedItem(item);
    setModalType('delete');
    setShowModal(true);
  };

  const handleSave = async () => {
    try {
      const tableName = getTableName(activeTab);
      if (modalType === 'create') {
        const { error } = await supabase.from(tableName).insert(formData);
        if (error) throw error;
      } else if (modalType === 'edit') {
        const { error } = await supabase.from(tableName).update(formData).eq('id', selectedItem.id);
        if (error) throw error;
      } else if (modalType === 'delete') {
        const { error } = await supabase.from(tableName).delete().eq('id', selectedItem.id);
        if (error) throw error;
      }
      setShowModal(false);
      loadAllData();
    } catch (error: any) {
      alert(`Error: ${error.message}`);
    }
  };

  const getTableName = (tabId: string) => {
    const tableMap: { [key: string]: string } = {
      'material-groups': 'material_groups',
      'vendor-categories': 'vendor_categories',
      'payment-terms': 'payment_terms',
      'uom-groups': 'uom_groups',
      'material-status': 'material_status'
    };
    return tableMap[tabId] || 'material_groups';
  };

  const tabs = [
    { id: 'material-groups', label: 'Material Groups', icon: '📋' },
    { id: 'vendor-categories', label: 'Vendor Categories', icon: '🏢' },
    { id: 'payment-terms', label: 'Payment Terms', icon: '💳' },
    { id: 'uom-groups', label: 'Units of Measure', icon: '📏' },
    { id: 'material-status', label: 'Material Status', icon: '🚦' }
  ];

  const renderTable = (tableData: any[], columns: string[], title: string) => (
    <div className="bg-white rounded-lg shadow-sm border border-gray-200">
      <div className="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
        <h3 className="text-lg font-semibold text-gray-900">{title}</h3>
        <button
          onClick={handleCreate}
          className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors duration-200 flex items-center space-x-2"
        >
          <span>➕</span>
          <span>Add New</span>
        </button>
      </div>
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              {columns.map(col => (
                <th key={col} className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  {col.replace('_', ' ')}
                </th>
              ))}
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {tableData.map((row, idx) => (
              <tr key={idx} className="hover:bg-gray-50">
                {columns.map(col => (
                  <td key={col} className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {typeof row[col] === 'boolean' ? (row[col] ? '✅' : '❌') : row[col] || '-'}
                  </td>
                ))}
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                  <button
                    onClick={() => handleEdit(row)}
                    className="text-blue-600 hover:text-blue-900 bg-blue-50 hover:bg-blue-100 px-2 py-1 rounded transition-colors"
                  >
                    ✏️
                  </button>
                  <button
                    onClick={() => handleDelete(row)}
                    className="text-red-600 hover:text-red-900 bg-red-50 hover:bg-red-100 px-2 py-1 rounded transition-colors"
                  >
                    🗑️
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );

  const renderFormFields = () => {
    const getFields = () => {
      switch (activeTab) {
        case 'material-groups':
          return [
            { name: 'group_code', label: 'Group Code', type: 'text', required: true, maxLength: 9 },
            { name: 'group_name', label: 'Group Name', type: 'text', required: true },
            { name: 'description', label: 'Description', type: 'textarea' }
          ];
        case 'vendor-categories':
          return [
            { name: 'category_code', label: 'Category Code', type: 'text', required: true, maxLength: 4 },
            { name: 'category_name', label: 'Category Name', type: 'text', required: true },
            { name: 'description', label: 'Description', type: 'textarea' }
          ];
        case 'payment-terms':
          return [
            { name: 'term_code', label: 'Term Code', type: 'text', required: true, maxLength: 4 },
            { name: 'term_name', label: 'Term Name', type: 'text', required: true },
            { name: 'net_days', label: 'Net Days', type: 'number', required: true },
            { name: 'discount_days', label: 'Discount Days', type: 'number' },
            { name: 'discount_percent', label: 'Discount %', type: 'number', step: '0.01' }
          ];
        case 'uom-groups':
          return [
            { name: 'base_uom', label: 'Base UoM', type: 'text', required: true, maxLength: 3 },
            { name: 'uom_name', label: 'UoM Name', type: 'text', required: true },
            { name: 'dimension', label: 'Dimension', type: 'select', options: ['PIECE', 'WEIGHT', 'LENGTH', 'AREA', 'VOLUME'] }
          ];
        case 'material-status':
          return [
            { name: 'status_code', label: 'Status Code', type: 'text', required: true, maxLength: 2 },
            { name: 'status_name', label: 'Status Name', type: 'text', required: true },
            { name: 'allow_procurement', label: 'Allow Procurement', type: 'checkbox' },
            { name: 'allow_consumption', label: 'Allow Consumption', type: 'checkbox' }
          ];
        default:
          return [];
      }
    };

    const fields = getFields();
    return (
      <div className="space-y-4">
        {fields.map(field => (
          <div key={field.name}>
            <label className="block text-sm font-medium mb-1">
              {field.label} {field.required && '*'}
            </label>
            {field.type === 'textarea' ? (
              <textarea
                value={formData[field.name] || ''}
                onChange={(e) => setFormData({...formData, [field.name]: e.target.value})}
                className="w-full border rounded px-3 py-2"
                rows={3}
                required={field.required}
              />
            ) : field.type === 'select' ? (
              <select
                value={formData[field.name] || ''}
                onChange={(e) => setFormData({...formData, [field.name]: e.target.value})}
                className="w-full border rounded px-3 py-2"
                required={field.required}
              >
                <option value="">Select {field.label}</option>
                {field.options?.map(option => (
                  <option key={option} value={option}>{option}</option>
                ))}
              </select>
            ) : field.type === 'checkbox' ? (
              <label className="flex items-center">
                <input
                  type="checkbox"
                  checked={formData[field.name] || false}
                  onChange={(e) => setFormData({...formData, [field.name]: e.target.checked})}
                  className="mr-2"
                />
                {field.label}
              </label>
            ) : (
              <input
                type={field.type}
                value={formData[field.name] || ''}
                onChange={(e) => setFormData({...formData, [field.name]: field.type === 'number' ? Number(e.target.value) : e.target.value})}
                className="w-full border rounded px-3 py-2"
                maxLength={field.maxLength}
                step={field.step}
                required={field.required}
              />
            )}
          </div>
        ))}
        <div>
          <label className="flex items-center">
            <input
              type="checkbox"
              checked={formData.is_active !== false}
              onChange={(e) => setFormData({...formData, is_active: e.target.checked})}
              className="mr-2"
            />
            Active
          </label>
        </div>
      </div>
    );
  };

  const renderTabContent = () => {
    switch (activeTab) {
      case 'material-groups':
        return renderTable(data.materialGroups, ['group_code', 'group_name', 'description', 'is_active'], 'Material Groups Configuration');
      case 'vendor-categories':
        return renderTable(data.vendorCategories, ['category_code', 'category_name', 'description', 'is_active'], 'Vendor Categories Configuration');
      case 'payment-terms':
        return renderTable(data.paymentTerms, ['term_code', 'term_name', 'net_days', 'discount_days', 'discount_percent', 'is_active'], 'Payment Terms Configuration');
      case 'uom-groups':
        return renderTable(data.uomGroups, ['base_uom', 'uom_name', 'dimension', 'is_active'], 'Units of Measure Configuration');
      case 'material-status':
        return renderTable(data.materialStatus, ['status_code', 'status_name', 'allow_procurement', 'allow_consumption', 'is_active'], 'Material Status Configuration');
      default:
        return <div>Select a tab to view configuration</div>;
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 p-4 sm:p-6">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/3 mb-6"></div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 mb-6">
            {[...Array(5)].map((_, i) => (
              <div key={i} className="h-12 bg-gray-200 rounded"></div>
            ))}
          </div>
          <div className="h-96 bg-gray-200 rounded"></div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 p-4 sm:p-6">
      <div className="max-w-7xl mx-auto">
        <div className="mb-6 sm:mb-8">
          <div className="flex items-center space-x-3 mb-2">
            <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center">
              <span className="text-white font-bold text-sm">ERP</span>
            </div>
            <h1 className="text-2xl sm:text-3xl font-bold text-gray-900">ERP Configuration</h1>
          </div>
          <p className="text-gray-600 text-sm sm:text-base">Configure master data and system parameters for your ERP system</p>
        </div>

        {/* Tab Navigation */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 mb-6">
          <div className="p-4 border-b border-gray-200">
            <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-2">
              {tabs.map(tab => (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`flex items-center space-x-2 px-3 py-2 rounded-lg text-sm font-medium transition-colors duration-200 ${
                    activeTab === tab.id
                      ? 'bg-blue-100 text-blue-700 border border-blue-200'
                      : 'text-gray-600 hover:text-gray-900 hover:bg-gray-50'
                  }`}
                >
                  <span className="text-lg">{tab.icon}</span>
                  <span className="hidden sm:inline truncate">{tab.label}</span>
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Tab Content */}
        <div className="space-y-6">
          {renderTabContent()}
        </div>

        {/* CRUD Modal */}
        {showModal && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-lg shadow-xl w-full max-w-md">
              <div className="px-6 py-4 border-b border-gray-200">
                <h3 className="text-lg font-semibold text-gray-900">
                  {modalType === 'create' && 'Create New Entry'}
                  {modalType === 'edit' && 'Edit Entry'}
                  {modalType === 'delete' && 'Delete Entry'}
                </h3>
              </div>
              
              <div className="p-6">
                {modalType === 'delete' ? (
                  <div className="text-center">
                    <div className="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
                      <span className="text-2xl">⚠️</span>
                    </div>
                    <p className="text-gray-600 mb-6">Are you sure you want to delete this entry? This action cannot be undone.</p>
                  </div>
                ) : (
                  renderFormFields()
                )}
              </div>
              
              <div className="px-6 py-4 border-t border-gray-200 flex justify-end space-x-3">
                <button
                  onClick={() => setShowModal(false)}
                  className="px-4 py-2 text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={handleSave}
                  className={`px-4 py-2 text-white rounded-lg transition-colors ${
                    modalType === 'delete' 
                      ? 'bg-red-600 hover:bg-red-700' 
                      : 'bg-blue-600 hover:bg-blue-700'
                  }`}
                >
                  {modalType === 'create' && 'Create'}
                  {modalType === 'edit' && 'Update'}
                  {modalType === 'delete' && 'Delete'}
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}