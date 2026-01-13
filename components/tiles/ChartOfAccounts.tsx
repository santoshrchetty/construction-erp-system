'use client'

import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'

interface ChartAccount {
  id: string
  coa_code: string
  coa_name: string
  account_code: string
  account_name: string
  account_type: 'ASSET' | 'LIABILITY' | 'EQUITY' | 'REVENUE' | 'EXPENSE'
  cost_relevant: boolean
  balance_sheet_account: boolean
  cost_category?: string
  company_code: string
}

interface GroupedAccounts {
  [key: string]: ChartAccount[]
}

export default function ChartOfAccounts() {
  const [accounts, setAccounts] = useState<ChartAccount[]>([])
  const [groupedAccounts, setGroupedAccounts] = useState<GroupedAccounts>({})
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedType, setSelectedType] = useState<string>('ALL')
  const [selectedCompany, setSelectedCompany] = useState<string>('')
  const [companies, setCompanies] = useState<{code: string, name: string}[]>([])
  const [showCreateForm, setShowCreateForm] = useState(false)
  const [showEditForm, setShowEditForm] = useState(false)
  const [showUpload, setShowUpload] = useState(false)
  const [showCopy, setShowCopy] = useState(false)
  const [sourceCompany, setSourceCompany] = useState('')
  const [editingAccount, setEditingAccount] = useState<ChartAccount | null>(null)
  const [formData, setFormData] = useState({
    coa_code: '',
    coa_name: '',
    account_code: '',
    account_name: '',
    account_type: 'ASSET' as ChartAccount['account_type'],
    cost_relevant: false,
    balance_sheet_account: false,
    cost_category: ''
  })
  const [viewMode, setViewMode] = useState<'list' | 'grouped'>('grouped')

  // Mobile responsive state
  const [isMobile, setIsMobile] = useState(false)

  useEffect(() => {
    const checkMobile = () => setIsMobile(window.innerWidth < 768)
    checkMobile()
    window.addEventListener('resize', checkMobile)
    return () => window.removeEventListener('resize', checkMobile)
  }, [])

  useEffect(() => {
    fetchCompanies()
  }, [])

  useEffect(() => {
    fetchAccounts()
  }, [searchTerm, selectedType, selectedCompany])

  const fetchCompanies = async () => {
    try {
      const response = await fetch('/api/tiles?category=finance&action=companies')
      const result = await response.json()
      if (result.success && result.data) {
        setCompanies(result.data)
        if (result.data.length > 0 && !selectedCompany) {
          setSelectedCompany(result.data[0].code)
        }
      }
    } catch (error) {
      console.error('Error fetching companies:', error)
    }
  }

  const fetchAccounts = async () => {
    setLoading(true)
    try {
      const params = new URLSearchParams({
        category: 'finance',
        action: 'chart_of_accounts',
        company_code: selectedCompany,
        ...(searchTerm && { search: searchTerm }),
        ...(selectedType !== 'ALL' && { account_type: selectedType })
      })

      console.log('Fetching accounts with params:', params.toString())
      const response = await fetch(`/api/tiles?${params}`)
      const result = await response.json()
      console.log('API Response:', result)

      if (result.success) {
        setAccounts(result.data?.accounts || [])
        setGroupedAccounts(result.data?.grouped || {})
        console.log('Accounts loaded:', result.data?.accounts?.length || 0)
      } else {
        console.error('API Error:', result.error)
      }
    } catch (error) {
      console.error('Error fetching accounts:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleCreate = async () => {
    try {
      const params = new URLSearchParams({
        category: 'finance',
        action: 'chart_of_accounts'
      })
      
      const response = await fetch(`/api/tiles?${params}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      })
      
      const result = await response.json()
      if (result.success) {
        setShowCreateForm(false)
        resetForm()
        fetchAccounts()
      } else {
        alert(result.error || 'Failed to create account')
      }
    } catch (error) {
      console.error('Error creating account:', error)
      alert('Failed to create account')
    }
  }

  const handleEdit = (account: ChartAccount) => {
    setEditingAccount(account)
    setFormData({
      coa_code: account.coa_code,
      coa_name: account.coa_name,
      account_code: account.account_code,
      account_name: account.account_name,
      account_type: account.account_type,
      cost_relevant: account.cost_relevant,
      balance_sheet_account: account.balance_sheet_account,
      cost_category: account.cost_category || ''
    })
    setShowEditForm(true)
  }

  const handleUpdate = async () => {
    if (!editingAccount) return
    
    try {
      const params = new URLSearchParams({
        category: 'finance',
        action: 'chart_of_accounts',
        id: editingAccount.id
      })
      
      const response = await fetch(`/api/tiles?${params}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      })
      
      const result = await response.json()
      if (result.success) {
        setShowEditForm(false)
        setEditingAccount(null)
        resetForm()
        fetchAccounts()
      } else {
        alert(result.error || 'Failed to update account')
      }
    } catch (error) {
      console.error('Error updating account:', error)
      alert('Failed to update account')
    }
  }

  const handleDelete = async (account: ChartAccount) => {
    if (!confirm(`Are you sure you want to delete account ${account.coa_code}?`)) return
    
    try {
      const params = new URLSearchParams({
        category: 'finance',
        action: 'chart_of_accounts',
        id: account.id
      })
      
      const response = await fetch(`/api/tiles?${params}`, {
        method: 'DELETE'
      })
      
      const result = await response.json()
      if (result.success) {
        fetchAccounts()
      } else {
        alert(result.error || 'Failed to delete account')
      }
    } catch (error) {
      console.error('Error deleting account:', error)
      alert('Failed to delete account')
    }
  }

  const resetForm = () => {
    setFormData({
      coa_code: '',
      coa_name: '',
      account_code: '',
      account_name: '',
      account_type: 'ASSET',
      cost_relevant: false,
      balance_sheet_account: false,
      cost_category: ''
    })
  }

  const downloadTemplate = () => {
    const csvContent = "account_code,account_name,account_type,parent_account\n" +
      "110000,Cash and Bank,ASSET,\n" +
      "120000,Accounts Receivable,ASSET,\n" +
      "140000,Inventory,ASSET,\n" +
      "200000,Accounts Payable,LIABILITY,\n" +
      "300000,Share Capital,EQUITY,\n" +
      "400000,Revenue,REVENUE,\n" +
      "500000,Cost of Sales,EXPENSE,\n" +
      "600000,Operating Expenses,EXPENSE,"

    const blob = new Blob([csvContent], { type: 'text/csv' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = 'chart_of_accounts_template.csv'
    a.click()
    window.URL.revokeObjectURL(url)
  }

  const handleFileUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    const formData = new FormData()
    formData.append('file', file)
    formData.append('company_code', selectedCompany)

    setLoading(true)
    try {
      const response = await fetch('/api/tiles', {
        method: 'POST',
        body: formData
      })
      const result = await response.json()
      if (result.success) {
        alert(`Successfully uploaded ${result.data.count} accounts`)
        fetchAccounts()
        setShowUpload(false)
      } else {
        alert(`Upload failed: ${result.error}`)
      }
    } catch (error) {
      console.error('Upload error:', error)
      alert('Upload failed')
    } finally {
      setLoading(false)
    }
  }

  const copyFromCompany = async () => {
    if (!sourceCompany) {
      alert('Please select a source company')
      return
    }

    console.log('Copy request:', { sourceCompany, targetCompany: selectedCompany }) // Debug

    setLoading(true)
    try {
      const response = await fetch('/api/tiles', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          category: 'finance',
          action: 'copy_chart',
          source_company: sourceCompany,
          target_company: selectedCompany
        })
      })
      
      const result = await response.json()
      console.log('Copy response:', result) // Debug
      
      if (result.success) {
        alert(`Successfully copied ${result.data.count} accounts`)
        fetchAccounts()
        setShowCopy(false)
      } else {
        alert(`Copy failed: ${result.error}`)
      }
    } catch (error) {
      console.error('Copy error:', error)
      alert('Copy failed')
    } finally {
      setLoading(false)
    }
  }

  const accountTypes = [
    { value: 'ALL', label: 'All Types', icon: Icons.List, color: 'bg-gray-100' },
    { value: 'ASSET', label: 'Assets', icon: Icons.Building, color: 'bg-blue-100' },
    { value: 'LIABILITY', label: 'Liabilities', icon: Icons.CreditCard, color: 'bg-red-100' },
    { value: 'EQUITY', label: 'Equity', icon: Icons.PieChart, color: 'bg-green-100' },
    { value: 'REVENUE', label: 'Revenue', icon: Icons.TrendingUp, color: 'bg-emerald-100' },
    { value: 'EXPENSE', label: 'Expenses', icon: Icons.TrendingDown, color: 'bg-orange-100' }
  ]

  const getAccountTypeIcon = (type: string) => {
    const typeConfig = accountTypes.find(t => t.value === type)
    return typeConfig ? typeConfig.icon : Icons.Circle
  }

  const getAccountTypeColor = (type: string) => {
    const typeConfig = accountTypes.find(t => t.value === type)
    return typeConfig ? typeConfig.color : 'bg-gray-100'
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading Chart of Accounts...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white shadow-sm border-b px-4 py-4">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-600">Company: {companies.find(c => c.code === selectedCompany)?.name}</p>
          </div>
          <div className="flex items-center space-x-2">
            <button
              onClick={downloadTemplate}
              className="bg-gray-600 text-white px-3 py-2 rounded-lg hover:bg-gray-700 flex items-center text-sm"
            >
              <Icons.Download className="w-4 h-4 mr-2" />
              {isMobile ? 'Template' : 'Download Template'}
            </button>
            <button
              onClick={() => setShowUpload(true)}
              className="bg-green-600 text-white px-3 py-2 rounded-lg hover:bg-green-700 flex items-center text-sm"
            >
              <Icons.Upload className="w-4 h-4 mr-2" />
              {isMobile ? 'Upload' : 'Upload CSV'}
            </button>
            <button
              onClick={() => setShowCopy(true)}
              className="bg-purple-600 text-white px-3 py-2 rounded-lg hover:bg-purple-700 flex items-center text-sm"
            >
              <Icons.Copy className="w-4 h-4 mr-2" />
              {isMobile ? 'Copy' : 'Copy from Company'}
            </button>
            <button
              onClick={() => setShowCreateForm(true)}
              className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center text-sm"
            >
              <Icons.Plus className="w-4 h-4 mr-2" />
              {isMobile ? 'Add' : 'Create Account'}
            </button>
          </div>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white border-b px-4 py-3">
        <div className="flex flex-col space-y-3 md:flex-row md:space-y-0 md:space-x-4 md:items-center">
          {/* Company Selection */}
          <div className="md:w-64">
            <label className="block text-sm font-medium text-gray-700 mb-1">Company</label>
            <select
              value={selectedCompany}
              onChange={(e) => setSelectedCompany(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            >
              {companies.map((company) => (
                <option key={company.code} value={company.code}>
                  {company.code} - {company.name}
                </option>
              ))}
            </select>
          </div>

          {/* Search */}
          <div className="flex-1 relative">
            <label className="block text-sm font-medium text-gray-700 mb-1">Search</label>
            <Icons.Search className="absolute left-3 top-9 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input
              type="text"
              placeholder="Search accounts..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>

          {/* View Mode Toggle */}
          <div className="flex bg-gray-100 rounded-lg p-1">
            <button
              onClick={() => setViewMode('grouped')}
              className={`px-3 py-1 rounded text-sm font-medium transition-colors ${
                viewMode === 'grouped' 
                  ? 'bg-white text-gray-900 shadow-sm' 
                  : 'text-gray-600 hover:text-gray-900'
              }`}
            >
              <Icons.Layers className="w-4 h-4 mr-1 inline" />
              Grouped
            </button>
            <button
              onClick={() => setViewMode('list')}
              className={`px-3 py-1 rounded text-sm font-medium transition-colors ${
                viewMode === 'list' 
                  ? 'bg-white text-gray-900 shadow-sm' 
                  : 'text-gray-600 hover:text-gray-900'
              }`}
            >
              <Icons.List className="w-4 h-4 mr-1 inline" />
              List
            </button>
          </div>
        </div>

        {/* Account Type Filters */}
        <div className="mt-3 flex flex-wrap gap-2">
          {accountTypes.map((type) => {
            const IconComponent = type.icon
            return (
              <button
                key={type.value}
                onClick={() => setSelectedType(type.value)}
                className={`flex items-center px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                  selectedType === type.value
                    ? 'bg-blue-600 text-white'
                    : `${type.color} text-gray-700 hover:bg-opacity-80`
                }`}
              >
                <IconComponent className="w-4 h-4 mr-2" />
                {type.label}
              </button>
            )
          })}
        </div>
      </div>

      {/* Content */}
      <div className="p-4">
        {viewMode === 'grouped' ? (
          // Grouped View
          <div className="space-y-6">
            {Object.entries(groupedAccounts || {}).map(([type, typeAccounts]) => {
              const IconComponent = getAccountTypeIcon(type)
              const colorClass = getAccountTypeColor(type)
              
              return (
                <div key={type} className="bg-white rounded-lg shadow-sm border">
                  <div className={`${colorClass} px-4 py-3 border-b flex items-center`}>
                    <IconComponent className="w-5 h-5 mr-3 text-gray-700" />
                    <h3 className="font-semibold text-gray-900">{type}</h3>
                    <span className="ml-auto bg-white px-2 py-1 rounded text-sm font-medium text-gray-600">
                      {typeAccounts.length}
                    </span>
                  </div>
                  <div className="divide-y divide-gray-200">
                    {typeAccounts.map((account) => (
                      <AccountCard 
                        key={account.id} 
                        account={account} 
                        isMobile={isMobile}
                        onEdit={handleEdit}
                        onDelete={handleDelete}
                      />
                    ))}
                  </div>
                </div>
              )
            })}
          </div>
        ) : (
          // List View
          <div className="bg-white rounded-lg shadow-sm border">
            <div className="divide-y divide-gray-200">
              {accounts.map((account) => (
                <AccountCard 
                  key={account.id} 
                  account={account} 
                  isMobile={isMobile}
                  onEdit={handleEdit}
                  onDelete={handleDelete}
                />
              ))}
            </div>
          </div>
        )}

        {accounts.length === 0 && !loading && (
          <div className="text-center py-12">
            <Icons.Search className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">No accounts found</h3>
            <p className="text-gray-600">Try adjusting your search or filters</p>
          </div>
        )}
      </div>

      {/* Create/Edit Form Modal */}
      {(showCreateForm || showEditForm) && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-md w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-semibold text-gray-900">
                  {showCreateForm ? 'Create Account' : 'Edit Account'}
                </h3>
                <button
                  onClick={() => {
                    setShowCreateForm(false)
                    setShowEditForm(false)
                    setEditingAccount(null)
                    resetForm()
                  }}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <Icons.X className="w-5 h-5" />
                </button>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    COA Code *
                  </label>
                  <input
                    type="text"
                    value={formData.coa_code}
                    onChange={(e) => setFormData({ ...formData, coa_code: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="e.g., 100001"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    COA Name *
                  </label>
                  <input
                    type="text"
                    value={formData.coa_name}
                    onChange={(e) => setFormData({ ...formData, coa_name: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="e.g., Cash and Cash Equivalents"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Account Code *
                  </label>
                  <input
                    type="text"
                    value={formData.account_code}
                    onChange={(e) => setFormData({ ...formData, account_code: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="e.g., 1000"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Account Name *
                  </label>
                  <input
                    type="text"
                    value={formData.account_name}
                    onChange={(e) => setFormData({ ...formData, account_name: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="e.g., Cash"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Account Type *
                  </label>
                  <select
                    value={formData.account_type}
                    onChange={(e) => setFormData({ ...formData, account_type: e.target.value as ChartAccount['account_type'] })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  >
                    <option value="ASSET">Asset</option>
                    <option value="LIABILITY">Liability</option>
                    <option value="EQUITY">Equity</option>
                    <option value="REVENUE">Revenue</option>
                    <option value="EXPENSE">Expense</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Cost Category
                  </label>
                  <input
                    type="text"
                    value={formData.cost_category}
                    onChange={(e) => setFormData({ ...formData, cost_category: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="e.g., Direct Materials"
                  />
                </div>

                <div className="flex items-center space-x-4">
                  <label className="flex items-center">
                    <input
                      type="checkbox"
                      checked={formData.cost_relevant}
                      onChange={(e) => setFormData({ ...formData, cost_relevant: e.target.checked })}
                      className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                    />
                    <span className="ml-2 text-sm text-gray-700">Cost Relevant</span>
                  </label>

                  <label className="flex items-center">
                    <input
                      type="checkbox"
                      checked={formData.balance_sheet_account}
                      onChange={(e) => setFormData({ ...formData, balance_sheet_account: e.target.checked })}
                      className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                    />
                    <span className="ml-2 text-sm text-gray-700">Balance Sheet</span>
                  </label>
                </div>
              </div>

              <div className="flex justify-end space-x-3 mt-6 pt-4 border-t">
                <button
                  onClick={() => {
                    setShowCreateForm(false)
                    setShowEditForm(false)
                    setEditingAccount(null)
                    resetForm()
                  }}
                  className="px-4 py-2 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={showCreateForm ? handleCreate : handleUpdate}
                  className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                >
                  {showCreateForm ? 'Create' : 'Update'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Upload Modal */}
      {showUpload && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-md w-full">
            <div className="p-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-semibold text-gray-900">Upload Chart of Accounts</h3>
                <button
                  onClick={() => setShowUpload(false)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <Icons.X className="w-5 h-5" />
                </button>
              </div>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Select CSV File
                  </label>
                  <input
                    type="file"
                    accept=".csv"
                    onChange={handleFileUpload}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md"
                  />
                </div>
                <div className="text-sm text-gray-600">
                  <p>CSV format: account_code, account_name, account_type, parent_account</p>
                  <p>Download template for reference.</p>
                </div>
              </div>
              <div className="flex gap-2 mt-6">
                <button
                  onClick={() => setShowUpload(false)}
                  className="flex-1 px-4 py-2 border border-gray-300 rounded-md hover:bg-gray-50"
                >
                  Cancel
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Copy Modal */}
      {showCopy && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg shadow-xl max-w-md w-full">
            <div className="p-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-semibold text-gray-900">Copy Chart of Accounts</h3>
                <button
                  onClick={() => setShowCopy(false)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <Icons.X className="w-5 h-5" />
                </button>
              </div>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Source Company
                  </label>
                  <select
                    value={sourceCompany}
                    onChange={(e) => setSourceCompany(e.target.value)}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md"
                  >
                    <option value="">Select source company</option>
                    {companies.filter(c => c.code !== selectedCompany).map(company => (
                      <option key={company.code} value={company.code}>
                        {company.name}
                      </option>
                    ))}
                  </select>
                </div>
                <div className="text-sm text-gray-600">
                  <p>This will copy all accounts from the source company to <strong>{selectedCompany}</strong>.</p>
                  <p className="text-red-600 mt-2">Warning: This will replace existing accounts!</p>
                </div>
              </div>
              <div className="flex gap-2 mt-6">
                <button
                  onClick={() => setShowCopy(false)}
                  className="flex-1 px-4 py-2 border border-gray-300 rounded-md hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  onClick={copyFromCompany}
                  disabled={!sourceCompany || loading}
                  className="flex-1 px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 disabled:opacity-50"
                >
                  {loading ? 'Copying...' : 'Copy'}
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

// Account Card Component
function AccountCard({ account, isMobile, onEdit, onDelete }: { 
  account: ChartAccount; 
  isMobile: boolean;
  onEdit: (account: ChartAccount) => void;
  onDelete: (account: ChartAccount) => void;
}) {
  return (
    <div className="p-4 hover:bg-gray-50 transition-colors">
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <div className="flex items-center space-x-3">
            <div className="font-mono text-sm font-semibold text-blue-600 bg-blue-50 px-2 py-1 rounded">
              {account.coa_code}
            </div>
            <div className="font-medium text-gray-900">{account.coa_name}</div>
            {account.cost_relevant && (
              <span className="bg-green-100 text-green-800 text-xs px-2 py-1 rounded-full font-medium">
                Cost Element
              </span>
            )}
          </div>
          
          <div className="mt-2 text-sm text-gray-600">
            <div className="font-mono">{account.account_code} - {account.account_name}</div>
            {account.cost_category && (
              <div className="mt-1 text-xs text-gray-500">Category: {account.cost_category}</div>
            )}
          </div>
        </div>

        <div className="flex items-center space-x-2 ml-4">
          <button 
            onClick={() => onEdit(account)}
            className="p-2 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded transition-colors"
            title="Edit Account"
          >
            <Icons.Edit className="w-4 h-4" />
          </button>
          <button 
            onClick={() => onDelete(account)}
            className="p-2 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded transition-colors"
            title="Delete Account"
          >
            <Icons.Trash2 className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  )
}