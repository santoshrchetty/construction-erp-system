'use client'

import { useState } from 'react'
import * as Icons from 'lucide-react'
import { ImportExportButton } from '@/components/shared/ImportExportButton'
import { BulkOperationsService } from '@/lib/services/BulkOperationsService'

interface ActivityImportExportProps {
  projectCode: string
  onImportComplete?: () => void
}

export default function ActivityImportExport({ 
  projectCode, 
  onImportComplete 
}: ActivityImportExportProps) {
  const [importing, setImporting] = useState(false)
  const [progress, setProgress] = useState('')

  const handleExportActivities = async () => {
    if (!projectCode) {
      alert('Please select a project first')
      return
    }

    const result = await BulkOperationsService.exportActivities(projectCode)
    
    if (result.success) {
      alert(`Exported ${result.count} activities successfully!`)
    } else {
      alert('Export failed: ' + result.error)
    }
  }

  const handleImportActivities = async (file: File) => {
    if (!projectCode) {
      alert('Please select a project first')
      return
    }

    setImporting(true)
    setProgress('Processing activities...')

    try {
      // Import and process the Excel file
      const response = await fetch('/api/activities/bulk-upload', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
          file: await fileToBase64(file),
          projectCode 
        })
      })

      const result = await response.json()
      
      if (result.success) {
        setProgress(`Complete: ${result.data.successful} created, ${result.data.failed} failed`)
        setTimeout(() => {
          onImportComplete?.()
          setProgress('')
        }, 2000)
      } else {
        setProgress('Import failed: ' + result.error)
      }
    } catch (error) {
      setProgress('Import failed: ' + (error as Error).message)
    } finally {
      setImporting(false)
    }
  }

  const downloadTemplate = () => {
    BulkOperationsService.downloadTemplate('activities')
  }

  const fileToBase64 = (file: File): Promise<string> => {
    return new Promise((resolve, reject) => {
      const reader = new FileReader()
      reader.readAsDataURL(file)
      reader.onload = () => resolve(reader.result as string)
      reader.onerror = error => reject(error)
    })
  }

  return (
    <div className="bg-white rounded-lg shadow p-4">
      <div className="flex justify-between items-center mb-4">
        <h3 className="text-md font-medium">Activity Import/Export</h3>
        <div className="flex gap-2">
          <button
            onClick={downloadTemplate}
            className="px-3 py-1.5 bg-gray-600 text-white rounded-lg hover:bg-gray-700 text-sm"
          >
            <Icons.Download className="w-4 h-4 inline mr-1" />
            Template
          </button>
          <ImportExportButton
            onExport={handleExportActivities}
            onImport={handleImportActivities}
            disabled={!projectCode || importing}
            acceptedFileTypes=".xlsx,.xls,.csv"
          />
        </div>
      </div>

      {progress && (
        <div className="p-3 bg-gray-100 rounded mb-4">
          <p className="text-sm">{progress}</p>
        </div>
      )}

      <div className="text-sm text-gray-600">
        <p className="mb-2">
          <strong>Project:</strong> {projectCode || 'No project selected'}
        </p>
        <p>
          Use the template to ensure proper column formatting for bulk activity import.
        </p>
      </div>
    </div>
  )
}