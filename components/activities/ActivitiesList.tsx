'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Progress } from '@/components/ui/progress'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { CalendarDays, Clock, DollarSign, Search, Plus, Play, Pause, CheckCircle, AlertCircle } from 'lucide-react'

interface Activity {
  id: string
  code: string
  name: string
  description?: string
  planned_start_date: string
  planned_end_date: string
  actual_start_date?: string
  actual_end_date?: string
  planned_hours: number
  budget_amount: number
  progress_percentage: number
  status: 'not_started' | 'in_progress' | 'completed' | 'on_hold'
  wbs_node: {
    code: string
    name: string
  }
  responsible_user?: {
    name: string
    email: string
  }
  tasks_count: number
  completed_tasks: number
}

interface ActivitiesListProps {
  projectId: string
}

export default function ActivitiesList({ projectId }: ActivitiesListProps) {
  const [activities, setActivities] = useState<Activity[]>([])
  const [filteredActivities, setFilteredActivities] = useState<Activity[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState('all')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadActivities()
  }, [projectId])

  useEffect(() => {
    filterActivities()
  }, [activities, searchTerm, statusFilter])

  const loadActivities = async () => {
    try {
      // Mock data - replace with actual API call
      const mockActivities: Activity[] = [
        {
          id: '1',
          code: 'ACT-001',
          name: 'Site Survey and Investigation',
          description: 'Complete topographical survey and soil investigation',
          planned_start_date: '2024-01-15',
          planned_end_date: '2024-01-25',
          actual_start_date: '2024-01-15',
          actual_end_date: '2024-01-24',
          planned_hours: 80,
          budget_amount: 25000,
          progress_percentage: 100,
          status: 'completed',
          wbs_node: { code: 'WBS-01.01', name: 'Site Survey' },
          responsible_user: { name: 'John Smith', email: 'john@example.com' },
          tasks_count: 4,
          completed_tasks: 4
        },
        {
          id: '2',
          code: 'ACT-002',
          name: 'Site Clearing and Preparation',
          description: 'Clear vegetation and prepare site for construction',
          planned_start_date: '2024-01-26',
          planned_end_date: '2024-02-05',
          actual_start_date: '2024-01-26',
          planned_hours: 120,
          budget_amount: 75000,
          progress_percentage: 75,
          status: 'in_progress',
          wbs_node: { code: 'WBS-01.02', name: 'Site Clearing' },
          responsible_user: { name: 'Mike Johnson', email: 'mike@example.com' },
          tasks_count: 6,
          completed_tasks: 4
        },
        {
          id: '3',
          code: 'ACT-003',
          name: 'Foundation Excavation',
          description: 'Excavate foundation trenches and footings',
          planned_start_date: '2024-02-06',
          planned_end_date: '2024-02-15',
          planned_hours: 160,
          budget_amount: 120000,
          progress_percentage: 0,
          status: 'not_started',
          wbs_node: { code: 'WBS-02.01', name: 'Excavation' },
          responsible_user: { name: 'Sarah Davis', email: 'sarah@example.com' },
          tasks_count: 8,
          completed_tasks: 0
        },
        {
          id: '4',
          code: 'ACT-004',
          name: 'Concrete Foundation Work',
          description: 'Pour concrete for foundation and footings',
          planned_start_date: '2024-02-16',
          planned_end_date: '2024-02-28',
          planned_hours: 200,
          budget_amount: 280000,
          progress_percentage: 0,
          status: 'not_started',
          wbs_node: { code: 'WBS-02.02', name: 'Concrete Foundation' },
          tasks_count: 10,
          completed_tasks: 0
        }
      ]
      setActivities(mockActivities)
    } catch (error) {
      console.error('Failed to load activities:', error)
    } finally {
      setLoading(false)
    }
  }

  const filterActivities = () => {
    let filtered = activities

    if (searchTerm) {
      filtered = filtered.filter(activity =>
        activity.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        activity.code.toLowerCase().includes(searchTerm.toLowerCase()) ||
        activity.description?.toLowerCase().includes(searchTerm.toLowerCase())
      )
    }

    if (statusFilter !== 'all') {
      filtered = filtered.filter(activity => activity.status === statusFilter)
    }

    setFilteredActivities(filtered)
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'completed':
        return <CheckCircle className="h-4 w-4 text-green-600" />
      case 'in_progress':
        return <Play className="h-4 w-4 text-blue-600" />
      case 'on_hold':
        return <Pause className="h-4 w-4 text-yellow-600" />
      case 'not_started':
        return <Clock className="h-4 w-4 text-gray-600" />
      default:
        return <AlertCircle className="h-4 w-4 text-red-600" />
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed':
        return 'bg-green-100 text-green-800'
      case 'in_progress':
        return 'bg-blue-100 text-blue-800'
      case 'on_hold':
        return 'bg-yellow-100 text-yellow-800'
      case 'not_started':
        return 'bg-gray-100 text-gray-800'
      default:
        return 'bg-red-100 text-red-800'
    }
  }

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0
    }).format(amount)
  }

  const isOverdue = (activity: Activity) => {
    if (activity.status === 'completed') return false
    const today = new Date()
    const plannedEnd = new Date(activity.planned_end_date)
    return today > plannedEnd
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
          <h1 className="text-3xl font-bold">Activities</h1>
          <p className="text-gray-600 mt-1">Project activities and work packages</p>
        </div>
        <Button>
          <Plus className="h-4 w-4 mr-2" />
          New Activity
        </Button>
      </div>

      <div className="flex gap-4 items-center">
        <div className="relative flex-1 max-w-sm">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
          <Input
            placeholder="Search activities..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="pl-10"
          />
        </div>
        <Select value={statusFilter} onValueChange={setStatusFilter}>
          <SelectTrigger className="w-48">
            <SelectValue placeholder="Filter by status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Status</SelectItem>
            <SelectItem value="not_started">Not Started</SelectItem>
            <SelectItem value="in_progress">In Progress</SelectItem>
            <SelectItem value="completed">Completed</SelectItem>
            <SelectItem value="on_hold">On Hold</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {filteredActivities.map((activity) => (
          <Card key={activity.id} className={`hover:shadow-lg transition-shadow ${isOverdue(activity) ? 'border-red-200' : ''}`}>
            <CardHeader className="pb-3">
              <div className="flex justify-between items-start">
                <div className="flex-1">
                  <div className="flex items-center space-x-2">
                    {getStatusIcon(activity.status)}
                    <CardTitle className="text-lg">{activity.name}</CardTitle>
                    {isOverdue(activity) && (
                      <Badge variant="destructive" className="text-xs">
                        Overdue
                      </Badge>
                    )}
                  </div>
                  <p className="text-sm text-gray-600 mt-1">{activity.code}</p>
                  {activity.description && (
                    <p className="text-sm text-gray-500 mt-2">{activity.description}</p>
                  )}
                </div>
                <Badge className={getStatusColor(activity.status)}>
                  {activity.status.replace('_', ' ')}
                </Badge>
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span>Progress</span>
                  <span>{activity.progress_percentage}%</span>
                </div>
                <Progress value={activity.progress_percentage} />
                <div className="text-xs text-gray-600">
                  {activity.completed_tasks} of {activity.tasks_count} tasks completed
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4 text-sm">
                <div className="flex items-center text-gray-600">
                  <CalendarDays className="h-4 w-4 mr-2" />
                  <div>
                    <div>Start: {new Date(activity.planned_start_date).toLocaleDateString()}</div>
                    <div>End: {new Date(activity.planned_end_date).toLocaleDateString()}</div>
                  </div>
                </div>
                <div className="flex items-center text-gray-600">
                  <DollarSign className="h-4 w-4 mr-2" />
                  <div>
                    <div>{formatCurrency(activity.budget_amount)}</div>
                    <div className="text-xs">{activity.planned_hours}h planned</div>
                  </div>
                </div>
              </div>

              <div className="pt-2 border-t">
                <div className="flex justify-between items-center">
                  <div>
                    <Badge variant="outline" className="text-xs">
                      {activity.wbs_node.code}
                    </Badge>
                    <p className="text-xs text-gray-600 mt-1">{activity.wbs_node.name}</p>
                  </div>
                  {activity.responsible_user && (
                    <div className="text-right">
                      <p className="text-sm font-medium">{activity.responsible_user.name}</p>
                      <p className="text-xs text-gray-600">{activity.responsible_user.email}</p>
                    </div>
                  )}
                </div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {filteredActivities.length === 0 && (
        <div className="text-center py-12">
          <p className="text-gray-500">No activities found matching your criteria.</p>
          <Button className="mt-4">
            <Plus className="h-4 w-4 mr-2" />
            Create First Activity
          </Button>
        </div>
      )}

      <Card>
        <CardHeader>
          <CardTitle>Activities Summary</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div className="text-center">
              <div className="text-2xl font-bold">{activities.length}</div>
              <p className="text-sm text-gray-600">Total Activities</p>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-green-600">
                {activities.filter(a => a.status === 'completed').length}
              </div>
              <p className="text-sm text-gray-600">Completed</p>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-blue-600">
                {activities.filter(a => a.status === 'in_progress').length}
              </div>
              <p className="text-sm text-gray-600">In Progress</p>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-red-600">
                {activities.filter(a => isOverdue(a)).length}
              </div>
              <p className="text-sm text-gray-600">Overdue</p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}