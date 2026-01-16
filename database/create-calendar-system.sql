-- Flexible Calendar System for Project Scheduling
-- Supports configurable weekends, holidays, and working hours

-- Calendar Master Table
CREATE TABLE IF NOT EXISTS calendars (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_default BOOLEAN DEFAULT false,
    company_code VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Calendar Working Days Configuration
CREATE TABLE IF NOT EXISTS calendar_working_days (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    calendar_id UUID NOT NULL REFERENCES calendars(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6), -- 0=Sunday, 6=Saturday
    is_working_day BOOLEAN NOT NULL DEFAULT true,
    work_hours DECIMAL(4,2) DEFAULT 8.0, -- Hours per day (e.g., 8.0, 4.0 for half day)
    UNIQUE(calendar_id, day_of_week)
);

-- Calendar Holidays/Exceptions
CREATE TABLE IF NOT EXISTS calendar_exceptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    calendar_id UUID NOT NULL REFERENCES calendars(id) ON DELETE CASCADE,
    exception_date DATE NOT NULL,
    is_working_day BOOLEAN NOT NULL DEFAULT false, -- false = holiday, true = special working day
    work_hours DECIMAL(4,2) DEFAULT 0.0,
    description VARCHAR(200), -- e.g., "Christmas", "Project Deadline - Work Saturday"
    UNIQUE(calendar_id, exception_date)
);

-- Link Projects to Calendars
ALTER TABLE projects ADD COLUMN IF NOT EXISTS calendar_id UUID REFERENCES calendars(id);

-- Link Activities to Calendars (optional override)
ALTER TABLE activities ADD COLUMN IF NOT EXISTS calendar_id UUID REFERENCES calendars(id);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_calendar_working_days_calendar ON calendar_working_days(calendar_id);
CREATE INDEX IF NOT EXISTS idx_calendar_exceptions_calendar ON calendar_exceptions(calendar_id);
CREATE INDEX IF NOT EXISTS idx_calendar_exceptions_date ON calendar_exceptions(exception_date);
CREATE INDEX IF NOT EXISTS idx_projects_calendar ON projects(calendar_id);
CREATE INDEX IF NOT EXISTS idx_activities_calendar ON activities(calendar_id);

-- Insert Default Calendars
INSERT INTO calendars (name, description, is_default) VALUES
('Standard (Sat-Sun)', 'Standard 5-day work week, Saturday-Sunday off', true),
('Middle East (Fri-Sat)', 'Friday-Saturday weekend', false),
('6-Day Week (Sun)', 'Sunday only off', false),
('7-Day Week', 'No weekends - continuous work', false);

-- Standard Calendar (Sat-Sun off)
INSERT INTO calendar_working_days (calendar_id, day_of_week, is_working_day, work_hours)
SELECT id, 0, true, 8.0 FROM calendars WHERE name = 'Standard (Sat-Sun)' -- Sunday
UNION ALL
SELECT id, 1, true, 8.0 FROM calendars WHERE name = 'Standard (Sat-Sun)' -- Monday
UNION ALL
SELECT id, 2, true, 8.0 FROM calendars WHERE name = 'Standard (Sat-Sun)' -- Tuesday
UNION ALL
SELECT id, 3, true, 8.0 FROM calendars WHERE name = 'Standard (Sat-Sun)' -- Wednesday
UNION ALL
SELECT id, 4, true, 8.0 FROM calendars WHERE name = 'Standard (Sat-Sun)' -- Thursday
UNION ALL
SELECT id, 5, false, 0.0 FROM calendars WHERE name = 'Standard (Sat-Sun)' -- Friday
UNION ALL
SELECT id, 6, false, 0.0 FROM calendars WHERE name = 'Standard (Sat-Sun)'; -- Saturday

-- Middle East Calendar (Fri-Sat off)
INSERT INTO calendar_working_days (calendar_id, day_of_week, is_working_day, work_hours)
SELECT id, 0, true, 8.0 FROM calendars WHERE name = 'Middle East (Fri-Sat)' -- Sunday
UNION ALL
SELECT id, 1, true, 8.0 FROM calendars WHERE name = 'Middle East (Fri-Sat)' -- Monday
UNION ALL
SELECT id, 2, true, 8.0 FROM calendars WHERE name = 'Middle East (Fri-Sat)' -- Tuesday
UNION ALL
SELECT id, 3, true, 8.0 FROM calendars WHERE name = 'Middle East (Fri-Sat)' -- Wednesday
UNION ALL
SELECT id, 4, true, 8.0 FROM calendars WHERE name = 'Middle East (Fri-Sat)' -- Thursday
UNION ALL
SELECT id, 5, false, 0.0 FROM calendars WHERE name = 'Middle East (Fri-Sat)' -- Friday
UNION ALL
SELECT id, 6, false, 0.0 FROM calendars WHERE name = 'Middle East (Fri-Sat)'; -- Saturday

-- 6-Day Week Calendar (Sun off)
INSERT INTO calendar_working_days (calendar_id, day_of_week, is_working_day, work_hours)
SELECT id, 0, false, 0.0 FROM calendars WHERE name = '6-Day Week (Sun)' -- Sunday
UNION ALL
SELECT id, 1, true, 8.0 FROM calendars WHERE name = '6-Day Week (Sun)' -- Monday
UNION ALL
SELECT id, 2, true, 8.0 FROM calendars WHERE name = '6-Day Week (Sun)' -- Tuesday
UNION ALL
SELECT id, 3, true, 8.0 FROM calendars WHERE name = '6-Day Week (Sun)' -- Wednesday
UNION ALL
SELECT id, 4, true, 8.0 FROM calendars WHERE name = '6-Day Week (Sun)' -- Thursday
UNION ALL
SELECT id, 5, true, 8.0 FROM calendars WHERE name = '6-Day Week (Sun)' -- Friday
UNION ALL
SELECT id, 6, true, 8.0 FROM calendars WHERE name = '6-Day Week (Sun)'; -- Saturday

-- 7-Day Week Calendar (no weekends)
INSERT INTO calendar_working_days (calendar_id, day_of_week, is_working_day, work_hours)
SELECT id, generate_series(0, 6), true, 8.0 FROM calendars WHERE name = '7-Day Week';

COMMENT ON TABLE calendars IS 'Master calendar definitions for projects';
COMMENT ON TABLE calendar_working_days IS 'Working day configuration per calendar (which days are working days)';
COMMENT ON TABLE calendar_exceptions IS 'Holidays and special working days (overrides working_days)';
COMMENT ON COLUMN calendar_working_days.day_of_week IS '0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday';
COMMENT ON COLUMN calendar_working_days.work_hours IS 'Hours per day (8.0 = full day, 4.0 = half day, 0.0 = non-working)';

SELECT 'Flexible calendar system created successfully!' as status;
