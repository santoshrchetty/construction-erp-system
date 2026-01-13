'use client'

import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'

interface PendingGRN {
  po_number: string
  vendor_name: string
  po_date: string
  expected_delivery: string
  days_pending: number
  total_value: number
  items_count: number
  status: 'pending' | 'overdue' | 'received_partial'
  priority: 'low' | 'medium' | 'high' | 'critical'
  items: Array<{
    description: string
    ordered_qty: number
    received_qty: number
    pending_qty: number
    unit: string
    unit_rate: number
  }>
}

interface AgingData {
  range: string
  count: number
  value: number
}

export default function PendingGRNDashboard({ projectId }: { projectId: string }) {
  const [pendingGRNs, setPendingGRNs] = useState<PendingGRN[]>([])
  const [agingData, setAgingData] = useState<AgingData[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadPendingGRNData()
  }, [projectId])

  const loadPendingGRNData = async () => {
    try {
      const mockPendingGRNs: PendingGRN[] = [
        {
          po_number: 'PO-001234',
          vendor_name: 'ABC Steel Suppliers',
          po_date: '2024-01-15',
          expected_delivery: '2024-01-25',
          days_pending: 15,
          total_value: 125000,
          items_count: 5,
          status: 'overdue',
          priority: 'high',
          items: [
            { description: 'Steel Rebar 16mm', ordered_qty: 1000, received_qty: 0, pending_qty: 1000, unit: 'kg', unit_rate: 85 },
            { description: 'Steel Rebar 20mm', ordered_qty: 500, received_qty: 0, pending_qty: 500, unit: 'kg', unit_rate: 90 }
          ]
        },
        {
          po_number: 'PO-001235',
          vendor_name: 'XYZ Concrete Co.',
          po_date: '2024-01-20',
          expected_delivery: '2024-02-05',
          days_pending: 8,
          total_value: 85000,
          items_count: 3,
          status: 'pending',
          priority: 'medium',
          items: [
            { description: 'Ready Mix Concrete M25', ordered_qty: 100, received_qty: 0, pending_qty: 100, unit: 'cum', unit_rate: 850 }
          ]
        },
        {
          po_number: 'PO-001236',
          vendor_name: 'Building Materials Ltd',
          po_date: '2024-01-18',
          expected_delivery: '2024-01-30',
          days_pending: 12,
          total_value: 45000,
          items_count: 8,
          status: 'received_partial',
          priority: 'low',
          items: [
            { description: 'Cement Bags', ordered_qty: 200, received_qty: 100, pending_qty: 100, unit: 'bags', unit_rate: 450 }
          ]
        }
      ]

      const mockAgingData: AgingData[] = [
        { range: '0-7 days', count: 5, value: 180000 },
        { range: '8-15 days', count: 8, value: 320000 },
        { range: '16-30 days', count: 4, value: 150000 },
        { range: '30+ days', count: 2, value: 85000 }
      ]

      setPendingGRNs(mockPendingGRNs)
      setAgingData(mockAgingData)
    } catch (error) {
      console.error('Failed to load pending GRN data:', error)
    } finally {
      setLoading(false)
    }
  }

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0
    }).format(value)
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'pending':
        return <Icons.Clock className="h-4 w-4 text-blue-600" />
      case 'overdue':
        return <Icons.AlertTriangle className="h-4 w-4 text-red-600" />
      case 'received_partial':
        return <Icons.Package className="h-4 w-4 text-yellow-600" />
      default:
        return <Icons.CheckCircle className="h-4 w-4 text-green-600" />
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending':
        return 'bg-blue-100 text-blue-800'
      case 'overdue':
        return 'bg-red-100 text-red-800'
      case 'received_partial':
        return 'bg-yellow-100 text-yellow-800'
      default:
        return 'bg-green-100 text-green-800'
    }
  }

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'critical':
        return 'bg-red-100 text-red-800'
      case 'high':
        return 'bg-orange-100 text-orange-800'
      case 'medium':
        return 'bg-yellow-100 text-yellow-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  const getTotalPendingValue = () => pendingGRNs.reduce((sum, grn) => sum + grn.total_value, 0)
  const getOverdueCount = () => pendingGRNs.filter(grn => grn.status === 'overdue').length
  const getHighPriorityCount = () => pendingGRNs.filter(grn => grn.priority === 'high' || grn.priority === 'critical').length

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">Pending GRN Dashboard</h1>
          <p className="text-gray-600 mt-1">Purchase orders awaiting goods receipt</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white p-6 rounded-lg shadow border">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Total Pending POs</p>
              <p className="text-2xl font-bold">{pendingGRNs.length}</p>
            </div>
            <Icons.Package className="h-8 w-8 text-blue-600" />
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow border">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Pending Value</p>
              <p className="text-2xl font-bold">{formatCurrency(getTotalPendingValue())}</p>
            </div>
            <Icons.Truck className="h-8 w-8 text-green-600" />
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow border">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">Overdue Deliveries</p>
              <p className="text-2xl font-bold text-red-600">{getOverdueCount()}</p>
            </div>
            <Icons.AlertTriangle className="h-8 w-8 text-red-600" />
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow border">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-gray-600">High Priority</p>
              <p className="text-2xl font-bold text-orange-600">{getHighPriorityCount()}</p>
            </div>
            <Icons.AlertTriangle className="h-8 w-8 text-orange-600" />
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow border">
        <div className="p-6 border-b">
          <h3 className="text-lg font-semibold">Pending Purchase Orders</h3>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">PO Number</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Vendor</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">PO Date</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Expected Delivery</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Days Pending</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Value</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Priority</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {pendingGRNs.map((grn, index) => (
                <tr key={index} className="hover:bg-gray-50">
                  <td className="px-4 py-3 font-medium">{grn.po_number}</td>
                  <td className="px-4 py-3">{grn.vendor_name}</td>
                  <td className="px-4 py-3">{new Date(grn.po_date).toLocaleDateString()}</td>
                  <td className="px-4 py-3">{new Date(grn.expected_delivery).toLocaleDateString()}</td>
                  <td className="px-4 py-3">
                    <span className={grn.days_pending > 10 ? 'text-red-600 font-medium' : ''}>
                      {grn.days_pending} days
                    </span>
                  </td>
                  <td className="px-4 py-3">{formatCurrency(grn.total_value)}</td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-1 text-xs rounded-full ${getPriorityColor(grn.priority)}`}>
                      {grn.priority.toUpperCase()}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center space-x-2">
                      {getStatusIcon(grn.status)}
                      <span className={`px-2 py-1 text-xs rounded-full ${getStatusColor(grn.status)}`}>
                        {grn.status.replace('_', ' ').toUpperCase()}
                      </span>
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex space-x-2">
                      <button className="px-3 py-1 text-xs border rounded hover:bg-gray-50">
                        Follow Up
                      </button>
                      <button className="px-3 py-1 text-xs border rounded hover:bg-gray-50">
                        Create GRN
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
}