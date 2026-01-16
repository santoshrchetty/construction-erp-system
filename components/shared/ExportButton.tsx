import { Download } from 'lucide-react';

interface ExportButtonProps {
  onClick: () => void;
  label?: string;
  disabled?: boolean;
  count?: number;
}

export function ExportButton({ 
  onClick, 
  label = 'Export', 
  disabled = false,
  count
}: ExportButtonProps) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className="px-3 py-1.5 bg-green-600 text-white rounded-lg hover:bg-green-700 
                 disabled:bg-gray-400 disabled:cursor-not-allowed
                 flex items-center gap-1 text-sm transition-colors"
      title={count ? `Export ${count} items` : 'Export to Excel'}
    >
      <Download className="w-4 h-4" />
      {label}
      {count !== undefined && <span className="text-xs">({count})</span>}
    </button>
  );
}
