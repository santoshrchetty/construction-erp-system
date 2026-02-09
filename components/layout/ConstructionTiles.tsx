'use client'

import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'
import UserManagement from './UserManagement'
import RoleManagement from './RoleManagement'
import UserRoleAssignment from './UserRoleAssignment'
import AuthorizationObjects from './AuthorizationObjects'
import ChartOfAccounts from './ChartOfAccounts'
import { MaterialRequestList } from '@/components/features/materials/MaterialRequestList'

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
}

export default function ConstructionTiles() {
  const [tiles, setTiles] = useState<ConstructionTile[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedCategory, setSelectedCategory] = useState<string>('all')
  const [activeTile, setActiveTile] = useState<ConstructionTile | null>(null)

  const getIcon = (iconName: string) => {
    // Map common icon names to Lucide components
    const iconMap: { [key: string]: any } = {
      'building': Icons.Building,
      'building-2': Icons.Building2,
      'plus-circle': Icons.PlusCircle,
      'edit': Icons.Edit,
      'edit-3': Icons.Edit3,
      'git-branch': Icons.GitBranch,
      'shopping-cart': Icons.ShoppingCart,
      'check-circle': Icons.CheckCircle,
      'package': Icons.Package,
      'package-check': Icons.PackageCheck,
      'box': Icons.Box,
      'users': Icons.Users,
      'calendar': Icons.Calendar,
      'play': Icons.Play,
      'play-circle': Icons.PlayCircle,
      'user-check': Icons.UserCheck,
      'trending-up': Icons.TrendingUp,
      'file-text': Icons.FileText,
      'shield-check': Icons.ShieldCheck,
      'dollar-sign': Icons.DollarSign,
      'pie-chart': Icons.PieChart,
      'bar-chart-3': Icons.BarChart3,
      'clock': Icons.Clock,
      'check-square': Icons.CheckSquare,
      'settings': Icons.Settings,
      'user-cog': Icons.UserCog,
      'truck': Icons.Truck,
      'warehouse': Icons.Warehouse
    }
    
    return iconMap[iconName] || Icons.Square
  }

  useEffect(() => {
    fetchTiles()
  }, [])

  const fetchTiles = async () => {
    try {
      const response = await fetch('/api/tiles-list')
      const data = await response.json()
      
      console.log('Tiles response:', data)
      
      if (response.ok) {
        setTiles(data.tiles || [])
      } else {
        console.error('Failed to fetch tiles:', data)
      }
    } catch (error) {
      console.error('Error fetching tiles:', error)
    } finally {
      setLoading(false)
    }
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
      setActiveTile(tile)
    }
  }

  const renderTileComponent = () => {
    if (!activeTile) return null

    switch (activeTile.title) {
      case 'User Management':
        return <UserManagement />
      case 'Role Management':
        return <RoleManagement />
      case 'User Role Assignment':
        return <UserRoleAssignment />
      case 'Authorization Objects':
        return <AuthorizationObjects />
      case 'Chart of Accounts':
        return <ChartOfAccounts />
      case 'Material Request List':
        return <MaterialRequestList />
      case 'ERP Configuration':
        return <ERPConfigurationTile />
      default:
        return (
          <div className="p-6">
            <h2 className="text-2xl font-bold mb-4">{activeTile.title}</h2>
            <p className="text-gray-600">This feature is coming soon.</p>
          </div>
        )
    }
  }

  if (activeTile) {
    return (
      <div className="min-h-screen bg-gray-50">
        <div className="bg-white shadow-sm border-b px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center">
              <button
                onClick={() => setActiveTile(null)}
                className="mr-4 p-2 hover:bg-gray-100 rounded"
              >
                <Icons.ArrowLeft className="w-5 h-5" />
              </button>
              <h1 className="text-2xl font-bold">{activeTile.title}</h1>
            </div>
            <span className="text-sm text-gray-500">{activeTile.module_code}</span>
          </div>
        </div>
        <div className="p-6">
          {renderTileComponent()}
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

  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Construction Management System</h1>
          <p className="text-gray-600">Access authorized modules based on your role permissions</p>
        </div>

        {/* Category Filter */}
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

        {/* Tiles Grid */}
        {filteredTiles.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {filteredTiles.map((tile) => (
              <div
                key={tile.id}
                onClick={() => handleTileClick(tile)}
                className={`bg-white rounded-lg shadow-sm border-2 p-6 transition-all duration-200 ${
                  tile.has_authorization
                    ? 'hover:shadow-md hover:border-blue-300 cursor-pointer transform hover:scale-105'
                    : 'opacity-50 cursor-not-allowed'
                }`}
              >
                <div className="flex items-center mb-4">
                  {(() => {
                    const IconComponent = getIcon(tile.icon)
                    return <IconComponent className="w-8 h-8 mr-3 text-blue-600" />
                  })()}
                  <div>
                    <h3 className="font-semibold text-gray-900">{tile.title}</h3>
                    <span className="text-xs text-blue-600 font-medium">{tile.module_code}</span>
                  </div>
                </div>
                
                <p className="text-sm text-gray-600 mb-4">{tile.subtitle}</p>
                
                <div className="flex justify-between items-center">
                  <span className="text-xs bg-gray-100 text-gray-700 px-2 py-1 rounded">
                    {tile.construction_action}
                  </span>
                  {tile.has_authorization && (
                    <span className="text-blue-600 text-sm font-medium">Access →</span>
                  )}
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="text-center py-12">
            <div className="text-6xl mb-4">🔒</div>
            <h3 className="text-xl font-semibold text-gray-900 mb-2">No Authorized Modules</h3>
            <p className="text-gray-600">
              {selectedCategory === 'all' 
                ? 'You don\'t have access to any modules. Contact your administrator.'
                : `No modules available in the ${categories.find(c => c.key === selectedCategory)?.label} category.`
              }
            </p>
          </div>
        )}

        {/* Stats */}
        <div className="mt-8 bg-white rounded-lg shadow-sm p-6">
          <h3 className="text-lg font-semibold mb-4">Access Summary</h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="text-center">
              <div className="text-2xl font-bold text-blue-600">{authorizedTiles.length}</div>
              <div className="text-sm text-gray-600">Authorized Modules</div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-gray-400">{tiles.length - authorizedTiles.length}</div>
              <div className="text-sm text-gray-600">Restricted Modules</div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-green-600">{tiles.length}</div>
              <div className="text-sm text-gray-600">Total Modules</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}