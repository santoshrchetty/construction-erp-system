'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Progress } from '@/components/ui/progress'
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line, Area, AreaChart } from 'recharts'
import { Calculator, TrendingUp, AlertCircle, CheckCircle } from 'lucide-react'

interface CostToCompleteData {
  wbs_code: string
  name: string
  budget: number
  actual_to_date: number
  estimate_to_complete: number
  estimate_at_completion: number
  variance_at_completion: number
  progress_percentage: number
}

interface ForecastData {
  month: string
  planned_spend: number
  forecast_spend: number
  cumulative_planned: number
  cumulative_forecast: number
}

export default function CostToCompleteDashboard({ projectId }: { projectId: string }) {
  const [costData, setCostData] = useState<CostToCompleteData[]>([])
  const [forecastData, setForecastData] = useState<ForecastData[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadCostToCompleteData()
  }, [projectId])

  const loadCostToCompleteData = async () => {
    try {
      const mockCostData: CostToCompleteData[] = [
        {
          wbs_code: 'WBS-01',
          name: 'Site Preparation',
          budget: 150000,
          actual_to_date: 145000,
          estimate_to_complete: 8000,
          estimate_at_completion: 153000,
          variance_at_completion: 3000,
          progress_percentage: 95
        },
        {
          wbs_code: 'WBS-02',
          name: 'Foundation Work',
          budget: 400000,
          actual_to_date: 320000,
          estimate_to_complete: 95000,
          estimate_at_completion: 415000,
          variance_at_completion: 15000,
          progress_percentage: 80
        },
        {
          wbs_code: 'WBS-03',
          name: 'Structural Work',
          budget: 600000,
          actual_to_date: 180000,
          estimate_to_complete: 450000,
          estimate_at_completion: 630000,
          variance_at_completion: 30000,
          progress_percentage: 30
        },
        {
          wbs_code: 'WBS-04',
          name: 'MEP Installation',
          budget: 350000,
          actual_to_date: 45000,
          estimate_to_complete: 320000,
          estimate_at_completion: 365000,
          variance_at_completion: 15000,
          progress_percentage: 15
        }
      ]

      const mockForecastData: ForecastData[] = [
        { month: 'Jul', planned_spend: 200000, forecast_spend: 180000, cumulative_planned: 1700000, cumulative_forecast: 1560000 },
        { month: 'Aug', planned_spend: 250000, forecast_spend: 280000, cumulative_planned: 1950000, cumulative_forecast: 1840000 },
        { month: 'Sep', planned_spend: 300000, forecast_spend: 320000, cumulative_planned: 2250000, cumulative_forecast: 2160000 },
        { month: 'Oct', planned_spend: 200000, forecast_spend: 230000, cumulative_planned: 2450000, cumulative_forecast: 2390000 },
        { month: 'Nov', planned_spend: 150000, forecast_spend: 170000, cumulative_planned: 2600000, cumulative_forecast: 2560000 },
        { month: 'Dec', planned_spend: 100000, forecast_spend: 103000, cumulative_planned: 2700000, cumulative_forecast: 2663000 }
      ]

      setCostData(mockCostData)
      setForecastData(mockForecastData)
    } catch (error) {
      console.error('Failed to load cost to complete data:', error)
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

  const getTotalBudget = () => costData.reduce((sum, item) => sum + item.budget, 0)
  const getTotalActual = () => costData.reduce((sum, item) => sum + item.actual_to_date, 0)
  const getTotalETC = () => costData.reduce((sum, item) => sum + item.estimate_to_complete, 0)
  const getTotalEAC = () => costData.reduce((sum, item) => sum + item.estimate_at_completion, 0)
  const getTotalVariance = () => costData.reduce((sum, item) => sum + item.variance_at_completion, 0)

  const getStatusIcon = (variance: number) => {
    if (variance <= 0) return <CheckCircle className="h-4 w-4 text-green-600" />
    if (variance <= 10000) return <AlertCircle className="h-4 w-4 text-yellow-600" />
    return <AlertCircle className="h-4 w-4 text-red-600" />
  }

  const getStatusColor = (variance: number) => {
    if (variance <= 0) return 'text-green-600'
    if (variance <= 10000) return 'text-yellow-600'
    return 'text-red-600'
  }

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
          <h1 className="text-3xl font-bold">Cost-to-Complete Dashboard</h1>
          <p className="text-gray-600 mt-1">Project completion cost forecasting and analysis</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-5 gap-6">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Budget</CardTitle>
            <Calculator className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatCurrency(getTotalBudget())}</div>
            <p className="text-xs text-muted-foreground">Original budget</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Actual to Date</CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatCurrency(getTotalActual())}</div>
            <p className="text-xs text-muted-foreground">Spent so far</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Estimate to Complete</CardTitle>
            <Calculator className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatCurrency(getTotalETC())}</div>
            <p className="text-xs text-muted-foreground">Remaining cost</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Estimate at Completion</CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatCurrency(getTotalEAC())}</div>
            <p className="text-xs text-muted-foreground">Total forecast</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Variance at Completion</CardTitle>
            {getTotalVariance() <= 0 ? (
              <CheckCircle className="h-4 w-4 text-green-600" />
            ) : (
              <AlertCircle className="h-4 w-4 text-red-600" />
            )}
          </CardHeader>
          <CardContent>
            <div className={`text-2xl font-bold ${getTotalVariance() <= 0 ? 'text-green-600' : 'text-red-600'}`}>
              {formatCurrency(Math.abs(getTotalVariance()))}
            </div>
            <p className="text-xs text-muted-foreground">
              {getTotalVariance() <= 0 ? 'Under' : 'Over'} budget
            </p>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Cost Forecast by Work Package</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={400}>
              <BarChart data={costData} layout="horizontal">
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis type="number" tickFormatter={(value) => `$${(value / 1000).toFixed(0)}K`} />
                <YAxis dataKey="wbs_code" type="category" width={80} />
                <Tooltip formatter={(value) => formatCurrency(Number(value))} />
                <Bar dataKey="budget" fill="#8884d8" name="Budget" />
                <Bar dataKey="estimate_at_completion" fill="#82ca9d" name="EAC" />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Spending Forecast</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={400}>
              <AreaChart data={forecastData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="month" />
                <YAxis tickFormatter={(value) => `$${(value / 1000).toFixed(0)}K`} />
                <Tooltip formatter={(value) => formatCurrency(Number(value))} />
                <Area type="monotone" dataKey="cumulative_planned" stackId="1" stroke="#8884d8" fill="#8884d8" name="Planned" />
                <Area type="monotone" dataKey="cumulative_forecast" stackId="2" stroke="#82ca9d" fill="#82ca9d" name="Forecast" />
              </AreaChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Work Package Analysis</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-6">
            {costData.map((item, index) => (
              <div key={index} className="border rounded-lg p-4">
                <div className="flex justify-between items-start mb-4">
                  <div>
                    <h4 className="font-medium text-lg">{item.name}</h4>
                    <p className="text-sm text-gray-600">{item.wbs_code}</p>
                  </div>
                  <div className="flex items-center space-x-2">
                    {getStatusIcon(item.variance_at_completion)}
                    <span className={`font-medium ${getStatusColor(item.variance_at_completion)}`}>
                      {item.variance_at_completion <= 0 ? 'On Track' : 'Over Budget'}
                    </span>
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-5 gap-4 mb-4">
                  <div>
                    <p className="text-sm text-gray-600">Budget</p>
                    <p className="font-medium">{formatCurrency(item.budget)}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Actual to Date</p>
                    <p className="font-medium">{formatCurrency(item.actual_to_date)}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Estimate to Complete</p>
                    <p className="font-medium">{formatCurrency(item.estimate_to_complete)}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Estimate at Completion</p>
                    <p className="font-medium">{formatCurrency(item.estimate_at_completion)}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Variance</p>
                    <p className={`font-medium ${getStatusColor(item.variance_at_completion)}`}>
                      {formatCurrency(item.variance_at_completion)}
                    </p>
                  </div>
                </div>

                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span>Progress</span>
                    <span>{item.progress_percentage}%</span>
                  </div>
                  <Progress value={item.progress_percentage} />
                  <div className="flex justify-between text-xs text-gray-600">
                    <span>Cost Performance: {((item.actual_to_date / (item.budget * item.progress_percentage / 100)) * 100).toFixed(1)}%</span>
                    <span>Completion Forecast: {((item.progress_percentage / 100) * 100).toFixed(0)}%</span>
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