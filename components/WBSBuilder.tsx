'use client';

import React, { useState, useEffect, useCallback, useMemo } from 'react';
import { supabase } from '../lib/supabase';

interface WBSNode {
  id: string;
  code: string;
  name: string;
  node_type: string;
  level: number;
  sequence_order: number;
  parent_id?: string;
  children?: WBSNode[];
  expanded?: boolean;
  activitiesExpanded?: boolean;
  activities?: Activity[];
}

interface Activity {
  id: string;
  code: string;
  name: string;
  activity_type: string;
  status: string;
  priority: string;
  duration_days: number;
  progress_percentage: number;
  budget_amount: number;
  wbs_node_id: string;
  predecessor_activities?: string[];
  dependency_type?: string;
  lag_days?: number;
  tasks?: Task[];
  tasksExpanded?: boolean;
}

interface Task {
  id: string;
  name: string;
  status: string;
  priority: string;
  activity_id: string;
}

interface DeleteWarning {
  show: boolean;
  nodeId: string;
  nodeName: string;
  hasChildren: boolean;
  hasActivities: boolean;
}

export default function WBSBuilder({ projectId }: { projectId: string }) {
  const [wbsNodes, setWbsNodes] = useState<WBSNode[]>([]);
  const [hierarchicalNodes, setHierarchicalNodes] = useState<WBSNode[]>([]);
  const [selectedItem, setSelectedItem] = useState<{type: 'wbs' | 'activity' | 'task', data: any} | null>(null);
  const [leftPanelWidth, setLeftPanelWidth] = useState(50);
  const [editMode, setEditMode] = useState(false);
  const [editData, setEditData] = useState<any>({});
  const [showTaskForm, setShowTaskForm] = useState(false);
  const [taskForm, setTaskForm] = useState({
    name: '',
    description: '',
    priority: 'medium',
    checklist_item: false
  });
  const [allActivities, setAllActivities] = useState<Activity[]>([]);
  const [allTasks, setAllTasks] = useState<Task[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [showActivityForm, setShowActivityForm] = useState(false);
  const [editingNode, setEditingNode] = useState<WBSNode | null>(null);
  const [activityForm, setActivityForm] = useState({
    code: '',
    name: '',
    activity_type: 'INTERNAL',
    planned_start_date: '',
    duration_days: 1,
    budget_amount: 0,
    priority: 'medium',
    planned_hours: 0,
    cost_rate: 0,
    vendor_id: '',
    rate: 0,
    quantity: 0
  });
  const [editingActivity, setEditingActivity] = useState<any | null>(null);
  const [vendors, setVendors] = useState<any[]>([]);
  const [deleteWarning, setDeleteWarning] = useState<DeleteWarning>({
    show: false,
    nodeId: '',
    nodeName: '',
    hasChildren: false,
    hasActivities: false
  });
  const [formData, setFormData] = useState({
    code: '',
    name: '',
    node_type: 'phase',
    parent_id: ''
  });
  const [error, setError] = useState<string>('');
  const [projectCode, setProjectCode] = useState<string>('');

  useEffect(() => {
    fetchProjectCode();
    fetchVendors();
    fetchAllActivities();
    fetchAllTasks();
    fetchWBS();
  }, [projectId]);

  useEffect(() => {
    if (wbsNodes.length > 0) {
      setHierarchicalNodes(buildHierarchy(wbsNodes));
    }
  }, [allActivities, allTasks, buildHierarchy, wbsNodes]);

  useEffect(() => {
    // Exit edit mode when selection changes
    setEditMode(false);
    setEditData({});
  }, [selectedItem]);

  const fetchVendors = async () => {
    const { data } = await supabase
      .from('vendors')
      .select('id, name, code')
      .eq('status', 'active');
    
    if (data) setVendors(data);
  };

  const fetchAllActivities = async () => {
    const { data } = await supabase
      .from('activities')
      .select('*')
      .eq('project_id', projectId)
      .order('created_at');
    
    if (data) {
      setAllActivities(data);
      return data;
    }
    return [];
  };

  const fetchAllTasks = async () => {
    const { data } = await supabase
      .from('tasks')
      .select('*')
      .eq('project_id', projectId)
      .order('created_at');
    
    if (data) {
      setAllTasks(data);
      return data;
    }
    return [];
  };

  // Using enhanced generateActivityCode from lib/code-generator.ts

  const saveActivity = async (e: React.FormEvent) => {
    e.preventDefault();
    
    const wbsNodeId = selectedItem?.type === 'wbs' ? selectedItem.data.id : 
                     selectedItem?.type === 'activity' ? selectedItem.data.wbs_node_id : null;
    
    if (!wbsNodeId) return;
    
    const activityData: any = {
      project_id: projectId,
      wbs_node_id: wbsNodeId,
      code: activityForm.code,
      name: activityForm.name,
      activity_type: activityForm.activity_type,
      planned_start_date: activityForm.planned_start_date,
      duration_days: activityForm.duration_days,
      budget_amount: activityForm.budget_amount,
      priority: activityForm.priority,
      status: 'not_started',
      progress_percentage: 0,
      direct_labor_cost: 0,
      direct_material_cost: 0,
      direct_equipment_cost: 0,
      direct_subcontract_cost: 0,
      direct_expense_cost: 0
    };

    if (activityForm.activity_type === 'INTERNAL') {
      activityData.planned_hours = activityForm.planned_hours;
      activityData.cost_rate = activityForm.cost_rate;
      activityData.requires_po = false;
    } else {
      activityData.vendor_id = activityForm.vendor_id || null;
      activityData.requires_po = true;
      if (activityForm.activity_type === 'EXTERNAL') {
        activityData.rate = activityForm.rate;
        activityData.quantity = activityForm.quantity;
      }
    }

    let error;
    if (editingActivity) {
      const { error: updateError } = await supabase
        .from('activities')
        .update(activityData)
        .eq('id', editingActivity.id);
      error = updateError;
    } else {
      const { error: insertError } = await supabase
        .from('activities')
        .insert(activityData);
      error = insertError;
    }

    if (!error) {
      resetActivityForm();
      // Force immediate refresh
      const newActivities = await fetchAllActivities();
      const newTasks = await fetchAllTasks();
      // Rebuild hierarchy immediately
      const { data: wbsData } = await supabase
        .from('wbs_nodes')
        .select('*')
        .eq('project_id', projectId)
        .order('level', { ascending: true })
        .order('sequence_order', { ascending: true });
      
      if (wbsData) {
        setWbsNodes(wbsData);
        setHierarchicalNodes(buildHierarchy(wbsData));
      }
    }
  };

  const editActivity = (activity: any) => {
    setEditingActivity(activity);
    setActivityForm({
      code: activity.code,
      name: activity.name,
      activity_type: activity.activity_type,
      planned_start_date: activity.planned_start_date || '',
      duration_days: activity.duration_days || 1,
      budget_amount: activity.budget_amount || 0,
      priority: activity.priority || 'medium',
      planned_hours: activity.planned_hours || 0,
      cost_rate: activity.cost_rate || 0,
      vendor_id: activity.vendor_id || '',
      rate: activity.rate || 0,
      quantity: activity.quantity || 0
    });
    setShowActivityForm(true);
  };

  const deleteActivity = async (activityId: string) => {
    const { error } = await supabase
      .from('activities')
      .delete()
      .eq('id', activityId);

    if (!error) {
      setSelectedItem(null);
      await fetchAllActivities();
      await fetchAllTasks();
      await fetchWBS();
    }
  };

  const resetActivityForm = () => {
    setShowActivityForm(false);
    setEditingActivity(null);
    setActivityForm({
      code: '',
      name: '',
      activity_type: 'INTERNAL',
      planned_start_date: '',
      duration_days: 1,
      budget_amount: 0,
      priority: 'medium',
      planned_hours: 0,
      cost_rate: 0,
      vendor_id: '',
      rate: 0,
      quantity: 0
    });
  };

  const fetchProjectCode = async () => {
    const { data } = await supabase
      .from('projects')
      .select('code')
      .eq('id', projectId)
      .single();
    
    if (data) setProjectCode(data.code);
  };

  const generateWBSCode = (parentId?: string) => {
    const parentNode = parentId ? wbsNodes.find(n => n.id === parentId) : null;
    
    if (parentNode) {
      // Child node: use parent code + sequence
      const siblings = wbsNodes.filter(n => n.parent_id === parentId);
      const nextSequence = siblings.length + 1;
      return `${parentNode.code}.${nextSequence.toString().padStart(2, '0')}`;
    } else {
      // Root node: use project code + sequence
      const rootNodes = wbsNodes.filter(n => !n.parent_id);
      const nextSequence = rootNodes.length + 1;
      return `${projectCode}.${nextSequence.toString().padStart(2, '0')}`;
    }
  };

  const fetchWBS = async () => {
    const { data, error } = await supabase
      .from('wbs_nodes')
      .select('*')
      .eq('project_id', projectId)
      .order('level', { ascending: true })
      .order('sequence_order', { ascending: true });

    if (data) {
      setWbsNodes(data);
      setHierarchicalNodes(buildHierarchy(data));
    }
  };

  const buildHierarchy = useCallback((nodes: WBSNode[]): WBSNode[] => {
    const nodeMap = new Map<string, WBSNode>();
    const rootNodes: WBSNode[] = [];

    // First pass: create all nodes with activities and tasks
    nodes.forEach(node => {
      const nodeActivities = allActivities.filter(a => a.wbs_node_id === node.id).map(activity => ({
        ...activity,
        tasks: allTasks.filter(t => t.activity_id === activity.id),
        tasksExpanded: false
      }));
      
      nodeMap.set(node.id, { 
        ...node, 
        children: [], 
        expanded: false,
        activitiesExpanded: false,
        activities: nodeActivities,
      });
    });

    // Second pass: build hierarchy
    nodes.forEach(node => {
      const nodeWithChildren = nodeMap.get(node.id)!;
      if (node.parent_id) {
        const parent = nodeMap.get(node.parent_id);
        if (parent) {
          parent.children!.push(nodeWithChildren);
        }
      } else {
        rootNodes.push(nodeWithChildren);
      }
    });

    return rootNodes;
  }, [allActivities, allTasks]);

  const toggleNode = useCallback((nodeId: string) => {
    setHierarchicalNodes(prev => {
      const updateExpanded = (nodes: WBSNode[]): WBSNode[] => {
        return nodes.map(node => {
          if (node.id === nodeId) {
            return { ...node, expanded: !node.expanded };
          }
          if (node.children) {
            return { ...node, children: updateExpanded(node.children) };
          }
          return node;
        });
      };
      return updateExpanded(prev);
    });
  }, []);



  const toggleActivities = useCallback((nodeId: string) => {
    setHierarchicalNodes(prev => {
      const updateActivitiesExpanded = (nodes: WBSNode[]): WBSNode[] => {
        return nodes.map(node => {
          if (node.id === nodeId) {
            return { ...node, activitiesExpanded: !node.activitiesExpanded };
          }
          if (node.children) {
            return { ...node, children: updateActivitiesExpanded(node.children) };
          }
          return node;
        });
      };
      return updateActivitiesExpanded(prev);
    });
  }, []);

  const toggleTasks = useCallback((nodeId: string, activityId: string) => {
    setHierarchicalNodes(prev => {
      const updateTasksExpanded = (nodes: WBSNode[]): WBSNode[] => {
        return nodes.map(node => {
          if (node.id === nodeId) {
            const updatedActivities = node.activities?.map(activity => {
              if (activity.id === activityId) {
                return { ...activity, tasksExpanded: !activity.tasksExpanded };
              }
              return activity;
            });
            return { ...node, activities: updatedActivities };
          }
          if (node.children) {
            return { ...node, children: updateTasksExpanded(node.children) };
          }
          return node;
        });
      };
      return updateTasksExpanded(prev);
    });
  }, []);

  const saveWBSNode = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    
    // Check for duplicate code
    const existingCode = wbsNodes.find(n => 
      n.code.toLowerCase() === formData.code.toLowerCase() && 
      (!editingNode || n.id !== editingNode.id)
    );
    
    if (existingCode) {
      setError('WBS code already exists. Please use a unique code.');
      return;
    }
    
    if (editingNode) {
      // Update existing node
      const { error } = await supabase
        .from('wbs_nodes')
        .update({
          code: formData.code,
          name: formData.name,
          node_type: formData.node_type
        })
        .eq('id', editingNode.id);
      
      if (error) {
        setError(error.message);
      } else {
        resetForm();
        fetchWBS();
      }
    } else {
      // Create new node
      const parentNode = formData.parent_id ? wbsNodes.find(n => n.id === formData.parent_id) : null;
      const level = parentNode ? parentNode.level + 1 : 1;
      const maxSequence = wbsNodes.filter(n => n.parent_id === formData.parent_id || (!n.parent_id && !formData.parent_id)).length;

      const { error } = await supabase
        .from('wbs_nodes')
        .insert({
          project_id: projectId,
          code: formData.code,
          name: formData.name,
          node_type: formData.node_type,
          parent_id: formData.parent_id || null,
          level: level,
          sequence_order: maxSequence + 1
        });

      if (error) {
        setError(error.message);
      } else {
        resetForm();
        fetchWBS();
      }
    }
  };

  const editNode = (node: WBSNode) => {
    setEditMode(true);
    setEditData({
      ...node
    });
  };

  const saveInlineEdit = async () => {
    if (!selectedItem || !editMode) return;
    
    if (selectedItem.type === 'wbs') {
      const { error } = await supabase
        .from('wbs_nodes')
        .update({
          name: editData.name,
          node_type: editData.node_type
        })
        .eq('id', selectedItem.data.id);
      
      if (!error) {
        setEditMode(false);
        fetchWBS();
      }
    } else if (selectedItem.type === 'activity') {
      // Prepare update data, excluding computed columns
      const updateData: any = {
        name: editData.name,
        activity_type: editData.activity_type,
        duration_days: parseInt(editData.duration_days) || 1,
        budget_amount: parseFloat(editData.budget_amount) || 0,
        priority: editData.priority,
        status: editData.status,
        progress_percentage: parseInt(editData.progress_percentage) || 0
      };
      
      // Add optional fields only if they have values
      if (editData.planned_start_date) updateData.planned_start_date = editData.planned_start_date;
      if (editData.actual_start_date) updateData.actual_start_date = editData.actual_start_date;
      if (editData.actual_end_date) updateData.actual_end_date = editData.actual_end_date;
      if (editData.actual_duration_days) updateData.actual_duration_days = parseInt(editData.actual_duration_days) || 0;
      if (editData.planned_hours) updateData.planned_hours = parseFloat(editData.planned_hours) || 0;
      if (editData.cost_rate) updateData.cost_rate = parseFloat(editData.cost_rate) || 0;
      if (editData.vendor_id) updateData.vendor_id = editData.vendor_id;
      if (editData.rate) updateData.rate = parseFloat(editData.rate) || 0;
      if (editData.quantity) updateData.quantity = parseFloat(editData.quantity) || 0;
      
      // Add dependency fields
      if (editData.predecessor_activities !== undefined) updateData.predecessor_activities = editData.predecessor_activities;
      if (editData.dependency_type) updateData.dependency_type = editData.dependency_type;
      if (editData.lag_days !== undefined) updateData.lag_days = parseInt(editData.lag_days) || 0;
      
      const { error } = await supabase
        .from('activities')
        .update(updateData)
        .eq('id', selectedItem.data.id);
      
      if (!error) {
        setEditMode(false);
        await fetchAllActivities();
        await fetchWBS();
      } else {
        console.error('Update error:', error);
      }
    } else if (selectedItem.type === 'task') {
      const { error } = await supabase
        .from('tasks')
        .update({
          name: editData.name,
          status: editData.status,
          priority: editData.priority,
          description: editData.description,
          checklist_item: editData.checklist_item,
          daily_logs: editData.daily_logs,
          qa_notes: editData.qa_notes,
          safety_notes: editData.safety_notes
        })
        .eq('id', selectedItem.data.id);
      
      if (!error) {
        setEditMode(false);
        await fetchAllTasks();
        await fetchWBS();
      }
    }
  };

  const cancelInlineEdit = () => {
    setEditMode(false);
    setEditData({});
  };

  const saveTask = async (e: React.FormEvent) => {
    e.preventDefault();
    
    const activityId = selectedItem?.type === 'activity' ? selectedItem.data.id : null;
    if (!activityId) return;
    
    const { error } = await supabase
      .from('tasks')
      .insert({
        project_id: projectId,
        activity_id: activityId,
        name: taskForm.name,
        description: taskForm.description,
        priority: taskForm.priority,
        status: 'not_started',
        checklist_item: taskForm.checklist_item,
        assigned_to: null,
        created_by: null // Fixed: Use null instead of string
      });

    if (!error) {
      resetTaskForm();
      await fetchAllTasks();
      await fetchWBS();
    } else {
      console.error('Task creation error:', error);
    }
  };

  const resetTaskForm = () => {
    setShowTaskForm(false);
    setTaskForm({
      name: '',
      description: '',
      priority: 'medium',
      checklist_item: false
    });
  };

  const checkDeleteWarnings = async (nodeId: string, nodeName: string) => {
    // Check for children
    const { data: children } = await supabase
      .from('wbs_nodes')
      .select('id')
      .eq('parent_id', nodeId);
    
    // Check for activities
    const { data: activities } = await supabase
      .from('activities')
      .select('id')
      .eq('wbs_node_id', nodeId);
    
    setDeleteWarning({
      show: true,
      nodeId,
      nodeName,
      hasChildren: (children?.length || 0) > 0,
      hasActivities: (activities?.length || 0) > 0
    });
  };

  const deleteNode = async () => {
    const { error } = await supabase
      .from('wbs_nodes')
      .delete()
      .eq('id', deleteWarning.nodeId);
    
    if (!error) {
      setDeleteWarning({ show: false, nodeId: '', nodeName: '', hasChildren: false, hasActivities: false });
      fetchWBS();
    }
  };

  const resetForm = () => {
    setShowForm(false);
    setEditingNode(null);
    setFormData({ code: '', name: '', node_type: 'phase', parent_id: '' });
    setError('');
  };

  const getNodeTypeColor = (type: string) => {
    switch (type) {
      case 'project': return 'bg-purple-100 text-purple-800';
      case 'phase': return 'bg-blue-100 text-blue-800';
      case 'deliverable': return 'bg-green-100 text-green-800';
      case 'work_package': return 'bg-orange-100 text-orange-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getNodeIcon = (type: string) => {
    switch (type) {
      case 'project': return '🏗️';
      case 'phase': return '📋';
      case 'deliverable': return '📦';
      case 'work_package': return '📄';
      default: return '📁';
    }
  };

  const getActivityIcon = (type: string) => {
    switch (type) {
      case 'INTERNAL': return '👥';
      case 'EXTERNAL': return '🏢';
      case 'SERVICE': return '⚙️';
      default: return '🔧';
    }
  };

  const getTaskIcon = (status: string) => {
    switch (status) {
      case 'completed': return '✅';
      case 'in_progress': return '🔄';
      case 'on_hold': return '⏸️';
      default: return '📝';
    }
  };

  const TreeNode = React.memo(({ node, level = 0 }: { node: WBSNode; level?: number }) => {
    const hasChildren = node.children && node.children.length > 0;
    const hasActivities = node.activities && node.activities.length > 0;
    const isSelected = selectedItem?.type === 'wbs' && selectedItem?.data.id === node.id;
    
    return (
      <div>
        {/* WBS Node */}
        <div 
          className={`flex items-center py-1.5 px-2 hover:bg-gray-50 cursor-pointer transition-colors duration-150 ${
            isSelected ? 'bg-blue-50 border-l-4 border-blue-500 shadow-sm' : ''
          }`}
          style={{ paddingLeft: `${level * 20 + 8}px` }}
          onClick={() => setSelectedItem({type: 'wbs', data: node})}
        >
          <div className="flex items-center space-x-3 flex-1">
            {/* Expand/Collapse for Children */}
            {hasChildren ? (
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  toggleNode(node.id);
                }}
                className="w-5 h-5 flex items-center justify-center text-gray-400 hover:text-gray-600 transition-colors"
                title="Toggle Child Nodes"
              >
                {node.expanded ? '▼' : '▶'}
              </button>
            ) : (
              <div className="w-5 h-5"></div>
            )}
            
            {/* Activities Toggle */}
            {hasActivities ? (
              <button
                onClick={(e) => {
                  e.stopPropagation();
                  toggleActivities(node.id);
                }}
                className="w-5 h-5 flex items-center justify-center text-blue-500 hover:text-blue-700 transition-colors"
                title="Toggle Activities"
              >
                {node.activitiesExpanded ? '📂' : '📁'}
              </button>
            ) : (
              <div className="w-5 h-5"></div>
            )}
            
            {/* Node Icon */}
            <span className="text-lg" title={`${node.node_type} node`}>
              {getNodeIcon(node.node_type)}
            </span>
            
            {/* Node Code */}
            <span className="font-mono text-xs text-gray-500 bg-gray-100 px-2 py-1 rounded">
              {node.code}
            </span>
            
            {/* Node Name */}
            <span className="text-sm font-medium text-gray-800 truncate flex-1">
              {node.name}
            </span>
            
            {/* Node Type Badge */}
            <span className={`px-2 py-1 rounded-full text-xs font-medium ${getNodeTypeColor(node.node_type)}`}>
              {node.node_type.replace('_', ' ')}
            </span>
          </div>
        </div>
        
        {/* Activities directly under WBS node */}
        {hasActivities && node.activitiesExpanded && (
          <div>
            {node.activities!.map(activity => {
              const isActivitySelected = selectedItem?.type === 'activity' && selectedItem?.data.id === activity.id;
              const hasTasks = activity.tasks && activity.tasks.length > 0;
              
              return (
                <div key={activity.id}>
                  {/* Activity */}
                  <div 
                    className={`flex items-center py-1.5 px-2 hover:bg-green-25 cursor-pointer transition-colors duration-150 ${
                      isActivitySelected ? 'bg-green-50 border-l-4 border-green-500 shadow-sm' : ''
                    }`}
                    style={{ paddingLeft: `${(level + 1) * 20 + 8}px` }}
                    onClick={() => setSelectedItem({type: 'activity', data: activity})}
                  >
                    <div className="flex items-center space-x-3 flex-1">
                      {/* Tasks Toggle */}
                      {hasTasks ? (
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            toggleTasks(node.id, activity.id);
                          }}
                          className="w-4 h-4 flex items-center justify-center text-gray-400 hover:text-gray-600 transition-colors"
                          title="Toggle Tasks"
                        >
                          {activity.tasksExpanded ? '▼' : '▶'}
                        </button>
                      ) : (
                        <div className="w-4 h-4"></div>
                      )}
                      
                      {/* Activity Icon */}
                      <span className="text-base" title={`${activity.activity_type} activity`}>
                        {getActivityIcon(activity.activity_type)}
                      </span>
                      
                      {/* Activity Code */}
                      <span className="font-mono text-xs text-gray-500 bg-green-100 px-2 py-1 rounded">
                        {activity.code}
                      </span>
                      
                      {/* Activity Name */}
                      <span className="text-sm text-gray-700 truncate flex-1">
                        {activity.name}
                      </span>
                      
                      {/* Progress Indicator */}
                      {activity.progress_percentage > 0 && (
                        <div className="flex items-center space-x-1">
                          <div className="w-12 h-2 bg-gray-200 rounded-full overflow-hidden">
                            <div 
                              className="h-full bg-green-500 transition-all duration-300"
                              style={{ width: `${activity.progress_percentage}%` }}
                            ></div>
                          </div>
                          <span className="text-xs text-gray-500">{activity.progress_percentage}%</span>
                        </div>
                      )}
                      
                      {/* Activity Type Badge */}
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                        activity.activity_type === 'INTERNAL' ? 'bg-blue-100 text-blue-700' :
                        activity.activity_type === 'EXTERNAL' ? 'bg-green-100 text-green-700' :
                        'bg-purple-100 text-purple-700'
                      }`}>
                        {activity.activity_type}
                      </span>
                    </div>
                  </div>
                  
                  {/* Tasks under this activity */}
                  {hasTasks && activity.tasksExpanded && (
                    <div>
                      {activity.tasks!.map(task => {
                        const isTaskSelected = selectedItem?.type === 'task' && selectedItem?.data.id === task.id;
                        
                        return (
                          <div 
                            key={task.id}
                            className={`flex items-center py-1 px-2 hover:bg-orange-25 cursor-pointer transition-colors duration-150 ${
                              isTaskSelected ? 'bg-orange-50 border-l-4 border-orange-500 shadow-sm' : ''
                            }`}
                            style={{ paddingLeft: `${(level + 2) * 20 + 8}px` }}
                            onClick={() => setSelectedItem({type: 'task', data: task})}
                          >
                            <div className="flex items-center space-x-3 flex-1">
                              {/* Task Icon */}
                              <span className="text-sm" title={`Task - ${task.status}`}>
                                {getTaskIcon(task.status)}
                              </span>
                              
                              {/* Task Name */}
                              <span className="text-sm text-gray-600 truncate flex-1">
                                {task.name}
                              </span>
                              
                              {/* Priority Indicator */}
                              {task.priority !== 'medium' && (
                                <span className={`w-2 h-2 rounded-full ${
                                  task.priority === 'critical' ? 'bg-red-500' :
                                  task.priority === 'high' ? 'bg-orange-500' :
                                  'bg-blue-500'
                                }`} title={`${task.priority} priority`}></span>
                              )}
                              
                              {/* Status Badge */}
                              <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${
                                task.status === 'completed' ? 'bg-green-100 text-green-700' :
                                task.status === 'in_progress' ? 'bg-blue-100 text-blue-700' :
                                task.status === 'on_hold' ? 'bg-yellow-100 text-yellow-700' :
                                'bg-gray-100 text-gray-700'
                              }`}>
                                {task.status.replace('_', ' ')}
                              </span>
                            </div>
                          </div>
                        );
                      })}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        )}
        
        {/* Child WBS Nodes */}
        {hasChildren && node.expanded && (
          <div>
            {node.children!.map(child => (
              <TreeNode key={child.id} node={child} level={level + 1} />
            ))}
          </div>
        )}
      </div>
    );
  });

  return (
    <div className="flex h-screen">
      {/* Left Panel - WBS Tree */}
      <div className="border-r bg-white" style={{ width: `${leftPanelWidth}%` }}>
        <div className="p-2 border-b bg-gray-50">
          <div className="flex justify-between items-center">
            <div className="flex items-center space-x-2">
              <span className="text-sm font-medium text-gray-700">WBS Structure</span>
              <span className="text-xs text-gray-500">({hierarchicalNodes.length} nodes)</span>
            </div>
            <button
              onClick={() => {
                const newCode = generateWBSCode();
                setFormData({ code: newCode, name: '', node_type: 'phase', parent_id: '' });
                setShowForm(true);
              }}
              className="bg-blue-600 text-white px-2 py-1 rounded text-xs hover:bg-blue-700 flex items-center space-x-1"
            >
              <span>+</span>
              <span>Add</span>
            </button>
          </div>
        </div>
        
        <div className="overflow-y-auto" style={{ height: 'calc(100vh - 60px)' }}>
          {hierarchicalNodes.length > 0 ? (
            <div className="py-1">
              {hierarchicalNodes.map(node => (
                <TreeNode key={node.id} node={node} />
              ))}
            </div>
          ) : (
            <div className="text-center py-8 text-gray-500">
              <p className="mb-3 text-sm">No WBS structure created yet</p>
              <button
                onClick={() => {
                  const newCode = generateWBSCode();
                  setFormData({ code: newCode, name: '', node_type: 'phase', parent_id: '' });
                  setShowForm(true);
                }}
                className="bg-blue-600 text-white px-3 py-1.5 rounded text-sm hover:bg-blue-700"
              >
                Create First Node
              </button>
            </div>
          )}
        </div>
      </div>

      {/* Resizer */}
      <div 
        className="w-1 bg-gray-300 hover:bg-blue-500 cursor-col-resize flex items-center justify-center group"
        onMouseDown={(e) => {
          const startX = e.clientX;
          const startWidth = leftPanelWidth;
          
          const handleMouseMove = (e: MouseEvent) => {
            const deltaX = e.clientX - startX;
            const containerWidth = window.innerWidth;
            const newWidth = startWidth + (deltaX / containerWidth) * 100;
            setLeftPanelWidth(Math.max(20, Math.min(80, newWidth)));
          };
          
          const handleMouseUp = () => {
            document.removeEventListener('mousemove', handleMouseMove);
            document.removeEventListener('mouseup', handleMouseUp);
          };
          
          document.addEventListener('mousemove', handleMouseMove);
          document.addEventListener('mouseup', handleMouseUp);
        }}
      >
        <div className="w-0.5 h-8 bg-gray-400 group-hover:bg-blue-600 rounded"></div>
      </div>

      {/* Right Panel - Item Details */}
      <div className="bg-gray-50" style={{ width: `${100 - leftPanelWidth}%` }}>
        {selectedItem ? (
          <div className="h-full flex flex-col">
            {/* Compact Header with Actions */}
            <div className="bg-white border-b p-2">
              <div className="flex justify-between items-center">
                <div className="flex items-center space-x-3">
                  <div>
                    <h3 className="text-lg font-semibold">{selectedItem.data.name}</h3>
                    <div className="flex items-center space-x-2">
                      <span className="text-xs text-gray-500 font-mono">{selectedItem.data.code || selectedItem.type}</span>
                      {selectedItem.type === 'wbs' && (
                        <span className={`px-2 py-0.5 rounded text-xs ${getNodeTypeColor(selectedItem.data.node_type)}`}>
                          {selectedItem.data.node_type.replace('_', ' ')}
                        </span>
                      )}
                      {selectedItem.type === 'activity' && (
                        <span className={`px-2 py-0.5 rounded text-xs ${
                          selectedItem.data.activity_type === 'INTERNAL' ? 'bg-blue-100 text-blue-800' :
                          selectedItem.data.activity_type === 'EXTERNAL' ? 'bg-green-100 text-green-800' :
                          'bg-purple-100 text-purple-800'
                        }`}>
                          {selectedItem.data.activity_type}
                        </span>
                      )}
                      {selectedItem.type === 'task' && (
                        <span className={`px-2 py-0.5 rounded text-xs ${
                          selectedItem.data.status === 'completed' ? 'bg-green-100 text-green-800' :
                          selectedItem.data.status === 'in_progress' ? 'bg-blue-100 text-blue-800' :
                          'bg-gray-100 text-gray-800'
                        }`}>
                          {selectedItem.data.status}
                        </span>
                      )}
                    </div>
                  </div>
                </div>
                
                {/* Compact Action Icons */}
                <div className="flex space-x-1">
                  {selectedItem.type === 'wbs' && (
                    <>
                      <button 
                        onClick={() => {
                          const newCode = generateWBSCode(selectedItem.data.id);
                          setFormData({ code: newCode, name: '', node_type: 'phase', parent_id: selectedItem.data.id });
                          setShowForm(true);
                        }}
                        className="p-1.5 text-blue-600 hover:bg-blue-50 rounded text-sm"
                        title="Add Child WBS"
                      >
                        📁+
                      </button>
                      <button 
                        onClick={async () => {
                          // Import and use the generateActivityCode function
                          const { generateActivityCode } = await import('../lib/code-generator');
                          const newCode = await generateActivityCode(projectId, selectedItem.data.id);
                          setActivityForm({ 
                            code: newCode, 
                            name: '', 
                            activity_type: 'INTERNAL',
                            planned_start_date: '',
                            duration_days: 1,
                            budget_amount: 0,
                            priority: 'medium',
                            planned_hours: 0,
                            cost_rate: 0,
                            vendor_id: '',
                            rate: 0,
                            quantity: 0
                          });
                          setShowActivityForm(true);
                        }}
                        className="p-1.5 text-green-600 hover:bg-green-50 rounded text-sm"
                        title="Add Activity"
                      >
                        🔧+
                      </button>
                      {!editMode ? (
                        <button 
                          onClick={() => {
                            setEditMode(true);
                            setEditData({...selectedItem.data});
                          }}
                          className="p-1.5 text-yellow-600 hover:bg-yellow-50 rounded text-sm"
                          title="Edit WBS"
                        >
                          ✏️
                        </button>
                      ) : (
                        <>
                          <button 
                            onClick={saveInlineEdit}
                            className="p-1.5 text-green-600 hover:bg-green-50 rounded text-sm"
                            title="Save Changes"
                          >
                            ✅
                          </button>
                          <button 
                            onClick={cancelInlineEdit}
                            className="p-1.5 text-red-600 hover:bg-red-50 rounded text-sm"
                            title="Cancel Edit"
                          >
                            ❌
                          </button>
                        </>
                      )}
                      <button 
                        onClick={() => checkDeleteWarnings(selectedItem.data.id, selectedItem.data.name)}
                        className="p-1.5 text-red-600 hover:bg-red-50 rounded text-sm"
                        title="Delete WBS"
                      >
                        🗑️
                      </button>
                    </>
                  )}
                  {selectedItem.type === 'activity' && (
                    <>
                      <button 
                        onClick={() => setShowTaskForm(true)}
                        className="p-1.5 text-purple-600 hover:bg-purple-50 rounded text-sm"
                        title="Add Task"
                      >
                        📝+
                      </button>
                      {!editMode ? (
                        <button 
                          onClick={() => {
                            setEditMode(true);
                            setEditData({...selectedItem.data});
                          }}
                          className="p-1.5 text-blue-600 hover:bg-blue-50 rounded text-sm"
                          title="Edit Activity"
                        >
                          ✏️
                        </button>
                      ) : (
                        <>
                          <button 
                            onClick={saveInlineEdit}
                            className="p-1.5 text-green-600 hover:bg-green-50 rounded text-sm"
                            title="Save Changes"
                          >
                            ✅
                          </button>
                          <button 
                            onClick={cancelInlineEdit}
                            className="p-1.5 text-red-600 hover:bg-red-50 rounded text-sm"
                            title="Cancel Edit"
                          >
                            ❌
                          </button>
                        </>
                      )}
                      <button 
                        onClick={() => {
                          if (confirm(`Delete activity "${selectedItem.data.name}"?`)) {
                            deleteActivity(selectedItem.data.id);
                          }
                        }}
                        className="p-1.5 text-red-600 hover:bg-red-50 rounded text-sm"
                        title="Delete Activity"
                      >
                        🗑️
                      </button>
                    </>
                  )}
                </div>
              </div>
            </div>

            {/* Content Area */}
            <div className="flex-1 overflow-y-auto p-2">
              <div className="bg-white rounded-lg p-3 shadow-sm">
                {selectedItem.type === 'wbs' && (
                  <div className="space-y-6">
                    <div className="grid grid-cols-2 gap-4 text-sm">
                      <div>
                        <label className="text-gray-600 font-medium">WBS Code</label>
                        <p className="font-mono text-lg">{selectedItem.data.code}</p>
                      </div>
                      <div>
                        <label className="text-gray-600 font-medium">Node Type</label>
                        {editMode ? (
                          <select
                            value={editData.node_type || ''}
                            onChange={(e) => setEditData({...editData, node_type: e.target.value})}
                            className="w-full border rounded px-3 py-2 font-medium"
                          >
                            <option value="phase">Phase</option>
                            <option value="deliverable">Deliverable</option>
                            <option value="work_package">Work Package</option>
                          </select>
                        ) : (
                          <p className="font-medium capitalize">{selectedItem.data.node_type.replace('_', ' ')}</p>
                        )}
                      </div>
                      <div>
                        <label className="text-gray-600 font-medium">Level</label>
                        <p className="font-medium">{selectedItem.data.level}</p>
                      </div>
                      <div>
                        <label className="text-gray-600 font-medium">Sequence Order</label>
                        <p className="font-medium">{selectedItem.data.sequence_order}</p>
                      </div>
                      <div>
                        <label className="text-gray-600 font-medium">Parent WBS</label>
                        <p className="font-medium">{selectedItem.data.parent_id ? 
                          wbsNodes.find(n => n.id === selectedItem.data.parent_id)?.code || 'Unknown' : 
                          'Root Level'
                        }</p>
                      </div>
                      <div>
                        <label className="text-gray-600 font-medium">Activities Count</label>
                        <p className="font-medium">{selectedItem.data.activities?.length || 0}</p>
                      </div>
                    </div>
                    
                    <div>
                      <label className="text-gray-600 font-medium">WBS Name</label>
                      {editMode ? (
                        <input
                          type="text"
                          value={editData.name || ''}
                          onChange={(e) => setEditData({...editData, name: e.target.value})}
                          className="w-full border rounded px-3 py-2 mt-1 text-lg font-medium"
                        />
                      ) : (
                        <p className="font-medium text-lg mt-1">{selectedItem.data.name}</p>
                      )}
                    </div>
                    
                    <div className="grid grid-cols-2 gap-4 text-sm">
                      <div>
                        <label className="text-gray-600 font-medium">Direct Cost Total</label>
                        <p className="font-medium text-green-600">${(selectedItem.data.wbs_direct_cost_total || 0).toLocaleString()}</p>
                      </div>
                      <div>
                        <label className="text-gray-600 font-medium">Indirect Cost Allocated</label>
                        <p className="font-medium text-blue-600">${(selectedItem.data.wbs_indirect_cost_allocated || 0).toLocaleString()}</p>
                      </div>
                    </div>
                    
                    {selectedItem.data.activities && selectedItem.data.activities.length > 0 && (
                      <div>
                        <label className="text-gray-600 font-medium">Activities Summary</label>
                        <div className="mt-2 space-y-1">
                          {selectedItem.data.activities.map(activity => (
                            <div key={activity.id} className="flex justify-between items-center p-2 bg-gray-50 rounded">
                              <span className="font-mono text-xs">{activity.code}</span>
                              <span className="text-sm truncate mx-2">{activity.name}</span>
                              <span className={`px-2 py-1 rounded text-xs ${
                                activity.activity_type === 'INTERNAL' ? 'bg-blue-100 text-blue-800' :
                                activity.activity_type === 'EXTERNAL' ? 'bg-green-100 text-green-800' :
                                'bg-purple-100 text-purple-800'
                              }`}>
                                {activity.activity_type}
                              </span>
                            </div>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                )}
                
                {selectedItem.type === 'activity' && (
                  <div className="space-y-6">
                    <div className="grid grid-cols-2 gap-4 text-sm">
                      <div>
                        <label className="text-gray-600 font-medium">Activity Code</label>
                        <p className="font-mono text-lg">{selectedItem.data.code}</p>
                      </div>
                      <div>
                        <label className="text-gray-600 font-medium">Activity Type</label>
                        {editMode ? (
                          <select
                            value={editData.activity_type || ''}
                            onChange={(e) => setEditData({...editData, activity_type: e.target.value})}
                            className="w-full border rounded px-3 py-2 font-medium"
                          >
                            <option value="INTERNAL">Internal Team</option>
                            <option value="EXTERNAL">External Vendor</option>
                            <option value="SERVICE">Service</option>
                          </select>
                        ) : (
                          <p className="font-medium">{selectedItem.data.activity_type}</p>
                        )}
                      </div>
                      <div>
                        <label className="text-gray-600 font-medium">Status</label>
                        {editMode ? (
                          <select
                            value={editData.status || ''}
                            onChange={(e) => setEditData({...editData, status: e.target.value})}
                            className="w-full border rounded px-3 py-2 font-medium"
                          >
                            <option value="not_started">Not Started</option>
                            <option value="in_progress">In Progress</option>
                            <option value="completed">Completed</option>
                            <option value="on_hold">On Hold</option>
                          </select>
                        ) : (
                          <p className="font-medium capitalize">{selectedItem.data.status?.replace('_', ' ')}</p>
                        )}
                      </div>
                      <div>
                        <label className="text-gray-600 font-medium">Priority</label>
                        {editMode ? (
                          <select
                            value={editData.priority || ''}
                            onChange={(e) => setEditData({...editData, priority: e.target.value})}
                            className="w-full border rounded px-3 py-2 font-medium"
                          >
                            <option value="low">Low</option>
                            <option value="medium">Medium</option>
                            <option value="high">High</option>
                            <option value="critical">Critical</option>
                          </select>
                        ) : (
                          <p className="font-medium capitalize">{selectedItem.data.priority}</p>
                        )}
                      </div>
                    </div>
                    
                    <div>
                      <label className="text-gray-600 font-medium">Activity Name</label>
                      {editMode ? (
                        <input
                          type="text"
                          value={editData.name || ''}
                          onChange={(e) => setEditData({...editData, name: e.target.value})}
                          className="w-full border rounded px-3 py-2 mt-1 text-lg font-medium"
                        />
                      ) : (
                        <p className="font-medium text-lg mt-1">{selectedItem.data.name}</p>
                      )}
                    </div>
                    
                    <div className="bg-gray-50 p-4 rounded">
                      <h4 className="font-medium text-gray-800 mb-3">Planned Schedule</h4>
                      <div className="grid grid-cols-2 gap-4 text-sm">
                        <div>
                          <label className="text-gray-600 font-medium">Planned Start</label>
                          {editMode ? (
                            <input
                              type="date"
                              value={editData.planned_start_date || ''}
                              onChange={(e) => setEditData({...editData, planned_start_date: e.target.value})}
                              className="w-full border rounded px-3 py-2 font-medium"
                            />
                          ) : (
                            <p className="font-medium">{selectedItem.data.planned_start_date || 'Not set'}</p>
                          )}
                        </div>
                        <div>
                          <label className="text-gray-600 font-medium">Planned Duration</label>
                          {editMode ? (
                            <input
                              type="number"
                              min="1"
                              value={editData.duration_days || selectedItem.data.duration_days || 1}
                              onChange={(e) => setEditData({...editData, duration_days: e.target.value})}
                              className="w-full border rounded px-3 py-2 font-medium"
                            />
                          ) : (
                            <p className="font-medium">{selectedItem.data.duration_days} days</p>
                          )}
                        </div>
                        <div>
                          <label className="text-gray-600 font-medium">Planned End</label>
                          <p className="font-medium">{selectedItem.data.planned_end_date || 'Not calculated'}</p>
                        </div>
                        <div>
                          <label className="text-gray-600 font-medium">Budget Amount</label>
                          {editMode ? (
                            <input
                              type="number"
                              min="0"
                              step="0.01"
                              value={editData.budget_amount || ''}
                              onChange={(e) => setEditData({...editData, budget_amount: parseFloat(e.target.value) || 0})}
                              className="w-full border rounded px-3 py-2 font-medium"
                            />
                          ) : (
                            <p className="font-medium text-green-600">${(selectedItem.data.budget_amount || 0).toLocaleString()}</p>
                          )}
                        </div>
                      </div>
                    </div>
                    
                    <div className="bg-blue-50 p-4 rounded">
                      <h4 className="font-medium text-blue-800 mb-3">Actual Performance</h4>
                      <div className="grid grid-cols-2 gap-4 text-sm">
                        <div>
                          <label className="text-blue-600 font-medium">Actual Start</label>
                          {editMode ? (
                            <input
                              type="date"
                              value={editData.actual_start_date || ''}
                              onChange={(e) => setEditData({...editData, actual_start_date: e.target.value})}
                              className="w-full border rounded px-3 py-2 font-medium"
                            />
                          ) : (
                            <p className="font-medium">{selectedItem.data.actual_start_date || 'Not started'}</p>
                          )}
                        </div>
                        <div>
                          <label className="text-blue-600 font-medium">Actual Duration</label>
                          {editMode ? (
                            <input
                              type="number"
                              min="0"
                              value={editData.actual_duration_days || ''}
                              onChange={(e) => setEditData({...editData, actual_duration_days: parseInt(e.target.value) || 0})}
                              className="w-full border rounded px-3 py-2 font-medium"
                            />
                          ) : (
                            <p className="font-medium">{selectedItem.data.actual_duration_days || 0} days</p>
                          )}
                        </div>
                        <div>
                          <label className="text-blue-600 font-medium">Actual End</label>
                          {editMode ? (
                            <input
                              type="date"
                              value={editData.actual_end_date || ''}
                              onChange={(e) => setEditData({...editData, actual_end_date: e.target.value})}
                              className="w-full border rounded px-3 py-2 font-medium"
                            />
                          ) : (
                            <p className="font-medium">{selectedItem.data.actual_end_date || 'Not finished'}</p>
                          )}
                        </div>
                        <div>
                          <label className="text-blue-600 font-medium">Progress</label>
                          {editMode ? (
                            <input
                              type="number"
                              min="0"
                              max="100"
                              value={editData.progress_percentage || ''}
                              onChange={(e) => setEditData({...editData, progress_percentage: parseInt(e.target.value) || 0})}
                              className="w-full border rounded px-3 py-2 font-medium"
                            />
                          ) : (
                            <p className="font-medium">{selectedItem.data.progress_percentage}%</p>
                          )}
                        </div>
                      </div>
                    </div>
                    
                    {(selectedItem.data.actual_start_date || selectedItem.data.actual_duration_days > 0) && (
                      <div className="bg-yellow-50 p-4 rounded">
                        <h4 className="font-medium text-yellow-800 mb-3">Variance Analysis</h4>
                        <div className="grid grid-cols-2 gap-4 text-sm">
                          <div>
                            <label className="text-yellow-600 font-medium">Start Date Variance</label>
                            <p className="font-medium">
                              {selectedItem.data.actual_start_date && selectedItem.data.planned_start_date ? (
                                (() => {
                                  const planned = new Date(selectedItem.data.planned_start_date);
                                  const actual = new Date(selectedItem.data.actual_start_date);
                                  const diff = Math.ceil((actual - planned) / (1000 * 60 * 60 * 24));
                                  return diff === 0 ? 'On time' : diff > 0 ? `${diff} days late` : `${Math.abs(diff)} days early`;
                                })()
                              ) : 'N/A'}
                            </p>
                          </div>
                          <div>
                            <label className="text-yellow-600 font-medium">Duration Variance</label>
                            <p className="font-medium">
                              {selectedItem.data.actual_duration_days > 0 ? (
                                (() => {
                                  const diff = selectedItem.data.actual_duration_days - selectedItem.data.duration_days;
                                  return diff === 0 ? 'On schedule' : diff > 0 ? `${diff} days over` : `${Math.abs(diff)} days under`;
                                })()
                              ) : 'N/A'}
                            </p>
                          </div>
                        </div>
                      </div>
                    )}
                    
                    {selectedItem.data.activity_type === 'INTERNAL' && (
                      <div className="bg-blue-50 p-4 rounded">
                        <h4 className="font-medium text-blue-800 mb-2">Internal Activity Details</h4>
                        <div className="grid grid-cols-2 gap-4 text-sm">
                          <div>
                            <label className="text-blue-600 font-medium">Planned Hours</label>
                            <p className="font-medium">{selectedItem.data.planned_hours || 0} hrs</p>
                          </div>
                          <div>
                            <label className="text-blue-600 font-medium">Cost Rate</label>
                            <p className="font-medium">${selectedItem.data.cost_rate || 0}/hr</p>
                          </div>
                        </div>
                      </div>
                    )}
                    
                    {(selectedItem.data.activity_type === 'EXTERNAL' || selectedItem.data.activity_type === 'SERVICE') && (
                      <div className="bg-green-50 p-4 rounded">
                        <h4 className="font-medium text-green-800 mb-2">External Activity Details</h4>
                        <div className="grid grid-cols-2 gap-4 text-sm">
                          <div>
                            <label className="text-green-600 font-medium">Vendor</label>
                            <p className="font-medium">{vendors.find(v => v.id === selectedItem.data.vendor_id)?.name || 'Not assigned'}</p>
                          </div>
                          <div>
                            <label className="text-green-600 font-medium">Requires PO</label>
                            <p className="font-medium">{selectedItem.data.requires_po ? 'Yes' : 'No'}</p>
                          </div>
                          {selectedItem.data.activity_type === 'EXTERNAL' && (
                            <>
                              <div>
                                <label className="text-green-600 font-medium">Quantity</label>
                                <p className="font-medium">{selectedItem.data.quantity || 0}</p>
                              </div>
                              <div>
                                <label className="text-green-600 font-medium">Rate</label>
                                <p className="font-medium">${selectedItem.data.rate || 0}</p>
                              </div>
                            </>
                          )}
                        </div>
                      </div>
                    )}
                    
                    <div className="bg-gray-50 p-4 rounded">
                      <h4 className="font-medium text-gray-800 mb-2">Cost Breakdown</h4>
                      <div className="grid grid-cols-2 gap-4 text-sm">
                        <div>
                          <label className="text-gray-600 font-medium">Labor Cost</label>
                          <p className="font-medium">${(selectedItem.data.direct_labor_cost || 0).toLocaleString()}</p>
                        </div>
                        <div>
                          <label className="text-gray-600 font-medium">Material Cost</label>
                          <p className="font-medium">${(selectedItem.data.direct_material_cost || 0).toLocaleString()}</p>
                        </div>
                        <div>
                          <label className="text-gray-600 font-medium">Equipment Cost</label>
                          <p className="font-medium">${(selectedItem.data.direct_equipment_cost || 0).toLocaleString()}</p>
                        </div>
                        <div>
                          <label className="text-gray-600 font-medium">Subcontract Cost</label>
                          <p className="font-medium">${(selectedItem.data.direct_subcontract_cost || 0).toLocaleString()}</p>
                        </div>
                        <div>
                          <label className="text-gray-600 font-medium">Expense Cost</label>
                          <p className="font-medium">${(selectedItem.data.direct_expense_cost || 0).toLocaleString()}</p>
                        </div>
                        <div>
                          <label className="text-gray-600 font-medium">Total Direct Cost</label>
                          <p className="font-medium text-green-600">${(
                            (selectedItem.data.direct_labor_cost || 0) +
                            (selectedItem.data.direct_material_cost || 0) +
                            (selectedItem.data.direct_equipment_cost || 0) +
                            (selectedItem.data.direct_subcontract_cost || 0) +
                            (selectedItem.data.direct_expense_cost || 0)
                          ).toLocaleString()}</p>
                        </div>
                      </div>
                    </div>
                    
                    <div className="bg-orange-50 p-4 rounded">
                      <h4 className="font-medium text-orange-800 mb-2">Dependencies</h4>
                      <div className="space-y-4">
                        <div>
                          <label className="text-orange-600 font-medium">Predecessors (Must finish before this activity)</label>
                          {editMode ? (
                            <div className="mt-2 space-y-2 max-h-32 overflow-y-auto">
                              {allActivities
                                .filter(a => a.id !== selectedItem.data.id)
                                .map(activity => (
                                  <label key={activity.id} className="flex items-center space-x-2 p-2 border rounded hover:bg-gray-50 cursor-pointer">
                                    <input
                                      type="checkbox"
                                      checked={(editData.predecessor_activities || []).includes(activity.id)}
                                      onChange={(e) => {
                                        const current = editData.predecessor_activities || [];
                                        const updated = e.target.checked
                                          ? [...current, activity.id]
                                          : current.filter(id => id !== activity.id);
                                        setEditData({...editData, predecessor_activities: updated});
                                      }}
                                      className="rounded"
                                    />
                                    <span className="font-mono text-xs text-gray-600">{activity.code}</span>
                                    <span className="text-sm">{activity.name}</span>
                                  </label>
                                ))
                              }
                              {allActivities.filter(a => a.id !== selectedItem.data.id).length === 0 && (
                                <p className="text-sm text-gray-500">No other activities available</p>
                              )}
                            </div>
                          ) : (
                            <div className="mt-2">
                              {selectedItem.data.predecessor_activities && selectedItem.data.predecessor_activities.length > 0 ? (
                                <div className="space-y-1">
                                  {selectedItem.data.predecessor_activities.map((predId: string) => {
                                    const predActivity = allActivities.find(a => a.id === predId);
                                    return predActivity ? (
                                      <div key={predId} className="flex items-center justify-between p-2 bg-white rounded border">
                                        <span className="font-mono text-xs">{predActivity.code}</span>
                                        <span className="text-sm">{predActivity.name}</span>
                                        <span className="text-xs text-gray-500">
                                          {selectedItem.data.dependency_type?.replace('_', ' ') || 'finish to start'}
                                        </span>
                                      </div>
                                    ) : null;
                                  })}
                                </div>
                              ) : (
                                <p className="text-sm text-gray-500">No predecessors</p>
                              )}
                            </div>
                          )}
                        </div>
                        
                        <div>
                          <label className="text-blue-600 font-medium">Successors (Activities that depend on this)</label>
                          {editMode ? (
                            <div className="mt-2 space-y-2 max-h-32 overflow-y-auto">
                              {allActivities
                                .filter(a => a.id !== selectedItem.data.id)
                                .map(activity => {
                                  const isSuccessor = activity.predecessor_activities && activity.predecessor_activities.includes(selectedItem.data.id);
                                  return (
                                    <label key={activity.id} className="flex items-center space-x-2 p-2 border rounded hover:bg-gray-50 cursor-pointer">
                                      <input
                                        type="checkbox"
                                        checked={isSuccessor}
                                        onChange={async (e) => {
                                          const currentPreds = activity.predecessor_activities || [];
                                          const updatedPreds = e.target.checked
                                            ? [...currentPreds, selectedItem.data.id]
                                            : currentPreds.filter(id => id !== selectedItem.data.id);
                                          
                                          await supabase
                                            .from('activities')
                                            .update({ predecessor_activities: updatedPreds })
                                            .eq('id', activity.id);
                                          
                                          await fetchAllActivities();
                                          await fetchWBS();
                                        }}
                                        className="rounded"
                                      />
                                      <span className="font-mono text-xs text-gray-600">{activity.code}</span>
                                      <span className="text-sm">{activity.name}</span>
                                    </label>
                                  );
                                })
                              }
                            </div>
                          ) : (
                            <div className="mt-2">
                              {(() => {
                                const successors = allActivities.filter(a => 
                                  a.predecessor_activities && 
                                  a.predecessor_activities.includes(selectedItem.data.id)
                                );
                                return successors.length > 0 ? (
                                  <div className="space-y-1">
                                    {successors.map(successor => (
                                      <div key={successor.id} className="flex items-center justify-between p-2 bg-blue-50 rounded border border-blue-200">
                                        <span className="font-mono text-xs">{successor.code}</span>
                                        <span className="text-sm">{successor.name}</span>
                                        <span className="text-xs text-blue-600">
                                          {successor.dependency_type?.replace('_', ' ') || 'finish to start'}
                                        </span>
                                      </div>
                                    ))}
                                  </div>
                                ) : (
                                  <p className="text-sm text-gray-500">No successors</p>
                                );
                              })()
                              }
                            </div>
                          )}
                        </div>
                        
                        <div className="grid grid-cols-2 gap-4">
                          <div>
                            <label className="text-orange-600 font-medium">Dependency Type</label>
                            {editMode ? (
                              <select
                                value={editData.dependency_type || 'finish_to_start'}
                                onChange={(e) => setEditData({...editData, dependency_type: e.target.value})}
                                className="w-full border rounded px-3 py-2 mt-1"
                              >
                                <option value="finish_to_start">Finish to Start</option>
                                <option value="start_to_start">Start to Start</option>
                                <option value="finish_to_finish">Finish to Finish</option>
                                <option value="start_to_finish">Start to Finish</option>
                              </select>
                            ) : (
                              <p className="font-medium mt-1 capitalize">{selectedItem.data.dependency_type?.replace('_', ' ') || 'finish to start'}</p>
                            )}
                          </div>
                          <div>
                            <label className="text-orange-600 font-medium">Lag Days</label>
                            {editMode ? (
                              <input
                                type="number"
                                value={editData.lag_days || 0}
                                onChange={(e) => setEditData({...editData, lag_days: parseInt(e.target.value) || 0})}
                                className="w-full border rounded px-3 py-2 mt-1"
                              />
                            ) : (
                              <p className="font-medium mt-1">{selectedItem.data.lag_days || 0} days</p>
                            )}
                          </div>
                        </div>
                      </div>
                    </div>
                    
                    {selectedItem.data.tasks && selectedItem.data.tasks.length > 0 && (
                      <div>
                        <label className="text-gray-600 font-medium">Tasks ({selectedItem.data.tasks.length})</label>
                        <div className="mt-2 space-y-1">
                          {selectedItem.data.tasks.map(task => (
                            <div key={task.id} className="flex justify-between items-center p-2 bg-gray-50 rounded">
                              <span className="text-sm">{task.name}</span>
                              <span className={`px-2 py-1 rounded text-xs ${
                                task.status === 'completed' ? 'bg-green-100 text-green-800' :
                                task.status === 'in_progress' ? 'bg-blue-100 text-blue-800' :
                                'bg-gray-100 text-gray-800'
                              }`}>
                                {task.status}
                              </span>
                            </div>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                )}
                
                {selectedItem.type === 'task' && (
                  <div className="space-y-6">
                    <div>
                      <label className="text-gray-600 font-medium">Task Name</label>
                      {editMode ? (
                        <input
                          type="text"
                          value={editData.name || ''}
                          onChange={(e) => setEditData({...editData, name: e.target.value})}
                          className="w-full border rounded px-3 py-2 mt-1 text-lg font-medium"
                        />
                      ) : (
                        <p className="font-medium text-lg mt-1">{selectedItem.data.name}</p>
                      )}
                    </div>
                    
                    <div className="grid grid-cols-2 gap-4 text-sm">
                      <div>
                        <label className="text-gray-600 font-medium">Status</label>
                        {editMode ? (
                          <select
                            value={editData.status || ''}
                            onChange={(e) => setEditData({...editData, status: e.target.value})}
                            className="w-full border rounded px-3 py-2 font-medium"
                          >
                            <option value="not_started">Not Started</option>
                            <option value="in_progress">In Progress</option>
                            <option value="completed">Completed</option>
                          </select>
                        ) : (
                          <p className="font-medium capitalize">{selectedItem.data.status?.replace('_', ' ')}</p>
                        )}
                      </div>
                      <div>
                        <label className="text-gray-600 font-medium">Priority</label>
                        {editMode ? (
                          <select
                            value={editData.priority || ''}
                            onChange={(e) => setEditData({...editData, priority: e.target.value})}
                            className="w-full border rounded px-3 py-2 font-medium"
                          >
                            <option value="low">Low</option>
                            <option value="medium">Medium</option>
                            <option value="high">High</option>
                            <option value="critical">Critical</option>
                          </select>
                        ) : (
                          <p className="font-medium capitalize">{selectedItem.data.priority}</p>
                        )}
                      </div>
                      <div>
                        <label className="text-gray-600 font-medium">Checklist Item</label>
                        {editMode ? (
                          <select
                            value={editData.checklist_item ? 'true' : 'false'}
                            onChange={(e) => setEditData({...editData, checklist_item: e.target.value === 'true'})}
                            className="w-full border rounded px-3 py-2 font-medium"
                          >
                            <option value="false">No</option>
                            <option value="true">Yes</option>
                          </select>
                        ) : (
                          <p className="font-medium">{selectedItem.data.checklist_item ? 'Yes' : 'No'}</p>
                        )}
                      </div>
                      <div>
                        <label className="text-gray-600 font-medium">Activity</label>
                        <p className="font-medium">{allActivities.find(a => a.id === selectedItem.data.activity_id)?.name || 'Unknown'}</p>
                      </div>
                    </div>
                    
                    <div>
                      <label className="text-gray-600 font-medium">Description</label>
                      {editMode ? (
                        <textarea
                          value={editData.description || ''}
                          onChange={(e) => setEditData({...editData, description: e.target.value})}
                          className="w-full border rounded px-3 py-2 mt-1 font-medium"
                          rows={3}
                        />
                      ) : (
                        <p className="font-medium mt-1">{selectedItem.data.description || 'No description provided'}</p>
                      )}
                    </div>
                    
                    <div>
                      <label className="text-gray-600 font-medium">Progress Notes</label>
                      <p className="text-sm text-gray-500 mt-1">
                        Tasks are progress tracking items within activities. Use activities for scheduling and dependencies.
                      </p>
                    </div>
                    
                    {/* Task Edit Buttons */}
                    <div className="flex space-x-2 mt-4">
                      {!editMode ? (
                        <button 
                          onClick={() => {
                            setEditMode(true);
                            setEditData({...selectedItem.data});
                          }}
                          className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
                        >
                          Edit Task
                        </button>
                      ) : (
                        <>
                          <button 
                            onClick={saveInlineEdit}
                            className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700"
                          >
                            Save Changes
                          </button>
                          <button 
                            onClick={cancelInlineEdit}
                            className="px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700"
                          >
                            Cancel
                          </button>
                        </>
                      )}
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>
        ) : (
          <div className="flex items-center justify-center h-full text-gray-500">
            <div className="text-center">
              <div className="text-4xl mb-3">📋</div>
              <p className="text-sm">Select an item to view details</p>
              <p className="text-xs mt-1 text-gray-400">Click any WBS node, activity, or task in the tree</p>
            </div>
          </div>
        )}
      </div>



      {showForm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-bold mb-4">{editingNode ? 'Edit WBS Node' : 'Add WBS Node'}</h3>
            {error && (
              <div className="bg-red-50 border border-red-200 rounded p-3 mb-4">
                <p className="text-red-800 text-sm">{error}</p>
              </div>
            )}
            <form onSubmit={saveWBSNode} className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1">Code</label>
                <input
                  type="text"
                  value={formData.code}
                  onChange={(e) => setFormData({...formData, code: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                  placeholder="WBS-01"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Name</label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) => setFormData({...formData, name: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                  placeholder="Foundation Work"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Type</label>
                <select
                  value={formData.node_type}
                  onChange={(e) => setFormData({...formData, node_type: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                >
                  <option value="phase">Phase</option>
                  <option value="deliverable">Deliverable</option>
                  <option value="work_package">Work Package</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Parent Node</label>
                <select
                  value={formData.parent_id}
                  onChange={(e) => setFormData({...formData, parent_id: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                  disabled={editingNode !== null}
                >
                  <option value="">Root Level</option>
                  {wbsNodes
                    .filter(node => !editingNode || node.id !== editingNode.id)
                    .map((node) => (
                    <option key={node.id} value={node.id}>
                      {node.code} - {node.name}
                    </option>
                  ))}
                </select>
                {editingNode && (
                  <p className="text-xs text-gray-500 mt-1">Parent cannot be changed when editing</p>
                )}
              </div>
              <div className="flex justify-end space-x-3">
                <button
                  type="button"
                  onClick={resetForm}
                  className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
                >
                  {editingNode ? 'Update' : 'Create'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {deleteWarning.show && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-bold mb-4 text-red-600">Delete WBS Node</h3>
            <div className="space-y-3">
              <p>Are you sure you want to delete <strong>{deleteWarning.nodeName}</strong>?</p>
              
              {deleteWarning.hasChildren && (
                <div className="bg-red-50 border border-red-200 rounded p-3">
                  <p className="text-red-800 text-sm font-medium">⚠️ Warning: This node has child nodes</p>
                  <p className="text-red-700 text-sm">All child nodes will also be deleted.</p>
                </div>
              )}
              
              {deleteWarning.hasActivities && (
                <div className="bg-orange-50 border border-orange-200 rounded p-3">
                  <p className="text-orange-800 text-sm font-medium">⚠️ Warning: This node has activities</p>
                  <p className="text-orange-700 text-sm">All associated activities and tasks will be affected.</p>
                </div>
              )}
              
              <div className="flex justify-end space-x-3 mt-6">
                <button
                  onClick={() => setDeleteWarning({ show: false, nodeId: '', nodeName: '', hasChildren: false, hasActivities: false })}
                  className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  onClick={deleteNode}
                  className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700"
                >
                  Delete
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Activity Form Modal */}
      {showActivityForm && selectedItem && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-bold mb-4">{editingActivity ? 'Edit Activity' : 'Add Activity to ' + (selectedItem?.type === 'wbs' ? selectedItem.data.name : 'WBS Node')}</h3>
            <form onSubmit={saveActivity} className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1">Activity Code</label>
                <div className="flex">
                  <input
                    type="text"
                    value={activityForm.code}
                    onChange={(e) => setActivityForm({...activityForm, code: e.target.value})}
                    className="flex-1 border rounded-l px-3 py-2 bg-gray-50"
                    readOnly
                  />
                  <button
                    type="button"
                    onClick={async () => {
                      if (selectedItem?.type === 'wbs') {
                        const { generateActivityCode } = await import('../lib/code-generator');
                        const newCode = await generateActivityCode(projectId, selectedItem.data.id);
                        setActivityForm({...activityForm, code: newCode});
                      }
                    }}
                    className="bg-blue-600 text-white px-3 py-2 rounded-r hover:bg-blue-700 text-sm"
                  >
                    🔄
                  </button>
                </div>
                <p className="text-xs text-gray-500 mt-1">Format: {selectedItem?.type === 'wbs' ? selectedItem.data.code : 'WBS'}-A01, etc.</p>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Activity Name</label>
                <input
                  type="text"
                  value={activityForm.name}
                  onChange={(e) => setActivityForm({...activityForm, name: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                  placeholder="Site Preparation"
                  required
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Start Date</label>
                  <input
                    type="date"
                    value={activityForm.planned_start_date}
                    onChange={(e) => setActivityForm({...activityForm, planned_start_date: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Duration (Days)</label>
                  <input
                    type="number"
                    min="1"
                    value={activityForm.duration_days}
                    onChange={(e) => setActivityForm({...activityForm, duration_days: parseInt(e.target.value) || 1})}
                    className="w-full border rounded px-3 py-2"
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Activity Type</label>
                  <select 
                    value={activityForm.activity_type}
                    onChange={(e) => setActivityForm({...activityForm, activity_type: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  >
                    <option value="INTERNAL">Internal Team</option>
                    <option value="EXTERNAL">External Vendor</option>
                    <option value="SERVICE">Service (with line items)</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Priority</label>
                  <select
                    value={activityForm.priority}
                    onChange={(e) => setActivityForm({...activityForm, priority: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  >
                    <option value="low">Low</option>
                    <option value="medium">Medium</option>
                    <option value="high">High</option>
                    <option value="critical">Critical</option>
                  </select>
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Budget Amount</label>
                <input
                  type="number"
                  min="0"
                  step="0.01"
                  value={activityForm.budget_amount}
                  onChange={(e) => setActivityForm({...activityForm, budget_amount: parseFloat(e.target.value) || 0})}
                  className="w-full border rounded px-3 py-2"
                  placeholder="50000"
                />
              </div>
              
              {/* Type-specific fields */}
              {activityForm.activity_type === 'INTERNAL' && (
                <div className="grid grid-cols-2 gap-4 bg-blue-50 p-3 rounded">
                  <div>
                    <label className="block text-sm font-medium mb-1">Planned Hours</label>
                    <input
                      type="number"
                      min="0"
                      step="0.5"
                      value={activityForm.planned_hours}
                      onChange={(e) => setActivityForm({...activityForm, planned_hours: parseFloat(e.target.value) || 0})}
                      className="w-full border rounded px-3 py-2"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-1">Cost Rate (per hour)</label>
                    <input
                      type="number"
                      min="0"
                      step="0.01"
                      value={activityForm.cost_rate}
                      onChange={(e) => setActivityForm({...activityForm, cost_rate: parseFloat(e.target.value) || 0})}
                      className="w-full border rounded px-3 py-2"
                    />
                  </div>
                </div>
              )}
              
              {(activityForm.activity_type === 'EXTERNAL' || activityForm.activity_type === 'SERVICE') && (
                <div className="bg-green-50 p-3 rounded space-y-3">
                  <div>
                    <label className="block text-sm font-medium mb-1">Vendor</label>
                    <select
                      value={activityForm.vendor_id}
                      onChange={(e) => setActivityForm({...activityForm, vendor_id: e.target.value})}
                      className="w-full border rounded px-3 py-2"
                    >
                      <option value="">Select Vendor</option>
                      {vendors.map((vendor) => (
                        <option key={vendor.id} value={vendor.id}>
                          {vendor.code} - {vendor.name}
                        </option>
                      ))}
                    </select>
                  </div>
                  
                  {activityForm.activity_type === 'EXTERNAL' && (
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="block text-sm font-medium mb-1">Quantity</label>
                        <input
                          type="number"
                          min="0"
                          step="0.01"
                          value={activityForm.quantity}
                          onChange={(e) => setActivityForm({...activityForm, quantity: parseFloat(e.target.value) || 0})}
                          className="w-full border rounded px-3 py-2"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium mb-1">Rate</label>
                        <input
                          type="number"
                          min="0"
                          step="0.01"
                          value={activityForm.rate}
                          onChange={(e) => setActivityForm({...activityForm, rate: parseFloat(e.target.value) || 0})}
                          className="w-full border rounded px-3 py-2"
                        />
                      </div>
                    </div>
                  )}
                </div>
              )}
              <div className="flex justify-end space-x-3">
                <button
                  type="button"
                  onClick={resetActivityForm}
                  className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700"
                >
                  {editingActivity ? 'Update Activity' : 'Create Activity'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Task Form Modal */}
      {showTaskForm && selectedItem && selectedItem.type === 'activity' && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-bold mb-4">Add Task to {selectedItem.data.name}</h3>
            <form onSubmit={saveTask} className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1">Task Name</label>
                <input
                  type="text"
                  value={taskForm.name}
                  onChange={(e) => setTaskForm({...taskForm, name: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                  placeholder="Install electrical outlets"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Description</label>
                <textarea
                  value={taskForm.description}
                  onChange={(e) => setTaskForm({...taskForm, description: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                  rows={3}
                  placeholder="Detailed task description..."
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Priority</label>
                  <select
                    value={taskForm.priority}
                    onChange={(e) => setTaskForm({...taskForm, priority: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  >
                    <option value="low">Low</option>
                    <option value="medium">Medium</option>
                    <option value="high">High</option>
                    <option value="critical">Critical</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Checklist Item</label>
                  <select
                    value={taskForm.checklist_item ? 'true' : 'false'}
                    onChange={(e) => setTaskForm({...taskForm, checklist_item: e.target.value === 'true'})}
                    className="w-full border rounded px-3 py-2"
                  >
                    <option value="false">No</option>
                    <option value="true">Yes</option>
                  </select>
                </div>
              </div>
              <div className="flex justify-end space-x-3">
                <button
                  type="button"
                  onClick={resetTaskForm}
                  className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-purple-600 text-white rounded hover:bg-purple-700"
                >
                  Create Task
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}