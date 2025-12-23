import React, { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';

interface ProjectFormData {
  name: string;
  code: string;
  description: string;
  project_type: string;
  start_date: string;
  planned_end_date: string;
  budget: number;
}

export default function ProjectForm({ onClose, onSuccess }: { 
  onClose: () => void; 
  onSuccess: () => void; 
}) {
  const [formData, setFormData] = useState<ProjectFormData>({
    name: '',
    code: '',
    description: '',
    project_type: 'commercial',
    start_date: '',
    planned_end_date: '',
    budget: 0
  });
  const [workingCalendar, setWorkingCalendar] = useState({
    working_days: [1, 2, 3, 4, 5], // Monday to Friday
    holidays: [] as string[]
  });
  const [newHoliday, setNewHoliday] = useState('');
  const [holidayName, setHolidayName] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('');
  const [loading, setLoading] = useState(false);

  const projectCategories = [
    { project_category: 'Airport', code_prefix: 'AIR', description: 'Airport construction projects' },
    { project_category: 'Bridge', code_prefix: 'BRD', description: 'Bridge and overpass projects' },
    { project_category: 'Building', code_prefix: 'BLD', description: 'Commercial and residential buildings' },
    { project_category: 'Highway', code_prefix: 'HWY', description: 'Highway and road construction' },
    { project_category: 'Railway', code_prefix: 'RLY', description: 'Railway and metro projects' },
    { project_category: 'Port', code_prefix: 'PRT', description: 'Port and marine infrastructure' },
    { project_category: 'Industrial', code_prefix: 'IND', description: 'Industrial facilities' },
    { project_category: 'Residential', code_prefix: 'RES', description: 'Residential complexes' },
    { project_category: 'Commercial', code_prefix: 'COM', description: 'Commercial complexes' },
    { project_category: 'Infrastructure', code_prefix: 'INF', description: 'General infrastructure' }
  ];

  const generateProjectCode = async (category: string) => {
    const categoryData = projectCategories.find(cat => cat.project_category === category);
    if (!categoryData) return;

    const prefix = categoryData.code_prefix;
    const year = new Date().getFullYear().toString().slice(-2);
    
    // Get existing projects with this prefix to determine next number
    const { data: existingProjects } = await supabase
      .from('projects')
      .select('code')
      .like('code', `${prefix}-${year}-%`);
    
    let nextNumber = 1;
    if (existingProjects && existingProjects.length > 0) {
      const numbers = existingProjects
        .map(p => {
          const match = p.code.match(new RegExp(`^${prefix}-${year}-(\\d+)$`));
          return match ? parseInt(match[1]) : 0;
        })
        .filter(n => n > 0);
      
      nextNumber = numbers.length > 0 ? Math.max(...numbers) + 1 : 1;
    }
    
    const newCode = `${prefix}-${year}-${nextNumber.toString().padStart(2, '0')}`;
    setFormData(prev => ({ ...prev, code: newCode }));
  };

  const handleCategoryChange = (category: string) => {
    setSelectedCategory(category);
    if (category) {
      generateProjectCode(category);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const { data: user } = await supabase.auth.getUser();
      
      const { error } = await supabase
        .from('projects')
        .insert({
          ...formData,
          status: 'planning',
          created_by: user.user?.id,
          working_days: workingCalendar.working_days,
          holidays: workingCalendar.holidays
        });

      if (error) throw error;

      onSuccess();
      onClose();
    } catch (error) {
      console.error('Error creating project:', error);
      console.error('Form data:', formData);
      console.error('Working calendar:', workingCalendar);
      alert(`Error creating project: ${error.message || JSON.stringify(error)}`);
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: name === 'budget' ? parseFloat(value) || 0 : value
    }));
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-xl font-bold">Create New Project</h2>
          <button onClick={onClose} className="text-gray-500 hover:text-gray-700">
            ✕
          </button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium mb-1">Project Name *</label>
            <input
              type="text"
              name="name"
              value={formData.name}
              onChange={handleChange}
              required
              className="w-full border rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Enter project name"
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium mb-1">Project Category *</label>
              <select
                value={selectedCategory}
                onChange={(e) => handleCategoryChange(e.target.value)}
                required
                className="w-full border rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">Select Category</option>
                {projectCategories.map((cat, index) => (
                  <option key={index} value={cat.project_category}>
                    {cat.project_category} ({cat.code_prefix})
                  </option>
                ))}
              </select>
              <p className="text-xs text-gray-500 mt-1">Category determines the project code prefix</p>
            </div>

            <div>
              <label className="block text-sm font-medium mb-1">Project Code *</label>
              <div className="flex">
                <input
                  type="text"
                  name="code"
                  value={formData.code}
                  onChange={handleChange}
                  required
                  className="flex-1 border rounded-l-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500 bg-gray-50"
                  placeholder="Auto-generated"
                  readOnly
                />
                <button
                  type="button"
                  onClick={() => selectedCategory && generateProjectCode(selectedCategory)}
                  className="bg-blue-600 text-white px-3 py-2 rounded-r-lg hover:bg-blue-700 text-sm"
                  disabled={!selectedCategory}
                >
                  🔄
                </button>
              </div>
              <p className="text-xs text-gray-500 mt-1">Format: PREFIX-YY-NN (e.g., AIR-24-01)</p>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium mb-1">Description</label>
            <textarea
              name="description"
              value={formData.description}
              onChange={handleChange}
              rows={3}
              className="w-full border rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Project description..."
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium mb-1">Project Type *</label>
              <select
                name="project_type"
                value={formData.project_type}
                onChange={handleChange}
                required
                className="w-full border rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="residential">Residential</option>
                <option value="commercial">Commercial</option>
                <option value="infrastructure">Infrastructure</option>
                <option value="industrial">Industrial</option>
              </select>
              <p className="text-xs text-gray-500 mt-1">General classification for reporting</p>
            </div>

            <div>
              <label className="block text-sm font-medium mb-1">Budget ($)</label>
              <input
                type="number"
                name="budget"
                value={formData.budget}
                onChange={handleChange}
                min="0"
                step="0.01"
                className="w-full border rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="0.00"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium mb-1">Start Date *</label>
              <input
                type="date"
                name="start_date"
                value={formData.start_date}
                onChange={handleChange}
                required
                className="w-full border rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            <div>
              <label className="block text-sm font-medium mb-1">Planned End Date *</label>
              <input
                type="date"
                name="planned_end_date"
                value={formData.planned_end_date}
                onChange={handleChange}
                required
                className="w-full border rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>

          <div className="border-t pt-4">
            <h4 className="font-medium mb-3">📅 Working Calendar</h4>
            
            <div className="mb-3">
              <label className="block text-sm font-medium mb-2">Working Days</label>
              <div className="flex space-x-2">
                {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day, index) => (
                  <label key={index} className="flex items-center space-x-1">
                    <input
                      type="checkbox"
                      checked={workingCalendar.working_days.includes(index)}
                      onChange={(e) => {
                        const newWorkingDays = e.target.checked
                          ? [...workingCalendar.working_days, index]
                          : workingCalendar.working_days.filter(d => d !== index);
                        setWorkingCalendar({...workingCalendar, working_days: newWorkingDays});
                      }}
                      className="rounded"
                    />
                    <span className="text-xs">{day}</span>
                  </label>
                ))}
              </div>
              <p className="text-xs text-gray-500 mt-1">Select working days for this project</p>
            </div>
            
            <div className="mb-4">
              <label className="block text-sm font-medium mb-2">Project Holidays</label>
              
              {/* Add Holiday */}
              <div className="flex space-x-2 mb-3">
                <input
                  type="date"
                  value={newHoliday}
                  onChange={(e) => setNewHoliday(e.target.value)}
                  className="flex-1 border rounded-lg px-3 py-2"
                  placeholder="Select date"
                />
                <input
                  type="text"
                  value={holidayName}
                  onChange={(e) => setHolidayName(e.target.value)}
                  className="flex-1 border rounded-lg px-3 py-2"
                  placeholder="Holiday name (optional)"
                />
                <button
                  type="button"
                  onClick={() => {
                    if (newHoliday && !workingCalendar.holidays.includes(newHoliday)) {
                      setWorkingCalendar({
                        ...workingCalendar, 
                        holidays: [...workingCalendar.holidays, newHoliday]
                      });
                      setNewHoliday('');
                      setHolidayName('');
                    }
                  }}
                  className="bg-green-600 text-white px-3 py-2 rounded-lg hover:bg-green-700"
                >
                  Add
                </button>
              </div>
              
              {/* Holiday List */}
              {workingCalendar.holidays.length > 0 && (
                <div className="space-y-2">
                  <p className="text-sm font-medium text-gray-700">Added Holidays:</p>
                  <div className="max-h-32 overflow-y-auto space-y-1">
                    {workingCalendar.holidays.map((holiday, index) => (
                      <div key={index} className="flex justify-between items-center bg-gray-50 px-3 py-2 rounded">
                        <div>
                          <span className="text-sm font-medium">
                            {new Date(holiday).toLocaleDateString('en-US', { 
                              weekday: 'short', 
                              year: 'numeric', 
                              month: 'short', 
                              day: 'numeric' 
                            })}
                          </span>
                        </div>
                        <button
                          type="button"
                          onClick={() => {
                            setWorkingCalendar({
                              ...workingCalendar,
                              holidays: workingCalendar.holidays.filter((_, i) => i !== index)
                            });
                          }}
                          className="text-red-600 hover:text-red-800 text-sm"
                        >
                          Remove
                        </button>
                      </div>
                    ))}
                  </div>
                </div>
              )}
              
              <p className="text-xs text-gray-500 mt-2">Select dates that should be excluded from working days</p>
            </div>
          </div>

          <div className="flex justify-end space-x-3 pt-4">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 text-gray-600 border border-gray-300 rounded-lg hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={loading}
              className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
            >
              {loading ? 'Creating...' : 'Create Project'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}