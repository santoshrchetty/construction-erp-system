import React, { useState, useEffect } from 'react';
import { ProjectCreationService, CreateProjectRequest } from '../domains/projects/projectCreationService';
import { X, ArrowLeft, ArrowRight, Check, Building2, Users, Calendar, MapPin } from 'lucide-react';

interface ProjectFormData {
  name: string;
  description: string;
  project_type: string;
  start_date: string;
  planned_end_date: string;
  budget: number;
  location: string;
  category: string;
  company_code: string;
  person_responsible_id: string;
  cost_center_id: string;
  profit_center_id: string;
  plant_id: string;
}

interface FormErrors {
  [key: string]: string;
}

const projectCreationService = new ProjectCreationService();

const STEPS = [
  { id: 1, title: 'Basic Information', icon: Building2, description: 'Project name and company details' },
  { id: 2, title: 'Organization', icon: Users, description: 'Assign organizational units' },
  { id: 3, title: 'Project Details', icon: Calendar, description: 'Type, budget, and timeline' },
  { id: 4, title: 'Review & Submit', icon: Check, description: 'Confirm and create project' }
];

export default function ProjectForm({ onClose, onSuccess }: { 
  onClose: () => void; 
  onSuccess: () => void; 
}) {
  const [currentStep, setCurrentStep] = useState(1);
  const [formData, setFormData] = useState<ProjectFormData>({
    name: '',
    description: '',
    project_type: 'commercial',
    start_date: '',
    planned_end_date: '',
    budget: 0,
    location: '',
    category: '',
    company_code: '',
    person_responsible_id: '',
    cost_center_id: '',
    profit_center_id: '',
    plant_id: ''
  });
  const [errors, setErrors] = useState<FormErrors>({});
  const [workingCalendar, setWorkingCalendar] = useState({
    working_days: [1, 2, 3, 4, 5],
    holidays: [] as string[]
  });
  const [projectCategories, setProjectCategories] = useState<Array<{ category: string; prefix: string; description: string }>>([]);
  const [projectTypes, setProjectTypes] = useState<Array<{ type_code: string; type_name: string; category_code: string; description: string }>>([]);
  const [numberingPatterns, setNumberingPatterns] = useState<Array<{ id: string; pattern: string; description: string; entity_type: string }>>([]);
  const [companyCodes, setCompanyCodes] = useState<Array<{ id: string; company_code: string; company_name: string }>>([]);
  const [personsResponsible, setPersonsResponsible] = useState<Array<{ id: string; name: string; role: string; email?: string }>>([]);
  const [costCenters, setCostCenters] = useState<Array<{ id: string; cost_center_code: string; cost_center_name: string; department: string }>>([]);
  const [profitCenters, setProfitCenters] = useState<Array<{ id: string; profit_center_code: string; profit_center_name: string; division: string }>>([]);
  const [plants, setPlants] = useState<Array<{ id: string; plant_code: string; plant_name: string; location: string }>>([]);
  const [generatedCode, setGeneratedCode] = useState('');
  const [selectedPattern, setSelectedPattern] = useState('');
  const [loading, setLoading] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showAddPerson, setShowAddPerson] = useState(false);
  const [newPerson, setNewPerson] = useState({ first_name: '', last_name: '', email: '', role: 'project_manager' });
  const [stepLoading, setStepLoading] = useState({ 1: false, 2: false, 3: false });
  const [dataLoaded, setDataLoaded] = useState({ categories: false, companies: false, organizational: false });

  useEffect(() => {
    // Only load essential data on mount
    loadEssentialData();
  }, []);

  useEffect(() => {
    // Load step-specific data when step changes
    loadStepData(currentStep);
  }, [currentStep]);

  const loadEssentialData = async () => {
    try {
      await Promise.all([
        loadProjectCategories(),
        loadCompanyCodes(),
        loadPersonsResponsible()
      ]);
      setDataLoaded(prev => ({ ...prev, categories: true, companies: true }));
    } catch (error) {
      console.error('Error loading essential data:', error);
    }
  };

  const loadStepData = async (step: number) => {
    if (stepLoading[step]) return;
    
    setStepLoading(prev => ({ ...prev, [step]: true }));
    
    try {
      switch (step) {
        case 1:
          // Data already loaded in useEffect
          break;
        case 2:
          if (formData.company_code && !dataLoaded.organizational) {
            await loadOrganizationalData(formData.company_code);
            setDataLoaded(prev => ({ ...prev, organizational: true }));
          }
          break;
        case 3:
          break;
      }
    } finally {
      setStepLoading(prev => ({ ...prev, [step]: false }));
    }
  };

  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && !isSubmitting) {
        onClose();
      }
    };
    document.addEventListener('keydown', handleEscape);
    return () => document.removeEventListener('keydown', handleEscape);
  }, [isSubmitting, onClose]);

  const renderStepContent = () => {
    switch (currentStep) {
      case 1:
        return (
          <div className="space-y-6">
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Company Code *</label>
                <select
                  name="company_code"
                  value={formData.company_code}
                  onChange={(e) => {
                    handleChange(e);
                    setDataLoaded(prev => ({ ...prev, organizational: false }));
                    loadOrganizationalData(e.target.value);
                    loadNumberingPatterns(e.target.value);
                    if (selectedPattern) {
                      setTimeout(() => generateProjectCode(selectedPattern), 100);
                    }
                  }}
                  className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
                    errors.company_code ? 'border-red-500' : 'border-gray-300'
                  }`}
                >
                  <option value="">Select Company</option>
                  {companyCodes.map((company) => (
                    <option key={company.id} value={company.company_code}>
                      {company.company_code} - {company.company_name}
                    </option>
                  ))}
                </select>
                {errors.company_code && <p className="mt-1 text-sm text-red-600">{errors.company_code}</p>}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Project Category *</label>
                <select
                  value={formData.category}
                  onChange={(e) => handleCategoryChange(e.target.value)}
                  className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
                    errors.category ? 'border-red-500' : 'border-gray-300'
                  }`}
                >
                  <option value="">Select Category</option>
                  {projectCategories.map((cat, index) => (
                    <option key={index} value={cat.category}>
                      {cat.category} ({cat.prefix})
                    </option>
                  ))}
                </select>
                {errors.category && <p className="mt-1 text-sm text-red-600">{errors.category}</p>}
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Project Name *</label>
              <input
                type="text"
                name="name"
                value={formData.name}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
                  errors.name ? 'border-red-500' : 'border-gray-300'
                }`}
                placeholder="Enter project name"
              />
              {errors.name && <p className="mt-1 text-sm text-red-600">{errors.name}</p>}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Project Code</label>
              <div className="space-y-3">
                <select
                  value={selectedPattern}
                  onChange={(e) => {
                    setSelectedPattern(e.target.value);
                    if (e.target.value) {
                      generateProjectCode(e.target.value);
                    }
                  }}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
                  disabled={!formData.company_code}
                >
                  <option value="">Select Numbering Pattern</option>
                  {numberingPatterns.map((pattern) => (
                    <option key={pattern.id} value={pattern.pattern}>
                      {pattern.pattern} - {pattern.description}
                    </option>
                  ))}
                </select>
                <div className="flex">
                  <input
                    type="text"
                    value={generatedCode}
                    className="flex-1 px-4 py-3 border border-gray-300 rounded-l-lg bg-gray-50"
                    placeholder="Select pattern to generate code"
                    readOnly
                  />
                  <button
                    type="button"
                    onClick={() => selectedPattern && generateProjectCode(selectedPattern)}
                    className="px-4 py-3 bg-blue-600 text-white rounded-r-lg hover:bg-blue-700 disabled:opacity-50"
                    disabled={!selectedPattern}
                  >
                    🔄
                  </button>
                </div>
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Description</label>
              <textarea
                name="description"
                value={formData.description}
                onChange={handleChange}
                rows={4}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
                placeholder="Project description..."
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Project Type *</label>
              <select
                name="project_type"
                value={formData.project_type}
                onChange={handleChange}
                className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors disabled:bg-gray-100 ${
                  errors.project_type ? 'border-red-500' : 'border-gray-300'
                }`}
                disabled={!formData.category}
              >
                <option value="">Select Project Type</option>
                {projectTypes.map((type) => (
                  <option key={type.type_code} value={type.type_code}>
                    {type.type_name}
                  </option>
                ))}
              </select>
              {errors.project_type && <p className="mt-1 text-sm text-red-600">{errors.project_type}</p>}
              {!formData.category && (
                <p className="mt-1 text-sm text-gray-500">Select a category first</p>
              )}
            </div>
          </div>
        );

      case 2:
        return (
          <div className="space-y-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Person Responsible</label>
              <div className="flex space-x-2">
                <select
                  name="person_responsible_id"
                  value={formData.person_responsible_id}
                  onChange={handleChange}
                  className={`flex-1 px-4 py-3 border rounded-l-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
                    errors.person_responsible_id ? 'border-red-500' : 'border-gray-300'
                  }`}
                >
                  <option value="">Select Person</option>
                  {personsResponsible.map((person) => (
                    <option key={person.id} value={person.id}>
                      {person.name} ({person.role.replace('_', ' ').toUpperCase()})
                    </option>
                  ))}
                </select>
                <button
                  type="button"
                  onClick={() => setShowAddPerson(true)}
                  className="px-4 py-3 bg-green-600 text-white rounded-r-lg hover:bg-green-700 transition-colors"
                  title="Add New Person"
                >
                  +
                </button>
              </div>
              {errors.person_responsible_id && <p className="mt-1 text-sm text-red-600">{errors.person_responsible_id}</p>}
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Cost Center *</label>
                <select
                  name="cost_center_id"
                  value={formData.cost_center_id}
                  onChange={handleChange}
                  disabled={!formData.company_code}
                  className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors disabled:bg-gray-100 ${
                    errors.cost_center_id ? 'border-red-500' : 'border-gray-300'
                  }`}
                >
                  <option value="">Select Cost Center</option>
                  {costCenters.map((cc) => (
                    <option key={cc.id} value={cc.id}>
                      {cc.cost_center_code} - {cc.cost_center_name}
                    </option>
                  ))}
                </select>
                {errors.cost_center_id && <p className="mt-1 text-sm text-red-600">{errors.cost_center_id}</p>}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Profit Center *</label>
                <select
                  name="profit_center_id"
                  value={formData.profit_center_id}
                  onChange={handleChange}
                  disabled={!formData.company_code}
                  className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors disabled:bg-gray-100 ${
                    errors.profit_center_id ? 'border-red-500' : 'border-gray-300'
                  }`}
                >
                  <option value="">Select Profit Center</option>
                  {profitCenters.map((pc) => (
                    <option key={pc.id} value={pc.id}>
                      {pc.profit_center_code} - {pc.profit_center_name}
                    </option>
                  ))}
                </select>
                {errors.profit_center_id && <p className="mt-1 text-sm text-red-600">{errors.profit_center_id}</p>}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Plant *</label>
                <select
                  name="plant_id"
                  value={formData.plant_id}
                  onChange={handleChange}
                  disabled={!formData.company_code}
                  className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors disabled:bg-gray-100 ${
                    errors.plant_id ? 'border-red-500' : 'border-gray-300'
                  }`}
                >
                  <option value="">Select Plant</option>
                  {plants.map((plant) => (
                    <option key={plant.id} value={plant.id}>
                      {plant.plant_code} - {plant.plant_name}
                    </option>
                  ))}
                </select>
                {errors.plant_id && <p className="mt-1 text-sm text-red-600">{errors.plant_id}</p>}
              </div>
            </div>
          </div>
        );

      case 3:
        return (
          <div className="space-y-6">
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Budget ($)</label>
                <input
                  type="number"
                  name="budget"
                  value={formData.budget}
                  onChange={handleChange}
                  min="0"
                  step="0.01"
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
                  placeholder="0.00"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Location</label>
                <div className="relative">
                  <MapPin className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                  <input
                    type="text"
                    name="location"
                    value={formData.location}
                    onChange={handleChange}
                    className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
                    placeholder="Project location"
                  />
                </div>
              </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Start Date *</label>
                <input
                  type="date"
                  name="start_date"
                  value={formData.start_date}
                  onChange={handleChange}
                  className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
                    errors.start_date ? 'border-red-500' : 'border-gray-300'
                  }`}
                />
                {errors.start_date && <p className="mt-1 text-sm text-red-600">{errors.start_date}</p>}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Planned End Date *</label>
                <input
                  type="date"
                  name="planned_end_date"
                  value={formData.planned_end_date}
                  onChange={handleChange}
                  className={`w-full px-4 py-3 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors ${
                    errors.planned_end_date ? 'border-red-500' : 'border-gray-300'
                  }`}
                />
                {errors.planned_end_date && <p className="mt-1 text-sm text-red-600">{errors.planned_end_date}</p>}
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Location</label>
              <div className="relative">
                <MapPin className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
                <input
                  type="text"
                  name="location"
                  value={formData.location}
                  onChange={handleChange}
                  className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
                  placeholder="Project location"
                />
              </div>
            </div>
          </div>
        );

      case 4:
        return (
          <div className="space-y-6">
            <div className="bg-gray-50 rounded-lg p-6">
              <h3 className="text-lg font-medium text-gray-900 mb-4">Review Project Details</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
                <div><span className="font-medium">Project Name:</span> {formData.name}</div>
                <div><span className="font-medium">Company:</span> {companyCodes.find(c => c.company_code === formData.company_code)?.company_name}</div>
                <div><span className="font-medium">Category:</span> {formData.category}</div>
                <div><span className="font-medium">Project Code:</span> {generatedCode}</div>
                <div><span className="font-medium">Person Responsible:</span> {personsResponsible.find(p => p.id === formData.person_responsible_id)?.name}</div>
                <div><span className="font-medium">Project Type:</span> {projectTypes.find(t => t.type_code === formData.project_type)?.type_name || formData.project_type}</div>
                <div><span className="font-medium">Budget:</span> ${formData.budget.toLocaleString()}</div>
                <div><span className="font-medium">Duration:</span> {formData.start_date} to {formData.planned_end_date}</div>
                {formData.location && <div><span className="font-medium">Location:</span> {formData.location}</div>}
              </div>
              {formData.description && (
                <div className="mt-4">
                  <span className="font-medium">Description:</span>
                  <p className="mt-1 text-gray-600">{formData.description}</p>
                </div>
              )}
            </div>
            {errors.submit && (
              <div className="bg-red-50 border border-red-200 rounded-lg p-4">
                <p className="text-red-600">{errors.submit}</p>
              </div>
            )}
          </div>
        );

      default:
        return null;
    }
  };

  const validateStep = (step: number): boolean => {
    const newErrors: FormErrors = {};
    
    switch (step) {
      case 1:
        if (!formData.name.trim()) newErrors.name = 'Project name is required';
        if (!formData.company_code) newErrors.company_code = 'Company code is required';
        if (!formData.category) newErrors.category = 'Project category is required';
        if (!formData.project_type) newErrors.project_type = 'Project type is required';
        break;
      case 2:
        if (!formData.cost_center_id) newErrors.cost_center_id = 'Cost center is required';
        if (!formData.profit_center_id) newErrors.profit_center_id = 'Profit center is required';
        if (!formData.plant_id) newErrors.plant_id = 'Plant is required';
        break;
      case 3:
        if (!formData.start_date) newErrors.start_date = 'Start date is required';
        if (!formData.planned_end_date) newErrors.planned_end_date = 'End date is required';
        if (formData.start_date && formData.planned_end_date && formData.start_date >= formData.planned_end_date) {
          newErrors.planned_end_date = 'End date must be after start date';
        }
        break;
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const nextStep = () => {
    if (validateStep(currentStep)) {
      setCurrentStep(prev => Math.min(prev + 1, STEPS.length));
    }
  };

  const prevStep = () => {
    setCurrentStep(prev => Math.max(prev - 1, 1));
  };

  const loadNumberingPatterns = async (companyCode?: string) => {
    try {
      const patterns = await projectCreationService.getNumberingPatterns('PROJECT', companyCode);
      setNumberingPatterns(patterns);
    } catch (error) {
      console.error('Error loading numbering patterns:', error);
    }
  };

  const loadProjectTypes = async (categoryCode?: string) => {
    try {
      const types = await projectCreationService.getProjectTypes(categoryCode);
      setProjectTypes(types);
    } catch (error) {
      console.error('Error loading project types:', error);
    }
  };

  const loadProjectCategories = async () => {
    try {
      const categories = await projectCreationService.getProjectCategories();
      setProjectCategories(categories);
    } catch (error) {
      console.error('Error loading categories:', error);
    }
  };

  const loadCompanyCodes = async () => {
    try {
      const companies = await projectCreationService.getCompanyCodes();
      setCompanyCodes(companies);
      // Set default company if only one exists
      if (companies.length === 1) {
        setFormData(prev => ({ ...prev, company_code: companies[0].company_code }));
      }
    } catch (error) {
      console.error('Error loading company codes:', error);
    }
  };

  const loadPersonsResponsible = async () => {
    try {
      const persons = await projectCreationService.getPersonsResponsible();
      setPersonsResponsible(persons);
    } catch (error) {
      console.error('Error loading persons responsible:', error);
    }
  };

  const loadOrganizationalData = async (companyCode: string) => {
    if (!companyCode) return;
    
    try {
      const [costCentersData, profitCentersData, plantsData] = await Promise.all([
        projectCreationService.getCostCenters(companyCode),
        projectCreationService.getProfitCenters(companyCode),
        projectCreationService.getPlants(companyCode)
      ]);
      
      setCostCenters(costCentersData);
      setProfitCenters(profitCentersData);
      setPlants(plantsData);
      
      // Reset selections when company changes
      setFormData(prev => ({
        ...prev,
        cost_center_id: '',
        profit_center_id: '',
        plant_id: ''
      }));
    } catch (error) {
      console.error('Error loading organizational data:', error);
    }
  };

  const generateProjectCode = async (pattern?: string) => {
    if (!formData.company_code || !pattern) return;
    
    try {
      // Use PREVIEW function - doesn't increment counter
      const code = await projectCreationService.generateProjectNumberWithPattern({
        entity_type: 'PROJECT',
        company_code: formData.company_code,
        pattern: pattern
      });
      setGeneratedCode(code);
    } catch (error) {
      console.error('Error generating project code:', error);
    }
  };

  const handleCategoryChange = (category: string) => {
    setFormData(prev => ({ ...prev, category, project_type: '' }));
    if (category) {
      generateProjectCode(category);
      loadProjectTypes(category);
    }
  };

  const handleSubmit = async () => {
    console.log('handleSubmit called');
    console.log('Current step:', currentStep);
    console.log('Form data:', formData);
    console.log('Selected pattern:', selectedPattern);
    
    if (!validateStep(3)) {
      console.log('Validation failed');
      return;
    }
    
    if (!selectedPattern) {
      console.log('No pattern selected');
      setErrors({ submit: 'Please select a numbering pattern' });
      return;
    }
    
    setIsSubmitting(true);
    console.log('Starting project creation...');
    
    try {
      const createRequest: CreateProjectRequest = {
        ...formData,
        working_days: workingCalendar.working_days,
        holidays: workingCalendar.holidays,
        selected_pattern: selectedPattern
      };
      
      console.log('Create request:', createRequest);
      
      const result = await projectCreationService.createProject(createRequest);
      console.log('Project created:', result);
      
      onSuccess();
      onClose();
    } catch (error) {
      console.error('Error creating project:', error);
      setErrors({ submit: `Error creating project: ${error.message}` });
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: name === 'budget' ? parseFloat(value) || 0 : value
    }));
    // Clear error when user starts typing
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: '' }));
    }
  };

  return (
    <div className="fixed inset-0 bg-white z-50 flex flex-col overflow-hidden">
      {/* Header */}
      <div className="bg-white border-b border-gray-200 px-4 sm:px-6 lg:px-8 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <button
              onClick={onClose}
              className="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-lg transition-colors"
              disabled={isSubmitting}
            >
              <X className="w-5 h-5" />
            </button>
            <div>
              <h1 className="text-xl sm:text-2xl font-bold text-gray-900">Create New Project</h1>
              <p className="text-sm text-gray-500 mt-1">Step {currentStep} of {STEPS.length}</p>
            </div>
          </div>
          <div className="hidden sm:flex items-center space-x-2">
            {STEPS.map((step) => {
              const Icon = step.icon;
              return (
                <div
                  key={step.id}
                  className={`flex items-center px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                    currentStep === step.id
                      ? 'bg-blue-100 text-blue-700'
                      : currentStep > step.id
                      ? 'bg-green-100 text-green-700'
                      : 'bg-gray-100 text-gray-500'
                  }`}
                >
                  <Icon className="w-4 h-4 mr-2" />
                  {step.title}
                </div>
              );
            })}
          </div>
        </div>
      </div>

      {/* Progress Bar */}
      <div className="bg-gray-200 h-1">
        <div
          className="bg-blue-600 h-1 transition-all duration-300 ease-out"
          style={{ width: `${(currentStep / STEPS.length) * 100}%` }}
        />
      </div>

      {/* Mobile Step Indicator */}
      <div className="sm:hidden bg-gray-50 px-4 py-3 border-b border-gray-200">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-3">
            {(() => {
              const Icon = STEPS[currentStep - 1].icon;
              return <Icon className="w-5 h-5 text-blue-600" />;
            })()}
            <div>
              <p className="font-medium text-gray-900">{STEPS[currentStep - 1].title}</p>
              <p className="text-sm text-gray-500">{STEPS[currentStep - 1].description}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-auto">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-6 sm:py-8">
          <div className="bg-white">
            {/* Step Title - Desktop */}
            <div className="hidden sm:block mb-8">
              <div className="flex items-center space-x-3 mb-2">
                {(() => {
                  const Icon = STEPS[currentStep - 1].icon;
                  return <Icon className="w-6 h-6 text-blue-600" />;
                })()}
                <h2 className="text-2xl font-bold text-gray-900">{STEPS[currentStep - 1].title}</h2>
              </div>
              <p className="text-gray-600">{STEPS[currentStep - 1].description}</p>
            </div>

            {/* Form Content */}
            {renderStepContent()}
          </div>
        </div>
      </div>

      {/* Footer */}
      <div className="bg-white border-t border-gray-200 px-4 sm:px-6 lg:px-8 py-4">
        <div className="max-w-4xl mx-auto flex items-center justify-between">
          <button
            type="button"
            onClick={prevStep}
            disabled={currentStep === 1 || isSubmitting}
            className="flex items-center px-4 py-2 text-gray-600 hover:text-gray-800 hover:bg-gray-100 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Previous
          </button>

          <div className="flex items-center space-x-3">
            {currentStep < STEPS.length ? (
              <button
                type="button"
                onClick={nextStep}
                disabled={isSubmitting}
                className="flex items-center px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Next
                <ArrowRight className="w-4 h-4 ml-2" />
              </button>
            ) : (
              <button
                type="button"
                onClick={handleSubmit}
                disabled={isSubmitting}
                className="flex items-center px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {isSubmitting ? (
                  <>
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                    Creating...
                  </>
                ) : (
                  <>
                    <Check className="w-4 h-4 mr-2" />
                    Create Project
                  </>
                )}
              </button>
            )}
          </div>
        </div>
      </div>

      {/* Add Person Modal */}
      {showAddPerson && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg p-6 w-full max-w-md">
            <h3 className="text-lg font-medium mb-4">Add New Person</h3>
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <input
                  type="text"
                  placeholder="First Name"
                  value={newPerson.first_name}
                  onChange={(e) => setNewPerson(prev => ({ ...prev, first_name: e.target.value }))}
                  className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                />
                <input
                  type="text"
                  placeholder="Last Name"
                  value={newPerson.last_name}
                  onChange={(e) => setNewPerson(prev => ({ ...prev, last_name: e.target.value }))}
                  className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <input
                type="email"
                placeholder="Email"
                value={newPerson.email}
                onChange={(e) => setNewPerson(prev => ({ ...prev, email: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              />
              <select
                value={newPerson.role}
                onChange={(e) => setNewPerson(prev => ({ ...prev, role: e.target.value }))}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
              >
                <option value="project_manager">Project Manager</option>
                <option value="site_supervisor">Site Supervisor</option>
                <option value="engineer">Engineer</option>
                <option value="architect">Architect</option>
              </select>
            </div>
            <div className="flex justify-end space-x-3 mt-6">
              <button
                onClick={() => setShowAddPerson(false)}
                className="px-4 py-2 text-gray-600 hover:bg-gray-100 rounded-lg"
              >
                Cancel
              </button>
              <button
                onClick={async () => {
                  if (!newPerson.first_name || !newPerson.last_name || !newPerson.email) return;
                  try {
                    const person = await projectCreationService.addPersonResponsible({
                      ...newPerson,
                      company_code: formData.company_code
                    });
                    setPersonsResponsible(prev => [...prev, person]);
                    setFormData(prev => ({ ...prev, person_responsible_id: person.id }));
                    setNewPerson({ first_name: '', last_name: '', email: '', role: 'project_manager' });
                    setShowAddPerson(false);
                  } catch (error) {
                    console.error('Error adding person:', error);
                  }
                }}
                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
              >
                Add Person
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}