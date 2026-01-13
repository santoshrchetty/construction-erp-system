// DEPRECATED: This file is marked for removal - no active dependencies found
// TODO: Remove after confirming no imports
/*
'use client'

import { useState, useEffect } from 'react'
import { repositories } from '@/lib/repositories'

interface WBSNode {
  id: string
  code: string
  name: string
  description?: string
  node_type: string
  level: number
  sequence_order: number
  budget_allocation?: number
  parent_id?: string
  children?: WBSNode[]
}

interface WBSListProps {
  projectId: string
}

export default function WBSList({ projectId }: WBSListProps) {
  const [wbsNodes, setWbsNodes] = useState<WBSNode[]>([])
  const [filteredNodes, setFilteredNodes] = useState<WBSNode[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [typeFilter, setTypeFilter] = useState('all')
  const [expandedNodes, setExpandedNodes] = useState<Set<string>>(new Set())
  const [viewMode, setViewMode] = useState<'tree' | 'table'>('tree')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadWBSNodes()
  }, [projectId])

  useEffect(() => {
    filterNodes()
  }, [wbsNodes, searchTerm, typeFilter])

  const loadWBSNodes = async () => {
    try {
      const data = await repositories.wbs.findByProject(projectId)
      const hierarchicalData = buildHierarchy(data)
      setWbsNodes(hierarchicalData)
      // Expand first level by default
      const firstLevelIds = hierarchicalData.filter(node => node.level === 1).map(node => node.id)
      setExpandedNodes(new Set(firstLevelIds))
    } catch (error) {
      console.error('Failed to load WBS nodes:', error)
    } finally {
      setLoading(false)
    }
  }

  const buildHierarchy = (nodes: any[]): WBSNode[] => {
    const nodeMap = new Map()
    const rootNodes: WBSNode[] = []

    // Create map of all nodes
    nodes.forEach(node => {
      nodeMap.set(node.id, { ...node, children: [] })
    })

    // Build hierarchy
    nodes.forEach(node => {
      const nodeWithChildren = nodeMap.get(node.id)
      if (node.parent_id) {
        const parent = nodeMap.get(node.parent_id)
        if (parent) {
          parent.children.push(nodeWithChildren)
        }
      } else {
        rootNodes.push(nodeWithChildren)
      }
    })

    return rootNodes.sort((a, b) => a.sequence_order - b.sequence_order)
  }

  const filterNodes = () => {
    let filtered = flattenNodes(wbsNodes)

    if (searchTerm) {
      filtered = filtered.filter(node =>
        node.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        node.code.toLowerCase().includes(searchTerm.toLowerCase()) ||
        node.description?.toLowerCase().includes(searchTerm.toLowerCase())
      )
    }

    if (typeFilter !== 'all') {
      filtered = filtered.filter(node => node.node_type === typeFilter)
    }

    setFilteredNodes(filtered)
  }

  const flattenNodes = (nodes: WBSNode[]): WBSNode[] => {
    const result: WBSNode[] = []
    
    const traverse = (nodeList: WBSNode[]) => {
      nodeList.forEach(node => {
        result.push(node)
        if (node.children && node.children.length > 0) {
          traverse(node.children)
        }
      })
    }
    
    traverse(nodes)
    return result
  }

  const toggleExpanded = (nodeId: string) => {
    const newExpanded = new Set(expandedNodes)
    if (newExpanded.has(nodeId)) {
      newExpanded.delete(nodeId)
    } else {
      newExpanded.add(nodeId)
    }
    setExpandedNodes(newExpanded)
  }

  const getTypeColor = (type: string) => {
    switch (type) {
      case 'project': return 'bg-purple-100 text-purple-800'
      case 'phase': return 'bg-blue-100 text-blue-800'
      case 'deliverable': return 'bg-green-100 text-green-800'
      case 'work_package': return 'bg-orange-100 text-orange-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const formatCurrency = (amount?: number) => {
    if (!amount) return '-'
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0
    }).format(amount)
  }

  const renderTreeNode = (node: WBSNode, depth = 0) => {
    const hasChildren = node.children && node.children.length > 0
    const isExpanded = expandedNodes.has(node.id)
    const indent = depth * 24

    return (
      <div key={node.id}>
        <div 
          className="flex items-center py-2 px-4 hover:bg-gray-50 border-b border-gray-100"
          style={{ paddingLeft: `${16 + indent}px` }}
        >
          <div className="flex items-center flex-1">
            {hasChildren && (
              <button
                onClick={() => toggleExpanded(node.id)}
                className="mr-2 w-4 h-4 flex items-center justify-center text-gray-400 hover:text-gray-600"
              >
                {isExpanded ? '▼' : '▶'}
              </button>
            )}
            {!hasChildren && <div className="w-6"></div>}
            
            <div className="flex-1">
              <div className="flex items-center space-x-2">
                <span className="font-mono text-xs text-gray-600">{node.code}</span>
                <span className={`px-2 py-1 rounded text-xs ${getTypeColor(node.node_type)}`}>
                  {node.node_type}
                </span>
              </div>
              <div className="font-medium text-sm mt-1">{node.name}</div>
              {node.description && (
                <div className="text-xs text-gray-500 mt-1">{node.description}</div>
              )}
            </div>
            
            <div className="text-right">
              <div className="text-sm font-medium">{formatCurrency(node.budget_allocation)}</div>
              <div className="text-xs text-gray-500">Level {node.level}</div>
            </div>
            
            <div className="ml-4 flex space-x-1">
              <button className="text-blue-600 hover:text-blue-800 text-xs px-2 py-1 rounded hover:bg-blue-50">
                Edit
              </button>
              <button className="text-green-600 hover:text-green-800 text-xs px-2 py-1 rounded hover:bg-green-50">
                Add Child
              </button>
            </div>
          </div>
        </div>
        
        {hasChildren && isExpanded && (
          <div>
            {node.children!.map(child => renderTreeNode(child, depth + 1))}
          </div>
        )}
      </div>
    )
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold">Work Breakdown Structure</h1>
          <p className="text-gray-600 text-sm">Project hierarchy and deliverables</p>
        </div>
        <div className="flex space-x-2">
          <button 
            onClick={() => setViewMode(viewMode === 'tree' ? 'table' : 'tree')}
            className="px-3 py-1 bg-gray-200 rounded text-sm hover:bg-gray-300"
          >
            {viewMode === 'tree' ? '📊 Table' : '🌳 Tree'}
          </button>
          <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 text-sm">
            + New WBS Node
          </button>
        </div>
      </div>

      <div className="flex flex-wrap gap-4 items-center bg-gray-50 p-4 rounded">
        <div className="flex-1 min-w-64">
          <input
            type="text"
            placeholder="Search WBS nodes..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full px-3 py-2 border rounded text-sm"
          />
        </div>
        <select
          value={typeFilter}
          onChange={(e) => setTypeFilter(e.target.value)}
          className="px-3 py-2 border rounded text-sm"
        >
          <option value="all">All Types</option>
          <option value="project">Project</option>
          <option value="phase">Phase</option>
          <option value="deliverable">Deliverable</option>
          <option value="work_package">Work Package</option>
        </select>
        <button
          onClick={() => setExpandedNodes(new Set(flattenNodes(wbsNodes).map(n => n.id)))}
          className="px-3 py-2 border rounded text-sm hover:bg-gray-50"
        >
          Expand All
        </button>
        <button
          onClick={() => setExpandedNodes(new Set())}
          className="px-3 py-2 border rounded text-sm hover:bg-gray-50"
        >
          Collapse All
        </button>
      </div>

      {viewMode === 'tree' && (
        <div className="bg-white rounded shadow overflow-hidden">
          <div className="max-h-96 overflow-y-auto">
            {wbsNodes.map(node => renderTreeNode(node))}
          </div>
        </div>
      )}

      {viewMode === 'table' && (
        <div className="bg-white rounded shadow overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-4 py-3 text-left">Code</th>
                  <th className="px-4 py-3 text-left">Name</th>
                  <th className="px-4 py-3 text-left">Type</th>
                  <th className="px-4 py-3 text-left">Level</th>
                  <th className="px-4 py-3 text-left">Budget</th>
                  <th className="px-4 py-3 text-left">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {filteredNodes.map((node) => (
                  <tr key={node.id} className="hover:bg-gray-50">
                    <td className="px-4 py-3 font-mono text-xs">{node.code}</td>
                    <td className="px-4 py-3">
                      <div className="font-medium">{node.name}</div>
                      {node.description && (
                        <div className="text-xs text-gray-500">{node.description}</div>
                      )}
                    </td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-1 rounded text-xs ${getTypeColor(node.node_type)}`}>
                        {node.node_type}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-xs">{node.level}</td>
                    <td className="px-4 py-3 text-xs">{formatCurrency(node.budget_allocation)}</td>
                    <td className="px-4 py-3">
                      <div className="flex space-x-1">
                        <button className="text-blue-600 hover:text-blue-800 text-xs px-2 py-1 rounded hover:bg-blue-50">
                          Edit
                        </button>
                        <button className="text-green-600 hover:text-green-800 text-xs px-2 py-1 rounded hover:bg-green-50">
                          Add Child
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {filteredNodes.length === 0 && (
        <div className="text-center py-12 bg-white rounded shadow">
          <p className="text-gray-500 mb-4">
            {searchTerm || typeFilter !== 'all' ? 'No WBS nodes match your filters.' : 'No WBS structure found.'}
          </p>
          <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
            Create WBS Structure
          </button>
        </div>
      )}
    </div>
  )
}
*/