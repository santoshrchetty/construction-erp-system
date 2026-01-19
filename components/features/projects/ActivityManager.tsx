'use client';

import React, { useState, useEffect } from 'react';
import { wbsApi } from '@/lib/wbs-api';
import ActivityMaterialsForm from '@/components/activities/ActivityMaterialsForm';


interface Activity {
  id: string;
  code: string;
  name: string;
  planned_start_date: string;
  planned_end_date: string;
  budget_amount: number;
  duration_days: number;
  progress_percentage: number;
  status: string;
  priority: string;
  activity_type: string;
  planned_hours?: number;
  cost_rate?: number;
  vendor_id?: string;
  rate?: number;
  quantity?: number;
  requires_po?: boolean;
  wbs_node_id: string;
  wbs_node_name?: string;
  vendor_name?: string;
  direct_labor_cost?: number;
  direct_material_cost?: number;
  direct_equipment_cost?: number;
  direct_subcontract_cost?: number;
  direct_expense_cost?: number;
  direct_cost_total?: number;
  assigned_internal_team?: string[];
  assigned_resources?: string[];
}

interface WBSNode {
  id: string;
  code: string;
  name: string;
}

export default function ActivityManager({ projectId }: { projectId: string }) {
  const [activities, setActivities] = useState<Activity[]>([]);
  const [wbsNodes, setWbsNodes] = useState<WBSNode[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [editingActivity, setEditingActivity] = useState<Activity | null>(null);
  const [showMaterialsModal, setShowMaterialsModal] = useState<{show: boolean, activity: Activity | null}>({show: false, activity: null});
  const [showDeleteConfirm, setShowDeleteConfirm] = useState<{show: boolean, activity: Activity | null}>({show: false, activity: null});
  const [formData, setFormData] = useState({
    name: '',
    wbs_node_id: '',
    planned_start_date: '',
    duration_days: 1,
    budget_amount: 0,
    priority: 'medium',
    activity_type: 'INTERNAL',
    planned_hours: 0,
    cost_rate: 0,
    vendor_id: '',
    rate: 0,
    quantity: 0
  });

  const [vendors, setVendors] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchActivities();
    fetchWBSNodes();
    fetchVendors();
  }, [projectId]);

  const fetchVendors = async () => {
    try {
      const data = await wbsApi.getVendors();
      setVendors(data);
    } catch (error) {
      console.error('Failed to fetch vendors:', error);
    }
  };

  const fetchActivities = async () => {
    try {
      const data = await wbsApi.getActivities(projectId);
      setActivities(data);
    } catch (error) {
      console.error('Failed to fetch activities:', error);
    }
    setLoading(false);
  };

  const fetchWBSNodes = async () => {
    try {
      const data = await wbsApi.getNodes(projectId);
      setWbsNodes(data);
    } catch (error) {
      console.error('Failed to fetch WBS nodes:', error);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed': return 'bg-green-500';
      case 'in_progress': return 'bg-blue-500';
      case 'on_hold': return 'bg-yellow-500';
      default: return 'bg-gray-300';
    }
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'critical': return 'text-red-600 bg-red-50';
      case 'high': return 'text-orange-600 bg-orange-50';
      case 'medium': return 'text-blue-600 bg-blue-50';
      default: return 'text-gray-600 bg-gray-50';
    }
  };

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'INTERNAL': return '👥';
      case 'EXTERNAL': return '🏢';
      case 'SERVICE': return '⚙️';
      default: return '📋';
    }
  };

  const editActivity = (activity: Activity) => {
    setEditingActivity(activity);
    setFormData({
      name: activity.name,
      wbs_node_id: activity.wbs_node_id,
      planned_start_date: activity.planned_start_date,
      duration_days: activity.duration_days,
      budget_amount: activity.budget_amount,
      priority: activity.priority,
      activity_type: activity.activity_type,
      planned_hours: activity.planned_hours || 0,
      cost_rate: activity.cost_rate || 0,
      vendor_id: activity.vendor_id || '',
      rate: activity.rate || 0,
      quantity: activity.quantity || 0
    });
    setShowForm(true);
  };

  const deleteActivity = async (activityId: string) => {
    try {
      await wbsApi.deleteActivity(activityId);
      setShowDeleteConfirm({show: false, activity: null});
      fetchActivities();
    } catch (error) {
      console.error('Failed to delete activity:', error);
      alert('Failed to delete activity');
    }
  };

  const saveActivity = async (e: React.FormEvent) => {
    e.preventDefault();
    
    const activityData: any = {
      project_id: projectId,
      name: formData.name,
      wbs_node_id: formData.wbs_node_id,
      planned_start_date: formData.planned_start_date,
      duration_days: formData.duration_days,
      budget_amount: formData.budget_amount,
      priority: formData.priority,
      activity_type: formData.activity_type,
      status: 'not_started',
      progress_percentage: 0
    };
    
    // Add type-specific fields
    if (formData.activity_type === 'INTERNAL') {
      activityData.planned_hours = formData.planned_hours;
      activityData.cost_rate = formData.cost_rate;
    } else if (formData.activity_type === 'EXTERNAL') {
      activityData.vendor_id = formData.vendor_id || null;
      activityData.rate = formData.rate;
      activityData.quantity = formData.quantity;
    } else if (formData.activity_type === 'SERVICE') {
      activityData.vendor_id = formData.vendor_id || null;
    }

    try {
      if (editingActivity) {
        await wbsApi.updateActivity(editingActivity.id, activityData);
      } else {
        await wbsApi.createActivity(activityData);
      }
      resetForm();
      fetchActivities();
    } catch (error: any) {
      console.error('Failed to save activity:', error);
      alert(`Error saving activity: ${error.message || 'Unknown error'}`);
    }
  };

  const resetForm = () => {
    setShowForm(false);
    setEditingActivity(null);
    setFormData({
      name: '',
      wbs_node_id: '',
      planned_start_date: '',
      duration_days: 1,
      budget_amount: 0,
      priority: 'medium',
      activity_type: 'INTERNAL',
      planned_hours: 0,
      cost_rate: 0,
      vendor_id: '',
      rate: 0,
      quantity: 0
    });
  };

  if (loading) return <div className="p-6">Loading activities...</div>;

  return (
    <div className="p-6">
      <div className="bg-white rounded-lg shadow">
        <div className="p-4 border-b">
          <div className="flex justify-between items-center">
            <div>
              <h2 className="text-lg font-bold">Activity Management</h2>
              <p className="text-sm text-gray-600">Manage project activities and resources</p>
            </div>
            <button
              onClick={() => setShowForm(true)}
              className="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700 flex items-center space-x-2"
            >
              <span>➕</span>
              <span>Add Activity</span>
            </button>
          </div>
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Activity</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">WBS</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Duration</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Budget</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Priority</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {activities.map((activity) => (
                <tr key={activity.id} className="hover:bg-gray-50">
                  <td className="px-4 py-3">
                    <div>
                      <div className="font-medium text-sm">{activity.name}</div>
                      <div className="text-xs text-gray-500">{activity.code}</div>
                      {activity.vendor_name && (
                        <div className="text-xs text-gray-400">Vendor: {activity.vendor_name}</div>
                      )}
                    </div>
                  </td>
                  <td className="px-4 py-3 text-sm">{activity.wbs_node_name}</td>
                  <td className="px-4 py-3">
                    <div className="flex items-center space-x-1">
                      <span>{getTypeIcon(activity.activity_type)}</span>
                      <span className="text-xs">{activity.activity_type}</span>
                    </div>
                  </td>
                  <td className="px-4 py-3 text-sm">{activity.duration_days} days</td>
                  <td className="px-4 py-3 text-sm font-medium">${activity.budget_amount?.toLocaleString()}</td>
                  <td className="px-4 py-3">
                    <div className="flex items-center">
                      <div className={`w-3 h-3 rounded-full ${getStatusColor(activity.status)} mr-2`}></div>
                      <span className="text-sm capitalize">{activity.status?.replace('_', ' ')}</span>
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-1 rounded text-xs ${getPriorityColor(activity.priority)}`}>
                      {activity.priority}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex space-x-2">
                      <button 
                        onClick={() => setShowMaterialsModal({show: true, activity})}
                        className="text-purple-600 hover:text-purple-800 text-sm"
                        title="Materials"
                      >
                        📦
                      </button>
                      <button 
                        onClick={() => editActivity(activity)}
                        className="text-blue-600 hover:text-blue-800 text-sm"
                        title="Edit"
                      >
                        ✏️
                      </button>
                      <button 
                        onClick={() => setShowDeleteConfirm({show: true, activity})}
                        className="text-red-600 hover:text-red-800 text-sm"
                        title="Delete"
                      >
                        🗑️
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {activities.length === 0 && (
          <div className="text-center py-12">
            <p className="text-gray-500 mb-4">No activities found. Create activities to get started.</p>
            <button
              onClick={() => setShowForm(true)}
              className="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700"
            >
              Create First Activity
            </button>
          </div>
        )}
      </div>

      {showForm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
            <h3 className="text-lg font-bold mb-4">{editingActivity ? 'Edit Activity' : 'Add Activity'}</h3>
            <form onSubmit={saveActivity} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">WBS Node</label>
                  <select
                    value={formData.wbs_node_id}
                    onChange={(e) => setFormData({...formData, wbs_node_id: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                    required
                  >
                    <option value="">Select WBS Node</option>
                    {wbsNodes.map((node) => (
                      <option key={node.id} value={node.id}>
                        {node.code} - {node.name}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
              
              <div>
                <label className="block text-sm font-medium mb-1">Activity Name</label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) => setFormData({...formData, name: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                  placeholder="Site Preparation"
                  required
                />
              </div>
              
              <div className="grid grid-cols-3 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Activity Type</label>
                  <select
                    value={formData.activity_type}
                    onChange={(e) => setFormData({...formData, activity_type: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  >
                    <option value="INTERNAL">Internal</option>
                    <option value="EXTERNAL">External</option>
                    <option value="SERVICE">Service</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Priority</label>
                  <select
                    value={formData.priority}
                    onChange={(e) => setFormData({...formData, priority: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  >
                    <option value="low">Low</option>
                    <option value="medium">Medium</option>
                    <option value="high">High</option>
                    <option value="critical">Critical</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Duration (Days)</label>
                  <input
                    type="number"
                    min="1"
                    value={formData.duration_days}
                    onChange={(e) => setFormData({...formData, duration_days: parseInt(e.target.value) || 1})}
                    className="w-full border rounded px-3 py-2"
                    required
                  />
                </div>
              </div>
              
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Start Date</label>
                  <input
                    type="date"
                    value={formData.planned_start_date}
                    onChange={(e) => setFormData({...formData, planned_start_date: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Budget Amount</label>
                  <input
                    type="number"
                    value={formData.budget_amount}
                    onChange={(e) => setFormData({...formData, budget_amount: parseFloat(e.target.value) || 0})}
                    className="w-full border rounded px-3 py-2"
                    placeholder="50000"
                    min="0"
                    step="0.01"
                  />
                </div>
              </div>
              
              {/* Type-specific fields */}
              {formData.activity_type === 'INTERNAL' && (
                <div className="grid grid-cols-2 gap-4 bg-blue-50 p-3 rounded">
                  <div>
                    <label className="block text-sm font-medium mb-1">Planned Hours</label>
                    <input
                      type="number"
                      min="0"
                      step="0.5"
                      value={formData.planned_hours}
                      onChange={(e) => setFormData({...formData, planned_hours: parseFloat(e.target.value) || 0})}
                      className="w-full border rounded px-3 py-2"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-1">Cost Rate (per hour)</label>
                    <input
                      type="number"
                      min="0"
                      step="0.01"
                      value={formData.cost_rate}
                      onChange={(e) => setFormData({...formData, cost_rate: parseFloat(e.target.value) || 0})}
                      className="w-full border rounded px-3 py-2"
                    />
                  </div>
                </div>
              )}
              
              {(formData.activity_type === 'EXTERNAL' || formData.activity_type === 'SERVICE') && (
                <div className="bg-green-50 p-3 rounded space-y-3">
                  <div>
                    <label className="block text-sm font-medium mb-1">Vendor</label>
                    <select
                      value={formData.vendor_id}
                      onChange={(e) => setFormData({...formData, vendor_id: e.target.value})}
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
                  
                  {formData.activity_type === 'EXTERNAL' && (
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="block text-sm font-medium mb-1">Quantity</label>
                        <input
                          type="number"
                          min="0"
                          step="0.01"
                          value={formData.quantity}
                          onChange={(e) => setFormData({...formData, quantity: parseFloat(e.target.value) || 0})}
                          className="w-full border rounded px-3 py-2"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium mb-1">Rate</label>
                        <input
                          type="number"
                          min="0"
                          step="0.01"
                          value={formData.rate}
                          onChange={(e) => setFormData({...formData, rate: parseFloat(e.target.value) || 0})}
                          className="w-full border rounded px-3 py-2"
                        />
                      </div>
                    </div>
                  )}
                </div>
              )}
              
              <div className="flex justify-end space-x-3 pt-4 border-t">
                <button
                  type="button"
                  onClick={resetForm}
                  className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700"
                >
                  {editingActivity ? 'Update' : 'Create'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {showDeleteConfirm.show && showDeleteConfirm.activity && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-bold mb-4 text-red-600">Delete Activity</h3>
            <p className="mb-4">
              Are you sure you want to delete <strong>{showDeleteConfirm.activity.name}</strong>?
            </p>
            <p className="text-sm text-gray-600 mb-6">
              This action cannot be undone. All associated tasks and data will be removed.
            </p>
            <div className="flex justify-end space-x-3">
              <button
                onClick={() => setShowDeleteConfirm({show: false, activity: null})}
                className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                onClick={() => deleteActivity(showDeleteConfirm.activity!.id)}
                className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700"
              >
                Delete Activity
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Materials Modal */}
      {showMaterialsModal.show && showMaterialsModal.activity && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-4xl max-h-[90vh] overflow-y-auto">
            <div className="flex justify-between items-center mb-4">
              <div>
                <h3 className="text-lg font-bold">Materials for {showMaterialsModal.activity.name}</h3>
                <p className="text-sm text-gray-600">Start Date: {showMaterialsModal.activity.planned_start_date}</p>
              </div>
              <button
                onClick={() => setShowMaterialsModal({show: false, activity: null})}
                className="text-gray-500 hover:text-gray-700"
              >
                ✕
              </button>
            </div>
            <ActivityMaterialsForm activityId={showMaterialsModal.activity.id} />
          </div>
        </div>
      )}
    </div>
  );
}