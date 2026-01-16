import React, { Suspense, ComponentType } from 'react'
import { DataPreloaderProvider } from '../contexts/DataPreloaderContext'

interface LazyWrapperProps {
  children: React.ReactNode
  fallback?: React.ReactNode
}

const DefaultFallback = () => (
  <div className="flex items-center justify-center p-8">
    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
    <span className="ml-2 text-gray-600">Loading...</span>
  </div>
)

export const LazyWrapper: React.FC<LazyWrapperProps> = ({ 
  children, 
  fallback = <DefaultFallback /> 
}) => {
  return (
    <DataPreloaderProvider>
      <Suspense fallback={fallback}>
        {children}
      </Suspense>
    </DataPreloaderProvider>
  )
}

// Enhanced lazy loading with data preloading
export const createLazyComponent = <T extends ComponentType<any>>(
  importFn: () => Promise<{ default: T }>
) => {
  const LazyComponent = React.lazy(importFn)
  
  return React.forwardRef<any, React.ComponentProps<T>>((props, ref) => (
    <LazyWrapper>
      <LazyComponent {...props} ref={ref} />
    </LazyWrapper>
  ))
}