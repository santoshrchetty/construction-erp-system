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
