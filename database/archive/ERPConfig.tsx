// DEPRECATED: This file is marked for removal - duplicate of ERPConfigurationModuleComplete.tsx
// TODO: Remove after confirming no imports
/*
'use client';

import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase-simple';

export default function ERPConfig() {
  const [activeTab, setActiveTab] = useState('materials');
  const [materialTypes, setMaterialTypes] = useState<any[]>([]);
  const [valuationClasses, setValuationClasses] = useState<any[]>([]);
  const [movementTypes, setMovementTypes] = useState<any[]>([]);
  const [accountKeys, setAccountKeys] = useState<any[]>([]);
  const [glAccounts, setGLAccounts] = useState<any[]>([]);
  const [accountDetermination, setAccountDetermination] = useState<any[]>([]);

  useEffect(() => {
    fetchAllData();
  }, []);

  const fetchAllData = async () => {
    const [matTypes, valClasses, movTypes, accKeys, glAcc, accDet] = await Promise.all([
      supabase.from('material_types').select('*').order('material_type_code'),
      supabase.from('valuation_classes').select('*').order('valuation_class_code'),
      supabase.from('movement_types').select('*').order('movement_type_code'),
      supabase.from('account_keys').select('*').order('account_key_code'),
      supabase.from('gl_accounts').select('*, chart:chart_of_accounts(chart_name)').order('account_number'),
      supabase.from('account_determination').select(`
        *,
        company:company_codes(company_code),
        valuation_class:valuation_classes(valuation_class_code),
        account_key:account_keys(account_key_code),
        gl_account:gl_accounts(account_number, account_name)
      `).order('id')
    ]);

    if (matTypes.data) setMaterialTypes(matTypes.data);
    if (valClasses.data) setValuationClasses(valClasses.data);
    if (movTypes.data) setMovementTypes(movTypes.data);
    if (accKeys.data) setAccountKeys(accKeys.data);
    if (glAcc.data) setGLAccounts(glAcc.data);
    if (accDet.data) setAccountDetermination(accDet.data);
  };

  const tabs = [
    { id: 'materials', name: 'Material Types', icon: '🧱' },
    { id: 'valuation', name: 'Valuation Classes', icon: '💰' },
    { id: 'movements', name: 'Movement Types', icon: '📦' },
    { id: 'accounts', name: 'Account Keys', icon: '🔑' },
    { id: 'gl', name: 'GL Accounts', icon: '📊' },
    { id: 'determination', name: 'Account Determination', icon: '⚙️' }
  ];

  const renderMaterialTypes = () => (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold">Material Types (like SAP T134)</h3>
      </div>
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left">Code</th>
              <th className="px-4 py-3 text-left">Name</th>
              <th className="px-4 py-3 text-left">Description</th>
              <th className="px-4 py-3 text-left">Inventory Managed</th>
              <th className="px-4 py-3 text-left">Status</th>
            </tr>
          </thead>
          <tbody>
            {materialTypes.map((type) => (
              <tr key={type.id} className="border-t">
                <td className="px-4 py-3 font-mono text-sm font-bold">{type.material_type_code}</td>
                <td className="px-4 py-3">{type.material_type_name}</td>
                <td className="px-4 py-3 text-sm">{type.description}</td>
                <td className="px-4 py-3">
                  <span className={`px-2 py-1 rounded text-xs ${
                    type.inventory_managed ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
                  }`}>
                    {type.inventory_managed ? 'Yes' : 'No'}
                  </span>
                </td>
                <td className="px-4 py-3">
                  <span className={`px-2 py-1 rounded text-xs ${
                    type.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                  }`}>
                    {type.is_active ? 'Active' : 'Inactive'}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );

  const renderValuationClasses = () => (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold">Valuation Classes (like SAP T025)</h3>
      </div>
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left">Code</th>
              <th className="px-4 py-3 text-left">Name</th>
              <th className="px-4 py-3 text-left">Description</th>
              <th className="px-4 py-3 text-left">Status</th>
            </tr>
          </thead>
          <tbody>
            {valuationClasses.map((vc) => (
              <tr key={vc.id} className="border-t">
                <td className="px-4 py-3 font-mono text-sm font-bold">{vc.valuation_class_code}</td>
                <td className="px-4 py-3">{vc.valuation_class_name}</td>
                <td className="px-4 py-3 text-sm">{vc.description}</td>
                <td className="px-4 py-3">
                  <span className={`px-2 py-1 rounded text-xs ${
                    vc.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                  }`}>
                    {vc.is_active ? 'Active' : 'Inactive'}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );

  const renderMovementTypes = () => (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold">Movement Types (like SAP T156)</h3>
      </div>
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left">Code</th>
              <th className="px-4 py-3 text-left">Name</th>
              <th className="px-4 py-3 text-left">Indicator</th>
              <th className="px-4 py-3 text-left">Special Stock</th>
              <th className="px-4 py-3 text-left">Description</th>
            </tr>
          </thead>
          <tbody>
            {movementTypes.map((mt) => (
              <tr key={mt.id} className="border-t">
                <td className="px-4 py-3 font-mono text-sm font-bold">{mt.movement_type_code}</td>
                <td className="px-4 py-3">{mt.movement_type_name}</td>
                <td className="px-4 py-3">
                  <span className={`px-2 py-1 rounded text-xs ${
                    mt.movement_indicator === '+' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                  }`}>
                    {mt.movement_indicator === '+' ? 'Receipt' : 'Issue'}
                  </span>
                </td>
                <td className="px-4 py-3 font-mono text-sm">{mt.special_stock_indicator || '-'}</td>
                <td className="px-4 py-3 text-sm">{mt.description}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );

  const renderAccountKeys = () => (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold">Account Keys (like SAP T030)</h3>
      </div>
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left">Code</th>
              <th className="px-4 py-3 text-left">Name</th>
              <th className="px-4 py-3 text-left">Debit/Credit</th>
              <th className="px-4 py-3 text-left">Description</th>
              <th className="px-4 py-3 text-left">Status</th>
            </tr>
          </thead>
          <tbody>
            {accountKeys.map((ak) => (
              <tr key={ak.id} className="border-t">
                <td className="px-4 py-3 font-mono text-sm font-bold">{ak.account_key_code}</td>
                <td className="px-4 py-3">{ak.account_key_name}</td>
                <td className="px-4 py-3">
                  <span className={`px-2 py-1 rounded text-xs ${
                    ak.debit_credit_indicator === 'D' ? 'bg-blue-100 text-blue-800' : 'bg-green-100 text-green-800'
                  }`}>
                    {ak.debit_credit_indicator === 'D' ? 'Debit' : 'Credit'}
                  </span>
                </td>
                <td className="px-4 py-3 text-sm">{ak.description}</td>
                <td className="px-4 py-3">
                  <span className={`px-2 py-1 rounded text-xs ${
                    ak.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                  }`}>
                    {ak.is_active ? 'Active' : 'Inactive'}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );

  const renderGLAccounts = () => (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold">GL Accounts Master</h3>
      </div>
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left">Account Number</th>
              <th className="px-4 py-3 text-left">Account Name</th>
              <th className="px-4 py-3 text-left">Account Type</th>
              <th className="px-4 py-3 text-left">Chart</th>
              <th className="px-4 py-3 text-left">Status</th>
            </tr>
          </thead>
          <tbody>
            {glAccounts.map((gl) => (
              <tr key={gl.id} className="border-t">
                <td className="px-4 py-3 font-mono text-sm font-bold">{gl.account_number}</td>
                <td className="px-4 py-3">{gl.account_name}</td>
                <td className="px-4 py-3">
                  <span className={`px-2 py-1 rounded text-xs ${
                    gl.account_type === 'A' ? 'bg-blue-100 text-blue-800' :
                    gl.account_type === 'L' ? 'bg-red-100 text-red-800' :
                    gl.account_type === 'E' ? 'bg-orange-100 text-orange-800' :
                    'bg-green-100 text-green-800'
                  }`}>
                    {gl.account_type === 'A' ? 'Asset' :
                     gl.account_type === 'L' ? 'Liability' :
                     gl.account_type === 'E' ? 'Expense' : 'Revenue'}
                  </span>
                </td>
                <td className="px-4 py-3 text-sm">{gl.chart?.chart_name || 'N/A'}</td>
                <td className="px-4 py-3">
                  <span className={`px-2 py-1 rounded text-xs ${
                    gl.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                  }`}>
                    {gl.is_active ? 'Active' : 'Inactive'}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );

  const renderAccountDetermination = () => (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold">Account Determination (Core ERP Logic)</h3>
      </div>
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left">Company</th>
              <th className="px-4 py-3 text-left">Valuation Class</th>
              <th className="px-4 py-3 text-left">Account Key</th>
              <th className="px-4 py-3 text-left">GL Account</th>
              <th className="px-4 py-3 text-left">Account Name</th>
            </tr>
          </thead>
          <tbody>
            {accountDetermination.map((ad) => (
              <tr key={ad.id} className="border-t">
                <td className="px-4 py-3 font-mono text-sm">{ad.company?.company_code}</td>
                <td className="px-4 py-3 font-mono text-sm">{ad.valuation_class?.valuation_class_code}</td>
                <td className="px-4 py-3 font-mono text-sm">{ad.account_key?.account_key_code}</td>
                <td className="px-4 py-3 font-mono text-sm font-bold">{ad.gl_account?.account_number}</td>
                <td className="px-4 py-3 text-sm">{ad.gl_account?.account_name}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <h4 className="font-medium text-blue-900 mb-2">How Account Determination Works:</h4>
        <p className="text-sm text-blue-800">
          Material → Material Type → Valuation Class + Movement Type → Account Key = GL Account
        </p>
        <p className="text-xs text-blue-600 mt-1">
          Example: Cement (ROH) → 3000 + Movement 101 → BSX = 140000 (Raw Materials Inventory)
        </p>
      </div>
    </div>
  );

  const renderContent = () => {
    switch (activeTab) {
      case 'materials': return renderMaterialTypes();
      case 'valuation': return renderValuationClasses();
      case 'movements': return renderMovementTypes();
      case 'accounts': return renderAccountKeys();
      case 'gl': return renderGLAccounts();
      case 'determination': return renderAccountDetermination();
      default: return renderMaterialTypes();
    }
  };

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold">ERP Configuration</h1>
        <p className="text-gray-600">Enterprise Resource Planning setup - Material Types, Valuation Classes, Account Determination</p>
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
*/