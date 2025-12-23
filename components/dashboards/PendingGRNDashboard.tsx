'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts'
import { Package, Clock, AlertTriangle, CheckCircle, Truck } from 'lucide-react'

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
        return <Clock className="h-4 w-4 text-blue-600" />
      case 'overdue':
        return <AlertTriangle className="h-4 w-4 text-red-600" />
      case 'received_partial':
        return <Package className="h-4 w-4 text-yellow-600" />
      default:
        return <CheckCircle className="h-4 w-4 text-green-600" />
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

  const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042']

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
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Pending POs</CardTitle>
            <Package className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{pendingGRNs.length}</div>
            <p className="text-xs text-muted-foreground">Purchase orders</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Pending Value</CardTitle>
            <Truck className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatCurrency(getTotalPendingValue())}</div>
            <p className="text-xs text-muted-foreground">Total value</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Overdue Deliveries</CardTitle>
            <AlertTriangle className="h-4 w-4 text-red-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-red-600">{getOverdueCount()}</div>
            <p className="text-xs text-muted-foreground">Past due date</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">High Priority</CardTitle>
            <AlertTriangle className="h-4 w-4 text-orange-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-orange-600">{getHighPriorityCount()}</div>
            <p className="text-xs text-muted-foreground">Critical/High priority</p>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Aging Analysis</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={agingData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="range" />
                <YAxis tickFormatter={(value) => `$${(value / 1000).toFixed(0)}K`} />
                <Tooltip formatter={(value) => formatCurrency(Number(value))} />
                <Bar dataKey="value" fill="#8884d8" name="Value" />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Status Distribution</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={[
                    { name: 'Pending', value: pendingGRNs.filter(g => g.status === 'pending').length },
                    { name: 'Overdue', value: pendingGRNs.filter(g => g.status === 'overdue').length },
                    { name: 'Partial', value: pendingGRNs.filter(g => g.status === 'received_partial').length }
                  ]}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, value }) => `${name}: ${value}`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {agingData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Pending Purchase Orders</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>PO Number</TableHead>
                <TableHead>Vendor</TableHead>
                <TableHead>PO Date</TableHead>
                <TableHead>Expected Delivery</TableHead>
                <TableHead>Days Pending</TableHead>
                <TableHead>Value</TableHead>
                <TableHead>Items</TableHead>
                <TableHead>Priority</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {pendingGRNs.map((grn, index) => (
                <TableRow key={index}>
                  <TableCell className="font-medium">{grn.po_number}</TableCell>
                  <TableCell>{grn.vendor_name}</TableCell>
                  <TableCell>{new Date(grn.po_date).toLocaleDateString()}</TableCell>
                  <TableCell>{new Date(grn.expected_delivery).toLocaleDateString()}</TableCell>
                  <TableCell>
                    <span className={grn.days_pending > 10 ? 'text-red-600 font-medium' : ''}>
                      {grn.days_pending} days
                    </span>
                  </TableCell>
                  <TableCell>{formatCurrency(grn.total_value)}</TableCell>
                  <TableCell>{grn.items_count}</TableCell>
                  <TableCell>
                    <Badge className={getPriorityColor(grn.priority)}>
                      {grn.priority.toUpperCase()}
                    </Badge>
                  </TableCell>
                  <TableCell>
                    <div className="flex items-center space-x-2">
                      {getStatusIcon(grn.status)}
                      <Badge className={getStatusColor(grn.status)}>
                        {grn.status.replace('_', ' ').toUpperCase()}
                      </Badge>
                    </div>
                  </TableCell>
                  <TableCell>
                    <div className="flex space-x-2">
                      <Button variant="outline" size="sm">
                        Follow Up
                      </Button>
                      <Button variant="outline" size="sm">
                        Create GRN
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Critical Actions Required</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {pendingGRNs
                .filter(grn => grn.status === 'overdue' || grn.priority === 'critical')
                .map((grn, index) => (
                  <div key={index} className="flex items-center justify-between p-4 border rounded-lg bg-red-50">
                    <div className="flex items-center space-x-3">
                      <AlertTriangle className="h-5 w-5 text-red-600" />
                      <div>
                        <p className="font-medium">{grn.po_number} - {grn.vendor_name}</p>
                        <p className="text-sm text-gray-600">
                          {grn.days_pending} days overdue • {formatCurrency(grn.total_value)}
                        </p>
                      </div>
                    </div>
                    <Button variant="outline" size="sm" className="text-red-600 border-red-600">
                      Urgent Follow-up
                    </Button>
                  </div>
                ))}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Delivery Schedule</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {pendingGRNs
                .sort((a, b) => new Date(a.expected_delivery).getTime() - new Date(b.expected_delivery).getTime())
                .slice(0, 5)
                .map((grn, index) => (
                  <div key={index} className="flex items-center justify-between p-3 border rounded-lg">
                    <div>
                      <p className="font-medium">{grn.po_number}</p>
                      <p className="text-sm text-gray-600">{grn.vendor_name}</p>
                    </div>
                    <div className="text-right">
                      <p className="font-medium">{new Date(grn.expected_delivery).toLocaleDateString()}</p>
                      <p className="text-sm text-gray-600">{formatCurrency(grn.total_value)}</p>
                    </div>
                  </div>
                ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}