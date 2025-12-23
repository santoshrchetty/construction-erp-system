'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { CalendarDays, DollarSign, Users, AlertTriangle, TrendingUp, Clock } from 'lucide-react'

interface ProjectDashboardProps {
  projectId: string
}

interface DashboardData {
  project: {
    name: string
    code: string
    status: string
    budget: number
    actual_cost: number
    progress: number
    start_date: string
    planned_end_date: string
  }
  stats: {
    total_tasks: number
    completed_tasks: number
    overdue_tasks: number
    active_workers: number
    budget_utilization: number
    schedule_variance: number
  }
  recent_activities: Array<{
    id: string
    description: string
    date: string
    type: string
  }>
  cost_breakdown: Array<{
    category: string
    budgeted: number
    actual: number
    variance: number
  }>
}

export default function ProjectDashboard({ projectId }: ProjectDashboardProps) {
  const [data, setData] = useState<DashboardData | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadDashboardData()
  }, [projectId])

  const loadDashboardData = async () => {
    try {
      // Mock data - replace with actual API calls
      const mockData: DashboardData = {
        project: {
          name: 'Downtown Office Complex',
          code: 'DOC-2024-001',
          status: 'active',
          budget: 2500000,
          actual_cost: 1850000,
          progress: 74,
          start_date: '2024-01-15',
          planned_end_date: '2024-12-31'
        },
        stats: {
          total_tasks: 156,
          completed_tasks: 115,
          overdue_tasks: 8,
          active_workers: 24,
          budget_utilization: 74,
          schedule_variance: -5
        },
        recent_activities: [
          { id: '1', description: 'Foundation work completed', date: '2024-01-20', type: 'milestone' },
          { id: '2', description: 'Steel delivery received', date: '2024-01-19', type: 'material' },
          { id: '3', description: 'Safety inspection passed', date: '2024-01-18', type: 'inspection' }
        ],
        cost_breakdown: [
          { category: 'Labor', budgeted: 800000, actual: 620000, variance: -180000 },
          { category: 'Materials', budgeted: 1200000, actual: 950000, variance: -250000 },
          { category: 'Equipment', budgeted: 300000, actual: 180000, variance: -120000 },
          { category: 'Overhead', budgeted: 200000, actual: 100000, variance: -100000 }
        ]
      }
      setData(mockData)
    } catch (error) {
      console.error('Failed to load dashboard data:', error)
    } finally {
      setLoading(false)
    }
  }

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0
    }).format(amount)
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active': return 'bg-green-100 text-green-800'
      case 'planning': return 'bg-blue-100 text-blue-800'
      case 'on_hold': return 'bg-yellow-100 text-yellow-800'
      case 'completed': return 'bg-gray-100 text-gray-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  if (!data) return <div>No data available</div>

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-start">
        <div>
          <h1 className="text-3xl font-bold">{data.project.name}</h1>
          <p className="text-gray-600 mt-1">{data.project.code}</p>
        </div>
        <Badge className={getStatusColor(data.project.status)}>
          {data.project.status}
        </Badge>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Project Progress</CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{data.project.progress}%</div>
            <Progress value={data.project.progress} className="mt-2" />
            <p className="text-xs text-muted-foreground mt-2">
              {data.stats.completed_tasks} of {data.stats.total_tasks} tasks completed
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Budget Status</CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{formatCurrency(data.project.actual_cost)}</div>
            <p className="text-xs text-muted-foreground">
              of {formatCurrency(data.project.budget)} budget
            </p>
            <Progress value={data.stats.budget_utilization} className="mt-2" />
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Active Workers</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{data.stats.active_workers}</div>
            <p className="text-xs text-muted-foreground">
              Currently on site
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Overdue Tasks</CardTitle>
            <AlertTriangle className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-red-600">{data.stats.overdue_tasks}</div>
            <p className="text-xs text-muted-foreground">
              Require attention
            </p>
          </CardContent>
        </Card>
      </div>

      <Tabs defaultValue="overview" className="space-y-4">
        <TabsList>
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="costs">Cost Analysis</TabsTrigger>
          <TabsTrigger value="activities">Recent Activities</TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="space-y-4">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <Card>
              <CardHeader>
                <CardTitle>Schedule Information</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex items-center justify-between">
                  <span className="text-sm text-gray-600">Start Date</span>
                  <span className="font-medium">{new Date(data.project.start_date).toLocaleDateString()}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm text-gray-600">Planned End Date</span>
                  <span className="font-medium">{new Date(data.project.planned_end_date).toLocaleDateString()}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm text-gray-600">Schedule Variance</span>
                  <span className={`font-medium ${data.stats.schedule_variance < 0 ? 'text-red-600' : 'text-green-600'}`}>
                    {data.stats.schedule_variance}%
                  </span>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Key Metrics</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex items-center justify-between">
                  <span className="text-sm text-gray-600">Total Tasks</span>
                  <span className="font-medium">{data.stats.total_tasks}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm text-gray-600">Completion Rate</span>
                  <span className="font-medium">{Math.round((data.stats.completed_tasks / data.stats.total_tasks) * 100)}%</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm text-gray-600">Budget Utilization</span>
                  <span className="font-medium">{data.stats.budget_utilization}%</span>
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="costs" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Cost Breakdown</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {data.cost_breakdown.map((item, index) => (
                  <div key={index} className="flex items-center justify-between p-4 border rounded-lg">
                    <div>
                      <h4 className="font-medium">{item.category}</h4>
                      <p className="text-sm text-gray-600">
                        {formatCurrency(item.actual)} of {formatCurrency(item.budgeted)}
                      </p>
                    </div>
                    <div className="text-right">
                      <div className={`font-medium ${item.variance < 0 ? 'text-green-600' : 'text-red-600'}`}>
                        {formatCurrency(Math.abs(item.variance))}
                      </div>
                      <p className="text-xs text-gray-600">
                        {item.variance < 0 ? 'Under' : 'Over'} budget
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="activities" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Recent Activities</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {data.recent_activities.map((activity) => (
                  <div key={activity.id} className="flex items-center space-x-4 p-4 border rounded-lg">
                    <div className="flex-shrink-0">
                      <Clock className="h-5 w-5 text-gray-400" />
                    </div>
                    <div className="flex-1">
                      <p className="font-medium">{activity.description}</p>
                      <p className="text-sm text-gray-600">{new Date(activity.date).toLocaleDateString()}</p>
                    </div>
                    <Badge variant="outline">{activity.type}</Badge>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  )
}