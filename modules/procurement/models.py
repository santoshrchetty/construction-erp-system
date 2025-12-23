from datetime import datetime
from enum import Enum
from typing import Optional, List
from dataclasses import dataclass
from decimal import Decimal

class VendorStatus(Enum):
    ACTIVE = "active"
    INACTIVE = "inactive"
    BLACKLISTED = "blacklisted"

class RFQStatus(Enum):
    DRAFT = "draft"
    SENT = "sent"
    RESPONSES_RECEIVED = "responses_received"
    EVALUATED = "evaluated"
    AWARDED = "awarded"
    CANCELLED = "cancelled"

class QuotationStatus(Enum):
    RECEIVED = "received"
    UNDER_REVIEW = "under_review"
    ACCEPTED = "accepted"
    REJECTED = "rejected"

@dataclass
class Vendor:
    id: str
    name: str
    code: str
    contact_person: str
    email: str
    phone: str
    address: str
    tax_id: str
    status: VendorStatus
    credit_limit: Decimal
    payment_terms: str
    specializations: List[str]
    rating: float
    created_at: datetime
    updated_at: datetime

@dataclass
class RFQ:
    id: str
    project_id: str
    rfq_number: str
    title: str
    description: Optional[str]
    issue_date: datetime
    response_deadline: datetime
    status: RFQStatus
    created_by: str
    total_estimated_value: Decimal
    created_at: datetime

@dataclass
class RFQItem:
    id: str
    rfq_id: str
    boq_item_id: Optional[str]
    description: str
    specification: Optional[str]
    quantity: Decimal
    unit: str
    estimated_rate: Optional[Decimal]
    delivery_date: Optional[datetime]

@dataclass
class Quotation:
    id: str
    rfq_id: str
    vendor_id: str
    quotation_number: str
    received_date: datetime
    valid_until: datetime
    status: QuotationStatus
    total_amount: Decimal
    payment_terms: str
    delivery_terms: str
    notes: Optional[str]

@dataclass
class QuotationItem:
    id: str
    quotation_id: str
    rfq_item_id: str
    quoted_rate: Decimal
    quoted_amount: Decimal
    delivery_date: datetime
    warranty_period: Optional[str]
    notes: Optional[str]