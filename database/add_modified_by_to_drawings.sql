-- Add modified_by column to drawings table
ALTER TABLE drawings ADD COLUMN IF NOT EXISTS modified_by UUID;
