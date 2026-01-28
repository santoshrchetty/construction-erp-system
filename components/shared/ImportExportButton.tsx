import { Download, Upload } from 'lucide-react';
import { useRef } from 'react';

interface ImportExportButtonProps {
  onExport?: () => void;
  onImport?: (file: File) => void;
  exportLabel?: string;
  importLabel?: string;
  disabled?: boolean;
  count?: number;
  showImport?: boolean;
  showExport?: boolean;
  acceptedFileTypes?: string;
}

export function ImportExportButton({ 
  onExport,
  onImport,
  exportLabel = 'Export',
  importLabel = 'Import',
  disabled = false,
  count,
  showImport = true,
  showExport = true,
  acceptedFileTypes = '.xlsx,.xls,.csv'
}: ImportExportButtonProps) {
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleImportClick = () => {
    fileInputRef.current?.click();
  };

  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file && onImport) {
      onImport(file);
    }
    // Reset input value to allow same file selection
    event.target.value = '';
  };

  return (
    <div className="flex gap-2">
      {showImport && (
        <>
          <input
            ref={fileInputRef}
            type="file"
            accept={acceptedFileTypes}
            onChange={handleFileChange}
            className="hidden"
          />
          <button
            onClick={handleImportClick}
            disabled={disabled}
            className="px-3 py-1.5 bg-blue-600 text-white rounded-lg hover:bg-blue-700 
                       disabled:bg-gray-400 disabled:cursor-not-allowed
                       flex items-center gap-1 text-sm transition-colors"
            title="Import from Excel/CSV"
          >
            <Upload className="w-4 h-4" />
            {importLabel}
          </button>
        </>
      )}
      
      {showExport && (
        <button
          onClick={onExport}
          disabled={disabled}
          className="px-3 py-1.5 bg-green-600 text-white rounded-lg hover:bg-green-700 
                     disabled:bg-gray-400 disabled:cursor-not-allowed
                     flex items-center gap-1 text-sm transition-colors"
          title={count ? `Export ${count} items` : 'Export to Excel'}
        >
          <Download className="w-4 h-4" />
          {exportLabel}
          {count !== undefined && <span className="text-xs">({count})</span>}
        </button>
      )}
    </div>
  );
}

// Backward compatibility - keep original ExportButton
export function ExportButton({ 
  onClick, 
  label = 'Export', 
  disabled = false,
  count
}: {
  onClick: () => void;
  label?: string;
  disabled?: boolean;
  count?: number;
}) {
  return (
    <ImportExportButton
      onExport={onClick}
      exportLabel={label}
      disabled={disabled}
      count={count}
      showImport={false}
      showExport={true}
    />
  );
}