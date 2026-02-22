'use client'

import { useState, useEffect } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { ArrowLeft, Search } from 'lucide-react'

export default function DisplayDocumentPage() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const documentId = searchParams.get('id')
  const [loading, setLoading] = useState(false)
  const [document, setDocument] = useState<any>(null)
  const [searchNumber, setSearchNumber] = useState('')
  const [error, setError] = useState('')

  useEffect(() => {
    if (documentId) {
      loadDocument(documentId)
    }
  }, [documentId])

  const loadDocument = async (id: string) => {
    setLoading(true)
    setError('')
    try {
      const response = await fetch(`/api/document-governance/records?action=get&id=${id}`)
      const result = await response.json()
      if (result.success) {
        setDocument(result.data)
      } else {
        setError('Document not found')
      }
    } catch (error) {
      console.error('Load error:', error)
      setError('Failed to load document')
    } finally {
      setLoading(false)
    }
  }

  const handleSearch = async () => {
    if (!searchNumber.trim()) {
      setError('Please enter a document number')
      return
    }
    
    setLoading(true)
    setError('')
    try {
      const response = await fetch(`/api/document-governance/records?action=find&document_number=${searchNumber}`)
      const result = await response.json()
      if (result.success && result.data && result.data.length > 0) {
        setDocument(result.data[0])
      } else {
        setError('Document not found')
        setDocument(null)
      }
    } catch (error) {
      console.error('Search error:', error)
      setError('Failed to search document')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="p-6">
      <div className="mb-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Display Document</h1>
            <p className="text-gray-600 mt-2">Enter document number to view details</p>
          </div>
          <button onClick={() => router.push('/erp-modules?category=Document Governance')} className="flex items-center px-4 py-2 text-gray-600 border border-gray-300 rounded-md hover:bg-gray-50">
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back
          </button>
        </div>
      </div>

      {/* Search Input */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6">
        <div className="flex gap-4">
          <input
            type="text"
            value={searchNumber}
            onChange={(e) => setSearchNumber(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && handleSearch()}
            placeholder="Enter document number (e.g., DOC-1771486253490)"
            className="flex-1 px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <button
            onClick={handleSearch}
            disabled={loading}
            className="flex items-center px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
          >
            <Search className="w-4 h-4 mr-2" />
            {loading ? 'Searching...' : 'Search'}
          </button>
        </div>
        {error && <p className="text-red-600 text-sm mt-2">{error}</p>}
      </div>

      {/* Document Display */}
      {document && (
        <div className="space-y-6">
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Basic Information</h2>
            <div className="space-y-4">
              <div className="grid grid-cols-12 gap-4">
                <div className="col-span-3">
                  <label className="block text-sm font-medium text-gray-700 mb-1">Document Number</label>
                  <input type="text" value={document.document_number || ''} disabled className="w-full px-3 py-2 text-sm border border-gray-300 rounded-md bg-gray-100 text-gray-600" />
                </div>
                <div className="col-span-9">
                  <label className="block text-sm font-medium text-gray-700 mb-1">Title</label>
                  <input type="text" value={document.title || ''} disabled className="w-full px-3 py-2 text-sm border border-gray-300 rounded-md bg-gray-100 text-gray-600" />
                </div>
              </div>

              {document.description && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                  <textarea value={document.description} disabled rows={2} className="w-full px-3 py-2 text-sm border border-gray-300 rounded-md bg-gray-100 text-gray-600" />
                </div>
              )}

              <div className="grid grid-cols-4 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Document Type</label>
                  <input type="text" value={document.document_type || ''} disabled className="w-full px-3 py-2 text-sm border border-gray-300 rounded-md bg-gray-100 text-gray-600" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Subtype</label>
                  <input type="text" value={document.document_subtype || ''} disabled className="w-full px-3 py-2 text-sm border border-gray-300 rounded-md bg-gray-100 text-gray-600" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
                  <input type="text" value={document.current_lifecycle?.status || ''} disabled className="w-full px-3 py-2 text-sm border border-gray-300 rounded-md bg-gray-100 text-gray-600" />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Version</label>
                  <input type="text" value={document.current_lifecycle?.version || ''} disabled className="w-full px-3 py-2 text-sm border border-gray-300 rounded-md bg-gray-100 text-gray-600" />
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
