// Context Field Selector with Sparse Context Support
import React, { useState, useCallback } from 'react';
import * as Icons from 'lucide-react';

interface ContextFieldSelectorProps {
  fieldDef: any;
  value: string[] | null;
  onChange: (fieldName: string, value: string[] | null) => void;
}

type ContextMode = 'GLOBAL' | 'SPECIFIC';

export function ContextFieldSelector({ fieldDef, value, onChange }: ContextFieldSelectorProps) {
  const [mode, setMode] = useState<ContextMode>(
    value === null ? 'GLOBAL' : 'SPECIFIC'
  );

  const handleModeChange = useCallback((newMode: ContextMode) => {
    setMode(newMode);
    if (newMode === 'GLOBAL') {
      onChange(fieldDef.field_name, null);
    } else {
      onChange(fieldDef.field_name, []);
    }
  }, [fieldDef.field_name, onChange]);

  const handleValueChange = useCallback((selectedValue: string) => {
    if (mode === 'GLOBAL') return;
    
    const currentValues = value || [];
    const newValues = currentValues.includes(selectedValue)
      ? currentValues.filter(v => v !== selectedValue)
      : [...currentValues, selectedValue];
    
    onChange(fieldDef.field_name, newValues);
  }, [fieldDef.field_name, value, mode, onChange]);

  return (
    <div className="bg-white border rounded-lg p-4">
      <div className="flex items-center justify-between mb-3">
        <label className="block text-sm font-medium text-gray-700">
          {fieldDef.field_label}
        </label>
        <div className="flex items-center space-x-2">
          <button
            onClick={() => handleModeChange('GLOBAL')}
            className={`px-2 py-1 text-xs rounded ${
              mode === 'GLOBAL' 
                ? 'bg-blue-100 text-blue-800 border border-blue-300' 
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            🌐 Global
          </button>
          <button
            onClick={() => handleModeChange('SPECIFIC')}
            className={`px-2 py-1 text-xs rounded ${
              mode === 'SPECIFIC' 
                ? 'bg-blue-100 text-blue-800 border border-blue-300' 
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            🎯 Specific
          </button>
        </div>
      </div>

      {mode === 'GLOBAL' ? (
        <div className="p-3 bg-blue-50 border border-blue-200 rounded text-center">
          <Icons.Globe className="w-5 h-5 text-blue-600 mx-auto mb-1" />
          <p className="text-sm text-blue-700">
            Applies to all {fieldDef.field_label.toLowerCase()}
          </p>
        </div>
      ) : (
        <div className="space-y-3">
          <div className="space-y-2 max-h-32 overflow-y-auto">
            {fieldDef.approval_field_options?.map((option: any) => (
              <label key={option.option_value} className="flex items-center space-x-2 text-sm">
                <input
                  type="checkbox"
                  checked={(value || []).includes(option.option_value)}
                  onChange={() => handleValueChange(option.option_value)}
                  className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                />
                <span className="flex-1">{option.option_label}</span>
              </label>
            ))}
          </div>
          
          {value && value.length > 0 && (
            <div className="flex flex-wrap gap-1">
              {value.map(val => {
                const option = fieldDef.approval_field_options?.find((o: any) => o.option_value === val);
                return (
                  <span key={val} className="inline-flex items-center px-2 py-1 text-xs bg-blue-100 text-blue-800 rounded">
                    {option?.option_label || val}
                    <button
                      onClick={() => handleValueChange(val)}
                      className="ml-1 text-blue-600 hover:text-blue-800"
                    >
                      <Icons.X className="w-3 h-3" />
                    </button>
                  </span>
                );
              })}
            </div>
          )}
          
          {(!value || value.length === 0) && (
            <p className="text-xs text-gray-500 italic">
              No {fieldDef.field_label.toLowerCase()} selected - policy will not apply to any {fieldDef.field_label.toLowerCase()}
            </p>
          )}
        </div>
      )}
    </div>
  );
}