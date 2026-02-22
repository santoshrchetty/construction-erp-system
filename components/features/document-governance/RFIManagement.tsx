'use client'

import { useState, useEffect } from 'react'
import { HelpCircle, Plus, Search, MessageCircle, CheckCircle } from 'lucide-react'

interface RFI {
  rfi_id: string
  rfi_number: string
  subject: string
  discipline: string
  status: string
  priority: string
  created_at: string
  due_date: string
}

export default function RFIManagement() {
  const [rfis, setRfis] = useState<RFI[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [filterStatus, setFilterStatus] = useState('ALL')

  useEffect(() => {
    fetchRfis()
  }, [])

  const fetchRfis = async () => {
    setLoading(true)
    try {
      const response = await fetch('/api/document-governance?resource=rfis')
      const result = await response.json()
      if (result.success) {
        setRfis(result.data || [])
      }
    } catch (error) {
      console.error('Error fetching RFIs:', error)
    } finally {
      setLoading(false)
    }
  }

  const filteredRfis = rfis.filter(r => {
    const matchesSearch = r.rfi_number.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         r.subject.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesStatus = filterStatus === 'ALL' || r.status === filterStatus
    return matchesSearch && matchesStatus
  })

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'Open': return 'bg-blue-100 text-blue-800'
      case 'Answered': return 'bg-green-100 text-green-800'
      case 'Closed': return 'bg-gray-100 text-gray-800'
      default: return 'bg-yellow-100 text-yellow-800'
    }
  }

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case 'High': return 'bg-red-100 text-red-800'
      case 'Medium': return 'bg-yellow-100 text-yellow-800'
      case 'Low': return 'bg-green-100 text-green-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  return (
    <div className="p-6 bg-gray-50 min-h-screen">
      <div className="max-w-7xl mx-auto">
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-900">RFI Management</h1>
          <p className="text-gray-600">Manage requests for information</p>
        </div>

        <div className="bg-white rounded-lg shadow-sm p-4 mb-6">
          <button className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
            <Plus className="w-4 h-4" />
            New RFI
          </button>
        </div>

        <div className="bg-white rounded-lg shadow-sm p-4 mb-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
              <input
                type="text"
                placeholder="Search RFIs..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg"
              />
            </div>
            <select value={filterStatus} onChange={(e) => setFilterStatus(e.target.value)} className="px-4 py-2 border border-gray-300 rounded-lg">
              <option value="ALL">All Statuses</option>
              <option value="Open">Open</option>
              <option value="Answered">Answered</option>
              <option value="Closed">Closed</option>
            </select>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-sm">
          {filteredRfis.length === 0 ? (
            <div className="p-8 text-center">
              <HelpCircle className="w-12 h-12 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-600">No RFIs found</p>
            </div>
          ) : (
            <table className="w-full">
              <thead className="bg-gray-50 border-b">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">RFI #</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Subject</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Discipline</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Priority</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Due Date</th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y">
                {filteredRfis.map((rfi) => (
                  <tr key={rfi.rfi_id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 text-sm font-medium">{rfi.rfi_number}</td>
                    <td className="px-6 py-4 text-sm">{rfi.subject}</td>
                    <td className="px-6 py-4 text-sm">{rfi.discipline}</td>
                    <td className="px-6 py-4">
                      <span className={`px-2 py-1 text-xs rounded-full ${getPriorityColor(rfi.priority)}`}>{rfi.priority}</span>
                    </td>
                    <td className="px-6 py-4">
                      <span className={`px-2 py-1 text-xs rounded-full ${getStatusColor(rfi.status)}`}>{rfi.status}</span>
                    </td>
                    <td className="px-6 py-4 text-sm">{rfi.due_date}</td>
                    <td className="px-6 py-4 text-right">
                      <div className="flex justify-end gap-2">
                        <button className="text-blue-600 hover:text-blue-900"><MessageCircle className="w-4 h-4" /></button>
                        <button className="text-green-600 hover:text-green-900"><CheckCircle className="w-4 h-4" /></button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </div>
  )
}
