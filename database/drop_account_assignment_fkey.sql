-- Drop foreign key constraint on account_assignment_code since we're using category codes (P, K, A, etc.)
ALTER TABLE material_request_items 
DROP CONSTRAINT IF EXISTS material_request_items_account_assignment_code_fkey;
