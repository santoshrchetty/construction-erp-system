'use client'

import React, { useState, useEffect } from 'react'
import { Plus, Trash2, Calculator, Save, X } from 'lucide-react'
import { useGLPosting } from '../../../hooks/useGLPosting'

interface GLAccount {
  account_number: string
  account_name: string
  account_type: string
}

interface CostCenter {
  cost_center_code: string
  cost_center_name: string
}

interface Project {
  code: string
  name: string
}

interface GLEntry {
  id: string
  gl_account: string
  debit_amount: number
  credit_amount: number
  cost_center: string
  project_code: string
  wbs_element: string
  description: string
}

export default function GLPosting() {
  const [companyCode, setCompanyCode] = useState('')
  const [postingDate, setPostingDate] = useState(new Date().toISOString().split('T')[0])
  const [documentDate, setDocumentDate] = useState(new Date().toISOString().split('T')[0])
  const [reference, setReference] = useState('')
  const [headerText, setHeaderText] = useState('')
  const [posting, setPosting] = useState(false)
  
  const { accounts, costCenters, projects, companies, config, loading, dataError, retryCount, postDocument, refreshData } = useGLPosting(companyCode)
  
  const [entries, setEntries] = useState<GLEntry[]>([
    { id: '1', gl_account: '', debit_amount: 0, credit_amount: 0, cost_center: '', project_code: '', wbs_element: '', description: '' },
    { id: '2', gl_account: '', debit_amount: 0, credit_amount: 0, cost_center: '', project_code: '', wbs_element: '', description: '' }
  ])

  useEffect(() => {
    if (companies.length > 0 && !companyCode) {
      setCompanyCode(companies[0].code)
    }
  }, [companies, companyCode])

  const addEntry = () => {
    const newEntry: GLEntry = {
      id: Date.now().toString(),
      gl_account: '',
      debit_amount: 0,
      credit_amount: 0,
      cost_center: '',
      project_code: '',
      wbs_element: '',
      description: ''
    }
    setEntries([...entries, newEntry])
  }

  const removeEntry = (id: string) => {
    if (entries.length > config.minimum_entries) {
      setEntries(entries.filter(entry => entry.id !== id))
    }
  }

  const updateEntry = (id: string, field: keyof GLEntry, value: string | number) => {
    setEntries(entries.map(entry => 
      entry.id === id ? { ...entry, [field]: value } : entry
    ))
  }

  const calculateTotals = () => {
    const totalDebit = entries.reduce((sum, entry) => sum + (entry.debit_amount || 0), 0)
    const totalCredit = entries.reduce((sum, entry) => sum + (entry.credit_amount || 0), 0)
    const difference = totalDebit - totalCredit
    return { totalDebit, totalCredit, difference, isBalanced: Math.abs(difference) < config.balance_tolerance }
  }

  const handlePost = async () => {
    const { isBalanced } = calculateTotals()
    if (!isBalanced) {
      alert('Document must be balanced before posting')
      return
    }

    setPosting(true)
    try {
      const document = {
        company_code: companyCode,
        posting_date: postingDate,
        document_date: documentDate,
        reference,
        header_text: headerText,
        entries: entries
          .filter(entry => entry.gl_account && (entry.debit_amount > 0 || entry.credit_amount > 0))
          .map(entry => ({
            account_code: entry.gl_account,
            debit_amount: entry.debit_amount,
            credit_amount: entry.credit_amount,
            cost_center: entry.cost_center,
            project_code: entry.project_code,
            description: entry.description
          }))
      }

      const result = await postDocument(document, 'current-user-id') // TODO: Get actual user ID
      
      if (result.success) {
        alert(`Document ${result.document_number} posted successfully`)
        // Reset form
        setEntries([
          { id: '1', gl_account: '', debit_amount: 0, credit_amount: 0, cost_center: '', project_code: '', wbs_element: '', description: '' },
          { id: '2', gl_account: '', debit_amount: 0, credit_amount: 0, cost_center: '', project_code: '', wbs_element: '', description: '' }
        ])
        setReference('')
        setHeaderText('')
      } else {
        alert(`Posting failed: ${result.error || 'Unknown error'}`)
      }
    } catch (error) {
      console.error('Posting error:', error)
      alert('Posting failed: Network error')
    } finally {
      setPosting(false)
    }
  }

  const { totalDebit, totalCredit, difference, isBalanced } = calculateTotals()

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  // Show error state if critical data is missing
  if (dataError.accounts) {
    return (
      <div className="min-h-screen bg-gray-50 p-4 flex items-center justify-center">
        <div className="bg-white rounded-lg shadow-sm border p-6 max-w-md">
          <div className="text-red-600 text-center">
            <h3 className="text-lg font-semibold mb-2">Unable to Load GL Posting</h3>
            <p className="text-sm mb-2">{dataError.accounts}</p>
            <p className="text-xs text-gray-500 mb-4">Retry attempts: {retryCount.accounts}</p>
            <div className="space-y-2">
              <button 
                onClick={() => refreshData()}
                className="w-full px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
              >
                Retry Loading Data
              </button>
              <button 
                onClick={() => window.location.reload()}
                className="w-full px-4 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700"
              >
                Refresh Page
              </button>
            </div>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50 p-2 sm:p-4">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="bg-white rounded-lg shadow-sm border p-4 mb-4">
          {/* Warning banners for non-critical data errors */}
          {(dataError.costCenters || dataError.projects) && (
            <div className="mb-4 p-3 bg-yellow-50 border border-yellow-200 rounded-md">
              <div className="flex items-center justify-between">
                <div>
                  <h4 className="text-sm font-medium text-yellow-800">Partial Data Loading Issues</h4>
                  <div className="text-xs text-yellow-700 mt-1">
                    {dataError.costCenters && <div>• Cost Centers: {dataError.costCenters}</div>}
                    {dataError.projects && <div>• Projects: {dataError.projects}</div>}
                  </div>
                </div>
                <button 
                  onClick={() => refreshData()}
                  className="text-xs px-2 py-1 bg-yellow-600 text-white rounded hover:bg-yellow-700"
                >
                  Retry
                </button>
              </div>
            </div>
          )}
          
          {/* Document Header */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Company Code</label>
              <select 
                value={companyCode} 
                onChange={(e) => setCompanyCode(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              >
                {companies.map((company) => (
                  <option key={company.code} value={company.code}>
                    {company.name}
                  </option>
                ))}
              </select>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Posting Date</label>
              <input
                type="date"
                value={postingDate}
                onChange={(e) => setPostingDate(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Document Date</label>
              <input
                type="date"
                value={documentDate}
                onChange={(e) => setDocumentDate(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Reference</label>
              <input
                type="text"
                value={reference}
                onChange={(e) => setReference(e.target.value)}
                placeholder="Document reference"
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              />
            </div>
          </div>
          
          <div className="mt-4">
            <label className="block text-sm font-medium text-gray-700 mb-1">Header Text</label>
            <input
              type="text"
              value={headerText}
              onChange={(e) => setHeaderText(e.target.value)}
              placeholder="Document description"
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
        </div>

        {/* Journal Entries */}
        <div className="bg-white rounded-lg shadow-sm border p-4 mb-4">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-lg font-semibold text-gray-900">Journal Entries</h2>
            <button
              onClick={addEntry}
              className="flex items-center gap-2 px-3 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors"
            >
              <Plus className="w-4 h-4" />
              <span className="hidden sm:inline">Add Line</span>
            </button>
          </div>

          {/* Mobile Card View */}
          <div className="block lg:hidden space-y-4">
            {entries.map((entry, index) => (
              <div key={entry.id} className="border rounded-lg p-4 bg-gray-50">
                <div className="flex justify-between items-center mb-3">
                  <span className="font-medium text-gray-900">Line {index + 1}</span>
                  {entries.length > config.minimum_entries && (
                    <button
                      onClick={() => removeEntry(entry.id)}
                      className="text-red-600 hover:text-red-800"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  )}
                </div>
                
                <div className="space-y-3">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">GL Account</label>
                    <select
                      value={entry.gl_account}
                      onChange={(e) => updateEntry(entry.id, 'gl_account', e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    >
                      <option value="">Select Account</option>
                      {accounts.map(account => (
                        <option key={account.account_number} value={account.account_number}>
                          {account.account_number} - {account.account_name}
                        </option>
                      ))}
                    </select>
                  </div>
                  
                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Debit</label>
                      <input
                        type="number"
                        step="0.01"
                        value={entry.debit_amount || ''}
                        onChange={(e) => updateEntry(entry.id, 'debit_amount', parseFloat(e.target.value) || 0)}
                        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Credit</label>
                      <input
                        type="number"
                        step="0.01"
                        value={entry.credit_amount || ''}
                        onChange={(e) => updateEntry(entry.id, 'credit_amount', parseFloat(e.target.value) || 0)}
                        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      />
                    </div>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                    <input
                      type="text"
                      value={entry.description}
                      onChange={(e) => updateEntry(entry.id, 'description', e.target.value)}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    />
                  </div>
                  
                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Cost Center</label>
                      <select
                        value={entry.cost_center || ''}
                        onChange={(e) => updateEntry(entry.id, 'cost_center', e.target.value)}
                        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      >
                        <option value="">Select Cost Center</option>
                        {costCenters.map(cc => (
                          <option key={cc.cost_center_code} value={cc.cost_center_code}>
                            {cc.cost_center_code} - {cc.cost_center_name}
                          </option>
                        ))}
                      </select>
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1">Project/WBS</label>
                      <select
                        value={entry.project_code || ''}
                        onChange={(e) => updateEntry(entry.id, 'project_code', e.target.value)}
                        className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      >
                        <option value="">Select Project</option>
                        {projects.map(project => (
                          <option key={project.code} value={project.code}>
                            {project.code} - {project.name}
                          </option>
                        ))}
                      </select>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* Desktop Table View */}
          <div className="hidden lg:block overflow-x-auto">
            <table className="min-w-full">
              <thead>
                <tr className="border-b">
                  <th className="text-left py-2 px-3 font-medium text-gray-700">Line</th>
                  <th className="text-left py-2 px-3 font-medium text-gray-700">GL Account</th>
                  <th className="text-right py-2 px-3 font-medium text-gray-700">Debit</th>
                  <th className="text-right py-2 px-3 font-medium text-gray-700">Credit</th>
                  <th className="text-left py-2 px-3 font-medium text-gray-700">Cost Center</th>
                  <th className="text-left py-2 px-3 font-medium text-gray-700">Project/WBS</th>
                  <th className="text-left py-2 px-3 font-medium text-gray-700">Description</th>
                  <th className="text-center py-2 px-3 font-medium text-gray-700">Actions</th>
                </tr>
              </thead>
              <tbody>
                {entries.map((entry, index) => (
                  <tr key={entry.id} className="border-b">
                    <td className="py-2 px-3 text-sm">{index + 1}</td>
                    <td className="py-2 px-3">
                      <select
                        value={entry.gl_account}
                        onChange={(e) => updateEntry(entry.id, 'gl_account', e.target.value)}
                        className="w-full px-2 py-1 border border-gray-300 rounded text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      >
                        <option value="">Select Account</option>
                        {accounts.map(account => (
                          <option key={account.account_number} value={account.account_number}>
                            {account.account_number} - {account.account_name}
                          </option>
                        ))}
                      </select>
                    </td>
                    <td className="py-2 px-3">
                      <input
                        type="number"
                        step="0.01"
                        value={entry.debit_amount || ''}
                        onChange={(e) => updateEntry(entry.id, 'debit_amount', parseFloat(e.target.value) || 0)}
                        className="w-full px-2 py-1 border border-gray-300 rounded text-sm text-right focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      />
                    </td>
                    <td className="py-2 px-3">
                      <input
                        type="number"
                        step="0.01"
                        value={entry.credit_amount || ''}
                        onChange={(e) => updateEntry(entry.id, 'credit_amount', parseFloat(e.target.value) || 0)}
                        className="w-full px-2 py-1 border border-gray-300 rounded text-sm text-right focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      />
                    </td>
                    <td className="py-2 px-3">
                      <select
                        value={entry.cost_center || ''}
                        onChange={(e) => updateEntry(entry.id, 'cost_center', e.target.value)}
                        className="w-full px-2 py-1 border border-gray-300 rounded text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      >
                        <option value="">Select</option>
                        {costCenters.map(cc => (
                          <option key={cc.cost_center_code} value={cc.cost_center_code}>
                            {cc.cost_center_code}
                          </option>
                        ))}
                      </select>
                    </td>
                    <td className="py-2 px-3">
                      <select
                        value={entry.project_code || ''}
                        onChange={(e) => updateEntry(entry.id, 'project_code', e.target.value)}
                        className="w-full px-2 py-1 border border-gray-300 rounded text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      >
                        <option value="">Select</option>
                        {projects.map(project => (
                          <option key={project.code} value={project.code}>
                            {project.code}
                          </option>
                        ))}
                      </select>
                    </td>
                    <td className="py-2 px-3">
                      <input
                        type="text"
                        value={entry.description}
                        onChange={(e) => updateEntry(entry.id, 'description', e.target.value)}
                        className="w-full px-2 py-1 border border-gray-300 rounded text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                      />
                    </td>
                    <td className="py-2 px-3 text-center">
                      {entries.length > config.minimum_entries && (
                        <button
                          onClick={() => removeEntry(entry.id)}
                          className="text-red-600 hover:text-red-800"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Totals and Actions */}
        <div className="bg-white rounded-lg shadow-sm border p-4">
          <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
            <div className="flex items-center gap-4">
              <Calculator className="w-5 h-5 text-gray-600" />
              <div className="text-sm">
                <span className="font-medium">Debit: ${totalDebit.toFixed(2)}</span>
                <span className="mx-2">|</span>
                <span className="font-medium">Credit: ${totalCredit.toFixed(2)}</span>
                <span className="mx-2">|</span>
                <span className={`font-medium ${isBalanced ? 'text-green-600' : 'text-red-600'}`}>
                  Difference: ${Math.abs(difference).toFixed(2)}
                </span>
              </div>
            </div>
            
            <button
              onClick={handlePost}
              disabled={!isBalanced || posting}
              className={`flex items-center gap-2 px-6 py-2 rounded-md font-medium transition-colors ${
                isBalanced && !posting
                  ? 'bg-green-600 text-white hover:bg-green-700'
                  : 'bg-gray-300 text-gray-500 cursor-not-allowed'
              }`}
            >
              {posting ? (
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
              ) : (
                <Save className="w-4 h-4" />
              )}
              {posting ? 'Posting...' : 'Post Document'}
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}