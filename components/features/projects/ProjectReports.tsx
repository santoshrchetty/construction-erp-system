'use client'

import React, { useState, useEffect } from 'react'
import { FileText, Download, Calendar, Building, RefreshCw } from 'lucide-react'

interface ProjectReport {
  project_code: string
  wbs_element: string
  gl_account: string
  account_name: string
  account_type: string
  debit_amount: number
  credit_amount: number
  net_amount: number
  cost_center: string
  employee_id: string
  material_number: string
}

export function ProjectReports() {
  const [reports, setReports] = useState<ProjectReport[]>([])
  const [loading, setLoading] = useState(false)
  const [projectCode, setProjectCode] = useState('P100')
  const [fromDate, setFromDate] = useState('')
  const [toDate, setToDate] = useState(new Date().toISOString().split('T')[0])

  const loadProjectReports = async () => {
    setLoading(true)
    try {
      const response = await fetch('/api/projects?action=reports', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          projectCode: projectCode || null,
          fromDate: fromDate || null,
          toDate,
          companyCode: 'C001'
        })
      })
      
      const result = await response.json()
      
      if (result.success) {
        setReports(result.data)
      }
    } catch (error) {
      console.error('Failed to load project reports:', error)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadProjectReports()
  }, [])

  // Group by project for summary
  const projectSummary = reports.reduce((acc, report) => {
    const project = report.project_code
    if (!acc[project]) {
      acc[project] = {
        project_code: project,
        total_debits: 0,
        total_credits: 0,
        net_amount: 0,
        wbs_count: new Set()
      }
    }
    acc[project].total_debits += report.debit_amount
    acc[project].total_credits += report.credit_amount
    acc[project].net_amount += report.net_amount
    if (report.wbs_element) acc[project].wbs_count.add(report.wbs_element)
    return acc
  }, {} as any)

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm border-b px-4 py-3">
        <div className="flex justify-between items-center">
          <h2 className="text-lg font-semibold text-gray-900">Project Reports (CJI3-Equivalent)</h2>
          <button
            onClick={loadProjectReports}
            disabled={loading}
            className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center"
          >
            <RefreshCw className={`w-4 h-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
            Generate Report
          </button>
        </div>
      </div>

      <div className="p-4">
        {/* Filters */}
        <div className="bg-white rounded-lg shadow-sm border p-4 mb-6">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
              <label className="block text-sm font-medium mb-2">Project Code</label>
              <input
                type="text"
                value={projectCode}
                onChange={(e) => setProjectCode(e.target.value)}
                placeholder="Leave empty for all projects"
                className="w-full border rounded-lg px-3 py-2"
              />
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">From Date</label>
              <input
                type="date"
                value={fromDate}
                onChange={(e) => setFromDate(e.target.value)}
                className="w-full border rounded-lg px-3 py-2"
              />
            </div>
            <div>
              <label className="block text-sm font-medium mb-2">To Date</label>
              <input
                type="date"
                value={toDate}
                onChange={(e) => setToDate(e.target.value)}
                className="w-full border rounded-lg px-3 py-2"
              />
            </div>
            <div className="flex items-end">
              <button
                onClick={loadProjectReports}
                disabled={loading}
                className="w-full bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 flex items-center justify-center"
              >
                <FileText className="w-4 h-4 mr-2" />
                Generate
              </button>
            </div>
          </div>
        </div>

        {/* Project Summary */}
        <div className="bg-white rounded-lg shadow-sm border mb-6 overflow-hidden">
          <div className="px-4 py-3 border-b">
            <h3 className="text-lg font-medium">Project Summary</h3>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Project</th>
                  <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Total Costs</th>
                  <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Total Revenue</th>
                  <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Net Profit</th>
                  <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">WBS Elements</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {Object.values(projectSummary).map((project: any) => (
                  <tr key={project.project_code} className="hover:bg-gray-50">
                    <td className="px-4 py-3 font-medium">{project.project_code}</td>
                    <td className="px-4 py-3 text-right">${project.total_debits.toLocaleString()}</td>
                    <td className="px-4 py-3 text-right">${project.total_credits.toLocaleString()}</td>
                    <td className={`px-4 py-3 text-right font-medium ${
                      project.net_amount >= 0 ? 'text-green-600' : 'text-red-600'
                    }`}>
                      ${project.net_amount.toLocaleString()}
                    </td>
                    <td className="px-4 py-3 text-right">{project.wbs_count.size}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Detailed Report */}
        <div className="bg-white rounded-lg shadow-sm border overflow-hidden">
          <div className="px-4 py-3 border-b">
            <h3 className="text-lg font-medium">Detailed Project Report</h3>
            <p className="text-sm text-gray-600">Line-by-line transactions from Universal Journal</p>
          </div>

          {loading ? (
            <div className="p-8 text-center">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
              <p className="mt-2 text-gray-500">Generating report...</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Project</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">WBS</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">GL Account</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Description</th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Type</th>
                    <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Debit</th>
                    <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Credit</th>
                    <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Net</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {reports.map((report, index) => (
                    <tr key={index} className="hover:bg-gray-50">
                      <td className="px-4 py-3 font-medium">{report.project_code}</td>
                      <td className="px-4 py-3">{report.wbs_element || '-'}</td>
                      <td className="px-4 py-3 font-mono">{report.gl_account}</td>
                      <td className="px-4 py-3">{report.account_name}</td>
                      <td className="px-4 py-3">
                        <span className={`px-2 py-1 text-xs rounded-full ${
                          report.account_type === 'ASSET' ? 'bg-blue-100 text-blue-800' :
                          report.account_type === 'LIABILITY' ? 'bg-red-100 text-red-800' :
                          report.account_type === 'EXPENSE' ? 'bg-orange-100 text-orange-800' :
                          'bg-green-100 text-green-800'
                        }`}>
                          {report.account_type}
                        </span>
                      </td>
                      <td className="px-4 py-3 text-right">
                        {report.debit_amount > 0 ? `$${report.debit_amount.toLocaleString()}` : '-'}
                      </td>
                      <td className="px-4 py-3 text-right">
                        {report.credit_amount > 0 ? `$${report.credit_amount.toLocaleString()}` : '-'}
                      </td>
                      <td className={`px-4 py-3 text-right font-medium ${
                        report.net_amount >= 0 ? 'text-green-600' : 'text-red-600'
                      }`}>
                        ${report.net_amount.toLocaleString()}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}