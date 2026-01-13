import React, { useState, useEffect } from 'react';
import { purchaseOrderService, PurchaseOrder } from '../../domains/purchase-orders/poServices-compatible';

const PurchaseOrderManagement: React.FC = () => {
  const [pos, setPOs] = useState<PurchaseOrder[]>([]);
  const [vendors, setVendors] = useState<any[]>([]);
  const [projects, setProjects] = useState<any[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [newPO, setNewPO] = useState({
    po_number: '',
    vendor_code: '',
    project_code: '',
    po_date: new Date().toISOString().split('T')[0],
    total_amount: 0,
    status: 'DRAFT' as const,
    created_by: 'current_user'
  });

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      const [posData, vendorsData, projectsData] = await Promise.all([
        purchaseOrderService.getAllPOs(),
        purchaseOrderService.getVendors(),
        purchaseOrderService.getProjects()
      ]);
      setPOs(posData);
      setVendors(vendorsData);
      setProjects(projectsData);
    } catch (error) {
      console.error('Error loading data:', error);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await purchaseOrderService.createPO(newPO);
      setShowForm(false);
      setNewPO({
        po_number: '',
        vendor_code: '',
        project_code: '',
        po_date: new Date().toISOString().split('T')[0],
        total_amount: 0,
        status: 'DRAFT',
        created_by: 'current_user'
      });
      loadData();
    } catch (error) {
      console.error('Error creating PO:', error);
    }
  };

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Purchase Orders</h1>
        <button
          onClick={() => setShowForm(true)}
          className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
        >
          Create PO
        </button>
      </div>

      {showForm && (
        <div className="mb-6 p-4 border rounded bg-gray-50">
          <h2 className="text-lg font-semibold mb-4">Create Purchase Order</h2>
          <form onSubmit={handleSubmit} className="grid grid-cols-2 gap-4">
            <input
              type="text"
              placeholder="PO Number"
              value={newPO.po_number}
              onChange={(e) => setNewPO({...newPO, po_number: e.target.value})}
              className="border p-2 rounded"
              required
            />
            <select
              value={newPO.vendor_code}
              onChange={(e) => setNewPO({...newPO, vendor_code: e.target.value})}
              className="border p-2 rounded"
              required
            >
              <option value="">Select Vendor</option>
              {vendors.map(v => (
                <option key={v.code} value={v.code}>{v.name}</option>
              ))}
            </select>
            <select
              value={newPO.project_code}
              onChange={(e) => setNewPO({...newPO, project_code: e.target.value})}
              className="border p-2 rounded"
              required
            >
              <option value="">Select Project</option>
              {projects.map(p => (
                <option key={p.project_code} value={p.project_code}>{p.project_name}</option>
              ))}
            </select>
            <input
              type="date"
              value={newPO.po_date}
              onChange={(e) => setNewPO({...newPO, po_date: e.target.value})}
              className="border p-2 rounded"
              required
            />
            <input
              type="number"
              placeholder="Total Amount"
              value={newPO.total_amount}
              onChange={(e) => setNewPO({...newPO, total_amount: parseFloat(e.target.value) || 0})}
              className="border p-2 rounded"
              step="0.01"
            />
            <div className="flex gap-2">
              <button type="submit" className="bg-green-500 text-white px-4 py-2 rounded">
                Create
              </button>
              <button
                type="button"
                onClick={() => setShowForm(false)}
                className="bg-gray-500 text-white px-4 py-2 rounded"
              >
                Cancel
              </button>
            </div>
          </form>
        </div>
      )}

      <div className="overflow-x-auto">
        <table className="min-w-full bg-white border">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-2 border text-left">PO Number</th>
              <th className="px-4 py-2 border text-left">Vendor</th>
              <th className="px-4 py-2 border text-left">Project</th>
              <th className="px-4 py-2 border text-left">Date</th>
              <th className="px-4 py-2 border text-left">Amount</th>
              <th className="px-4 py-2 border text-left">Status</th>
            </tr>
          </thead>
          <tbody>
            {pos.map(po => (
              <tr key={po.id} className="hover:bg-gray-50">
                <td className="px-4 py-2 border">{po.po_number}</td>
                <td className="px-4 py-2 border">{po.vendor_code}</td>
                <td className="px-4 py-2 border">{po.project_code}</td>
                <td className="px-4 py-2 border">{po.po_date}</td>
                <td className="px-4 py-2 border">₹{po.total_amount.toLocaleString()}</td>
                <td className="px-4 py-2 border">
                  <span className={`px-2 py-1 rounded text-sm ${
                    po.status === 'APPROVED' ? 'bg-green-100 text-green-800' :
                    po.status === 'DRAFT' ? 'bg-yellow-100 text-yellow-800' :
                    'bg-blue-100 text-blue-800'
                  }`}>
                    {po.status}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default PurchaseOrderManagement;