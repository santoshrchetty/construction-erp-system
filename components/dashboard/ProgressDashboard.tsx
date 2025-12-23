'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { TrendingUp, TrendingDown, Calendar, Target, AlertTriangle, CheckCircle } from 'lucide-react'

interface ProgressData {
  overall_progress: number
  schedule_performance: {
    planned_progress: number
    actual_progress: number
    variance: number
    status: 'ahead' | 'on_track' | 'behind'
  }
  cost_performance: {
    budgeted_cost: number
    actual_cost: number
    earned_value: number
    cpi: number
    spi: number
  }
  milestones: Array<{
    id: string
    name: string
    planned_date: string
    actual_date?: string
    status: 'completed' | 'in_progress' | 'delayed' | 'upcoming'
    progress: number
  }>
  activities_progress: Array<{
    wbs_code: string
    name: string
    planned_progress: number
    actual_progress: number
    status: string
  }>
  critical_path: Array<{
    activity: string
    float: number
    is_critical: boolean
  }>
}

interface ProgressDashboardProps {
  projectId: string
}

export default function ProgressDashboard({ projectId }: ProgressDashboardProps) {
  const [progressData, setProgressData] = useState<ProgressData | null>(null)
  const [selectedPeriod, setSelectedPeriod] = useState('month')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadProgressData()
  }, [projectId, selectedPeriod])

  const loadProgressData = async () => {
    try {
      // Mock data - replace with actual API call
      const mockData: ProgressData = {
        overall_progress: 68,
        schedule_performance: {
          planned_progress: 75,
          actual_progress: 68,
          variance: -7,
          status: 'behind'
        },
        cost_performance: {
          budgeted_cost: 1875000,
          actual_cost: 1650000,
          earned_value: 1700000,
          cpi: 1.03,
          spi: 0.91
        },
        milestones: [
          {
            id: '1',
            name: 'Site Preparation Complete',
            planned_date: '2024-01-31',
            actual_date: '2024-01-29',
            status: 'completed',
            progress: 100
          },
          {
            id: '2',
            name: 'Foundation Work Complete',
            planned_date: '2024-02-28',
            status: 'in_progress',
            progress: 75
          },
          {
            id: '3',
            name: 'Structural Frame Complete',
            planned_date: '2024-04-15',
            status: 'upcoming',
            progress: 0
          },
          {
            id: '4',
            name: 'Building Envelope Complete',
            planned_date: '2024-06-30',
            status: 'upcoming',
            progress: 0
          }
        ],
        activities_progress: [
          { wbs_code: 'WBS-01', name: 'Site Preparation', planned_progress: 100, actual_progress: 100, status: 'completed' },
          { wbs_code: 'WBS-02', name: 'Foundation Work', planned_progress: 90, actual_progress: 75, status: 'in_progress' },
          { wbs_code: 'WBS-03', name: 'Structural Work', planned_progress: 45, actual_progress: 30, status: 'in_progress' },
          { wbs_code: 'WBS-04', name: 'MEP Installation', planned_progress: 20, actual_progress: 10, status: 'in_progress' },
          { wbs_code: 'WBS-05', name: 'Finishing Work', planned_progress: 5, actual_progress: 0, status: 'not_started' }
        ],
        critical_path: [
          { activity: 'Foundation Excavation', float: 0, is_critical: true },
          { activity: 'Concrete Foundation', float: 0, is_critical: true },
          { activity: 'Steel Frame Erection', float: 2, is_critical: false },
          { activity: 'Roof Installation', float: 0, is_critical: true }
        ]
      }
      setProgressData(mockData)
    } catch (error) {
      console.error('Failed to load progress data:', error)
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

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'completed':
        return <CheckCircle className="h-4 w-4 text-green-600" />
      case 'ahead':
        return <TrendingUp className="h-4 w-4 text-green-600" />
      case 'on_track':
        return <Target className="h-4 w-4 text-blue-600" />
      case 'behind':
      case 'delayed':
        return <AlertTriangle className="h-4 w-4 text-red-600" />
      default:
        return <Calendar className="h-4 w-4 text-gray-600" />
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed':
        return 'bg-green-100 text-green-800'
      case 'ahead':
        return 'bg-green-100 text-green-800'
      case 'on_track':
        return 'bg-blue-100 text-blue-800'
      case 'behind':
      case 'delayed':
        return 'bg-red-100 text-red-800'
      case 'in_progress':
        return 'bg-yellow-100 text-yellow-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  if (!progressData) return <div>No progress data available</div>

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">Progress Dashboard</h1>
          <p className="text-gray-600 mt-1">Project progress tracking and performance metrics</p>
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

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Overall Progress</CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{progressData.overall_progress}%</div>
            <Progress value={progressData.overall_progress} className="mt-2" />
            <p className="text-xs text-muted-foreground mt-2">
              Project completion
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Schedule Performance</CardTitle>
            {getStatusIcon(progressData.schedule_performance.status)}
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{progressData.schedule_performance.actual_progress}%</div>
            <p className="text-xs text-muted-foreground">
              vs {progressData.schedule_performance.planned_progress}% planned
            </p>
            <div className={`text-sm font-medium mt-2 ${progressData.schedule_performance.variance < 0 ? 'text-red-600' : 'text-green-600'}`}>
              {progressData.schedule_performance.variance > 0 ? '+' : ''}{progressData.schedule_performance.variance}% variance
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Cost Performance Index</CardTitle>
            {progressData.cost_performance.cpi >= 1 ? (
              <TrendingUp className="h-4 w-4 text-green-600" />
            ) : (
              <TrendingDown className="h-4 w-4 text-red-600" />
            )}
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{progressData.cost_performance.cpi.toFixed(2)}</div>
            <p className="text-xs text-muted-foreground">
              {formatCurrency(progressData.cost_performance.earned_value)} earned
            </p>
            <p className="text-xs text-muted-foreground">
              {formatCurrency(progressData.cost_performance.actual_cost)} spent
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Schedule Performance Index</CardTitle>
            {progressData.cost_performance.spi >= 1 ? (
              <TrendingUp className="h-4 w-4 text-green-600" />
            ) : (
              <TrendingDown className="h-4 w-4 text-red-600" />
            )}
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{progressData.cost_performance.spi.toFixed(2)}</div>
            <p className="text-xs text-muted-foreground">
              Schedule efficiency
            </p>
          </CardContent>
        </Card>
      </div>

      <Tabs defaultValue="milestones" className="space-y-4">
        <TabsList>
          <TabsTrigger value="milestones">Milestones</TabsTrigger>
          <TabsTrigger value="activities">Activities Progress</TabsTrigger>
          <TabsTrigger value="critical">Critical Path</TabsTrigger>
        </TabsList>

        <TabsContent value="milestones" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Project Milestones</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {progressData.milestones.map((milestone) => (
                  <div key={milestone.id} className="flex items-center justify-between p-4 border rounded-lg">
                    <div className="flex items-center space-x-4">
                      {getStatusIcon(milestone.status)}
                      <div>
                        <h4 className="font-medium">{milestone.name}</h4>
                        <p className="text-sm text-gray-600">
                          Planned: {new Date(milestone.planned_date).toLocaleDateString()}
                          {milestone.actual_date && (
                            <span> | Actual: {new Date(milestone.actual_date).toLocaleDateString()}</span>
                          )}
                        </p>
                      </div>
                    </div>
                    <div className="flex items-center space-x-4">
                      <div className="w-24">
                        <Progress value={milestone.progress} />
                      </div>
                      <Badge className={getStatusColor(milestone.status)}>
                        {milestone.status.replace('_', ' ')}
                      </Badge>
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
              <CardTitle>Activities Progress</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {progressData.activities_progress.map((activity, index) => (
                  <div key={index} className="space-y-2">
                    <div className="flex justify-between items-center">
                      <div>
                        <h4 className="font-medium">{activity.name}</h4>
                        <p className="text-sm text-gray-600">{activity.wbs_code}</p>
                      </div>
                      <Badge className={getStatusColor(activity.status)}>
                        {activity.status.replace('_', ' ')}
                      </Badge>
                    </div>
                    <div className="space-y-1">
                      <div className="flex justify-between text-sm">
                        <span>Actual Progress</span>
                        <span>{activity.actual_progress}%</span>
                      </div>
                      <Progress value={activity.actual_progress} />
                      <div className="flex justify-between text-xs text-gray-600">
                        <span>Planned: {activity.planned_progress}%</span>
                        <span className={activity.actual_progress >= activity.planned_progress ? 'text-green-600' : 'text-red-600'}>
                          Variance: {activity.actual_progress - activity.planned_progress}%
                        </span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="critical" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Critical Path Analysis</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {progressData.critical_path.map((item, index) => (
                  <div key={index} className="flex items-center justify-between p-4 border rounded-lg">
                    <div className="flex items-center space-x-4">
                      {item.is_critical ? (
                        <AlertTriangle className="h-4 w-4 text-red-600" />
                      ) : (
                        <Calendar className="h-4 w-4 text-gray-600" />
                      )}
                      <div>
                        <h4 className="font-medium">{item.activity}</h4>
                        <p className="text-sm text-gray-600">
                          Float: {item.float} days
                        </p>
                      </div>
                    </div>
                    <Badge className={item.is_critical ? 'bg-red-100 text-red-800' : 'bg-gray-100 text-gray-800'}>
                      {item.is_critical ? 'Critical' : 'Non-Critical'}
                    </Badge>
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