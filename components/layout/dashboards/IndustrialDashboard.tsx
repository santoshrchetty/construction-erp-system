'use client'
import { useEffect, useState } from 'react'
import { usePermissionContext } from '../../shared/permissions/PermissionContext'
import { Permission } from '../../shared/permissions/types'
import * as Icons from 'lucide-react'

interface DatabaseTile {
  id: string
  title: string
  subtitle: string
  icon: string
  color: string
  route: string
  module_code: string
  tile_category: string
  construction_action: string
  has_authorization: boolean
}

export function IndustrialDashboard() {
  const { userRole, checkPermission } = usePermissionContext()
  const [tiles, setTiles] = useState<DatabaseTile[]>([])
  const [loading, setLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedCategory, setSelectedCategory] = useState('all')
  const [activeTile, setActiveTile] = useState<DatabaseTile | null>(null)

  useEffect(() => {
    fetchAuthorizedTiles()
  }, [userRole])

  const fetchAuthorizedTiles = async () => {
    try {
      const response = await fetch('/api/tiles-list')
      const data = await response.json()
      
      if (response.ok) {
        const authorizedTiles = (data.tiles || []).filter((tile: DatabaseTile) => 
          tile.has_authorization && hasModuleAccess(tile.module_code)
        )
        setTiles(authorizedTiles)
      }
    } catch (error) {
      console.error('Error fetching tiles:', error)
    } finally {
      setLoading(false)
    }
  }

  const hasModuleAccess = (moduleCode: string): boolean => {
    const moduleMap: Record<string, any> = {
      'MM': 'procurement',
      'FI': 'costing', 
      'CO': 'costing',
      'PS': 'projects',
      'PP': 'projects',
      'WM': 'stores',
      'HR': 'employees'
    }
    
    const module = moduleMap[moduleCode] || 'projects'
    return checkPermission(module, Permission.READ)
  }

  const handleTileClick = (tile: DatabaseTile) => {
    setActiveTile(tile)
  }

  const closeTile = () => {
    setActiveTile(null)
  }

  const filteredTiles = tiles.filter(tile => {
    const matchesSearch = tile.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         tile.subtitle.toLowerCase().includes(searchQuery.toLowerCase())
    const matchesCategory = selectedCategory === 'all' || tile.tile_category === selectedCategory
    return matchesSearch && matchesCategory
  })

  const categories = ['all', ...Array.from(new Set(tiles.map(tile => tile.tile_category).filter(cat => cat)))]

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-4 border-blue-600 border-t-transparent mx-auto mb-4"></div>
          <p className="text-gray-600">Loading modules...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Mobile-optimized header */}
      <div className="bg-white shadow-sm border-b sticky top-0 z-10">
        <div className="px-4 py-4">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h1 className="text-xl font-bold text-gray-900 sm:text-2xl">
                Construction Hub
              </h1>
              <p className="text-sm text-gray-600">
                Welcome, {userRole} • {filteredTiles.length} modules
              </p>
            </div>
            <div className="flex items-center space-x-2">
              <button className="p-2 text-gray-400 hover:text-gray-600 rounded-lg">
                <Icons.Bell className="w-5 h-5" />
              </button>
              <button className="p-2 text-gray-400 hover:text-gray-600 rounded-lg">
                <Icons.Settings className="w-5 h-5" />
              </button>
            </div>
          </div>

          {/* Search bar */}
          <div className="relative mb-4">
            <Icons.Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input
              type="text"
              placeholder="Search modules..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>

          {/* Category filter */}
          <div className="flex space-x-2 overflow-x-auto scrollbar-hide pb-2">
            {categories.map(category => (
              <button
                key={category}
                onClick={() => setSelectedCategory(category)}
                className={`px-3 py-1.5 text-sm font-medium rounded-full whitespace-nowrap transition-colors ${
                  selectedCategory === category
                    ? 'bg-blue-600 text-white'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
              >
                {category === 'all' ? 'All' : (category || '').charAt(0).toUpperCase() + (category || '').slice(1)}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="p-4">
        {/* Quick actions */}
        <div className="mb-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-3">Quick Actions</h2>
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
            {[
              { icon: Icons.Plus, label: 'New Request', color: 'bg-blue-500' },
              { icon: Icons.CheckSquare, label: 'Approvals', color: 'bg-green-500' },
              { icon: Icons.BarChart3, label: 'Reports', color: 'bg-purple-500' },
              { icon: Icons.Users, label: 'Team', color: 'bg-orange-500' }
            ].map((action, index) => (
              <button
                key={index}
                className="bg-white rounded-lg shadow-sm border p-4 hover:shadow-md transition-shadow"
              >
                <div className={`w-10 h-10 ${action.color} rounded-lg flex items-center justify-center mb-2`}>
                  <action.icon className="w-5 h-5 text-white" />
                </div>
                <p className="text-sm font-medium text-gray-900">{action.label}</p>
              </button>
            ))}
          </div>
        </div>

        {/* Flexible Approval Engine - Featured */}
        <div className="mb-6">
          <div 
            onClick={() => window.location.href = '/flexible-approval'}
            className="bg-gradient-to-r from-blue-600 to-blue-700 rounded-lg shadow-sm p-6 text-white cursor-pointer hover:shadow-md transition-shadow"
          >
            <div className="flex items-center justify-between">
              <div className="flex-1">
                <div className="flex items-center mb-2">
                  <Icons.GitBranch className="w-6 h-6 mr-2" />
                  <h3 className="text-lg font-semibold">Flexible Approval Engine</h3>
                  <span className="ml-2 bg-green-400 text-green-900 text-xs px-2 py-1 rounded-full font-medium">
                    NEW
                  </span>
                </div>
                <p className="text-blue-100 text-sm">
                  Step-driven workflows with dynamic agent resolution
                </p>
              </div>
              <Icons.ArrowRight className="w-5 h-5 ml-4" />
            </div>
          </div>
        </div>

        {/* Module tiles */}
        <div className="mb-4">
          <h2 className="text-lg font-semibold text-gray-900 mb-3">All Modules</h2>
        </div>

        {filteredTiles.length === 0 ? (
          <div className="bg-white rounded-lg shadow-sm border p-8 text-center">
            <Icons.Search className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">No modules found</h3>
            <p className="text-gray-500">
              {searchQuery ? 'Try adjusting your search terms' : 'No accessible modules for your role'}
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
            {filteredTiles.map(tile => (
              <div 
                key={tile.id}
                onClick={() => handleTileClick(tile)}
                className="bg-white rounded-lg shadow-sm border hover:shadow-md transition-shadow cursor-pointer group"
              >
                <div className="p-4">
                  <div className="flex items-start justify-between mb-3">
                    <div className="flex-1 min-w-0">
                      <h3 className="font-semibold text-gray-900 text-sm group-hover:text-blue-600 transition-colors truncate">
                        {tile.title}
                      </h3>
                      <p className="text-xs text-gray-600 mt-1 line-clamp-2">
                        {tile.subtitle}
                      </p>
                    </div>
                    <Icons.ExternalLink className="w-4 h-4 text-gray-400 group-hover:text-blue-600 transition-colors flex-shrink-0 ml-2" />
                  </div>
                  
                  <div className="flex items-center justify-between">
                    <span className="text-xs bg-gray-100 text-gray-700 px-2 py-1 rounded font-medium">
                      {tile.module_code}
                    </span>
                    <span className="text-xs text-gray-500">
                      {tile.tile_category}
                    </span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Bottom navigation for mobile */}
      <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 px-4 py-2 sm:hidden">
        <div className="flex justify-around">
          {[
            { icon: Icons.Home, label: 'Home', active: true },
            { icon: Icons.Search, label: 'Search' },
            { icon: Icons.Bell, label: 'Alerts' },
            { icon: Icons.User, label: 'Profile' }
          ].map((item, index) => (
            <button
              key={index}
              className={`flex flex-col items-center py-2 px-3 rounded-lg transition-colors ${
                item.active 
                  ? 'text-blue-600 bg-blue-50' 
                  : 'text-gray-500 hover:text-gray-700'
              }`}
            >
              <item.icon className="w-5 h-5 mb-1" />
              <span className="text-xs font-medium">{item.label}</span>
            </button>
          ))}
        </div>
      </div>

      {/* Add bottom padding for mobile navigation */}
      <div className="h-20 sm:hidden"></div>

      {/* Tile Modal */}
      {activeTile && (
        <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-lg shadow-xl w-full max-w-6xl max-h-[90vh] overflow-hidden">
            <div className="flex items-center justify-between p-4 border-b">
              <div>
                <h2 className="text-xl font-bold text-gray-900">{activeTile.title}</h2>
                <p className="text-sm text-gray-600">{activeTile.subtitle}</p>
              </div>
              <button
                onClick={closeTile}
                className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
              >
                <Icons.X className="w-5 h-5" />
              </button>
            </div>
            <div className="overflow-y-auto max-h-[calc(90vh-80px)]">
              {renderTileComponent(activeTile)}
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

function renderTileComponent(tile: DatabaseTile) {
  // Temporarily disabled - components not available
  return (
    <div className="p-8 text-center">
      <Icons.AlertCircle className="w-12 h-12 text-gray-400 mx-auto mb-4" />
      <p className="text-gray-600">Component not yet implemented</p>
      <p className="text-sm text-gray-500 mt-2">Action: {tile.construction_action}</p>
    </div>
  )
}