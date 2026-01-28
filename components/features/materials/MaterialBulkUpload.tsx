'use client'

import { useState } from 'react'
import * as Icons from 'lucide-react'
import * as XLSX from 'xlsx'

interface MaterialBulkUploadProps {
  onComplete: () => void
}

export default function MaterialBulkUpload({ onComplete }: MaterialBulkUploadProps) {
  const [file, setFile] = useState<File | null>(null)
  const [uploading, setUploading] = useState(false)
  const [progress, setProgress] = useState('')
  const [previewData, setPreviewData] = useState<any[]>([])
  const [showPreview, setShowPreview] = useState(false)

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFile = e.target.files?.[0]
    if (!selectedFile) return

    setFile(selectedFile)
    setProgress('Reading file...')

    try {
      const data = await selectedFile.arrayBuffer()
      const workbook = XLSX.read(data)
      const worksheet = workbook.Sheets[workbook.SheetNames[0]]
      const jsonData = XLSX.utils.sheet_to_json(worksheet)

      // Transform data to match material master structure
      const materials = jsonData.map((row: any, index: number) => ({
        line: index + 1,
        material_code: row['item_code'] || row['material_code'],
        material_name: row['description'] || row['material_name'],
        category: row['category'],
        base_uom: row['unit'] || row['base_uom'],
        plant_code: row['plant_code'],
        plant_name: row['plant_name'],
        reorder_level: parseFloat(row['reorder_level']) || 0,
        safety_stock: parseFloat(row['safety_stock']) || 0,
        standard_price: parseFloat(row['standard_price']) || 0,
        currency: row['currency'] || 'INR',
        sloc_code: row['sloc_code'],
        sloc_name: row['sloc_name'],
        current_stock: parseFloat(row['current_stock']) || 0,
        company_code: row['company_code'] || 'C001',
        company_name: row['company_name']
      })).filter(material => material.material_code && material.material_name)

      setPreviewData(materials)
      setShowPreview(true)
      setProgress(`Preview ready: ${materials.length} materials`)
    } catch (error) {
      setProgress('Error reading file: ' + (error as Error).message)
    }
  }

  const processBulkUpload = async () => {
    if (!previewData.length) return

    setUploading(true)
    setProgress('Processing materials...')

    try {
      const response = await fetch('/api/materials/bulk-upload', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ materials: previewData })
      })

      const result = await response.json()
      
      if (result.success) {
        setProgress(`Complete: ${result.data.successful} created, ${result.data.failed} failed`)
        setTimeout(() => {
          onComplete()
          resetForm()
        }, 2000)
      } else {
        setProgress('Upload failed: ' + result.error)
      }
    } catch (error) {
      setProgress('Upload failed: ' + (error as Error).message)
    } finally {
      setUploading(false)
    }
  }

  const resetForm = () => {
    setFile(null)
    setPreviewData([])
    setShowPreview(false)
    setProgress('')
    setUploading(false)
  }

  const downloadTemplate = () => {
    const template = [
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
    ]

    const ws = XLSX.utils.json_to_sheet(template)
    const wb = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(wb, ws, 'Material Template')
    XLSX.writeFile(wb, 'material_bulk_upload_template.xlsx')
  }

  return (
    <div className="bg-white rounded-lg shadow p-6">
      <h3 className="text-lg font-bold mb-4">Material Bulk Upload</h3>
      
      <div className="mb-4 p-4 bg-blue-50 rounded">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-blue-800 mb-2">
              Upload Excel/CSV with material master data
            </p>
            <p className="text-xs text-blue-600">
              Required columns: item_code, description, category, unit
            </p>
          </div>
          <button
            onClick={downloadTemplate}
            className="px-3 py-1 bg-blue-600 text-white rounded text-sm hover:bg-blue-700"
          >
            <Icons.Download className="w-4 h-4 inline mr-1" />
            Template
          </button>
        </div>
      </div>

      <div className="space-y-4">
        <div>
          <input
            type="file"
            accept=".xlsx,.xls,.csv"
            onChange={handleFileUpload}
            className="w-full border rounded px-3 py-2"
            disabled={uploading}
          />
        </div>
        
        {progress && (
          <div className="p-3 bg-gray-100 rounded">
            <p className="text-sm">{progress}</p>
          </div>
        )}

        {showPreview && (
          <div className="border rounded p-4">
            <h4 className="font-medium mb-2">Preview ({previewData.length} materials)</h4>
            <div className="max-h-60 overflow-y-auto">
              <table className="min-w-full text-sm">
                <thead>
                  <tr className="bg-gray-50">
                    <th className="px-2 py-1 text-left">Code</th>
                    <th className="px-2 py-1 text-left">Name</th>
                    <th className="px-2 py-1 text-left">Category</th>
                    <th className="px-2 py-1 text-left">UOM</th>
                    <th className="px-2 py-1 text-left">Plant</th>
                  </tr>
                </thead>
                <tbody>
                  {previewData.slice(0, 10).map((material, index) => (
                    <tr key={index} className="border-t">
                      <td className="px-2 py-1">{material.material_code}</td>
                      <td className="px-2 py-1">{material.material_name}</td>
                      <td className="px-2 py-1">{material.category}</td>
                      <td className="px-2 py-1">{material.base_uom}</td>
                      <td className="px-2 py-1">{material.plant_code}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
              {previewData.length > 10 && (
                <p className="text-xs text-gray-500 mt-2">
                  Showing first 10 of {previewData.length} materials
                </p>
              )}
            </div>
          </div>
        )}

        <div className="flex justify-end space-x-3">
          <button
            type="button"
            onClick={resetForm}
            className="px-4 py-2 bg-gray-500 text-white rounded hover:bg-gray-600"
          >
            Clear
          </button>
          <button
            onClick={processBulkUpload}
            disabled={!showPreview || uploading}
            className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700 disabled:opacity-50"
          >
            {uploading ? 'Uploading...' : 'Upload Materials'}
          </button>
        </div>
      </div>
    </div>
  )
}