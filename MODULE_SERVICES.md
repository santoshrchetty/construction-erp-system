# Construction Management SaaS - Module Services Architecture

## Service Layer Design Pattern

Each module implements a consistent service layer pattern with the following components:

### Core Service Classes per Module:

#### 1. Projects Module Services
- **ProjectService**: CRUD operations, project lifecycle management
- **ProjectTeamService**: Team member assignment and role management
- **ProjectSettingsService**: Configuration and preferences management

#### 2. WBS Module Services
- **WBSService**: Tree structure operations, node management
- **WBSTemplateService**: Template creation and application
- **WBSValidationService**: Structure validation and integrity checks

#### 3. BOQ Module Services
- **BOQService**: Item management, quantity calculations
- **BOQRevisionService**: Version control and change tracking
- **RateCardService**: Pricing and rate management

#### 4. Tasks Module Services
- **TaskService**: Task CRUD, status management
- **TaskDependencyService**: Dependency management, critical path calculation
- **TaskAssignmentService**: Resource allocation and workload balancing

#### 5. Timesheets Module Services
- **TimesheetService**: Time entry and validation
- **TimesheetApprovalService**: Multi-level approval workflows
- **LaborCostService**: Cost calculations and rate applications

#### 6. Procurement Module Services
- **VendorService**: Vendor management and qualification
- **RFQService**: RFQ creation, distribution, and evaluation
- **QuotationService**: Quote comparison and analysis

#### 7. PO Tracking Module Services
- **PurchaseOrderService**: PO lifecycle management
- **POApprovalService**: Approval workflow management
- **POTrackingService**: Delivery tracking and status updates

#### 8. Goods Receipt Module Services
- **GoodsReceiptService**: Receipt processing and validation
- **QualityControlService**: Inspection and quality management
- **MaterialRejectionService**: Rejection handling and vendor communication

#### 9. Stores Module Services
- **InventoryService**: Stock level management and tracking
- **StockMovementService**: Movement processing and validation
- **StoreLocationService**: Location management and optimization

#### 10. Costing Module Services
- **CostCaptureService**: Actual cost recording and validation
- **CostAllocationService**: Cost distribution and allocation rules
- **BudgetService**: Budget management and revision control

#### 11. Cost-to-Complete Module Services
- **ForecastingService**: Cost projection and EVM calculations
- **VarianceAnalysisService**: Variance identification and analysis
- **ScenarioModelingService**: What-if analysis and risk modeling

#### 12. Progress Module Services
- **ProgressMeasurementService**: Progress tracking and validation
- **MilestoneService**: Milestone management and tracking
- **ProgressReportingService**: Progress report generation

#### 13. Reporting Module Services
- **ReportGenerationService**: Dynamic report creation
- **DashboardService**: Dashboard configuration and data aggregation
- **KPIService**: KPI calculation and monitoring
- **ScheduledReportService**: Automated report distribution

## Inter-Service Communication Patterns

### Event-Driven Communication
```python
# Example: When a task is completed, notify multiple services
class TaskService:
    def complete_task(self, task_id: str):
        # Update task status
        task = self.update_task_status(task_id, TaskStatus.COMPLETED)
        
        # Publish event
        self.event_bus.publish(TaskCompletedEvent(
            task_id=task_id,
            project_id=task.project_id,
            completion_date=datetime.now()
        ))

# Subscribers
class ProgressService:
    @event_handler(TaskCompletedEvent)
    def handle_task_completed(self, event: TaskCompletedEvent):
        self.update_progress_measurement(event.task_id)

class CostingService:
    @event_handler(TaskCompletedEvent)
    def handle_task_completed(self, event: TaskCompletedEvent):
        self.finalize_task_costs(event.task_id)
```

### Service Dependencies
- **Projects** → Foundation for all other services
- **WBS** → Used by Tasks, BOQ, Progress, Costing
- **BOQ** → Feeds Procurement, PO Tracking, Costing
- **Tasks** → Connects to Timesheets, Progress
- **Procurement** → Links to PO Tracking, Goods Receipt
- **All Services** → Feed into Reporting and Analytics

### Data Consistency Patterns
- **Eventual Consistency**: For cross-module updates
- **Strong Consistency**: Within module boundaries
- **Compensating Transactions**: For complex multi-module operations

### Service Integration Points
1. **Master Data Sync**: Projects, WBS, BOQ changes propagate
2. **Cost Aggregation**: All cost-related modules feed costing
3. **Progress Rollup**: Task and milestone progress aggregates up WBS
4. **Reporting Data**: All modules provide data to reporting engine