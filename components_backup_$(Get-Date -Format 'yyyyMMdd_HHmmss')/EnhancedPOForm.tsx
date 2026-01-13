import React, { useState, useEffect } from 'react';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';

interface POItem {
  id?: number;
  material_code: string;
  material_description: string;
  quantity: number;
  unit: string;
  unit_price: number;
  tax_code: string;
  account_assignment_category: string;
  account_assignment_object: string;
  line_total: number;
  tax_amount: number;
  net_amount: number;
}

interface PurchaseOrder {
  po_number: string;
  vendor_code: string;
  project_code: string;
  po_date: string;
  delivery_date: string;
  po_type: string;
  items: POItem[];
  total_amount: number;
  tax_amount: number;
  net_amount: number;
}

export default function EnhancedPOForm() {
  const [po, setPO] = useState<PurchaseOrder>({
    po_number: '',
    vendor_code: '',
    project_code: '',
    po_date: new Date().toISOString().split('T')[0],
    delivery_date: '',
    po_type: 'STANDARD',
    items: [],
    total_amount: 0,
    tax_amount: 0,
    net_amount: 0
  });

  const [vendors, setVendors] = useState([]);
  const [projects, setProjects] = useState([]);
  const [materials, setMaterials] = useState([]);
  const [taxCodes, setTaxCodes] = useState([]);
  const [costCenters, setCostCenters] = useState([]);

  useEffect(() => {
    loadMasterData();
    generatePONumber();
  }, []);

  const loadMasterData = async () => {
    try {
      const [vendorsRes, projectsRes, materialsRes, taxRes, ccRes] = await Promise.all([
        fetch('/api/suppliers'),
        fetch('/api/projects'),
        fetch('/api/materials'),
        fetch('/api/tax-codes'),
        fetch('/api/cost-centers')
      ]);
      
      const vendorsData = await vendorsRes.json();
      const projectsData = await projectsRes.json();
      const materialsData = await materialsRes.json();
      const taxData = await taxRes.json();
      const ccData = await ccRes.json();
      
      setVendors(vendorsData.data || []);
      setProjects(projectsData.data || []);
      setMaterials(materialsData.data || []);
      setTaxCodes(taxData.data || []);
      setCostCenters(ccData.data || []);
    } catch (error) {
      console.error('Error loading master data:', error);
    }
  };

  const generatePONumber = () => {
    const year = new Date().getFullYear().toString().slice(-2);
    const month = (new Date().getMonth() + 1).toString().padStart(2, '0');
    const random = Math.floor(Math.random() * 9999).toString().padStart(4, '0');
    setPO(prev => ({ ...prev, po_number: `PO${year}${month}${random}` }));
  };

  const addItem = () => {
    const newItem: POItem = {
      material_code: '',
      material_description: '',
      quantity: 1,
      unit: 'EA',
      unit_price: 0,
      tax_code: 'GST18',
      account_assignment_category: 'K',
      account_assignment_object: '',
      line_total: 0,
      tax_amount: 0,
      net_amount: 0
    };
    setPO(prev => ({ ...prev, items: [...prev.items, newItem] }));
  };

  const updateItem = (index: number, field: keyof POItem, value: any) => {
    const updatedItems = [...po.items];
    updatedItems[index] = { ...updatedItems[index], [field]: value };
    
    // Auto-calculate totals
    if (['quantity', 'unit_price', 'tax_code'].includes(field)) {
      const item = updatedItems[index];
      item.line_total = item.quantity * item.unit_price;
      const taxRate = taxCodes.find(t => t.tax_code === item.tax_code)?.tax_rate || 18;
      item.tax_amount = item.line_total * taxRate / 100;
      item.net_amount = item.line_total + item.tax_amount;
    }
    
    setPO(prev => ({ ...prev, items: updatedItems }));
    calculateTotals(updatedItems);
  };

  const calculateTotals = (items: POItem[]) => {
    const total_amount = items.reduce((sum, item) => sum + item.line_total, 0);
    const tax_amount = items.reduce((sum, item) => sum + item.tax_amount, 0);
    const net_amount = total_amount + tax_amount;
    
    setPO(prev => ({ ...prev, total_amount, tax_amount, net_amount }));
  };

  const savePO = async () => {
    try {
      const response = await fetch('/api/purchase?action=create', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          ...po,
          created_by: 'current_user',
          status: 'DRAFT'
        })
      });
      
      const result = await response.json();
      if (result.success) {
        alert('Purchase Order saved successfully!');
      } else {
        alert('Error: ' + (result.error || 'Unknown error'));
      }
    } catch (error) {
      console.error('Error saving PO:', error);
      alert('Error saving Purchase Order');
    }
  };

  return (
    <div className="p-6 max-w-6xl mx-auto">
      <Card>
        <CardHeader>
          <CardTitle>Create Purchase Order</CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Header */}
          <div className="grid grid-cols-4 gap-4">
            <div>
              <label className="block text-sm font-medium mb-1">PO Number</label>
              <Input value={po.po_number} readOnly className="bg-gray-50" />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Vendor</label>
              <Select value={po.vendor_code} onValueChange={(value) => setPO(prev => ({ ...prev, vendor_code: value }))}>
                <SelectTrigger>
                  <SelectValue placeholder="Select vendor" />
                </SelectTrigger>
                <SelectContent>
                  {vendors.map((vendor: any) => (
                    <SelectItem key={vendor.supplier_code || vendor.vendor_code} value={vendor.supplier_code || vendor.vendor_code}>
                      {vendor.supplier_name || vendor.vendor_name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Project</label>
              <Select value={po.project_code} onValueChange={(value) => setPO(prev => ({ ...prev, project_code: value }))}>
                <SelectTrigger>
                  <SelectValue placeholder="Select project" />
                </SelectTrigger>
                <SelectContent>
                  {projects.map((project: any) => (
                    <SelectItem key={project.project_code} value={project.project_code}>
                      {project.project_name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">PO Type</label>
              <Select value={po.po_type} onValueChange={(value) => setPO(prev => ({ ...prev, po_type: value }))}>
                <SelectTrigger>
                  <SelectValue placeholder="Select PO type" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="STANDARD">Standard PO</SelectItem>
                  <SelectItem value="EMERGENCY">Emergency PO</SelectItem>
                  <SelectItem value="BLANKET">Blanket PO</SelectItem>
                  <SelectItem value="INTERNAL">Internal Transfer</SelectItem>
                  <SelectItem value="PETTY_CASH">Petty Cash</SelectItem>
                  <SelectItem value="MAINTENANCE">Maintenance</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Delivery Date</label>
              <Input 
                type="date" 
                value={po.delivery_date}
                onChange={(e) => setPO(prev => ({ ...prev, delivery_date: e.target.value }))}
              />
            </div>
          </div>

          {/* Items */}
          <div>
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-medium">Line Items</h3>
              <Button onClick={addItem}>Add Item</Button>
            </div>
            
            <div className="space-y-4">
              {po.items.map((item, index) => (
                <div key={index} className="grid grid-cols-8 gap-2 p-4 border rounded">
                  <div>
                    <Select value={item.material_code} onValueChange={(value) => updateItem(index, 'material_code', value)}>
                      <SelectTrigger>
                        <SelectValue placeholder="Material" />
                      </SelectTrigger>
                      <SelectContent>
                        {materials.map((material: any) => (
                          <SelectItem key={material.material_code} value={material.material_code}>
                            {material.material_code}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <Input 
                    placeholder="Quantity"
                    type="number"
                    value={item.quantity}
                    onChange={(e) => updateItem(index, 'quantity', parseFloat(e.target.value) || 0)}
                  />
                  <Input 
                    placeholder="Unit Price"
                    type="number"
                    value={item.unit_price}
                    onChange={(e) => updateItem(index, 'unit_price', parseFloat(e.target.value) || 0)}
                  />
                  <Select value={item.tax_code} onValueChange={(value) => updateItem(index, 'tax_code', value)}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {taxCodes.map((tax: any) => (
                        <SelectItem key={tax.tax_code} value={tax.tax_code}>
                          {tax.tax_name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  <Select value={item.account_assignment_category} onValueChange={(value) => updateItem(index, 'account_assignment_category', value)}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="K">Cost Center</SelectItem>
                      <SelectItem value="P">Project</SelectItem>
                      <SelectItem value="A">Asset</SelectItem>
                      <SelectItem value="O">Order</SelectItem>
                    </SelectContent>
                  </Select>
                  <Input 
                    placeholder="Assignment Object"
                    value={item.account_assignment_object}
                    onChange={(e) => updateItem(index, 'account_assignment_object', e.target.value)}
                  />
                  <div className="text-right font-medium">₹{item.line_total.toFixed(2)}</div>
                  <div className="text-right font-medium">₹{item.net_amount.toFixed(2)}</div>
                </div>
              ))}
            </div>
          </div>

          {/* Totals */}
          <div className="border-t pt-4">
            <div className="flex justify-end space-x-8">
              <div>Total: ₹{po.total_amount.toFixed(2)}</div>
              <div>Tax: ₹{po.tax_amount.toFixed(2)}</div>
              <div className="font-bold">Net: ₹{po.net_amount.toFixed(2)}</div>
            </div>
          </div>

          {/* Actions */}
          <div className="flex justify-end space-x-4">
            <Button variant="outline">Save as Draft</Button>
            <Button onClick={savePO}>Create PO</Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}