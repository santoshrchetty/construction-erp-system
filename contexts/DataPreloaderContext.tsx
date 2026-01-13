import React, { createContext, useContext, ReactNode } from 'react'
import { useDropdownData } from '../hooks/useDropdownData'

interface DropdownData {
  companies: Array<{ code: string; name: string }>
  projectTypes: Array<{ value: string; label: string }>
  costCenters: Array<{ id: string; name: string }>
  profitCenters: Array<{ id: string; name: string }>
  personsResponsible: Array<{ id: string; name: string }>
}

interface DataPreloaderContextType {
  data: DropdownData
  loading: boolean
  error: string | null
  refetch: () => Promise<void>
}

const DataPreloaderContext = createContext<DataPreloaderContextType | undefined>(undefined)

interface DataPreloaderProviderProps {
  children: ReactNode
}

export const DataPreloaderProvider: React.FC<DataPreloaderProviderProps> = ({ children }) => {
  const dropdownData = useDropdownData()

  return (
    <DataPreloaderContext.Provider value={dropdownData}>
      {children}
    </DataPreloaderContext.Provider>
  )
}

export const usePreloadedData = (): DataPreloaderContextType => {
  const context = useContext(DataPreloaderContext)
  if (context === undefined) {
    throw new Error('usePreloadedData must be used within a DataPreloaderProvider')
  }
  return context
}