'use client'

import React, { useState, useEffect } from 'react'
import { Calendar, Download, RefreshCw, DollarSign, TrendingUp, FileText } from 'lucide-react'

interface TrialBalanceItem {
  account_number: string
  account_name: string
  account_type: string
  debit_balance: number
  credit_balance: number
  net_balance: number
}

interface PLItem {
  section: string
  account_number: string
  account_name: string
  amount: number
}

export function TrialBalance() {
  const [data, setData] = useState<TrialBalanceItem[]>([])
  const [loading, setLoading] = useState(false)
  const [companyCode, setCompanyCode] = useState('C001')
  const [fromDate, setFromDate] = useState('')
  const [toDate, setToDate] = useState(new Date().toISOString().split('T')[0])

  const loadTrialBalance = async () => {
    setLoading(true)
    try {
      const response = await fetch('/api/finance?action=trial_balance', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          ledger: 'ACCRUAL',
          postingDate: toDate
        })
      })
      const result = await response.json()
      
      if (result.success) {
        // Transform data to match component format
        const transformedData = result.data.map(item => ({
          account_number: item.gl_account,
          account_name: item.account_name || 'Unknown Account',
          account_type: item.account_type || 'UNKNOWN',
          debit_balance: item.debit_balance || 0,
          credit_balance: item.credit_balance || 0,
          net_balance: item.net_balance || 0
        }))
        setData(transformedData)
      }
    } catch (error) {
      console.error('Failed to load trial balance:', error)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadTrialBalance()
  }, [])

  const totalDebits = data.reduce((sum, item) => sum + item.debit_balance, 0)
  const totalCredits = data.reduce((sum, item) => sum + item.credit_balance, 0)

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm border-b px-4 py-3">
      </div>

      <div className="p-4">
        {/* Filters */}
        <div className="bg-white rounded-lg shadow-sm border p-4 mb-4">
          <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Company</label>
              <select 
                value={companyCode} 
                onChange={(e) => setCompanyCode(e.target.value)}
                className="w-full px-3 py-2 border rounded-md focus:ring-2 focus:ring-blue-500"
              >
                <option value="C001">C001 - Main Company</option>
                <option value="C002">C002 - Subsidiary</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">From Date</label>
              <input
                type="date"
                value={fromDate}
                onChange={(e) => setFromDate(e.target.value)}
                className="w-full px-3 py-2 border rounded-md focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">To Date</label>
              <input
                type="date"
                value={toDate}
                onChange={(e) => setToDate(e.target.value)}
                className="w-full px-3 py-2 border rounded-md focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div className="flex items-end">
              <button
                onClick={loadTrialBalance}
                disabled={loading}
                className="w-full bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 disabled:opacity-50 flex items-center justify-center"
              >
                {loading ? <RefreshCw className="w-4 h-4 animate-spin" /> : <RefreshCw className="w-4 h-4 mr-2" />}
                Refresh
              </button>
            </div>
          </div>
        </div>

        {/* Summary Cards */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-4">
          <div className="bg-white p-4 rounded-lg shadow-sm border">
            <div className="flex items-center">
              <DollarSign className="w-8 h-8 text-green-600 mr-3" />
              <div>
                <p className="text-sm text-gray-600">Total Debits</p>
                <p className="text-xl font-bold text-green-900">${totalDebits.toLocaleString()}</p>
              </div>
            </div>
          </div>
          <div className="bg-white p-4 rounded-lg shadow-sm border">
            <div className="flex items-center">
              <DollarSign className="w-8 h-8 text-red-600 mr-3" />
              <div>
                <p className="text-sm text-gray-600">Total Credits</p>
                <p className="text-xl font-bold text-red-900">${totalCredits.toLocaleString()}</p>
              </div>
            </div>
          </div>
          <div className="bg-white p-4 rounded-lg shadow-sm border">
            <div className="flex items-center">
              <TrendingUp className="w-8 h-8 text-blue-600 mr-3" />
              <div>
                <p className="text-sm text-gray-600">Difference</p>
                <p className={`text-xl font-bold ${Math.abs(totalDebits - totalCredits) < 0.01 ? 'text-green-900' : 'text-red-900'}`}>
                  ${Math.abs(totalDebits - totalCredits).toLocaleString()}
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Trial Balance Table */}
        <div className="bg-white rounded-lg shadow-sm border overflow-hidden">
          {/* Desktop View */}
          <div className="hidden md:block overflow-x-auto">
            <table className="min-w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Account</th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
                  <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Debit</th>
                  <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Credit</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {data.map((item) => (
                  <tr key={item.account_number} className="hover:bg-gray-50">
                    <td className="px-4 py-3 font-mono text-sm">{item.account_number}</td>
                    <td className="px-4 py-3 text-sm">{item.account_name}</td>
                    <td className="px-4 py-3 text-sm">
                      <span className={`px-2 py-1 text-xs rounded-full ${
                        item.account_type === 'ASSET' ? 'bg-blue-100 text-blue-800' :
                        item.account_type === 'LIABILITY' ? 'bg-red-100 text-red-800' :
                        item.account_type === 'EXPENSE' ? 'bg-orange-100 text-orange-800' :
                        'bg-green-100 text-green-800'
                      }`}>
                        {item.account_type}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-sm text-right font-medium">
                      {item.debit_balance > 0 ? `$${item.debit_balance.toLocaleString()}` : '-'}
                    </td>
                    <td className="px-4 py-3 text-sm text-right font-medium">
                      {item.credit_balance > 0 ? `$${item.credit_balance.toLocaleString()}` : '-'}
                    </td>
                  </tr>
                ))}
                <tr className="bg-gray-100 font-bold">
                  <td colSpan={3} className="px-4 py-3 text-sm">TOTALS</td>
                  <td className="px-4 py-3 text-sm text-right">${totalDebits.toLocaleString()}</td>
                  <td className="px-4 py-3 text-sm text-right">${totalCredits.toLocaleString()}</td>
                </tr>
              </tbody>
            </table>
          </div>

          {/* Mobile Cards */}
          <div className="md:hidden">
            {data.map((item) => (
              <div key={item.account_number} className="p-4 border-b">
                <div className="flex justify-between items-start mb-2">
                  <div>
                    <p className="font-mono text-sm font-medium">{item.account_number}</p>
                    <p className="text-sm text-gray-900">{item.account_name}</p>
                  </div>
                  <span className={`px-2 py-1 text-xs rounded-full ${
                    item.account_type === 'ASSET' ? 'bg-blue-100 text-blue-800' :
                    item.account_type === 'LIABILITY' ? 'bg-red-100 text-red-800' :
                    item.account_type === 'EXPENSE' ? 'bg-orange-100 text-orange-800' :
                    'bg-green-100 text-green-800'
                  }`}>
                    {item.account_type}
                  </span>
                </div>
                <div className="flex justify-between text-sm">
                  <span>Debit: <strong>{item.debit_balance > 0 ? `$${item.debit_balance.toLocaleString()}` : '-'}</strong></span>
                  <span>Credit: <strong>{item.credit_balance > 0 ? `$${item.credit_balance.toLocaleString()}` : '-'}</strong></span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}

export function ProfitLossStatement() {
  const [data, setData] = useState<PLItem[]>([])
  const [loading, setLoading] = useState(false)
  const [companyCode, setCompanyCode] = useState('C001')
  const [fromDate, setFromDate] = useState(new Date(new Date().getFullYear(), 0, 1).toISOString().split('T')[0])
  const [toDate, setToDate] = useState(new Date().toISOString().split('T')[0])

  const loadProfitLoss = async () => {
    setLoading(true)
    try {
      const params = new URLSearchParams({
        type: 'profit_loss',
        company_code: companyCode,
        from_date: fromDate,
        to_date: toDate
      })

      const response = await fetch(`/api/finance/reports?${params}`)
      const result = await response.json()
      
      if (result.success) {
        setData(result.data)
      }
    } catch (error) {
      console.error('Failed to load P&L:', error)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadProfitLoss()
  }, [])

  const revenue = data.filter(item => item.section === 'REVENUE')
  const expenses = data.filter(item => item.section === 'EXPENSE')
  const totalRevenue = revenue.reduce((sum, item) => sum + item.amount, 0)
  const totalExpenses = expenses.reduce((sum, item) => sum + item.amount, 0)
  const netIncome = totalRevenue - totalExpenses

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm border-b px-4 py-3">
      </div>

      <div className="p-4">
        {/* Filters */}
        <div className="bg-white rounded-lg shadow-sm border p-4 mb-4">
          <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Company</label>
              <select 
                value={companyCode} 
                onChange={(e) => setCompanyCode(e.target.value)}
                className="w-full px-3 py-2 border rounded-md focus:ring-2 focus:ring-blue-500"
              >
                <option value="C001">C001 - Main Company</option>
                <option value="C002">C002 - Subsidiary</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">From Date</label>
              <input
                type="date"
                value={fromDate}
                onChange={(e) => setFromDate(e.target.value)}
                className="w-full px-3 py-2 border rounded-md focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">To Date</label>
              <input
                type="date"
                value={toDate}
                onChange={(e) => setToDate(e.target.value)}
                className="w-full px-3 py-2 border rounded-md focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div className="flex items-end">
              <button
                onClick={loadProfitLoss}
                disabled={loading}
                className="w-full bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 disabled:opacity-50 flex items-center justify-center"
              >
                {loading ? <RefreshCw className="w-4 h-4 animate-spin" /> : <RefreshCw className="w-4 h-4 mr-2" />}
                Generate
              </button>
            </div>
          </div>
        </div>

        {/* P&L Statement */}
        <div className="bg-white rounded-lg shadow-sm border">
          <div className="px-4 py-3 border-b">
            <h3 className="text-lg font-medium">Profit & Loss Statement</h3>
            <p className="text-sm text-gray-600">Period: {fromDate} to {toDate}</p>
          </div>

          <div className="p-4">
            {/* Revenue Section */}
            <div className="mb-6">
              <h4 className="text-md font-semibold text-green-800 mb-3 flex items-center">
                <TrendingUp className="w-5 h-5 mr-2" />
                REVENUE
              </h4>
              {revenue.map((item) => (
                <div key={item.account_number} className="flex justify-between py-2 border-b border-gray-100">
                  <span className="text-sm">{item.account_number} - {item.account_name}</span>
                  <span className="text-sm font-medium">${item.amount.toLocaleString()}</span>
                </div>
              ))}
              <div className="flex justify-between py-2 font-semibold text-green-800 border-t-2 border-green-200">
                <span>Total Revenue</span>
                <span>${totalRevenue.toLocaleString()}</span>
              </div>
            </div>

            {/* Expenses Section */}
            <div className="mb-6">
              <h4 className="text-md font-semibold text-red-800 mb-3 flex items-center">
                <FileText className="w-5 h-5 mr-2" />
                EXPENSES
              </h4>
              {expenses.map((item) => (
                <div key={item.account_number} className="flex justify-between py-2 border-b border-gray-100">
                  <span className="text-sm">{item.account_number} - {item.account_name}</span>
                  <span className="text-sm font-medium">${item.amount.toLocaleString()}</span>
                </div>
              ))}
              <div className="flex justify-between py-2 font-semibold text-red-800 border-t-2 border-red-200">
                <span>Total Expenses</span>
                <span>${totalExpenses.toLocaleString()}</span>
              </div>
            </div>

            {/* Net Income */}
            <div className={`flex justify-between py-3 text-lg font-bold border-t-4 ${
              netIncome >= 0 ? 'border-green-500 text-green-800' : 'border-red-500 text-red-800'
            }`}>
              <span>NET INCOME</span>
              <span>${netIncome.toLocaleString()}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}