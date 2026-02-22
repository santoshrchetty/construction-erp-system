'use client'

import { useState, useEffect } from 'react'
import { Search, Filter, Eye, Edit, FileText, Download, Settings, Trash2, ArrowLeft } from 'lucide-react'
import Breadcrumb from '@/components/Breadcrumb'
import { useRouter } from 'next/navigation'

interface DocumentRecord {
  id: string
  document_number: string
  document_type: string
  title: string
  description?: string
  document_subtype?: string
  part_number?: string
  parent_document_id?: string
  document_level: number
  project_code: string
  created_at: string
  parent_document?: {
    document_number: string
    title: string
  }
  current_lifecycle: {
    version: string
    revision?: string
    status: string
    effective_date?: string
  }
}

interface SearchFilters {
  document_number: string
  title: string
  document_type: string
  status: string
  project_id: string
}

interface ColumnConfig {
  key: keyof DocumentRecord | 'current_lifecycle.status' | 'current_lifecycle.version' | 'parent_document.document_number'
  label: string
  visible: boolean
}

const DEFAULT_COLUMNS: ColumnConfig[] = [
  { key: 'document_number', label: 'Document Number', visible: true },
  { key: 'title', label: 'Title', visible: true },
  { key: 'document_type', label: 'Type', visible: true },
  { key: 'document_subtype', label: 'Subtype', visible: true },
  { key: 'part_number', label: 'Part Number', visible: true },
  { key: 'document_level', label: 'Level', visible: true },
  { key: 'current_lifecycle.status', label: 'Status', visible: true },
  { key: 'current_lifecycle.version', label: 'Version', visible: true },
  { key: 'parent_document.document_number', label: 'Parent Document', visible: false },
  { key: 'project_code', label: 'Project', visible: false },
  { key: 'description', label: 'Description', visible: false },
  { key: 'created_at', label: 'Created Date', visible: false }
]

export default function FindDocumentPage() {
  const router = useRouter()
  const [documents, setDocuments] = useState<DocumentRecord[]>([])
  const [loading, setLoading] = useState(false)
  const [showFilters, setShowFilters] = useState(false)
  const [showColumnConfig, setShowColumnConfig] = useState(false)
  const [columns, setColumns] = useState<ColumnConfig[]>(DEFAULT_COLUMNS)
  const [filters, setFilters] = useState<SearchFilters>({
    document_number: '',
    title: '',
    document_type: '',
    status: '',
    project_id: ''
  })
  const [documentTypes, setDocumentTypes] = useState<Array<{value: string, label: string}>>([])
  const [documentStatuses, setDocumentStatuses] = useState<Array<{value: string, label: string}>>([])

  useEffect(() => {
    loadDocumentTypes()
    loadDocumentStatuses()
    searchDocuments()
  }, [])

  const loadDocumentTypes = async () => {
    try {
      const response = await fetch('/api/document-governance/records?action=document-types')
      const result = await response.json()
      if (result.success) {
        setDocumentTypes(result.data)
      }
    } catch (error) {
      console.error('Failed to load document types:', error)
    }
  }

  const loadDocumentStatuses = async () => {
    try {
      const response = await fetch('/api/document-governance/records?action=document-statuses')
      const result = await response.json()
      if (result.success) {
        setDocumentStatuses(result.data)
      }
    } catch (error) {
      console.error('Failed to load document statuses:', error)
    }
  }

  const searchDocuments = async () => {
    setLoading(true)
    try {
      const params = new URLSearchParams({
        action: 'find',
        ...Object.fromEntries(Object.entries(filters).filter(([_, value]) => value))
      })

      const response = await fetch(`/api/document-governance/records?${params}`)
      const result = await response.json()
      
      if (result.success) {
        setDocuments(result.data)
      } else {
        console.error('Search failed:', result.error)
      }
    } catch (error) {
      console.error('Search error:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleFilterChange = (field: keyof SearchFilters, value: string) => {
    setFilters(prev => ({ ...prev, [field]: value }))
  }

  const clearFilters = () => {
    setFilters({
      document_number: '',
      title: '',
      document_type: '',
      status: '',
      project_id: ''
    })
  }

  const getStatusColor = (status: string) => {
    const colors = {
      'DRAFT': 'bg-gray-100 text-gray-800',
      'IFR': 'bg-yellow-100 text-yellow-800',
      'IFA': 'bg-blue-100 text-blue-800',
      'IFC': 'bg-green-100 text-green-800',
      'AS_BUILT': 'bg-purple-100 text-purple-800',
      'VOID': 'bg-red-100 text-red-800'
    }
    return colors[status as keyof typeof colors] || 'bg-gray-100 text-gray-800'
  }

  const toggleColumn = (key: string) => {
    setColumns(prev => prev.map(col => 
      col.key === key ? { ...col, visible: !col.visible } : col
    ))
  }

  const downloadCSV = () => {
    const visibleColumns = columns.filter(col => col.visible)
    const headers = visibleColumns.map(col => col.label).join(',')
    
    const rows = documents.map(doc => {
      return visibleColumns.map(col => {
        let value = ''
        if (col.key === 'current_lifecycle.status') {
          value = doc.current_lifecycle?.status || 'DRAFT'
        } else if (col.key === 'current_lifecycle.version') {
          value = doc.current_lifecycle?.version || '0.1'
        } else if (col.key === 'parent_document.document_number') {
          value = doc.parent_document?.document_number || ''
        } else {
          value = String(doc[col.key as keyof DocumentRecord] || '')
        }
        return `"${value.replace(/"/g, '""')}"`
      }).join(',')
    })
    
    const csv = [headers, ...rows].join('\n')
    const blob = new Blob([csv], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `documents_${new Date().toISOString().split('T')[0]}.csv`
    a.click()
    URL.revokeObjectURL(url)
  }

  const handleView = (doc: DocumentRecord) => {
    router.push(`/document-governance/records/display?id=${doc.id}`)
  }

  const handleEdit = (doc: DocumentRecord) => {
    router.push(`/document-governance/records/new?id=${doc.id}&mode=edit`)
  }

  const handleDelete = async (doc: DocumentRecord) => {
    const isDraft = doc.current_lifecycle?.status === 'DRAFT'
    const deleteType = isDraft ? 'permanently delete' : 'archive'
    
    if (!confirm(`Are you sure you want to ${deleteType} document ${doc.document_number}?`)) {
      return
    }

    try {
      const response = await fetch('/api/document-governance/records', {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
          action: 'delete', 
          documentId: doc.id,
          hardDelete: isDraft
        })
      })

      const result = await response.json()
      if (result.success) {
        alert(`Document ${doc.document_number} ${isDraft ? 'deleted' : 'archived'} successfully`)
        searchDocuments() // Refresh the list
      } else {
        alert(`Error: ${result.error}`)
      }
    } catch (error) {
      console.error('Delete error:', error)
      alert('Failed to delete document')
    }
  }

  return (
    <div className="p-6">
      <div className="mb-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Find Document</h1>
            <p className="text-gray-600 mt-2">Search and view document records</p>
          </div>
          <button 
            onClick={() => router.push('/erp-modules?category=Document Governance')} 
            className="flex items-center px-4 py-2 text-gray-600 border border-gray-300 rounded-md hover:bg-gray-50"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back
          </button>
        </div>
      </div>

      {/* Search and Filter Section */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold">Search Documents</h2>
          <div className="flex items-center space-x-2">
            <button
              onClick={() => setShowColumnConfig(!showColumnConfig)}
              className="flex items-center px-3 py-2 text-sm border border-gray-300 rounded-md hover:bg-gray-50"
            >
              <Settings className="w-4 h-4 mr-2" />
              Columns
            </button>
            <button
              onClick={downloadCSV}
              disabled={documents.length === 0}
              className="flex items-center px-3 py-2 text-sm border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50"
            >
              <Download className="w-4 h-4 mr-2" />
              Download
            </button>
            <button
              onClick={() => setShowFilters(!showFilters)}
              className="flex items-center px-3 py-2 text-sm border border-gray-300 rounded-md hover:bg-gray-50"
            >
              <Filter className="w-4 h-4 mr-2" />
              {showFilters ? 'Hide Filters' : 'Show Filters'}
            </button>
          </div>
        </div>

        {showColumnConfig && (
          <div className="mb-4 p-4 bg-gray-50 rounded-md">
            <h3 className="text-sm font-medium text-gray-700 mb-3">Select Columns to Display</h3>
            <div className="grid grid-cols-3 gap-2">
              {columns.map(col => (
                <label key={col.key} className="flex items-center space-x-2">
                  <input
                    type="checkbox"
                    checked={col.visible}
                    onChange={() => toggleColumn(col.key)}
                    className="rounded border-gray-300"
                  />
                  <span className="text-sm text-gray-700">{col.label}</span>
                </label>
              ))}
            </div>
          </div>
        )}

        {showFilters && (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Document Number
              </label>
              <input
                type="text"
                value={filters.document_number}
                onChange={(e) => handleFilterChange('document_number', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Enter document number"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Title
              </label>
              <input
                type="text"
                value={filters.title}
                onChange={(e) => handleFilterChange('title', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Enter title"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Document Type
              </label>
              <select
                value={filters.document_type}
                onChange={(e) => handleFilterChange('document_type', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">All Types</option>
                {documentTypes.map(type => (
                  <option key={type.value} value={type.value}>{type.label}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Status
              </label>
              <select
                value={filters.status}
                onChange={(e) => handleFilterChange('status', e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="">All Statuses</option>
                {documentStatuses.map(status => (
                  <option key={status.value} value={status.value}>{status.label}</option>
                ))}
              </select>
            </div>
          </div>
        )}

        <div className="flex items-center space-x-3">
          <button
            onClick={searchDocuments}
            disabled={loading}
            className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
          >
            <Search className="w-4 h-4 mr-2" />
            {loading ? 'Searching...' : 'Search'}
          </button>
          <button
            onClick={clearFilters}
            className="px-4 py-2 border border-gray-300 text-gray-700 rounded-md hover:bg-gray-50"
          >
            Clear Filters
          </button>
        </div>
      </div>

      {/* Results Section */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200">
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg font-semibold">
            Search Results ({documents.length} documents)
          </h3>
        </div>

        {loading ? (
          <div className="p-8 text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
            <p className="mt-2 text-gray-600">Searching documents...</p>
          </div>
        ) : documents.length === 0 ? (
          <div className="p-8 text-center">
            <FileText className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <p className="text-gray-600">No documents found matching your criteria</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  {columns.filter(col => col.visible).map(col => (
                    <th key={col.key} className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      {col.label}
                    </th>
                  ))}
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {documents.map((doc) => (
                  <tr key={doc.id} className="hover:bg-gray-50">
                    {columns.filter(col => col.visible).map(col => (
                      <td key={col.key} className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        {col.key === 'current_lifecycle.status' ? (
                          <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(doc.current_lifecycle?.status || 'DRAFT')}`}>
                            {doc.current_lifecycle?.status || 'DRAFT'}
                          </span>
                        ) : col.key === 'current_lifecycle.version' ? (
                          <span>
                            {doc.current_lifecycle?.version || '0.1'}
                            {doc.current_lifecycle?.revision && ` Rev ${doc.current_lifecycle.revision}`}
                          </span>
                        ) : col.key === 'parent_document.document_number' ? (
                          doc.parent_document?.document_number || '-'
                        ) : col.key === 'document_number' ? (
                          <span className="font-medium">{doc[col.key as keyof DocumentRecord]}</span>
                        ) : col.key === 'created_at' ? (
                          new Date(doc.created_at).toLocaleDateString()
                        ) : (
                          String(doc[col.key as keyof DocumentRecord] || '-')
                        )}
                      </td>
                    ))}
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <div className="flex items-center space-x-2">
                        <button 
                          onClick={() => handleView(doc)}
                          className="text-blue-600 hover:text-blue-900"
                          title="View Document"
                        >
                          <Eye className="w-4 h-4" />
                        </button>
                        <button 
                          onClick={() => handleEdit(doc)}
                          className="text-green-600 hover:text-green-900"
                          title="Edit Document"
                        >
                          <Edit className="w-4 h-4" />
                        </button>
                        <button 
                          onClick={() => handleDelete(doc)}
                          className="text-red-600 hover:text-red-900"
                          title={doc.current_lifecycle?.status === 'DRAFT' ? 'Delete Document' : 'Archive Document'}
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  )
}