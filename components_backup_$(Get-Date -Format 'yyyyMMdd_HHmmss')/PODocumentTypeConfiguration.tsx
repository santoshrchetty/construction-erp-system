import React, { useState, useEffect } from 'react';

interface PODocumentType {
  document_type: string;
  type_name: string;
  description: string;
  approval_required: boolean;
  auto_approve_limit: number;
  goods_receipt_required: boolean;
  invoice_receipt_required: boolean;
  workflow_template: string;
  field_selection: any;
  default_values: any;
  is_active: boolean;
}

export default function PODocumentTypeConfiguration() {
  const [documentTypes, setDocumentTypes] = useState<PODocumentType[]>([]);
  const [selectedType, setSelectedType] = useState<PODocumentType | null>(null);
  const [isEditing, setIsEditing] = useState(false);

  const [formData, setFormData] = useState({
    document_type: '',
    type_name: '',
    description: '',
    approval_required: true,
    auto_approve_limit: 0,
    goods_receipt_required: true,
    invoice_receipt_required: true,
    workflow_template: 'STANDARD_PO',
    is_active: true
  });

  useEffect(() => {
    loadDocumentTypes();
  }, []);

  const loadDocumentTypes = async () => {
    try {
      const response = await fetch('/api/po-document-types');
      const data = await response.json();
      setDocumentTypes(data.data || []);
    } catch (error) {
      console.error('Error loading document types:', error);
    }
  };

  const saveDocumentType = async () => {
    try {
      const response = await fetch('/api/po-document-types', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      });

      if (response.ok) {
        alert('Document type saved successfully!');
        loadDocumentTypes();
        resetForm();
      }
    } catch (error) {
      console.error('Error saving document type:', error);
    }
  };

  const resetForm = () => {
    setFormData({
      document_type: '',
      type_name: '',
      description: '',
      approval_required: true,
      auto_approve_limit: 0,
      goods_receipt_required: true,
      invoice_receipt_required: true,
      workflow_template: 'STANDARD_PO',
      is_active: true
    });
    setSelectedType(null);
    setIsEditing(false);
  };

  const editDocumentType = (docType: PODocumentType) => {
    setFormData({
      document_type: docType.document_type,
      type_name: docType.type_name,
      description: docType.description,
      approval_required: docType.approval_required,
      auto_approve_limit: docType.auto_approve_limit,
      goods_receipt_required: docType.goods_receipt_required,
      invoice_receipt_required: docType.invoice_receipt_required,
      workflow_template: docType.workflow_template,
      is_active: docType.is_active
    });
    setSelectedType(docType);
    setIsEditing(true);
  };

  return (
    <div className="p-6 max-w-6xl mx-auto space-y-6">
      <div className="bg-white border rounded-lg shadow">
        <div className="px-6 py-4 border-b">
          <h2 className="text-xl font-semibold">PO Document Type Configuration (SAP-Style)</h2>
        </div>
        <div className="p-6">
          <div className="grid grid-cols-2 gap-6">
            {/* Configuration Form */}
            <div className="space-y-4">
              <h3 className="text-lg font-medium">
                {isEditing ? 'Edit Document Type' : 'Create New Document Type'}
              </h3>
              
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Document Type (4 chars)</label>
                  <input
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                    value={formData.document_type}
                    onChange={(e) => setFormData(prev => ({ ...prev, document_type: e.target.value.toUpperCase() }))}
                    maxLength={4}
                    placeholder="e.g., NB, EM, BL"
                    disabled={isEditing}
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Type Name</label>
                  <input
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                    value={formData.type_name}
                    onChange={(e) => setFormData(prev => ({ ...prev, type_name: e.target.value }))}
                    placeholder="Standard Purchase Order"
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium mb-1">Description</label>
                <textarea
                  value={formData.description}
                  onChange={(e) => setFormData(prev => ({ ...prev, description: e.target.value }))}
                  placeholder="Detailed description of this PO type"
                  rows={2}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Workflow Template</label>
                  <select 
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                    value={formData.workflow_template} 
                    onChange={(e) => setFormData(prev => ({ ...prev, workflow_template: e.target.value }))}
                  >
                    <option value="STANDARD_PO">Standard PO</option>
                    <option value="EMERGENCY_PO">Emergency PO</option>
                    <option value="BLANKET_PO">Blanket PO</option>
                    <option value="SERVICE_PO">Service PO</option>
                    <option value="INTERNAL_PO">Internal PO</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Auto-Approve Limit ($)</label>
                  <input
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                    type="number"
                    value={formData.auto_approve_limit}
                    onChange={(e) => setFormData(prev => ({ ...prev, auto_approve_limit: parseFloat(e.target.value) || 0 }))}
                    placeholder="0"
                  />
                </div>
              </div>

              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <label className="text-sm font-medium">Approval Required</label>
                  <input
                    type="checkbox"
                    checked={formData.approval_required}
                    onChange={(e) => setFormData(prev => ({ ...prev, approval_required: e.target.checked }))}
                    className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                </div>
                <div className="flex items-center justify-between">
                  <label className="text-sm font-medium">Goods Receipt Required</label>
                  <input
                    type="checkbox"
                    checked={formData.goods_receipt_required}
                    onChange={(e) => setFormData(prev => ({ ...prev, goods_receipt_required: e.target.checked }))}
                    className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                </div>
                <div className="flex items-center justify-between">
                  <label className="text-sm font-medium">Invoice Receipt Required</label>
                  <input
                    type="checkbox"
                    checked={formData.invoice_receipt_required}
                    onChange={(e) => setFormData(prev => ({ ...prev, invoice_receipt_required: e.target.checked }))}
                    className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                </div>
                <div className="flex items-center justify-between">
                  <label className="text-sm font-medium">Active</label>
                  <input
                    type="checkbox"
                    checked={formData.is_active}
                    onChange={(e) => setFormData(prev => ({ ...prev, is_active: e.target.checked }))}
                    className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                </div>
              </div>

              <div className="flex space-x-4">
                <button 
                  onClick={saveDocumentType}
                  className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
                >
                  {isEditing ? 'Update' : 'Create'} Document Type
                </button>
                {isEditing && (
                  <button 
                    onClick={resetForm}
                    className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50"
                  >
                    Cancel
                  </button>
                )}
              </div>
            </div>

            {/* Document Types List */}
            <div>
              <h3 className="text-lg font-medium mb-4">Existing Document Types</h3>
              <div className="space-y-2 max-h-96 overflow-y-auto">
                {documentTypes.map((docType) => (
                  <div key={docType.document_type} className="p-3 border rounded cursor-pointer hover:bg-gray-50"
                       onClick={() => editDocumentType(docType)}>
                    <div className="flex justify-between items-start">
                      <div>
                        <div className="font-medium">{docType.document_type} - {docType.type_name}</div>
                        <div className="text-sm text-gray-600">{docType.description}</div>
                        <div className="text-xs text-gray-500 mt-1">
                          Approval: {docType.approval_required ? 'Required' : 'Not Required'} | 
                          Auto-approve: ${docType.auto_approve_limit?.toLocaleString()}
                        </div>
                      </div>
                      <div className={`px-2 py-1 rounded text-xs ${docType.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
                        {docType.is_active ? 'Active' : 'Inactive'}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}