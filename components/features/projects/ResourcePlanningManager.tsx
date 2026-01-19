'use client'

import { useState, useEffect } from 'react'
import { Package, Truck, Users, ClipboardCheck, HardHat, ChevronLeft, Menu, X } from 'lucide-react'
import ActivityMaterialsForm from '@/components/activities/ActivityMaterialsForm'
import ActivityEquipmentForm from '@/components/activities/ActivityEquipmentForm'
import ActivityManpowerForm from '@/components/activities/ActivityManpowerForm'
import { ActivityServicesForm } from '@/components/activities/ActivityServicesForm'
import { ActivitySubcontractorsForm } from '@/components/activities/ActivitySubcontractorsForm'

interface Activity {
  id: string
  code: string
  name: string
  planned_start_date: string
  planned_end_date: string
  material_count: number
  equipment_count: number
  manpower_count: number
  services_count: number
  subcontractor_count: number
  material_cost?: number
  equipment_cost?: number
  manpower_cost?: number
  services_cost?: number
  subcontractor_cost?: number
  total_planned_cost?: number
  material_actual?: number
  equipment_actual?: number
  manpower_actual?: number
  services_actual?: number
  subcontractor_actual?: number
  total_actual_cost?: number
}

interface ResourcePlanningManagerProps {
  projectId: string
}

export default function ResourcePlanningManager({ projectId }: ResourcePlanningManagerProps) {
  const [activities, setActivities] = useState<Activity[]>([])
  const [selectedActivity, setSelectedActivity] = useState<Activity | null>(null)
  const [activeTab, setActiveTab] = useState<'materials' | 'equipment' | 'manpower' | 'services' | 'subcontractors'>('materials')
  const [sidebarOpen, setSidebarOpen] = useState(true)
  const [mobileDrawerOpen, setMobileDrawerOpen] = useState(false)
  const [filters, setFilters] = useState({
    dateFrom: new Date().toISOString().split('T')[0],
    dateTo: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]
  })

  useEffect(() => {
    if (projectId) {
      fetchActivities()
    }
  }, [filters, projectId])

  const fetchActivities = async () => {
    const params = new URLSearchParams({ ...filters, projectId, limit: '50' })
    const res = await fetch(`/api/planning?${params}`)
    const data = await res.json()
    setActivities(data.activities || [])
  }

  const getBudgetStatus = (planned: number, actual: number) => {
    if (actual === 0) return { emoji: '⏳', text: 'Not Started', color: 'text-gray-600' }
    if (actual > planned) return { emoji: '🔴', text: 'Over Budget', color: 'text-red-600' }
    return { emoji: '🟢', text: 'On Track', color: 'text-green-600' }
  }

  const handleActivitySelect = (activity: Activity) => {
    setSelectedActivity(activity)
    setMobileDrawerOpen(false)
  }

  const formatCurrency = (amount?: number) => {
    if (!amount) return '$0'
    return `$${amount.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
  }

  const getVarianceColor = (planned: number, actual: number) => {
    if (actual === 0) return 'text-gray-500'
    const variance = ((actual - planned) / planned) * 100
    if (variance > 10) return 'text-red-600'
    if (variance > 0) return 'text-orange-500'
    return 'text-green-600'
  }

  return (
    <div className="h-full flex flex-col">
      {/* Header with filters */}
      <div className="bg-white border-b px-4 py-3 flex items-center gap-4">
        <button
          onClick={() => setMobileDrawerOpen(true)}
          className="lg:hidden p-2 hover:bg-gray-100 rounded"
        >
          <Menu size={20} />
        </button>
        <button
          onClick={() => setSidebarOpen(!sidebarOpen)}
          className="hidden lg:block p-2 hover:bg-gray-100 rounded"
        >
          <Menu size={20} />
        </button>
        <input
          type="date"
          value={filters.dateFrom}
          onChange={(e) => setFilters({ ...filters, dateFrom: e.target.value })}
          className="px-3 py-1.5 border rounded text-sm"
        />
        <input
          type="date"
          value={filters.dateTo}
          onChange={(e) => setFilters({ ...filters, dateTo: e.target.value })}
          className="px-3 py-1.5 border rounded text-sm"
        />
      </div>

      <div className="flex-1 flex overflow-hidden relative">
        {/* Mobile Drawer Overlay */}
        {mobileDrawerOpen && (
          <div
            className="lg:hidden fixed inset-0 bg-black bg-opacity-50 z-40"
            onClick={() => setMobileDrawerOpen(false)}
          />
        )}

        {/* Activities Sidebar */}
        <div
          className={`
            fixed lg:relative inset-y-0 left-0 z-50
            bg-white border-r overflow-y-auto
            transition-transform duration-300 ease-in-out
            ${mobileDrawerOpen ? 'translate-x-0' : '-translate-x-full'}
            lg:translate-x-0
            ${sidebarOpen ? 'lg:w-[30%]' : 'lg:w-0 lg:border-0'}
            w-[85%] sm:w-[70%]
          `}
        >
          {/* Mobile close button */}
          <div className="lg:hidden sticky top-0 bg-white border-b px-4 py-3 flex items-center justify-between">
            <span className="font-semibold text-sm">Activities</span>
            <button
              onClick={() => setMobileDrawerOpen(false)}
              className="p-2 hover:bg-gray-100 rounded"
            >
              <X size={20} />
            </button>
          </div>

          {activities.map((activity) => {
            const status = getBudgetStatus(
              activity.total_planned_cost || 0,
              activity.total_actual_cost || 0
            )
            return (
              <div
                key={activity.id}
                onClick={() => handleActivitySelect(activity)}
                className={`p-4 cursor-pointer hover:bg-gray-50 border-b transition-colors ${
                  selectedActivity?.id === activity.id ? 'bg-blue-50 border-l-4 border-l-blue-500' : ''
                }`}
              >
                <div className="font-medium text-sm mb-1">{activity.name}</div>
                <div className="text-xs text-gray-500 mb-2">{activity.code}</div>
                {activity.total_planned_cost && activity.total_planned_cost > 0 && (
                  <>
                    <div className="flex items-center justify-between text-xs mb-1">
                      <span className="text-gray-600">Budget:</span>
                      <span className="font-semibold">
                        {formatCurrency(activity.total_actual_cost)} / {formatCurrency(activity.total_planned_cost)}
                      </span>
                    </div>
                    <div className="flex items-center gap-2 text-xs">
                      <span className="text-lg">{status.emoji}</span>
                      <span className={status.color}>{status.text}</span>
                    </div>
                  </>
                )}
              </div>
            )
          })}
        </div>

        {/* Main Content Area */}
        <div className="flex-1 flex flex-col overflow-hidden">
          {selectedActivity ? (
            <>
              {/* Mobile back button */}
              <div className="lg:hidden sticky top-0 bg-white border-b px-4 py-3 flex items-center gap-3 z-10">
                <button
                  onClick={() => setMobileDrawerOpen(true)}
                  className="p-2 hover:bg-gray-100 rounded"
                >
                  <ChevronLeft size={20} />
                </button>
                <div className="flex-1 min-w-0">
                  <div className="font-semibold text-sm truncate">{selectedActivity.name}</div>
                  <div className="text-xs text-gray-500">{selectedActivity.code}</div>
                </div>
              </div>

              <div className="p-4 border-b bg-gray-50 overflow-y-auto">
                <h2 className="font-semibold hidden lg:block">{selectedActivity.name}</h2>
                <div className="text-sm text-gray-600 hidden lg:block">{selectedActivity.planned_start_date}</div>
                {selectedActivity.total_planned_cost && selectedActivity.total_planned_cost > 0 && (
                  <div className="mt-2 p-3 bg-white rounded-lg border">
                    {/* Desktop Table Header */}
                    <div className="hidden md:grid grid-cols-6 gap-3 text-xs mb-3">
                      <div className="font-semibold text-gray-700">Resource</div>
                      <div className="font-semibold text-blue-700 text-right">Planned</div>
                      <div className="font-semibold text-purple-700 text-right">Actual</div>
                      <div className="font-semibold text-gray-700 text-right">Variance</div>
                      <div className="font-semibold text-gray-700 text-right">%</div>
                      <div className="font-semibold text-gray-700">Status</div>
                    </div>
                    
                    {/* Materials */}
                    <div className="border-t py-2">
                      <div className="hidden md:grid grid-cols-6 gap-3 text-xs">
                        <div className="text-gray-600">Materials</div>
                        <div className="text-blue-700 text-right">{formatCurrency(selectedActivity.material_cost)}</div>
                        <div className="text-purple-700 text-right font-semibold">{formatCurrency(selectedActivity.material_actual)}</div>
                        <div className={`text-right ${getVarianceColor(selectedActivity.material_cost || 0, selectedActivity.material_actual || 0)}`}>
                          {formatCurrency((selectedActivity.material_actual || 0) - (selectedActivity.material_cost || 0))}
                        </div>
                        <div className={`text-right ${getVarianceColor(selectedActivity.material_cost || 0, selectedActivity.material_actual || 0)}`}>
                          {selectedActivity.material_cost ? ((((selectedActivity.material_actual || 0) - selectedActivity.material_cost) / selectedActivity.material_cost) * 100).toFixed(1) : '0'}%
                        </div>
                        <div>
                          {(selectedActivity.material_actual || 0) > (selectedActivity.material_cost || 0) ? '⚠️ Over' : (selectedActivity.material_actual || 0) > 0 ? '✓ On Track' : '⏳ Pending'}
                        </div>
                      </div>
                      <div className="md:hidden space-y-1 text-xs">
                        <div className="font-semibold text-gray-700">Materials</div>
                        <div className="flex justify-between"><span className="text-gray-600">Planned:</span><span className="text-blue-700">{formatCurrency(selectedActivity.material_cost)}</span></div>
                        <div className="flex justify-between"><span className="text-gray-600">Actual:</span><span className="text-purple-700 font-semibold">{formatCurrency(selectedActivity.material_actual)}</span></div>
                        <div className="flex justify-between items-center">
                          <span className="text-gray-600">Status:</span>
                          <span>{(selectedActivity.material_actual || 0) > (selectedActivity.material_cost || 0) ? '⚠️ Over' : (selectedActivity.material_actual || 0) > 0 ? '✓ On Track' : '⏳ Pending'}</span>
                        </div>
                      </div>
                    </div>
                    
                    {/* Equipment */}
                    <div className="border-t py-2">
                      <div className="hidden md:grid grid-cols-6 gap-3 text-xs">
                        <div className="text-gray-600">Equipment</div>
                        <div className="text-blue-700 text-right">{formatCurrency(selectedActivity.equipment_cost)}</div>
                        <div className="text-purple-700 text-right font-semibold">{formatCurrency(selectedActivity.equipment_actual)}</div>
                        <div className={`text-right ${getVarianceColor(selectedActivity.equipment_cost || 0, selectedActivity.equipment_actual || 0)}`}>
                          {formatCurrency((selectedActivity.equipment_actual || 0) - (selectedActivity.equipment_cost || 0))}
                        </div>
                        <div className={`text-right ${getVarianceColor(selectedActivity.equipment_cost || 0, selectedActivity.equipment_actual || 0)}`}>
                          {selectedActivity.equipment_cost ? ((((selectedActivity.equipment_actual || 0) - selectedActivity.equipment_cost) / selectedActivity.equipment_cost) * 100).toFixed(1) : '0'}%
                        </div>
                        <div>
                          {(selectedActivity.equipment_actual || 0) > (selectedActivity.equipment_cost || 0) ? '⚠️ Over' : (selectedActivity.equipment_actual || 0) > 0 ? '✓ On Track' : '⏳ Pending'}
                        </div>
                      </div>
                      <div className="md:hidden space-y-1 text-xs">
                        <div className="font-semibold text-gray-700">Equipment</div>
                        <div className="flex justify-between"><span className="text-gray-600">Planned:</span><span className="text-blue-700">{formatCurrency(selectedActivity.equipment_cost)}</span></div>
                        <div className="flex justify-between"><span className="text-gray-600">Actual:</span><span className="text-purple-700 font-semibold">{formatCurrency(selectedActivity.equipment_actual)}</span></div>
                        <div className="flex justify-between items-center">
                          <span className="text-gray-600">Status:</span>
                          <span>{(selectedActivity.equipment_actual || 0) > (selectedActivity.equipment_cost || 0) ? '⚠️ Over' : (selectedActivity.equipment_actual || 0) > 0 ? '✓ On Track' : '⏳ Pending'}</span>
                        </div>
                      </div>
                    </div>
                    
                    {/* Manpower */}
                    <div className="border-t py-2">
                      <div className="hidden md:grid grid-cols-6 gap-3 text-xs">
                        <div className="text-gray-600">Manpower</div>
                        <div className="text-blue-700 text-right">{formatCurrency(selectedActivity.manpower_cost)}</div>
                        <div className="text-purple-700 text-right font-semibold">{formatCurrency(selectedActivity.manpower_actual)}</div>
                        <div className={`text-right ${getVarianceColor(selectedActivity.manpower_cost || 0, selectedActivity.manpower_actual || 0)}`}>
                          {formatCurrency((selectedActivity.manpower_actual || 0) - (selectedActivity.manpower_cost || 0))}
                        </div>
                        <div className={`text-right ${getVarianceColor(selectedActivity.manpower_cost || 0, selectedActivity.manpower_actual || 0)}`}>
                          {selectedActivity.manpower_cost ? ((((selectedActivity.manpower_actual || 0) - selectedActivity.manpower_cost) / selectedActivity.manpower_cost) * 100).toFixed(1) : '0'}%
                        </div>
                        <div>
                          {(selectedActivity.manpower_actual || 0) > (selectedActivity.manpower_cost || 0) ? '⚠️ Over' : (selectedActivity.manpower_actual || 0) > 0 ? '✓ On Track' : '⏳ Pending'}
                        </div>
                      </div>
                      <div className="md:hidden space-y-1 text-xs">
                        <div className="font-semibold text-gray-700">Manpower</div>
                        <div className="flex justify-between"><span className="text-gray-600">Planned:</span><span className="text-blue-700">{formatCurrency(selectedActivity.manpower_cost)}</span></div>
                        <div className="flex justify-between"><span className="text-gray-600">Actual:</span><span className="text-purple-700 font-semibold">{formatCurrency(selectedActivity.manpower_actual)}</span></div>
                        <div className="flex justify-between items-center">
                          <span className="text-gray-600">Status:</span>
                          <span>{(selectedActivity.manpower_actual || 0) > (selectedActivity.manpower_cost || 0) ? '⚠️ Over' : (selectedActivity.manpower_actual || 0) > 0 ? '✓ On Track' : '⏳ Pending'}</span>
                        </div>
                      </div>
                    </div>
                    
                    {/* Services */}
                    <div className="border-t py-2">
                      <div className="hidden md:grid grid-cols-6 gap-3 text-xs">
                        <div className="text-gray-600">Services</div>
                        <div className="text-blue-700 text-right">{formatCurrency(selectedActivity.services_cost)}</div>
                        <div className="text-purple-700 text-right font-semibold">{formatCurrency(selectedActivity.services_actual)}</div>
                        <div className={`text-right ${getVarianceColor(selectedActivity.services_cost || 0, selectedActivity.services_actual || 0)}`}>
                          {formatCurrency((selectedActivity.services_actual || 0) - (selectedActivity.services_cost || 0))}
                        </div>
                        <div className={`text-right ${getVarianceColor(selectedActivity.services_cost || 0, selectedActivity.services_actual || 0)}`}>
                          {selectedActivity.services_cost ? ((((selectedActivity.services_actual || 0) - selectedActivity.services_cost) / selectedActivity.services_cost) * 100).toFixed(1) : '0'}%
                        </div>
                        <div>
                          {(selectedActivity.services_actual || 0) > (selectedActivity.services_cost || 0) ? '⚠️ Over' : (selectedActivity.services_actual || 0) > 0 ? '✓ On Track' : '⏳ Pending'}
                        </div>
                      </div>
                      <div className="md:hidden space-y-1 text-xs">
                        <div className="font-semibold text-gray-700">Services</div>
                        <div className="flex justify-between"><span className="text-gray-600">Planned:</span><span className="text-blue-700">{formatCurrency(selectedActivity.services_cost)}</span></div>
                        <div className="flex justify-between"><span className="text-gray-600">Actual:</span><span className="text-purple-700 font-semibold">{formatCurrency(selectedActivity.services_actual)}</span></div>
                        <div className="flex justify-between items-center">
                          <span className="text-gray-600">Status:</span>
                          <span>{(selectedActivity.services_actual || 0) > (selectedActivity.services_cost || 0) ? '⚠️ Over' : (selectedActivity.services_actual || 0) > 0 ? '✓ On Track' : '⏳ Pending'}</span>
                        </div>
                      </div>
                    </div>
                    
                    {/* Subcontractors */}
                    <div className="border-t py-2">
                      <div className="hidden md:grid grid-cols-6 gap-3 text-xs">
                        <div className="text-gray-600">Subcontractors</div>
                        <div className="text-blue-700 text-right">{formatCurrency(selectedActivity.subcontractor_cost)}</div>
                        <div className="text-purple-700 text-right font-semibold">{formatCurrency(selectedActivity.subcontractor_actual)}</div>
                        <div className={`text-right ${getVarianceColor(selectedActivity.subcontractor_cost || 0, selectedActivity.subcontractor_actual || 0)}`}>
                          {formatCurrency((selectedActivity.subcontractor_actual || 0) - (selectedActivity.subcontractor_cost || 0))}
                        </div>
                        <div className={`text-right ${getVarianceColor(selectedActivity.subcontractor_cost || 0, selectedActivity.subcontractor_actual || 0)}`}>
                          {selectedActivity.subcontractor_cost ? ((((selectedActivity.subcontractor_actual || 0) - selectedActivity.subcontractor_cost) / selectedActivity.subcontractor_cost) * 100).toFixed(1) : '0'}%
                        </div>
                        <div>
                          {(selectedActivity.subcontractor_actual || 0) > (selectedActivity.subcontractor_cost || 0) ? '⚠️ Over' : (selectedActivity.subcontractor_actual || 0) > 0 ? '✓ On Track' : '⏳ Pending'}
                        </div>
                      </div>
                      <div className="md:hidden space-y-1 text-xs">
                        <div className="font-semibold text-gray-700">Subcontractors</div>
                        <div className="flex justify-between"><span className="text-gray-600">Planned:</span><span className="text-blue-700">{formatCurrency(selectedActivity.subcontractor_cost)}</span></div>
                        <div className="flex justify-between"><span className="text-gray-600">Actual:</span><span className="text-purple-700 font-semibold">{formatCurrency(selectedActivity.subcontractor_actual)}</span></div>
                        <div className="flex justify-between items-center">
                          <span className="text-gray-600">Status:</span>
                          <span>{(selectedActivity.subcontractor_actual || 0) > (selectedActivity.subcontractor_cost || 0) ? '⚠️ Over' : (selectedActivity.subcontractor_actual || 0) > 0 ? '✓ On Track' : '⏳ Pending'}</span>
                        </div>
                      </div>
                    </div>
                    
                    {/* Total */}
                    <div className="border-t-2 border-gray-300 py-2 font-bold">
                      <div className="hidden md:grid grid-cols-6 gap-3 text-xs">
                        <div className="text-gray-900">TOTAL</div>
                        <div className="text-blue-900 text-right">{formatCurrency(selectedActivity.total_planned_cost)}</div>
                        <div className="text-purple-900 text-right">{formatCurrency(selectedActivity.total_actual_cost)}</div>
                        <div className={`text-right ${getVarianceColor(selectedActivity.total_planned_cost || 0, selectedActivity.total_actual_cost || 0)}`}>
                          {formatCurrency((selectedActivity.total_actual_cost || 0) - (selectedActivity.total_planned_cost || 0))}
                        </div>
                        <div className={`text-right ${getVarianceColor(selectedActivity.total_planned_cost || 0, selectedActivity.total_actual_cost || 0)}`}>
                          {selectedActivity.total_planned_cost ? ((((selectedActivity.total_actual_cost || 0) - selectedActivity.total_planned_cost) / selectedActivity.total_planned_cost) * 100).toFixed(1) : '0'}%
                        </div>
                        <div>
                          {(selectedActivity.total_actual_cost || 0) > (selectedActivity.total_planned_cost || 0) ? '🔴 Over Budget' : (selectedActivity.total_actual_cost || 0) > 0 ? '🟢 Under Budget' : '⏳ Not Started'}
                        </div>
                      </div>
                      <div className="md:hidden space-y-1 text-xs">
                        <div className="text-gray-900 text-sm">TOTAL</div>
                        <div className="flex justify-between"><span className="text-gray-600">Planned:</span><span className="text-blue-900">{formatCurrency(selectedActivity.total_planned_cost)}</span></div>
                        <div className="flex justify-between"><span className="text-gray-600">Actual:</span><span className="text-purple-900">{formatCurrency(selectedActivity.total_actual_cost)}</span></div>
                        <div className="flex justify-between items-center">
                          <span className="text-gray-600">Status:</span>
                          <span>{(selectedActivity.total_actual_cost || 0) > (selectedActivity.total_planned_cost || 0) ? '🔴 Over Budget' : (selectedActivity.total_actual_cost || 0) > 0 ? '🟢 Under Budget' : '⏳ Not Started'}</span>
                        </div>
                      </div>
                    </div>
                  </div>
                )}
              </div>

              {/* Tabs - Horizontal scroll on mobile */}
              <div className="flex border-b overflow-x-auto">
                <button
                  onClick={() => setActiveTab('materials')}
                  className={`flex items-center gap-2 px-4 py-3 whitespace-nowrap min-h-[44px] ${
                    activeTab === 'materials' ? 'border-b-2 border-blue-500 text-blue-600 font-semibold' : 'text-gray-600'
                  }`}
                >
                  <Package size={16} />
                  <span className="hidden sm:inline">Materials</span>
                </button>
                <button
                  onClick={() => setActiveTab('equipment')}
                  className={`flex items-center gap-2 px-4 py-3 whitespace-nowrap min-h-[44px] ${
                    activeTab === 'equipment' ? 'border-b-2 border-blue-500 text-blue-600 font-semibold' : 'text-gray-600'
                  }`}
                >
                  <Truck size={16} />
                  <span className="hidden sm:inline">Equipment</span>
                </button>
                <button
                  onClick={() => setActiveTab('manpower')}
                  className={`flex items-center gap-2 px-4 py-3 whitespace-nowrap min-h-[44px] ${
                    activeTab === 'manpower' ? 'border-b-2 border-blue-500 text-blue-600 font-semibold' : 'text-gray-600'
                  }`}
                >
                  <Users size={16} />
                  <span className="hidden sm:inline">Manpower</span>
                </button>
                <button
                  onClick={() => setActiveTab('services')}
                  className={`flex items-center gap-2 px-4 py-3 whitespace-nowrap min-h-[44px] ${
                    activeTab === 'services' ? 'border-b-2 border-blue-500 text-blue-600 font-semibold' : 'text-gray-600'
                  }`}
                >
                  <ClipboardCheck size={16} />
                  <span className="hidden sm:inline">Services</span>
                </button>
                <button
                  onClick={() => setActiveTab('subcontractors')}
                  className={`flex items-center gap-2 px-4 py-3 whitespace-nowrap min-h-[44px] ${
                    activeTab === 'subcontractors' ? 'border-b-2 border-blue-500 text-blue-600 font-semibold' : 'text-gray-600'
                  }`}
                >
                  <HardHat size={16} />
                  <span className="hidden sm:inline">Subcontractors</span>
                </button>
              </div>

              <div className="flex-1 overflow-y-auto p-4">
                <div className="max-w-full overflow-x-auto">
                  {activeTab === 'materials' && <ActivityMaterialsForm activityId={selectedActivity.id} />}
                  {activeTab === 'equipment' && <ActivityEquipmentForm activityId={selectedActivity.id} />}
                  {activeTab === 'manpower' && <ActivityManpowerForm activityId={selectedActivity.id} />}
                  {activeTab === 'services' && <ActivityServicesForm activityId={selectedActivity.id} />}
                  {activeTab === 'subcontractors' && <ActivitySubcontractorsForm activityId={selectedActivity.id} />}
                </div>
              </div>
            </>
          ) : (
            <div className="flex-1 flex items-center justify-center text-gray-500">
              Select an activity to assign resources
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
