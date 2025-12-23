from datetime import datetime
from enum import Enum
from typing import Optional
from dataclasses import dataclass
from decimal import Decimal

class ForecastMethod(Enum):
    BOTTOM_UP = "bottom_up"
    TOP_DOWN = "top_down"
    PARAMETRIC = "parametric"
    THREE_POINT = "three_point"
    EARNED_VALUE = "earned_value"

class VarianceType(Enum):
    COST_VARIANCE = "cost_variance"
    SCHEDULE_VARIANCE = "schedule_variance"
    SCOPE_VARIANCE = "scope_variance"

@dataclass
class CostForecast:
    id: str
    project_id: str
    wbs_node_id: Optional[str]
    cost_center_id: Optional[str]
    forecast_date: datetime
    forecast_method: ForecastMethod
    budget_at_completion: Decimal
    actual_cost_to_date: Decimal
    committed_costs: Decimal
    estimate_to_complete: Decimal
    estimate_at_completion: Decimal
    variance_at_completion: Decimal
    confidence_level: float
    created_by: str
    notes: Optional[str]
    created_at: datetime

@dataclass
class EarnedValueMetrics:
    id: str
    project_id: str
    wbs_node_id: Optional[str]
    measurement_date: datetime
    planned_value: Decimal
    earned_value: Decimal
    actual_cost: Decimal
    budget_at_completion: Decimal
    cost_performance_index: Decimal
    schedule_performance_index: Decimal
    cost_variance: Decimal
    schedule_variance: Decimal
    estimate_at_completion: Decimal
    estimate_to_complete: Decimal
    to_complete_performance_index: Decimal

@dataclass
class VarianceAnalysis:
    id: str
    project_id: str
    analysis_date: datetime
    variance_type: VarianceType
    variance_amount: Decimal
    variance_percentage: Decimal
    root_cause: str
    impact_assessment: str
    corrective_action: str
    responsible_person: str
    target_resolution_date: datetime
    status: str
    created_by: str

@dataclass
class CostScenario:
    id: str
    project_id: str
    scenario_name: str
    description: str
    base_forecast_id: str
    risk_adjustment: Decimal
    opportunity_adjustment: Decimal
    contingency_percentage: Decimal
    adjusted_estimate_at_completion: Decimal
    probability: float
    created_by: str
    created_at: datetime