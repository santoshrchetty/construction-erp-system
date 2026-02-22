-- Quick test to verify the engineering documents system is working

-- Check if tables exist
SELECT 'documents table' as table_name, COUNT(*) as count FROM documents;
SELECT 'document_lifecycle table' as table_name, COUNT(*) as count FROM document_lifecycle;

-- Check current documents with lifecycle
SELECT 
  d.document_number,
  d.title,
  d.document_type,
  dl.version,
  dl.status,
  dl.is_current
FROM documents d
LEFT JOIN document_lifecycle dl ON d.id = dl.document_id AND dl.is_current = true
ORDER BY d.created_at DESC;