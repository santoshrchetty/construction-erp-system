'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line, PieChart, Pie, Cell } from 'recharts'
import { Package, AlertTriangle, TrendingDown, Warehouse, ShoppingCart } from 'lucide-react'

interface StockItem {
  item_code: string
  description: string
  category: string
  unit: string
  current_stock: number
  minimum_stock: number
  maximum_stock: number
  reorder_level: number
  unit_cost: number
  total_value: number
  last_receipt_date: string
  last_issue_date: string
  stock_status: 'normal' | 'low' | 'critical' | 'overstock'
  store_name: string
}

interface StockMovement {
  date: string
  receipts: number
  issues: number
  balance: number
}

interface CategorySummary {
  category: string
  items_count: number
  total_value: number
  low_stock_items: number
}

export default function StockLevelsDashboard({ projectId }: { projectId: string }) {
  const [stockItems, setStockItems] = useState<StockItem[]>([])
  const [stockMovements, setStockMovements] = useState<StockMovement[]>([])
  const [categorySummary, setCategorySummary] = useState<CategorySummary[]>([])
  const [selectedStore, setSelectedStore] = useState('all')
  const [selectedCategory, setSelectedCategory] = useState('all')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadStockData()
  }, [projectId, selectedStore, selectedCategory])

  const loadStockData = async () => {
    try {
      const mockStockItems: StockItem[] = [
        {
          item_code: 'STL-001',
          description: 'Steel Rebar 16mm',
          category: 'Steel',
          unit: 'kg',
          current_stock: 850,
          minimum_stock: 500,
          maximum_stock: 2000,
          reorder_level: 750,
          unit_cost: 85,
          total_value: 72250,
          last_receipt_date: '2024-01-20',
          last_issue_date: '2024-01-28',
          stock_status: 'low',
          store_name: 'Main Store'
        },
        {
          item_code: 'CEM-001',
          description: 'Portland Cement 50kg',
          category: 'Cement',
          unit: 'bags',
          current_stock: 45,
          minimum_stock: 100,
          maximum_stock: 500,
          reorder_level: 150,
          unit_cost: 12,
          total_value: 540,
          last_receipt_date: '2024-01-15',
          last_issue_date: '2024-01-29',
          stock_status: 'critical',
          store_name: 'Main Store'
        },
        {
          item_code: 'AGG-001',
          description: '20mm Aggregate',
          category: 'Aggregates',
          unit: 'cum',
          current_stock: 125,
          minimum_stock: 50,
          maximum_stock: 200,
          reorder_level: 75,
          unit_cost: 45,
          total_value: 5625,
          last_receipt_date: '2024-01-25',
          last_issue_date: '2024-01-27',
          stock_status: 'normal',
          store_name: 'Site Store A'
        },
        {
          item_code: 'BRK-001',
          description: 'Clay Bricks',
          category: 'Masonry',
          unit: 'nos',
          current_stock: 8500,
          minimum_stock: 2000,
          maximum_stock: 10000,
          reorder_level: 3000,
          unit_cost: 0.5,
          total_value: 4250,
          last_receipt_date: '2024-01-22',
          last_issue_date: '2024-01-26',
          stock_status: 'overstock',
          store_name: 'Site Store B'
        }
      ]

      const mockStockMovements: StockMovement[] = [
        { date: '2024-01-01', receipts: 15000, issues: 8000, balance: 45000 },
        { date: '2024-01-08', receipts: 12000, issues: 10000, balance: 47000 },
        { date: '2024-01-15', receipts: 18000, issues: 12000, balance: 53000 },
        { date: '2024-01-22', receipts: 8000, issues: 15000, balance: 46000 },
        { date: '2024-01-29', receipts: 20000, issues: 18000, balance: 48000 }
      ]

      const mockCategorySummary: CategorySummary[] = [
        { category: 'Steel', items_count: 8, total_value: 125000, low_stock_items: 2 },
        { category: 'Cement', items_count: 5, total_value: 45000, low_stock_items: 3 },
        { category: 'Aggregates', items_count: 6, total_value: 35000, low_stock_items: 1 },
        { category: 'Masonry', items_count: 12, total_value: 28000, low_stock_items: 0 }
      ]

      setStockItems(mockStockItems)
      setStockMovements(mockStockMovements)
      setCategorySummary(mockCategorySummary)
    } catch (error) {
      console.error('Failed to load stock data:', error)
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

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'critical':
        return 'bg-red-100 text-red-800'
      case 'low':
        return 'bg-yellow-100 text-yellow-800'
      case 'overstock':
        return 'bg-blue-100 text-blue-800'
      default:
        return 'bg-green-100 text-green-800'
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'critical':
        return <AlertTriangle className="h-4 w-4 text-red-600" />
      case 'low':
        return <TrendingDown className="h-4 w-4 text-yellow-600" />
      case 'overstock':
        return <Package className="h-4 w-4 text-blue-600" />
      default:
        return <Package className="h-4 w-4 text-green-600" />
    }
  }

  const getStockPercentage = (current: number, min: number, max: number) => {
    return ((current - min) / (max - min)) * 100
  }

  const getTotalStockValue = () => stockItems.reduce((sum, item) => sum + item.total_value, 0)
  const getCriticalItems = () => stockItems.filter(item => item.stock_status === 'critical').length
  const getLowStockItems = () => stockItems.filter(item => item.stock_status === 'low').length
  const getOverstockItems = () => stockItems.filter(item => item.stock_status === 'overstock').length

  const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884D8']

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
          <p className="text-gray-600 mt-1">Inventory management and stock monitoring</p>
        </div>
        <div className="flex space-x-2">
          <Select value={selectedStore} onValueChange={setSelectedStore}>
            <SelectTrigger className="w-40">
              <SelectValue placeholder="Select store" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Stores</SelectItem>
              <SelectItem value="main">Main Store</SelectItem>
              <SelectItem value="site-a">Site Store A</SelectItem>
              <SelectItem value="site-b">Site Store B</SelectItem>
            </SelectContent>
          </Select>
          <Select value={selectedCategory} onValueChange={setSelectedCategory}>
            <SelectTrigger className="w-40">
              <SelectValue placeholder="Select category" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Categories</SelectItem>
              <SelectItem value="steel">Steel</SelectItem>
              <SelectItem value="cement">Cement</SelectItem>
              <SelectItem value="aggregates">Aggregates</SelectItem>
              <SelectItem value="masonry">Masonry</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-5 gap-6">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Stock Value</CardTitle>
            <Warehouse className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatCurrency(getTotalStockValue())}</div>
            <p className="text-xs text-muted-foreground">Current inventory value</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Critical Items</CardTitle>
            <AlertTriangle className="h-4 w-4 text-red-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-red-600">{getCriticalItems()}</div>
            <p className="text-xs text-muted-foreground">Below minimum stock</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Low Stock Items</CardTitle>
            <TrendingDown className="h-4 w-4 text-yellow-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-yellow-600">{getLowStockItems()}</div>
            <p className="text-xs text-muted-foreground">Near reorder level</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Overstock Items</CardTitle>
            <Package className="h-4 w-4 text-blue-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-blue-600">{getOverstockItems()}</div>
            <p className="text-xs text-muted-foreground">Above maximum level</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Reorder Required</CardTitle>
            <ShoppingCart className="h-4 w-4 text-orange-600" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-orange-600">
              {stockItems.filter(item => item.current_stock <= item.reorder_level).length}
            </div>
            <p className="text-xs text-muted-foreground">Items to reorder</p>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Stock Movement Trend</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={stockMovements}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" tickFormatter={(value) => new Date(value).toLocaleDateString()} />
                <YAxis tickFormatter={(value) => `$${(value / 1000).toFixed(0)}K`} />
                <Tooltip formatter={(value) => formatCurrency(Number(value))} />
                <Line type="monotone" dataKey="receipts" stroke="#8884d8" name="Receipts" strokeWidth={2} />
                <Line type="monotone" dataKey="issues" stroke="#82ca9d" name="Issues" strokeWidth={2} />
                <Line type="monotone" dataKey="balance" stroke="#ffc658" name="Balance" strokeWidth={2} />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Category Distribution</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={categorySummary}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ category, total_value }) => `${category}: ${formatCurrency(total_value)}`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="total_value"
                >
                  {categorySummary.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip formatter={(value) => formatCurrency(Number(value))} />
              </PieChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Stock Status by Category</CardTitle>
        </CardHeader>
        <CardContent>
          <ResponsiveContainer width="100%" height={400}>
            <BarChart data={categorySummary}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="category" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="items_count" fill="#8884d8" name="Total Items" />
              <Bar dataKey="low_stock_items" fill="#ff8042" name="Low Stock Items" />
            </BarChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Stock Items Detail</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {stockItems.map((item, index) => (
              <div key={index} className="border rounded-lg p-4">
                <div className="flex justify-between items-start mb-4">
                  <div>
                    <h4 className="font-medium text-lg">{item.description}</h4>
                    <p className="text-sm text-gray-600">{item.item_code} • {item.category} • {item.store_name}</p>
                  </div>
                  <div className="flex items-center space-x-2">
                    {getStatusIcon(item.stock_status)}
                    <Badge className={getStatusColor(item.stock_status)}>
                      {item.stock_status.toUpperCase()}
                    </Badge>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-5 gap-4 mb-4">
                  <div>
                    <p className="text-sm text-gray-600">Current Stock</p>
                    <p className="font-medium">{item.current_stock.toLocaleString()} {item.unit}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Minimum Stock</p>
                    <p className="font-medium">{item.minimum_stock.toLocaleString()} {item.unit}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Reorder Level</p>
                    <p className="font-medium">{item.reorder_level.toLocaleString()} {item.unit}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Unit Cost</p>
                    <p className="font-medium">{formatCurrency(item.unit_cost)}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Total Value</p>
                    <p className="font-medium">{formatCurrency(item.total_value)}</p>
                  </div>
                </div>

                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span>Stock Level</span>
                    <span>{getStockPercentage(item.current_stock, item.minimum_stock, item.maximum_stock).toFixed(1)}%</span>
                  </div>
                  <Progress value={getStockPercentage(item.current_stock, item.minimum_stock, item.maximum_stock)} />
                  <div className="flex justify-between text-xs text-gray-600">
                    <span>Last Receipt: {new Date(item.last_receipt_date).toLocaleDateString()}</span>
                    <span>Last Issue: {new Date(item.last_issue_date).toLocaleDateString()}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}