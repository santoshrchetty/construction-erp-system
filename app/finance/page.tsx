'use client'

import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase-client'
import CostToCompleteDashboard from '@/components/dashboards/CostToCompleteDashboard'
import EarnedValueDashboard from '@/components/dashboards/EarnedValueDashboard'

export default function FinanceDashboard() {
  const [activeTab, setActiveTab] = useState('overview')
  const [selectedProjectId, setSelectedProjectId] = useState<string>('')
  const [stats, setStats] = useState({
    totalBudget: 0,
    actualCosts: 0,
    variance: 0,
    pendingInvoices: 0
  })

  const tabs = [
    { key: 'overview', label: 'Overview', icon: '📊' },
    { key: 'evm', label: 'Earned Value', icon: '📈' },
    { key: 'cost-to-complete', label: 'Cost to Complete', icon: '💰' },
    { key: 'billing', label: 'Billing', icon: '🧾' }
  ]

  useEffect(() => {
    fetchStats()
  }, [])

  const fetchStats = async () => {
    try {
      const { data: projects } = await supabase.from('projects').select('budget, project_direct_cost_total')
      
      const totalBudget = projects?.reduce((sum, p) => sum + (p.budget || 0), 0) || 0
      const actualCosts = projects?.reduce((sum, p) => sum + (p.project_direct_cost_total || 0), 0) || 0
      
      setStats({
        totalBudget,
        actualCosts,
        variance: totalBudget - actualCosts,
        pendingInvoices: 8 // Mock data
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
              <h1 className="text-2xl font-bold text-gray-900">Finance Dashboard</h1>
              <p className="text-gray-600">Cost analysis, budget tracking, and financial reports</p>
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
                  <span className="text-2xl">💰</span>
                </div>
                <div className="ml-4">
                  <h3 className="text-lg font-medium text-gray-900">${stats.totalBudget.toLocaleString()}</h3>
                  <p className="text-sm text-gray-500">Total Budget</p>
                </div>
              </div>
            </div>

            <div className="bg-white rounded-lg shadow p-6">
              <div className="flex items-center">
                <div className="p-2 bg-red-100 rounded-lg">
                  <span className="text-2xl">📊</span>
                </div>
                <div className="ml-4">
                  <h3 className="text-lg font-medium text-gray-900">${stats.actualCosts.toLocaleString()}</h3>
                  <p className="text-sm text-gray-500">Actual Costs</p>
                </div>
              </div>
            </div>

            <div className="bg-white rounded-lg shadow p-6">
              <div className="flex items-center">
                <div className="p-2 bg-green-100 rounded-lg">
                  <span className="text-2xl">📈</span>
                </div>
                <div className="ml-4">
                  <h3 className={`text-lg font-medium ${stats.variance >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                    ${Math.abs(stats.variance).toLocaleString()}
                  </h3>
                  <p className="text-sm text-gray-500">Budget Variance</p>
                </div>
              </div>
            </div>

            <div className="bg-white rounded-lg shadow p-6">
              <div className="flex items-center">
                <div className="p-2 bg-yellow-100 rounded-lg">
                  <span className="text-2xl">🧾</span>
                </div>
                <div className="ml-4">
                  <h3 className="text-lg font-medium text-gray-900">{stats.pendingInvoices}</h3>
                  <p className="text-sm text-gray-500">Pending Invoices</p>
                </div>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'evm' && (
          <EarnedValueDashboard projectId={selectedProjectId || 'default'} />
        )}

        {activeTab === 'cost-to-complete' && (
          <CostToCompleteDashboard projectId={selectedProjectId || 'default'} />
        )}

        {activeTab === 'billing' && (
          <div className="bg-white rounded-lg shadow">
            <div className="p-6 border-b">
              <div className="flex justify-between items-center">
                <h2 className="text-lg font-bold">Billing & Invoicing</h2>
                <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
                  Create Invoice
                </button>
              </div>
            </div>
            <div className="p-6">
              <p className="text-gray-500">Billing interface coming soon...</p>
            </div>
          </div>
        )}
      </main>
    </div>
  )
}