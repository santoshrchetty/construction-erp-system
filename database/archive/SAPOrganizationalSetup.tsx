'use client'

import React, { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase/client'
import * as Icons from 'lucide-react'

export default function SAPOrganizationalSetup() {
  const [currentStep, setCurrentStep] = useState(1)
  const [setupData, setSetupData] = useState({
    companies: [],
    controllingAreas: [],
    plants: [],
    departments: [],
    assignments: {}
  })
  const [isMobile, setIsMobile] = useState(false)

  useEffect(() => {
    setIsMobile(window.innerWidth < 768)
    const handleResize = () => setIsMobile(window.innerWidth < 768)
    window.addEventListener('resize', handleResize)
    return () => window.removeEventListener('resize', handleResize)
  }, [])

  const steps = [
    { id: 1, title: 'Company Setup', icon: Icons.Building, description: 'Define legal entities' },
    { id: 2, title: 'Controlling Areas', icon: Icons.BarChart3, description: 'Setup cost control' },
    { id: 3, title: 'Plants & Locations', icon: Icons.Factory, description: 'Physical locations' },
    { id: 4, title: 'Departments', icon: Icons.Users, description: 'Organizational units' },
    { id: 5, title: 'Assignments', icon: Icons.Link, description: 'Link everything together' },
    { id: 6, title: 'Review & Activate', icon: Icons.CheckCircle, description: 'Final validation' }
  ]

  const StepIndicator = () => (
    <div className={`${isMobile ? 'px-4 py-3' : 'px-6 py-4'} bg-white border-b`}>
      <div className="flex items-center justify-between">
        <h1 className={`${isMobile ? 'text-lg' : 'text-xl'} font-semibold`}>
          SAP Organizational Setup
        </h1>
        <span className="text-sm text-gray-500">
          Step {currentStep} of {steps.length}
        </span>
      </div>
      
      {/* Progress Bar */}
      <div className="mt-3">
        <div className="flex items-center">
          <div className="flex-1 bg-gray-200 rounded-full h-2">
            <div 
              className="bg-blue-600 h-2 rounded-full transition-all duration-300"
              style={{ width: `${(currentStep / steps.length) * 100}%` }}
            />
          </div>
          <span className="ml-3 text-sm font-medium text-blue-600">
            {Math.round((currentStep / steps.length) * 100)}%
          </span>
        </div>
      </div>

      {/* Step Navigation - Mobile Optimized */}
      {!isMobile && (
        <div className="flex mt-4 space-x-1">
          {steps.map((step) => (
            <button
              key={step.id}
              onClick={() => setCurrentStep(step.id)}
              className={`flex-1 p-2 text-xs rounded transition-colors ${
                currentStep === step.id
                  ? 'bg-blue-100 text-blue-700 border border-blue-300'
                  : currentStep > step.id
                  ? 'bg-green-100 text-green-700'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              <div className="flex items-center justify-center">
                <step.icon className="w-4 h-4 mr-1" />
                <span className="hidden sm:inline">{step.title}</span>
              </div>
            </button>
          ))}
        </div>
      )}
    </div>
  )

  const CompanySetupStep = () => (
    <div className="p-6 space-y-6">
      <div className="text-center mb-6">
        <Icons.Building className="w-16 h-16 mx-auto text-blue-600 mb-4" />
        <h2 className="text-2xl font-bold mb-2">Company Code Setup</h2>
        <p className="text-gray-600">
          Define your legal entities. Each company code represents a separate legal entity in your organization.
        </p>
      </div>

      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
        <div className="flex items-start">
          <Icons.Info className="w-5 h-5 text-blue-600 mr-3 mt-0.5" />
          <div>
            <h4 className="font-medium text-blue-900">SAP Best Practice</h4>
            <p className="text-sm text-blue-800 mt-1">
              Start with your main company, then add subsidiaries. Each company code will have its own financial statements.
            </p>
          </div>
        </div>
      </div>

      <CompanyForm />
      <CompanyList />
    </div>
  )

  const CompanyForm = () => {
    const [formData, setFormData] = useState({
      company_code: '',
      company_name: '',
      legal_entity_name: '',
      currency: 'USD',
      country: '',
      city: ''
    })

    const handleSubmit = async (e) => {
      e.preventDefault()
      try {
        const { error } = await supabase
          .from('company_codes')
          .insert([formData])
        
        if (error) throw error
        
        // Refresh data and reset form
        setFormData({
          company_code: '',
          company_name: '',
          legal_entity_name: '',
          currency: 'USD',
          country: '',
          city: ''
        })
        
        // Show success message
        alert('Company created successfully!')
        
      } catch (error) {
        alert('Error creating company: ' + error.message)
      }
    }

    return (
      <div className="bg-white rounded-lg border p-6">
        <h3 className="font-semibold mb-4 flex items-center">
          <Icons.Plus className="w-5 h-5 mr-2" />
          Add New Company
        </h3>
        
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium mb-1">
                Company Code *
              </label>
              <input
                type="text"
                value={formData.company_code}
                onChange={(e) => setFormData({...formData, company_code: e.target.value.toUpperCase()})}
                className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 font-mono"
                placeholder="e.g., C001"
                maxLength={4}
                required
              />
              <p className="text-xs text-gray-500 mt-1">4-character unique code</p>
            </div>
            
            <div>
              <label className="block text-sm font-medium mb-1">
                Currency
              </label>
              <select
                value={formData.currency}
                onChange={(e) => setFormData({...formData, currency: e.target.value})}
                className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
              >
                <option value="USD">USD - US Dollar</option>
                <option value="EUR">EUR - Euro</option>
                <option value="GBP">GBP - British Pound</option>
                <option value="AED">AED - UAE Dirham</option>
              </select>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium mb-1">
              Company Name *
            </label>
            <input
              type="text"
              value={formData.company_name}
              onChange={(e) => setFormData({...formData, company_name: e.target.value})}
              className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
              placeholder="e.g., ABC Construction Ltd"
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium mb-1">
              Legal Entity Name
            </label>
            <input
              type="text"
              value={formData.legal_entity_name}
              onChange={(e) => setFormData({...formData, legal_entity_name: e.target.value})}
              className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
              placeholder="Full legal name as per registration"
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium mb-1">Country</label>
              <input
                type="text"
                value={formData.country}
                onChange={(e) => setFormData({...formData, country: e.target.value})}
                className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
                placeholder="e.g., United States"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium mb-1">City</label>
              <input
                type="text"
                value={formData.city}
                onChange={(e) => setFormData({...formData, city: e.target.value})}
                className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
                placeholder="e.g., New York"
              />
            </div>
          </div>

          <button
            type="submit"
            className="w-full bg-blue-600 text-white py-3 rounded-lg hover:bg-blue-700 font-medium"
          >
            Create Company Code
          </button>
        </form>
      </div>
    )
  }

  const CompanyList = () => (
    <div className="bg-white rounded-lg border">
      <div className="p-4 border-b">
        <h3 className="font-semibold">Existing Companies</h3>
      </div>
      <div className="divide-y">
        {setupData.companies.map((company) => (
          <div key={company.company_code} className="p-4 hover:bg-gray-50">
            <div className="flex items-center justify-between">
              <div>
                <div className="font-medium">{company.company_code} - {company.company_name}</div>
                <div className="text-sm text-gray-600">{company.currency} • {company.country}</div>
              </div>
              <div className="flex space-x-2">
                <button className="text-blue-600 hover:text-blue-800">
                  <Icons.Edit className="w-4 h-4" />
                </button>
                <button className="text-green-600 hover:text-green-800">
                  <Icons.Check className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )

  const NavigationButtons = () => (
    <div className={`${isMobile ? 'p-4' : 'p-6'} bg-white border-t`}>
      <div className="flex justify-between">
        <button
          onClick={() => setCurrentStep(Math.max(1, currentStep - 1))}
          disabled={currentStep === 1}
          className="flex items-center px-4 py-2 text-gray-600 hover:text-gray-800 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <Icons.ChevronLeft className="w-4 h-4 mr-1" />
          Previous
        </button>
        
        <div className="flex space-x-3">
          <button className="px-4 py-2 text-gray-600 hover:text-gray-800">
            Save Draft
          </button>
          <button
            onClick={() => setCurrentStep(Math.min(steps.length, currentStep + 1))}
            disabled={currentStep === steps.length}
            className="flex items-center px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {currentStep === steps.length ? 'Complete Setup' : 'Next Step'}
            {currentStep < steps.length && <Icons.ChevronRight className="w-4 h-4 ml-1" />}
          </button>
        </div>
      </div>
    </div>
  )

  const renderCurrentStep = () => {
    switch (currentStep) {
      case 1: return <CompanySetupStep />
      case 2: return <div className="p-6">Controlling Areas Step</div>
      case 3: return <div className="p-6">Plants & Locations Step</div>
      case 4: return <div className="p-6">Departments Step</div>
      case 5: return <div className="p-6">Assignments Step</div>
      case 6: return <div className="p-6">Review & Activate Step</div>
      default: return <CompanySetupStep />
    }
  }

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      <StepIndicator />
      <div className="flex-1 overflow-y-auto">
        {renderCurrentStep()}
      </div>
      <NavigationButtons />
    </div>
  )
}