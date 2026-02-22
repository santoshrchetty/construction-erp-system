'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { Save, ArrowLeft, Plus, Trash2, FileText, TreePine, Search } from 'lucide-react'
import Breadcrumb from '@/components/Breadcrumb'
import { createClient } from '@/lib/supabase/client'

interface ObjectLink {
  object_type: string
  object_id: string
  description: string
  searchQuery: string
  searchBy: string
  project_code?: string
}

interface DocumentFormData {
  document_number: string
  title: string
  description: string
  document_type: string
  document_subtype: string
  version: string
  part_number: string
  parent_document_id: string
  system_status: string
  user_status: string
  tags: string[]
  object_links: ObjectLink[]
}

const DRAWING_TYPES = [
  { value: 'GA', label: 'GA - General Arrangement' },
  { value: 'DETAIL', label: 'Detail Drawing' },
  { value: 'ASSEMBLY', label: 'Assembly Drawing' },
  { value: 'SCHEMATIC', label: 'Schematic' },
  { value: 'LAYOUT', label: 'Layout' },
  { value: 'ISOMETRIC', label: 'Isometric' }
]

const DISCIPLINES = [
  { value: 'MECHANICAL', label: 'Mechanical' },
  { value: 'ELECTRICAL', label: 'Electrical' },
  { value: 'CIVIL', label: 'Civil' },
  { value: 'PIPING', label: 'Piping' },
  { value: 'INSTRUMENTATION', label: 'Instrumentation' },
  { value: 'STRUCTURAL', label: 'Structural' },
  { value: 'ARCHITECTURAL', label: 'Architectural' }
]

const DRAWING_SIZES = [
  { value: 'A0', label: 'A0' },
  { value: 'A1', label: 'A1' },
  { value: 'A2', label: 'A2' },
  { value: 'A3', label: 'A3' },
  { value: 'A4', label: 'A4' }
]

const SCALES = [
  { value: '1:1', label: '1:1' },
  { value: '1:2', label: '1:2' },
  { value: '1:5', label: '1:5' },
  { value: '1:10', label: '1:10' },
  { value: '1:20', label: '1:20' },
  { value: '1:50', label: '1:50' },
  { value: '1:100', label: '1:100' },
  { value: '1:200', label: '1:200' },
  { value: 'NTS', label: 'NTS - Not to Scale' }
]

const DOCUMENT_SUBTYPES: { [key: string]: Array<{ value: string; label: string }> } = {
  DRW: [
    { value: 'GA', label: 'GA - General Arrangement' },
    { value: 'DTL', label: 'Detail Drawing' },
    { value: 'ASM', label: 'Assembly Drawing' },
    { value: 'SCH', label: 'Schematic' },
    { value: 'LAY', label: 'Layout' },
    { value: 'ISO', label: 'Isometric' }
  ],
  CNT: [
    { value: 'MAN', label: 'Main Contract' },
    { value: 'SUB', label: 'Subcontract' },
    { value: 'PUR', label: 'Purchase Order' },
    { value: 'SRV', label: 'Service Agreement' },
    { value: 'NDA', label: 'Non-Disclosure Agreement' }
  ],
  SPE: [
    { value: 'TEC', label: 'Technical Specification' },
    { value: 'MAT', label: 'Material Specification' },
    { value: 'EQP', label: 'Equipment Specification' },
    { value: 'PER', label: 'Performance Specification' }
  ],
  DOC: [
    { value: 'PRO', label: 'Progress Report' },
    { value: 'INS', label: 'Inspection Report' },
    { value: 'TST', label: 'Test Report' },
    { value: 'QUA', label: 'Quality Report' },
    { value: 'SAF', label: 'Safety Report' }
  ]
}

const DOCUMENT_TYPES = [
  { value: 'DRW', label: 'Drawing' },
  { value: 'SPE', label: 'Specification' },
  { value: 'CNT', label: 'Contract' },
  { value: 'RFI', label: 'RFI' },
  { value: 'SUB', label: 'Submittal' },
  { value: 'CHG', label: 'Change Order' },
  { value: 'DOC', label: 'Other' }
]

const SYSTEM_STATUSES = [
  { value: 'WIP', label: 'WIP - Work in Progress' },
  { value: 'SHARED', label: 'SHARED - Shared for Review' },
  { value: 'APPROVED', label: 'APPROVED - Approved' },
  { value: 'CURRENT', label: 'CURRENT - Current Version' },
  { value: 'ARCHIVED', label: 'ARCHIVED - Archived' },
  { value: 'SUPERSEDED', label: 'SUPERSEDED - Superseded' }
]

const USER_STATUSES = [
  { value: 'IFC', label: 'IFC - Issued for Construction' },
  { value: 'IFA', label: 'IFA - Issued for Approval' },
  { value: 'IFI', label: 'IFI - Issued for Information' },
  { value: 'IFT', label: 'IFT - Issued for Tender' },
  { value: 'IFR', label: 'IFR - Issued for Review' },
  { value: 'AS-BUILT', label: 'AS-BUILT - As-Built' }
]

const SEARCH_CRITERIA: { [key: string]: Array<{ value: string; label: string }> } = {
  PROJECT: [
    { value: 'project_code', label: 'Project Code' },
    { value: 'project_code_name', label: 'Code & Name' },
    { value: 'location', label: 'Location' }
  ],
  WBS: [
    { value: 'wbs_code_description', label: 'Code & Description' }
  ],
  COST_CENTER: [
    { value: 'cost_center_code', label: 'Cost Center Code' },
    { value: 'cost_center_code_name', label: 'Code & Name' }
  ],
  MATERIAL: [
    { value: 'material_code', label: 'Material Code' },
    { value: 'material_code_name', label: 'Code & Name' },
    { value: 'category', label: 'Category' }
  ],
  EQUIPMENT: [
    { value: 'equipment_tag', label: 'Equipment Tag' },
    { value: 'equipment_tag_name', label: 'Tag & Name' }
  ],
  PURCHASE_ORDER: [
    { value: 'po_number', label: 'PO Number' },
    { value: 'po_number_vendor', label: 'PO & Vendor' }
  ],
  SALES_ORDER: [
    { value: 'so_number', label: 'SO Number' },
    { value: 'so_number_customer', label: 'SO & Customer' }
  ]
}

const OBJECT_TYPES = [
  { value: 'PROJECT', label: 'Project' },
  { value: 'WBS', label: 'WBS Element' },
  { value: 'COST_CENTER', label: 'Cost Center' },
  { value: 'MATERIAL', label: 'Material' },
  { value: 'EQUIPMENT', label: 'Equipment' },
  { value: 'PURCHASE_ORDER', label: 'Purchase Order' },
  { value: 'SALES_ORDER', label: 'Sales Order' }
]

export default function CreateDocumentPage() {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [showDescription, setShowDescription] = useState(false)
  const [currentUserId, setCurrentUserId] = useState<string | null>(null)
  const [mode, setMode] = useState<'create' | 'view' | 'edit'>('create')
  const [documentId, setDocumentId] = useState<string | null>(null)
  const [formData, setFormData] = useState<DocumentFormData>({
    document_number: '',
    title: '',
    description: '',
    document_type: '',
    document_subtype: '',
    version: '1.0',
    part_number: '',
    parent_document_id: '',
    system_status: 'WIP',
    user_status: '',
    tags: [],
    object_links: []
  })

  useEffect(() => {
    const getUser = async () => {
      const supabase = createClient()
      const { data: { user } } = await supabase.auth.getUser()
      if (user) setCurrentUserId(user.id)
    }
    
    // Check URL parameters for mode and document ID
    const urlParams = new URLSearchParams(window.location.search)
    const urlMode = urlParams.get('mode') as 'view' | 'edit' | null
    const urlId = urlParams.get('id')
    
    if (urlMode && urlId) {
      setMode(urlMode)
      setDocumentId(urlId)
      loadDocument(urlId)
    }
    
    getUser()
  }, [])

  const handleInputChange = (field: keyof DocumentFormData, value: string) => {
    setFormData(prev => {
      const updated = { ...prev, [field]: value }
      // Reset subtype when document type changes
      if (field === 'document_type') {
        updated.document_subtype = ''
        updated.parent_document_id = ''
      }
      return updated
    })
    
    // Load parent documents when document type changes
    if (field === 'document_type' && value) {
      setTimeout(() => loadParentDocuments(), 100)
    }
    
    // Load hierarchy when parent document is selected
    if (field === 'parent_document_id' && value) {
      loadHierarchy(value)
    }
  }

  const [objectSearchResults, setObjectSearchResults] = useState<{ [key: number]: any[] }>({})
  const [searchingObjects, setSearchingObjects] = useState<{ [key: number]: boolean }>({})
  const [showAllObjects, setShowAllObjects] = useState<{ [key: number]: boolean }>({})

  const [projectsList, setProjectsList] = useState<any[]>([])
  const [loadingProjects, setLoadingProjects] = useState(false)
  const [parentDocuments, setParentDocuments] = useState<any[]>([])
  const [loadingParents, setLoadingParents] = useState(false)
  const [parentSearchQuery, setParentSearchQuery] = useState('')
  const [showParentDropdown, setShowParentDropdown] = useState(false)
  const [filteredParentDocs, setFilteredParentDocs] = useState<any[]>([])
  const [showHierarchy, setShowHierarchy] = useState(false)
  const [hierarchyData, setHierarchyData] = useState<any[]>([])

  const loadDocument = async (id: string) => {
    try {
      const response = await fetch(`/api/document-governance/records?action=get&id=${id}`)
      const result = await response.json()
      if (result.success) {
        const doc = result.data
        setFormData({
          document_number: doc.document_number,
          title: doc.title,
          description: doc.description || '',
          document_type: doc.document_type,
          document_subtype: doc.document_subtype || '',
          version: doc.current_lifecycle?.version || '1.0',
          part_number: doc.part_number || '',
          parent_document_id: doc.parent_document_id || '',
          system_status: 'WIP',
          user_status: doc.current_lifecycle?.status || '',
          tags: [],
          object_links: []
        })
        if (doc.description) setShowDescription(true)
      }
    } catch (error) {
      console.error('Failed to load document:', error)
    }
  }

  const addObjectLink = () => {
    setFormData(prev => ({
      ...prev,
      object_links: [...prev.object_links, { object_type: '', object_id: '', description: '', searchQuery: '', searchBy: '', project_code: '' }]
    }))
  }

  const removeObjectLink = (index: number) => {
    setFormData(prev => ({
      ...prev,
      object_links: prev.object_links.filter((_, i) => i !== index)
    }))
  }

  const updateObjectLink = (index: number, field: keyof ObjectLink, value: string) => {
    setFormData(prev => ({
      ...prev,
      object_links: prev.object_links.map((link, i) => 
        i === index ? { ...link, [field]: value } : link
      )
    }))

    // Reset search when object type changes
    if (field === 'object_type') {
      setFormData(prev => ({
        ...prev,
        object_links: prev.object_links.map((link, i) => 
          i === index ? { ...link, searchBy: '', searchQuery: '', object_id: '', description: '', project_code: '' } : link
        )
      }))
      setObjectSearchResults(prev => ({ ...prev, [index]: [] }))
      setShowAllObjects(prev => ({ ...prev, [index]: false }))
      
      // Load projects if WBS is selected
      if (value === 'WBS') {
        loadProjects()
      }
    }

    // Load WBS when project is selected
    if (field === 'project_code' && value) {
      const link = formData.object_links[index]
      if (link.object_type === 'WBS' && link.searchBy) {
        loadAllObjects(index, link.object_type, link.searchBy, value)
      }
    }

    // Load all objects when searchBy is selected
    if (field === 'searchBy' && value) {
      const link = formData.object_links[index]
      if (link.object_type === 'WBS') {
        // For WBS, wait for project selection
        if (link.project_code) {
          console.log('Auto-loading WBS for project:', link.project_code)
          loadAllObjects(index, link.object_type, value, link.project_code)
        }
      } else if (link.object_type) {
        loadAllObjects(index, link.object_type, value)
      }
    }

    // Auto-select Code & Description for WBS when project is selected
    if (field === 'project_code' && value) {
      const link = formData.object_links[index]
      if (link.object_type === 'WBS') {
        // Auto-select the search criteria
        setFormData(prev => ({
          ...prev,
          object_links: prev.object_links.map((l, i) => 
            i === index ? { ...l, searchBy: 'wbs_code_description' } : l
          )
        }))
        // Load WBS data
        loadAllObjects(index, 'WBS', 'wbs_code_description', value)
      }
    }

    // Trigger search when searchQuery changes
    if (field === 'searchQuery' && value.length >= 2) {
      const link = formData.object_links[index]
      if (link.object_type && link.searchBy) {
        if (link.object_type === 'WBS' && link.project_code) {
          searchObjects(index, link.object_type, link.searchBy, value, link.project_code)
        } else if (link.object_type !== 'WBS') {
          searchObjects(index, link.object_type, link.searchBy, value)
        }
      }
    } else if (field === 'searchQuery' && value.length === 0) {
      // Show all when search is cleared
      const link = formData.object_links[index]
      if (link.object_type && link.searchBy) {
        if (link.object_type === 'WBS' && link.project_code) {
          loadAllObjects(index, link.object_type, link.searchBy, link.project_code)
        } else if (link.object_type !== 'WBS') {
          loadAllObjects(index, link.object_type, link.searchBy)
        }
      }
    }
  }

  const loadProjects = async () => {
    setLoadingProjects(true)
    try {
      const response = await fetch('/api/document-governance/records?action=load-objects&type=PROJECT')
      const result = await response.json()
      console.log('Projects loaded:', result)
      if (result.success && result.data) {
        const projects = Array.isArray(result.data) ? result.data : []
        console.log('Setting projects:', projects)
        setProjectsList(projects)
      }
    } catch (error) {
      console.error('Load projects error:', error)
    } finally {
      setLoadingProjects(false)
    }
  }

  const loadParentDocuments = async () => {
    if (!formData.document_type) return
    
    console.log('Loading parent documents for type:', formData.document_type)
    setLoadingParents(true)
    try {
      const response = await fetch(`/api/document-governance/records?action=parent-documents&document_type=${formData.document_type}`)
      const result = await response.json()
      console.log('Parent documents response:', result)
      if (result.success && result.data) {
        console.log('Setting parent documents:', result.data.length, 'documents')
        setParentDocuments(result.data)
        setFilteredParentDocs(result.data)
      } else {
        console.error('Parent documents error:', result.error)
        setParentDocuments([])
        setFilteredParentDocs([])
      }
    } catch (error) {
      console.error('Load parent documents error:', error)
      setParentDocuments([])
      setFilteredParentDocs([])
    } finally {
      setLoadingParents(false)
    }
  }

  const handleParentSearch = (query: string) => {
    setParentSearchQuery(query)
    if (!query.trim()) {
      setFilteredParentDocs(parentDocuments)
    } else {
      const filtered = parentDocuments.filter(doc => 
        doc.document_number.toLowerCase().includes(query.toLowerCase()) ||
        doc.title.toLowerCase().includes(query.toLowerCase())
      )
      setFilteredParentDocs(filtered)
    }
  }

  const selectParentDocument = (docId: string, docNumber: string, docTitle: string) => {
    handleInputChange('parent_document_id', docId)
    setParentSearchQuery(`${docNumber} - ${docTitle}`)
    setShowParentDropdown(false)
  }

  const loadHierarchy = async (rootId: string) => {
    try {
      const response = await fetch(`/api/document-governance/records?action=hierarchy&rootId=${rootId}`)
      const result = await response.json()
      if (result.success && result.data) {
        setHierarchyData(result.data)
      }
    } catch (error) {
      console.error('Load hierarchy error:', error)
    }
  }

  const loadAllObjects = async (index: number, objectType: string, searchBy: string, projectCode?: string) => {
    setSearchingObjects(prev => ({ ...prev, [index]: true }))
    setShowAllObjects(prev => ({ ...prev, [index]: true }))
    try {
      const params = new URLSearchParams({ action: 'load-objects', type: objectType })
      if (projectCode) params.append('projectCode', projectCode)
      const response = await fetch(`/api/document-governance/records?${params.toString()}`)
      const result = await response.json()
      
      if (result.success) {
        const dataArray = Array.isArray(result.data) ? result.data : (result.data ? [result.data] : [])
        const normalizedData = dataArray.map((item: any) => ({
          id: item.project_code || item.wbs_code || item.cost_center_code || item.material_code || item.po_number || item.id,
          name: item.name || item.project_name || item.wbs_description || item.description || item.cost_center_name || item.material_name || item.vendor_name || item.title
        }))
        setObjectSearchResults(prev => ({ ...prev, [index]: normalizedData }))
      }
    } catch (error) {
      console.error('Load error:', error)
    } finally {
      setSearchingObjects(prev => ({ ...prev, [index]: false }))
    }
  }

  const searchObjects = async (index: number, objectType: string, searchBy: string, query: string, projectCode?: string) => {
    setSearchingObjects(prev => ({ ...prev, [index]: true }))
    try {
      const params = new URLSearchParams({ action: 'search-objects', type: objectType, query })
      if (projectCode) params.append('projectCode', projectCode)
      const response = await fetch(`/api/document-governance/records?${params.toString()}`)
      const result = await response.json()
      
      if (result.success && result.data) {
        const dataArray = Array.isArray(result.data) ? result.data : (result.data ? [result.data] : [])
        const normalizedData = dataArray.map((item: any) => ({
          id: item.project_code || item.wbs_code || item.cost_center_code || item.material_code || item.po_number || item.id,
          name: item.name || item.project_name || item.wbs_description || item.description || item.cost_center_name || item.material_name || item.vendor_name || item.title
        }))
        setObjectSearchResults(prev => ({ ...prev, [index]: normalizedData }))
      }
    } catch (error) {
      console.error('Search error:', error)
    } finally {
      setSearchingObjects(prev => ({ ...prev, [index]: false }))
    }
  }

  const selectObject = (index: number, objectId: string, description: string) => {
    setFormData(prev => ({
      ...prev,
      object_links: prev.object_links.map((link, i) => 
        i === index ? { ...link, object_id: objectId, description: description, searchQuery: '' } : link
      )
    }))
    setObjectSearchResults(prev => ({ ...prev, [index]: [] }))
    setShowAllObjects(prev => ({ ...prev, [index]: false }))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)

    try {
      const response = await fetch('/api/document-governance/records', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'create', data: { ...formData, created_by: currentUserId } })
      })

      const result = await response.json()

      if (result.success) {
        alert(`Document ${result.data.document_number} created successfully!`)
        router.push('/document-governance/records/list')
      } else {
        alert(`Error: ${result.error}`)
      }
    } catch (error) {
      console.error('Create document error:', error)
      alert('Failed to create document. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  const isFormValid = formData.title && formData.document_type
  const isDisabled = mode === 'view'

  return (
    <div className="p-6">
      <div className="mb-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">
              {mode === 'view' ? 'View Document' : mode === 'edit' ? 'Edit Document' : 'Create Document'}
            </h1>
            <p className="text-gray-600 mt-2">
              {mode === 'view' ? 'View document details' : mode === 'edit' ? 'Modify existing document' : 'Create a new document record with ISO 19650 governance'}
            </p>
          </div>
          <button onClick={() => router.push('/erp-modules?category=Document Governance')} className="flex items-center px-4 py-2 text-gray-600 border border-gray-300 rounded-md hover:bg-gray-50">
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back
          </button>
        </div>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Basic Information */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Basic Information</h2>
          <div className="space-y-4">
            {/* Row 1: Document Number, Title, Icon */}
            <div className="grid grid-cols-12 gap-4">
              <div className="col-span-3">
                <label className="block text-sm font-medium text-gray-700 mb-1">Document Number</label>
                <input type="text" value={formData.document_number} onChange={(e) => handleInputChange('document_number', e.target.value)} className="w-full px-3 py-2 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="Auto-generated" disabled={mode === 'view'} />
              </div>
              <div className="col-span-8">
                <label className="block text-sm font-medium text-gray-700 mb-1">Title <span className="text-red-500">*</span></label>
                <input type="text" value={formData.title} onChange={(e) => handleInputChange('title', e.target.value)} className="w-full px-3 py-2 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" required disabled={mode === 'view'} />
              </div>
              <div className="col-span-1 flex items-end">
                <button type="button" onClick={() => setShowDescription(!showDescription)} className="w-full px-3 py-2 hover:bg-gray-100 rounded-md border border-gray-300" title="Add description">
                  <FileText className="w-4 h-4 text-gray-400 mx-auto" />
                </button>
              </div>
            </div>

            {/* Description (conditional) */}
            {showDescription && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                <textarea value={formData.description} onChange={(e) => handleInputChange('description', e.target.value)} rows={2} placeholder="Description (optional)" className="w-full px-3 py-2 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" disabled={isDisabled} />
              </div>
            )}

            {/* Row 2: Document Type, Document Subtype, Version, Part No */}
            <div className="grid grid-cols-4 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Document Type <span className="text-red-500">*</span></label>
                <select value={formData.document_type} onChange={(e) => handleInputChange('document_type', e.target.value)} className="w-full px-3 py-2 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" required disabled={isDisabled}>
                  <option value="">Select type</option>
                  {DOCUMENT_TYPES.map(type => <option key={type.value} value={type.value}>{type.label}</option>)}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Document Subtype</label>
                <select value={formData.document_subtype} onChange={(e) => handleInputChange('document_subtype', e.target.value)} className="w-full px-3 py-2 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" disabled={!formData.document_type || !DOCUMENT_SUBTYPES[formData.document_type]}>
                  <option value="">Select subtype</option>
                  {formData.document_type && DOCUMENT_SUBTYPES[formData.document_type]?.map(subtype => <option key={subtype.value} value={subtype.value}>{subtype.label}</option>)}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Version</label>
                <input type="text" value={formData.version} onChange={(e) => handleInputChange('version', e.target.value)} className="w-full px-3 py-2 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="1.0" />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Part No</label>
                <input type="text" value={formData.part_number} onChange={(e) => handleInputChange('part_number', e.target.value)} className="w-full px-3 py-2 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" placeholder="01, 02" />
              </div>
            </div>

            {/* Row 3: Parent Document and Hierarchy */}
            <div className="grid grid-cols-12 gap-4">
              <div className="col-span-10">
                <label className="block text-sm font-medium text-gray-700 mb-1">Parent Document</label>
                <div className="relative">
                  <input
                    type="text"
                    value={parentSearchQuery}
                    onChange={(e) => handleParentSearch(e.target.value)}
                    onFocus={() => {
                      if (parentDocuments.length > 0) {
                        setShowParentDropdown(true)
                        setFilteredParentDocs(parentDocuments)
                      }
                    }}
                    placeholder={formData.document_type ? "Search by document number or title..." : "Select document type first"}
                    className="w-full px-3 py-2 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                    disabled={!formData.document_type || loadingParents}
                  />
                  {loadingParents && <span className="absolute right-3 top-2 text-xs text-gray-400">Loading...</span>}
                  {showParentDropdown && filteredParentDocs.length > 0 && (
                    <div className="absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-md shadow-lg max-h-48 overflow-y-auto">
                      {filteredParentDocs.map((doc) => (
                        <button
                          key={doc.id}
                          type="button"
                          onClick={() => selectParentDocument(doc.id, doc.document_number, doc.title)}
                          className="w-full text-left px-3 py-2 text-sm hover:bg-blue-50 border-b last:border-b-0"
                        >
                          <div className="font-medium">{doc.document_number}</div>
                          <div className="text-xs text-gray-600">{doc.title} (Level {doc.document_level})</div>
                        </button>
                      ))}
                    </div>
                  )}
                </div>
              </div>
              <div className="col-span-2 flex items-end space-x-2">
                <button 
                  type="button" 
                  onClick={() => setShowHierarchy(!showHierarchy)}
                  className="flex-1 px-3 py-2 border border-gray-300 rounded-md hover:bg-gray-50 flex items-center justify-center"
                  title="Show/Hide Hierarchy"
                  disabled={!formData.parent_document_id}
                >
                  <TreePine className="w-4 h-4" />
                </button>
                <button 
                  type="button" 
                  onClick={() => formData.document_type && loadParentDocuments()}
                  className="flex-1 px-3 py-2 border border-gray-300 rounded-md hover:bg-gray-50 flex items-center justify-center"
                  title="Refresh Parent Documents"
                  disabled={!formData.document_type}
                >
                  <Search className="w-4 h-4" />
                </button>
              </div>
            </div>

            {/* Hierarchy Viewer */}
            {showHierarchy && hierarchyData.length > 0 && (
              <div className="bg-gray-50 rounded-md p-4">
                <h4 className="text-sm font-medium text-gray-700 mb-3">Document Hierarchy</h4>
                <div className="space-y-2">
                  {hierarchyData.map((item, index) => (
                    <div 
                      key={item.document_id} 
                      className="flex items-center text-sm"
                      style={{ paddingLeft: `${(item.level_depth - 1) * 20}px` }}
                    >
                      <div className="flex items-center">
                        {item.level_depth > 1 && (
                          <span className="text-gray-400 mr-2">
                            {'└─'.repeat(item.level_depth - 1)}
                          </span>
                        )}
                        <span className="font-medium text-blue-600">{item.document_number}</span>
                        <span className="text-gray-600 ml-2">{item.title}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Governance & Control */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Governance & Control (ISO 19650)</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">System Status</label>
              <select value={formData.system_status} onChange={(e) => handleInputChange('system_status', e.target.value)} className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                {SYSTEM_STATUSES.map(status => <option key={status.value} value={status.value}>{status.label}</option>)}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">User Status</label>
              <select value={formData.user_status} onChange={(e) => handleInputChange('user_status', e.target.value)} className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                <option value="">Select status</option>
                {USER_STATUSES.map(status => <option key={status.value} value={status.value}>{status.label}</option>)}
              </select>
            </div>
          </div>
        </div>

        {/* Object Links */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900">Object Links</h2>
            <button type="button" onClick={addObjectLink} className="flex items-center px-3 py-1.5 text-sm bg-blue-600 text-white rounded-md hover:bg-blue-700">
              <Plus className="w-4 h-4 mr-1" />
              Add Link
            </button>
          </div>
          {formData.object_links.length === 0 ? (
            <p className="text-gray-500 text-sm">No object links added</p>
          ) : (
            <div className="space-y-3">
              {formData.object_links.map((link, index) => (
                <div key={index} className="p-3 bg-gray-50 rounded-md space-y-2">
                  <div className="grid grid-cols-12 gap-3 items-start">
                    <div className="col-span-2">
                      <select value={link.object_type} onChange={(e) => updateObjectLink(index, 'object_type', e.target.value)} className="w-full px-2 py-1.5 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                        <option value="">Select type</option>
                        {OBJECT_TYPES.map(type => <option key={type.value} value={type.value}>{type.label}</option>)}
                      </select>
                    </div>
                    {link.object_type === 'WBS' && (
                      <div className="col-span-3">
                        <select value={link.project_code || ''} onChange={(e) => updateObjectLink(index, 'project_code', e.target.value)} className="w-full px-2 py-1.5 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                          <option value="">Select project {loadingProjects ? '(Loading...)' : `(${projectsList.length})`}</option>
                          {projectsList.map((proj, idx) => <option key={`${proj.project_code}-${idx}`} value={proj.project_code}>{proj.project_code} - {proj.project_name}</option>)}
                        </select>
                      </div>
                    )}
                    <div className={link.object_type === 'WBS' ? 'col-span-2' : 'col-span-3'}>
                      <select value={link.searchBy} onChange={(e) => updateObjectLink(index, 'searchBy', e.target.value)} disabled={!link.object_type || (link.object_type === 'WBS' && !link.project_code)} className="w-full px-2 py-1.5 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                        <option value="">Search by</option>
                        {link.object_type && SEARCH_CRITERIA[link.object_type]?.map(criteria => <option key={criteria.value} value={criteria.value}>{criteria.label}</option>)}
                      </select>
                    </div>
                    <div className={link.object_type === 'WBS' ? 'col-span-4' : 'col-span-6'}>
                      {link.object_id ? (
                        <div className="flex gap-2">
                          <input type="text" value={link.object_id} readOnly className="flex-1 px-2 py-1.5 text-sm border border-gray-300 rounded-md bg-gray-100" />
                          <button type="button" onClick={() => updateObjectLink(index, 'object_id', '')} className="px-2 py-1.5 text-xs bg-gray-200 rounded-md hover:bg-gray-300">Change</button>
                        </div>
                      ) : (
                        <div className="relative">
                          <input 
                            type="text" 
                            value={link.searchQuery} 
                            onChange={(e) => updateObjectLink(index, 'searchQuery', e.target.value)} 
                            onFocus={() => {
                              if (link.searchBy && !showAllObjects[index]) {
                                if (link.object_type === 'WBS' && link.project_code) {
                                  loadAllObjects(index, link.object_type, link.searchBy, link.project_code)
                                } else if (link.object_type !== 'WBS') {
                                  loadAllObjects(index, link.object_type, link.searchBy)
                                }
                              }
                            }}
                            placeholder={link.searchBy ? `Search or select...` : "Select search criteria"}
                            disabled={!link.searchBy}
                            className="w-full px-2 py-1.5 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" 
                          />
                          {searchingObjects[index] && <span className="absolute right-2 top-2 text-xs text-gray-400">Loading...</span>}
                          {(objectSearchResults[index]?.length > 0 || showAllObjects[index]) && (
                            <div className="absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-md shadow-lg max-h-48 overflow-y-auto">
                              {objectSearchResults[index]?.length > 0 ? (
                                objectSearchResults[index].map((obj: any, objIndex: number) => (
                                  <button
                                    key={`${obj.id}-${objIndex}`}
                                    type="button"
                                    onClick={() => selectObject(index, obj.id, obj.name || obj.title)}
                                    className="w-full text-left px-3 py-2 text-sm hover:bg-blue-50 border-b last:border-b-0"
                                  >
                                    <div className="font-medium">{obj.id}</div>
                                    <div className="text-xs text-gray-600">{obj.name || obj.title}</div>
                                  </button>
                                ))
                              ) : (
                                <div className="px-3 py-2 text-sm text-gray-500">No results found</div>
                              )}
                            </div>
                          )}
                        </div>
                      )}
                    </div>
                    <div className="col-span-1">
                      <button type="button" onClick={() => removeObjectLink(index)} className="p-1.5 text-red-600 hover:bg-red-50 rounded-md">
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                  {link.object_id && (
                    <input type="text" value={link.description} onChange={(e) => updateObjectLink(index, 'description', e.target.value)} placeholder="Description" className="w-full px-2 py-1.5 text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                  )}
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Form Actions */}
        <div className="flex items-center justify-end space-x-4">
          <button type="button" onClick={() => router.push('/erp-modules')} className="px-4 py-2 border border-gray-300 text-gray-700 rounded-md hover:bg-gray-50">Cancel</button>
          {mode !== 'view' && (
            <button type="submit" disabled={!isFormValid || loading} className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed">
              <Save className="w-4 h-4 mr-2" />
              {loading ? (mode === 'edit' ? 'Updating...' : 'Creating...') : (mode === 'edit' ? 'Update Document' : 'Create Document')}
            </button>
          )}
        </div>
      </form>
    </div>
  )
}