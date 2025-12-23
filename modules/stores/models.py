from datetime import datetime
from enum import Enum
from typing import Optional
from dataclasses import dataclass
from decimal import Decimal

class StockMovementType(Enum):
    RECEIPT = "receipt"
    ISSUE = "issue"
    RETURN = "return"
    TRANSFER = "transfer"
    ADJUSTMENT = "adjustment"
    WRITE_OFF = "write_off"

class ValuationMethod(Enum):
    FIFO = "fifo"
    LIFO = "lifo"
    WEIGHTED_AVERAGE = "weighted_average"
    STANDARD_COST = "standard_cost"

@dataclass
class Store:
    id: str
    project_id: str
    name: str
    code: str
    location: str
    store_keeper_id: str
    is_active: bool
    created_at: datetime
    updated_at: datetime

@dataclass
class StoreLocation:
    id: str
    store_id: str
    location_code: str
    description: str
    capacity: Optional[Decimal]
    current_utilization: Decimal
    is_active: bool

@dataclass
class StockItem:
    id: str
    item_code: str
    description: str
    category: str
    unit: str
    reorder_level: Decimal
    maximum_level: Decimal
    minimum_level: Decimal
    valuation_method: ValuationMethod
    is_active: bool
    created_at: datetime
    updated_at: datetime

@dataclass
class StockBalance:
    id: str
    store_id: str
    stock_item_id: str
    location_id: Optional[str]
    current_quantity: Decimal
    reserved_quantity: Decimal
    available_quantity: Decimal
    average_cost: Decimal
    total_value: Decimal
    last_movement_date: datetime

@dataclass
class StockMovement:
    id: str
    store_id: str
    stock_item_id: str
    movement_type: StockMovementType
    reference_number: str
    reference_type: str  # PO, Issue, Transfer, etc.
    quantity: Decimal
    unit_cost: Decimal
    total_cost: Decimal
    from_location_id: Optional[str]
    to_location_id: Optional[str]
    movement_date: datetime
    created_by: str
    notes: Optional[str]
    created_at: datetime