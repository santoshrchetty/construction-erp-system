from datetime import datetime
from enum import Enum
from typing import Optional, List
from dataclasses import dataclass

class ProjectStatus(Enum):
    PLANNING = "planning"
    ACTIVE = "active"
    ON_HOLD = "on_hold"
    COMPLETED = "completed"
    CANCELLED = "cancelled"

class ProjectType(Enum):
    RESIDENTIAL = "residential"
    COMMERCIAL = "commercial"
    INFRASTRUCTURE = "infrastructure"
    INDUSTRIAL = "industrial"

@dataclass
class Project:
    id: str
    name: str
    code: str
    description: Optional[str]
    project_type: ProjectType
    status: ProjectStatus
    start_date: datetime
    planned_end_date: datetime
    actual_end_date: Optional[datetime]
    budget: float
    client_id: str
    project_manager_id: str
    location: str
    created_at: datetime
    updated_at: datetime

@dataclass
class ProjectPhase:
    id: str
    project_id: str
    name: str
    description: Optional[str]
    start_date: datetime
    end_date: datetime
    budget_allocation: float
    sequence_order: int
    status: ProjectStatus

@dataclass
class ProjectTeamMember:
    id: str
    project_id: str
    user_id: str
    role: str
    assigned_date: datetime
    hourly_rate: Optional[float]
    is_active: bool

@dataclass
class ProjectSettings:
    id: str
    project_id: str
    currency: str
    timezone: str
    working_days: List[int]  # 0-6 (Monday-Sunday)
    working_hours_per_day: float
    cost_codes_enabled: bool
    approval_workflows_enabled: bool