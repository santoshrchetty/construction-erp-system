import * as XLSX from 'xlsx';

/**
 * Export data to Excel file
 */
export function exportToExcel(
  data: any[],
  filename: string,
  sheetName: string = 'Data'
) {
  const ws = XLSX.utils.json_to_sheet(data);
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, sheetName);
  XLSX.writeFile(wb, filename);
}

/**
 * Export multiple sheets to single Excel file
 */
export function exportMultiSheet(
  sheets: { name: string; data: any[] }[],
  filename: string
) {
  const wb = XLSX.utils.book_new();
  
  sheets.forEach(sheet => {
    const ws = XLSX.utils.json_to_sheet(sheet.data);
    XLSX.utils.book_append_sheet(wb, ws, sheet.name);
  });
  
  XLSX.writeFile(wb, filename);
}

/**
 * Generate filename with project code and date
 */
export function generateExportFilename(
  projectCode: string,
  type: string
): string {
  const date = new Date().toISOString().split('T')[0];
  return `${projectCode}_${type}_${date}.xlsx`;
}

/**
 * Export materials with template format
 */
export function exportMaterialsTemplate(
  materials: any[] = [],
  filename?: string
) {
  const templateData = materials.length > 0 ? materials : [
    {
      item_code: 'CEMENT-OPC-53',
      description: 'OPC 53 Grade Cement',
      category: 'CEMENT',
      unit: 'BAG',
      plant_code: 'P001',
      plant_name: 'Main Plant',
      reorder_level: 100,
      safety_stock: 50,
      standard_price: 500.00,
      currency: 'INR',
      sloc_code: 'S001',
      sloc_name: 'Main Store',
      current_stock: 0,
      company_code: 'C001',
      company_name: 'ABC Construction'
    }
  ];

  const finalFilename = filename || `material_export_${new Date().toISOString().split('T')[0]}.xlsx`;
  exportToExcel(templateData, finalFilename, 'Materials');
}

/**
 * Export activities data
 */
export function exportActivities(
  activities: any[],
  projectCode: string
) {
  const filename = generateExportFilename(projectCode, 'activities');
  exportToExcel(activities, filename, 'Activities');
}

/**
 * Export WBS elements
 */
export function exportWBS(
  wbsElements: any[],
  projectCode: string
) {
  const filename = generateExportFilename(projectCode, 'wbs');
  exportToExcel(wbsElements, filename, 'WBS Elements');
}

/**
 * Import Excel file and return JSON data
 */
export async function importFromExcel(file: File): Promise<any[]> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    
    reader.onload = (e) => {
      try {
        const data = new Uint8Array(e.target?.result as ArrayBuffer);
        const workbook = XLSX.read(data, { type: 'array' });
        const sheetName = workbook.SheetNames[0];
        const worksheet = workbook.Sheets[sheetName];
        const jsonData = XLSX.utils.sheet_to_json(worksheet);
        resolve(jsonData);
      } catch (error) {
        reject(error);
      }
    };
    
    reader.onerror = () => reject(new Error('Failed to read file'));
    reader.readAsArrayBuffer(file);
  });
}
