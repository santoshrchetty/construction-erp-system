import { createServiceClient } from '@/lib/supabase'

export interface DataIntegrityIssue {
  table_name: string
  issue_type: string
  issue_count: number
  details: string
}

export class DataIntegrityService {
  private supabase = createServiceClient()

  /**
   * Validate data integrity across all related tables
   */
  async validateDataIntegrity(): Promise<DataIntegrityIssue[]> {
    try {
      const { data, error } = await this.supabase
        .rpc('validate_data_integrity')
      
      if (error) throw error
      
      return data || []
    } catch (error) {
      console.error('Data integrity validation failed:', error)
      throw error
    }
  }

  /**
   * Validate company exists before creating/updating plant
   */
  async validateCompanyExists(companyCodeId: string): Promise<boolean> {
    try {
      const { data, error } = await this.supabase
        .from('company_codes')
        .select('id')
        .eq('id', companyCodeId)
        .single()
      
      if (error && error.code !== 'PGRST116') throw error
      
      return !!data
    } catch (error) {
      console.error('Company validation failed:', error)
      return false
    }
  }

  /**
   * Validate plant exists before creating/updating storage location
   */
  async validatePlantExists(plantId: string): Promise<boolean> {
    try {
      const { data, error } = await this.supabase
        .from('plants')
        .select('id')
        .eq('id', plantId)
        .single()
      
      if (error && error.code !== 'PGRST116') throw error
      
      return !!data
    } catch (error) {
      console.error('Plant validation failed:', error)
      return false
    }
  }

  /**
   * Validate storage location exists before creating stock balance
   */
  async validateStorageLocationExists(storageLocationId: string): Promise<boolean> {
    try {
      const { data, error } = await this.supabase
        .from('storage_locations')
        .select('id')
        .eq('id', storageLocationId)
        .single()
      
      if (error && error.code !== 'PGRST116') throw error
      
      return !!data
    } catch (error) {
      console.error('Storage location validation failed:', error)
      return false
    }
  }

  /**
   * Validate stock item exists before creating stock balance
   */
  async validateStockItemExists(stockItemId: string): Promise<boolean> {
    try {
      const { data, error } = await this.supabase
        .from('stock_items')
        .select('id')
        .eq('id', stockItemId)
        .single()
      
      if (error && error.code !== 'PGRST116') throw error
      
      return !!data
    } catch (error) {
      console.error('Stock item validation failed:', error)
      return false
    }
  }

  /**
   * Fix orphaned plant relationships by inferring from plant codes
   */
  async fixOrphanedPlants(): Promise<{ fixed: number; errors: string[] }> {
    const errors: string[] = []
    let fixed = 0

    try {
      // Get orphaned plants
      const { data: orphanedPlants } = await this.supabase
        .from('plants')
        .select('id, plant_code, company_code_id')
        .is('company_code_id', null)

      if (!orphanedPlants) return { fixed: 0, errors: [] }

      // Get all companies for mapping
      const { data: companies } = await this.supabase
        .from('company_codes')
        .select('id, company_code')

      const companyMap = companies?.reduce((acc, company) => {
        acc[company.company_code] = company.id
        return acc
      }, {} as Record<string, string>) || {}

      // Fix each orphaned plant
      for (const plant of orphanedPlants) {
        try {
          let inferredCompanyCode = ''
          
          // Infer company from plant code pattern
          if (plant.plant_code.startsWith('N')) inferredCompanyCode = 'N001'
          else if (plant.plant_code.startsWith('C') || plant.plant_code.startsWith('P')) inferredCompanyCode = 'C001'
          else if (plant.plant_code.startsWith('B')) inferredCompanyCode = 'B001'

          const companyId = companyMap[inferredCompanyCode]
          
          if (companyId) {
            const { error } = await this.supabase
              .from('plants')
              .update({ company_code_id: companyId })
              .eq('id', plant.id)

            if (error) {
              errors.push(`Failed to fix plant ${plant.plant_code}: ${error.message}`)
            } else {
              fixed++
            }
          } else {
            errors.push(`Could not infer company for plant ${plant.plant_code}`)
          }
        } catch (error) {
          errors.push(`Error processing plant ${plant.plant_code}: ${error}`)
        }
      }
    } catch (error) {
      errors.push(`Failed to fix orphaned plants: ${error}`)
    }

    return { fixed, errors }
  }

  /**
   * Run comprehensive data integrity check and return report
   */
  async generateIntegrityReport(): Promise<{
    issues: DataIntegrityIssue[]
    hasIssues: boolean
    summary: string
  }> {
    const issues = await this.validateDataIntegrity()
    const hasIssues = issues.some(issue => issue.issue_count > 0)
    
    const totalIssues = issues.reduce((sum, issue) => sum + issue.issue_count, 0)
    const summary = hasIssues 
      ? `Found ${totalIssues} data integrity issues across ${issues.length} checks`
      : 'All data integrity checks passed'

    return { issues, hasIssues, summary }
  }
}

export const dataIntegrityService = new DataIntegrityService()