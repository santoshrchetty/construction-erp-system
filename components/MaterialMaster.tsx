'use client';

import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';

interface Material {
  id: string;
  item_code: string;
  description: string;
  category: string;
  unit: string;
  project_id?: string;
  material_type_id?: string;
  valuation_class_id?: string;
  is_active: boolean;
  project?: { name: string; code: string };
  material_type?: { material_type_code: string; material_type_name: string };
  valuation_class?: { valuation_class_code: string; valuation_class_name: string };
  plants?: any[];
}

export default function MaterialMaster() {
  const [materials, setMaterials] = useState<Material[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [editingMaterial, setEditingMaterial] = useState<Material | null>(null);
  const [projects, setProjects] = useState<any[]>([]);
  const [materialTypes, setMaterialTypes] = useState<any[]>([]);
  const [valuationClasses, setValuationClasses] = useState<any[]>([]);
  const [formData, setFormData] = useState({
    item_code: '',
    description: '',
    category: '',
    unit: 'EA',
    project_id: '',
    material_type_id: '',
    valuation_class_id: ''
  });

  useEffect(() => {
    fetchMaterials();
    fetchProjects();
    fetchMaterialTypes();
    fetchValuationClasses();
  }, []);

  const fetchMaterials = async () => {
    const { data } = await supabase
      .from('stock_items')
      .select(`
        *,
        project:projects(name, code),
        material_type:material_types(material_type_code, material_type_name),
        valuation_class:valuation_classes(valuation_class_code, valuation_class_name)
      `)
      .order('item_code');
    
    if (data) setMaterials(data);
  };

  const fetchMaterialTypes = async () => {
    const { data } = await supabase
      .from('material_types')
      .select('id, material_type_code, material_type_name')
      .eq('is_active', true);
    if (data) setMaterialTypes(data);
  };

  const fetchValuationClasses = async () => {
    const { data } = await supabase
      .from('valuation_classes')
      .select('id, valuation_class_code, valuation_class_name')
      .eq('is_active', true);
    if (data) setValuationClasses(data);
  };

  const fetchProjects = async () => {
    const { data } = await supabase
      .from('projects')
      .select('id, name, code')
      .eq('status', 'active');
    if (data) setProjects(data);
  };

  const saveMaterial = async (e: React.FormEvent) => {
    e.preventDefault();
    
    const materialData = {
      item_code: formData.item_code,
      description: formData.description,
      category: formData.category,
      unit: formData.unit,
      project_id: formData.project_id || null,
      material_type_id: formData.material_type_id || null,
      valuation_class_id: formData.valuation_class_id || null,
      reorder_level: 0,
      is_active: true
    };

    if (editingMaterial) {
      await supabase
        .from('stock_items')
        .update(materialData)
        .eq('id', editingMaterial.id);
    } else {
      await supabase
        .from('stock_items')
        .insert(materialData);
    }

    resetForm();
    fetchMaterials();
  };

  const deleteMaterial = async (id: string) => {
    if (confirm('Delete this material?')) {
      await supabase.from('stock_items').update({ is_active: false }).eq('id', id);
      fetchMaterials();
    }
  };

  const editMaterial = (material: Material) => {
    setEditingMaterial(material);
    setFormData({
      item_code: material.item_code,
      description: material.description,
      category: material.category || '',
      unit: material.unit,
      project_id: material.project_id || '',
      material_type_id: material.material_type_id || '',
      valuation_class_id: material.valuation_class_id || ''
    });
    setShowForm(true);
  };

  const resetForm = () => {
    setShowForm(false);
    setEditingMaterial(null);
    setFormData({
      item_code: '',
      description: '',
      category: '',
      unit: 'EA',
      project_id: '',
      material_type_id: '',
      valuation_class_id: ''
    });
  };

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold">Material Master</h1>
          <p className="text-gray-600">SAP-style material management | Normal Stock → Account Assignment 'Q' for Project Stock</p>
        </div>
        <button
          onClick={() => setShowForm(true)}
          className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
        >
          Add Material
        </button>
      </div>

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left">Code</th>
              <th className="px-4 py-3 text-left">Description</th>
              <th className="px-4 py-3 text-left">Material Type</th>
              <th className="px-4 py-3 text-left">Valuation Class</th>
              <th className="px-4 py-3 text-left">Unit</th>
              <th className="px-4 py-3 text-left">Account Assignment</th>
              <th className="px-4 py-3 text-left">Actions</th>
            </tr>
          </thead>
          <tbody>
            {materials.map((material) => (
              <tr key={material.id} className="border-t">
                <td className="px-4 py-3 font-mono text-sm">{material.item_code}</td>
                <td className="px-4 py-3">{material.description}</td>
                <td className="px-4 py-3">
                  <span className="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded">
                    {material.material_type?.material_type_code || 'ROH'}
                  </span>
                </td>
                <td className="px-4 py-3">
                  <span className="text-xs bg-purple-100 text-purple-800 px-2 py-1 rounded">
                    {material.valuation_class?.valuation_class_code || '3000'}
                  </span>
                </td>
                <td className="px-4 py-3">{material.unit}</td>
                <td className="px-4 py-3">
                  {material.project ? (
                    <span className="text-sm bg-blue-100 text-blue-800 px-2 py-1 rounded">
                      Q: {material.project.code}
                    </span>
                  ) : (
                    <span className="text-sm bg-green-100 text-green-800 px-2 py-1 rounded">Normal Stock</span>
                  )}
                </td>

                <td className="px-4 py-3">
                  <button
                    onClick={() => editMaterial(material)}
                    className="text-blue-600 hover:text-blue-800 mr-3"
                  >
                    Edit
                  </button>
                  <button
                    onClick={() => deleteMaterial(material.id)}
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
          <div className="bg-white rounded-lg p-6 w-full max-w-2xl">
            <h3 className="text-lg font-bold mb-4">
              {editingMaterial ? 'Edit Material' : 'Add Material'}
            </h3>
            <form onSubmit={saveMaterial} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Material Code</label>
                  <input
                    type="text"
                    value={formData.item_code}
                    onChange={(e) => setFormData({...formData, item_code: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Unit</label>
                  <select
                    value={formData.unit}
                    onChange={(e) => setFormData({...formData, unit: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  >
                    <option value="EA">Each</option>
                    <option value="KG">Kilogram</option>
                    <option value="M">Meter</option>
                    <option value="M2">Square Meter</option>
                    <option value="M3">Cubic Meter</option>
                    <option value="L">Liter</option>
                    <option value="TON">Ton</option>
                    <option value="BAG">Bag</option>
                  </select>
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Description</label>
                <input
                  type="text"
                  value={formData.description}
                  onChange={(e) => setFormData({...formData, description: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                  required
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Material Type</label>
                  <select
                    value={formData.material_type_id}
                    onChange={(e) => setFormData({...formData, material_type_id: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                    required
                  >
                    <option value="">Select Material Type</option>
                    {materialTypes.map((type) => (
                      <option key={type.id} value={type.id}>
                        {type.material_type_code} - {type.material_type_name}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Valuation Class</label>
                  <select
                    value={formData.valuation_class_id}
                    onChange={(e) => setFormData({...formData, valuation_class_id: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                    required
                  >
                    <option value="">Select Valuation Class</option>
                    {valuationClasses.map((vc) => (
                      <option key={vc.id} value={vc.id}>
                        {vc.valuation_class_code} - {vc.valuation_class_name}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Category</label>
                  <select
                    value={formData.category}
                    onChange={(e) => setFormData({...formData, category: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  >
                    <option value="">Select Category</option>
                    <option value="Cement">Cement</option>
                    <option value="Steel">Steel</option>
                    <option value="Aggregate">Aggregate</option>
                    <option value="Electrical">Electrical</option>
                    <option value="Plumbing">Plumbing</option>
                    <option value="Paint">Paint</option>
                    <option value="Hardware">Hardware</option>
                    <option value="Tools">Tools</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Account Assignment</label>
                  <select
                    value={formData.project_id}
                    onChange={(e) => setFormData({...formData, project_id: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  >
                    <option value="">Normal Stock (Unrestricted)</option>
                    {projects.map((project) => (
                      <option key={project.id} value={project.id}>
                        Q: {project.code} - {project.name}
                      </option>
                    ))}
                  </select>
                  <p className="text-xs text-gray-500 mt-1">
                    Normal Stock = Available to all projects | Q = Project-specific stock
                  </p>
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
                  {editingMaterial ? 'Update' : 'Create'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}