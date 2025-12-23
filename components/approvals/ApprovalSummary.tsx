'use client'

import { useState, useEffect } from 'react'
import { getPendingApprovals } from '@/app/actions/approvals/actions'

export default function ApprovalSummary() {
  const [stats, setStats] = useState({
    totalPending: 0,
    purchaseOrders: 0,
    timesheets: 0,
    tasks: 0
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadStats()
  }, [])

  const loadStats = async () => {
    const result = await getPendingApprovals()
    if (result.success) {
      const { purchaseOrders, timesheets, tasks } = result.data
      setStats({
        totalPending: purchaseOrders.length + timesheets.length + tasks.length,
        purchaseOrders: purchaseOrders.length,
        timesheets: timesheets.length,
        tasks: tasks.length
      })
    }
    setLoading(false)
  }

  if (loading) {
    return (
      <div className="bg-white rounded-lg shadow p-6">
        <div className="animate-pulse">
          <div className="h-4 bg-gray-200 rounded w-1/4 mb-4"></div>
          <div className="h-8 bg-gray-200 rounded w-1/2"></div>
        </div>
      </div>
    )
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
      <div className="bg-white rounded-lg shadow p-6">
        <div className="flex items-center">
          <div className="p-2 bg-red-100 rounded-lg">
            <span className="text-2xl">⏳</span>
          </div>
          <div className="ml-4">
            <h3 className="text-lg font-medium text-gray-900">{stats.totalPending}</h3>
            <p className="text-sm text-gray-500">Total Pending</p>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <div className="flex items-center">
          <div className="p-2 bg-purple-100 rounded-lg">
            <span className="text-2xl">📋</span>
          </div>
          <div className="ml-4">
            <h3 className="text-lg font-medium text-gray-900">{stats.purchaseOrders}</h3>
            <p className="text-sm text-gray-500">Purchase Orders</p>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <div className="flex items-center">
          <div className="p-2 bg-blue-100 rounded-lg">
            <span className="text-2xl">⏰</span>
          </div>
          <div className="ml-4">
            <h3 className="text-lg font-medium text-gray-900">{stats.timesheets}</h3>
            <p className="text-sm text-gray-500">Timesheets</p>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <div className="flex items-center">
          <div className="p-2 bg-green-100 rounded-lg">
            <span className="text-2xl">✅</span>
          </div>
          <div className="ml-4">
            <h3 className="text-lg font-medium text-gray-900">{stats.tasks}</h3>
            <p className="text-sm text-gray-500">Tasks</p>
          </div>
        </div>
      </div>
    </div>
  )
}