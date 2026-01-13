'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar, Area, AreaChart } from 'recharts'
import { TrendingUp, TrendingDown, Target, DollarSign, Calendar, AlertTriangle } from 'lucide-react'

interface EarnedValueData {
  period: string
  planned_value: number
  earned_value: number
  actual_cost: number
  budget_at_completion: number
  estimate_at_completion: number
  cpi: number
  spi: number
  cv: number
  sv: number
}

interface PerformanceMetrics {
  cpi: number
  spi: number
  cv: number
  sv: number
  tcpi: number
  eac: number
  etc: number
  vac: number
}

export default function EarnedValueDashboard({ projectId }: { projectId: string }) {
  const [evData, setEvData] = useState<EarnedValueData[]>([])
  const [metrics, setMetrics] = useState<PerformanceMetrics | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadEarnedValueData()
  }, [projectId])

  const loadEarnedValueData = async () => {
    try {
      const mockEvData: EarnedValueData[] = [
        {
          period: 'Jan',
          planned_value: 250000,
          earned_value: 220000,
          actual_cost: 240000,
          budget_at_completion: 2500000,
          estimate_at_completion: 2650000,
          cpi: 0.92,
          spi: 0.88,
          cv: -20000,
          sv: -30000
        },
        {
          period: 'Feb',
          planned_value: 500000,
          earned_value: 480000,
          actual_cost: 520000,
          budget_at_completion: 2500000,
          estimate_at_completion: 2650000,
          cpi: 0.92,
          spi: 0.96,
          cv: -40000,
          sv: -20000
        },
        {
          period: 'Mar',
          planned_value: 750000,
          earned_value: 720000,
          actual_cost: 780000,
          budget_at_completion: 2500000,
          estimate_at_completion: 2650000,
          cpi: 0.92,
          spi: 0.96,
          cv: -60000,
          sv: -30000
        },
        {
          period: 'Apr',
          planned_value: 1000000,
          earned_value: 980000,
          actual_cost: 1050000,
          budget_at_completion: 2500000,
          estimate_at_completion: 2650000,
          cpi: 0.93,
          spi: 0.98,
          cv: -70000,
          sv: -20000
        },
        {
          period: 'May',
          planned_value: 1250000,
          earned_value: 1230000,
          actual_cost: 1320000,
          budget_at_completion: 2500000,
          estimate_at_completion: 2650000,
          cpi: 0.93,
          spi: 0.98,
          cv: -90000,
          sv: -20000
        },
        {
          period: 'Jun',
          planned_value: 1500000,
          earned_value: 1480000,
          actual_cost: 1580000,
          budget_at_completion: 2500000,
          estimate_at_completion: 2650000,
          cpi: 0.94,
          spi: 0.99,
          cv: -100000,
          sv: -20000
        }
      ]

      const currentMetrics: PerformanceMetrics = {
        cpi: 0.94,
        spi: 0.99,
        cv: -100000,
        sv: -20000,
        tcpi: 1.08,
        eac: 2650000,
        etc: 1070000,
        vac: -150000
      }

      setEvData(mockEvData)
      setMetrics(currentMetrics)
    } catch (error) {
      console.error('Failed to load earned value data:', error)
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

  const getPerformanceStatus = (value: number, threshold: number = 1.0) => {
    if (value >= threshold) return { color: 'text-green-600', icon: <TrendingUp className="h-4 w-4 text-green-600" /> }
    if (value >= threshold - 0.1) return { color: 'text-yellow-600', icon: <AlertTriangle className="h-4 w-4 text-yellow-600" /> }
    return { color: 'text-red-600', icon: <TrendingDown className="h-4 w-4 text-red-600" /> }
  }

  const getVarianceStatus = (value: number) => {
    if (value >= 0) return { color: 'text-green-600', icon: <TrendingUp className="h-4 w-4 text-green-600" /> }
    if (value >= -50000) return { color: 'text-yellow-600', icon: <AlertTriangle className="h-4 w-4 text-yellow-600" /> }
    return { color: 'text-red-600', icon: <TrendingDown className="h-4 w-4 text-red-600" /> }
  }

  if (loading || !metrics) {
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
          <h1 className="text-3xl font-bold">Earned Value Management</h1>
          <p className="text-gray-600 mt-1">Project performance measurement and forecasting</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Cost Performance Index</CardTitle>
            {getPerformanceStatus(metrics.cpi).icon}
          </CardHeader>
          <CardContent>
            <div className={`text-2xl font-bold ${getPerformanceStatus(metrics.cpi).color}`}>
              {metrics.cpi.toFixed(2)}
            </div>
            <p className="text-xs text-muted-foreground">
              {metrics.cpi >= 1.0 ? 'Under budget' : 'Over budget'}
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Schedule Performance Index</CardTitle>
            {getPerformanceStatus(metrics.spi).icon}
          </CardHeader>
          <CardContent>
            <div className={`text-2xl font-bold ${getPerformanceStatus(metrics.spi).color}`}>
              {metrics.spi.toFixed(2)}
            </div>
            <p className="text-xs text-muted-foreground">
              {metrics.spi >= 1.0 ? 'Ahead of schedule' : 'Behind schedule'}
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Cost Variance</CardTitle>
            {getVarianceStatus(metrics.cv).icon}
          </CardHeader>
          <CardContent>
            <div className={`text-2xl font-bold ${getVarianceStatus(metrics.cv).color}`}>
              {formatCurrency(Math.abs(metrics.cv))}
            </div>
            <p className="text-xs text-muted-foreground">
              {metrics.cv >= 0 ? 'Under budget' : 'Over budget'}
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Schedule Variance</CardTitle>
            {getVarianceStatus(metrics.sv).icon}
          </CardHeader>
          <CardContent>
            <div className={`text-2xl font-bold ${getVarianceStatus(metrics.sv).color}`}>
              {formatCurrency(Math.abs(metrics.sv))}
            </div>
            <p className="text-xs text-muted-foreground">
              {metrics.sv >= 0 ? 'Ahead' : 'Behind'} schedule
            </p>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Earned Value Trend</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={400}>
              <LineChart data={evData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="period" />
                <YAxis tickFormatter={(value) => `$${(value / 1000).toFixed(0)}K`} />
                <Tooltip formatter={(value) => formatCurrency(Number(value))} />
                <Line type="monotone" dataKey="planned_value" stroke="#8884d8" name="Planned Value (PV)" strokeWidth={2} />
                <Line type="monotone" dataKey="earned_value" stroke="#82ca9d" name="Earned Value (EV)" strokeWidth={2} />
                <Line type="monotone" dataKey="actual_cost" stroke="#ffc658" name="Actual Cost (AC)" strokeWidth={2} />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Performance Indices Trend</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={400}>
              <LineChart data={evData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="period" />
                <YAxis domain={[0.8, 1.2]} />
                <Tooltip formatter={(value) => Number(value).toFixed(2)} />
                <Line type="monotone" dataKey="cpi" stroke="#8884d8" name="CPI" strokeWidth={2} />
                <Line type="monotone" dataKey="spi" stroke="#82ca9d" name="SPI" strokeWidth={2} />
                <Line type="monotone" dataKey={1.0} stroke="#ff0000" strokeDasharray="5 5" name="Baseline" />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Variance Analysis</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={evData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="period" />
                <YAxis tickFormatter={(value) => `$${(value / 1000).toFixed(0)}K`} />
                <Tooltip formatter={(value) => formatCurrency(Number(value))} />
                <Bar dataKey="cv" fill="#8884d8" name="Cost Variance" />
                <Bar dataKey="sv" fill="#82ca9d" name="Schedule Variance" />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Project Forecast</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-2">
                  <p className="text-sm text-gray-600">Budget at Completion (BAC)</p>
                  <p className="text-lg font-bold">{formatCurrency(2500000)}</p>
                </div>
                <div className="space-y-2">
                  <p className="text-sm text-gray-600">Estimate at Completion (EAC)</p>
                  <p className={`text-lg font-bold ${metrics.eac > 2500000 ? 'text-red-600' : 'text-green-600'}`}>
                    {formatCurrency(metrics.eac)}
                  </p>
                </div>
                <div className="space-y-2">
                  <p className="text-sm text-gray-600">Estimate to Complete (ETC)</p>
                  <p className="text-lg font-bold">{formatCurrency(metrics.etc)}</p>
                </div>
                <div className="space-y-2">
                  <p className="text-sm text-gray-600">Variance at Completion (VAC)</p>
                  <p className={`text-lg font-bold ${metrics.vac >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                    {formatCurrency(Math.abs(metrics.vac))}
                  </p>
                </div>
              </div>
              
              <div className="border-t pt-4">
                <div className="space-y-2">
                  <p className="text-sm text-gray-600">To Complete Performance Index (TCPI)</p>
                  <p className={`text-xl font-bold ${metrics.tcpi <= 1.0 ? 'text-green-600' : 'text-red-600'}`}>
                    {metrics.tcpi.toFixed(2)}
                  </p>
                  <p className="text-xs text-gray-500">
                    {metrics.tcpi <= 1.0 
                      ? 'Achievable with current performance' 
                      : 'Requires improved performance to meet budget'
                    }
                  </p>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Performance Summary</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="space-y-4">
              <h4 className="font-medium text-lg">Cost Performance</h4>
              <div className="space-y-2">
                <div className="flex justify-between">
                  <span>Cost Performance Index:</span>
                  <span className={`font-medium ${getPerformanceStatus(metrics.cpi).color}`}>
                    {metrics.cpi.toFixed(2)}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span>Cost Variance:</span>
                  <span className={`font-medium ${getVarianceStatus(metrics.cv).color}`}>
                    {formatCurrency(metrics.cv)}
                  </span>
                </div>
                <p className="text-sm text-gray-600">
                  {metrics.cpi >= 1.0 
                    ? 'Project is performing well within budget constraints.'
                    : 'Project is over budget and requires cost control measures.'
                  }
                </p>
              </div>
            </div>

            <div className="space-y-4">
              <h4 className="font-medium text-lg">Schedule Performance</h4>
              <div className="space-y-2">
                <div className="flex justify-between">
                  <span>Schedule Performance Index:</span>
                  <span className={`font-medium ${getPerformanceStatus(metrics.spi).color}`}>
                    {metrics.spi.toFixed(2)}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span>Schedule Variance:</span>
                  <span className={`font-medium ${getVarianceStatus(metrics.sv).color}`}>
                    {formatCurrency(metrics.sv)}
                  </span>
                </div>
                <p className="text-sm text-gray-600">
                  {metrics.spi >= 1.0 
                    ? 'Project is on or ahead of schedule.'
                    : 'Project is behind schedule and may need acceleration.'
                  }
                </p>
              </div>
            </div>

            <div className="space-y-4">
              <h4 className="font-medium text-lg">Forecast</h4>
              <div className="space-y-2">
                <div className="flex justify-between">
                  <span>Completion Forecast:</span>
                  <span className={`font-medium ${metrics.eac > 2500000 ? 'text-red-600' : 'text-green-600'}`}>
                    {formatCurrency(metrics.eac)}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span>Required Performance:</span>
                  <span className={`font-medium ${metrics.tcpi <= 1.0 ? 'text-green-600' : 'text-red-600'}`}>
                    {metrics.tcpi.toFixed(2)}
                  </span>
                </div>
                <p className="text-sm text-gray-600">
                  {metrics.vac >= 0 
                    ? 'Project is forecasted to finish under budget.'
                    : `Project is forecasted to exceed budget by ${formatCurrency(Math.abs(metrics.vac))}.`
                  }
                </p>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}