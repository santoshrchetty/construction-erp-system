-- MyHome Construction Company - Project Numbering Examples
-- Real-world construction company numbering patterns

-- MyHome Company Setup
INSERT INTO project_numbering_rules (entity_type, pattern, current_number, description, company_code) VALUES
-- MyHome specific patterns
('PROJECT', 'MH-{####}', 1001, 'MyHome project numbering', 'MH01'),
('WBS_ELEMENT', '{PROJECT}.{##}', 1, 'MyHome WBS structure', 'MH01'),
('ACTIVITY', '{WBS}.{###}', 1, 'MyHome activity numbering', 'MH01'),
('TASK', '{ACTIVITY}.T{##}', 1, 'MyHome task numbering', 'MH01')
ON CONFLICT DO NOTHING;

-- Alternative MyHome patterns (consultant can choose)
INSERT INTO industry_numbering_templates (industry_code, entity_type, pattern, description, is_default) VALUES
-- Option 1: Simple sequential
('MYHOME', 'PROJECT', 'MH-{####}', 'MyHome simple sequential', true),
('MYHOME', 'WBS_ELEMENT', '{PROJECT}.{##}', 'MyHome 2-level WBS', true),
('MYHOME', 'ACTIVITY', '{WBS}.{###}', 'MyHome activities', true),

-- Option 2: Project type based
('MYHOME', 'PROJECT', 'MH-{TYPE}-{###}', 'MyHome with project type', false),
('MYHOME', 'WBS_ELEMENT', '{PROJECT}.{PHASE##}', 'MyHome phase-based WBS', false),

-- Option 3: Location based
('MYHOME', 'PROJECT', 'MH-{CITY}-{###}', 'MyHome city-based numbering', false),
('MYHOME', 'WBS_ELEMENT', '{PROJECT}.{BUILDING##}', 'MyHome building-based WBS', false),

-- Option 4: Year-independent with category
('MYHOME', 'PROJECT', 'MH-{CATEGORY}-{###}', 'MyHome category-based', false)
ON CONFLICT DO NOTHING;

-- MYHOME CONSTRUCTION EXAMPLES:
-- =============================

-- OPTION 1: Simple Sequential Pattern
-- Pattern: MH-{####}
-- Projects:
-- MH-1001 - Luxury Villa Project
-- MH-1002 - Apartment Complex Phase 1
-- MH-1003 - Commercial Office Building
-- MH-1004 - Residential Township
-- MH-1005 - Shopping Mall Construction

-- WBS Structure for MH-1001 (Luxury Villa):
-- MH-1001                    (Project: Luxury Villa)
-- ├── MH-1001.01             (Site Preparation)
-- │   ├── MH-1001.01.001     (Land Survey)
-- │   ├── MH-1001.01.002     (Soil Testing)
-- │   ├── MH-1001.01.003     (Site Clearing)
-- │   └── MH-1001.01.004     (Temporary Facilities)
-- ├── MH-1001.02             (Foundation Work)
-- │   ├── MH-1001.02.001     (Excavation)
-- │   ├── MH-1001.02.002     (Footing Construction)
-- │   ├── MH-1001.02.003     (Foundation Walls)
-- │   └── MH-1001.02.004     (Waterproofing)
-- ├── MH-1001.03             (Structure)
-- │   ├── MH-1001.03.001     (Ground Floor Slab)
-- │   ├── MH-1001.03.002     (Columns & Beams)
-- │   ├── MH-1001.03.003     (First Floor Slab)
-- │   └── MH-1001.03.004     (Roof Structure)
-- ├── MH-1001.04             (Masonry Work)
-- │   ├── MH-1001.04.001     (External Walls)
-- │   ├── MH-1001.04.002     (Internal Walls)
-- │   └── MH-1001.04.003     (Boundary Walls)
-- ├── MH-1001.05             (Roofing)
-- │   ├── MH-1001.05.001     (Roof Waterproofing)
-- │   ├── MH-1001.05.002     (Tile Work)
-- │   └── MH-1001.05.003     (Gutters & Drainage)
-- ├── MH-1001.06             (MEP Works)
-- │   ├── MH-1001.06.001     (Electrical Installation)
-- │   ├── MH-1001.06.002     (Plumbing Installation)
-- │   └── MH-1001.06.003     (HVAC Installation)
-- ├── MH-1001.07             (Finishing Works)
-- │   ├── MH-1001.07.001     (Plastering)
-- │   ├── MH-1001.07.002     (Painting)
-- │   ├── MH-1001.07.003     (Flooring)
-- │   └── MH-1001.07.004     (Fixtures & Fittings)
-- └── MH-1001.08             (External Works)
--     ├── MH-1001.08.001     (Landscaping)
--     ├── MH-1001.08.002     (Driveway & Parking)
--     └── MH-1001.08.003     (Compound Wall)

-- OPTION 2: Project Type Based Pattern
-- Pattern: MH-{TYPE}-{###}
-- Projects:
-- MH-VILLA-001 - Luxury Villa Project
-- MH-APT-001 - Apartment Complex Phase 1
-- MH-COM-001 - Commercial Office Building
-- MH-TWN-001 - Residential Township
-- MH-MALL-001 - Shopping Mall Construction

-- OPTION 3: Location Based Pattern
-- Pattern: MH-{CITY}-{###}
-- Projects:
-- MH-BLR-001 - Bangalore Project 1
-- MH-HYD-001 - Hyderabad Project 1
-- MH-CHN-001 - Chennai Project 1
-- MH-MUM-001 - Mumbai Project 1
-- MH-DEL-001 - Delhi Project 1

-- OPTION 4: Category Based Pattern
-- Pattern: MH-{CATEGORY}-{###}
-- Projects:
-- MH-RES-001 - Residential Project 1
-- MH-COM-001 - Commercial Project 1
-- MH-IND-001 - Industrial Project 1
-- MH-INF-001 - Infrastructure Project 1

-- Activity Examples for MH-1001.02 (Foundation Work):
-- MH-1001.02.001.T01 - Mark foundation layout
-- MH-1001.02.001.T02 - Excavate to required depth
-- MH-1001.02.001.T03 - Level and compact base
-- MH-1001.02.002.T01 - Place reinforcement
-- MH-1001.02.002.T02 - Pour concrete
-- MH-1001.02.002.T03 - Cure concrete

-- INTEGRATION WITH EXTERNAL TOOLS:
-- ================================

-- Primavera P6 Integration:
-- Internal: MH-1001.02.001
-- External: P6_MH_1001_02_001

-- MS Project Integration:
-- Internal: MH-1001.02.001
-- External: 2.1 (Outline Number)

-- Tally ERP Integration:
-- Internal: MH-1001
-- External: MYHOME_1001

-- ADVANTAGES FOR MYHOME:
-- ======================
-- 1. Brand Recognition: "MH" prefix identifies MyHome projects
-- 2. Simple Sequential: Easy to remember and communicate
-- 3. Scalable: Can handle thousands of projects
-- 4. Flexible WBS: Supports different project types and sizes
-- 5. External Integration: Works with construction software
-- 6. Audit Trail: Clear project identification for accounting

-- RECOMMENDED PATTERN FOR MYHOME:
-- ===============================
-- Start with: MH-{####} (Simple Sequential)
-- Reason: Clean, professional, scalable
-- Future: Can add location/type prefixes if needed