'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase/client'
import * as Icons from 'lucide-react'

export default function MaterialStockOverview() {
  const [showFilters, setShowFilters] = useState(false)
  const [searchResults, setSearchResults] = useState([])
  const [isSearched, setIsSearched] = useState(false)
  const [companies, setCompanies] = useState([])
  const [allPlants, setAllPlants] = useState([])
  const [allStorageLocations, setAllStorageLocations] = useState([])
  const [dataLoaded, setDataLoaded] = useState(false)
  const [filters, setFilters] = useState({
    companyCodes: [] as string[],
    plants: [] as string[],
    storageLocations: [] as string[],
    materialCategory: '',
    materialCodePattern: '',
    stockStatus: ''
  })

  useEffect(() => {
    const loadAllData = async () => {
      await Promise.all([
        loadCompanies(),
        loadPlants(),
        loadStorageLocations()
      ])
      setDataLoaded(true)
    }
    loadAllData()
  }, [])

  const loadCompanies = async () => {
    try {
      const supabase = createClient()
      const { data, error } = await supabase
        .from('company_codes')
        .select('company_code, company_name, currency')
        .eq('is_active', true)
        .order('company_code')
      
      if (error) throw error
      
      setCompanies(data?.map(company => ({
        code: company.company_code,
        name: company.company_name,
        currency: company.currency
      })) || [])
    } catch (error) {
      console.error('Failed to load companies:', error)
    }
  }

  const loadPlants = async () => {
    try {
      const supabase = createClient()
      const { data, error } = await supabase
        .from('plants')
        .select(`
          plant_code,
          plant_name,
          company_code_id
        `)
        .eq('is_active', true)
        .order('plant_code')
      
      if (error) {
        console.error('Plants query error:', error)
        throw error
      }
      
      // Get company codes to map IDs to codes
      const { data: companyData } = await supabase
        .from('company_codes')
        .select('id, company_code')
      
      const companyMap = companyData?.reduce((acc, company) => {
        acc[company.id] = company.company_code
        return acc
      }, {} as Record<string, string>) || {}
      
      const plantsWithCompany = data?.map(plant => {
        let companyCode = companyMap[plant.company_code_id]
        
        // Fallback: try to infer company from plant code pattern
        if (!companyCode || companyCode === 'Unknown') {
          if (plant.plant_code.startsWith('N')) companyCode = 'N001'
          else if (plant.plant_code.startsWith('C')) companyCode = 'C001'
          else if (plant.plant_code.startsWith('B')) companyCode = 'B001'
          else if (plant.plant_code.startsWith('P')) companyCode = 'C001'
        }
        
        return {
          code: plant.plant_code,
          name: plant.plant_name,
          companyCode: companyCode || 'Unknown'
        }
      }) || []
      
      console.log('Loaded plants:', plantsWithCompany)
      setAllPlants(plantsWithCompany)
    } catch (error) {
      console.error('Failed to load plants:', error)
    }
  }

  const loadStorageLocations = async () => {
    try {
      const supabase = createClient()
      const { data, error } = await supabase
        .from('storage_locations')
        .select(`
          sloc_code,
          sloc_name,
          plant_id
        `)
        .eq('is_active', true)
        .order('sloc_code')
      
      if (error) {
        console.error('Storage locations query error:', error)
        throw error
      }
      
      // Get plants to map IDs to codes
      const { data: plantData } = await supabase
        .from('plants')
        .select('id, plant_code')
      
      const plantMap = plantData?.reduce((acc, plant) => {
        acc[plant.id] = plant.plant_code
        return acc
      }, {} as Record<string, string>) || {}
      
      setAllStorageLocations(data?.map(storage => ({
        code: storage.sloc_code,
        name: storage.sloc_name,
        plantCode: plantMap[storage.plant_id] || 'Unknown'
      })) || [])
    } catch (error) {
      console.error('Failed to load storage locations:', error)
    }
  }

  // Filter plants based on selected companies - show ALL plants, not just those with stock
  const availablePlants = filters.companyCodes.length > 0 
    ? allPlants.filter(plant => filters.companyCodes.includes(plant.companyCode))
    : allPlants

  // Filter storage locations based on selected plants
  const availableStorageLocations = filters.plants.length > 0
    ? allStorageLocations.filter(storage => filters.plants.includes(storage.plantCode))
    : []

  const handleCompanyChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const selectedOptions = Array.from(e.target.selectedOptions, option => option.value)
    setFilters(prev => ({
      ...prev,
      companyCodes: selectedOptions,
      plants: [], // Reset plants when companies change
      storageLocations: [] // Reset storage locations when companies change
    }))
  }

  const handlePlantChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const selectedOptions = Array.from(e.target.selectedOptions, option => option.value)
    setFilters(prev => ({
      ...prev,
      plants: selectedOptions,
      storageLocations: [] // Reset storage locations when plants change
    }))
  }

  const handleStorageLocationChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    const selectedOptions = Array.from(e.target.selectedOptions, option => option.value)
    setFilters(prev => ({
      ...prev,
      storageLocations: selectedOptions
    }))
  }

  const selectAllPlants = () => {
    setFilters(prev => ({
      ...prev,
      plants: availablePlants.map(plant => plant.code),
      storageLocations: [] // Reset storage locations
    }))
  }

  const selectAllStorageLocations = () => {
    setFilters(prev => ({
      ...prev,
      storageLocations: availableStorageLocations.map(storage => storage.code)
    }))
  }

  const clearAllFilters = () => {
    setFilters({
      companyCodes: [],
      plants: [],
      storageLocations: [],
      materialCategory: '',
      materialCodePattern: '',
      stockStatus: ''
    })
  }

  const [loading, setLoading] = useState(false)

  const handleSearch = async () => {
    setLoading(true)
    try {
      const params = new URLSearchParams({
        category: 'materials',
        action: 'stock-overview',
        company_code: filters.companyCodes[0] || 'C001',
        material_category: filters.materialCategory || '',
        stock_status: filters.stockStatus || ''
      })
      
      const response = await fetch(`/api/tiles?${params.toString()}`, {
        method: 'GET'
      })
      
      const data = await response.json()
      
      if (data.success) {
        setSearchResults(data.data || [])
        setIsSearched(true)
        setShowFilters(false)
      } else {
        console.error('Search failed:', data.error)
        alert('Search failed: ' + (data.error || 'Unknown error'))
      }
    } catch (error) {
      console.error('Search error:', error)
      alert('Search error: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b px-4 py-3 sticky top-0 z-10">
        <div className="flex items-center justify-between">
          <button 
            onClick={() => setShowFilters(!showFilters)}
            className="lg:hidden bg-blue-500 text-white px-3 py-2 rounded-lg flex items-center text-sm"
          >
            <Icons.Filter className="w-4 h-4 mr-1" />
            Filters
          </button>
        </div>
      </div>

      <div className="flex flex-col lg:flex-row">
        {/* Filters Sidebar */}
        <div className={`${showFilters ? 'block' : 'hidden'} lg:block w-full lg:w-80 bg-white border-r border-gray-200 lg:h-screen lg:sticky lg:top-16 flex flex-col`}>
          <div className="flex-1 p-4 overflow-y-auto">
            <div className="space-y-4">
              <div className="flex items-center justify-between lg:hidden">
                <h3 className="font-medium text-gray-900">Filters</h3>
                <button onClick={() => setShowFilters(false)} className="text-gray-500">
                  <Icons.X className="w-5 h-5" />
                </button>
              </div>
            
            {/* Company Selection */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Companies</label>
              {!dataLoaded ? (
                <div className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm text-gray-500">
                  Loading companies...
                </div>
              ) : (
                <select 
                  multiple 
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500" 
                  size={3}
                  value={filters.companyCodes}
                  onChange={handleCompanyChange}
                >
                  {companies.map(company => (
                    <option key={company.code} value={company.code} className="py-1">
                      {company.code} - {company.name}
                    </option>
                  ))}
                </select>
              )}
              <p className="text-xs text-gray-500 mt-1">Hold Ctrl/Cmd for multiple</p>
            </div>

            {/* Plants */}
            <div>
              <div className="flex items-center justify-between mb-2">
                <label className="text-sm font-medium text-gray-700">Plants</label>
                {availablePlants.length > 0 && (
                  <button 
                    type="button" 
                    onClick={selectAllPlants}
                    className="text-xs text-blue-600 hover:text-blue-800 font-medium"
                  >
                    Select All
                  </button>
                )}
              </div>
              <select 
                multiple 
                className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500" 
                size={3}
                value={filters.plants}
                onChange={handlePlantChange}
                disabled={filters.companyCodes.length === 0}
              >
                {availablePlants.map(plant => (
                  <option key={plant.code} value={plant.code} className="py-1">
                    {plant.code} - {plant.name}
                  </option>
                ))}
              </select>
            </div>

            {/* Storage Locations */}
            <div>
              <div className="flex items-center justify-between mb-2">
                <label className="text-sm font-medium text-gray-700">Storage Locations</label>
                {availableStorageLocations.length > 0 && (
                  <button 
                    type="button" 
                    onClick={selectAllStorageLocations}
                    className="text-xs text-blue-600 hover:text-blue-800 font-medium"
                  >
                    Select All
                  </button>
                )}
              </div>
              <select 
                multiple 
                className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500" 
                size={3}
                value={filters.storageLocations}
                onChange={handleStorageLocationChange}
                disabled={filters.plants.length === 0}
              >
                {availableStorageLocations.map(storage => (
                  <option key={`${storage.plantCode}-${storage.code}`} value={storage.code} className="py-1">
                    {storage.code} - {storage.name}
                  </option>
                ))}
              </select>
            </div>

            {/* Category & Status */}
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Category</label>
                <select 
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  value={filters.materialCategory}
                  onChange={(e) => setFilters(prev => ({ ...prev, materialCategory: e.target.value }))}
                >
                  <option value="">All Categories</option>
                  <option value="CEMENT">CEMENT</option>
                  <option value="STEEL">STEEL</option>
                  <option value="AGGREGATE">AGGREGATE</option>
                  <option value="ASPHALT">ASPHALT</option>
                  <option value="POWER">POWER</option>
                  <option value="SAFETY">SAFETY</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Stock Status</label>
                <select 
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  value={filters.stockStatus}
                  onChange={(e) => setFilters(prev => ({ ...prev, stockStatus: e.target.value }))}
                >
                  <option value="">All Stock Levels</option>
                  <option value="normal">Normal Stock</option>
                  <option value="low">Low Stock</option>
                  <option value="zero">Zero Stock</option>
                  <option value="negative">Negative Stock</option>
                </select>
              </div>
            </div>
            </div>
          </div>
          
          {/* Sticky Action Buttons */}
          <div className="p-4 border-t border-gray-200 bg-white">
            <div className="space-y-2">
              <button 
                type="button" 
                onClick={handleSearch} 
                disabled={loading}
                className="w-full bg-blue-600 text-white py-3 rounded-lg hover:bg-blue-700 disabled:opacity-50 flex items-center justify-center font-medium"
              >
                <Icons.Search className="w-4 h-4 mr-2" />
                {loading ? 'Searching...' : 'Search'}
              </button>
              <div className="grid grid-cols-2 gap-2">
                <button 
                  type="button" 
                  onClick={clearAllFilters} 
                  className="bg-gray-100 text-gray-700 py-2 rounded-lg hover:bg-gray-200 flex items-center justify-center text-sm font-medium"
                >
                  <Icons.X className="w-4 h-4 mr-1" />
                  Clear
                </button>
                <button 
                  type="button" 
                  className="bg-green-100 text-green-700 py-2 rounded-lg hover:bg-green-200 flex items-center justify-center text-sm font-medium"
                >
                  <Icons.Download className="w-4 h-4 mr-1" />
                  Export
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Main Content */}
        <div className="flex-1 p-4">
          {/* Summary Cards */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
            <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4">
              <div className="flex items-center">
                <div className="p-2 bg-blue-100 rounded-lg">
                  <Icons.Building className="w-5 h-5 text-blue-600" />
                </div>
                <div className="ml-3">
                  <p className="text-sm font-medium text-gray-600">Companies</p>
                  <p className="text-2xl font-bold text-gray-900">
                    {isSearched ? new Set(searchResults.map(item => item.company)).size : companies.length}
                  </p>
                </div>
              </div>
            </div>
            <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4">
              <div className="flex items-center">
                <div className="p-2 bg-purple-100 rounded-lg">
                  <Icons.Building2 className="w-5 h-5 text-purple-600" />
                </div>
                <div className="ml-3">
                  <p className="text-sm font-medium text-gray-600">Plants</p>
                  <p className="text-2xl font-bold text-gray-900">
                    {isSearched ? new Set(searchResults.map(item => item.plant)).size : 
                     filters.companyCodes.length > 0 ? availablePlants.length : allPlants.length}
                  </p>
                </div>
              </div>
            </div>
            <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-4">
              <div className="flex items-center">
                <div className="p-2 bg-green-100 rounded-lg">
                  <Icons.Package className="w-5 h-5 text-green-600" />
                </div>
                <div className="ml-3">
                  <p className="text-sm font-medium text-gray-600">Materials</p>
                  <p className="text-2xl font-bold text-gray-900">{searchResults.length}</p>
                </div>
              </div>
            </div>
          </div>

          {/* Results Table */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200">
            <div className="px-4 py-3 border-b border-gray-200">
              <h3 className="text-lg font-medium text-gray-900">Stock Results</h3>
            </div>
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Material</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider hidden md:table-cell">Company</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider hidden lg:table-cell">Plant</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider hidden lg:table-cell">Storage</th>
                    <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Stock</th>
                    <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider hidden sm:table-cell">Value</th>
                    <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {isSearched && searchResults.length > 0 ? (
                    searchResults.map((result: any, index: number) => (
                      <tr key={index} className="hover:bg-gray-50">
                        <td className="px-4 py-4">
                          <div>
                            <div className="text-sm font-medium text-gray-900">{result.code}</div>
                            <div className="text-sm text-gray-500 truncate max-w-xs">{result.description}</div>
                            <div className="md:hidden text-xs text-gray-400 mt-1">{result.company}</div>
                          </div>
                        </td>
                        <td className="px-4 py-4 text-sm text-gray-900 hidden md:table-cell">{result.company}</td>
                        <td className="px-4 py-4 text-sm text-gray-900 hidden lg:table-cell">{result.plant}</td>
                        <td className="px-4 py-4 text-sm text-gray-900 hidden lg:table-cell">{result.storage}</td>
                        <td className="px-4 py-4 text-sm text-gray-900 text-right font-medium">{result.stock}</td>
                        <td className="px-4 py-4 text-sm text-gray-900 text-right font-medium hidden sm:table-cell">{result.value}</td>
                        <td className="px-4 py-4 text-center">
                          <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                            result.status === 'Normal' 
                              ? 'bg-green-100 text-green-800' 
                              : result.status === 'Low Stock'
                              ? 'bg-yellow-100 text-yellow-800'
                              : 'bg-red-100 text-red-800'
                          }`}>
                            {result.status}
                          </span>
                        </td>
                      </tr>
                    ))
                  ) : isSearched ? (
                    <tr>
                      <td colSpan={7} className="px-4 py-8 text-center text-gray-500">
                        <Icons.Search className="w-8 h-8 mx-auto mb-2 text-gray-400" />
                        <p>No results found for the selected filters</p>
                      </td>
                    </tr>
                  ) : (
                    <tr>
                      <td colSpan={7} className="px-4 py-8 text-center text-gray-500">
                        <Icons.Filter className="w-8 h-8 mx-auto mb-2 text-gray-400" />
                        <p>Select filters and click Search to view results</p>
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}