'use client'

import { useState } from 'react'

export default function SystemSettings() {
  const [settings, setSettings] = useState({
    siteName: 'Construction Management SaaS',
    defaultRole: 'Employee',
    sessionTimeout: 30,
    enableNotifications: true,
    enableAuditLogs: true,
    maxFileSize: 10,
    allowedFileTypes: 'pdf,doc,docx,xls,xlsx,jpg,png'
  })

  const handleSave = () => {
    // Save settings logic
    alert('Settings saved successfully!')
  }

  return (
    <div className="space-y-6">
      <h2 className="text-2xl font-bold">System Settings</h2>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-lg font-medium mb-4">General Settings</h3>
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-1">Site Name</label>
              <input
                type="text"
                value={settings.siteName}
                onChange={(e) => setSettings({...settings, siteName: e.target.value})}
                className="w-full border rounded px-3 py-2"
              />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Default User Role</label>
              <select
                value={settings.defaultRole}
                onChange={(e) => setSettings({...settings, defaultRole: e.target.value})}
                className="w-full border rounded px-3 py-2"
              >
                <option value="Employee">Employee</option>
                <option value="Engineer">Engineer</option>
                <option value="Manager">Manager</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Session Timeout (minutes)</label>
              <input
                type="number"
                value={settings.sessionTimeout}
                onChange={(e) => setSettings({...settings, sessionTimeout: parseInt(e.target.value)})}
                className="w-full border rounded px-3 py-2"
              />
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow p-6">
          <h3 className="text-lg font-medium mb-4">Feature Settings</h3>
          <div className="space-y-4">
            <div>
              <label className="flex items-center">
                <input
                  type="checkbox"
                  checked={settings.enableNotifications}
                  onChange={(e) => setSettings({...settings, enableNotifications: e.target.checked})}
                  className="mr-2"
                />
                Enable Email Notifications
              </label>
            </div>
            <div>
              <label className="flex items-center">
                <input
                  type="checkbox"
                  checked={settings.enableAuditLogs}
                  onChange={(e) => setSettings({...settings, enableAuditLogs: e.target.checked})}
                  className="mr-2"
                />
                Enable Audit Logging
              </label>
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Max File Upload Size (MB)</label>
              <input
                type="number"
                value={settings.maxFileSize}
                onChange={(e) => setSettings({...settings, maxFileSize: parseInt(e.target.value)})}
                className="w-full border rounded px-3 py-2"
              />
            </div>
            <div>
              <label className="block text-sm font-medium mb-1">Allowed File Types</label>
              <input
                type="text"
                value={settings.allowedFileTypes}
                onChange={(e) => setSettings({...settings, allowedFileTypes: e.target.value})}
                className="w-full border rounded px-3 py-2"
                placeholder="pdf,doc,docx,jpg,png"
              />
            </div>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="text-lg font-medium mb-4">Database Maintenance</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <button className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
            Backup Database
          </button>
          <button className="bg-yellow-600 text-white px-4 py-2 rounded hover:bg-yellow-700">
            Clear Cache
          </button>
          <button className="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700">
            Optimize Tables
          </button>
        </div>
      </div>

      <div className="flex justify-end">
        <button
          onClick={handleSave}
          className="bg-blue-600 text-white px-6 py-2 rounded hover:bg-blue-700"
        >
          Save Settings
        </button>
      </div>
    </div>
  )
}