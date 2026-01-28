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
  data?: any;
}

interface ContextMenu {
  show: boolean;
  x: number;
  y: number;
  node: OrgNode | null;
}

export default function SAPOrgTreeCRUD() {
  const [orgTree, setOrgTree] = useState<OrgNode[]>([]);
  const [loading, setLoading] = useState(true);
  const [contextMenu, setContextMenu] = useState<ContextMenu>({ show: false, x: 0, y: 0, node: null });
  const [showModal, setShowModal] = useState(false);
  const [modalType, setModalType] = useState<'create' | 'edit' | 'delete'>('create');
  const [selectedNode, setSelectedNode] = useState<OrgNode | null>(null);
  const [createNodeType, setCreateNodeType] = useState<string>('');
  const [availableControllingAreas, setAvailableControllingAreas] = useState<any[]>([]);
  const [availableCompanies, setAvailableCompanies] = useState<any[]>([]);
  const [availablePlants, setAvailablePlants] = useState<any[]>([]);
  const [availableStorageLocations, setAvailableStorageLocations] = useState<any[]>([]);
  const [availablePurchasingOrgs, setAvailablePurchasingOrgs] = useState<any[]>([]);
  const [createNewControlling, setCreateNewControlling] = useState(false);
  const [createNewPlant, setCreateNewPlant] = useState(false);
  const [createNewStorage, setCreateNewStorage] = useState(false);
  const [createNewPurchasing, setCreateNewPurchasing] = useState(false);

  useEffect(() => {
    buildOrgTree();
  }, []);

  const buildOrgTree = async () => {
    try {
      setLoading(true);
      const [companies, controlling, plants, storage, purchasing] = await Promise.all([
        supabase.from('company_codes').select('*').order('company_code'),
        supabase.from('controlling_areas').select('*').order('cocarea_code'),
        supabase.from('plants').select('*, company_code').order('plant_code'),
        supabase.from('storage_locations').select('*, plant:plants(plant_code)').order('sloc_code'),
        supabase.from('purchasing_organizations').select('*, company_code').order('porg_code')
      ]);

      const tree: OrgNode[] = [];

      companies.data?.forEach(company => {
        const companyNode: OrgNode = {
          id: company.id,
          code: company.company_code,
          name: company.company_name,
          type: 'company',
          children: [],
          expanded: false,
          data: company
        };

        controlling.data?.forEach(ca => {
          if (company.controlling_area_code === ca.cocarea_code) {
            companyNode.children?.push({
              id: ca.id,
              code: ca.cocarea_code,
              name: ca.cocarea_name,
              type: 'controlling',
              parentId: company.id,
              data: ca
            });
          }
        });

        plants.data?.forEach(plant => {
          if (plant.company_code === company.company_code) {
            const plantNode: OrgNode = {
              id: plant.id,
              code: plant.plant_code,
              name: plant.plant_name,
              type: 'plant',
              children: [],
              parentId: company.id,
              expanded: false,
              data: plant
            };

            storage.data?.forEach(sloc => {
              if (sloc.plant_id === plant.id) {
                plantNode.children?.push({
                  id: sloc.id,
                  code: sloc.sloc_code,
                  name: sloc.sloc_name,
                  type: 'storage',
                  parentId: plant.id,
                  data: sloc
                });
              }
            });

            companyNode.children?.push(plantNode);
          }
        });

        purchasing.data?.forEach(porg => {
          if (porg.company_code === company.company_code) {
            companyNode.children?.push({
              id: porg.id,
              code: porg.porg_code,
              name: porg.porg_name,
              type: 'purchasing',
              parentId: company.id,
              data: porg
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

  const handleRightClick = (e: React.MouseEvent, node: OrgNode) => {
    e.preventDefault();
    e.stopPropagation();
    setContextMenu({
      show: true,
      x: e.clientX,
      y: e.clientY,
      node
    });
  };

  const hideContextMenu = () => {
    setContextMenu({ show: false, x: 0, y: 0, node: null });
  };

  const handleCreate = async (parentNode: OrgNode | null, nodeType: string) => {
    setSelectedNode(parentNode);
    setCreateNodeType(nodeType);
    setModalType('create');
    setCreateNewControlling(false);
    setCreateNewPlant(false);
    setCreateNewStorage(false);
    setCreateNewPurchasing(false);
    
    if (nodeType === 'controlling') {
      const { data } = await supabase.from('controlling_areas').select('*').order('cocarea_code');
      setAvailableControllingAreas(data || []);
    } else if (nodeType === 'plant') {
      const [companiesResult, plantsResult] = await Promise.all([
        supabase.from('company_codes').select('*').order('company_code'),
        supabase.from('plants').select('*, company:company_codes!company_code_id(company_code, company_name)').order('plant_code')
      ]);
      setAvailableCompanies(companiesResult.data || []);
      setAvailablePlants(plantsResult.data || []);
    } else if (nodeType === 'storage') {
      const [plantsResult, storageResult] = await Promise.all([
        supabase.from('plants').select('*, company:company_codes!company_code_id(company_code)').order('plant_code'),
        supabase.from('storage_locations').select('*, plant:plants(plant_code)').order('sloc_code')
      ]);
      setAvailablePlants(plantsResult.data || []);
      setAvailableStorageLocations(storageResult.data || []);
    } else if (nodeType === 'purchasing') {
      const [companiesResult, purchasingResult] = await Promise.all([
        supabase.from('company_codes').select('*').order('company_code'),
        supabase.from('purchasing_organizations').select('*, company:company_codes!company_code_id(company_code)').order('porg_code')
      ]);
      setAvailableCompanies(companiesResult.data || []);
      setAvailablePurchasingOrgs(purchasingResult.data || []);
    }
    
    setShowModal(true);
    hideContextMenu();
  };

  const handleEdit = async (node: OrgNode) => {
    setSelectedNode(node);
    setModalType('edit');
    
    if (node.type === 'plant') {
      const { data } = await supabase.from('company_codes').select('*').order('company_code');
      setAvailableCompanies(data || []);
    }
    
    setShowModal(true);
    hideContextMenu();
  };

  const handleDelete = (node: OrgNode) => {
    setSelectedNode(node);
    setModalType('delete');
    setShowModal(true);
    hideContextMenu();
  };

  const getCreateOptions = (node: OrgNode) => {
    switch (node.type) {
      case 'company':
        return ['controlling', 'plant', 'purchasing'];
      case 'plant':
        return ['storage'];
      default:
        return [];
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

  const getNodeIcon = (type: string) => {
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
      <div key={node.id} className="select-none group">
        <div 
          className={`flex items-center py-3 px-4 hover:bg-gray-50 cursor-pointer border-l-4 transition-all duration-200 rounded-r-lg ${getNodeColor(node.type)} group-hover:shadow-sm`}
          style={{ marginLeft: `${indent}px` }}
          onClick={() => hasChildren && toggleNode(node.id)}
          onContextMenu={(e) => handleRightClick(e, node)}
        >
          <div className="flex items-center space-x-3 flex-1">
            {hasChildren && (
              <span className="text-gray-400 text-sm transition-transform duration-200">
                {node.expanded ? '▼' : '▶'}
              </span>
            )}
            {!hasChildren && <span className="w-4"></span>}
            
            <span className="text-xl">{getNodeIcon(node.type)}</span>
            
            <div className="flex items-center space-x-3 flex-1">
              <span className="font-mono text-sm font-bold text-gray-900">{node.code}</span>
              <span className="text-sm text-gray-700 font-medium">{node.name}</span>
            </div>
          </div>
          
          <div className="flex items-center space-x-3 opacity-0 group-hover:opacity-100 transition-opacity duration-200">
            <button
              onClick={(e) => { e.stopPropagation(); handleEdit(node); }}
              className="text-blue-600 hover:text-blue-800 hover:bg-blue-50 p-1.5 rounded-md transition-colors duration-200"
              title="Edit"
            >
              ✏️
            </button>
            <span className="text-xs text-gray-500 uppercase font-medium px-2 py-1 bg-gray-100 rounded-full">{node.type}</span>
          </div>
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
    <div className="min-h-screen bg-gray-50 p-4 sm:p-6">
      <div className="max-w-7xl mx-auto">
        <div className="mb-6 sm:mb-8">
          <div className="flex items-center space-x-3 mb-2">
            <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center">
              <span className="text-white font-bold text-sm">SAP</span>
            </div>
            <h1 className="text-2xl sm:text-3xl font-bold text-gray-900">Organizational Structure</h1>
          </div>
          <p className="text-gray-600 text-sm sm:text-base">Manage your enterprise organizational hierarchy with SAP-style structure</p>
        </div>

        <div className="bg-white rounded-xl shadow-lg border border-gray-200 overflow-hidden">
          <div className="bg-gradient-to-r from-blue-50 to-indigo-50 border-b border-gray-200 p-4 sm:p-6">
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 sm:gap-0">
              <div>
                <h3 className="text-lg font-semibold text-gray-900 mb-1">Organization Tree</h3>
                <div className="flex items-center space-x-4 text-sm text-gray-600">
                  <span className="flex items-center space-x-1">
                    <span className="w-2 h-2 bg-blue-500 rounded-full"></span>
                    <span>Right-click for actions</span>
                  </span>
                  <span className="flex items-center space-x-1">
                    <span>✏️</span>
                    <span>Quick edit</span>
                  </span>
                </div>
              </div>
              <div className="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-3 w-full sm:w-auto">
                <button
                  onClick={() => handleCreate(null, 'company')}
                  className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2.5 rounded-lg text-sm font-medium transition-colors duration-200 flex items-center justify-center space-x-2 shadow-sm"
                >
                  <span className="text-lg">🏢</span>
                  <span>Add Company</span>
                </button>
                <button
                  onClick={() => handleCreate(null, 'plant')}
                  className="bg-green-600 hover:bg-green-700 text-white px-4 py-2.5 rounded-lg text-sm font-medium transition-colors duration-200 flex items-center justify-center space-x-2 shadow-sm"
                >
                  <span className="text-lg">🏭</span>
                  <span>Add Plant</span>
                </button>
              </div>
            </div>
          </div>
          
          <div className="p-4 sm:p-6" onClick={hideContextMenu}>
            {orgTree.length > 0 ? (
              <div className="space-y-1">
                {orgTree.map(node => renderNode(node))}
              </div>
            ) : (
              <div className="text-center py-12 sm:py-16">
                <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <span className="text-2xl">🏢</span>
                </div>
                <h3 className="text-lg font-medium text-gray-900 mb-2">No Organizations Found</h3>
                <p className="text-gray-500 mb-6 max-w-sm mx-auto">Get started by creating your first company or plant to build your organizational structure.</p>
                <div className="flex flex-col sm:flex-row gap-3 justify-center">
                  <button
                    onClick={() => handleCreate(null, 'company')}
                    className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-3 rounded-lg font-medium transition-colors duration-200 flex items-center justify-center space-x-2 shadow-sm"
                  >
                    <span>🏢</span>
                    <span>Create Company</span>
                  </button>
                  <button
                    onClick={() => handleCreate(null, 'plant')}
                    className="bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg font-medium transition-colors duration-200 flex items-center justify-center space-x-2 shadow-sm"
                  >
                    <span>🏭</span>
                    <span>Create Plant</span>
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Context Menu */}
        {contextMenu.show && (
          <>
            <div className="fixed inset-0 z-40" onClick={hideContextMenu} />
            <div
              className="fixed bg-white border shadow-lg rounded-md py-2 z-50"
              style={{ left: contextMenu.x, top: contextMenu.y }}
            >
              <button
                onClick={() => handleEdit(contextMenu.node!)}
                className="block w-full text-left px-4 py-2 text-sm hover:bg-gray-100"
              >
                ✏️ Edit {contextMenu.node?.type}
              </button>
              
              {getCreateOptions(contextMenu.node!).map(type => (
                <button
                  key={type}
                  onClick={() => handleCreate(contextMenu.node!, type)}
                  className="block w-full text-left px-4 py-2 text-sm hover:bg-gray-100"
                >
                  ➕ Add {type}
                </button>
              ))}
              
              <hr className="my-1" />
              <button
                onClick={() => handleDelete(contextMenu.node!)}
                className="block w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50"
              >
                🗑️ Delete {contextMenu.node?.type}
              </button>
            </div>
          </>
        )}

        {/* Modal */}
        {showModal && (
          <div className="fixed inset-0 bg-black bg-opacity-50 backdrop-blur-sm flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg max-h-[90vh] overflow-hidden">
              <div className="bg-gradient-to-r from-blue-50 to-indigo-50 px-6 py-4 border-b border-gray-200">
                <h3 className="text-xl font-semibold text-gray-900">
                  {modalType === 'create' && `Create ${createNodeType || 'Organization'}`}
                  {modalType === 'edit' && `Edit ${selectedNode?.type}`}
                  {modalType === 'delete' && `Delete ${selectedNode?.type}`}
                </h3>
                {modalType !== 'delete' && (
                  <p className="text-sm text-gray-600 mt-1">
                    {modalType === 'create' ? 'Add a new organizational unit to your structure' : 'Update the organizational unit details'}
                  </p>
                )}
              </div>
              
              <div className="p-6 overflow-y-auto max-h-[calc(90vh-120px)]">
                {modalType === 'delete' ? (
                  <div className="text-center">
                    <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
                      <span className="text-2xl">⚠️</span>
                    </div>
                    <h4 className="text-lg font-semibold text-gray-900 mb-2">Confirm Deletion</h4>
                    <p className="text-gray-600 mb-6">
                      Are you sure you want to delete <strong className="text-gray-900">{selectedNode?.code} - {selectedNode?.name}</strong>? This action cannot be undone.
                    </p>
                    <div className="flex flex-col sm:flex-row justify-center space-y-3 sm:space-y-0 sm:space-x-3">
                      <button
                        onClick={() => setShowModal(false)}
                        className="px-6 py-2.5 text-gray-700 bg-gray-100 hover:bg-gray-200 border border-gray-300 rounded-lg font-medium transition-colors duration-200"
                      >
                        Cancel
                      </button>
                      <button
                        onClick={async () => {
                          try {
                            let error;
                            if (selectedNode?.type === 'company') {
                              ({ error } = await supabase.from('company_codes').delete().eq('id', selectedNode.id));
                            } else if (selectedNode?.type === 'controlling') {
                              ({ error } = await supabase.from('controlling_areas').delete().eq('id', selectedNode.id));
                            } else if (selectedNode?.type === 'plant') {
                              ({ error } = await supabase.from('plants').delete().eq('id', selectedNode.id));
                            } else if (selectedNode?.type === 'storage') {
                              ({ error } = await supabase.from('storage_locations').delete().eq('id', selectedNode.id));
                            } else if (selectedNode?.type === 'purchasing') {
                              ({ error } = await supabase.from('purchasing_organizations').delete().eq('id', selectedNode.id));
                            }
                            
                            if (error) throw error;
                            setShowModal(false);
                            buildOrgTree();
                          } catch (error: any) {
                            alert(`Error deleting: ${error.message}`);
                          }
                        }}
                        className="px-6 py-2.5 bg-red-600 hover:bg-red-700 text-white rounded-lg font-medium transition-colors duration-200 shadow-sm"
                      >
                        Delete Permanently
                      </button>
                    </div>
                  </div>
                                ) : (
                  <form onSubmit={async (e) => {
                    e.preventDefault();
                    const formData = new FormData(e.currentTarget);
                    const code = formData.get('code') as string;
                    const name = formData.get('name') as string;
                    const legalEntity = formData.get('legal_entity') as string;
                    const currency = formData.get('currency') as string;
                    const country = formData.get('country') as string;
                    const address = formData.get('address') as string;
                    const taxNumber = formData.get('tax_number') as string;
                    
                    try {
                      if (modalType === 'create') {
                        if (createNodeType === 'company') {
                          const { error } = await supabase.from('company_codes').insert({
                            company_code: code,
                            company_name: name,
                            legal_entity_name: legalEntity || name,
                            currency: currency || 'INR',
                            country: country || 'IN',
                            address: address || null,
                            tax_number: taxNumber || null,
                            is_active: true
                          });
                          if (error) throw error;
                        } else if (createNodeType === 'controlling') {
                          if (createNewControlling) {
                            const { data: newCA, error } = await supabase.from('controlling_areas').insert({
                              cocarea_code: code,
                              cocarea_name: name,
                              currency: currency || 'INR',
                              fiscal_year_variant: formData.get('fiscal_year_variant') || 'K4',
                              is_active: true
                            }).select().single();
                            if (error) throw error;
                            
                            await supabase.from('company_codes').update({
                              controlling_area_code: code
                            }).eq('id', selectedNode?.id);
                          } else {
                            const existingCACode = formData.get('existing_controlling') as string;
                            await supabase.from('company_codes').update({
                              controlling_area_code: existingCACode
                            }).eq('id', selectedNode?.id);
                          }
                        } else if (createNodeType === 'plant') {
                          if (createNewPlant) {
                            const companyId = selectedNode?.id || formData.get('company_id') as string;
                            const { error } = await supabase.from('plants').insert({
                              company_code: selectedNode?.data?.company_code || formData.get('company_code') as string,
                              plant_code: code,
                              plant_name: name,
                              plant_type: formData.get('plant_type') || 'PROJECT',
                              address: address || null,
                              is_active: true
                            });
                            if (error) throw error;
                          } else {
                            const existingPlantId = formData.get('existing_plant') as string;
                            console.log('Selected existing plant:', existingPlantId);
                          }
                        } else if (createNodeType === 'storage') {
                          if (createNewStorage) {
                            const plantId = selectedNode?.id || formData.get('plant_id') as string;
                            const { error } = await supabase.from('storage_locations').insert({
                              plant_id: plantId,
                              sloc_code: code,
                              sloc_name: name,
                              location_type: formData.get('location_type') || 'WAREHOUSE',
                              is_active: true
                            });
                            if (error) throw error;
                          } else {
                            const existingStorageId = formData.get('existing_storage') as string;
                            console.log('Selected existing storage:', existingStorageId);
                          }
                        } else if (createNodeType === 'purchasing') {
                          if (createNewPurchasing) {
                            const { error } = await supabase.from('purchasing_organizations').insert({
                              company_code: selectedNode?.data?.company_code,
                              porg_code: code,
                              porg_name: name,
                              is_active: true
                            });
                            if (error) throw error;
                          } else {
                            const existingPurchasingId = formData.get('existing_purchasing') as string;
                            console.log('Selected existing purchasing:', existingPurchasingId);
                          }
                        }
                      } else if (modalType === 'edit') {
                        if (selectedNode?.type === 'company') {
                          const { error } = await supabase.from('company_codes').update({
                            company_code: code,
                            company_name: name,
                            legal_entity_name: legalEntity || name,
                            currency: currency || 'INR',
                            country: country || 'IN',
                            address: address || null,
                            tax_number: taxNumber || null
                          }).eq('id', selectedNode.id);
                          if (error) throw error;
                        } else if (selectedNode?.type === 'controlling') {
                          const { error } = await supabase.from('controlling_areas').update({
                            cocarea_code: code,
                            cocarea_name: name,
                            currency: currency || 'INR'
                          }).eq('id', selectedNode.id);
                          if (error) throw error;
                        } else if (selectedNode?.type === 'plant') {
                          const { error } = await supabase.from('plants').update({
                            plant_code: code,
                            plant_name: name,
                            plant_type: formData.get('plant_type') || 'PROJECT',
                            address: address || null
                          }).eq('id', selectedNode.id);
                          if (error) throw error;
                        } else if (selectedNode?.type === 'storage') {
                          const { error } = await supabase.from('storage_locations').update({
                            sloc_code: code,
                            sloc_name: name,
                            location_type: formData.get('location_type') || 'WAREHOUSE'
                          }).eq('id', selectedNode.id);
                          if (error) throw error;
                        } else if (selectedNode?.type === 'purchasing') {
                          const { error } = await supabase.from('purchasing_organizations').update({
                            porg_code: code,
                            porg_name: name
                          }).eq('id', selectedNode.id);
                          if (error) throw error;
                        }
                      }
                      
                      setShowModal(false);
                      buildOrgTree();
                    } catch (error: any) {
                      console.error('Error:', error);
                      alert(`Error: ${error.message || 'Unknown error'}`);
                    }
                  }}>
                    <div className="space-y-4">
                      {/* Company Code Display for child nodes */}
                      {selectedNode && createNodeType !== 'company' && modalType === 'create' && (
                        <div>
                          <label className="block text-sm font-medium mb-1">
                            {createNodeType === 'storage' ? 'Plant Code' : 'Company Code'}
                          </label>
                          <input
                            type="text"
                            value={selectedNode.code}
                            className="w-full border rounded px-3 py-2 bg-gray-50 font-mono"
                            disabled
                          />
                        </div>
                      )}
                      
                      {/* Controlling Area Selection */}
                      {createNodeType === 'controlling' && (
                        <div className="space-y-3">
                          <div>
                            <label className="block text-sm font-medium mb-2">Controlling Area Assignment</label>
                            <div className="space-y-2">
                              <label className="flex items-center p-2 border rounded-lg hover:bg-gray-50 cursor-pointer">
                                <input
                                  type="radio"
                                  name="controlling_option"
                                  checked={createNewControlling}
                                  onChange={() => setCreateNewControlling(true)}
                                  className="mr-3 h-4 w-4"
                                />
                                <span className="text-sm">Create New Controlling Area</span>
                              </label>
                              <label className="flex items-center p-2 border rounded-lg hover:bg-gray-50 cursor-pointer">
                                <input
                                  type="radio"
                                  name="controlling_option"
                                  checked={!createNewControlling}
                                  onChange={() => setCreateNewControlling(false)}
                                  className="mr-3 h-4 w-4"
                                />
                                <span className="text-sm">Use Existing Controlling Area</span>
                              </label>
                            </div>
                          </div>
                          
                          {!createNewControlling && (
                            <div>
                              <label className="block text-sm font-medium mb-1">Select Controlling Area *</label>
                              <select
                                name="existing_controlling"
                                className="w-full border rounded px-3 py-2 text-sm"
                                required
                              >
                                <option value="">Select existing controlling area</option>
                                {availableControllingAreas.map(ca => (
                                  <option key={ca.id} value={ca.cocarea_code}>
                                    {ca.cocarea_code} - {ca.cocarea_name}
                                  </option>
                                ))}
                              </select>
                            </div>
                          )}
                        </div>
                      )}
                      
                      {/* Plant Selection */}
                      {createNodeType === 'plant' && (
                        <div className="space-y-3">
                          <div>
                            <label className="block text-sm font-medium mb-2">Plant Assignment</label>
                            <div className="space-y-2">
                              <label className="flex items-center p-2 border rounded-lg hover:bg-gray-50 cursor-pointer">
                                <input
                                  type="radio"
                                  name="plant_option"
                                  checked={createNewPlant}
                                  onChange={() => setCreateNewPlant(true)}
                                  className="mr-3 h-4 w-4"
                                />
                                <span className="text-sm">Create New Plant</span>
                              </label>
                              <label className="flex items-center p-2 border rounded-lg hover:bg-gray-50 cursor-pointer">
                                <input
                                  type="radio"
                                  name="plant_option"
                                  checked={!createNewPlant}
                                  onChange={() => setCreateNewPlant(false)}
                                  className="mr-3 h-4 w-4"
                                />
                                <span className="text-sm">Use Existing Plant</span>
                              </label>
                            </div>
                          </div>
                          
                          {!createNewPlant && (
                            <div>
                              <label className="block text-sm font-medium mb-1">Select Plant *</label>
                              <select
                                name="existing_plant"
                                className="w-full border rounded px-3 py-2 text-sm"
                                required
                              >
                                <option value="">Select existing plant</option>
                                {availablePlants.map(plant => (
                                  <option key={plant.id} value={plant.id}>
                                    {plant.plant_code} - {plant.plant_name}
                                  </option>
                                ))}
                              </select>
                            </div>
                          )}
                        </div>
                      )}
                      
                      {/* Storage Location Selection */}
                      {createNodeType === 'storage' && (
                        <div className="space-y-3">
                          <div>
                            <label className="block text-sm font-medium mb-2">Storage Location Assignment</label>
                            <div className="space-y-2">
                              <label className="flex items-center p-2 border rounded-lg hover:bg-gray-50 cursor-pointer">
                                <input
                                  type="radio"
                                  name="storage_option"
                                  checked={createNewStorage}
                                  onChange={() => setCreateNewStorage(true)}
                                  className="mr-3 h-4 w-4"
                                />
                                <span className="text-sm">Create New Storage Location</span>
                              </label>
                              <label className="flex items-center p-2 border rounded-lg hover:bg-gray-50 cursor-pointer">
                                <input
                                  type="radio"
                                  name="storage_option"
                                  checked={!createNewStorage}
                                  onChange={() => setCreateNewStorage(false)}
                                  className="mr-3 h-4 w-4"
                                />
                                <span className="text-sm">Use Existing Storage Location</span>
                              </label>
                            </div>
                          </div>
                          
                          {!createNewStorage && (
                            <div>
                              <label className="block text-sm font-medium mb-1">Select Storage Location *</label>
                              <select
                                name="existing_storage"
                                className="w-full border rounded px-3 py-2 text-sm"
                                required
                              >
                                <option value="">Select existing storage location</option>
                                {availableStorageLocations.map(sloc => (
                                  <option key={sloc.id} value={sloc.id}>
                                    {sloc.sloc_code} - {sloc.sloc_name}
                                  </option>
                                ))}
                              </select>
                            </div>
                          )}
                        </div>
                      )}
                      
                      {/* Purchasing Organization Selection */}
                      {createNodeType === 'purchasing' && (
                        <div className="space-y-3">
                          <div>
                            <label className="block text-sm font-medium mb-2">Purchasing Organization Assignment</label>
                            <div className="space-y-2">
                              <label className="flex items-center p-2 border rounded-lg hover:bg-gray-50 cursor-pointer">
                                <input
                                  type="radio"
                                  name="purchasing_option"
                                  checked={createNewPurchasing}
                                  onChange={() => setCreateNewPurchasing(true)}
                                  className="mr-3 h-4 w-4"
                                />
                                <span className="text-sm">Create New Purchasing Organization</span>
                              </label>
                              <label className="flex items-center p-2 border rounded-lg hover:bg-gray-50 cursor-pointer">
                                <input
                                  type="radio"
                                  name="purchasing_option"
                                  checked={!createNewPurchasing}
                                  onChange={() => setCreateNewPurchasing(false)}
                                  className="mr-3 h-4 w-4"
                                />
                                <span className="text-sm">Use Existing Purchasing Organization</span>
                              </label>
                            </div>
                          </div>
                          
                          {!createNewPurchasing && (
                            <div>
                              <label className="block text-sm font-medium mb-1">Select Purchasing Organization *</label>
                              <select
                                name="existing_purchasing"
                                className="w-full border rounded px-3 py-2 text-sm"
                                required
                              >
                                <option value="">Select existing purchasing organization</option>
                                {availablePurchasingOrgs.map(porg => (
                                  <option key={porg.id} value={porg.id}>
                                    {porg.porg_code} - {porg.porg_name}
                                  </option>
                                ))}
                              </select>
                            </div>
                          )}
                        </div>
                      )}
                      
                      {/* Standard fields for new entries or other types */}
                      {(createNodeType !== 'controlling' || createNewControlling) &&
                       (createNodeType !== 'plant' || createNewPlant) &&
                       (createNodeType !== 'storage' || createNewStorage) &&
                       (createNodeType !== 'purchasing' || createNewPurchasing) && (
                        <>
                      
                      <div>
                        <label className="block text-sm font-medium mb-1">
                          {createNodeType === 'storage' ? 'Storage Location Code' :
                           createNodeType === 'company' ? 'Company Code' :
                           createNodeType === 'controlling' ? 'Controlling Area Code' :
                           createNodeType === 'plant' ? 'Plant Code' :
                           createNodeType === 'purchasing' ? 'Purchasing Org Code' :
                           selectedNode?.type === 'storage' ? 'Storage Location Code' :
                           selectedNode?.type === 'company' ? 'Company Code' :
                           selectedNode?.type === 'controlling' ? 'Controlling Area Code' :
                           selectedNode?.type === 'plant' ? 'Plant Code' :
                           selectedNode?.type === 'purchasing' ? 'Purchasing Org Code' : 'Code'} *
                        </label>
                        <input
                          name="code"
                          type="text"
                          defaultValue={modalType === 'edit' ? selectedNode?.code : ''}
                          className="w-full border rounded px-3 py-2 font-mono"
                          placeholder={createNodeType === 'storage' || selectedNode?.type === 'storage' ? 'e.g., 0001' : 
                                     createNodeType === 'controlling' || selectedNode?.type === 'controlling' ? 'e.g., 1000' :
                                     'e.g., C001'}
                          maxLength={4}
                          required
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium mb-1">
                          {createNodeType === 'storage' ? 'Storage Location Name' :
                           createNodeType === 'company' ? 'Company Name' :
                           createNodeType === 'controlling' ? 'Controlling Area Name' :
                           createNodeType === 'plant' ? 'Plant Name' :
                           createNodeType === 'purchasing' ? 'Purchasing Organization Name' :
                           selectedNode?.type === 'storage' ? 'Storage Location Name' :
                           selectedNode?.type === 'company' ? 'Company Name' :
                           selectedNode?.type === 'controlling' ? 'Controlling Area Name' :
                           selectedNode?.type === 'plant' ? 'Plant Name' :
                           selectedNode?.type === 'purchasing' ? 'Purchasing Organization Name' : 'Name'} *
                        </label>
                        <input
                          name="name"
                          type="text"
                          defaultValue={modalType === 'edit' ? selectedNode?.name : ''}
                          className="w-full border rounded px-3 py-2"
                          placeholder="Descriptive name"
                          required
                        />
                      </div>
                      
                      {/* Currency for Company and Controlling only - exclude purchasing */}
                      {((createNodeType === 'company' || selectedNode?.type === 'company') ||
                        (createNodeType === 'controlling' || selectedNode?.type === 'controlling')) &&
                        createNodeType !== 'purchasing' && selectedNode?.type !== 'purchasing' && (
                        <div>
                          <label className="block text-sm font-medium mb-1">Currency *</label>
                          <select
                            name="currency"
                            className="w-full border rounded px-3 py-2"
                            defaultValue={modalType === 'edit' ? selectedNode?.data?.currency : 'INR'}
                            required
                          >
                            <option value="INR">INR - Indian Rupee</option>
                            <option value="USD">USD - US Dollar</option>
                            <option value="EUR">EUR - Euro</option>
                            <option value="GBP">GBP - British Pound</option>
                            <option value="AED">AED - UAE Dirham</option>
                            <option value="SAR">SAR - Saudi Riyal</option>
                          </select>
                        </div>
                      )}
                      {/* Plant Type */}
                      {(createNodeType === 'plant' || selectedNode?.type === 'plant') && (
                        <div>
                          <label className="block text-sm font-medium mb-1">Plant Type *</label>
                          <select
                            name="plant_type"
                            defaultValue={modalType === 'edit' ? selectedNode?.data?.plant_type : 'PROJECT'}
                            className="w-full border rounded px-3 py-2"
                            required
                          >
                            <option value="PROJECT">Project Site</option>
                            <option value="WAREHOUSE">Warehouse</option>
                            <option value="OFFICE">Office</option>
                          </select>
                        </div>
                      )}
                      
                      {/* Address for Company and Plant only - exclude purchasing */}
                      {((createNodeType === 'company' || selectedNode?.type === 'company') ||
                        (createNodeType === 'plant' || selectedNode?.type === 'plant')) &&
                        createNodeType !== 'purchasing' && selectedNode?.type !== 'purchasing' && (
                        <div>
                          <label className="block text-sm font-medium mb-1">Address</label>
                          <textarea
                            name="address"
                            defaultValue={modalType === 'edit' ? selectedNode?.data?.address : ''}
                            className="w-full border rounded px-3 py-2"
                            rows={3}
                            placeholder="Enter address"
                          />
                        </div>
                      )}
                      
                      {/* Company specific fields only - exclude purchasing */}
                      {(createNodeType === 'company' || selectedNode?.type === 'company') &&
                        createNodeType !== 'purchasing' && selectedNode?.type !== 'purchasing' && (
                        <>
                          <div>
                            <label className="block text-sm font-medium mb-1">Legal Entity Name *</label>
                            <input
                              name="legal_entity"
                              type="text"
                              defaultValue={modalType === 'edit' ? selectedNode?.data?.legal_entity_name : ''}
                              className="w-full border rounded px-3 py-2"
                              placeholder="Legal entity name"
                              required
                            />
                          </div>
                          <div>
                            <label className="block text-sm font-medium mb-1">Country *</label>
                            <select
                              name="country"
                              defaultValue={modalType === 'edit' ? selectedNode?.data?.country : 'IN'}
                              className="w-full border rounded px-3 py-2"
                              required
                            >
                              <option value="IN">India</option>
                              <option value="US">United States</option>
                              <option value="GB">United Kingdom</option>
                              <option value="AE">UAE</option>
                              <option value="SA">Saudi Arabia</option>
                            </select>
                          </div>
                          <div>
                            <label className="block text-sm font-medium mb-1">Tax Number</label>
                            <input
                              name="tax_number"
                              type="text"
                              defaultValue={modalType === 'edit' ? selectedNode?.data?.tax_number : ''}
                              className="w-full border rounded px-3 py-2"
                              placeholder="Tax identification number"
                            />
                          </div>
                        </>
                      )}
                      
                      {/* Storage Location Type */}
                      {(createNodeType === 'storage' || selectedNode?.type === 'storage') && (
                        <div>
                          <label className="block text-sm font-medium mb-1">Location Type *</label>
                          <select
                            name="location_type"
                            defaultValue={modalType === 'edit' ? selectedNode?.data?.location_type : 'WAREHOUSE'}
                            className="w-full border rounded px-3 py-2"
                            required
                          >
                            <option value="WAREHOUSE">Warehouse</option>
                            <option value="YARD">Yard</option>
                            <option value="OFFICE">Office</option>
                            <option value="STAGING">Staging Area</option>
                          </select>
                        </div>
                      )}
                      
                      {/* Controlling Area specific fields */}
                      {(createNodeType === 'controlling' || selectedNode?.type === 'controlling') && (
                        <div>
                          <label className="block text-sm font-medium mb-1">Fiscal Year Variant</label>
                          <select
                            name="fiscal_year_variant"
                            defaultValue={modalType === 'edit' ? selectedNode?.data?.fiscal_year_variant : 'K4'}
                            className="w-full border rounded px-3 py-2"
                          >
                            <option value="K4">K4 - April to March</option>
                            <option value="V3">V3 - January to December</option>
                            <option value="V6">V6 - July to June</option>
                          </select>
                        </div>
                      )}
                        </>
                      )}
                    </div>
                    
                    <div className="flex flex-col sm:flex-row justify-end space-y-3 sm:space-y-0 sm:space-x-3 pt-6 border-t border-gray-200">
                      <button
                        type="button"
                        onClick={() => setShowModal(false)}
                        className="px-6 py-2.5 text-gray-700 bg-gray-100 hover:bg-gray-200 border border-gray-300 rounded-lg font-medium transition-colors duration-200"
                      >
                        Cancel
                      </button>
                      <button
                        type="submit"
                        className="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-medium transition-colors duration-200 shadow-sm"
                      >
                        {modalType === 'create' ? 'Create' : 'Update'}
                      </button>
                    </div>
                  </form>
                )}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}