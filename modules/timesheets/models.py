from datetime import datetime, date
from enum import Enum
from typing import Optional
from dataclasses import dataclass

class TimesheetStatus(Enum):
    DRAFT = "draft"
    SUBMITTED = "submitted"
    APPROVED = "approved"
    REJECTED = "rejected"

class EntryType(Enum):
    REGULAR = "regular"
    OVERTIME = "overtime"
    HOLIDAY = "holiday"
    SICK_LEAVE = "sick_leave"
    VACATION = "vacation"

@dataclass
class Timesheet:
    id: str
    user_id: str
    project_id: str
    week_ending_date: date
    status: TimesheetStatus
    total_hours: float
    total_overtime_hours: float
    submitted_date: Optional[datetime]
    approved_by: Optional[str]
    approved_date: Optional[datetime]
    rejection_reason: Optional[str]
    created_at: datetime
    updated_at: datetime

@dataclass
class TimesheetEntry:
    id: str
    timesheet_id: str
    task_id: Optional[str]
    wbs_node_id: Optional[str]
    entry_date: date
    entry_type: EntryType
    hours: float
    description: Optional[str]
    billable: bool
    cost_code: Optional[str]
    created_at: datetime

@dataclass
class LaborRate:
    id: str
    user_id: str
    project_id: Optional[str]
    role: str
    regular_rate: float
    overtime_rate: float
    effective_date: datetime
    expiry_date: Optional[datetime]
    is_active: bool

@dataclass
class TimesheetApproval:
    id: str
    timesheet_id: str
    approver_id: str
    approval_level: int
    status: TimesheetStatus
    comments: Optional[str]
    approved_date: datetime