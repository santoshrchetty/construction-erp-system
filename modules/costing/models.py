from datetime import datetime
from enum import Enum
from typing import Optional
from dataclasses import dataclass
from decimal import Decimal

class CostType(Enum):
    LABOR = "labor"
    MATERIAL = "material"
    EQUIPMENT = "equipment"
    SUBCONTRACTOR = "subcontractor"
    OVERHEAD = "overhead"
    OTHER = "other"

class CostStatus(Enum):
    PLANNED = "planned"
    COMMITTED = "committed"
    ACTUAL = "actual"
    ACCRUED = "accrued"

@dataclass
class CostCenter:
    id: str
    project_id: str
    code: str
    name: str
    description: Optional[str]
    parent_cost_center_id: Optional[str]
    budget_amount: Decimal
    is_active: bool
    created_at: datetime

@dataclass
class CostCode:
    id: str
    project_id: str
    code: str
    description: str
    cost_type: CostType
    is_active: bool
    created_at: datetime

@dataclass
class ActualCost:
    id: str
    project_id: str
    cost_center_id: str
    cost_code_id: str
    wbs_node_id: Optional[str]
    task_id: Optional[str]
    cost_type: CostType
    cost_status: CostStatus
    amount: Decimal
    cost_date: datetime
    reference_number: Optional[str]
    reference_type: Optional[str]  # Timesheet, PO, Invoice, etc.
    description: Optional[str]
    created_by: str
    created_at: datetime

@dataclass
class CostAllocation:
    id: str
    actual_cost_id: str
    allocation_percentage: Decimal
    allocated_amount: Decimal
    target_cost_center_id: str
    target_wbs_node_id: Optional[str]
    allocation_reason: str
    created_by: str
    created_at: datetime

@dataclass
class BudgetRevision:
    id: str
    project_id: str
    cost_center_id: str
    revision_number: int
    original_budget: Decimal
    revised_budget: Decimal
    revision_amount: Decimal
    revision_reason: str
    approved_by: str
    approved_date: datetime
    effective_date: datetime