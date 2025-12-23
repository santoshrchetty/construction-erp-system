'use client'

import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase-client'

export default function ProcurementDashboard() {
  const [activeTab, setActiveTab] = useState('overview')
  const [stats, setStats] = useState({
    totalPOs: 0,
    pendingApprovals: 0,
    activeVendors: 0,
    monthlySpend: 0
  })

  const tabs = [
    { key: 'overview', label: 'Overview', icon: '📊' },
    { key: 'vendors', label: 'Vendors', icon: '🏢' },
    { key: 'purchase-orders', label: 'Purchase Orders', icon: '📋' },
    { key: 'approvals', label: 'Approvals', icon: '✅' }
  ]

  useEffect(() => {
    fetchStats()
  }, [])

  const fetchStats = async () => {
    try {
      const { data: pos } = await supabase.from('purchase_orders').select('*')
      const { data: vendors } = await supabase.from('vendors').select('*').eq('status', 'active')
      
      setStats({
        totalPOs: pos?.length || 0,
        pendingApprovals: pos?.filter(po => po.status === 'pending_approval').length || 0,
        activeVendors: vendors?.length || 0,
        monthlySpend: pos?.reduce((sum, po) => sum + (po.total_amount || 0), 0) || 0
      })
    } catch (error) {
      console.error('Error fetching stats:', error)
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Procurement Dashboard</h1>
              <p className="text-gray-600">Manage vendors, purchase orders, and approvals</p>
            </div>
          </div>
        </div>
      </div>

      <nav className="bg-white border-b">
        <div className="max-w-7xl mx-auto px-4">
          <div className="flex space-x-6">
            {tabs.map((tab) => (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                className={`py-3 px-2 border-b-2 font-medium text-sm flex items-center space-x-2 ${
                  activeTab === tab.key
                    ? 'border-blue-500 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                <span>{tab.icon}</span>
                <span>{tab.label}</span>
              </button>
            ))}
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {activeTab === 'overview' && (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <div className="bg-white rounded-lg shadow p-6">
              <div className="flex items-center">
                <div className="p-2 bg-blue-100 rounded-lg">
                  <span className="text-2xl">📋</span>
                </div>
                <div className="ml-4">
                  <h3 className="text-lg font-medium text-gray-900">{stats.totalPOs}</h3>
                  <p className="text-sm text-gray-500">Total Purchase Orders</p>
                </div>
              </div>
            </div>

            <div className="bg-white rounded-lg shadow p-6">
              <div className="flex items-center">
                <div className="p-2 bg-yellow-100 rounded-lg">
                  <span className="text-2xl">⏳</span>
                </div>
                <div className="ml-4">
                  <h3 className="text-lg font-medium text-gray-900">{stats.pendingApprovals}</h3>
                  <p className="text-sm text-gray-500">Pending Approvals</p>
                </div>
              </div>
            </div>

            <div className="bg-white rounded-lg shadow p-6">
              <div className="flex items-center">
                <div className="p-2 bg-green-100 rounded-lg">
                  <span className="text-2xl">🏢</span>
                </div>
                <div className="ml-4">
                  <h3 className="text-lg font-medium text-gray-900">{stats.activeVendors}</h3>
                  <p className="text-sm text-gray-500">Active Vendors</p>
                </div>
              </div>
            </div>

            <div className="bg-white rounded-lg shadow p-6">
              <div className="flex items-center">
                <div className="p-2 bg-purple-100 rounded-lg">
                  <span className="text-2xl">💰</span>
                </div>
                <div className="ml-4">
                  <h3 className="text-lg font-medium text-gray-900">${stats.monthlySpend.toLocaleString()}</h3>
                  <p className="text-sm text-gray-500">Monthly Spend</p>
                </div>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'vendors' && (
          <div className="bg-white rounded-lg shadow">
            <div className="p-6 border-b">
              <div className="flex justify-between items-center">
                <h2 className="text-lg font-bold">Vendor Management</h2>
                <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                  Add Vendor
                </button>
              </div>
            </div>
            <div className="p-6">
              <p className="text-gray-500">Vendor management interface coming soon...</p>
            </div>
          </div>
        )}

        {activeTab === 'purchase-orders' && (
          <div className="bg-white rounded-lg shadow">
            <div className="p-6 border-b">
              <div className="flex justify-between items-center">
                <h2 className="text-lg font-bold">Purchase Orders</h2>
                <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                  Create PO
                </button>
              </div>
            </div>
            <div className="p-6">
              <p className="text-gray-500">Purchase order management interface coming soon...</p>
            </div>
          </div>
        )}

        {activeTab === 'approvals' && (
          <div className="bg-white rounded-lg shadow">
            <div className="p-6 border-b">
              <h2 className="text-lg font-bold">Pending Approvals</h2>
            </div>
            <div className="p-6">
              <p className="text-gray-500">Approval workflow interface coming soon...</p>
            </div>
          </div>
        )}
      </main>
    </div>
  )
}