-- Add missing columns to projects table
ALTER TABLE projects 
ADD COLUMN IF NOT EXISTS cost_center_id UUID,
ADD COLUMN IF NOT EXISTS profit_center_id UUID,
ADD COLUMN IF NOT EXISTS plant_id UUID,
ADD COLUMN IF NOT EXISTS person_responsible_id UUID,
ADD COLUMN IF NOT EXISTS company_code_id VARCHAR(10),
ADD COLUMN IF NOT EXISTS code VARCHAR(50),
ADD COLUMN IF NOT EXISTS description TEXT,
ADD COLUMN IF NOT EXISTS start_date DATE,
ADD COLUMN IF NOT EXISTS planned_end_date DATE,
ADD COLUMN IF NOT EXISTS budget DECIMAL(15,2),
ADD COLUMN IF NOT EXISTS location VARCHAR(255),
ADD COLUMN IF NOT EXISTS created_by UUID,
ADD COLUMN IF NOT EXISTS working_days INTEGER[],
ADD COLUMN IF NOT EXISTS holidays DATE[];

-- Add foreign key constraints (run separately if needed)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_projects_cost_center') THEN
        ALTER TABLE projects ADD CONSTRAINT fk_projects_cost_center 
        FOREIGN KEY (cost_center_id) REFERENCES cost_centers(id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_projects_profit_center') THEN
        ALTER TABLE projects ADD CONSTRAINT fk_projects_profit_center 
        FOREIGN KEY (profit_center_id) REFERENCES profit_centers(id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_projects_plant') THEN
        ALTER TABLE projects ADD CONSTRAINT fk_projects_plant 
        FOREIGN KEY (plant_id) REFERENCES plants(id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_projects_person_responsible') THEN
        ALTER TABLE projects ADD CONSTRAINT fk_projects_person_responsible 
        FOREIGN KEY (person_responsible_id) REFERENCES persons_responsible(id);
    END IF;
END $$;