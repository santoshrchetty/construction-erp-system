import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'
import { TrialBalance, ProfitLossStatement } from './FinancialReports'

// Chart of Accounts Component - Enhanced
export function ChartOfAccounts() {
  const [accounts, setAccounts] = useState([])
  const [filteredAccounts, setFilteredAccounts] = useState([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [filterType, setFilterType] = useState('all')
  const [showCreateModal, setShowCreateModal] = useState(false)

  useEffect(() => {
    loadAccounts()
  }, [])

  useEffect(() => {
    filterAccounts()
  }, [accounts, searchTerm, filterType])

  const loadAccounts = async () => {
    try {
      // Mock data - replace with API call to chart_of_accounts
      const mockAccounts = [
        { account_code: '110000', account_name: 'Cash and Bank', account_type: 'ASSET', cost_relevant: false, balance: 125000 },
        { account_code: '140000', account_name: 'Raw Materials Inventory', account_type: 'ASSET', cost_relevant: false, balance: 85000 },
        { account_code: '400100', account_name: 'Raw Materials Consumed', account_type: 'EXPENSE', cost_relevant: true, balance: 45000 },
        { account_code: '450100', account_name: 'Subcontractor - Civil Work', account_type: 'EXPENSE', cost_relevant: true, balance: 125000 },
        { account_code: '600100', account_name: 'Direct Labor - Site Workers', account_type: 'EXPENSE', cost_relevant: true, balance: 95000 },
        { account_code: '650100', account_name: 'Equipment Rental', account_type: 'EXPENSE', cost_relevant: true, balance: 35000 }
      ]
      setAccounts(mockAccounts)
    } catch (error) {
      console.error('Error loading accounts:', error)
    } finally {
      setLoading(false)
    }
  }

  const filterAccounts = () => {
    let filtered = accounts
    
    if (searchTerm) {
      filtered = filtered.filter(account => 
        account.account_code.includes(searchTerm) || 
        account.account_name.toLowerCase().includes(searchTerm.toLowerCase())
      )
    }
    
    if (filterType !== 'all') {
      if (filterType === 'cost_relevant') {
        filtered = filtered.filter(account => account.cost_relevant)
      } else {
        filtered = filtered.filter(account => account.account_type === filterType)
      }
    }
    
    setFilteredAccounts(filtered)
  }

  const getTypeColor = (type) => {
    switch (type) {
      case 'ASSET': return 'bg-blue-100 text-blue-800'
      case 'LIABILITY': return 'bg-red-100 text-red-800'
      case 'EXPENSE': return 'bg-orange-100 text-orange-800'
      case 'REVENUE': return 'bg-green-100 text-green-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Mobile-optimized header */}
      <div className="bg-white shadow-sm border-b px-4 py-3">
        <div className="flex items-center justify-between">
          <button 
            onClick={() => setShowCreateModal(true)}
            className="bg-blue-600 text-white px-3 py-2 rounded-lg hover:bg-blue-700 flex items-center text-sm"
          >
            <Icons.Plus className="w-4 h-4 mr-1" />
            <span className="hidden sm:inline">New Account</span>
          </button>
        </div>
      </div>

      <div className="p-4">
        {/* Search and Filter Controls */}
        <div className="bg-white rounded-lg shadow-sm border p-4 mb-4">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="flex-1">
              <div className="relative">
                <Icons.Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
                <input
                  type="text"
                  placeholder="Search accounts..."
                  className="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                />
              </div>
            </div>
            <div className="sm:w-48">
              <select 
                className="w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
                value={filterType}
                onChange={(e) => setFilterType(e.target.value)}
              >
                <option value="all">All Types</option>
                <option value="ASSET">Assets</option>
                <option value="LIABILITY">Liabilities</option>
                <option value="EXPENSE">Expenses</option>
                <option value="REVENUE">Revenue</option>
                <option value="cost_relevant">Cost Relevant</option>
              </select>
            </div>
          </div>
        </div>

        {/* Summary Cards */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
          <div className="bg-white p-4 rounded-lg shadow-sm border">
            <div className="flex items-center">
              <Icons.Building className="w-8 h-8 text-blue-600 mr-3" />
              <div>
                <p className="text-sm text-gray-600">Total Accounts</p>
                <p className="text-xl font-bold">{accounts.length}</p>
              </div>
            </div>
          </div>
          <div className="bg-white p-4 rounded-lg shadow-sm border">
            <div className="flex items-center">
              <Icons.Target className="w-8 h-8 text-green-600 mr-3" />
              <div>
                <p className="text-sm text-gray-600">Cost Elements</p>
                <p className="text-xl font-bold">{accounts.filter(a => a.cost_relevant).length}</p>
              </div>
            </div>
          </div>
          <div className="bg-white p-4 rounded-lg shadow-sm border">
            <div className="flex items-center">
              <Icons.TrendingUp className="w-8 h-8 text-orange-600 mr-3" />
              <div>
                <p className="text-sm text-gray-600">Assets</p>
                <p className="text-xl font-bold">{accounts.filter(a => a.account_type === 'ASSET').length}</p>
              </div>
            </div>
          </div>
          <div className="bg-white p-4 rounded-lg shadow-sm border">
            <div className="flex items-center">
              <Icons.DollarSign className="w-8 h-8 text-purple-600 mr-3" />
              <div>
                <p className="text-sm text-gray-600">Expenses</p>
                <p className="text-xl font-bold">{accounts.filter(a => a.account_type === 'EXPENSE').length}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Accounts Table */}
        <div className="bg-white rounded-lg shadow-sm border overflow-hidden">
          {/* Desktop Table */}
          <div className="hidden md:block overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Account</th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Balance</th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Cost Element</th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {filteredAccounts.map(account => (
                  <tr key={account.account_code} className="hover:bg-gray-50">
                    <td className="px-4 py-3 font-mono text-sm font-medium">{account.account_code}</td>
                    <td className="px-4 py-3 text-sm">{account.account_name}</td>
                    <td className="px-4 py-3">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getTypeColor(account.account_type)}`}>
                        {account.account_type}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-sm font-medium">${account.balance?.toLocaleString() || '0'}</td>
                    <td className="px-4 py-3 text-sm">
                      {account.cost_relevant ? 
                        <Icons.Check className="w-4 h-4 text-green-600" /> : 
                        <Icons.X className="w-4 h-4 text-gray-400" />
                      }
                    </td>
                    <td className="px-4 py-3 text-sm">
                      <div className="flex space-x-2">
                        <button className="text-blue-600 hover:text-blue-800">
                          <Icons.Edit className="w-4 h-4" />
                        </button>
                        <button className="text-gray-600 hover:text-gray-800">
                          <Icons.Eye className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* Mobile Cards */}
          <div className="md:hidden">
            {filteredAccounts.map(account => (
              <div key={account.account_code} className="p-4 border-b border-gray-200 last:border-b-0">
                <div className="flex justify-between items-start mb-2">
                  <div>
                    <p className="font-mono text-sm font-medium">{account.account_code}</p>
                    <p className="text-sm text-gray-900">{account.account_name}</p>
                  </div>
                  <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getTypeColor(account.account_type)}`}>
                    {account.account_type}
                  </span>
                </div>
                <div className="flex justify-between items-center">
                  <div className="flex items-center space-x-4">
                    <span className="text-sm font-medium">${account.balance?.toLocaleString() || '0'}</span>
                    {account.cost_relevant && (
                      <span className="text-xs bg-green-100 text-green-800 px-2 py-1 rounded">Cost Element</span>
                    )}
                  </div>
                  <div className="flex space-x-2">
                    <button className="text-blue-600 hover:text-blue-800">
                      <Icons.Edit className="w-4 h-4" />
                    </button>
                    <button className="text-gray-600 hover:text-gray-800">
                      <Icons.Eye className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {filteredAccounts.length === 0 && (
          <div className="bg-white rounded-lg shadow-sm border p-8 text-center">
            <Icons.Search className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <p className="text-gray-500">No accounts found matching your criteria</p>
          </div>
        )}
      </div>
    </div>
  )
}

// Project Cost Analysis (CJI3 equivalent)
export function ProjectCostAnalysis() {
  const [projectCosts, setProjectCosts] = useState([])
  const [selectedProject, setSelectedProject] = useState('')

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm border-b px-4 py-3">
        <h2 className="text-lg font-semibold text-gray-900">Project Cost Analysis (CJI3)</h2>
      </div>
      <div className="p-4">
        <div className="mb-4">
          <select className="border rounded-lg px-3 py-2">
            <option value="">Select Project</option>
            <option value="PROJ-001">PROJ-001 - Office Building</option>
          </select>
        </div>
        <div className="bg-white rounded-lg shadow-sm border">
          <div className="p-4">
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
              <div className="bg-blue-50 p-4 rounded-lg">
                <div className="flex items-center">
                  <Icons.DollarSign className="w-8 h-8 text-blue-600 mr-3" />
                  <div>
                    <p className="text-sm text-blue-600">Total Actual Cost</p>
                    <p className="text-2xl font-bold text-blue-900">$125,000</p>
                  </div>
                </div>
              </div>
              <div className="bg-green-50 p-4 rounded-lg">
                <div className="flex items-center">
                  <Icons.Target className="w-8 h-8 text-green-600 mr-3" />
                  <div>
                    <p className="text-sm text-green-600">Budget</p>
                    <p className="text-2xl font-bold text-green-900">$150,000</p>
                  </div>
                </div>
              </div>
              <div className="bg-orange-50 p-4 rounded-lg">
                <div className="flex items-center">
                  <Icons.AlertTriangle className="w-8 h-8 text-orange-600 mr-3" />
                  <div>
                    <p className="text-sm text-orange-600">Commitments</p>
                    <p className="text-2xl font-bold text-orange-900">$35,000</p>
                  </div>
                </div>
              </div>
              <div className="bg-purple-50 p-4 rounded-lg">
                <div className="flex items-center">
                  <Icons.TrendingUp className="w-8 h-8 text-purple-600 mr-3" />
                  <div>
                    <p className="text-sm text-purple-600">Variance</p>
                    <p className="text-2xl font-bold text-purple-900">$25,000</p>
                  </div>
                </div>
              </div>
            </div>
            <div className="text-center text-gray-500 py-8">
              <Icons.BarChart3 className="w-12 h-12 mx-auto mb-2 text-gray-400" />
              <p>Select a project to view cost analysis</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

// Document Reversal Component
export function DocumentReversal() {
  const [documentNumber, setDocumentNumber] = useState('')
  const [reversalReason, setReversalReason] = useState('')
  const [canReverse, setCanReverse] = useState(null)

  const checkReversal = async () => {
    // Mock check - replace with API call
    setCanReverse({
      can_reverse: true,
      document_type: 'GR',
      total_amount: 15000,
      posting_date: '2024-01-15'
    })
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm border-b px-4 py-3">
      </div>
      <div className="p-4">
        <div className="bg-white rounded-lg shadow-sm border p-6">
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-2">Document Number</label>
              <div className="flex gap-2">
                <input
                  type="text"
                  className="flex-1 border rounded-lg px-3 py-2"
                  placeholder="Enter document number"
                  value={documentNumber}
                  onChange={(e) => setDocumentNumber(e.target.value)}
                />
                <button 
                  onClick={checkReversal}
                  className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
                >
                  Check
                </button>
              </div>
            </div>

            {canReverse && (
              <div className="border rounded-lg p-4 bg-green-50">
                <h3 className="font-medium text-green-800 mb-2">Document Details</h3>
                <div className="grid grid-cols-2 gap-4 text-sm">
                  <div>Type: {canReverse.document_type}</div>
                  <div>Amount: ${canReverse.total_amount.toLocaleString()}</div>
                  <div>Date: {canReverse.posting_date}</div>
                  <div>Status: Can be reversed</div>
                </div>
              </div>
            )}

            <div>
              <label className="block text-sm font-medium mb-2">Reversal Reason</label>
              <textarea
                className="w-full border rounded-lg px-3 py-2"
                rows="3"
                placeholder="Enter reason for reversal"
                value={reversalReason}
                onChange={(e) => setReversalReason(e.target.value)}
              />
            </div>

            <div className="flex gap-4">
              <button className="bg-red-600 text-white px-6 py-2 rounded-lg hover:bg-red-700">
                Reverse Document
              </button>
              <button className="bg-gray-500 text-white px-6 py-2 rounded-lg hover:bg-gray-600">
                Clear
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

// GL Posting Component - Industry Grade
export function GLPostingComponent() {
  return (
    <div className="min-h-screen bg-gray-50 p-6">
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-xl font-semibold mb-4">GL Account Posting</h2>
        <p className="text-gray-600">Post journal entries to general ledger accounts</p>
      </div>
    </div>
  )
}

// Trial Balance Component
export function TrialBalanceComponent() {
  return <TrialBalance />
}

// Profit & Loss Component
export function ProfitLossComponent() {
  return <ProfitLossStatement />
}