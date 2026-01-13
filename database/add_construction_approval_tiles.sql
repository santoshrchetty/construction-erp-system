-- ADD MISSING CONSTRUCTION APPROVAL TILES
INSERT INTO tiles (title, icon, route) 
SELECT 'Purchase Requisition Approvals', 'fas fa-file-invoice', '/procurement/pr-approvals'
WHERE NOT EXISTS (SELECT 1 FROM tiles WHERE title = 'Purchase Requisition Approvals')
UNION ALL
SELECT 'Claims Approvals', 'fas fa-receipt', '/finance/claims-approvals'
WHERE NOT EXISTS (SELECT 1 FROM tiles WHERE title = 'Claims Approvals')
UNION ALL
SELECT 'Contract Approvals', 'fas fa-handshake', '/contracts/contract-approvals'
WHERE NOT EXISTS (SELECT 1 FROM tiles WHERE title = 'Contract Approvals')
UNION ALL
SELECT 'Invoice Approvals', 'fas fa-file-invoice-dollar', '/finance/invoice-approvals'
WHERE NOT EXISTS (SELECT 1 FROM tiles WHERE title = 'Invoice Approvals')
UNION ALL
SELECT 'Change Order Approvals', 'fas fa-edit', '/projects/change-order-approvals'
WHERE NOT EXISTS (SELECT 1 FROM tiles WHERE title = 'Change Order Approvals')
UNION ALL
SELECT 'Budget Approvals', 'fas fa-calculator', '/finance/budget-approvals'
WHERE NOT EXISTS (SELECT 1 FROM tiles WHERE title = 'Budget Approvals');

SELECT 'Construction approval tiles added' as result;