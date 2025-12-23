from datetime import datetime
from enum import Enum
from typing import Optional
from dataclasses import dataclass
from decimal import Decimal

class POStatus(Enum):
    DRAFT = "draft"
    PENDING_APPROVAL = "pending_approval"
    APPROVED = "approved"
    SENT = "sent"
    ACKNOWLEDGED = "acknowledged"
    PARTIALLY_RECEIVED = "partially_received"
    FULLY_RECEIVED = "fully_received"
    CANCELLED = "cancelled"

class POType(Enum):
    STANDARD = "standard"
    BLANKET = "blanket"
    CONTRACT = "contract"
    EMERGENCY = "emergency"

@dataclass
class PurchaseOrder:
    id: str
    project_id: str
    po_number: str
    vendor_id: str
    quotation_id: Optional[str]
    po_type: POType
    status: POStatus
    issue_date: datetime
    delivery_date: datetime
    total_amount: Decimal
    tax_amount: Decimal
    grand_total: Decimal
    payment_terms: str
    delivery_terms: str
    created_by: str
    approved_by: Optional[str]
    approved_date: Optional[datetime]
    notes: Optional[str]
    created_at: datetime
    updated_at: datetime

@dataclass
class POLine:
    id: str
    po_id: str
    line_number: int
    boq_item_id: Optional[str]
    description: str
    specification: Optional[str]
    quantity: Decimal
    unit: str
    unit_rate: Decimal
    line_total: Decimal
    received_quantity: Decimal
    pending_quantity: Decimal
    delivery_date: datetime

@dataclass
class PORevision:
    id: str
    po_id: str
    revision_number: int
    revision_reason: str
    revised_by: str
    revised_date: datetime
    previous_total: Decimal
    new_total: Decimal
    approved_by: Optional[str]
    approved_date: Optional[datetime]

@dataclass
class POApproval:
    id: str
    po_id: str
    approver_id: str
    approval_level: int
    status: str
    comments: Optional[str]
    approved_date: datetime