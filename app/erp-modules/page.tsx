'use client'

import { Suspense } from 'react'
import { useSearchParams } from 'next/navigation'
import EnhancedConstructionTiles from '@/components/layout/EnhancedConstructionTiles'

function LoadingFallback() {
  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center">
      <div className="text-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
        <p className="mt-4 text-gray-600">Loading ERP Modules...</p>
      </div>
    </div>
  )
}

function ERPModulesContent() {
  const searchParams = useSearchParams()
  const category = searchParams.get('category')
  
  return <EnhancedConstructionTiles filterCategory={category || undefined} />
}

export default function ERPModulesPage() {
  return (
    <Suspense fallback={<LoadingFallback />}>
      <ERPModulesContent />
    </Suspense>
  )
}