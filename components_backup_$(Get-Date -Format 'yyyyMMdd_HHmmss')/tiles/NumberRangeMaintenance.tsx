import React, { useState, useEffect } from 'react';

interface NumberRange {
  id: string;
  company_code: string;
  document_type: string;
  from_number: number;
  to_number: number;
  current_number: number;
  status: string;
}

interface NumberRangeAlert {
  id: string;
  company_code: string;
  document_type: string;
  alert_type: string;
  alert_message: string;
  created_at: string;
}

interface NumberRangeStatistics {
  company_code: string;
  document_type: string;
  total_capacity: number;
  numbers_used: number;
  usage_percentage: number;
  days_since_last_use: number | null;
  estimated_days_remaining: number | null;
}

interface NumberRangeMaintenanceProps {
  companyCode?: string;
}

export const NumberRangeMaintenance: React.FC<NumberRangeMaintenanceProps> = ({ companyCode }) => {
  const [numberRanges, setNumberRanges] = useState<NumberRange[]>([]);
  const [alerts, setAlerts] = useState<NumberRangeAlert[]>([]);
  const [statistics, setStatistics] = useState<NumberRangeStatistics[]>([]);
  const [selectedRange, setSelectedRange] = useState<NumberRange | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<'ranges' | 'alerts' | 'statistics'>('ranges');

  useEffect(() => {
    loadData();
    const interval = setInterval(loadData, 30000); // Refresh every 30 seconds
    return () => clearInterval(interval);
  }, [companyCode]);

  const loadData = async () => {
    try {
      setIsLoading(true);
      const response = await fetch('/api/number-ranges');
      const data = await response.json();
      
      if (response.ok) {
        setNumberRanges(data.numberRanges || []);
        // Mock alerts and statistics for now
        setAlerts([]);
        setStatistics([]);
      }
    } catch (error) {
      console.error('Failed to load data:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleExtendRange = async (id: string) => {
    try {
      const response = await fetch('/api/number-ranges', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id, action: 'extend' })
      });
      
      if (response.ok) {
        loadData();
      }
    } catch (error) {
      console.error('Failed to extend range:', error);
    }
  };

  const handleAcknowledgeAlert = async (alertId: string) => {
    try {
      // Mock implementation for now
      console.log('Acknowledging alert:', alertId);
      loadData();
    } catch (error) {
      console.error('Failed to acknowledge alert:', error);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'ACTIVE': return 'text-green-600';
      case 'INACTIVE': return 'text-gray-500';
      case 'EXHAUSTED': return 'text-red-600';
      case 'SUSPENDED': return 'text-yellow-600';
      default: return 'text-gray-500';
    }
  };

  const getUsageColor = (percentage: number) => {
    if (percentage >= 95) return 'bg-red-500';
    if (percentage >= 80) return 'bg-yellow-500';
    return 'bg-green-500';
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-lg shadow-lg p-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-4 sm:mb-0">Number Range Maintenance</h2>
        <div className="flex space-x-2">
          <button
            onClick={() => setActiveTab('ranges')}
            className={`px-4 py-2 rounded-md text-sm font-medium ${
              activeTab === 'ranges' ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-700'
            }`}
          >
            Ranges ({numberRanges.length})
          </button>
          <button
            onClick={() => setActiveTab('alerts')}
            className={`px-4 py-2 rounded-md text-sm font-medium relative ${
              activeTab === 'alerts' ? 'bg-red-600 text-white' : 'bg-gray-200 text-gray-700'
            }`}
          >
            Alerts ({alerts.length})
            {alerts.length > 0 && (
              <span className="absolute -top-2 -right-2 bg-red-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">
                {alerts.length}
              </span>
            )}
          </button>
          <button
            onClick={() => setActiveTab('statistics')}
            className={`px-4 py-2 rounded-md text-sm font-medium ${
              activeTab === 'statistics' ? 'bg-green-600 text-white' : 'bg-gray-200 text-gray-700'
            }`}
          >
            Statistics
          </button>
        </div>
      </div>

      {activeTab === 'ranges' && (
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Company</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Range</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Current</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Usage</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {numberRanges.map((range) => {
                const stat = statistics.find(s => s.company_code === range.company_code && s.document_type === range.document_type);
                const usagePercentage = stat?.usage_percentage || 0;
                
                return (
                  <tr key={range.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{range.company_code}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{range.document_type}</td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {range.from_number.toLocaleString()} - {range.to_number.toLocaleString()}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{range.current_number.toLocaleString()}</td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="w-16 bg-gray-200 rounded-full h-2 mr-2">
                          <div
                            className={`h-2 rounded-full ${getUsageColor(usagePercentage)}`}
                            style={{ width: `${Math.min(usagePercentage, 100)}%` }}
                          ></div>
                        </div>
                        <span className="text-sm text-gray-500">{usagePercentage}%</span>
                      </div>
                    </td>
                    <td className={`px-6 py-4 whitespace-nowrap text-sm font-medium ${getStatusColor(range.status)}`}>
                      {range.status}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <div className="flex space-x-2">
                        <button
                          onClick={() => setSelectedRange(range)}
                          className="text-blue-600 hover:text-blue-900"
                        >
                          Edit
                        </button>
                        {usagePercentage >= 80 && (
                          <button
                            onClick={() => handleExtendRange(range.id)}
                            className="text-green-600 hover:text-green-900"
                          >
                            Extend
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}

      {activeTab === 'alerts' && (
        <div className="space-y-4">
          {alerts.length === 0 ? (
            <div className="text-center py-8 text-gray-500">No active alerts</div>
          ) : (
            alerts.map((alert) => (
              <div key={alert.id} className={`p-4 rounded-lg border-l-4 ${
                alert.alert_type === 'CRITICAL' ? 'border-red-500 bg-red-50' : 'border-yellow-500 bg-yellow-50'
              }`}>
                <div className="flex justify-between items-start">
                  <div>
                    <h4 className="font-medium text-gray-900">
                      {alert.company_code} - {alert.document_type}
                    </h4>
                    <p className="text-sm text-gray-600 mt-1">{alert.alert_message}</p>
                    <p className="text-xs text-gray-500 mt-2">
                      Created: {new Date(alert.created_at).toLocaleString()}
                    </p>
                  </div>
                  <button
                    onClick={() => handleAcknowledgeAlert(alert.id)}
                    className="text-sm bg-white px-3 py-1 rounded border hover:bg-gray-50"
                  >
                    Acknowledge
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
      )}

      {activeTab === 'statistics' && (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {statistics.map((stat) => (
            <div key={`${stat.company_code}-${stat.document_type}`} className="bg-gray-50 rounded-lg p-4">
              <h4 className="font-medium text-gray-900 mb-2">
                {stat.company_code} - {stat.document_type}
              </h4>
              <div className="space-y-2 text-sm">
                <div className="flex justify-between">
                  <span>Capacity:</span>
                  <span>{stat.total_capacity.toLocaleString()}</span>
                </div>
                <div className="flex justify-between">
                  <span>Used:</span>
                  <span>{stat.numbers_used.toLocaleString()}</span>
                </div>
                <div className="flex justify-between">
                  <span>Usage:</span>
                  <span className={`font-medium ${
                    stat.usage_percentage >= 95 ? 'text-red-600' : 
                    stat.usage_percentage >= 80 ? 'text-yellow-600' : 'text-green-600'
                  }`}>
                    {stat.usage_percentage}%
                  </span>
                </div>
                {stat.days_since_last_use !== null && (
                  <div className="flex justify-between">
                    <span>Last used:</span>
                    <span>{stat.days_since_last_use} days ago</span>
                  </div>
                )}
                {stat.estimated_days_remaining !== null && (
                  <div className="flex justify-between">
                    <span>Est. remaining:</span>
                    <span>{stat.estimated_days_remaining} days</span>
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};