import { useState, useEffect } from 'react'
import * as Icons from 'lucide-react'

// Trial Balance Component
export function TrialBalance() {
  const [trialBalance, setTrialBalance] = useState([])
  const [loading, setLoading] = useState(true)
  const [asOfDate, setAsOfDate] = useState(new Date().toISOString().split('T')[0])
  const [showZeroBalances, setShowZeroBalances] = useState(false)

  useEffect(() => {
    loadTrialBalance()
  }, [asOfDate, showZeroBalances])

  const loadTrialBalance = async () => {
    setLoading(true)
    try {
      const mockData = [
        { account_code: '110000', account_name: 'Cash and Bank', debit: 125000, credit: 0, account_type: 'ASSET' },
        { account_code: '140000', account_name: 'Raw Materials Inventory', debit: 85000, credit: 0, account_type: 'ASSET' },
        { account_code: '200000', account_name: 'Accounts Payable', debit: 0, credit: 45000, account_type: 'LIABILITY' },
        { account_code: '400100', account_name: 'Raw Materials Consumed', debit: 45000, credit: 0, account_type: 'EXPENSE' },
        { account_code: '600100', account_name: 'Direct Labor', debit: 95000, credit: 0, account_type: 'EXPENSE' },
        { account_code: '800100', account_name: 'Construction Revenue', debit: 0, credit: 350000, account_type: 'REVENUE' }
      ]
      
      const filtered = showZeroBalances ? mockData : mockData.filter(item => item.debit > 0 || item.credit > 0)
      setTrialBalance(filtered)
    } catch (error) {
      console.error('Error loading trial balance:', error)
    } finally {
      setLoading(false)
    }
  }

  const totalDebits = trialBalance.reduce((sum, item) => sum + item.debit, 0)
  const totalCredits = trialBalance.reduce((sum, item) => sum + item.credit, 0)
  const isBalanced = totalDebits === totalCredits

  const getTypeColor = (type) => {
    switch (type) {
      case 'ASSET': return 'text-blue-600'
      case 'LIABILITY': return 'text-red-600'
      case 'EXPENSE': return 'text-orange-600'
      case 'REVENUE': return 'text-green-600'
      default: return 'text-gray-600'
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm border-b px-4 py-3 sticky top-0 z-10">
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between">
          <h2 className="text-lg font-semibold text-gray-900 mb-2 sm:mb-0">Trial Balance</h2>
        </div>
      </div>
      <div className="p-4">
        <div className="bg-white rounded-lg shadow-sm border p-4 mb-6">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="flex-1">
              <label className="block text-sm font-medium mb-2">As of Date</label>
              <input
                type="date"
                className="w-full border rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
                value={asOfDate}
                onChange={(e) => setAsOfDate(e.target.value)}
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

// Financial Statements Component
export function FinancialStatements() {
  const [activeStatement, setActiveStatement] = useState('balance-sheet')
  const [period, setPeriod] = useState('current')

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm border-b px-4 py-3 sticky top-0 z-10">
        <h2 className="text-lg font-semibold text-gray-900">Financial Statements</h2>
      </div>
    </div>
  )
}
