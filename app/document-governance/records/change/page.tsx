'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { Search, ArrowLeft, FileText } from 'lucide-react'
import Breadcrumb from '@/components/Breadcrumb'

interface DocumentRecord {
  id: string
  document_number: string
  title: string
  description?: string
  document_type: string
  current_lifecycle: {
    status: string
    version: string
  }
  created_at: string
}

export default function ChangeDocumentPage() {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [searchQuery, setSearchQuery] = useState('')
  const [searchResults, setSearchResults] = useState<DocumentRecord[]>([])

  const searchDocuments = async () => {
    if (!searchQuery.trim()) {
      alert('Please enter a document number or title to search')
      return
    }

    setLoading(true)
    try {
      const params = new URLSearchParams({
        action: 'find',
        document_number: searchQuery,
        title: searchQuery
      })

      const response = await fetch(`/api/document-governance/records?${params}`)
      const result = await response.json()
      
      if (result.success) {
        setSearchResults(result.data)
      } else {
        alert('Search failed. Please try again.')
        setSearchResults([])
      }
    } catch (error) {
      console.error('Search error:', error)
      alert('Failed to search documents. Please try again.')
      setSearchResults([])
    } finally {
      setLoading(false)
    }
  }

  const handleEditDocument = (doc: DocumentRecord) => {
    router.push(`/document-governance/records/new?id=${doc.id}&mode=edit`)
  }

  return (
    <div className="p-6">
      <Breadcrumb items={[
        { label: 'ERP Modules', href: '/erp-modules' },
        { label: 'Change Document' }
      ]} />
      
      <div className="mb-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Change Document</h1>
            <p className="text-gray-600 mt-2">Search and select a document to modify</p>
          </div>
          <button
            onClick={() => router.back()}
            className="flex items-center px-4 py-2 text-gray-600 border border-gray-300 rounded-md hover:bg-gray-50"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back
          </button>
        </div>
      </div>

      {/* Search Section */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6">
        <h2 className="text-lg font-semibold mb-4">Search Document</h2>
        <div className="flex items-center space-x-3">
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Enter document number or title"
            onKeyPress={(e) => e.key === 'Enter' && searchDocuments()}
          />
          <button
            onClick={searchDocuments}
            disabled={loading}
            className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
          >
            <Search className="w-4 h-4 mr-2" />
            {loading ? 'Searching...' : 'Search'}
          </button>
        </div>
      </div>

      {/* Search Results */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200">
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg font-semibold">
            Search Results ({searchResults.length} documents)
          </h3>
        </div>

        {searchResults.length === 0 ? (
          <div className="p-8 text-center">
            <FileText className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <p className="text-gray-600">No documents found. Try searching with different criteria.</p>
          </div>
        ) : (
          <div className="divide-y divide-gray-200">
            {searchResults.map((doc) => (
              <div key={doc.id} className="p-6 hover:bg-gray-50">
                <div className="flex items-center justify-between">
                  <div className="flex-1">
                    <h4 className="text-lg font-medium text-gray-900">{doc.document_number}</h4>
                    <p className="text-gray-600 mt-1">{doc.title}</p>
                    <div className="flex items-center space-x-4 mt-2 text-sm text-gray-500">
                      <span>Status: {doc.current_lifecycle?.status || 'DRAFT'}</span>
                      <span>Version: {doc.current_lifecycle?.version || '0.1'}</span>
                      <span>Created: {new Date(doc.created_at).toLocaleDateString()}</span>
                    </div>
                  </div>
                  <button
                    onClick={() => handleEditDocument(doc)}
                    className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
                  >
                    Edit Document
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}