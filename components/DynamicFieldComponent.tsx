// Enhanced Dynamic Dropdown Component with Multi-Selection
import React, { useState, useCallback, useMemo } from 'react';
import * as Icons from 'lucide-react';

interface FieldOption {
  value: string;
  label: string;
  description?: string;
}

interface FieldDefinition {
  field_name: string;
  field_label: string;
  field_type: 'SINGLE_SELECT' | 'MULTI_SELECT' | 'TEXT' | 'CUSTOM';
  field_category: string;
  is_required: boolean;
  options: FieldOption[];
}

interface DynamicFieldProps {
  fieldDef: FieldDefinition;
  value: string | string[];
  onChange: (fieldName: string, value: string | string[]) => void;
  onAddCustomOption?: (fieldName: string, newOption: FieldOption) => void;
}

export function DynamicField({ fieldDef, value, onChange, onAddCustomOption }: DynamicFieldProps) {
  const [showCustomInput, setShowCustomInput] = useState(false);
  const [customValue, setCustomValue] = useState('');
  const [customLabel, setCustomLabel] = useState('');
  const [error, setError] = useState<string | null>(null);

  const validateInput = useCallback((val: string, label: string): boolean => {
    if (!val.trim() || !label.trim()) {
      setError('Both value and label are required');
      return false;
    }
    if (val.length > 50 || label.length > 100) {
      setError('Value must be ≤50 chars, label ≤100 chars');
      return false;
    }
    if (!/^[A-Z0-9_]+$/.test(val.toUpperCase())) {
      setError('Value must contain only letters, numbers, and underscores');
      return false;
    }
    setError(null);
    return true;
  }, []);

  const handleSingleSelect = useCallback((selectedValue: string) => {
    onChange(fieldDef.field_name, selectedValue);
  }, [fieldDef.field_name, onChange]);

  const handleMultiSelect = useCallback((selectedValue: string) => {
    const currentValues = Array.isArray(value) ? value : [];
    const newValues = currentValues.includes(selectedValue)
      ? currentValues.filter(v => v !== selectedValue)
      : [...currentValues, selectedValue];
    onChange(fieldDef.field_name, newValues);
  }, [fieldDef.field_name, value, onChange]);

  const handleAddCustomOption = useCallback(() => {
    const trimmedValue = customValue.trim();
    const trimmedLabel = customLabel.trim();
    
    if (!validateInput(trimmedValue, trimmedLabel)) {
      return;
    }

    if (onAddCustomOption) {
      const newOption: FieldOption = {
        value: trimmedValue.toUpperCase().replace(/\s+/g, '_'),
        label: trimmedLabel,
        description: `Custom ${fieldDef.field_label.toLowerCase()}`
      };
      onAddCustomOption(fieldDef.field_name, newOption);
      setCustomValue('');
      setCustomLabel('');
      setShowCustomInput(false);
      setError(null);
    }
  }, [customValue, customLabel, fieldDef.field_name, fieldDef.field_label, onAddCustomOption, validateInput]);

  const selectedValues = useMemo(() => {
    return Array.isArray(value) ? value : [];
  }, [value]);

  if (fieldDef.field_type === 'SINGLE_SELECT') {
    return (
      <div className="bg-white border rounded-lg p-4">
        <div className="flex items-center justify-between mb-2">
          <label className="block text-sm font-medium text-gray-700">
            {fieldDef.field_label}
            {fieldDef.is_required && <span className="text-red-500 ml-1">*</span>}
          </label>
          <button
            onClick={() => setShowCustomInput(!showCustomInput)}
            className="text-xs text-blue-600 hover:text-blue-800"
            title="Add custom option"
          >
            <Icons.Plus className="w-3 h-3" />
          </button>
        </div>
        
        <select
          className="w-full border rounded-lg px-3 py-2"
          value={value as string || ''}
          onChange={(e) => handleSingleSelect(e.target.value)}
        >
          <option value="">Select {fieldDef.field_label}</option>
          {fieldDef.options.map(option => (
            <option key={option.value} value={option.value}>
              {option.label}
            </option>
          ))}
        </select>
        
        {error && (
          <div className="mt-1 text-xs text-red-600">{error}</div>
        )}
        
        {showCustomInput && (
          <div className="mt-2 p-2 bg-gray-50 rounded border">
            <div className="grid grid-cols-2 gap-2">
              <input
                type="text"
                placeholder="Value (e.g., PLANT_SF)"
                value={customValue}
                onChange={(e) => setCustomValue(e.target.value.substring(0, 50))}
                className="text-xs border rounded px-2 py-1"
                maxLength={50}
              />
              <input
                type="text"
                placeholder="Label (e.g., San Francisco Plant)"
                value={customLabel}
                onChange={(e) => setCustomLabel(e.target.value.substring(0, 100))}
                className="text-xs border rounded px-2 py-1"
                maxLength={100}
              />
            </div>
            <div className="flex justify-end space-x-1 mt-2">
              <button
                onClick={() => {
                  setShowCustomInput(false);
                  setError(null);
                  setCustomValue('');
                  setCustomLabel('');
                }}
                className="text-xs px-2 py-1 text-gray-600 hover:text-gray-800"
              >
                Cancel
              </button>
              <button
                onClick={handleAddCustomOption}
                disabled={!customValue.trim() || !customLabel.trim()}
                className="text-xs px-2 py-1 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Add
              </button>
            </div>
          </div>
        )}
      </div>
    );
  }

  if (fieldDef.field_type === 'MULTI_SELECT') {
    return (
      <div className="bg-white border rounded-lg p-4">
        <div className="flex items-center justify-between mb-2">
          <label className="block text-sm font-medium text-gray-700">
            {fieldDef.field_label}
            {fieldDef.is_required && <span className="text-red-500 ml-1">*</span>}
          </label>
          <button
            onClick={() => setShowCustomInput(!showCustomInput)}
            className="text-xs text-blue-600 hover:text-blue-800"
            title="Add custom option"
          >
            <Icons.Plus className="w-3 h-3" />
          </button>
        </div>
        
        <div className="space-y-2 max-h-32 overflow-y-auto">
          {fieldDef.options.map(option => (
            <label key={option.value} className="flex items-center space-x-2 text-sm">
              <input
                type="checkbox"
                checked={selectedValues.includes(option.value)}
                onChange={() => handleMultiSelect(option.value)}
                className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
              />
              <span className="flex-1">{option.label}</span>
              {option.description && (
                <span className="text-xs text-gray-500">{option.description}</span>
              )}
            </label>
          ))}
        </div>
        
        {selectedValues.length > 0 && (
          <div className="mt-2 flex flex-wrap gap-1">
            {selectedValues.map(val => {
              const option = fieldDef.options.find(o => o.value === val);
              return (
                <span key={val} className="inline-flex items-center px-2 py-1 text-xs bg-blue-100 text-blue-800 rounded">
                  {option?.label || val}
                  <button
                    onClick={() => handleMultiSelect(val)}
                    className="ml-1 text-blue-600 hover:text-blue-800"
                  >
                    <Icons.X className="w-3 h-3" />
                  </button>
                </span>
              );
            })}
          </div>
        )}
        
        {error && (
          <div className="mt-1 text-xs text-red-600">{error}</div>
        )}
        
        {showCustomInput && (
          <div className="mt-2 p-2 bg-gray-50 rounded border">
            <div className="grid grid-cols-2 gap-2">
              <input
                type="text"
                placeholder="Value"
                value={customValue}
                onChange={(e) => setCustomValue(e.target.value.substring(0, 50))}
                className="text-xs border rounded px-2 py-1"
                maxLength={50}
              />
              <input
                type="text"
                placeholder="Label"
                value={customLabel}
                onChange={(e) => setCustomLabel(e.target.value.substring(0, 100))}
                className="text-xs border rounded px-2 py-1"
                maxLength={100}
              />
            </div>
            <div className="flex justify-end space-x-1 mt-2">
              <button
                onClick={() => {
                  setShowCustomInput(false);
                  setError(null);
                  setCustomValue('');
                  setCustomLabel('');
                }}
                className="text-xs px-2 py-1 text-gray-600 hover:text-gray-800"
              >
                Cancel
              </button>
              <button
                onClick={handleAddCustomOption}
                disabled={!customValue.trim() || !customLabel.trim()}
                className="text-xs px-2 py-1 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Add
              </button>
            </div>
          </div>
        )}
      </div>
    );
  }

  return (
    <div className="bg-white border rounded-lg p-4">
      <label className="block text-sm font-medium text-gray-700 mb-2">
        {fieldDef.field_label}
        {fieldDef.is_required && <span className="text-red-500 ml-1">*</span>}
      </label>
      <input
        type="text"
        value={value as string || ''}
        onChange={(e) => onChange(fieldDef.field_name, e.target.value.substring(0, 1000))}
        className="w-full border rounded-lg px-3 py-2"
        placeholder={`Enter ${fieldDef.field_label.toLowerCase()}`}
        maxLength={1000}
      />
    </div>
  );
}