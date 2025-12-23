'use client'

import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase-client'
import PendingGRNDashboard from '@/components/dashboards/PendingGRNDashboard'
import StockLevelsDashboard from '@/components/dashboards/StockLevelsDashboard'

export default function StorekeeperDashboard() {
  const [activeTab, setActiveTab] = useState('overview')
  const [selectedProjectId, setSelectedProjectId] = useState<string>('')
  const [stats, setStats] = useState({
    totalStores: 0,
    pendingGRNs: 0,
    lowStockItems: 0,
    totalValue: 0
  })

  const tabs = [
    { key: 'overview', label: 'Overview', icon: '📊' },
    { key: 'inventory', label: 'Inventory', icon: '📦' },
    { key: 'goods-receipt', label: 'Goods Receipt', icon: '📥' },
    { key: 'stock-levels', label: 'Stock Levels', icon: '📈' }
  ]

  useEffect(() => {
    fetchStats()
  }, [])

  const fetchStats = async () => {
    try {
      const { data: stores } = await supabase.from('stores').select('*')
      const { data: grns } = await supabase.from('goods_receipt_notes').select('*').eq('status', 'pending')
      
      setStats({
        totalStores: stores?.length || 0,
        pendingGRNs: grns?.length || 0,
        lowStockItems: 5, // Mock data
        totalValue: 125000 // Mock data
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
              <h1 className="text-2xl font-bold text-gray-900">Storekeeper Dashboard</h1>
              <p className="text-gray-600">Manage inventory, goods receipt, and stock levels</p>
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
                  <span className="text-2xl">🏪</span>
                </div>
                <div className="ml-4">
                  <h3 className="text-lg font-medium text-gray-900">{stats.totalStores}</h3>
                  <p className="text-sm text-gray-500">Total Stores</p>
                </div>
              </div>
            </div>

            <div className="bg-white rounded-lg shadow p-6">
              <div className="flex items-center">
                <div className="p-2 bg-yellow-100 rounded-lg">
                  <span className="text-2xl">📥</span>
                </div>
                <div className="ml-4">
                  <h3 className="text-lg font-medium text-gray-900">{stats.pendingGRNs}</h3>
                  <p className="text-sm text-gray-500">Pending GRNs</p>
                </div>
              </div>
            </div>

            <div className="bg-white rounded-lg shadow p-6">
              <div className="flex items-center">
                <div className="p-2 bg-red-100 rounded-lg">
                  <span className="text-2xl">⚠️</span>
                </div>
                <div className="ml-4">
                  <h3 className="text-lg font-medium text-gray-900">{stats.lowStockItems}</h3>
                  <p className="text-sm text-gray-500">Low Stock Items</p>
                </div>
              </div>
            </div>

            <div className="bg-white rounded-lg shadow p-6">
              <div className="flex items-center">
                <div className="p-2 bg-green-100 rounded-lg">
                  <span className="text-2xl">💰</span>
                </div>
                <div className="ml-4">
                  <h3 className="text-lg font-medium text-gray-900">${stats.totalValue.toLocaleString()}</h3>
                  <p className="text-sm text-gray-500">Total Inventory Value</p>
                </div>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'inventory' && (
          <div className="bg-white rounded-lg shadow">
            <div className="p-6 border-b">
              <div className="flex justify-between items-center">
                <h2 className="text-lg font-bold">Inventory Management</h2>
                <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                  Add Item
                </button>
              </div>
            </div>
            <div className="p-6">
              <p className="text-gray-500">Inventory management interface coming soon...</p>
            </div>
          </div>
        )}

        {activeTab === 'goods-receipt' && (
          <PendingGRNDashboard projectId={selectedProjectId || 'default'} />
        )}

        {activeTab === 'stock-levels' && (
          <StockLevelsDashboard projectId={selectedProjectId || 'default'} />
        )}
      </main>
    </div>
  )
}