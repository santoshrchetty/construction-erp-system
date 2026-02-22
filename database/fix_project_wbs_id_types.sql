-- Fix project_id and wbs_element_id to be UUID instead of INTEGER
ALTER TABLE material_request_items 
ALTER COLUMN project_id TYPE UUID USING project_id::text::uuid,
ALTER COLUMN wbs_element_id TYPE UUID USING wbs_element_id::text::uuid;
