'use client';

import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase-simple';

interface OrgNode {
  id: string;
  code: string;
  name: string;
  type: 'company' | 'controlling' | 'plant' | 'storage' | 'purchasing';
  children?: OrgNode[];
  expanded?: boolean;
  parentId?: string;
}

export default function SAPOrgTree() {
  const [orgTree, setOrgTree] = useState<OrgNode[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    buildOrgTree();
  }, []);

  const buildOrgTree = async () => {
    try {
      const [companies, controlling, plants, storage, purchasing] = await Promise.all([
        supabase.from('company_codes').select('*').order('company_code'),
        supabase.from('controlling_areas').select('*').order('cocarea_code'),
        supabase.from('plants').select('*, company_code').order('plant_code'),
        supabase.from('storage_locations').select('*, plant:plants(plant_code)').order('sloc_code'),
        supabase.from('purchasing_organizations').select('*, company_code').order('porg_code')
      ]);

      const tree: OrgNode[] = [];

      // Build company nodes
      companies.data?.forEach(company => {
        const companyNode: OrgNode = {
          id: company.id,
          code: company.company_code,
          name: company.company_name,
          type: 'company',
          children: [],
          expanded: true
        };

        // Add controlling areas for this company
        controlling.data?.forEach(ca => {
          if (company.controlling_area_code === ca.cocarea_code) {
            companyNode.children?.push({
              id: ca.id,
              code: ca.cocarea_code,
              name: ca.cocarea_name,
              type: 'controlling',
              parentId: company.id
            });
          }
        });

        // Add plants for this company
        plants.data?.forEach(plant => {
          if (plant.company?.company_code === company.company_code) {
            const plantNode: OrgNode = {
              id: plant.id,
              code: plant.plant_code,
              name: plant.plant_name,
              type: 'plant',
              children: [],
              parentId: company.id,
              expanded: false
            };

            // Add storage locations for this plant
            storage.data?.forEach(sloc => {
              if (sloc.plant?.plant_code === plant.plant_code) {
                plantNode.children?.push({
                  id: sloc.id,
                  code: sloc.sloc_code,
                  name: sloc.sloc_name,
                  type: 'storage',
                  parentId: plant.id
                });
              }
            });

            companyNode.children?.push(plantNode);
          }
        });

        // Add purchasing organizations for this company
        purchasing.data?.forEach(porg => {
          if (porg.company?.company_code === company.company_code) {
            companyNode.children?.push({
              id: porg.id,
              code: porg.porg_code,
              name: porg.porg_name,
              type: 'purchasing',
              parentId: company.id
            });
          }
        });

        tree.push(companyNode);
      });

      setOrgTree(tree);
    } catch (error) {
      console.error('Error building org tree:', error);
    } finally {
      setLoading(false);
    }
  };

  const toggleNode = (nodeId: string) => {
    const updateNode = (nodes: OrgNode[]): OrgNode[] => {
      return nodes.map(node => {
        if (node.id === nodeId) {
          return { ...node, expanded: !node.expanded };
        }
        if (node.children) {
          return { ...node, children: updateNode(node.children) };
        }
        return node;
      });
    };
    setOrgTree(updateNode(orgTree));
  };

  const getNodeIcon = (type: string, expanded?: boolean) => {
    switch (type) {
      case 'company': return '🏢';
      case 'controlling': return '📊';
      case 'plant': return '🏭';
      case 'storage': return '📦';
      case 'purchasing': return '🛒';
      default: return '📁';
    }
  };

  const getNodeColor = (type: string) => {
    switch (type) {
      case 'company': return 'text-blue-800 bg-blue-50 border-blue-200';
      case 'controlling': return 'text-green-800 bg-green-50 border-green-200';
      case 'plant': return 'text-purple-800 bg-purple-50 border-purple-200';
      case 'storage': return 'text-orange-800 bg-orange-50 border-orange-200';
      case 'purchasing': return 'text-indigo-800 bg-indigo-50 border-indigo-200';
      default: return 'text-gray-800 bg-gray-50 border-gray-200';
    }
  };

  const renderNode = (node: OrgNode, level: number = 0) => {
    const hasChildren = node.children && node.children.length > 0;
    const indent = level * 24;

    return (
      <div key={node.id} className="select-none">
        <div 
          className={`flex items-center py-2 px-3 hover:bg-gray-100 cursor-pointer border-l-2 ${getNodeColor(node.type)}`}
          style={{ marginLeft: `${indent}px` }}
          onClick={() => hasChildren && toggleNode(node.id)}
        >
          <div className="flex items-center space-x-2 flex-1">
            {hasChildren && (
              <span className="text-gray-400 text-xs">
                {node.expanded ? '▼' : '▶'}
              </span>
            )}
            {!hasChildren && <span className="w-3"></span>}
            
            <span className="text-lg">{getNodeIcon(node.type)}</span>
            
            <div className="flex items-center space-x-2">
              <span className="font-mono text-sm font-bold">{node.code}</span>
              <span className="text-sm">{node.name}</span>
            </div>
          </div>
          
          <span className="text-xs text-gray-500 uppercase">{node.type}</span>
        </div>
        
        {hasChildren && node.expanded && (
          <div>
            {node.children?.map(child => renderNode(child, level + 1))}
          </div>
        )}
      </div>
    );
  };

  if (loading) {
    return (
      <div className="p-6">
        <div className="animate-pulse">
          <div className="h-4 bg-gray-200 rounded w-1/4 mb-4"></div>
          <div className="space-y-2">
            {[...Array(5)].map((_, i) => (
              <div key={i} className="h-8 bg-gray-200 rounded"></div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold">SAP Organizational Structure</h1>
        <p className="text-gray-600">Interactive tree view of the complete organizational hierarchy</p>
      </div>

      <div className="bg-white rounded-lg shadow-sm border">
        <div className="p-4 border-b bg-gray-50">
          <h3 className="font-semibold text-gray-800">Organizational Tree</h3>
          <p className="text-sm text-gray-600">Click on nodes with children to expand/collapse</p>
        </div>
        
        <div className="p-4">
          {orgTree.length > 0 ? (
            <div className="space-y-1">
              {orgTree.map(node => renderNode(node))}
            </div>
          ) : (
            <div className="text-center py-8 text-gray-500">
              <p>No organizational data found</p>
              <p className="text-sm">Please set up company codes, plants, and other organizational units</p>
            </div>
          )}
        </div>
      </div>

      <div className="mt-6 bg-blue-50 border border-blue-200 rounded-lg p-4">
        <h4 className="font-medium text-blue-900 mb-2">SAP Organizational Hierarchy:</h4>
        <div className="text-sm text-blue-800 space-y-1">
          <p>🏢 <strong>Company Code</strong> → Legal entity for financial reporting</p>
          <p>📊 <strong>Controlling Area</strong> → Cost accounting and internal reporting</p>
          <p>🏭 <strong>Plant</strong> → Production and logistics unit</p>
          <p>📦 <strong>Storage Location</strong> → Physical storage within plant</p>
          <p>🛒 <strong>Purchasing Organization</strong> → Procurement responsibility</p>
        </div>
      </div>
    </div>
  );
}