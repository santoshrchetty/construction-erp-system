-- Add account assignment to purchase_requisition_items
-- Run this AFTER purchase_requisition_items table is created

ALTER TABLE purchase_requisition_items
ADD COLUMN IF NOT EXISTS account_assignment_code VARCHAR(2) REFERENCES account_assignment_types(code),
ADD COLUMN IF NOT EXISTS activity_code VARCHAR(12),
ADD COLUMN IF NOT EXISTS asset_number VARCHAR(12),
ADD COLUMN IF NOT EXISTS order_number VARCHAR(12);

CREATE INDEX IF NOT EXISTS idx_pr_items_account_assignment ON purchase_requisition_items(account_assignment_code);
