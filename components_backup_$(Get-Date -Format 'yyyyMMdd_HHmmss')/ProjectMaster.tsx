'use client';

import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { useSearchParams } from 'next/navigation';

interface Project {
  id: string;
  name: string;
  code: string;
  description?: string;
  project_type: string;
  status: string;
  start_date: string;
  planned_end_date: string;
  actual_end_date?: string;
  budget: number;
  location?: string;
  company_code_id?: string;
  purchasing_org_id?: string;
  plant_id?: string;
  company?: { company_code: string; company_name: string };
  purchasing_org?: { porg_code: string; porg_name: string };
}

export default function ProjectMaster() {
  const searchParams = useSearchParams()
  const action = searchParams.get('action')
  const [projects, setProjects] = useState<Project[]>([]);
  const [showForm, setShowForm] = useState(action === 'create');
  const [editingProject, setEditingProject] = useState<Project | null>(null);
  const [companyCodes, setCompanyCodes] = useState<any[]>([]);
  const [purchasingOrgs, setPurchasingOrgs] = useState<any[]>([]);
  const [formData, setFormData] = useState({
    name: '',
    code: '',
    description: '',
    project_type: 'commercial',
    status: 'planning',
    start_date: '',
    planned_end_date: '',
    budget: 0,
    location: '',
    company_code_id: '',
    purchasing_org_id: ''
  });

  useEffect(() => {
    fetchProjects();
    fetchCompanyCodes();
    fetchPurchasingOrgs();
  }, []);

  const fetchProjects = async () => {
    const { data } = await supabase
      .from('projects')
      .select(`
        *,
        company:company_codes(company_code, company_name),
        purchasing_org:purchasing_organizations(porg_code, porg_name)
      `)
      .order('created_at', { ascending: false });
    
    if (data) setProjects(data);
  };

  const fetchCompanyCodes = async () => {
    const { data } = await supabase
      .from('company_codes')
      .select('id, company_code, company_name')
      .eq('is_active', true);
    if (data) setCompanyCodes(data);
  };

  const fetchPurchasingOrgs = async () => {
    const { data } = await supabase
      .from('purchasing_organizations')
      .select('id, porg_code, porg_name')
      .eq('is_active', true);
    if (data) setPurchasingOrgs(data);
  };

  const saveProject = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (editingProject) {
      await supabase
        .from('projects')
        .update(formData)
        .eq('id', editingProject.id);
    } else {
      await supabase
        .from('projects')
        .insert(formData);
    }

    resetForm();
    fetchProjects();
  };

  const deleteProject = async (id: string) => {
    if (confirm('Delete this project? This will also delete all related data.')) {
      await supabase.from('projects').delete().eq('id', id);
      fetchProjects();
    }
  };

  const editProject = (project: Project) => {
    setEditingProject(project);
    setFormData({
      name: project.name,
      code: project.code,
      description: project.description || '',
      project_type: project.project_type,
      status: project.status,
      start_date: project.start_date,
      planned_end_date: project.planned_end_date,
      budget: project.budget,
      location: project.location || '',
      company_code_id: project.company_code_id || '',
      purchasing_org_id: project.purchasing_org_id || ''
    });
    setShowForm(true);
  };

  const resetForm = () => {
    setShowForm(false);
    setEditingProject(null);
    setFormData({
      name: '',
      code: '',
      description: '',
      project_type: 'commercial',
      status: 'planning',
      start_date: '',
      planned_end_date: '',
      budget: 0,
      location: '',
      company_code_id: '',
      purchasing_org_id: ''
    });
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active': return 'bg-green-100 text-green-800';
      case 'completed': return 'bg-blue-100 text-blue-800';
      case 'on_hold': return 'bg-yellow-100 text-yellow-800';
      case 'cancelled': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold">
            {action === 'create' ? 'Create New Project' : 
             action === 'edit' ? 'Modify Projects' : 'Project Master'}
          </h1>
          <p className="text-gray-600">
            {action === 'create' ? 'Add a new construction project' :
             action === 'edit' ? 'Edit existing project details' :
             'Manage all construction projects'}
          </p>
        </div>
        {action !== 'create' && (
          <button
            onClick={() => setShowForm(true)}
            className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
          >
            Add Project
          </button>
        )}
      </div>

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left">Code</th>
              <th className="px-4 py-3 text-left">Name</th>
              <th className="px-4 py-3 text-left">Company</th>
              <th className="px-4 py-3 text-left">Type</th>
              <th className="px-4 py-3 text-left">Status</th>
              <th className="px-4 py-3 text-left">Budget</th>
              <th className="px-4 py-3 text-left">Actions</th>
            </tr>
          </thead>
          <tbody>
            {projects.map((project) => (
              <tr key={project.id} className="border-t">
                <td className="px-4 py-3 font-mono text-sm">{project.code}</td>
                <td className="px-4 py-3 font-medium">{project.name}</td>
                <td className="px-4 py-3">
                  <span className="text-sm bg-blue-100 text-blue-800 px-2 py-1 rounded">
                    {project.company?.company_code || 'C001'}
                  </span>
                </td>
                <td className="px-4 py-3 capitalize">{project.project_type}</td>
                <td className="px-4 py-3">
                  <span className={`px-2 py-1 rounded text-xs ${getStatusColor(project.status)}`}>
                    {project.status.replace('_', ' ')}
                  </span>
                </td>
                <td className="px-4 py-3 font-medium">${project.budget.toLocaleString()}</td>
                <td className="px-4 py-3">
                  <button
                    onClick={() => editProject(project)}
                    className="text-blue-600 hover:text-blue-800 mr-3"
                  >
                    Edit
                  </button>
                  <button
                    onClick={() => deleteProject(project.id)}
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
              {editingProject ? 'Edit Project' : 'Add Project'}
            </h3>
            <form onSubmit={saveProject} className="space-y-4">
              <div className="grid grid-cols-3 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Company Code</label>
                  <select
                    value={formData.company_code_id}
                    onChange={(e) => setFormData({...formData, company_code_id: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                    required
                  >
                    <option value="">Select Company</option>
                    {companyCodes.map((company) => (
                      <option key={company.id} value={company.id}>
                        {company.company_code} - {company.company_name}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Purchasing Org</label>
                  <select
                    value={formData.purchasing_org_id}
                    onChange={(e) => setFormData({...formData, purchasing_org_id: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                    required
                  >
                    <option value="">Select Purch Org</option>
                    {purchasingOrgs.map((org) => (
                      <option key={org.id} value={org.id}>
                        {org.porg_code} - {org.porg_name}
                      </option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Project Code</label>
                  <input
                    type="text"
                    value={formData.code}
                    onChange={(e) => setFormData({...formData, code: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                    required
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Project Type</label>
                  <select
                    value={formData.project_type}
                    onChange={(e) => setFormData({...formData, project_type: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  >
                    <option value="residential">Residential</option>
                    <option value="commercial">Commercial</option>
                    <option value="infrastructure">Infrastructure</option>
                    <option value="industrial">Industrial</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Status</label>
                  <select
                    value={formData.status}
                    onChange={(e) => setFormData({...formData, status: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  >
                    <option value="planning">Planning</option>
                    <option value="active">Active</option>
                    <option value="on_hold">On Hold</option>
                    <option value="completed">Completed</option>
                    <option value="cancelled">Cancelled</option>
                  </select>
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Project Name</label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) => setFormData({...formData, name: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Description</label>
                <textarea
                  value={formData.description}
                  onChange={(e) => setFormData({...formData, description: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                  rows={3}
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Budget</label>
                <input
                  type="number"
                  value={formData.budget}
                  onChange={(e) => setFormData({...formData, budget: parseFloat(e.target.value) || 0})}
                  className="w-full border rounded px-3 py-2"
                  min="0"
                  step="0.01"
                  required
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Start Date</label>
                  <input
                    type="date"
                    value={formData.start_date}
                    onChange={(e) => setFormData({...formData, start_date: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Planned End Date</label>
                  <input
                    type="date"
                    value={formData.planned_end_date}
                    onChange={(e) => setFormData({...formData, planned_end_date: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                    required
                  />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Location</label>
                <input
                  type="text"
                  value={formData.location}
                  onChange={(e) => setFormData({...formData, location: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                />
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
                  {editingProject ? 'Update' : 'Create'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}