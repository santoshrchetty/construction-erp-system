'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Badge } from '@/components/ui/badge'
import { Textarea } from '@/components/ui/textarea'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { ChevronLeft, ChevronRight, Plus, Save, Send, Trash2, Copy, Calculator } from 'lucide-react'

interface TimesheetEntry {
  id?: string
  task_id: string
  task_name: string
  activity_name: string
  cost_object_code: string
  work_description: string
  hourly_rate: number
  hours: {
    monday: number
    tuesday: number
    wednesday: number
    thursday: number
    friday: number
    saturday: number
    sunday: number
  }
  total_hours: number
  total_cost: number
}

interface Task {
  id: string
  name: string
  activity_name: string
  cost_object_code: string
  hourly_rate: number
}

interface WeeklyTimesheetProps {
  employeeId: string
  projectId: string
}

export default function WeeklyTimesheet({ employeeId, projectId }: WeeklyTimesheetProps) {
  const [currentWeek, setCurrentWeek] = useState(new Date())
  const [entries, setEntries] = useState<TimesheetEntry[]>([])
  const [availableTasks, setAvailableTasks] = useState<Task[]>([])
  const [status, setStatus] = useState<'draft' | 'submitted' | 'approved' | 'rejected'>('draft')
  const [loading, setLoading] = useState(false)

  const weekDays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']
  const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']

  useEffect(() => {
    loadTimesheetData()
    loadAvailableTasks()
  }, [currentWeek, employeeId, projectId])

  const loadTimesheetData = async () => {
    try {
      const mockEntries: TimesheetEntry[] = [
        {
          id: '1',
          task_id: 'task-1',
          task_name: 'Foundation Excavation',
          activity_name: 'Site Preparation',
          cost_object_code: 'WBS-01.02',
          work_description: 'Excavation work for foundation',
          hourly_rate: 45.00,
          hours: { monday: 8, tuesday: 8, wednesday: 6, thursday: 8, friday: 8, saturday: 0, sunday: 0 },
          total_hours: 38,
          total_cost: 1710
        }
      ]
      setEntries(mockEntries)
    } catch (error) {
      console.error('Failed to load timesheet data:', error)
    }
  }

  const loadAvailableTasks = async () => {
    try {
      const mockTasks: Task[] = [
        { id: 'task-1', name: 'Foundation Excavation', activity_name: 'Site Preparation', cost_object_code: 'WBS-01.02', hourly_rate: 45.00 },
        { id: 'task-2', name: 'Concrete Pouring', activity_name: 'Foundation Work', cost_object_code: 'WBS-02.01', hourly_rate: 50.00 },
        { id: 'task-3', name: 'Steel Reinforcement', activity_name: 'Foundation Work', cost_object_code: 'WBS-02.02', hourly_rate: 55.00 }
      ]
      setAvailableTasks(mockTasks)
    } catch (error) {
      console.error('Failed to load tasks:', error)
    }
  }

  const getWeekDates = () => {
    const startOfWeek = new Date(currentWeek)
    const day = startOfWeek.getDay()
    const diff = startOfWeek.getDate() - day + (day === 0 ? -6 : 1)
    startOfWeek.setDate(diff)

    return Array.from({ length: 7 }, (_, i) => {
      const date = new Date(startOfWeek)
      date.setDate(startOfWeek.getDate() + i)
      return date
    })
  }

  const navigateWeek = (direction: 'prev' | 'next') => {
    const newWeek = new Date(currentWeek)
    newWeek.setDate(currentWeek.getDate() + (direction === 'next' ? 7 : -7))
    setCurrentWeek(newWeek)
  }

  const addNewEntry = () => {
    const newEntry: TimesheetEntry = {
      task_id: '',
      task_name: '',
      activity_name: '',
      cost_object_code: '',
      work_description: '',
      hourly_rate: 0,
      hours: { monday: 0, tuesday: 0, wednesday: 0, thursday: 0, friday: 0, saturday: 0, sunday: 0 },
      total_hours: 0,
      total_cost: 0
    }
    setEntries([...entries, newEntry])
  }

  const updateEntry = (index: number, field: string, value: any) => {
    const updatedEntries = [...entries]
    
    if (field === 'task_id') {
      const selectedTask = availableTasks.find(task => task.id === value)
      if (selectedTask) {
        updatedEntries[index] = {
          ...updatedEntries[index],
          task_id: value,
          task_name: selectedTask.name,
          activity_name: selectedTask.activity_name,
          cost_object_code: selectedTask.cost_object_code,
          hourly_rate: selectedTask.hourly_rate
        }
      }
    } else if (weekDays.includes(field)) {
      (updatedEntries[index].hours as any)[field] = parseFloat(value) || 0
    } else {
      updatedEntries[index] = { ...updatedEntries[index], [field]: value }
    }

    const totalHours = Object.values(updatedEntries[index].hours).reduce((sum, hours) => sum + hours, 0)
    updatedEntries[index].total_hours = totalHours
    updatedEntries[index].total_cost = totalHours * updatedEntries[index].hourly_rate

    setEntries(updatedEntries)
  }

  const deleteEntry = (index: number) => {
    setEntries(entries.filter((_, i) => i !== index))
  }

  const copyEntry = (index: number) => {
    const entryToCopy = { ...entries[index] }
    delete entryToCopy.id
    entryToCopy.hours = { monday: 0, tuesday: 0, wednesday: 0, thursday: 0, friday: 0, saturday: 0, sunday: 0 }
    entryToCopy.total_hours = 0
    entryToCopy.total_cost = 0
    setEntries([...entries, entryToCopy])
  }

  const getTotalHours = () => {
    return entries.reduce((sum, entry) => sum + entry.total_hours, 0)
  }

  const getTotalCost = () => {
    return entries.reduce((sum, entry) => sum + entry.total_cost, 0)
  }

  const getDayTotal = (day: string) => {
    return entries.reduce((sum, entry) => sum + (entry.hours[day as keyof typeof entry.hours] || 0), 0)
  }

  const saveTimesheet = async () => {
    setLoading(true)
    try {
      console.log('Saving timesheet:', entries)
    } catch (error) {
      console.error('Failed to save timesheet:', error)
    } finally {
      setLoading(false)
    }
  }

  const submitTimesheet = async () => {
    setLoading(true)
    try {
      console.log('Submitting timesheet:', entries)
      setStatus('submitted')
    } catch (error) {
      console.error('Failed to submit timesheet:', error)
    } finally {
      setLoading(false)
    }
  }

  const weekDates = getWeekDates()
  const isReadOnly = status === 'submitted' || status === 'approved'

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">Weekly Timesheet</h1>
          <p className="text-gray-600 mt-1">Week of {weekDates[0].toLocaleDateString()} - {weekDates[6].toLocaleDateString()}</p>
        </div>
        <Badge className={
          status === 'draft' ? 'bg-gray-100 text-gray-800' :
          status === 'submitted' ? 'bg-blue-100 text-blue-800' :
          status === 'approved' ? 'bg-green-100 text-green-800' :
          'bg-red-100 text-red-800'
        }>
          {status.toUpperCase()}
        </Badge>
      </div>

      <div className="flex justify-between items-center">
        <div className="flex items-center space-x-2">
          <Button variant="outline" size="sm" onClick={() => navigateWeek('prev')}>
            <ChevronLeft className="h-4 w-4" />
          </Button>
          <span className="font-medium">
            {weekDates[0].toLocaleDateString('en-US', { month: 'short', day: 'numeric' })} - {weekDates[6].toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
          </span>
          <Button variant="outline" size="sm" onClick={() => navigateWeek('next')}>
            <ChevronRight className="h-4 w-4" />
          </Button>
        </div>
        
        {!isReadOnly && (
          <div className="flex space-x-2">
            <Button variant="outline" onClick={addNewEntry}>
              <Plus className="h-4 w-4 mr-2" />
              Add Row
            </Button>
            <Button variant="outline" onClick={saveTimesheet} disabled={loading}>
              <Save className="h-4 w-4 mr-2" />
              Save Draft
            </Button>
            <Button onClick={submitTimesheet} disabled={loading}>
              <Send className="h-4 w-4 mr-2" />
              Submit
            </Button>
          </div>
        )}
      </div>

      <Card>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="w-48">Task</TableHead>
                  <TableHead className="w-32">Activity</TableHead>
                  <TableHead className="w-24">Cost Code</TableHead>
                  <TableHead className="w-48">Description</TableHead>
                  <TableHead className="w-20">Rate</TableHead>
                  {dayLabels.map((day, index) => (
                    <TableHead key={day} className="w-16 text-center">
                      <div>{day}</div>
                      <div className="text-xs text-gray-500">
                        {weekDates[index].getDate()}
                      </div>
                    </TableHead>
                  ))}
                  <TableHead className="w-20 text-center">Total</TableHead>
                  <TableHead className="w-24 text-center">Cost</TableHead>
                  {!isReadOnly && <TableHead className="w-20">Actions</TableHead>}
                </TableRow>
              </TableHeader>
              <TableBody>
                {entries.map((entry, index) => (
                  <TableRow key={entry.id || index}>
                    <TableCell>
                      {isReadOnly ? (
                        <span className="font-medium">{entry.task_name}</span>
                      ) : (
                        <Select
                          value={entry.task_id}
                          onValueChange={(value) => updateEntry(index, 'task_id', value)}
                        >
                          <SelectTrigger>
                            <SelectValue placeholder="Select task" />
                          </SelectTrigger>
                          <SelectContent>
                            {availableTasks.map(task => (
                              <SelectItem key={task.id} value={task.id}>
                                {task.name}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      )}
                    </TableCell>
                    <TableCell>
                      <span className="text-sm text-gray-600">{entry.activity_name}</span>
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline" className="text-xs">
                        {entry.cost_object_code}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      {isReadOnly ? (
                        <span className="text-sm">{entry.work_description}</span>
                      ) : (
                        <Textarea
                          value={entry.work_description}
                          onChange={(e) => updateEntry(index, 'work_description', e.target.value)}
                          placeholder="Work description"
                          className="min-h-[60px] text-sm"
                        />
                      )}
                    </TableCell>
                    <TableCell>
                      <span className="text-sm font-medium">
                        ${entry.hourly_rate.toFixed(2)}
                      </span>
                    </TableCell>
                    {weekDays.map(day => (
                      <TableCell key={day} className="text-center">
                        {isReadOnly ? (
                          <span className="font-medium">
                            {entry.hours[day as keyof typeof entry.hours] || 0}
                          </span>
                        ) : (
                          <Input
                            type="number"
                            step="0.25"
                            min="0"
                            max="24"
                            value={entry.hours[day as keyof typeof entry.hours] || ''}
                            onChange={(e) => updateEntry(index, day, e.target.value)}
                            className="w-16 text-center"
                          />
                        )}
                      </TableCell>
                    ))}
                    <TableCell className="text-center font-medium">
                      {entry.total_hours.toFixed(2)}
                    </TableCell>
                    <TableCell className="text-center font-medium">
                      ${entry.total_cost.toFixed(2)}
                    </TableCell>
                    {!isReadOnly && (
                      <TableCell>
                        <div className="flex space-x-1">
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => copyEntry(index)}
                          >
                            <Copy className="h-4 w-4" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => deleteEntry(index)}
                            className="text-red-600 hover:text-red-700"
                          >
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        </div>
                      </TableCell>
                    )}
                  </TableRow>
                ))}
                
                <TableRow className="bg-gray-50 font-medium">
                  <TableCell colSpan={5} className="text-right">
                    <strong>Daily Totals:</strong>
                  </TableCell>
                  {weekDays.map(day => (
                    <TableCell key={day} className="text-center font-bold">
                      {getDayTotal(day).toFixed(1)}
                    </TableCell>
                  ))}
                  <TableCell className="text-center font-bold text-blue-600">
                    {getTotalHours().toFixed(2)}
                  </TableCell>
                  <TableCell className="text-center font-bold text-green-600">
                    ${getTotalCost().toFixed(2)}
                  </TableCell>
                  {!isReadOnly && <TableCell />}
                </TableRow>
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center">
              <Calculator className="h-5 w-5 mr-2" />
              Week Summary
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              <div className="flex justify-between">
                <span>Total Hours:</span>
                <span className="font-bold">{getTotalHours().toFixed(2)}</span>
              </div>
              <div className="flex justify-between">
                <span>Regular Hours:</span>
                <span className="font-medium">{Math.min(getTotalHours(), 40).toFixed(2)}</span>
              </div>
              <div className="flex justify-between">
                <span>Overtime Hours:</span>
                <span className="font-medium">{Math.max(getTotalHours() - 40, 0).toFixed(2)}</span>
              </div>
              <div className="flex justify-between border-t pt-2">
                <span>Total Cost:</span>
                <span className="font-bold text-green-600">${getTotalCost().toFixed(2)}</span>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Daily Breakdown</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              {dayLabels.map((day, index) => (
                <div key={day} className="flex justify-between text-sm">
                  <span>{day} ({weekDates[index].getDate()}):</span>
                  <span className="font-medium">{getDayTotal(weekDays[index]).toFixed(1)}h</span>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Status & Actions</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div>
                <span className="text-sm text-gray-600">Current Status:</span>
                <Badge className={`ml-2 ${
                  status === 'draft' ? 'bg-gray-100 text-gray-800' :
                  status === 'submitted' ? 'bg-blue-100 text-blue-800' :
                  status === 'approved' ? 'bg-green-100 text-green-800' :
                  'bg-red-100 text-red-800'
                }`}>
                  {status.toUpperCase()}
                </Badge>
              </div>
              
              {status === 'draft' && (
                <div className="space-y-2">
                  <Button className="w-full" onClick={submitTimesheet} disabled={loading}>
                    <Send className="h-4 w-4 mr-2" />
                    Submit for Approval
                  </Button>
                  <Button variant="outline" className="w-full" onClick={saveTimesheet} disabled={loading}>
                    <Save className="h-4 w-4 mr-2" />
                    Save Draft
                  </Button>
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}