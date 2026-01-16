'use client';

import React, { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase/client';

interface PurchaseOrder {
  id: string;
  po_number: string;
  vendor_id: string;
  project_id: string;
  status: string;
  issue_date: string;
  delivery_date: string;
  total_amount: number;
  grand_total: number;
  vendor?: { name: string; code: string };
  project?: { name: string; code: string };
}

interface POLine {
  id: string;
  line_number: number;
  description: string;
  quantity: number;
  unit: string;
  unit_rate: number;
  line_total: number;
}

export default function PurchaseOrderManager({ projectId }: { projectId?: string }) {
  const [purchaseOrders, setPurchaseOrders] = useState<PurchaseOrder[]>([]);
  const [vendors, setVendors] = useState<any[]>([]);
  const [projects, setProjects] = useState<any[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [editingPO, setEditingPO] = useState<PurchaseOrder | null>(null);
  const [formData, setFormData] = useState({
    po_number: '',
    vendor_id: '',
    project_id: projectId || '',
    issue_date: new Date().toISOString().split('T')[0],
    delivery_date: '',
    payment_terms: '',
    notes: ''
  });
  const [lines, setLines] = useState<Omit<POLine, 'id'>[]>([
    { line_number: 1, description: '', quantity: 1, unit: 'EA', unit_rate: 0, line_total: 0 }
  ]);

  useEffect(() => {
    fetchPurchaseOrders();
    fetchVendors();
    if (!projectId) fetchProjects();
  }, [projectId]);

  const fetchPurchaseOrders = async () => {
    let query = supabase
      .from('purchase_orders')
      .select(`
        *,
        vendor:vendors(name, code),
        project:projects(name, code)
      `)
      .order('created_at', { ascending: false });

    if (projectId) {
      query = query.eq('project_id', projectId);
    }

    const { data } = await query;
    if (data) setPurchaseOrders(data);
  };

  const fetchVendors = async () => {
    const { data } = await supabase
      .from('vendors')
      .select('id, name, code')
      .eq('status', 'active');
    if (data) setVendors(data);
  };

  const fetchProjects = async () => {
    const { data } = await supabase
      .from('projects')
      .select('id, name, code')
      .eq('status', 'active');
    if (data) setProjects(data);
  };

  const generatePONumber = () => {
    const date = new Date();
    const year = date.getFullYear().toString().slice(-2);
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
    return `PO${year}${month}${random}`;
  };

  const updateLineTotal = (index: number, quantity: number, rate: number) => {
    const newLines = [...lines];
    newLines[index].quantity = quantity;
    newLines[index].unit_rate = rate;
    newLines[index].line_total = quantity * rate;
    setLines(newLines);
  };

  const addLine = () => {
    setLines([...lines, {
      line_number: lines.length + 1,
      description: '',
      quantity: 1,
      unit: 'EA',
      unit_rate: 0,
      line_total: 0
    }]);
  };

  const removeLine = (index: number) => {
    if (lines.length > 1) {
      const newLines = lines.filter((_, i) => i !== index);
      setLines(newLines.map((line, i) => ({ ...line, line_number: i + 1 })));
    }
  };

  const savePurchaseOrder = async (e: React.FormEvent) => {
    e.preventDefault();
    
    const totalAmount = lines.reduce((sum, line) => sum + line.line_total, 0);
    
    const poData = {
      ...formData,
      po_number: formData.po_number || generatePONumber(),
      total_amount: totalAmount,
      tax_amount: 0,
      created_by: null
    };

    let poId: string;

    if (editingPO) {
      const { data } = await supabase
        .from('purchase_orders')
        .update(poData)
        .eq('id', editingPO.id)
        .select()
        .single();
      poId = data?.id;
    } else {
      const { data } = await supabase
        .from('purchase_orders')
        .insert(poData)
        .select()
        .single();
      poId = data?.id;
    }

    if (poId) {
      // Delete existing lines if editing
      if (editingPO) {
        await supabase.from('po_lines').delete().eq('po_id', poId);
      }

      // Insert new lines
      const lineData = lines.map(line => ({
        po_id: poId,
        ...line
      }));

      await supabase.from('po_lines').insert(lineData);
    }

    resetForm();
    fetchPurchaseOrders();
  };

  const deletePO = async (id: string) => {
    if (confirm('Delete this purchase order?')) {
      await supabase.from('purchase_orders').delete().eq('id', id);
      fetchPurchaseOrders();
    }
  };

  const resetForm = () => {
    setShowForm(false);
    setEditingPO(null);
    setFormData({
      po_number: '',
      vendor_id: '',
      project_id: projectId || '',
      issue_date: new Date().toISOString().split('T')[0],
      delivery_date: '',
      payment_terms: '',
      notes: ''
    });
    setLines([{ line_number: 1, description: '', quantity: 1, unit: 'EA', unit_rate: 0, line_total: 0 }]);
  };

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Purchase Orders</h1>
        <button
          onClick={() => setShowForm(true)}
          className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
        >
          Create PO
        </button>
      </div>

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left">PO Number</th>
              <th className="px-4 py-3 text-left">Vendor</th>
              {!projectId && <th className="px-4 py-3 text-left">Project</th>}
              <th className="px-4 py-3 text-left">Status</th>
              <th className="px-4 py-3 text-left">Amount</th>
              <th className="px-4 py-3 text-left">Delivery Date</th>
              <th className="px-4 py-3 text-left">Actions</th>
            </tr>
          </thead>
          <tbody>
            {purchaseOrders.map((po) => (
              <tr key={po.id} className="border-t">
                <td className="px-4 py-3 font-mono text-sm">{po.po_number}</td>
                <td className="px-4 py-3">{po.vendor?.name}</td>
                {!projectId && <td className="px-4 py-3">{po.project?.name}</td>}
                <td className="px-4 py-3">
                  <span className={`px-2 py-1 rounded text-xs ${
                    po.status === 'approved' ? 'bg-green-100 text-green-800' :
                    po.status === 'draft' ? 'bg-gray-100 text-gray-800' :
                    'bg-yellow-100 text-yellow-800'
                  }`}>
                    {po.status.replace('_', ' ')}
                  </span>
                </td>
                <td className="px-4 py-3 font-medium">${po.grand_total.toLocaleString()}</td>
                <td className="px-4 py-3">{new Date(po.delivery_date).toLocaleDateString()}</td>
                <td className="px-4 py-3">
                  <button
                    onClick={() => deletePO(po.id)}
                    className="text-red-600 hover:text-red-800"
                  >
                    Delete
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {showForm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-4xl max-h-[90vh] overflow-y-auto">
            <h3 className="text-lg font-bold mb-4">Create Purchase Order</h3>
            <form onSubmit={savePurchaseOrder} className="space-y-6">
              <div className="grid grid-cols-3 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">PO Number</label>
                  <input
                    type="text"
                    value={formData.po_number}
                    onChange={(e) => setFormData({...formData, po_number: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                    placeholder="Auto-generated"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Issue Date</label>
                  <input
                    type="date"
                    value={formData.issue_date}
                    onChange={(e) => setFormData({...formData, issue_date: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Delivery Date</label>
                  <input
                    type="date"
                    value={formData.delivery_date}
                    onChange={(e) => setFormData({...formData, delivery_date: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                    required
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Vendor</label>
                  <select
                    value={formData.vendor_id}
                    onChange={(e) => setFormData({...formData, vendor_id: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                    required
                  >
                    <option value="">Select Vendor</option>
                    {vendors.map((vendor) => (
                      <option key={vendor.id} value={vendor.id}>
                        {vendor.code} - {vendor.name}
                      </option>
                    ))}
                  </select>
                </div>
                {!projectId && (
                  <div>
                    <label className="block text-sm font-medium mb-1">Project</label>
                    <select
                      value={formData.project_id}
                      onChange={(e) => setFormData({...formData, project_id: e.target.value})}
                      className="w-full border rounded px-3 py-2"
                      required
                    >
                      <option value="">Select Project</option>
                      {projects.map((project) => (
                        <option key={project.id} value={project.id}>
                          {project.code} - {project.name}
                        </option>
                      ))}
                    </select>
                  </div>
                )}
              </div>

              <div>
                <div className="flex justify-between items-center mb-3">
                  <h4 className="font-medium">Line Items</h4>
                  <button
                    type="button"
                    onClick={addLine}
                    className="bg-green-600 text-white px-3 py-1 rounded text-sm hover:bg-green-700"
                  >
                    Add Line
                  </button>
                </div>
                <div className="border rounded overflow-hidden">
                  <table className="w-full">
                    <thead className="bg-gray-50">
                      <tr>
                        <th className="px-3 py-2 text-left text-sm">#</th>
                        <th className="px-3 py-2 text-left text-sm">Description</th>
                        <th className="px-3 py-2 text-left text-sm">Qty</th>
                        <th className="px-3 py-2 text-left text-sm">Unit</th>
                        <th className="px-3 py-2 text-left text-sm">Rate</th>
                        <th className="px-3 py-2 text-left text-sm">Total</th>
                        <th className="px-3 py-2 text-left text-sm">Action</th>
                      </tr>
                    </thead>
                    <tbody>
                      {lines.map((line, index) => (
                        <tr key={index} className="border-t">
                          <td className="px-3 py-2 text-sm">{line.line_number}</td>
                          <td className="px-3 py-2">
                            <input
                              type="text"
                              value={line.description}
                              onChange={(e) => {
                                const newLines = [...lines];
                                newLines[index].description = e.target.value;
                                setLines(newLines);
                              }}
                              className="w-full border rounded px-2 py-1 text-sm"
                              required
                            />
                          </td>
                          <td className="px-3 py-2">
                            <input
                              type="number"
                              value={line.quantity}
                              onChange={(e) => updateLineTotal(index, parseFloat(e.target.value) || 0, line.unit_rate)}
                              className="w-20 border rounded px-2 py-1 text-sm"
                              min="0"
                              step="0.01"
                              required
                            />
                          </td>
                          <td className="px-3 py-2">
                            <input
                              type="text"
                              value={line.unit}
                              onChange={(e) => {
                                const newLines = [...lines];
                                newLines[index].unit = e.target.value;
                                setLines(newLines);
                              }}
                              className="w-16 border rounded px-2 py-1 text-sm"
                              required
                            />
                          </td>
                          <td className="px-3 py-2">
                            <input
                              type="number"
                              value={line.unit_rate}
                              onChange={(e) => updateLineTotal(index, line.quantity, parseFloat(e.target.value) || 0)}
                              className="w-24 border rounded px-2 py-1 text-sm"
                              min="0"
                              step="0.01"
                              required
                            />
                          </td>
                          <td className="px-3 py-2 text-sm font-medium">
                            ${line.line_total.toFixed(2)}
                          </td>
                          <td className="px-3 py-2">
                            <button
                              type="button"
                              onClick={() => removeLine(index)}
                              className="text-red-600 hover:text-red-800 text-sm"
                              disabled={lines.length === 1}
                            >
                              Remove
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
                <div className="mt-3 text-right">
                  <span className="text-lg font-bold">
                    Total: ${lines.reduce((sum, line) => sum + line.line_total, 0).toFixed(2)}
                  </span>
                </div>
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
                  Create PO
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}