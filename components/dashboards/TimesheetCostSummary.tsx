'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Badge } from '@/components/ui/badge'
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line, PieChart, Pie, Cell, Area, AreaChart } from 'recharts'
import { Clock, DollarSign, Users, TrendingUp, Calendar, Target } from 'lucide-react'

interface TimesheetSummary {
  period: string
  total_hours: number
  regular_hours: number
  overtime_hours: number
  total_cost: number
  average_hourly_rate: number
  employees_count: number
  productivity_index: number
}

interface CostByCategory {
  category: string
  hours: number
  cost: number
  percentage: number
}

interface EmployeeProductivity {
  employee_name: string
  total_hours: number
  total_cost: number
  hourly_rate: number
  efficiency_rating: number
  projects_worked: number
}

interface CostObjectAllocation {
  cost_object_code: string
  cost_object_name: string
  allocated_hours: number
  allocated_cost: number
  budget_hours: number
  budget_cost: number
  variance_hours: number
  variance_cost: number
}

export default function TimesheetCostSummary({ projectId }: { projectId: string }) {
  const [timesheetSummary, setTimesheetSummary] = useState<TimesheetSummary[]>([])
  const [costByCategory, setCostByCategory] = useState<CostByCategory[]>([])
  const [employeeProductivity, setEmployeeProductivity] = useState<EmployeeProductivity[]>([])
  const [costObjectAllocation, setCostObjectAllocation] = useState<CostObjectAllocation[]>([])
  const [selectedPeriod, setSelectedPeriod] = useState('month')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadTimesheetData()
  }, [projectId, selectedPeriod])

  const loadTimesheetData = async () => {
    try {
      const mockTimesheetSummary: TimesheetSummary[] = [
        {
          period: 'Week 1',
          total_hours: 320,
          regular_hours: 280,
          overtime_hours: 40,
          total_cost: 16800,
          average_hourly_rate: 52.5,
          employees_count: 8,
          productivity_index: 0.85
        },
        {
          period: 'Week 2',
          total_hours: 340,
          regular_hours: 300,
          overtime_hours: 40,
          total_cost: 18200,
          average_hourly_rate: 53.5,
          employees_count: 8,
          productivity_index: 0.88
        },
        {
          period: 'Week 3',
          total_hours: 360,
          regular_hours: 320,
          overtime_hours: 40,
          total_cost: 19600,
          average_hourly_rate: 54.4,
          employees_count: 9,
          productivity_index: 0.92
        },
        {
          period: 'Week 4',
          total_hours: 380,
          regular_hours: 340,
          overtime_hours: 40,
          total_cost: 21000,
          average_hourly_rate: 55.3,
          employees_count: 10,
          productivity_index: 0.89
        }
      ]

      const mockCostByCategory: CostByCategory[] = [
        { category: 'Site Preparation', hours: 280, cost: 14000, percentage: 18.5 },
        { category: 'Foundation Work', hours: 420, cost: 23100, percentage: 30.5 },
        { category: 'Structural Work', hours: 360, cost: 21600, percentage: 28.5 },
        { category: 'MEP Installation', hours: 180, cost: 10800, percentage: 14.3 },
        { category: 'Finishing Work', hours: 120, cost: 6000, percentage: 8.2 }
      ]

      const mockEmployeeProductivity: EmployeeProductivity[] = [
        {
          employee_name: 'John Smith',
          total_hours: 168,
          total_cost: 8400,
          hourly_rate: 50,
          efficiency_rating: 0.92,
          projects_worked: 2
        },
        {
          employee_name: 'Mike Johnson',
          total_hours: 172,
          total_cost: 9460,
          hourly_rate: 55,
          efficiency_rating: 0.88,
          projects_worked: 1
        },
        {
          employee_name: 'Sarah Davis',
          total_hours: 160,
          total_cost: 9600,
          hourly_rate: 60,
          efficiency_rating: 0.95,
          projects_worked: 3
        },
        {
          employee_name: 'Robert Wilson',
          total_hours: 176,
          total_cost: 7920,
          hourly_rate: 45,
          efficiency_rating: 0.85,
          projects_worked: 1
        }
      ]

      const mockCostObjectAllocation: CostObjectAllocation[] = [
        {
          cost_object_code: 'WBS-01.01',
          cost_object_name: 'Site Survey',
          allocated_hours: 120,
          allocated_cost: 6000,
          budget_hours: 100,
          budget_cost: 5000,
          variance_hours: 20,
          variance_cost: 1000
        },
        {
          cost_object_code: 'WBS-02.01',
          cost_object_name: 'Foundation Excavation',
          allocated_hours: 280,
          allocated_cost: 14000,
          budget_hours: 300,
          budget_cost: 15000,
          variance_hours: -20,
          variance_cost: -1000
        },
        {
          cost_object_code: 'WBS-03.01',
          cost_object_name: 'Concrete Work',
          allocated_hours: 360,
          allocated_cost: 21600,
          budget_hours: 320,
          budget_cost: 19200,
          variance_hours: 40,
          variance_cost: 2400
        }
      ]

      setTimesheetSummary(mockTimesheetSummary)
      setCostByCategory(mockCostByCategory)
      setEmployeeProductivity(mockEmployeeProductivity)
      setCostObjectAllocation(mockCostObjectAllocation)
    } catch (error) {
      console.error('Failed to load timesheet data:', error)
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

  const getTotalHours = () => timesheetSummary.reduce((sum, item) => sum + item.total_hours, 0)
  const getTotalCost = () => timesheetSummary.reduce((sum, item) => sum + item.total_cost, 0)
  const getAverageProductivity = () => {
    const avg = timesheetSummary.reduce((sum, item) => sum + item.productivity_index, 0) / timesheetSummary.length
    return avg * 100
  }
  const getTotalEmployees = () => Math.max(...timesheetSummary.map(item => item.employees_count))

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
          <h1 className="text-3xl font-bold">Timesheet Cost Summary</h1>
          <p className="text-gray-600 mt-1">Labor cost analysis and productivity metrics</p>
        </div>
        <Select value={selectedPeriod} onValueChange={setSelectedPeriod}>
          <SelectTrigger className="w-32">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="week">Week</SelectItem>
            <SelectItem value="month">Month</SelectItem>
            <SelectItem value="quarter">Quarter</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Hours</CardTitle>
            <Clock className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{getTotalHours().toLocaleString()}</div>
            <p className="text-xs text-muted-foreground">Labor hours logged</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Labor Cost</CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatCurrency(getTotalCost())}</div>
            <p className="text-xs text-muted-foreground">Including overtime</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Active Employees</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{getTotalEmployees()}</div>
            <p className="text-xs text-muted-foreground">Working on project</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Avg Productivity</CardTitle>
            <Target className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{getAverageProductivity().toFixed(1)}%</div>
            <p className="text-xs text-muted-foreground">Efficiency index</p>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Labor Cost Trend</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <AreaChart data={timesheetSummary}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="period" />
                <YAxis tickFormatter={(value) => `$${(value / 1000).toFixed(0)}K`} />
                <Tooltip formatter={(value) => formatCurrency(Number(value))} />
                <Area type="monotone" dataKey="total_cost" stackId="1" stroke="#8884d8" fill="#8884d8" name="Total Cost" />
              </AreaChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Hours Distribution</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={timesheetSummary}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="period" />
                <YAxis />
                <Tooltip />
                <Bar dataKey="regular_hours" fill="#8884d8" name="Regular Hours" />
                <Bar dataKey="overtime_hours" fill="#82ca9d" name="Overtime Hours" />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Cost by Work Category</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={costByCategory}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ category, percentage }) => `${category}: ${percentage}%`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="cost"
                >
                  {costByCategory.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip formatter={(value) => formatCurrency(Number(value))} />
              </PieChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Productivity Trend</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={timesheetSummary}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="period" />
                <YAxis domain={[0.8, 1.0]} tickFormatter={(value) => `${(value * 100).toFixed(0)}%`} />
                <Tooltip formatter={(value) => `${(Number(value) * 100).toFixed(1)}%`} />
                <Line type="monotone" dataKey="productivity_index" stroke="#8884d8" name="Productivity" strokeWidth={2} />
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Employee Productivity Analysis</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {employeeProductivity.map((employee, index) => (
              <div key={index} className="flex items-center justify-between p-4 border rounded-lg">
                <div className="flex-1">
                  <h4 className="font-medium">{employee.employee_name}</h4>
                  <div className="flex space-x-4 text-sm text-gray-600 mt-1">
                    <span>Hours: {employee.total_hours}</span>
                    <span>Rate: {formatCurrency(employee.hourly_rate)}/hr</span>
                    <span>Projects: {employee.projects_worked}</span>
                  </div>
                </div>
                <div className="text-right">
                  <div className="text-lg font-bold">{formatCurrency(employee.total_cost)}</div>
                  <Badge className={employee.efficiency_rating >= 0.9 ? 'bg-green-100 text-green-800' : 
                                   employee.efficiency_rating >= 0.8 ? 'bg-yellow-100 text-yellow-800' : 
                                   'bg-red-100 text-red-800'}>
                    {(employee.efficiency_rating * 100).toFixed(0)}% Efficiency
                  </Badge>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Cost Object Allocation</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {costObjectAllocation.map((allocation, index) => (
              <div key={index} className="border rounded-lg p-4">
                <div className="flex justify-between items-start mb-4">
                  <div>
                    <h4 className="font-medium text-lg">{allocation.cost_object_name}</h4>
                    <p className="text-sm text-gray-600">{allocation.cost_object_code}</p>
                  </div>
                  <Badge className={allocation.variance_cost <= 0 ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}>
                    {allocation.variance_cost <= 0 ? 'Under Budget' : 'Over Budget'}
                  </Badge>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                  <div>
                    <p className="text-sm text-gray-600">Allocated Hours</p>
                    <p className="font-medium">{allocation.allocated_hours} hrs</p>
                    <p className="text-xs text-gray-500">Budget: {allocation.budget_hours} hrs</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Allocated Cost</p>
                    <p className="font-medium">{formatCurrency(allocation.allocated_cost)}</p>
                    <p className="text-xs text-gray-500">Budget: {formatCurrency(allocation.budget_cost)}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Hours Variance</p>
                    <p className={`font-medium ${allocation.variance_hours <= 0 ? 'text-green-600' : 'text-red-600'}`}>
                      {allocation.variance_hours > 0 ? '+' : ''}{allocation.variance_hours} hrs
                    </p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Cost Variance</p>
                    <p className={`font-medium ${allocation.variance_cost <= 0 ? 'text-green-600' : 'text-red-600'}`}>
                      {formatCurrency(allocation.variance_cost)}
                    </p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card>
          <CardHeader>
            <CardTitle>Cost Summary</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              <div className="flex justify-between">
                <span>Regular Hours Cost:</span>
                <span className="font-medium">
                  {formatCurrency(timesheetSummary.reduce((sum, item) => sum + (item.regular_hours * item.average_hourly_rate), 0))}
                </span>
              </div>
              <div className="flex justify-between">
                <span>Overtime Premium:</span>
                <span className="font-medium">
                  {formatCurrency(timesheetSummary.reduce((sum, item) => sum + (item.overtime_hours * item.average_hourly_rate * 0.5), 0))}
                </span>
              </div>
              <div className="flex justify-between border-t pt-2">
                <span>Total Labor Cost:</span>
                <span className="font-bold text-green-600">{formatCurrency(getTotalCost())}</span>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Efficiency Metrics</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              <div className="flex justify-between">
                <span>Average Hourly Rate:</span>
                <span className="font-medium">
                  {formatCurrency(getTotalCost() / getTotalHours())}
                </span>
              </div>
              <div className="flex justify-between">
                <span>Hours per Employee:</span>
                <span className="font-medium">
                  {(getTotalHours() / getTotalEmployees()).toFixed(1)} hrs
                </span>
              </div>
              <div className="flex justify-between">
                <span>Productivity Index:</span>
                <span className="font-medium">{getAverageProductivity().toFixed(1)}%</span>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Period Comparison</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              <div className="flex justify-between">
                <span>Current Period:</span>
                <span className="font-medium">{timesheetSummary[timesheetSummary.length - 1]?.period}</span>
              </div>
              <div className="flex justify-between">
                <span>Hours This Period:</span>
                <span className="font-medium">{timesheetSummary[timesheetSummary.length - 1]?.total_hours} hrs</span>
              </div>
              <div className="flex justify-between">
                <span>Cost This Period:</span>
                <span className="font-medium">{formatCurrency(timesheetSummary[timesheetSummary.length - 1]?.total_cost || 0)}</span>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}