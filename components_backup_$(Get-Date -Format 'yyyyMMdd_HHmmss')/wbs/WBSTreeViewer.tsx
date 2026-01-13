'use client'

import { useState, useEffect } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from '@/components/ui/collapsible'
import { ChevronDown, ChevronRight, Plus, Edit, Trash2, FolderOpen, FileText } from 'lucide-react'

interface WBSNode {
  id: string
  code: string
  name: string
  description?: string
  node_type: 'project' | 'phase' | 'deliverable' | 'work_package'
  level: number
  sequence_order: number
  budget_allocation: number
  planned_hours: number
  parent_id?: string
  children?: WBSNode[]
  is_active: boolean
}

interface WBSTreeViewerProps {
  projectId: string
}

export default function WBSTreeViewer({ projectId }: WBSTreeViewerProps) {
  const [wbsTree, setWbsTree] = useState<WBSNode[]>([])
  const [expandedNodes, setExpandedNodes] = useState<Set<string>>(new Set())
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadWBSTree()
  }, [projectId])

  const loadWBSTree = async () => {
    try {
      // Mock data - replace with actual API call
      const mockData: WBSNode[] = [
        {
          id: '1',
          code: 'WBS-01',
          name: 'Site Preparation',
          node_type: 'phase',
          level: 1,
          sequence_order: 1,
          budget_allocation: 150000,
          planned_hours: 200,
          is_active: true,
          children: [
            {
              id: '1.1',
              code: 'WBS-01.01',
              name: 'Site Survey',
              node_type: 'deliverable',
              level: 2,
              sequence_order: 1,
              budget_allocation: 25000,
              planned_hours: 40,
              parent_id: '1',
              is_active: true,
              children: [
                {
                  id: '1.1.1',
                  code: 'WBS-01.01.01',
                  name: 'Topographical Survey',
                  node_type: 'work_package',
                  level: 3,
                  sequence_order: 1,
                  budget_allocation: 15000,
                  planned_hours: 24,
                  parent_id: '1.1',
                  is_active: true
                },
                {
                  id: '1.1.2',
                  code: 'WBS-01.01.02',
                  name: 'Soil Testing',
                  node_type: 'work_package',
                  level: 3,
                  sequence_order: 2,
                  budget_allocation: 10000,
                  planned_hours: 16,
                  parent_id: '1.1',
                  is_active: true
                }
              ]
            },
            {
              id: '1.2',
              code: 'WBS-01.02',
              name: 'Site Clearing',
              node_type: 'deliverable',
              level: 2,
              sequence_order: 2,
              budget_allocation: 75000,
              planned_hours: 120,
              parent_id: '1',
              is_active: true
            }
          ]
        },
        {
          id: '2',
          code: 'WBS-02',
          name: 'Foundation Work',
          node_type: 'phase',
          level: 1,
          sequence_order: 2,
          budget_allocation: 400000,
          planned_hours: 600,
          is_active: true,
          children: [
            {
              id: '2.1',
              code: 'WBS-02.01',
              name: 'Excavation',
              node_type: 'deliverable',
              level: 2,
              sequence_order: 1,
              budget_allocation: 120000,
              planned_hours: 180,
              parent_id: '2',
              is_active: true
            },
            {
              id: '2.2',
              code: 'WBS-02.02',
              name: 'Concrete Foundation',
              node_type: 'deliverable',
              level: 2,
              sequence_order: 2,
              budget_allocation: 280000,
              planned_hours: 420,
              parent_id: '2',
              is_active: true
            }
          ]
        }
      ]
      setWbsTree(mockData)
      // Expand first level by default
      setExpandedNodes(new Set(['1', '2']))
    } catch (error) {
      console.error('Failed to load WBS tree:', error)
    } finally {
      setLoading(false)
    }
  }

  const toggleNode = (nodeId: string) => {
    const newExpanded = new Set(expandedNodes)
    if (newExpanded.has(nodeId)) {
      newExpanded.delete(nodeId)
    } else {
      newExpanded.add(nodeId)
    }
    setExpandedNodes(newExpanded)
  }

  const getNodeIcon = (nodeType: string) => {
    switch (nodeType) {
      case 'phase':
        return <FolderOpen className="h-4 w-4 text-blue-600" />
      case 'deliverable':
        return <FileText className="h-4 w-4 text-green-600" />
      case 'work_package':
        return <FileText className="h-4 w-4 text-orange-600" />
      default:
        return <FileText className="h-4 w-4 text-gray-600" />
    }
  }

  const getNodeTypeColor = (nodeType: string) => {
    switch (nodeType) {
      case 'phase':
        return 'bg-blue-100 text-blue-800'
      case 'deliverable':
        return 'bg-green-100 text-green-800'
      case 'work_package':
        return 'bg-orange-100 text-orange-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0
    }).format(amount)
  }

  const renderWBSNode = (node: WBSNode, depth: number = 0) => {
    const hasChildren = node.children && node.children.length > 0
    const isExpanded = expandedNodes.has(node.id)
    const paddingLeft = depth * 24

    return (
      <div key={node.id} className="space-y-2">
        <Card className="hover:shadow-md transition-shadow">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-3" style={{ paddingLeft: `${paddingLeft}px` }}>
                {hasChildren ? (
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => toggleNode(node.id)}
                    className="p-0 h-6 w-6"
                  >
                    {isExpanded ? (
                      <ChevronDown className="h-4 w-4" />
                    ) : (
                      <ChevronRight className="h-4 w-4" />
                    )}
                  </Button>
                ) : (
                  <div className="w-6" />
                )}
                
                {getNodeIcon(node.node_type)}
                
                <div className="flex-1">
                  <div className="flex items-center space-x-2">
                    <h4 className="font-medium">{node.name}</h4>
                    <Badge className={getNodeTypeColor(node.node_type)} variant="secondary">
                      {node.node_type.replace('_', ' ')}
                    </Badge>
                  </div>
                  <p className="text-sm text-gray-600 mt-1">{node.code}</p>
                  {node.description && (
                    <p className="text-sm text-gray-500 mt-1">{node.description}</p>
                  )}
                </div>
              </div>

              <div className="flex items-center space-x-4">
                <div className="text-right">
                  <div className="text-sm font-medium">{formatCurrency(node.budget_allocation)}</div>
                  <div className="text-xs text-gray-500">{node.planned_hours}h planned</div>
                </div>
                
                <div className="flex items-center space-x-1">
                  <Button variant="ghost" size="sm">
                    <Edit className="h-4 w-4" />
                  </Button>
                  <Button variant="ghost" size="sm">
                    <Plus className="h-4 w-4" />
                  </Button>
                  <Button variant="ghost" size="sm" className="text-red-600 hover:text-red-700">
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        {hasChildren && isExpanded && (
          <div className="space-y-2">
            {node.children!.map(child => renderWBSNode(child, depth + 1))}
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
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">Work Breakdown Structure</h1>
          <p className="text-gray-600 mt-1">Hierarchical project structure and budget allocation</p>
        </div>
        <Button>
          <Plus className="h-4 w-4 mr-2" />
          Add WBS Node
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>WBS Tree</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {wbsTree.map(node => renderWBSNode(node))}
          </div>
        </CardContent>
      </Card>

      {wbsTree.length === 0 && (
        <div className="text-center py-12">
          <p className="text-gray-500">No WBS structure defined for this project.</p>
          <Button className="mt-4">
            <Plus className="h-4 w-4 mr-2" />
            Create WBS Structure
          </Button>
        </div>
      )}
    </div>
  )
}