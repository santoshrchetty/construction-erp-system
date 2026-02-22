-- ALL FIELDS FOR DOCUMENT CREATE

-- REQUIRED FIELDS
tenant_id UUID                    -- Auto-set to tenant
title VARCHAR(500)               -- Document title
document_type VARCHAR(3)         -- DRW, SPE, CNT, RFI, SUB, CHG, DOC
created_by UUID                  -- User ID creating the document

-- AUTO-GENERATED FIELDS
id UUID                          -- Auto-generated primary key
document_number VARCHAR(100)     -- Auto-generated: DRW-26-0001
part_number VARCHAR(100)         -- Auto-generated based on hierarchy
document_level INTEGER           -- Auto-calculated based on parent
created_at TIMESTAMP             -- Auto-set to NOW()
updated_at TIMESTAMP             -- Auto-set to NOW()

-- OPTIONAL CORE FIELDS
description TEXT                 -- Document description
status VARCHAR(50)               -- DRAFT, UNDER_REVIEW, APPROVED, REJECTED, SUPERSEDED (default: DRAFT)
version VARCHAR(20)              -- Version number (default: 1.0)
revision VARCHAR(10)             -- Revision letter/number

-- HIERARCHY FIELDS
parent_document_id UUID          -- Link to parent document (NULL for root)

-- PROJECT LINKING FIELDS
project_id UUID                  -- Link to projects table
project_code VARCHAR(100)        -- Project code
project_name VARCHAR(200)        -- Project name
wbs_element VARCHAR(100)         -- Work breakdown structure

-- OBJECT LINKING FIELDS
contract_number VARCHAR(100)     -- Contract reference
material_number VARCHAR(100)     -- Material code
material_description VARCHAR(500) -- Material description
vendor_name VARCHAR(200)         -- Vendor name
equipment_number VARCHAR(100)    -- Equipment reference
cost_center VARCHAR(50)          -- Cost center code

-- EXAMPLE CREATE PAYLOAD:
{
  "title": "Master Layout Drawing",
  "description": "Overall site layout showing all major components",
  "document_type": "DRW",
  "status": "DRAFT",
  "version": "1.0",
  "revision": "A",
  "parent_document_id": null,
  "project_code": "PROJ-001",
  "project_name": "Construction Project Alpha",
  "wbs_element": "WBS-001.001",
  "material_number": "MAT-12345",
  "material_description": "Concrete Grade 30",
  "vendor_name": "ABC Construction Supply",
  "contract_number": "CNT-2024-001",
  "cost_center": "CC-100",
  "created_by": "user-uuid-here"
}