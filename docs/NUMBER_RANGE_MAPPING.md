# Number Range Mapping: SAP S/4HANA to Construction App

## Overview
This document maps SAP S/4HANA number range tables to the Construction App implementation.

## SAP Tables

### TNRO - Number Range Objects
Defines number range objects (e.g., MATL for materials, BELNR for documents).

### NRIV - Number Range Intervals
Stores actual number range intervals with from/to numbers and current level.

## Construction App Tables

### document_number_ranges
Main table storing number range configurations.

**Key Differences from SAP:**
- Combined TNRO + NRIV into single table
- Added `company_code` for multi-company support
- Added `prefix`, `suffix`, `padding_length` for formatting
- Added `warning_threshold` for proactive alerts
- Uses `document_type` instead of SAP's `OBJECT`

### number_range_alerts
Custom table for monitoring number range exhaustion (not in SAP standard).

### number_range_usage_history
Audit trail for number assignments (not in SAP standard).

## Document Type Mapping

| SAP Object | SAP Description | Construction App Type |
|------------|----------------|----------------------|
| MATL | Material Number | MATERIAL |
| BELNR | Accounting Document | FI_DOCUMENT |
| BANFN | Purchase Requisition | PR |
| EBELN | Purchase Order | PO |
| MBLNR | Material Document | GR |
| BELNR_INV | Invoice Document | INVOICE |
| PSPNR | Project Definition | PROJECT |
| AUFNR | Internal Order | ORDER |

## Key Enhancements Over SAP

1. **Alert System**: Proactive monitoring with configurable thresholds
2. **Usage History**: Complete audit trail of number assignments
3. **Flexible Formatting**: Prefix, suffix, and padding configuration
4. **Company Code Integration**: Multi-company support at number range level
5. **Real-time Statistics**: Dashboard for monitoring utilization
