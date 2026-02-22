'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { ArrowLeft } from 'lucide-react'
import Breadcrumb from '@/components/Breadcrumb'
import EnhancedConstructionTiles from '@/components/layout/EnhancedConstructionTiles'

const CATEGORY_ROUTES: { [key: string]: string } = {
  'Document Governance': '/document-governance',
  'Materials Management': '/materials-management',
  'Finance': '/finance',
  'Projects': '/projects',
  'Human Resources': '/human-resources'
}

export default function DocumentGovernancePage() {
  const router = useRouter()
  const [tiles, setTiles] = useState([])
  const [loading, setLoading] = useState(true)
  const category = 'Document Governance'

  useEffect(() => {
    loadTiles()
  }, [])

  const loadTiles = async () => {
    try {
      const response = await fetch(`/api/tiles?category=${encodeURIComponent(category)}`)
      const result = await response.json()
      if (result.success) {
        setTiles(result.tiles)
      }
    } catch (error) {
      console.error('Failed to load tiles:', error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="p-6">
      <Breadcrumb items={[
        { label: 'ERP Modules', href: '/erp-modules' },
        { label: category }
      ]} />
      
      <div className="mb-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">{category}</h1>
            <p className="text-gray-600 mt-2">Manage documents, drawings, contracts, and specifications</p>
          </div>
          <button 
            onClick={() => router.push('/erp-modules')} 
            className="flex items-center px-4 py-2 text-gray-600 border border-gray-300 rounded-md hover:bg-gray-50"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back to Modules
          </button>
        </div>
      </div>

      {loading ? (
        <div className="flex justify-center items-center h-64">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
        </div>
      ) : (
        <EnhancedConstructionTiles tiles={tiles} />
      )}
    </div>
  )
}
