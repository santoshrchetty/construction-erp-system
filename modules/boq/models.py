from datetime import datetime
from enum import Enum
from typing import Optional, Dict
from dataclasses import dataclass
from decimal import Decimal

class BOQStatus(Enum):
    DRAFT = "draft"
    APPROVED = "approved"
    REVISED = "revised"
    FINAL = "final"

class UnitType(Enum):
    LENGTH = "length"
    AREA = "area"
    VOLUME = "volume"
    WEIGHT = "weight"
    COUNT = "count"
    LUMP_SUM = "lump_sum"

@dataclass
class BOQItem:
    id: str
    project_id: str
    wbs_node_id: Optional[str]
    item_code: str
    description: str
    specification: Optional[str]
    unit: str
    unit_type: UnitType
    quantity: Decimal
    rate: Decimal
    amount: Decimal
    category_id: str
    trade_id: Optional[str]
    is_provisional: bool
    created_at: datetime
    updated_at: datetime

@dataclass
class BOQCategory:
    id: str
    project_id: str
    name: str
    code: str
    description: Optional[str]
    parent_category_id: Optional[str]
    sequence_order: int

@dataclass
class BOQRevision:
    id: str
    project_id: str
    revision_number: str
    description: str
    status: BOQStatus
    total_amount: Decimal
    approved_by: Optional[str]
    approved_date: Optional[datetime]
    created_by: str
    created_at: datetime

@dataclass
class RateCard:
    id: str
    project_id: str
    item_code: str
    description: str
    unit: str
    base_rate: Decimal
    location_factor: Decimal
    effective_date: datetime
    expiry_date: Optional[datetime]
    supplier_id: Optional[str]