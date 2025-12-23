'use client'

import React, { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase-simple'
import { Plus, Edit2, Trash2, DollarSign, PieChart, TrendingUp, Calculator } from 'lucide-react'

interface GLAccount {
  id: string
  account_code: string
  account_name: string
  account_type: string
  is_active: boolean
}

interface ValuationClass {
  id: string
  class_code: string
  class_name: string
  description: string
  is_active: boolean
}

interface AccountKey {
  id: string
  key_code: string
  key_name: string
  description: string
  is_active: boolean
}

export default function FinanceControllingModule() {
  const [activeTab, setActiveTab] = useState('accounts')
  const [glAccounts, setGLAccounts] = useState<GLAccount[]>([])
  const [valuationClasses, setValuationClasses] = useState<ValuationClass[]>([])
  const [accountKeys, setAccountKeys] = useState<AccountKey[]>([])
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    setLoading(true)
    try {
      const [glRes, vcRes, akRes] = await Promise.all([
        supabase.from('gl_accounts').select('*').order('account_code'),
        supabase.from('valuation_classes').select('*').order('class_code'),
        supabase.from('account_keys').select('*').order('key_code')
      ])

      if (glRes.data) setGLAccounts(glRes.data)
      if (vcRes.data) setValuationClasses(vcRes.data)
      if (akRes.data) setAccountKeys(akRes.data)
    } catch (error) {
      console.error('Error loading data:', error)
    } finally {
      setLoading(false)
    }
  }

  const tabs = [
    { id: 'accounts', label: 'GL Accounts', icon: DollarSign },
    { id: 'valuation', label: 'Valuation', icon: Calculator },
    { id: 'controlling', label: 'Controlling', icon: PieChart },
    { id: 'reporting', label: 'Reporting', icon: TrendingUp }
  ]

  const renderAccountsTab = () => (
    <div className="space-y-6">
      <div className="bg-white rounded-lg shadow-sm border p-4">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-lg font-semibold flex items-center gap-2">
            <DollarSign className="w-5 h-5" />
            General Ledger Accounts
          </h3>
          <button className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors">
            <Plus className="w-4 h-4" />
            <span className="hidden sm:inline">Add Account</span>
          </button>
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b">
                <th className="text-left py-2 px-3">Account Code</th>
                <th className="text-left py-2 px-3">Account Name</th>
                <th className="text-left py-2 px-3 hidden sm:table-cell">Type</th>
                <th className="text-left py-2 px-3">Status</th>
                <th className="text-right py-2 px-3">Actions</th>
              </tr>
            </thead>
            <tbody>
              {glAccounts.map((account) => (
                <tr key={account.id} className="border-b hover:bg-gray-50">
                  <td className="py-2 px-3 font-medium">{account.account_code}</td>
                  <td className="py-2 px-3">{account.account_name}</td>
                  <td className="py-2 px-3 hidden sm:table-cell">
                    <span className="px-2 py-1 bg-blue-100 text-blue-800 rounded text-xs">
                      {account.account_type}
                    </span>
                  </td>
                  <td className="py-2 px-3">
                    <span className={`px-2 py-1 rounded text-xs ${
                      account.is_active 
                        ? 'bg-green-100 text-green-800' 
                        : 'bg-red-100 text-red-800'
                    }`}>
                      {account.is_active ? 'Active' : 'Inactive'}
                    </span>
                  </td>
                  <td className="py-2 px-3 text-right">
                    <div className="flex justify-end gap-1">
                      <button className="p-1 text-blue-600 hover:bg-blue-100 rounded">
                        <Edit2 className="w-4 h-4" />
                      </button>
                      <button className="p-1 text-red-600 hover:bg-red-100 rounded">
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )

  const renderValuationTab = () => (
    <div className="space-y-6">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-lg shadow-sm border p-4">
          <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
            <Calculator className="w-5 h-5" />
            Valuation Classes
          </h3>
          <div className="space-y-2 max-h-64 overflow-y-auto">
            {valuationClasses.map((valClass) => (
              <div key={valClass.id} className="flex justify-between items-center p-2 bg-gray-50 rounded">
                <div>
                  <span className="font-medium">{valClass.class_code}</span>
                  <span className="text-gray-600 ml-2">{valClass.class_name}</span>
                  <div className="text-xs text-gray-500">{valClass.description}</div>
                </div>
                <div className="flex gap-1">
                  <button className="p-1 text-blue-600 hover:bg-blue-100 rounded">
                    <Edit2 className="w-4 h-4" />
                  </button>
                  <button className="p-1 text-red-600 hover:bg-red-100 rounded">
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm border p-4">
          <h3 className="text-lg font-semibold mb-4">Account Keys</h3>
          <div className="space-y-2 max-h-64 overflow-y-auto">
            {accountKeys.map((key) => (
              <div key={key.id} className="flex justify-between items-center p-2 bg-gray-50 rounded">
                <div>
                  <span className="font-medium">{key.key_code}</span>
                  <span className="text-gray-600 ml-2">{key.key_name}</span>
                  <div className="text-xs text-gray-500">{key.description}</div>
                </div>
                <div className="flex gap-1">
                  <button className="p-1 text-blue-600 hover:bg-blue-100 rounded">
                    <Edit2 className="w-4 h-4" />
                  </button>
                  <button className="p-1 text-red-600 hover:bg-red-100 rounded">
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )

  const renderControllingTab = () => (
    <div className="bg-white rounded-lg shadow-sm border p-4">
      <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
        <PieChart className="w-5 h-5" />
        Cost Centers & Controlling
      </h3>
      <div className="text-center py-8 text-gray-500">
        <PieChart className="w-12 h-12 mx-auto mb-4 opacity-50" />
        <p>Cost center management coming soon...</p>
        <p className="text-sm">Cost centers, profit centers, and internal orders</p>
      </div>
    </div>
  )

  const renderReportingTab = () => (
    <div className="bg-white rounded-lg shadow-sm border p-4">
      <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
        <TrendingUp className="w-5 h-5" />
        Financial Reporting
      </h3>
      <div className="text-center py-8 text-gray-500">
        <TrendingUp className="w-12 h-12 mx-auto mb-4 opacity-50" />
        <p>Financial reports coming soon...</p>
        <p className="text-sm">P&L, Balance Sheet, and Cost Reports</p>
      </div>
    </div>
  )

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 to-emerald-100 p-4">
      <div className="max-w-7xl mx-auto">
        <div className="mb-6">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Finance & Controlling</h1>
          <p className="text-gray-600">Manage financial accounts, valuation, and controlling</p>
        </div>

        {/* Mobile-first tab navigation */}
        <div className="bg-white rounded-lg shadow-sm border mb-6">
          <div className="flex overflow-x-auto">
            {tabs.map((tab) => {
              const Icon = tab.icon
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`flex items-center gap-2 px-4 py-3 whitespace-nowrap border-b-2 transition-colors ${
                    activeTab === tab.id
                      ? 'border-green-500 text-green-600 bg-green-50'
                      : 'border-transparent text-gray-600 hover:text-gray-900 hover:bg-gray-50'
                  }`}
                >
                  <Icon className="w-4 h-4" />
                  <span className="hidden sm:inline">{tab.label}</span>
                </button>
              )
            })}
          </div>
        </div>

        {/* Tab content */}
        <div className="transition-all duration-200">
          {loading ? (
            <div className="bg-white rounded-lg shadow-sm border p-8 text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-green-600 mx-auto"></div>
              <p className="mt-2 text-gray-600">Loading...</p>
            </div>
          ) : (
            <>
              {activeTab === 'accounts' && renderAccountsTab()}
              {activeTab === 'valuation' && renderValuationTab()}
              {activeTab === 'controlling' && renderControllingTab()}
              {activeTab === 'reporting' && renderReportingTab()}
            </>
          )}
        </div>
      </div>
    </div>
  )
}