import { useState, useEffect, useCallback } from 'react'

interface DropdownData {
  companies: Array<{ code: string; name: string }>
  projectTypes: Array<{ value: string; label: string }>
  costCenters: Array<{ id: string; name: string }>
  profitCenters: Array<{ id: string; name: string }>
  personsResponsible: Array<{ id: string; name: string }>
}

interface UseDropdownDataReturn {
  data: DropdownData
  loading: boolean
  error: string | null
  refetch: () => Promise<void>
}

export const useDropdownData = (): UseDropdownDataReturn => {
  const [data, setData] = useState<DropdownData>({
    companies: [],
    projectTypes: [],
    costCenters: [],
    profitCenters: [],
    personsResponsible: []
  })
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchData = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)

      // Use only existing working endpoints
      const [companiesRes] = await Promise.all([
        fetch('/api/erp-config?category=erp-config')
      ])

      const [companiesData] = await Promise.all([
        companiesRes.json()
      ])

      setData({
        companies: companiesData.success ? companiesData.data.company_codes || [] : [],
        projectTypes: [
          { value: 'commercial', label: 'Commercial' },
          { value: 'residential', label: 'Residential' },
          { value: 'industrial', label: 'Industrial' },
          { value: 'infrastructure', label: 'Infrastructure' }
        ],
        costCenters: [],
        profitCenters: [],
        personsResponsible: []
      })
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load dropdown data')
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    fetchData()
  }, [fetchData])

  return { data, loading, error, refetch: fetchData }
}