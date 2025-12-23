from datetime import datetime
from enum import Enum
from typing import Optional, List
from dataclasses import dataclass
from decimal import Decimal

class ProgressMethod(Enum):
    PERCENTAGE_COMPLETE = "percentage_complete"
    MILESTONE_WEIGHTED = "milestone_weighted"
    UNITS_COMPLETE = "units_complete"
    COST_RATIO = "cost_ratio"
    PHYSICAL_MEASUREMENT = "physical_measurement"

class MilestoneStatus(Enum):
    NOT_STARTED = "not_started"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    DELAYED = "delayed"

@dataclass
class ProgressMeasurement:
    id: str
    project_id: str
    wbs_node_id: Optional[str]
    task_id: Optional[str]
    measurement_date: datetime
    progress_method: ProgressMethod
    planned_progress: Decimal
    actual_progress: Decimal
    progress_variance: Decimal
    units_planned: Optional[Decimal]
    units_completed: Optional[Decimal]
    measured_by: str
    verified_by: Optional[str]
    notes: Optional[str]
    created_at: datetime

@dataclass
class Milestone:
    id: str
    project_id: str
    wbs_node_id: Optional[str]
    name: str
    description: Optional[str]
    planned_date: datetime
    actual_date: Optional[datetime]
    status: MilestoneStatus
    weight: Decimal
    is_critical: bool
    responsible_person: str
    created_at: datetime
    updated_at: datetime

@dataclass
class ProgressPhoto:
    id: str
    project_id: str
    wbs_node_id: Optional[str]
    task_id: Optional[str]
    photo_url: str
    caption: str
    taken_date: datetime
    taken_by: str
    location_coordinates: Optional[str]
    tags: List[str]
    created_at: datetime

@dataclass
class WeightedProgress:
    id: str
    project_id: str
    wbs_node_id: str
    calculation_date: datetime
    total_weight: Decimal
    completed_weight: Decimal
    weighted_progress_percentage: Decimal
    child_progress_data: str  # JSON string of child node progress
    calculated_by: str
    created_at: datetime

@dataclass
class ProgressReport:
    id: str
    project_id: str
    report_date: datetime
    reporting_period_start: datetime
    reporting_period_end: datetime
    overall_progress: Decimal
    planned_progress: Decimal
    progress_variance: Decimal
    critical_path_progress: Decimal
    key_achievements: str
    issues_and_risks: str
    next_period_plan: str
    created_by: str
    created_at: datetime