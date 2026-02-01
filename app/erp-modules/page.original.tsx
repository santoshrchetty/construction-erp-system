'use client'

import { Suspense } from 'react'
import EnhancedConstructionTiles from '../../components/layout/EnhancedConstructionTiles'

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

export default function ERPModulesPageOriginal() {
  return (
    <Suspense fallback={<LoadingFallback />}>
      <EnhancedConstructionTiles />
    </Suspense>
  )
}