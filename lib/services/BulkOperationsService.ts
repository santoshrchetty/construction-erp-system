import { createClient } from '@supabase/supabase-js'
import { exportToExcel, exportMaterialsTemplate, importFromExcel } from '@/lib/excel-export'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

export class BulkOperationsService {
  
  /**
   * Export materials to Excel
   */
  static async exportMaterials(filters?: {
    company_code?: string;
    plant_code?: string;
    category?: string;
  }) {
    try {
      let query = supabase
        .from('materials')
        .select(`
          material_code,
          material_name,
          description,
          category,
          base_uom,
          material_type,
          is_active,
          material_plant_data(
            plant_code,
            reorder_level,
            safety_stock,
            standard_price
          )
        `)
        .eq('is_active', true)

      if (filters?.company_code) {
        query = query.eq('company_code', filters.company_code)
      }
      
      if (filters?.category) {
        query = query.eq('category', filters.category)
      }

      const { data, error } = await query

      if (error) throw error

      // Transform data for export
      const exportData = data?.map(material => ({
        item_code: material.material_code,
        description: material.material_name,
        category: material.category,
        unit: material.base_uom,
        material_type: material.material_type,
        plant_code: material.material_plant_data?.[0]?.plant_code || '',
        reorder_level: material.material_plant_data?.[0]?.reorder_level || 0,
        safety_stock: material.material_plant_data?.[0]?.safety_stock || 0,
        standard_price: material.material_plant_data?.[0]?.standard_price || 0,
        currency: 'INR',
        is_active: material.is_active
      })) || []

      exportMaterialsTemplate(exportData)
      return { success: true, count: exportData.length }

    } catch (error) {
      return { 
        success: false, 
        error: error instanceof Error ? error.message : 'Export failed' 
      }
    }
  }

  /**
   * Export activities to Excel
   */
  static async exportActivities(projectCode: string) {
    try {
      const { data, error } = await supabase
        .from('activities')
        .select(`
          code,
          name,
          description,
          project_code,
          wbs_element,
          planned_start_date,
          planned_end_date,
          actual_start_date,
          actual_end_date,
          duration_days,
          progress_percentage,
          status,
          priority,
          budget_amount,
          direct_cost_total
        `)
        .eq('project_code', projectCode)
        .eq('is_active', true)

      if (error) throw error

      const filename = `${projectCode}_activities_${new Date().toISOString().split('T')[0]}.xlsx`
      exportToExcel(data || [], filename, 'Activities')
      
      return { success: true, count: data?.length || 0 }

    } catch (error) {
      return { 
        success: false, 
        error: error instanceof Error ? error.message : 'Export failed' 
      }
    }
  }

  /**
   * Export WBS elements to Excel
   */
  static async exportWBS(projectCode: string) {
    try {
      const { data, error } = await supabase
        .from('wbs_elements')
        .select('*')
        .eq('project_code', projectCode)
        .eq('is_active', true)
        .order('wbs_level', { ascending: true })

      if (error) throw error

      const filename = `${projectCode}_wbs_${new Date().toISOString().split('T')[0]}.xlsx`
      exportToExcel(data || [], filename, 'WBS Elements')
      
      return { success: true, count: data?.length || 0 }

    } catch (error) {
      return { 
        success: false, 
        error: error instanceof Error ? error.message : 'Export failed' 
      }
    }
  }

  /**
   * Import materials from Excel file
   */
  static async importMaterials(file: File) {
    try {
      const jsonData = await importFromExcel(file)
      
      // Transform and validate data
      const materials = jsonData.map((row: any, index: number) => ({
        line: index + 1,
        material_code: row['item_code'] || row['material_code'],
        material_name: row['description'] || row['material_name'],
        category: row['category'],
        base_uom: row['unit'] || row['base_uom'],
        plant_code: row['plant_code'],
        reorder_level: parseFloat(row['reorder_level']) || 0,
        safety_stock: parseFloat(row['safety_stock']) || 0,
        standard_price: parseFloat(row['standard_price']) || 0,
        currency: row['currency'] || 'INR',
        company_code: row['company_code'] || 'C001'
      })).filter(material => material.material_code && material.material_name)

      // Send to bulk upload API
      const response = await fetch('/api/materials/bulk-upload', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ materials })
      })

      const result = await response.json()
      return result

    } catch (error) {
      return { 
        success: false, 
        error: error instanceof Error ? error.message : 'Import failed' 
      }
    }
  }

  /**
   * Export users to Excel
   */
  static async exportUsers() {
    try {
      const { data, error } = await supabase
        .from('users')
        .select(`
          email,
          first_name,
          last_name,
          employee_code,
          department,
          is_active,
          roles(name)
        `)
        .eq('is_active', true)

      if (error) throw error

      const exportData = data?.map(user => ({
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        employee_code: user.employee_code,
        department: user.department,
        role: user.roles?.name,
        is_active: user.is_active
      })) || []

      const filename = `users_export_${new Date().toISOString().split('T')[0]}.xlsx`
      exportToExcel(exportData, filename, 'Users')
      
      return { success: true, count: exportData.length }

    } catch (error) {
      return { 
        success: false, 
        error: error instanceof Error ? error.message : 'Export failed' 
      }
    }
  }

  /**
   * Download template for specific entity type
   */
  static downloadTemplate(entityType: 'materials' | 'users' | 'activities') {
    switch (entityType) {
      case 'materials':
        exportMaterialsTemplate()
        break
      case 'users':
        const userTemplate = [{
          email: 'user@example.com',
          password: 'temp123',
          first_name: 'John',
          last_name: 'Doe',
          role_id: 'role-uuid-here',
          department: 'Engineering'
        }]
        exportToExcel(userTemplate, 'user_bulk_upload_template.xlsx', 'Users')
        break
      case 'activities':
        const activityTemplate = [{
          code: 'ACT-001',
          name: 'Foundation Work',
          description: 'Excavation and foundation laying',
          project_code: 'PROJ-001',
          wbs_element: 'WBS-001',
          planned_start_date: '2024-01-01',
          planned_end_date: '2024-01-15',
          duration_days: 14,
          budget_amount: 50000
        }]
        exportToExcel(activityTemplate, 'activity_bulk_upload_template.xlsx', 'Activities')
        break
    }
  }
}