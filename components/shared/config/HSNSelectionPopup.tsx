'use client'

import { useState } from 'react'
import { X, Search } from 'lucide-react'

interface HSNOption {
  hsn_code: string
  description: string
  gst_rate: number
  is_default: boolean
}

interface HSNSelectionPopupProps {
  isOpen: boolean
  onClose: () => void
  onSelect: (hsnCode: string) => void
  hsnOptions: HSNOption[]
  materialGroup: string
  defaultHsn?: string
}

export default function HSNSelectionPopup({
  isOpen,
  onClose,
  onSelect,
  hsnOptions,
  materialGroup,
  defaultHsn
}: HSNSelectionPopupProps) {
  const [searchTerm, setSearchTerm] = useState('')

  if (!isOpen) return null

  const filteredOptions = hsnOptions.filter(option =>
    option.hsn_code.includes(searchTerm) || 
    option.description.toLowerCase().includes(searchTerm.toLowerCase())
  )

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 max-w-4xl w-full mx-4 max-h-[80vh] overflow-y-auto">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-lg font-semibold">Select HSN Code - {materialGroup}</h3>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="mb-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input
              type="text"
              placeholder="Search HSN code or description..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
            />
          </div>
        </div>

        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">HSN Code</th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Description</th>
              <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">GST Rate</th>
              <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Action</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {filteredOptions.map((option) => (
              <tr key={option.hsn_code} className={`hover:bg-gray-50 ${option.hsn_code === defaultHsn ? 'bg-blue-50' : ''}`}>
                <td className="px-4 py-4 text-sm font-mono font-medium text-gray-900">{option.hsn_code}</td>
                <td className="px-4 py-4 text-sm text-gray-900">{option.description}</td>
                <td className="px-4 py-4 text-center text-sm text-gray-900">{option.gst_rate}%</td>
                <td className="px-4 py-4 text-center">
                  <button
                    onClick={() => onSelect(option.hsn_code)}
                    className="bg-blue-100 text-blue-700 px-3 py-1 rounded text-sm hover:bg-blue-200"
                  >
                    Select
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}