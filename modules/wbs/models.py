from datetime import datetime
from enum import Enum
from typing import Optional, List
from dataclasses import dataclass

class WBSNodeType(Enum):
    PROJECT = "project"
    PHASE = "phase"
    DELIVERABLE = "deliverable"
    WORK_PACKAGE = "work_package"

@dataclass
class WBSNode:
    id: str
    project_id: str
    parent_id: Optional[str]
    code: str
    name: str
    description: Optional[str]
    node_type: WBSNodeType
    level: int
    sequence_order: int
    budget_allocation: float
    planned_hours: float
    responsible_user_id: Optional[str]
    start_date: Optional[datetime]
    end_date: Optional[datetime]
    is_active: bool
    created_at: datetime
    updated_at: datetime

@dataclass
class WBSTemplate:
    id: str
    name: str
    description: Optional[str]
    project_type: str
    is_standard: bool
    created_by: str
    created_at: datetime

@dataclass
class WBSTemplateNode:
    id: str
    template_id: str
    parent_id: Optional[str]
    code: str
    name: str
    description: Optional[str]
    node_type: WBSNodeType
    level: int
    sequence_order: int
    estimated_hours: float
    is_mandatory: bool