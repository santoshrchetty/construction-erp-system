from datetime import datetime
from enum import Enum
from typing import Optional
from dataclasses import dataclass
from decimal import Decimal

class ReceiptStatus(Enum):
    PENDING = "pending"
    RECEIVED = "received"
    PARTIALLY_RECEIVED = "partially_received"
    REJECTED = "rejected"
    RETURNED = "returned"

class QualityStatus(Enum):
    PENDING = "pending"
    PASSED = "passed"
    FAILED = "failed"
    CONDITIONAL = "conditional"

@dataclass
class GoodsReceipt:
    id: str
    project_id: str
    po_id: str
    receipt_number: str
    vendor_id: str
    receipt_date: datetime
    received_by: str
    status: ReceiptStatus
    delivery_note_number: Optional[str]
    vehicle_number: Optional[str]
    driver_name: Optional[str]
    total_received_value: Decimal
    notes: Optional[str]
    created_at: datetime
    updated_at: datetime

@dataclass
class ReceiptLine:
    id: str
    receipt_id: str
    po_line_id: str
    ordered_quantity: Decimal
    received_quantity: Decimal
    accepted_quantity: Decimal
    rejected_quantity: Decimal
    unit_rate: Decimal
    line_value: Decimal
    quality_status: QualityStatus
    storage_location: Optional[str]
    batch_number: Optional[str]
    expiry_date: Optional[datetime]
    notes: Optional[str]

@dataclass
class QualityCheck:
    id: str
    receipt_line_id: str
    inspector_id: str
    inspection_date: datetime
    quality_parameters: str  # JSON string
    test_results: str  # JSON string
    overall_status: QualityStatus
    remarks: Optional[str]
    certificate_number: Optional[str]

@dataclass
class MaterialRejection:
    id: str
    receipt_line_id: str
    rejected_quantity: Decimal
    rejection_reason: str
    rejection_date: datetime
    rejected_by: str
    return_required: bool
    vendor_notified: bool
    replacement_requested: bool