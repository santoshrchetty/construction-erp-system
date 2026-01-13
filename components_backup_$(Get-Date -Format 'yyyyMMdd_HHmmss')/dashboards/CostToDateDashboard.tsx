'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, LineChart, Line } from 'recharts'
import { TrendingUp, DollarSign, AlertTriangle, Target } from 'lucide-react'

interface CostData {
  cost_object: string
  budgeted: number
  actual: number
  variance: number
  percentage_spent: number
}

interface TrendData {
  month: string
  cumulative_budget: number
  cumulative_actual: number
}

export default function CostToDateDashboard({ projectId }: { projectId: string }) {
  const [costData, setCostData] = useState<CostData[]>([])
  const [trendData, setTrendData] = useState<TrendData[]>([])
  const [selectedPeriod, setSelectedPeriod] = useState('ytd')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadCostData()
  }, [projectId, selectedPeriod])

  const loadCostData = async () => {
    try {
      const mockCostData: CostData[] = [
        { cost_object: 'Labor', budgeted: 800000, actual: 620000, variance: -180000, percentage_spent: 77.5 },
        { cost_object: 'Materials', budgeted: 1200000, actual: 950000, variance: -250000, percentage_spent: 79.2 },
        { cost_object: 'Equipment', budgeted: 300000, actual: 280000, variance: -20000, percentage_spent: 93.3 },
        { cost_object: 'Subcontractors', budgeted: 500000, actual: 420000, variance: -80000, percentage_spent: 84.0 },
        { cost_object: 'Overhead', budgeted: 200000, actual: 180000, variance: -20000, percentage_spent: 90.0 }
      ]

      const mockTrendData: TrendData[] = [
        { month: 'Jan', cumulative_budget: 250000, cumulative_actual: 180000 },
        { month: 'Feb', cumulative_budget: 500000, cumulative_actual: 420000 },
        { month: 'Mar', cumulative_budget: 750000, cumulative_actual: 680000 },
        { month: 'Apr', cumulative_budget: 1000000, cumulative_actual: 890000 },
        { month: 'May', cumulative_budget: 1250000, cumulative_actual: 1150000 },
        { month: 'Jun', cumulative_budget: 1500000, cumulative_actual: 1380000 }
      ]

      setCostData(mockCostData)
      setTrendData(mockTrendData)
    } catch (error) {
      console.error('Failed to load cost data:', error)
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

  const getTotalBudget = () => costData.reduce((sum, item) => sum + item.budgeted, 0)
  const getTotalActual = () => costData.reduce((sum, item) => sum + item.actual, 0)
  const getTotalVariance = () => costData.reduce((sum, item) => sum + item.variance, 0)

  const pieData = costData.map(item => ({
    name: item.cost_object,
    value: item.actual,
    percentage: ((item.actual / getTotalActual()) * 100).toFixed(1)
  }))

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
          <h1 className="text-3xl font-bold">Cost-to-Date Dashboard</h1>
          <p className="text-gray-600 mt-1">Project cost analysis and budget tracking</p>
        </div>
        <Select value={selectedPeriod} onValueChange={setSelectedPeriod}>
          <SelectTrigger className="w-32">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="mtd">MTD</SelectItem>
            <SelectItem value="qtd">QTD</SelectItem>
            <SelectItem value="ytd">YTD</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Budget</CardTitle>
            <Target className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatCurrency(getTotalBudget())}</div>
            <p className="text-xs text-muted-foreground">Project budget allocation</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Actual Spent</CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatCurrency(getTotalActual())}</div>
            <p className="text-xs text-muted-foreground">
              {((getTotalActual() / getTotalBudget()) * 100).toFixed(1)}% of budget
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Variance</CardTitle>
            {getTotalVariance() < 0 ? (
              <TrendingUp className="h-4 w-4 text-green-600" />
            ) : (
              <AlertTriangle className="h-4 w-4 text-red-600" />
            )}
          </CardHeader>
          <CardContent>
            <div className={`text-2xl font-bold ${getTotalVariance() < 0 ? 'text-green-600' : 'text-red-600'}`}>
              {formatCurrency(Math.abs(getTotalVariance()))}
            </div>
            <p className="text-xs text-muted-foreground">
              {getTotalVariance() < 0 ? 'Under' : 'Over'} budget
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Remaining Budget</CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatCurrency(getTotalBudget() - getTotalActual())}</div>
            <p className="text-xs text-muted-foreground">Available to spend</p>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Cost Breakdown by Category</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={costData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="cost_object" />
                <YAxis tickFormatter={(value) => `$${(value / 1000).toFixed(0)}K`} />
                <Tooltip formatter={(value) => formatCurrency(Number(value))} />
                <Bar dataKey="budgeted" fill="#8884d8" name="Budgeted" />
                <Bar dataKey="actual" fill="#82ca9d" name="Actual" />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Cost Distribution</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={pieData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percentage }) => `${name}: ${percentage}%`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {pieData.map((entry, index) => (
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
          <CardTitle>Cumulative Cost Trend</CardTitle>
        </CardHeader>
        <CardContent>
          <ResponsiveContainer width="100%" height={400}>
            <LineChart data={trendData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="month" />
              <YAxis tickFormatter={(value) => `$${(value / 1000).toFixed(0)}K`} />
              <Tooltip formatter={(value) => formatCurrency(Number(value))} />
              <Line type="monotone" dataKey="cumulative_budget" stroke="#8884d8" name="Budget" strokeWidth={2} />
              <Line type="monotone" dataKey="cumulative_actual" stroke="#82ca9d" name="Actual" strokeWidth={2} />
            </LineChart>
          </ResponsiveContainer>
        </CardContent>
      </Card>
    </div>
  )
}