-- Enhanced Timesheet System - Update Script
-- =====================================================

-- Employee/Worker Management (only if not exists)
CREATE TABLE IF NOT EXISTS employees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_code VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    job_title VARCHAR(100),
    department VARCHAR(100),
    hire_date DATE NOT NULL,
    employment_type VARCHAR(20) DEFAULT 'permanent',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Employee Rate Cards
CREATE TABLE IF NOT EXISTS employee_rates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    rate_type VARCHAR(20) NOT NULL DEFAULT 'regular',
    hourly_rate DECIMAL(10,2) NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(employee_id, project_id, rate_type, effective_from)
);

-- Subcontractor Rate Cards (subcontractors table already exists)
CREATE TABLE IF NOT EXISTS subcontractor_rates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subcontractor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    work_type VARCHAR(100) NOT NULL,
    unit_type VARCHAR(20) NOT NULL DEFAULT 'hour',
    unit_rate DECIMAL(10,2) NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enhanced Daily Timesheets (replace existing)
DROP TABLE IF EXISTS timesheets CASCADE;
DROP TABLE IF EXISTS timesheet_entries CASCADE;

CREATE TABLE daily_timesheets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    timesheet_date DATE NOT NULL,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    employee_id UUID REFERENCES employees(id) ON DELETE CASCADE,
    vendor_id UUID REFERENCES vendors(id) ON DELETE CASCADE,
    supervisor_id UUID REFERENCES employees(id),
    status VARCHAR(20) DEFAULT 'draft',
    total_regular_hours DECIMAL(8,2) DEFAULT 0,
    total_overtime_hours DECIMAL(8,2) DEFAULT 0,
    total_cost DECIMAL(15,2) DEFAULT 0,
    submitted_at TIMESTAMP WITH TIME ZONE,
    approved_by UUID REFERENCES employees(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT check_worker_type CHECK (
        (employee_id IS NOT NULL AND vendor_id IS NULL) OR 
        (employee_id IS NULL AND vendor_id IS NOT NULL)
    ),
    UNIQUE(timesheet_date, project_id, employee_id, vendor_id)
);

-- Timesheet Line Items
CREATE TABLE timesheet_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    timesheet_id UUID NOT NULL REFERENCES daily_timesheets(id) ON DELETE CASCADE,
    task_id UUID REFERENCES tasks(id) ON DELETE SET NULL,
    activity_id UUID REFERENCES activities(id) ON DELETE SET NULL,
    cost_object_id UUID REFERENCES cost_objects(id) ON DELETE SET NULL,
    work_description TEXT NOT NULL,
    start_time TIME,
    end_time TIME,
    break_minutes INTEGER DEFAULT 0,
    regular_hours DECIMAL(8,2) NOT NULL DEFAULT 0,
    overtime_hours DECIMAL(8,2) DEFAULT 0,
    hourly_rate DECIMAL(10,2) NOT NULL,
    line_cost DECIMAL(15,2) GENERATED ALWAYS AS ((regular_hours + overtime_hours * 1.5) * hourly_rate) STORED,
    work_location VARCHAR(255),
    equipment_used TEXT,
    materials_used TEXT,
    weather_conditions VARCHAR(100),
    remarks TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Cost Allocation Records
CREATE TABLE timesheet_cost_allocations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    timesheet_line_id UUID NOT NULL REFERENCES timesheet_lines(id) ON DELETE CASCADE,
    cost_object_id UUID NOT NULL REFERENCES cost_objects(id) ON DELETE CASCADE,
    allocation_date DATE NOT NULL,
    labor_hours DECIMAL(8,2) NOT NULL,
    labor_cost DECIMAL(15,2) NOT NULL,
    cost_type VARCHAR(20) DEFAULT 'actual',
    allocation_method VARCHAR(20) DEFAULT 'direct',
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TRIGGERS FOR AUTOMATED COST ALLOCATION
-- =====================================================

-- Auto-calculate timesheet totals
CREATE OR REPLACE FUNCTION calculate_timesheet_totals()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE daily_timesheets 
    SET 
        total_regular_hours = (
            SELECT COALESCE(SUM(regular_hours), 0)
            FROM timesheet_lines 
            WHERE timesheet_id = COALESCE(NEW.timesheet_id, OLD.timesheet_id)
        ),
        total_overtime_hours = (
            SELECT COALESCE(SUM(overtime_hours), 0)
            FROM timesheet_lines 
            WHERE timesheet_id = COALESCE(NEW.timesheet_id, OLD.timesheet_id)
        ),
        total_cost = (
            SELECT COALESCE(SUM(line_cost), 0)
            FROM timesheet_lines 
            WHERE timesheet_id = COALESCE(NEW.timesheet_id, OLD.timesheet_id)
        ),
        updated_at = NOW()
    WHERE id = COALESCE(NEW.timesheet_id, OLD.timesheet_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_calculate_timesheet_totals
    AFTER INSERT OR UPDATE OR DELETE ON timesheet_lines
    FOR EACH ROW
    EXECUTE FUNCTION calculate_timesheet_totals();

-- Auto-allocate costs when timesheet is approved
CREATE OR REPLACE FUNCTION allocate_timesheet_costs()
RETURNS TRIGGER AS $$
DECLARE
    line_rec RECORD;
BEGIN
    IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
        FOR line_rec IN 
            SELECT * FROM timesheet_lines WHERE timesheet_id = NEW.id
        LOOP
            INSERT INTO timesheet_cost_allocations (
                timesheet_line_id,
                cost_object_id,
                allocation_date,
                labor_hours,
                labor_cost,
                created_by
            ) VALUES (
                line_rec.id,
                line_rec.cost_object_id,
                NEW.timesheet_date,
                line_rec.regular_hours + line_rec.overtime_hours,
                line_rec.line_cost,
                NEW.approved_by
            );
            
            INSERT INTO cost_transactions (
                cost_object_id,
                transaction_type,
                amount,
                reference_type,
                reference_id,
                transaction_date,
                description,
                created_by
            ) VALUES (
                line_rec.cost_object_id,
                'actual',
                line_rec.line_cost,
                'timesheet',
                NEW.id,
                NEW.timesheet_date,
                'Labor cost - ' || COALESCE(
                    (SELECT first_name || ' ' || last_name FROM employees WHERE id = NEW.employee_id),
                    (SELECT name FROM vendors WHERE id = NEW.vendor_id)
                ),
                NEW.approved_by
            );
            
            UPDATE cost_objects 
            SET 
                actual_amount = actual_amount + line_rec.line_cost,
                updated_at = NOW()
            WHERE id = line_rec.cost_object_id;
        END LOOP;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_allocate_timesheet_costs
    AFTER UPDATE ON daily_timesheets
    FOR EACH ROW
    EXECUTE FUNCTION allocate_timesheet_costs();

-- Auto-populate hourly rates
CREATE OR REPLACE FUNCTION populate_hourly_rate()
RETURNS TRIGGER AS $$
DECLARE
    rate_amount DECIMAL(10,2);
    timesheet_rec RECORD;
BEGIN
    SELECT * INTO timesheet_rec
    FROM daily_timesheets
    WHERE id = NEW.timesheet_id;
    
    IF timesheet_rec.employee_id IS NOT NULL THEN
        SELECT hourly_rate INTO rate_amount
        FROM employee_rates
        WHERE employee_id = timesheet_rec.employee_id
        AND (project_id = timesheet_rec.project_id OR project_id IS NULL)
        AND rate_type = 'regular'
        AND effective_from <= timesheet_rec.timesheet_date
        AND (effective_to IS NULL OR effective_to >= timesheet_rec.timesheet_date)
        AND is_active = true
        ORDER BY project_id NULLS LAST, effective_from DESC
        LIMIT 1;
    ELSE
        SELECT unit_rate INTO rate_amount
        FROM subcontractor_rates
        WHERE subcontractor_id = timesheet_rec.vendor_id
        AND (project_id = timesheet_rec.project_id OR project_id IS NULL)
        AND unit_type = 'hour'
        AND effective_from <= timesheet_rec.timesheet_date
        AND (effective_to IS NULL OR effective_to >= timesheet_rec.timesheet_date)
        AND is_active = true
        ORDER BY project_id NULLS LAST, effective_from DESC
        LIMIT 1;
    END IF;
    
    IF rate_amount IS NOT NULL THEN
        NEW.hourly_rate := rate_amount;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_populate_hourly_rate
    BEFORE INSERT OR UPDATE ON timesheet_lines
    FOR EACH ROW
    WHEN (NEW.hourly_rate = 0 OR NEW.hourly_rate IS NULL)
    EXECUTE FUNCTION populate_hourly_rate();

-- Indexes for performance
CREATE INDEX idx_daily_timesheets_date_project ON daily_timesheets(timesheet_date, project_id);
CREATE INDEX idx_daily_timesheets_employee ON daily_timesheets(employee_id);
CREATE INDEX idx_daily_timesheets_vendor ON daily_timesheets(vendor_id);
CREATE INDEX idx_daily_timesheets_status ON daily_timesheets(status);
CREATE INDEX idx_timesheet_lines_cost_object ON timesheet_lines(cost_object_id);
CREATE INDEX idx_timesheet_lines_task ON timesheet_lines(task_id);
CREATE INDEX idx_employee_rates_lookup ON employee_rates(employee_id, project_id, effective_from);
CREATE INDEX idx_subcontractor_rates_lookup ON subcontractor_rates(subcontractor_id, project_id, effective_from);
CREATE INDEX idx_cost_allocations_date ON timesheet_cost_allocations(allocation_date);
CREATE INDEX idx_cost_allocations_cost_object ON timesheet_cost_allocations(cost_object_id);