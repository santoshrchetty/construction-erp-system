'use client';

import React, { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase/client';

interface StockItem {
  id: string;
  item_code: string;
  description: string;
  category: string;
  unit: string;
  reorder_level: number;
  is_active: boolean;
}

interface StockBalance {
  id: string;
  store_id: string;
  stock_item_id: string;
  current_quantity: number;
  reserved_quantity: number;
  available_quantity: number;
  average_cost: number;
  total_value: number;
  stock_item?: StockItem;
  store?: { name: string; code: string };
}

interface StockMovement {
  id: string;
  movement_type: string;
  quantity: number;
  unit_cost: number;
  movement_date: string;
  reference_number: string;
  notes?: string;
  stock_item?: StockItem;
}

export default function InventoryManager({ projectId }: { projectId?: string }) {
  const [activeTab, setActiveTab] = useState<'items' | 'balances' | 'movements'>('balances');
  const [stockItems, setStockItems] = useState<StockItem[]>([]);
  const [stockBalances, setStockBalances] = useState<StockBalance[]>([]);
  const [stockMovements, setStockMovements] = useState<StockMovement[]>([]);
  const [stores, setStores] = useState<any[]>([]);
  const [showItemForm, setShowItemForm] = useState(false);
  const [showMovementForm, setShowMovementForm] = useState(false);
  const [itemForm, setItemForm] = useState({
    item_code: '',
    description: '',
    category: '',
    unit: 'EA',
    reorder_level: 0
  });
  const [movementForm, setMovementForm] = useState({
    store_id: '',
    stock_item_id: '',
    movement_type: 'receipt' as const,
    quantity: 0,
    unit_cost: 0,
    reference_number: '',
    notes: ''
  });

  useEffect(() => {
    fetchStockItems();
    fetchStockBalances();
    fetchStockMovements();
    fetchStores();
  }, [projectId]);

  const fetchStockItems = async () => {
    const { data } = await supabase
      .from('stock_items')
      .select('*')
      .eq('is_active', true)
      .order('item_code');
    if (data) setStockItems(data);
  };

  const fetchStockBalances = async () => {
    let query = supabase
      .from('stock_balances')
      .select(`
        *,
        stock_item:stock_items(*),
        store:stores(name, code)
      `)
      .order('current_quantity', { ascending: false });

    if (projectId) {
      query = query.eq('stores.project_id', projectId);
    }

    const { data } = await query;
    if (data) setStockBalances(data);
  };

  const fetchStockMovements = async () => {
    let query = supabase
      .from('stock_movements')
      .select(`
        *,
        stock_item:stock_items(*)
      `)
      .order('created_at', { ascending: false })
      .limit(100);

    const { data } = await query;
    if (data) setStockMovements(data);
  };

  const fetchStores = async () => {
    let query = supabase
      .from('stores')
      .select('*')
      .eq('is_active', true);

    if (projectId) {
      query = query.eq('project_id', projectId);
    }

    const { data } = await query;
    if (data) setStores(data);
  };

  const saveStockItem = async (e: React.FormEvent) => {
    e.preventDefault();
    
    await supabase
      .from('stock_items')
      .insert({
        ...itemForm,
        is_active: true
      });

    resetItemForm();
    fetchStockItems();
  };

  const saveStockMovement = async (e: React.FormEvent) => {
    e.preventDefault();
    
    const movementData = {
      ...movementForm,
      movement_date: new Date().toISOString().split('T')[0],
      created_by: null
    };

    await supabase
      .from('stock_movements')
      .insert(movementData);

    resetMovementForm();
    fetchStockMovements();
    fetchStockBalances();
  };

  const resetItemForm = () => {
    setShowItemForm(false);
    setItemForm({
      item_code: '',
      description: '',
      category: '',
      unit: 'EA',
      reorder_level: 0
    });
  };

  const resetMovementForm = () => {
    setShowMovementForm(false);
    setMovementForm({
      store_id: '',
      stock_item_id: '',
      movement_type: 'receipt',
      quantity: 0,
      unit_cost: 0,
      reference_number: '',
      notes: ''
    });
  };

  const getMovementTypeColor = (type: string) => {
    switch (type) {
      case 'receipt': return 'bg-green-100 text-green-800';
      case 'issue': return 'bg-red-100 text-red-800';
      case 'transfer': return 'bg-blue-100 text-blue-800';
      case 'adjustment': return 'bg-yellow-100 text-yellow-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getLowStockItems = () => {
    return stockBalances.filter(balance => 
      balance.current_quantity <= (balance.stock_item?.reorder_level || 0)
    );
  };

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Inventory Management</h1>
        <div className="flex space-x-2">
          <button
            onClick={() => setShowItemForm(true)}
            className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
          >
            Add Item
          </button>
          <button
            onClick={() => setShowMovementForm(true)}
            className="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700"
          >
            Record Movement
          </button>
        </div>
      </div>

      {/* Low Stock Alert */}
      {getLowStockItems().length > 0 && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
          <h3 className="text-red-800 font-medium mb-2">⚠️ Low Stock Alert</h3>
          <div className="text-red-700 text-sm">
            {getLowStockItems().length} items are below reorder level
          </div>
        </div>
      )}

      {/* Tabs */}
      <div className="border-b mb-6">
        <nav className="flex space-x-8">
          {[
            { key: 'balances', label: 'Stock Balances' },
            { key: 'movements', label: 'Movements' },
            { key: 'items', label: 'Items Master' }
          ].map((tab) => (
            <button
              key={tab.key}
              onClick={() => setActiveTab(tab.key as any)}
              className={`py-2 px-1 border-b-2 font-medium text-sm ${
                activeTab === tab.key
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </nav>
      </div>

      {/* Stock Balances Tab */}
      {activeTab === 'balances' && (
        <div className="bg-white rounded-lg shadow overflow-hidden">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left">Item Code</th>
                <th className="px-4 py-3 text-left">Description</th>
                <th className="px-4 py-3 text-left">Store</th>
                <th className="px-4 py-3 text-left">Current Qty</th>
                <th className="px-4 py-3 text-left">Available</th>
                <th className="px-4 py-3 text-left">Avg Cost</th>
                <th className="px-4 py-3 text-left">Total Value</th>
                <th className="px-4 py-3 text-left">Status</th>
              </tr>
            </thead>
            <tbody>
              {stockBalances.map((balance) => (
                <tr key={balance.id} className="border-t">
                  <td className="px-4 py-3 font-mono text-sm">{balance.stock_item?.item_code}</td>
                  <td className="px-4 py-3">{balance.stock_item?.description}</td>
                  <td className="px-4 py-3">{balance.store?.name}</td>
                  <td className="px-4 py-3 font-medium">{balance.current_quantity}</td>
                  <td className="px-4 py-3">{balance.available_quantity}</td>
                  <td className="px-4 py-3">${balance.average_cost.toFixed(2)}</td>
                  <td className="px-4 py-3 font-medium">${balance.total_value.toFixed(2)}</td>
                  <td className="px-4 py-3">
                    {balance.current_quantity <= (balance.stock_item?.reorder_level || 0) ? (
                      <span className="px-2 py-1 rounded text-xs bg-red-100 text-red-800">
                        Low Stock
                      </span>
                    ) : (
                      <span className="px-2 py-1 rounded text-xs bg-green-100 text-green-800">
                        In Stock
                      </span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Stock Movements Tab */}
      {activeTab === 'movements' && (
        <div className="bg-white rounded-lg shadow overflow-hidden">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left">Date</th>
                <th className="px-4 py-3 text-left">Item</th>
                <th className="px-4 py-3 text-left">Type</th>
                <th className="px-4 py-3 text-left">Quantity</th>
                <th className="px-4 py-3 text-left">Unit Cost</th>
                <th className="px-4 py-3 text-left">Reference</th>
                <th className="px-4 py-3 text-left">Notes</th>
              </tr>
            </thead>
            <tbody>
              {stockMovements.map((movement) => (
                <tr key={movement.id} className="border-t">
                  <td className="px-4 py-3 text-sm">{new Date(movement.movement_date).toLocaleDateString()}</td>
                  <td className="px-4 py-3">
                    <div className="text-sm">
                      <div className="font-mono">{movement.stock_item?.item_code}</div>
                      <div className="text-gray-500">{movement.stock_item?.description}</div>
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-1 rounded text-xs ${getMovementTypeColor(movement.movement_type)}`}>
                      {movement.movement_type}
                    </span>
                  </td>
                  <td className="px-4 py-3 font-medium">
                    {movement.movement_type === 'issue' ? '-' : '+'}{movement.quantity}
                  </td>
                  <td className="px-4 py-3">${movement.unit_cost.toFixed(2)}</td>
                  <td className="px-4 py-3 font-mono text-sm">{movement.reference_number}</td>
                  <td className="px-4 py-3 text-sm">{movement.notes}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Stock Items Tab */}
      {activeTab === 'items' && (
        <div className="bg-white rounded-lg shadow overflow-hidden">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left">Item Code</th>
                <th className="px-4 py-3 text-left">Description</th>
                <th className="px-4 py-3 text-left">Category</th>
                <th className="px-4 py-3 text-left">Unit</th>
                <th className="px-4 py-3 text-left">Reorder Level</th>
                <th className="px-4 py-3 text-left">Status</th>
              </tr>
            </thead>
            <tbody>
              {stockItems.map((item) => (
                <tr key={item.id} className="border-t">
                  <td className="px-4 py-3 font-mono text-sm">{item.item_code}</td>
                  <td className="px-4 py-3">{item.description}</td>
                  <td className="px-4 py-3">{item.category}</td>
                  <td className="px-4 py-3">{item.unit}</td>
                  <td className="px-4 py-3">{item.reorder_level}</td>
                  <td className="px-4 py-3">
                    <span className={`px-2 py-1 rounded text-xs ${
                      item.is_active ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
                    }`}>
                      {item.is_active ? 'Active' : 'Inactive'}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Add Item Form */}
      {showItemForm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-bold mb-4">Add Stock Item</h3>
            <form onSubmit={saveStockItem} className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1">Item Code</label>
                <input
                  type="text"
                  value={itemForm.item_code}
                  onChange={(e) => setItemForm({...itemForm, item_code: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Description</label>
                <input
                  type="text"
                  value={itemForm.description}
                  onChange={(e) => setItemForm({...itemForm, description: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                  required
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Category</label>
                  <input
                    type="text"
                    value={itemForm.category}
                    onChange={(e) => setItemForm({...itemForm, category: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Unit</label>
                  <select
                    value={itemForm.unit}
                    onChange={(e) => setItemForm({...itemForm, unit: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  >
                    <option value="EA">Each</option>
                    <option value="KG">Kilogram</option>
                    <option value="M">Meter</option>
                    <option value="M2">Square Meter</option>
                    <option value="M3">Cubic Meter</option>
                    <option value="L">Liter</option>
                  </select>
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Reorder Level</label>
                <input
                  type="number"
                  value={itemForm.reorder_level}
                  onChange={(e) => setItemForm({...itemForm, reorder_level: parseFloat(e.target.value) || 0})}
                  className="w-full border rounded px-3 py-2"
                  min="0"
                />
              </div>
              <div className="flex justify-end space-x-3">
                <button
                  type="button"
                  onClick={resetItemForm}
                  className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
                >
                  Add Item
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Record Movement Form */}
      {showMovementForm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-bold mb-4">Record Stock Movement</h3>
            <form onSubmit={saveStockMovement} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Store</label>
                  <select
                    value={movementForm.store_id}
                    onChange={(e) => setMovementForm({...movementForm, store_id: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                    required
                  >
                    <option value="">Select Store</option>
                    {stores.map((store) => (
                      <option key={store.id} value={store.id}>
                        {store.name}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Movement Type</label>
                  <select
                    value={movementForm.movement_type}
                    onChange={(e) => setMovementForm({...movementForm, movement_type: e.target.value as any})}
                    className="w-full border rounded px-3 py-2"
                  >
                    <option value="receipt">Receipt</option>
                    <option value="issue">Issue</option>
                    <option value="transfer">Transfer</option>
                    <option value="adjustment">Adjustment</option>
                  </select>
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Stock Item</label>
                <select
                  value={movementForm.stock_item_id}
                  onChange={(e) => setMovementForm({...movementForm, stock_item_id: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                  required
                >
                  <option value="">Select Item</option>
                  {stockItems.map((item) => (
                    <option key={item.id} value={item.id}>
                      {item.item_code} - {item.description}
                    </option>
                  ))}
                </select>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Quantity</label>
                  <input
                    type="number"
                    value={movementForm.quantity}
                    onChange={(e) => setMovementForm({...movementForm, quantity: parseFloat(e.target.value) || 0})}
                    className="w-full border rounded px-3 py-2"
                    min="0"
                    step="0.01"
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Unit Cost</label>
                  <input
                    type="number"
                    value={movementForm.unit_cost}
                    onChange={(e) => setMovementForm({...movementForm, unit_cost: parseFloat(e.target.value) || 0})}
                    className="w-full border rounded px-3 py-2"
                    min="0"
                    step="0.01"
                    required
                  />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Reference Number</label>
                <input
                  type="text"
                  value={movementForm.reference_number}
                  onChange={(e) => setMovementForm({...movementForm, reference_number: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Notes</label>
                <textarea
                  value={movementForm.notes}
                  onChange={(e) => setMovementForm({...movementForm, notes: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                  rows={2}
                />
              </div>
              <div className="flex justify-end space-x-3">
                <button
                  type="button"
                  onClick={resetMovementForm}
                  className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700"
                >
                  Record Movement
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}