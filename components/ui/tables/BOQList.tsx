'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Search, Plus, Edit, Trash2, Calculator, FileText } from 'lucide-react'

interface BOQItem {
  id: string
  item_code: string
  description: string
  specification?: string
  unit: string
  quantity: number
  rate: number
  amount: number
  category: {
    id: string
    name: string
    code: string
  }
  is_provisional: boolean
  wbs_node?: {
    code: string
    name: string
  }
}

interface BOQListProps {
  projectId: string
}

export default function BOQList({ projectId }: BOQListProps) {
  const [boqItems, setBOQItems] = useState<BOQItem[]>([])
  const [filteredItems, setFilteredItems] = useState<BOQItem[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [categoryFilter, setCategoryFilter] = useState('all')
  const [loading, setLoading] = useState(true)
  const [categories, setCategories] = useState<Array<{ id: string; name: string; code: string }>>([])

  useEffect(() => {
    loadBOQData()
  }, [projectId])

  useEffect(() => {
    filterItems()
  }, [boqItems, searchTerm, categoryFilter])

  const loadBOQData = async () => {
    try {
      // Mock data - replace with actual API calls
      const mockCategories = [
        { id: '1', name: 'Earthwork', code: 'EW' },
        { id: '2', name: 'Concrete Work', code: 'CW' },
        { id: '3', name: 'Steel Work', code: 'SW' },
        { id: '4', name: 'Masonry', code: 'MW' }
      ]

      const mockBOQItems: BOQItem[] = [
        {
          id: '1',
          item_code: 'EW-001',
          description: 'Excavation for foundation',
          specification: 'Machine excavation in ordinary soil up to 3m depth',
          unit: 'cum',
          quantity: 1250,
          rate: 45.50,
          amount: 56875,
          category: mockCategories[0],
          is_provisional: false,
          wbs_node: { code: 'WBS-01.02', name: 'Site Clearing' }
        },
        {
          id: '2',
          item_code: 'CW-001',
          description: 'PCC 1:4:8 for foundation',
          specification: 'Plain cement concrete 1:4:8 with 40mm aggregate',
          unit: 'cum',
          quantity: 85,
          rate: 4200.00,
          amount: 357000,
          category: mockCategories[1],
          is_provisional: false,
          wbs_node: { code: 'WBS-02.02', name: 'Concrete Foundation' }
        },
        {
          id: '3',
          item_code: 'CW-002',
          description: 'RCC M25 for columns',
          specification: 'Reinforced cement concrete M25 grade',
          unit: 'cum',
          quantity: 120,
          rate: 6800.00,
          amount: 816000,
          category: mockCategories[1],
          is_provisional: false
        },
        {
          id: '4',
          item_code: 'SW-001',
          description: 'TMT Steel bars',
          specification: 'Fe 500 TMT steel bars of various dia',
          unit: 'kg',
          quantity: 15000,
          rate: 65.00,
          amount: 975000,
          category: mockCategories[2],
          is_provisional: true
        }
      ]

      setCategories(mockCategories)
      setBOQItems(mockBOQItems)
    } catch (error) {
      console.error('Failed to load BOQ data:', error)
    } finally {
      setLoading(false)
    }
  }

  const filterItems = () => {
    let filtered = boqItems

    if (searchTerm) {
      filtered = filtered.filter(item =>
        item.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
        item.item_code.toLowerCase().includes(searchTerm.toLowerCase()) ||
        item.specification?.toLowerCase().includes(searchTerm.toLowerCase())
      )
    }

    if (categoryFilter !== 'all') {
      filtered = filtered.filter(item => item.category.id === categoryFilter)
    }

    setFilteredItems(filtered)
  }

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 2
    }).format(amount)
  }

  const formatNumber = (num: number) => {
    return new Intl.NumberFormat('en-US', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    }).format(num)
  }

  const getTotalAmount = () => {
    return filteredItems.reduce((sum, item) => sum + item.amount, 0)
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
          <h1 className="text-3xl font-bold">Bill of Quantities (BOQ)</h1>
          <p className="text-gray-600 mt-1">Project cost estimation and quantity takeoff</p>
        </div>
        <div className="flex space-x-2">
          <Button variant="outline">
            <Calculator className="h-4 w-4 mr-2" />
            Calculate Total
          </Button>
          <Button>
            <Plus className="h-4 w-4 mr-2" />
            Add BOQ Item
          </Button>
        </div>
      </div>

      <div className="flex gap-4 items-center">
        <div className="relative flex-1 max-w-sm">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
          <Input
            placeholder="Search BOQ items..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="pl-10"
          />
        </div>
        <Select value={categoryFilter} onValueChange={setCategoryFilter}>
          <SelectTrigger className="w-48">
            <SelectValue placeholder="Filter by category" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Categories</SelectItem>
            {categories.map(category => (
              <SelectItem key={category.id} value={category.id}>
                {category.name}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      <Card>
        <CardHeader>
          <div className="flex justify-between items-center">
            <CardTitle>BOQ Items</CardTitle>
            <div className="text-right">
              <div className="text-2xl font-bold">{formatCurrency(getTotalAmount())}</div>
              <p className="text-sm text-gray-600">Total BOQ Value</p>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Item Code</TableHead>
                <TableHead>Description</TableHead>
                <TableHead>Category</TableHead>
                <TableHead>Unit</TableHead>
                <TableHead className="text-right">Quantity</TableHead>
                <TableHead className="text-right">Rate</TableHead>
                <TableHead className="text-right">Amount</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredItems.map((item) => (
                <TableRow key={item.id} className="hover:bg-gray-50">
                  <TableCell className="font-medium">{item.item_code}</TableCell>
                  <TableCell>
                    <div>
                      <div className="font-medium">{item.description}</div>
                      {item.specification && (
                        <div className="text-sm text-gray-600 mt-1">{item.specification}</div>
                      )}
                      {item.wbs_node && (
                        <div className="text-xs text-blue-600 mt-1">
                          {item.wbs_node.code} - {item.wbs_node.name}
                        </div>
                      )}
                    </div>
                  </TableCell>
                  <TableCell>
                    <Badge variant="outline">
                      {item.category.name}
                    </Badge>
                  </TableCell>
                  <TableCell>{item.unit}</TableCell>
                  <TableCell className="text-right">{formatNumber(item.quantity)}</TableCell>
                  <TableCell className="text-right">{formatCurrency(item.rate)}</TableCell>
                  <TableCell className="text-right font-medium">{formatCurrency(item.amount)}</TableCell>
                  <TableCell>
                    {item.is_provisional ? (
                      <Badge variant="secondary" className="bg-yellow-100 text-yellow-800">
                        Provisional
                      </Badge>
                    ) : (
                      <Badge variant="secondary" className="bg-green-100 text-green-800">
                        Confirmed
                      </Badge>
                    )}
                  </TableCell>
                  <TableCell className="text-right">
                    <div className="flex justify-end space-x-1">
                      <Button variant="ghost" size="sm">
                        <Edit className="h-4 w-4" />
                      </Button>
                      <Button variant="ghost" size="sm" className="text-red-600 hover:text-red-700">
                        <Trash2 className="h-4 w-4" />
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      {filteredItems.length === 0 && (
        <div className="text-center py-12">
          <FileText className="h-12 w-12 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-500">No BOQ items found matching your criteria.</p>
          <Button className="mt-4">
            <Plus className="h-4 w-4 mr-2" />
            Add First BOQ Item
          </Button>
        </div>
      )}

      <Card>
        <CardHeader>
          <CardTitle>BOQ Summary</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div className="text-center">
              <div className="text-2xl font-bold">{filteredItems.length}</div>
              <p className="text-sm text-gray-600">Total Items</p>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold">{categories.length}</div>
              <p className="text-sm text-gray-600">Categories</p>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold">
                {filteredItems.filter(item => item.is_provisional).length}
              </div>
              <p className="text-sm text-gray-600">Provisional Items</p>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-green-600">{formatCurrency(getTotalAmount())}</div>
              <p className="text-sm text-gray-600">Total Value</p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}