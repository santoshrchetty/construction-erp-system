'use client'

import { useState, useEffect, lazy, Suspense } from 'react'
import { useAuth } from '@/lib/contexts/AuthContext'
import { createClient } from '@/lib/supabase/client'
import { DataPreloaderProvider, usePreloadedData } from '@/contexts/DataPreloaderContext'
import * as Icons from 'lucide-react'

// Loading component for lazy-loaded modules
function ModuleLoader() {
  return (
    <div className="flex items-center justify-center p-8">
      <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      <span className="ml-3 text-gray-600">Loading module...</span>
    </div>
  )
}
// Lazy-loaded components with error handling
const ProjectDashboard = lazy(() => 
  import('../projects/ProjectDashboard')
    .then(module => ({ default: module.ProjectsOverviewDashboard }))
    .catch(error => {
      console.error('Failed to load ProjectDashboard:', error)
      return { default: () => <div className="p-6 text-red-600">Failed to load Projects Dashboard</div> }
    })
)
// Enhanced lazy loading with data preloading
const ProjectForm = lazy(() => 
  import('../ProjectForm').then(module => {
    // Preload dropdown data when component is imported
    return { default: module.default }
  })
)
const ProjectMaster = lazy(() => import('../ProjectMaster'))
const WBSBuilder = lazy(() => import('../WBSBuilder'))
const ActivitiesList = lazy(() => import('../activities/ActivitiesListSimple'))
const TaskManager = lazy(() => import('../TaskManager'))
const SchedulingManager = lazy(() => import('../SchedulingManager'))
const CostManager = lazy(() => import('../CostManager'))
const PurchaseOrderManager = lazy(() => import('../PurchaseOrderManager'))
const MaterialMaster = lazy(() => import('../MaterialMaster'))
const VendorManager = lazy(() => import('../VendorManager'))
const InventoryManager = lazy(() => import('../InventoryManager'))
const SAPConfig = lazy(() => import('../SAPConfig'))
const ERPConfigurationModuleComplete = lazy(() => import('../ERPConfigurationModuleComplete'))
const UserManagement = lazy(() => import('./UserManagement'))
const RoleManagement = lazy(() => import('./RoleManagement'))
const UserRoleAssignment = lazy(() => import('./UserRoleAssignment'))
const AuthorizationObjects = lazy(() => import('./AuthorizationObjects'))
const CostCenterAccounting = lazy(() => import('./CostCenterAccounting'))
const ChartOfAccounts = lazy(() => import('./ChartOfAccounts'))
const CreateMaterialMaster = lazy(() => import('./MaterialMasterComponents').then(module => ({ default: module.CreateMaterialMaster })))
const MaintainMaterialMaster = lazy(() => import('./MaterialMasterComponents').then(module => ({ default: module.MaintainMaterialMaster })))
const GoodsReceipt = lazy(() => import('./InventoryComponents').then(module => ({ default: module.GoodsReceipt })))
const GoodsIssue = lazy(() => import('./InventoryComponents').then(module => ({ default: module.GoodsIssue })))
const GoodsTransfer = lazy(() => import('./InventoryComponents').then(module => ({ default: module.GoodsTransfer })))
const PhysicalInventory = lazy(() => import('./InventoryComponents').then(module => ({ default: module.PhysicalInventory })))
const InventoryAdjustments = lazy(() => import('./InventoryComponents').then(module => ({ default: module.InventoryAdjustments })))
const GLPostingComponent = lazy(() => import('./GLPosting'))
const TrialBalanceComponent = lazy(() => import('./FinanceComponents').then(module => ({ default: module.TrialBalanceComponent })))
const ProfitLossComponent = lazy(() => import('./FinanceComponents').then(module => ({ default: module.ProfitLossComponent })))
const MaterialStockOverview = lazy(() => import('./MaterialStockOverview'))
const ExtendMaterialToPlant = lazy(() => import('./MaterialPlantComponents').then(module => ({ default: module.ExtendMaterialToPlant })))
const MaterialPlantParameters = lazy(() => import('./MaterialPlantComponents').then(module => ({ default: module.MaterialPlantParameters })))
const MaterialReservations = lazy(() => import('./MaterialReservationsComponent').then(module => ({ default: module.MaterialReservations })))
const UnifiedMaterialRequest = lazy(() => import('./UnifiedMaterialRequestComponent').then(module => ({ default: module.UnifiedMaterialRequest })))
const ApprovalConfiguration = lazy(() => import('./approval-configuration'))
const WBSManagement = lazy(() => import('./WBSManagement').then(module => ({ default: module.WBSManagement })))

interface ConstructionTile {
  id: string
  title: string
  subtitle: string
  icon: string
  module_code: string
  construction_action: string
  route: string
  tile_category: string
  has_authorization: boolean
  auth_object?: string
}

export default function EnhancedConstructionTiles() {
  const { user, signOut, loading: authLoading } = useAuth()
  const [tiles, setTiles] = useState<ConstructionTile[]>([])
  const [loading, setLoading] = useState(true)
  const [loggingOut, setLoggingOut] = useState(false)
  const [selectedCategory, setSelectedCategory] = useState<string>('all')
  const [activeComponent, setActiveComponent] = useState<string | null>(null)
  const [selectedProjectId, setSelectedProjectId] = useState<string>('')
  const [selectedProjectName, setSelectedProjectName] = useState<string>('')

  const supabase = createClient()

  useEffect(() => {
    if (!authLoading && user) {
      fetchTiles()
    }
  }, [user, authLoading])

  const fetchTiles = async () => {
    try {
      const response = await fetch('/api/tiles-list')
      const data = await response.json()
      
      if (response.ok && data.success) {
        setTiles(data.tiles || [])
      } else if (response.status === 401) {
        window.location.href = '/login'
      }
    } catch (error) {
      console.error('Error fetching tiles:', error)
    } finally {
      setLoading(false)
    }
  }

  const getIcon = (iconName: string) => {
    const iconMap: { [key: string]: any } = {
      'building': Icons.Building,
      'plus-circle': Icons.PlusCircle,
      'edit': Icons.Edit,
      'git-branch': Icons.GitBranch,
      'settings': Icons.Settings,
      'shopping-cart': Icons.ShoppingCart,
      'check-circle': Icons.CheckCircle,
      'check-square': Icons.CheckSquare,
      'package': Icons.Package,
      'box': Icons.Box,
      'users': Icons.Users,
      'calendar': Icons.Calendar,
      'play': Icons.Play,
      'user-check': Icons.UserCheck,
      'trending-up': Icons.TrendingUp,
      'file-text': Icons.FileText,
      'shield': Icons.Shield,
      'dollar-sign': Icons.DollarSign,
      'pie-chart': Icons.PieChart,
      'bar-chart-3': Icons.BarChart3,
      'clock': Icons.Clock,
      'truck': Icons.Truck,
      'warehouse': Icons.Warehouse,
      'building-2': Icons.Building2,
      'factory': Icons.Building2,
      'refresh-cw': Icons.RefreshCw
    }
    return iconMap[iconName] || Icons.Square
  }

  const categories = [
    { key: 'all', label: 'All Modules', icon: '🏗️' },
    { key: 'Administration', label: 'Administration', icon: '⚙️' },
    { key: 'Project Management', label: 'Project Management', icon: '📋' },
    { key: 'Procurement', label: 'Procurement', icon: '🛒' },
    { key: 'Materials', label: 'Materials', icon: '📦' },
    { key: 'Warehouse', label: 'Warehouse', icon: '🏪' },
    { key: 'Finance', label: 'Finance', icon: '💰' },
    { key: 'Quality', label: 'Quality', icon: '✅' },
    { key: 'Safety', label: 'Safety', icon: '🛡️' },
    { key: 'Human Resources', label: 'Human Resources', icon: '👥' },
    { key: 'Configuration', label: 'Configuration', icon: '🔧' }
  ]

  const authorizedTiles = tiles.filter(tile => tile.has_authorization)
  const filteredTiles = selectedCategory === 'all' 
    ? authorizedTiles 
    : authorizedTiles.filter(tile => tile.tile_category === selectedCategory)

  const handleTileClick = (tile: ConstructionTile) => {
    if (tile.has_authorization) {
      setActiveComponent(tile.title)
    }
  }

  const handleProjectSelect = (projectId: string, projectName: string) => {
    setSelectedProjectId(projectId)
    setSelectedProjectName(projectName)
  }

  const renderActiveComponent = () => {
    switch (activeComponent) {
      // Project Management
      case 'Create Project':
        return (
          <DataPreloaderProvider>
            <Suspense fallback={<ModuleLoader />}>
              <ProjectForm 
                onClose={() => setActiveComponent(null)} 
                onSuccess={() => {
                  setActiveComponent('Projects Dashboard')
                }} 
              />
            </Suspense>
          </DataPreloaderProvider>
        )
      case 'Project Master':
        return <ProjectMaster />
      case 'Projects Dashboard':
        return (
          <div>
            <div className="bg-white shadow-sm border-b px-4 py-3 mb-4">
              <div className="flex justify-between items-center">
                <div>
                  <p className="text-sm text-gray-600">Real-time project financial data and status overview</p>
                </div>
                <button
                  onClick={() => window.location.reload()}
                  className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center"
                >
                  <Icons.RefreshCw className="w-4 h-4 mr-2" />
                  Refresh Data
                </button>
              </div>
            </div>
            <ProjectDashboard onProjectSelect={handleProjectSelect} onNewProject={() => {}} />
          </div>
        )
      case 'WBS Management':
        return <WBSManagement />
      case 'Activities':
        return selectedProjectId ? (
          <div className="p-6">
            <ActivitiesList projectId={selectedProjectId} />
          </div>
        ) : (
          <div className="p-6 text-center py-12">
            <p className="text-gray-500 mb-4">Select a project first from Projects Dashboard</p>
            <button onClick={() => setActiveComponent('Projects Dashboard')} className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
              Go to Projects
            </button>
          </div>
        )
      case 'Tasks':
        return selectedProjectId ? (
          <TaskManager projectId={selectedProjectId} />
        ) : (
          <div className="p-6 text-center py-12">
            <p className="text-gray-500 mb-4">Select a project first from Projects Dashboard</p>
            <button onClick={() => setActiveComponent('Projects Dashboard')} className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
              Go to Projects
            </button>
          </div>
        )
      case 'Schedule':
        return selectedProjectId ? (
          <SchedulingManager projectId={selectedProjectId} />
        ) : (
          <div className="p-6 text-center py-12">
            <p className="text-gray-500 mb-4">Select a project first from Projects Dashboard</p>
            <button onClick={() => setActiveComponent('Projects Dashboard')} className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
              Go to Projects
            </button>
          </div>
        )
      case 'Cost Management':
        return selectedProjectId ? (
          <CostManager projectId={selectedProjectId} />
        ) : (
          <div className="p-6 text-center py-12">
            <p className="text-gray-500 mb-4">Select a project first from Projects Dashboard</p>
            <button onClick={() => setActiveComponent('Projects Dashboard')} className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
              Go to Projects
            </button>
          </div>
        )
      case 'Reports':
        return (
          <div className="p-6">
            <div className="bg-white rounded-lg shadow p-8 text-center">
              <h3 className="text-lg font-medium mb-2">Reports & Analytics</h3>
              <p className="text-gray-600 mb-4">Project: {selectedProjectName || 'All Projects'}</p>
              <p className="text-gray-500">Progress reports coming soon</p>
            </div>
          </div>
        )
      
      // Procurement
      case 'Purchase Orders':
      case 'PO Approvals':
      case 'Create Purchase Requisition':
      case 'PR Approval Workflow':
      case 'Convert PR to PO':
      case 'PO Financial Approval':
        return <PurchaseOrderManager />
      
      // Materials Management
      case 'Material Master':
      case 'Display Material Master':
        return <MaterialMaster />
      case 'Create Material Master':
        return <CreateMaterialMaster />
      case 'Maintain Material Master':
      case 'Material Master Maintenance':
        return <MaintainMaterialMaster />
      case 'Vendor Master':
      case 'Vendor Performance Monitor':
        return <VendorManager />
      
      // Inventory Management
      case 'Inventory Management':
        return <InventoryManager />
      case 'Goods Receipt':
      case 'Goods Receipt Processing':
        return <GoodsReceipt />
      case 'Goods Issue':
      case 'Goods Issue to Project':
        return <GoodsIssue />
      case 'Goods Transfer':
      case 'Stock Transfer Between Sites':
        return <GoodsTransfer />
      case 'Physical Inventory':
      case 'Physical Inventory Count':
        return <PhysicalInventory />
      case 'Inventory Adjustments':
        return <InventoryAdjustments />
      case 'Material Requests':
      case 'Unified Material Request':
        return <UnifiedMaterialRequest />
      case 'Material Reservations':
      case 'Create Material Reservation':
      case 'My Reservations':
      case 'Approve Material Reservations':
      case 'Material Reservation Monitor':
        return <MaterialReservations />
      case 'Material Stock Overview':
      case 'Stock Overview by Location':
        return <MaterialStockOverview />
      case 'Material Availability Check':
        return (
          <div className="p-6">
            <div className="bg-white rounded-lg shadow p-6">
              <p className="text-gray-600">Check stock vs requirements for planning</p>
            </div>
          </div>
        )
      case 'Extend Material to Plant':
        return <ExtendMaterialToPlant />
      case 'Material Plant Parameters':
        return <MaterialPlantParameters />
      case 'Material Pricing':
        return (
          <div className="p-6">
            <div className="bg-white rounded-lg shadow p-6">
              <p className="text-gray-600">Manage material pricing by company and plant</p>
            </div>
          </div>
        )
      
      // Finance & Controlling
      case 'Chart of Accounts':
        return <ChartOfAccounts />
      case 'Cost Center Accounting':
        return <CostCenterAccounting />
      case 'GL Account Posting':
        return <GLPostingComponent />
      case 'Trial Balance':
        return <TrialBalanceComponent />
      case 'Profit & Loss Statement':
        return <ProfitLossComponent />
      case 'Project Budget vs Actual':
      case 'Material Cost Variance':
      case 'Project Cost Consumption':
        return (
          <div className="p-6">
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-xl font-semibold mb-4">{activeComponent}</h2>
              <p className="text-gray-600">Financial analysis and cost control</p>
            </div>
          </div>
        )
      
      // Configuration & Administration
      case 'SAP Configuration':
        return <SAPConfig />
      case 'ERP Configuration':
        return <ERPConfigurationModuleComplete />
      case 'User Management':
        return <UserManagement />
      case 'Role Management':
        return <RoleManagement />
      case 'User Role Assignment':
        return <UserRoleAssignment />
      case 'Authorization Objects':
        return <AuthorizationObjects />
      case 'Approval Configuration':
      case 'Configure Approvals':
        return <ApprovalConfiguration />
      case 'Authorization Management':
        return (
          <div className="p-6">
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-xl font-semibold mb-4">Authorization Management</h2>
              <p className="text-gray-600">Manage user roles and permissions</p>
            </div>
          </div>
        )
      
      // Planning & Analytics
      case 'Activity Material Requirements':
      case 'Project Material Forecast':
      case 'Material Requirement Forecast':
        return (
          <div className="p-6">
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-xl font-semibold mb-4">{activeComponent}</h2>
              <p className="text-gray-600">Material planning and forecasting</p>
            </div>
          </div>
        )
      case 'MRP Run Configuration':
      case 'MRP Shortage Monitor':
      case 'Planned PR Dashboard':
        return (
          <div className="p-6">
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-xl font-semibold mb-4">{activeComponent}</h2>
              <p className="text-gray-600">MRP planning and execution</p>
            </div>
          </div>
        )
      
      // Analytics & KPIs
      case 'Procurement Performance KPIs':
      case 'Project Material Efficiency':
      case 'Procurement Spend Analysis':
        return (
          <div className="p-6">
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-xl font-semibold mb-4">{activeComponent}</h2>
              <p className="text-gray-600">Performance analytics and KPIs</p>
            </div>
          </div>
        )
      
      // Bulk Operations
      case 'Bulk Upload Materials':
        return (
          <div className="p-6">
            <div className="bg-white rounded-lg shadow p-6">
              
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium mb-2">
                    Select File (Excel/CSV)
                  </label>
                  <input 
                    id="file-upload"
                    type="file" 
                    accept=".xlsx,.xls,.csv"
                    className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100"
                  />
                </div>
                
                <div className="flex space-x-4">
                  <button 
                    onClick={() => {
                      const fileInput = document.getElementById('file-upload') as HTMLInputElement
                      const file = fileInput?.files?.[0]
                      if (!file) {
                        alert('Please select a file first')
                        return
                      }
                      
                      const reader = new FileReader()
                      reader.onload = (e) => {
                        const content = e.target?.result as string
                        const lines = content.split('\n')
                        const preview = lines.slice(0, 6).join('\n') // Show first 5 rows + header
                        
                        const previewDiv = document.getElementById('file-preview')
                        if (previewDiv) {
                          previewDiv.innerHTML = `
                            <div class="mt-4 p-4 bg-blue-50 rounded border">
                              <h4 class="font-medium mb-2">File Preview (${lines.length - 1} rows):</h4>
                              <pre class="text-xs text-gray-700 overflow-x-auto">${preview}</pre>
                              <div class="mt-3 flex space-x-2">
                                <button class="bg-green-600 text-white px-3 py-1 rounded text-sm hover:bg-green-700" onclick="
                                  const lines = document.querySelector('#file-preview pre').textContent.split('\\n');
                                  const headers = lines[0].split(',');
                                  const dataRows = lines.slice(1).filter(line => line.trim());
                                  
                                  const materials = dataRows.map(row => {
                                    const values = row.split(',');
                                    return {
                                      material_code: values[0],
                                      material_name: values[1],
                                      description: values[2],
                                      category: values[3],
                                      base_uom: values[4],
                                      material_type: values[5] || 'FERT',
                                      standard_price: parseFloat(values[6]) || 0,
                                      plant_code: values[7],
                                      plant_name: values[8],
                                      reorder_level: parseFloat(values[9]) || 0,
                                      safety_stock: parseFloat(values[10]) || 0,
                                      storage_location_id: parseInt(values[11]) || 1,
                                      current_stock: parseFloat(values[12]) || 0,
                                      bin_required: values[13] || 'N',
                                      bin_location: values[14] || null
                                    };
                                  });
                                  
                                  fetch('/api/tiles?category=materials&action=bulk-upload', {
                                    method: 'POST',
                                    headers: { 'Content-Type': 'application/json' },
                                    body: JSON.stringify({ materials })
                                  })
                                  .then(res => res.json())
                                  .then(data => {
                                    if (data.success) {
                                      alert('Successfully uploaded ' + data.data.count + ' materials!');
                                      document.getElementById('file-preview').innerHTML = '';
                                      document.getElementById('file-upload').value = '';
                                    } else {
                                      alert('Upload failed: ' + data.error);
                                    }
                                  })
                                  .catch(err => alert('Upload error: ' + err.message));
                                ">
                                  Confirm Upload
                                </button>
                                <button class="bg-gray-500 text-white px-3 py-1 rounded text-sm hover:bg-gray-600" onclick="document.getElementById('file-preview').innerHTML = ''">
                                  Cancel
                                </button>
                              </div>
                            </div>
                          `
                        }
                      }
                      reader.readAsText(file)
                    }}
                    className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
                  >
                    Upload & Preview
                  </button>
                  <button 
                    onClick={() => {
                      const csvContent = "material_code,material_name,description,category,base_uom,material_type,standard_price,plant_code,plant_name,reorder_level,safety_stock,storage_location_id,current_stock,bin_required,bin_location\nCEMENT-OPC-53,OPC 53 Grade Cement,Ordinary Portland Cement 53 Grade,CEMENT,BAG,FERT,500.00,P001,Main Plant,100,50,1,0,N,\nSTEEL-TMT-12MM,TMT Steel Bars 12mm,Thermo Mechanically Treated Steel Bars,STEEL,TON,FERT,65000.00,P001,Main Plant,5,2,1,0,Y,STEEL-RACK-A1\nSAND-RIVER,River Sand,Fine aggregate for concrete,AGGREGATE,CUM,FERT,1500.00,P001,Main Plant,50,20,1,0,N,"
                      const blob = new Blob([csvContent], { type: 'text/csv' })
                      const url = window.URL.createObjectURL(blob)
                      const a = document.createElement('a')
                      a.href = url
                      a.download = 'material_master_template.csv'
                      document.body.appendChild(a)
                      a.click()
                      document.body.removeChild(a)
                      window.URL.revokeObjectURL(url)
                    }}
                    className="bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600"
                  >
                    Download Template
                  </button>
                </div>
              </div>
              
              <div id="file-preview"></div>
              
              <div className="mt-6 p-4 bg-gray-50 rounded">
                <h3 className="font-medium mb-2">Template Format:</h3>
                <p className="text-sm text-gray-600">
                  material_code | material_name | description | category | base_uom | material_type | standard_price | plant_code | plant_name | reorder_level | safety_stock | storage_location_id | current_stock | available_stock | bin_location
                </p>
              </div>
            </div>
          </div>
        )
      
      // Additional Tiles - Generic Handler
      case 'Convert Planned PRs':
      case 'Cost Object Settlement':
      case 'Cost Object Hierarchy':
      case 'Inventory Valuation Report':
        return (
          <div className="p-6">
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-xl font-semibold mb-4">{activeComponent}</h2>
              <p className="text-gray-600">Feature available - Implementation in progress</p>
            </div>
          </div>
        )
      
      default:
        return (
          <div className="p-6">
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-xl font-semibold mb-4">{activeComponent}</h2>
              <p className="text-gray-600">Module functionality available</p>
            </div>
          </div>
        )
    }
  }

  if (authLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Authenticating...</p>
        </div>
      </div>
    )
  }

  if (!user) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="text-6xl mb-4">🔒</div>
          <h3 className="text-xl font-semibold text-gray-900 mb-2">Authentication Required</h3>
          <p className="text-gray-600 mb-4">Please log in to access the construction modules.</p>
          <button 
            onClick={() => window.location.href = '/login'}
            className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700"
          >
            Go to Login
          </button>
        </div>
      </div>
    )
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading construction modules...</p>
        </div>
      </div>
    )
  }

  if (activeComponent) {
    return (
      <div className="min-h-screen bg-gray-50">
        <div className="bg-white shadow-sm border-b px-6 py-4">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-xl font-semibold">{activeComponent}</h1>
              {selectedProjectName && (
                <p className="text-sm text-gray-600">Project: {selectedProjectName}</p>
              )}
            </div>
            <button
              onClick={() => setActiveComponent(null)}
              className="flex items-center text-gray-600 hover:text-gray-800"
            >
              <Icons.ArrowLeft className="w-4 h-4 mr-2" />
              Back to Modules
            </button>
          </div>
        </div>
        <Suspense fallback={<ModuleLoader />}>
          {renderActiveComponent()}
        </Suspense>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <div className="max-w-7xl mx-auto">
        <div className="mb-8">
          <div className="flex justify-between items-center">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">Construction Management System</h1>
              <p className="text-gray-600">Access authorized modules based on your role permissions</p>
            </div>
            <button
              onClick={async () => {
                if (loggingOut) return
                setLoggingOut(true)
                try {
                  await signOut()
                } catch (error) {
                  console.error('Logout error:', error)
                } finally {
                  setLoggingOut(false)
                }
              }}
              disabled={loggingOut}
              className="flex items-center px-4 py-2 text-gray-600 hover:text-gray-800 hover:bg-gray-100 rounded-lg transition-colors disabled:opacity-50"
            >
              <Icons.LogOut className="w-4 h-4 mr-2" />
              {loggingOut ? 'Signing out...' : 'Logout'}
            </button>
          </div>
        </div>

        <div className="mb-6">
          <div className="flex flex-wrap gap-2">
            {categories.map((category) => (
              <button
                key={category.key}
                onClick={() => setSelectedCategory(category.key)}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                  selectedCategory === category.key
                    ? 'bg-blue-600 text-white'
                    : 'bg-white text-gray-700 hover:bg-gray-100 border'
                }`}
              >
                <span className="mr-2">{category.icon}</span>
                {category.label}
              </button>
            ))}
          </div>
        </div>

        {filteredTiles.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {filteredTiles.map((tile) => (
              <div
                key={tile.id}
                onClick={() => handleTileClick(tile)}
                className="bg-white rounded-lg shadow-sm border-2 p-6 transition-all duration-200 hover:shadow-md hover:border-blue-300 cursor-pointer transform hover:scale-105"
              >
                <div className="flex items-center mb-4">
                  {(() => {
                    const IconComponent = getIcon(tile.icon)
                    return <IconComponent className="w-8 h-8 mr-3 text-blue-600" />
                  })()}
                  <div className="flex-1">
                    <div className="flex items-center gap-2">
                      <h3 className="font-semibold text-gray-900">{tile.title}</h3>
                      {tile.auth_object && (
                        <span className="text-xs text-gray-400 font-mono">
                          {tile.auth_object}
                        </span>
                      )}
                    </div>
                    <span className="text-xs text-blue-600 font-medium">{tile.module_code}</span>
                  </div>
                </div>
                
                <p className="text-sm text-gray-600 mb-4">{tile.subtitle}</p>
                
                <div className="flex justify-between items-center">
                  <span className="text-xs bg-gray-100 text-gray-700 px-2 py-1 rounded">
                    {tile.construction_action}
                  </span>
                  <span className="text-blue-600 text-sm font-medium">Open →</span>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="text-center py-12">
            <div className="text-6xl mb-4">🔒</div>
            <h3 className="text-xl font-semibold text-gray-900 mb-2">No Authorized Modules</h3>
            <p className="text-gray-600">Contact your administrator for access.</p>
          </div>
        )}
      </div>
    </div>
  )
}