'use client'

import { useState } from 'react'
import { useState } from 'react'
import * as Icons from 'lucide-react'

// API service function following 4-layer architecture
const createUsersBatch = async (users: any[]) => {
  const response = await fetch('/api/admin?action=bulk-create-users', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ users })
  })
  return await response.json()
}

interface BulkUploadProps {
  onComplete: () => void
}

export default function BulkUserUpload({ onComplete }: BulkUploadProps) {
  const [file, setFile] = useState<File | null>(null)
  const [uploading, setUploading] = useState(false)
  const [progress, setProgress] = useState('')

  const handleFileUpload = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!file) return

    setUploading(true)
    setProgress('Reading file...')

    try {
      const text = await file.text()
      const lines = text.split('\n').slice(1) // Skip header
      
      const users = lines
        .filter(line => line.trim())
        .map(line => {
          const [email, password, firstName, lastName, roleId, department] = line.split(',')
          return {
            email: email?.trim(),
            password: password?.trim(),
            first_name: firstName?.trim(),
            last_name: lastName?.trim(),
            role_id: roleId?.trim(),
            department: department?.trim()
          }
        })
        .filter(user => user.email && user.password && user.role_id)

      setProgress(`Processing ${users.length} users...`)
      
      const results = await createUsersBatch(users)
      const successful = results.filter(r => r.status === 'fulfilled').length
      const failed = results.length - successful

      setProgress(`Complete: ${successful} created, ${failed} failed`)
      
      setTimeout(() => {
        onComplete()
        setUploading(false)
        setFile(null)
        setProgress('')
      }, 2000)

    } catch (error) {
      setProgress('Upload failed')
      setUploading(false)
    }
  }

  return (
    <div className="bg-white rounded-lg shadow p-6">
      <h3 className="text-lg font-bold mb-4">Bulk User Upload</h3>
      
      <div className="mb-4 p-4 bg-blue-50 rounded">
        <p className="text-sm text-blue-800">
          Upload CSV with columns: email, password, first_name, last_name, role_id, department
        </p>
      </div>

      <form onSubmit={handleFileUpload} className="space-y-4">
        <div>
          <input
            type="file"
            accept=".csv"
            onChange={(e) => setFile(e.target.files?.[0] || null)}
            className="w-full border rounded px-3 py-2"
            disabled={uploading}
          />
        </div>
        
        {progress && (
          <div className="p-3 bg-gray-100 rounded">
            <p className="text-sm">{progress}</p>
          </div>
        )}

        <div className="flex justify-end space-x-3">
          <button
            type="submit"
            disabled={!file || uploading}
            className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700 disabled:opacity-50"
          >
            {uploading ? 'Uploading...' : 'Upload Users'}
          </button>
        </div>
      </form>
    </div>
  )
}