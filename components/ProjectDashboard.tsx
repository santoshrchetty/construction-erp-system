import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';

interface Project {
  id: string;
  name: string;
  code: string;
  status: string;
  budget: number;
  start_date: string;
  planned_end_date: string;
  project_type: string;
  progress?: number;
  task_count?: number;
  activity_count?: number;
}

export default function ProjectDashboard({ 
  onProjectSelect, 
  onNewProject 
}: { 
  onProjectSelect?: (projectId: string, projectName: string) => void;
  onNewProject?: () => void;
}) {
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState<{show: boolean, project: Project | null}>({show: false, project: null});
  const [showCopyConfirm, setShowCopyConfirm] = useState<{show: boolean, project: Project | null, nextCode: string}>({show: false, project: null, nextCode: ''});
  const [showEditForm, setShowEditForm] = useState<{show: boolean, project: Project | null}>({show: false, project: null});
  const [editFormData, setEditFormData] = useState({
    name: '',
    budget: 0,
    start_date: '',
    planned_end_date: '',
    status: 'planning'
  });

  useEffect(() => {
    fetchProjects();
  }, []);

  const fetchProjects = async () => {
    try {
      const { data, error } = await supabase
        .from('projects')
        .select(`
          id, name, code, status, budget, start_date, planned_end_date, project_type,
          activities(id),
          tasks(progress_percentage)
        `)
        .order('created_at', { ascending: false });

      if (error) throw error;

      const projectsWithStats = data?.map(project => ({
        ...project,
        progress: project.tasks?.length > 0 
          ? project.tasks.reduce((sum: number, task: any) => sum + (task.progress_percentage || 0), 0) / project.tasks.length
          : 0,
        task_count: project.tasks?.length || 0,
        activity_count: project.activities?.length || 0
      })) || [];

      setProjects(projectsWithStats);
    } catch (error) {
      console.error('Error fetching projects:', error);
    } finally {
      setLoading(false);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active': return 'bg-green-500';
      case 'planning': return 'bg-blue-500';
      case 'on_hold': return 'bg-yellow-500';
      case 'completed': return 'bg-gray-500';
      default: return 'bg-gray-300';
    }
  };

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'airport': return '✈️';
      case 'bridge': return '🌉';
      case 'building': return '🏢';
      case 'road': return '🛣️';
      case 'residential': return '🏠';
      case 'commercial': return '🏬';
      case 'industrial': return '🏭';
      default: return '🏗️';
    }
  };

  const generateNextProjectCode = (sourceProject: Project) => {
    const year = new Date().getFullYear().toString().slice(-2);
    
    // Get type prefix from source project's existing code if available
    let typePrefix;
    if (sourceProject.code && sourceProject.code.includes('-')) {
      typePrefix = sourceProject.code.split('-')[0];
    } else {
      // Fallback to project_type mapping
      typePrefix = {
        'airport': 'AIR',
        'bridge': 'BRD', 
        'building': 'BLD',
        'road': 'RD',
        'residential': 'RES',
        'commercial': 'COM',
        'industrial': 'IND'
      }[sourceProject.project_type] || 'PRJ';
    }
    
    console.log('=== PROJECT CODE GENERATION DEBUG ===');
    console.log('Source project:', sourceProject.name, sourceProject.code);
    console.log('Using type prefix:', typePrefix);
    console.log('Current year:', year);
    console.log('All project codes:', projects.map(p => p.code));
    
    // Filter existing codes by same type prefix and year
    const sameTypePattern = new RegExp(`^${typePrefix}-${year}-(\\d+)$`);
    console.log('Pattern:', sameTypePattern.toString());
    
    const allCodes = projects.map(p => p.code).filter(code => code && code.trim());
    console.log('Valid codes:', allCodes);
    
    const matchingCodes = allCodes.filter(code => {
      const matches = sameTypePattern.test(code);
      console.log(`Testing ${code} against pattern: ${matches}`);
      return matches;
    });
    
    console.log('Matching codes:', matchingCodes);
    
    const existingSequences = matchingCodes
      .map(code => {
        const match = code.match(sameTypePattern);
        const seq = match ? parseInt(match[1]) : 0;
        console.log(`Extracting sequence from ${code}: ${seq}`);
        return seq;
      })
      .filter(seq => seq > 0)
      .sort((a, b) => a - b);
    
    console.log('Existing sequences:', existingSequences);
    
    // Find the highest sequence number and add 1
    const maxSequence = existingSequences.length > 0 ? Math.max(...existingSequences) : 0;
    const sequence = maxSequence + 1;
    
    console.log('Max sequence found:', maxSequence);
    console.log('Next sequence:', sequence);
    
    const newCode = `${typePrefix}-${year}-${sequence.toString().padStart(2, '0')}`;
    console.log('Final generated code:', newCode);
    console.log('=== END DEBUG ===');
    
    return newCode;
  };

  const showCopyConfirmation = (sourceProject: Project) => {
    const nextCode = generateNextProjectCode(sourceProject);
    setShowCopyConfirm({show: true, project: sourceProject, nextCode});
  };

  const copyProject = async () => {
    if (!showCopyConfirm.project) return;
    
    try {
      const sourceProject = showCopyConfirm.project;
      const newCode = showCopyConfirm.nextCode;

      const { data: newProject, error } = await supabase
        .from('projects')
        .insert({
          name: `${sourceProject.name} (Copy)`,
          code: newCode,
          project_type: sourceProject.project_type,
          status: 'planning',
          budget: sourceProject.budget,
          start_date: new Date().toISOString().split('T')[0],
          planned_end_date: sourceProject.planned_end_date
        })
        .select()
        .single();

      if (error) throw error;

      const { data: wbsNodes } = await supabase
        .from('wbs_nodes')
        .select('*')
        .eq('project_id', sourceProject.id);

      if (wbsNodes && wbsNodes.length > 0) {
        const wbsMapping = new Map();
        
        for (const node of wbsNodes) {
          const { data: newNode } = await supabase
            .from('wbs_nodes')
            .insert({
              project_id: newProject.id,
              code: node.code.replace(sourceProject.code, newCode),
              name: node.name,
              node_type: node.node_type,
              level: node.level,
              sequence_order: node.sequence_order,
              parent_id: node.parent_id ? wbsMapping.get(node.parent_id) : null
            })
            .select()
            .single();
          
          if (newNode) wbsMapping.set(node.id, newNode.id);
        }
      }

      setShowCopyConfirm({show: false, project: null, nextCode: ''});
      fetchProjects();
    } catch (error) {
      console.error('Error copying project:', error);
    }
  };

  const showEditProject = (project: Project) => {
    setEditFormData({
      name: project.name,
      budget: project.budget,
      start_date: project.start_date,
      planned_end_date: project.planned_end_date,
      status: project.status
    });
    setShowEditForm({show: true, project});
  };

  const updateProject = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!showEditForm.project) return;

    try {
      const { error } = await supabase
        .from('projects')
        .update({
          name: editFormData.name,
          budget: editFormData.budget,
          start_date: editFormData.start_date,
          planned_end_date: editFormData.planned_end_date,
          status: editFormData.status
        })
        .eq('id', showEditForm.project.id);

      if (error) throw error;
      
      setShowEditForm({show: false, project: null});
      fetchProjects();
    } catch (error) {
      console.error('Error updating project:', error);
    }
  };

  const deleteProject = async (projectId: string) => {
    try {
      const { error } = await supabase
        .from('projects')
        .delete()
        .eq('id', projectId);

      if (error) throw error;
      
      setShowDeleteConfirm({show: false, project: null});
      fetchProjects();
    } catch (error) {
      console.error('Error deleting project:', error);
    }
  };

  if (loading) return <div className="p-6">Loading projects...</div>;

  return (
    <div className="p-6">
      <div className="bg-white rounded-lg shadow">
        <div className="p-4 border-b">
          <div className="flex justify-between items-center">
            <div>
              <h2 className="text-lg font-bold">Project Management</h2>
              <p className="text-sm text-gray-600">Manage and track construction projects</p>
            </div>
          </div>
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Project</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Progress</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Budget</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actual Cost</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Start Date</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">End Date</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {projects.map((project) => (
                <tr key={project.id} className="hover:bg-gray-50">
                  <td className="px-4 py-3">
                    <div>
                      <div className="font-medium text-sm">{project.name}</div>
                      <div className="text-xs text-gray-500">{project.code}</div>
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center">
                      <div className={`w-3 h-3 rounded-full ${getStatusColor(project.status)} mr-2`}></div>
                      <span className="text-sm capitalize">{project.status.replace('_', ' ')}</span>
                    </div>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center space-x-2">
                      <div className="w-16 h-2 bg-gray-200 rounded-full overflow-hidden">
                        <div 
                          className="h-full bg-blue-500 transition-all duration-300"
                          style={{ width: `${project.progress || 0}%` }}
                        ></div>
                      </div>
                      <span className="text-xs text-gray-500">{Math.round(project.progress || 0)}%</span>
                    </div>
                  </td>
                  <td className="px-4 py-3 text-sm font-medium">${project.budget?.toLocaleString()}</td>
                  <td className="px-4 py-3 text-sm font-medium text-green-600">${(project.project_direct_cost_total || 0).toLocaleString()}</td>
                  <td className="px-4 py-3 text-sm">{new Date(project.start_date).toLocaleDateString()}</td>
                  <td className="px-4 py-3 text-sm">{new Date(project.planned_end_date).toLocaleDateString()}</td>
                  <td className="px-4 py-3">
                    <div className="flex space-x-2">
                      <button 
                        onClick={() => onProjectSelect?.(project.id, project.name)}
                        className="text-blue-600 hover:text-blue-800 text-sm"
                        title="Select Project"
                      >
                        📋
                      </button>
                      <button 
                        onClick={() => showCopyConfirmation(project)}
                        className="text-green-600 hover:text-green-800 text-sm"
                        title="Copy Project"
                      >
                        📋+
                      </button>
                      <button 
                        onClick={() => showEditProject(project)}
                        className="text-yellow-600 hover:text-yellow-800 text-sm"
                        title="Edit Project"
                      >
                        ✏️
                      </button>
                      <button 
                        onClick={() => setShowDeleteConfirm({show: true, project})}
                        className="text-red-600 hover:text-red-800 text-sm"
                        title="Delete Project"
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
        
        {projects.length === 0 && (
          <div className="text-center py-12">
            <p className="text-gray-500 mb-4">No projects found. Create your first project to get started.</p>
          </div>
        )}
      </div>

      {/* Edit Project Modal */}
      {showEditForm.show && showEditForm.project && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-bold mb-4 text-yellow-600">Edit Project</h3>
            <form onSubmit={updateProject} className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1">Project Name</label>
                <input
                  type="text"
                  value={editFormData.name}
                  onChange={(e) => setEditFormData({...editFormData, name: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Budget</label>
                <input
                  type="number"
                  value={editFormData.budget}
                  onChange={(e) => setEditFormData({...editFormData, budget: parseFloat(e.target.value) || 0})}
                  className="w-full border rounded px-3 py-2"
                  min="0"
                  step="0.01"
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium mb-1">Start Date</label>
                  <input
                    type="date"
                    value={editFormData.start_date}
                    onChange={(e) => setEditFormData({...editFormData, start_date: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">End Date</label>
                  <input
                    type="date"
                    value={editFormData.planned_end_date}
                    onChange={(e) => setEditFormData({...editFormData, planned_end_date: e.target.value})}
                    className="w-full border rounded px-3 py-2"
                  />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium mb-1">Status</label>
                <select
                  value={editFormData.status}
                  onChange={(e) => setEditFormData({...editFormData, status: e.target.value})}
                  className="w-full border rounded px-3 py-2"
                >
                  <option value="planning">Planning</option>
                  <option value="active">Active</option>
                  <option value="on_hold">On Hold</option>
                  <option value="completed">Completed</option>
                </select>
              </div>
              <div className="flex justify-end space-x-3">
                <button
                  type="button"
                  onClick={() => setShowEditForm({show: false, project: null})}
                  className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-yellow-600 text-white rounded hover:bg-yellow-700"
                >
                  Update Project
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Copy Confirmation Modal */}
      {showCopyConfirm.show && showCopyConfirm.project && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-bold mb-4 text-green-600">Copy Project</h3>
            <p className="mb-4">
              Copy <strong>{showCopyConfirm.project.name}</strong> ({showCopyConfirm.project.code}) to a new project?
            </p>
            <div className="bg-green-50 border border-green-200 rounded p-3 mb-4">
              <p className="text-sm text-green-800">
                <strong>Next Project ID:</strong> {showCopyConfirm.nextCode}
              </p>
              <p className="text-xs text-green-600">
                Series: {showCopyConfirm.nextCode.split('-')[0]} projects ({showCopyConfirm.project.project_type})
              </p>
              <p className="text-xs text-green-600 mt-1">
                The new project will include the complete WBS structure
              </p>
            </div>
            <div className="flex justify-end space-x-3">
              <button
                onClick={() => setShowCopyConfirm({show: false, project: null, nextCode: ''})}
                className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                onClick={copyProject}
                className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700"
              >
                Copy Project
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {showDeleteConfirm.show && showDeleteConfirm.project && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-bold mb-4 text-red-600">Delete Project</h3>
            <p className="mb-4">
              Are you sure you want to delete <strong>{showDeleteConfirm.project.name}</strong>?
            </p>
            <p className="text-sm text-gray-600 mb-6">
              This action cannot be undone. All WBS nodes, activities, and tasks will be permanently removed.
            </p>
            <div className="flex justify-end space-x-3">
              <button
                onClick={() => setShowDeleteConfirm({show: false, project: null})}
                className="px-4 py-2 text-gray-600 border rounded hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                onClick={() => deleteProject(showDeleteConfirm.project!.id)}
                className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700"
              >
                Delete Project
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}