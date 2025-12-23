from datetime import datetime
from enum import Enum
from typing import Optional, List
from dataclasses import dataclass

class TaskStatus(Enum):
    NOT_STARTED = "not_started"
    IN_PROGRESS = "in_progress"
    ON_HOLD = "on_hold"
    COMPLETED = "completed"
    CANCELLED = "cancelled"

class TaskPriority(Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"

class DependencyType(Enum):
    FINISH_TO_START = "finish_to_start"
    START_TO_START = "start_to_start"
    FINISH_TO_FINISH = "finish_to_finish"
    START_TO_FINISH = "start_to_finish"

@dataclass
class Task:
    id: str
    project_id: str
    wbs_node_id: Optional[str]
    name: str
    description: Optional[str]
    status: TaskStatus
    priority: TaskPriority
    planned_start_date: datetime
    planned_end_date: datetime
    actual_start_date: Optional[datetime]
    actual_end_date: Optional[datetime]
    planned_hours: float
    actual_hours: float
    progress_percentage: float
    assigned_to: Optional[str]
    created_by: str
    created_at: datetime
    updated_at: datetime

@dataclass
class TaskDependency:
    id: str
    predecessor_task_id: str
    successor_task_id: str
    dependency_type: DependencyType
    lag_days: int
    created_at: datetime

@dataclass
class TaskAssignment:
    id: str
    task_id: str
    user_id: str
    role: str
    allocated_hours: float
    hourly_rate: Optional[float]
    assigned_date: datetime
    is_active: bool

@dataclass
class TaskComment:
    id: str
    task_id: str
    user_id: str
    comment: str
    created_at: datetime