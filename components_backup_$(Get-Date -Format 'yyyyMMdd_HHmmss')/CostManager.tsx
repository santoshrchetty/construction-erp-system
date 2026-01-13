'use client';

import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';

interface WBSNode {
  id: string;
  code: string;
  name: string;
  wbs_direct_cost_total: number;
  wbs_indirect_cost_allocated: number;
}

interface Activity {
  id: string;
  code: string;
  name: string;
  budget_amount: number;
  direct_labor_cost: number;
  direct_material_cost: number;
  direct_equipment_cost: number;
  direct_subcontract_cost: number;
  direct_expense_cost: number;
  wbs_node_id: string;
}

export default function CostManager({ projectId }: { projectId: string }) {
  const [wbsNodes, setWbsNodes] = useState<WBSNode[]>([]);
  const [activities, setActivities] = useState<Activity[]>([]);
  const [projectBudget, setProjectBudget] = useState(0);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData();
  }, [projectId]);

  const fetchData = async () => {
    const [wbsResult, activitiesResult, projectResult] = await Promise.all([
      supabase.from('wbs_nodes').select('*').eq('project_id', projectId),
      supabase.from('activities').select('*').eq('project_id', projectId),
      supabase.from('projects').select('budget').eq('id', projectId).single()
    ]);

    if (wbsResult.data) setWbsNodes(wbsResult.data);
    if (activitiesResult.data) setActivities(activitiesResult.data);
    if (projectResult.data) setProjectBudget(projectResult.data.budget);
    setLoading(false);
  };

  const calculateTotalDirectCost = (wbsNodeId: string) => {
    return activities
      .filter(a => a.wbs_node_id === wbsNodeId)
      .reduce((sum, activity) => sum + (
        (activity.direct_labor_cost || 0) +
        (activity.direct_material_cost || 0) +
        (activity.direct_equipment_cost || 0) +
        (activity.direct_subcontract_cost || 0) +
        (activity.direct_expense_cost || 0)
      ), 0);
  };

  const totalProjectCost = wbsNodes.reduce((sum, node) => 
    sum + (node.wbs_direct_cost_total || 0) + (node.wbs_indirect_cost_allocated || 0), 0
  );

  if (loading) return <div className="p-6">Loading cost data...</div>;

  return (
    <div className="p-6 space-y-6">
      {/* Project Cost Summary */}
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-lg font-bold mb-4">Project Cost Summary</h2>
        <div className="grid grid-cols-3 gap-6">
          <div className="text-center">
            <div className="text-2xl font-bold text-blue-600">${projectBudget.toLocaleString()}</div>
            <div className="text-sm text-gray-600">Budget</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold text-green-600">${totalProjectCost.toLocaleString()}</div>
            <div className="text-sm text-gray-600">Total Cost</div>
          </div>
          <div className="text-center">
            <div className={`text-2xl font-bold ${projectBudget - totalProjectCost >= 0 ? 'text-green-600' : 'text-red-600'}`}>
              ${(projectBudget - totalProjectCost).toLocaleString()}
            </div>
            <div className="text-sm text-gray-600">Variance</div>
          </div>
        </div>
      </div>

      {/* WBS Cost Breakdown */}
      <div className="bg-white rounded-lg shadow">
        <div className="p-4 border-b">
          <h2 className="text-lg font-bold">WBS Cost Breakdown</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">WBS Code</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Direct Cost</th>
                <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Indirect Cost</th>
                <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Total Cost</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {wbsNodes.map((node) => {
                const directCost = node.wbs_direct_cost_total || 0;
                const indirectCost = node.wbs_indirect_cost_allocated || 0;
                const totalCost = directCost + indirectCost;
                
                return (
                  <tr key={node.id} className="hover:bg-gray-50">
                    <td className="px-4 py-3 font-mono text-sm">{node.code}</td>
                    <td className="px-4 py-3 text-sm">{node.name}</td>
                    <td className="px-4 py-3 text-sm text-right">${directCost.toLocaleString()}</td>
                    <td className="px-4 py-3 text-sm text-right">${indirectCost.toLocaleString()}</td>
                    <td className="px-4 py-3 text-sm text-right font-medium">${totalCost.toLocaleString()}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>

      {/* Activity Cost Details */}
      <div className="bg-white rounded-lg shadow">
        <div className="p-4 border-b">
          <h2 className="text-lg font-bold">Activity Cost Details</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Activity</th>
                <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Budget</th>
                <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Labor</th>
                <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Material</th>
                <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Equipment</th>
                <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Subcontract</th>
                <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Total Actual</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {activities.map((activity) => {
                const totalActual = (activity.direct_labor_cost || 0) + 
                                  (activity.direct_material_cost || 0) + 
                                  (activity.direct_equipment_cost || 0) + 
                                  (activity.direct_subcontract_cost || 0) + 
                                  (activity.direct_expense_cost || 0);
                
                return (
                  <tr key={activity.id} className="hover:bg-gray-50">
                    <td className="px-4 py-3">
                      <div>
                        <div className="font-medium text-sm">{activity.name}</div>
                        <div className="text-xs text-gray-500">{activity.code}</div>
                      </div>
                    </td>
                    <td className="px-4 py-3 text-sm text-right">${(activity.budget_amount || 0).toLocaleString()}</td>
                    <td className="px-4 py-3 text-sm text-right">${(activity.direct_labor_cost || 0).toLocaleString()}</td>
                    <td className="px-4 py-3 text-sm text-right">${(activity.direct_material_cost || 0).toLocaleString()}</td>
                    <td className="px-4 py-3 text-sm text-right">${(activity.direct_equipment_cost || 0).toLocaleString()}</td>
                    <td className="px-4 py-3 text-sm text-right">${(activity.direct_subcontract_cost || 0).toLocaleString()}</td>
                    <td className="px-4 py-3 text-sm text-right font-medium">${totalActual.toLocaleString()}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}