-- Remove constraints from drawings table
ALTER TABLE drawings ALTER COLUMN drawing_type DROP NOT NULL;
ALTER TABLE drawings ALTER COLUMN file_path DROP NOT NULL;
ALTER TABLE drawings ALTER COLUMN file_name DROP NOT NULL;
ALTER TABLE drawings DROP CONSTRAINT IF EXISTS drawings_status_check;
