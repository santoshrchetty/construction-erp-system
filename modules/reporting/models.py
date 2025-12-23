from datetime import datetime
from enum import Enum
from typing import Optional, List, Dict
from dataclasses import dataclass

class ReportType(Enum):
    PROJECT_DASHBOARD = "project_dashboard"
    COST_REPORT = "cost_report"
    PROGRESS_REPORT = "progress_report"
    RESOURCE_UTILIZATION = "resource_utilization"
    PROCUREMENT_REPORT = "procurement_report"
    TIMESHEET_SUMMARY = "timesheet_summary"
    VARIANCE_ANALYSIS = "variance_analysis"
    CUSTOM = "custom"

class ReportFormat(Enum):
    PDF = "pdf"
    EXCEL = "excel"
    CSV = "csv"
    JSON = "json"
    HTML = "html"

class ScheduleFrequency(Enum):
    DAILY = "daily"
    WEEKLY = "weekly"
    MONTHLY = "monthly"
    QUARTERLY = "quarterly"
    ON_DEMAND = "on_demand"

@dataclass
class Report:
    id: str
    name: str
    description: Optional[str]
    report_type: ReportType
    project_id: Optional[str]
    query_definition: str  # JSON string
    parameters: Dict[str, str]
    created_by: str
    is_public: bool
    created_at: datetime
    updated_at: datetime

@dataclass
class Dashboard:
    id: str
    name: str
    description: Optional[str]
    project_id: Optional[str]
    layout_config: str  # JSON string
    widgets: List[str]  # List of widget IDs
    created_by: str
    is_default: bool
    created_at: datetime
    updated_at: datetime

@dataclass
class KPI:
    id: str
    name: str
    description: str
    calculation_formula: str
    target_value: Optional[float]
    warning_threshold: Optional[float]
    critical_threshold: Optional[float]
    unit: str
    category: str
    is_active: bool
    created_at: datetime

@dataclass
class KPIValue:
    id: str
    kpi_id: str
    project_id: str
    measurement_date: datetime
    actual_value: float
    target_value: Optional[float]
    variance: Optional[float]
    status: str  # Green, Yellow, Red
    notes: Optional[str]
    calculated_at: datetime

@dataclass
class ReportSchedule:
    id: str
    report_id: str
    frequency: ScheduleFrequency
    recipients: List[str]  # Email addresses
    format: ReportFormat
    parameters: Dict[str, str]
    next_run_date: datetime
    is_active: bool
    created_by: str
    created_at: datetime

@dataclass
class ReportExecution:
    id: str
    report_id: str
    schedule_id: Optional[str]
    execution_date: datetime
    parameters_used: Dict[str, str]
    execution_time_seconds: float
    output_file_path: Optional[str]
    status: str  # Success, Failed, In Progress
    error_message: Optional[str]
    executed_by: str