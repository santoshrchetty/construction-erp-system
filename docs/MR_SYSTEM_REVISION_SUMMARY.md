# Material Request System Revision Summary

## Overview
Updated Material Request system to support PRODUCTION and QUALITY MR types with line-item level control fields.

## Changes Made

### 1. Database Schema Updates
- **File**: `database/material_request_schema.sql`
- **Changes**: Added PRODUCTION and QUALITY to mr_type enum
- **File**: `database/add_line_item_fields.sql` (NEW)
- **Changes**: Added line-item level fields to material_request_items table

### 2. Type Definitions Updates
- **File**: `types/material-request-database.ts`
- **Changes**: 
  - Added PRODUCTION and QUALITY to mr_type unions
  - Added line-item level fields to material_request_items types
  - Updated status enums to include all workflow states

### 3. Account Assignment Mapping
- **File**: `database/add_production_quality_mr_types.sql`
- **Changes**: Added OP (Production Order) and OQ (Quality Order) mappings

### 4. Documentation Updates
- **File**: `docs/MR_ACCOUNT_ASSIGNMENT_TYPES.md`
- **Changes**: 
  - Added PRODUCTION (OP) and QUALITY (OQ) account assignment categories
  - Updated distribution percentages
  - Added examples and schemas

## New Line-Item Level Fields
The following fields were moved from header to line-item level for better granular control:

- `status` - DRAFT/SUBMITTED/APPROVED/REJECTED/CONVERTED/FULFILLED/CANCELLED
- `priority` - LOW/MEDIUM/HIGH/URGENT
- `requested_by`, `requested_date`, `required_date`
- `company_code`, `plant_code`, `department_code`
- `delivery_location`, `purpose`, `justification`, `notes`
- `total_value`, `currency`
- `approval_workflow_id`, `approved_by`, `approved_date`

## New MR Types

### PRODUCTION MR Type
- **Account Assignment**: OP (Production Order)
- **Usage**: Materials for manufacturing and production
- **Fields**: production_order_number, operation_number, work_center

### QUALITY MR Type
- **Account Assignment**: OQ (Quality Order)  
- **Usage**: Materials for quality inspection and testing
- **Fields**: quality_order_number, inspection_lot, quality_level

## Impact
- Enhanced flexibility with line-item level control
- Support for manufacturing and quality processes
- Maintains backward compatibility
- Follows ERP best practices for account assignment

## Status: ✅ COMPLETE
All reference documents and schemas have been updated to reflect the new MR system architecture.