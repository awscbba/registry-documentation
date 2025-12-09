# Design Document

## Overview

The AI Project Lifecycle Manager is a multi-agent system built on AWS Strands Agents and Amazon Agent Core that provides intelligent, automated management of project lifecycles in the AWS Community Builder registry platform. The system employs four specialized agents orchestrated by Agent Core to handle status management, anomaly detection, analytics, and notifications. Each agent leverages Claude 3.5 Sonnet through Bedrock Runtime and can call registered tools to interact with the system.

The architecture follows a coordinated multi-agent pattern where an orchestrator manages agent execution, context passing, and conversation memory. This design enables separation of concerns, parallel execution where appropriate, and intelligent decision-making that goes beyond simple rule-based automation.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    EventBridge Schedule                      │
│                   (Hourly or Daily Trigger)                  │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              Lambda: Orchestrator Handler                    │
│  - Initializes Agent Core orchestrator                      │
│  - Creates session ID                                       │
│  - Invokes agent workflow                                   │
│  - Returns execution summary                                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              Amazon Agent Core Orchestrator                  │
│  - Manages agent lifecycle                                  │
│  - Coordinates agent execution (sequential/parallel)        │
│  - Passes context between agents                            │
│  - Maintains conversation memory in DynamoDB                │
└─────┬───────────┬────────────┬──────────────┬──────────────┘
      │           │            │              │
      ▼           ▼            ▼              ▼
┌──────────┐ ┌─────────┐ ┌──────────┐ ┌────────────┐
│ Status   │ │ Anomaly │ │Analytics │ │Notification│
│ Manager  │ │Detector │ │ Agent    │ │  Agent     │
│ Agent    │ │ Agent   │ │          │ │            │
└────┬─────┘ └────┬────┘ └────┬─────┘ └─────┬──────┘
     │            │           │             │
     └────────────┴───────────┴─────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                    Tool Functions                            │
│  - get_projects_needing_update()                            │
│  - update_project_status()                                  │
│  - get_project_metrics()                                    │
│  - analyze_project_performance()                            │
│  - send_notification()                                      │
│  - create_audit_log()                                       │
└─────────────────────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                  AWS Services Layer                          │
│  - DynamoDB (Projects, Audit Logs, Conversation Memory)    │
│  - SES (Email Notifications)                                │
│  - CloudWatch (Metrics & Logs)                              │
│  - X-Ray (Distributed Tracing)                              │
└─────────────────────────────────────────────────────────────┘
```

### Agent Execution Flow

```
Session Start (session_id: "daily-check-2025-12-08T10:00:00")
    │
    ▼
StatusManager Agent
    │ Input: "Check all projects for 2025-12-08 and update statuses"
    │ Tools: get_projects_needing_update(), update_project_status()
    │ Output: { updated_projects: [...], reasoning: "..." }
    │
    ▼
AnomalyDetector Agent
    │ Input: "Analyze all active projects for anomalies"
    │ Context: StatusManager results
    │ Tools: get_project_metrics(), get_historical_patterns()
    │ Output: { anomalies: [...], severity: "...", recommendations: [...] }
    │
    ▼
AnalyticsAgent
    │ Input: "Generate insights based on recent updates"
    │ Context: StatusManager + AnomalyDetector results
    │ Tools: analyze_project_performance(), get_similar_projects()
    │ Output: { insights: [...], recommendations: [...] }
    │
    ▼
NotificationAgent
    │ Input: "Send daily summary to admins"
    │ Context: All previous agent results
    │ Tools: send_notification(), format_message()
    │ Output: { notifications_sent: 3, recipients: [...] }
    │
    ▼
Session End (stored in DynamoDB conversation memory)
```

## Components and Interfaces

### 1. StatusManager Agent

**Responsibility:** Manages project lifecycle and status transitions

**Agent Configuration:**
```python
{
    "name": "StatusManager",
    "model_id": "anthropic.claude-3-5-sonnet-20241022-v2:0",
    "instruction": """
    You are a project status management agent. Your role is to:
    1. Monitor project end dates and update statuses accordingly
    2. Ensure status transitions are valid and logical
    3. Document all changes with clear reasoning
    4. Handle edge cases like pending registrations after end dates
    
    When updating a project status:
    - Always check the current date against end_date
    - Verify the current status before updating
    - Provide clear reasoning for the change
    - Consider participant counts and registration status
    """,
    "tools": [
        "get_projects_needing_update",
        "update_project_status",
        "validate_status_transition",
        "create_audit_log"
    ]
}
```

**Tools:**
- `get_projects_needing_update(current_date: str) -> List[Project]`
- `update_project_status(project_id: str, new_status: str, reason: str) -> bool`
- `validate_status_transition(current_status: str, new_status: str) -> bool`
- `create_audit_log(project_id: str, action: str, details: dict) -> None`

### 2. AnomalyDetector Agent

**Responsibility:** Identifies unusual patterns and potential issues

**Agent Configuration:**
```python
{
    "name": "AnomalyDetector",
    "model_id": "anthropic.claude-3-5-sonnet-20241022-v2:0",
    "instruction": """
    You are an anomaly detection agent. Your role is to:
    1. Identify unusual patterns in project data
    2. Detect low participation rates compared to historical averages
    3. Flag data integrity issues (e.g., end_date before start_date)
    4. Assign severity levels to anomalies
    5. Provide actionable recommendations
    
    When analyzing projects:
    - Compare current metrics to historical baselines
    - Consider project type and context
    - Prioritize anomalies by severity and impact
    - Suggest specific remediation actions
    """,
    "tools": [
        "get_project_metrics",
        "get_historical_patterns",
        "calculate_participation_rate",
        "compare_to_baseline"
    ]
}
```

**Tools:**
- `get_project_metrics(project_id: str) -> dict`
- `get_historical_patterns(project_type: str, metric: str) -> dict`
- `calculate_participation_rate(project_id: str) -> float`
- `compare_to_baseline(current_value: float, baseline: dict) -> dict`

### 3. AnalyticsAgent

**Responsibility:** Provides insights and recommendations

**Agent Configuration:**
```python
{
    "name": "AnalyticsAgent",
    "model_id": "anthropic.claude-3-5-sonnet-20241022-v2:0",
    "instruction": """
    You are an analytics agent. Your role is to:
    1. Analyze project performance against historical data
    2. Identify success patterns and trends
    3. Generate actionable recommendations for future projects
    4. Provide data-driven insights with confidence levels
    
    When generating insights:
    - Base recommendations on statistical analysis
    - Include supporting data and confidence levels
    - Consider multiple factors (timing, capacity, type, etc.)
    - Prioritize high-impact recommendations
    """,
    "tools": [
        "analyze_project_performance",
        "get_similar_projects",
        "calculate_success_metrics",
        "generate_recommendations"
    ]
}
```

**Tools:**
- `analyze_project_performance(project_id: str) -> dict`
- `get_similar_projects(project_id: str, limit: int) -> List[Project]`
- `calculate_success_metrics(project_ids: List[str]) -> dict`
- `generate_recommendations(analysis: dict) -> List[dict]`

### 4. NotificationAgent

**Responsibility:** Handles all communications

**Agent Configuration:**
```python
{
    "name": "NotificationAgent",
    "model_id": "anthropic.claude-3-5-sonnet-20241022-v2:0",
    "instruction": """
    You are a notification agent. Your role is to:
    1. Send appropriate notifications to admins and participants
    2. Format messages based on recipient role and notification type
    3. Handle notification delivery failures with retries
    4. Generate daily summary reports
    
    When sending notifications:
    - Use appropriate tone and formatting for recipient
    - Include relevant context and action items
    - Prioritize critical notifications
    - Track delivery status
    """,
    "tools": [
        "send_email",
        "send_sms",
        "create_notification",
        "format_message"
    ]
}
```

**Tools:**
- `send_email(to: str, subject: str, body: str, template: str) -> bool`
- `send_sms(to: str, message: str) -> bool`
- `create_notification(user_id: str, type: str, content: dict) -> None`
- `format_message(template: str, context: dict) -> str`

### 5. Agent Core Orchestrator

**Responsibility:** Coordinates all agents and manages execution

**Interface:**
```python
class AgentOrchestrator:
    def __init__(
        self,
        agents: List[Agent],
        memory: ConversationMemory,
        coordination_strategy: str = "sequential"
    ):
        """
        Initialize orchestrator with agents and memory
        
        Args:
            agents: List of Strands agents to coordinate
            memory: Conversation memory instance (DynamoDB-backed)
            coordination_strategy: "sequential" or "parallel"
        """
        
    async def invoke_agent(
        self,
        agent_name: str,
        session_id: str,
        input_text: str,
        context: Optional[dict] = None
    ) -> dict:
        """
        Invoke a specific agent with input and context
        
        Returns:
            Agent response including output, tool calls, and reasoning
        """
        
    async def execute_workflow(
        self,
        session_id: str,
        workflow_definition: dict
    ) -> dict:
        """
        Execute a complete multi-agent workflow
        
        Returns:
            Aggregated results from all agents
        """
        
    def get_conversation_history(
        self,
        session_id: str
    ) -> List[dict]:
        """
        Retrieve conversation history for a session
        """
```

## Data Models

### Project Model
```python
@dataclass
class Project:
    id: str
    name: str
    status: str  # pending, active, ongoing, completed, cancelled
    start_date: date
    end_date: date
    registration_deadline: date
    current_participants: int
    max_participants: int
    project_type: str
    created_at: datetime
    updated_at: datetime
```

### Agent Session Model
```python
@dataclass
class AgentSession:
    session_id: str
    timestamp: datetime
    agents_invoked: List[str]
    projects_processed: int
    projects_updated: int
    anomalies_detected: int
    recommendations_generated: int
    notifications_sent: int
    execution_time_ms: int
    status: str  # success, partial_failure, failure
```

### Audit Log Model
```python
@dataclass
class AuditLog:
    id: str
    project_id: str
    session_id: str
    agent_name: str
    action: str
    old_value: Optional[str]
    new_value: str
    reasoning: str
    timestamp: datetime
```

### Anomaly Model
```python
@dataclass
class Anomaly:
    id: str
    project_id: str
    session_id: str
    anomaly_type: str  # low_participation, data_integrity, etc.
    severity: str  # low, medium, high
    description: str
    metrics: dict
    recommendations: List[str]
    detected_at: datetime
```

### Tool Call Model
```python
@dataclass
class ToolCall:
    tool_name: str
    parameters: dict
    result: Any
    success: bool
    error: Optional[str]
    duration_ms: int
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*


### Property Reflection

Before defining properties, I've reviewed the prework analysis to eliminate redundancy:

- Properties 1.1 and 1.4 both relate to status updates but test different aspects (individual correctness vs. completeness)
- Properties 4.1, 4.2, and 4.3 all test notification sending but for different triggers - these should remain separate
- Properties 6.1 and 6.3 both relate to storage but test different aspects (that it happens vs. what fields are stored)
- Properties 7.3 and 7.5 both relate to error handling but at different levels (validation vs. retry)
- Properties 8.1 and 8.2 both track metrics but for different components (agents vs. tools)

All properties provide unique validation value and should be retained.

### Status Management Properties

Property 1: Expired projects are completed
*For any* project where the current date is after the end date and status is not "completed", the system should update the status to "completed"
**Validates: Requirements 1.1**

Property 2: Status updates create audit logs
*For any* automatic status update, an audit log entry should be created with the project ID, old status, new status, and reasoning
**Validates: Requirements 1.2**

Property 3: Status transitions are validated
*For any* status update attempt, only valid transitions according to the lifecycle rules should succeed (e.g., cannot go from "completed" to "pending")
**Validates: Requirements 1.3**

Property 4: All eligible projects are processed
*For any* execution cycle, all projects meeting the update criteria should be processed (no projects should be skipped)
**Validates: Requirements 1.4**

### Anomaly Detection Properties

Property 5: Zero participation near start date triggers anomaly
*For any* project with zero participants and a start date within 3 days, the system should flag it as an anomaly with appropriate severity
**Validates: Requirements 2.1**

Property 6: Low participation rates are detected
*For any* project with participation rate significantly below (>20% below) the historical average for similar projects, the system should identify it as a low-participation anomaly
**Validates: Requirements 2.2**

Property 7: Invalid date ranges are flagged
*For any* project where end_date is before start_date, the system should flag it as a data integrity anomaly
**Validates: Requirements 2.3**

Property 8: Unsubscription spikes are detected
*For any* project where unsubscriptions in a 24-hour period exceed 2x the historical average, the system should detect this as an anomaly
**Validates: Requirements 2.4**

Property 9: Anomalies include required metadata
*For any* detected anomaly, the output should include severity level (low/medium/high) and at least one recommended action
**Validates: Requirements 2.5**

### Analytics Properties

Property 10: Completed projects are compared to history
*For any* project that completes, the system should retrieve and compare against at least 3 similar historical projects
**Validates: Requirements 3.2**

Property 11: Max capacity triggers suggestions
*For any* project at maximum capacity (current_participants >= max_participants), the system should generate a recommendation to create similar projects
**Validates: Requirements 3.4**

Property 12: Recommendations include supporting data
*For any* generated recommendation, the output should include supporting data and a confidence level (0.0-1.0)
**Validates: Requirements 3.5**

### Notification Properties

Property 13: Completed projects notify participants
*For any* project status change to "completed", notification emails should be sent to all participants in the project
**Validates: Requirements 4.1**

Property 14: Cancelled projects notify with explanation
*For any* project status change to "cancelled", notification emails should be sent to all participants with an explanation field populated
**Validates: Requirements 4.2**

Property 15: Deadline passage notifies pending registrants
*For any* project where registration_deadline passes, notifications should be sent to all users with pending registrations
**Validates: Requirements 4.3**

Property 16: Notifications are formatted by type and role
*For any* notification, the message format should differ based on notification type (completion/cancellation/deadline) and recipient role (admin/participant)
**Validates: Requirements 4.4**

Property 17: Failed notifications are retried with backoff
*For any* notification delivery failure, the system should retry with exponentially increasing delays (1s, 2s, 4s, 8s) up to 4 attempts
**Validates: Requirements 4.5**

### Summary and Reporting Properties

Property 18: Execution cycles generate summaries
*For any* completed execution cycle, a summary report should be generated containing session metadata
**Validates: Requirements 5.1**

Property 19: Summaries include required counts
*For any* generated summary, it should include counts for projects_updated, anomalies_detected, and recommendations_made
**Validates: Requirements 5.2**

Property 20: Summaries are sent to admins
*For any* generated summary, it should be sent via email to all configured administrator addresses
**Validates: Requirements 5.3**

Property 21: Critical issues are highlighted
*For any* summary containing anomalies with severity="high", those anomalies should appear in a dedicated "Critical Issues" section
**Validates: Requirements 5.4**

Property 22: AI decisions include reasoning
*For any* AI decision in a summary, the decision entry should include a "reasoning" field with non-empty text
**Validates: Requirements 5.5**

### Memory and Context Properties

Property 23: Decisions are persisted to memory
*For any* agent decision, the Agent Core should store an entry in DynamoDB conversation memory with the session_id
**Validates: Requirements 6.1**

Property 24: Historical context is retrieved
*For any* agent invocation with similar context to a previous session, the Agent Core should retrieve and provide relevant historical context
**Validates: Requirements 6.2**

Property 25: Conversation history includes required fields
*For any* stored conversation entry, it should include timestamp, agent_name, input, output, tool_calls, and reasoning fields
**Validates: Requirements 6.3**

Property 26: Old sessions are archived
*For any* conversation memory entry older than the retention period (default 30 days), the entry should be archived or deleted
**Validates: Requirements 6.4**

Property 27: Context retrieval is limited
*For any* historical context retrieval, the number of returned sessions should not exceed the configured limit (default 10)
**Validates: Requirements 6.5**

### Orchestration Properties

Property 28: All four agents are invoked
*For any* orchestrator execution, all four agents (StatusManager, AnomalyDetector, AnalyticsAgent, NotificationAgent) should be invoked
**Validates: Requirements 7.1**

Property 29: Context is passed between agents
*For any* agent execution after the first, the agent should receive context containing outputs from all previous agents in the workflow
**Validates: Requirements 7.2**

Property 30: Tool parameters are validated
*For any* tool call with invalid parameters (missing required fields or wrong types), the Agent Core should reject the call and return a validation error
**Validates: Requirements 7.3**

Property 31: Coordination strategies work correctly
*For any* orchestrator configuration, both "sequential" and "parallel" coordination strategies should produce correct results
**Validates: Requirements 7.4**

Property 32: Failed agents are retried
*For any* agent execution failure, the Agent Core should retry up to 3 times with exponential backoff (1s, 2s, 4s)
**Validates: Requirements 7.5**

### Observability Properties

Property 33: Agent metrics are emitted
*For any* agent invocation, metrics should be emitted to CloudWatch including invocation_count, duration_ms, success (boolean), and token_usage
**Validates: Requirements 8.1**

Property 34: Tool metrics are tracked
*For any* tool call, metrics should be tracked including tool_name, success_rate, and latency_ms
**Validates: Requirements 8.2**

Property 35: Errors are logged with details
*For any* error occurrence, a log entry should be created including error_message, stack_trace, and context (agent_name, session_id, etc.)
**Validates: Requirements 8.3**

Property 36: High token usage triggers alerts
*For any* execution where total token usage exceeds the threshold (default 100K tokens), a cost control alert should be sent to operators
**Validates: Requirements 8.4**

Property 37: Traces appear in X-Ray
*For any* execution, distributed traces should appear in AWS X-Ray with segments for each agent and tool call
**Validates: Requirements 8.5**

### Approval Workflow Properties

Property 38: Critical actions create approval requests
*For any* agent recommendation marked as critical (severity="high" or affects >50 participants), an approval request should be created in the admin dashboard
**Validates: Requirements 9.1**

Property 39: Approval requests include reasoning
*For any* created approval request, it should include the agent's reasoning and expected_impact fields
**Validates: Requirements 9.2**

Property 40: Approved actions are executed
*For any* approval request that is approved, the recommended action should be executed and an approval record created with approver_id and timestamp
**Validates: Requirements 9.3**

Property 41: Rejections are recorded
*For any* approval request that is rejected, a rejection record should be created with rejector_id, timestamp, and reason
**Validates: Requirements 9.4**

Property 42: Pending requests trigger reminders
*For any* approval request pending longer than the timeout period (default 24 hours), a reminder notification should be sent to admins
**Validates: Requirements 9.5**

### Reliability and Fallback Properties

Property 43: API unavailability triggers fallback
*For any* execution where Bedrock Runtime API returns 503 or times out, the system should fall back to rule-based logic for status updates
**Validates: Requirements 10.1**

Property 44: Agent failures are logged and skipped
*For any* agent that fails to make a decision, the failure should be logged and the orchestrator should continue with remaining agents
**Validates: Requirements 10.2**

Property 45: Tool failures are retried
*For any* tool call failure, the system should retry up to 3 times with exponential backoff (1s, 2s, 4s) before giving up
**Validates: Requirements 10.3**

Property 46: Errors trigger alerts and continuation
*For any* unexpected error, an alert should be sent to operators and the system should continue processing remaining projects
**Validates: Requirements 10.4**

Property 47: Rate limits trigger backoff
*For any* Bedrock API response with rate limit error (429), the system should implement exponential backoff and queue the operation for retry
**Validates: Requirements 10.5**

## Error Handling

### Error Categories

1. **Agent Execution Errors**
   - Model invocation failures (Bedrock API errors)
   - Tool calling errors (invalid parameters, execution failures)
   - Context management errors (memory storage/retrieval failures)

2. **Tool Execution Errors**
   - Database errors (DynamoDB read/write failures)
   - External service errors (SES email delivery failures)
   - Validation errors (invalid input parameters)

3. **Orchestration Errors**
   - Agent coordination failures
   - Timeout errors (agent takes too long)
   - Resource exhaustion (memory, token limits)

### Error Handling Strategies

**Retry with Exponential Backoff:**
```python
async def retry_with_backoff(
    func: Callable,
    max_retries: int = 3,
    base_delay: float = 1.0
) -> Any:
    """
    Retry a function with exponential backoff
    
    Delays: 1s, 2s, 4s for max_retries=3
    """
    for attempt in range(max_retries):
        try:
            return await func()
        except RetryableError as e:
            if attempt == max_retries - 1:
                raise
            delay = base_delay * (2 ** attempt)
            await asyncio.sleep(delay)
            logger.warning(f"Retry attempt {attempt + 1} after {delay}s")
```

**Graceful Degradation:**
```python
async def execute_with_fallback(
    primary_func: Callable,
    fallback_func: Callable
) -> Any:
    """
    Try primary function, fall back to simpler logic on failure
    """
    try:
        return await primary_func()
    except Exception as e:
        logger.error(f"Primary function failed: {e}, using fallback")
        return await fallback_func()
```

**Circuit Breaker Pattern:**
```python
class CircuitBreaker:
    """
    Prevent cascading failures by stopping calls to failing services
    """
    def __init__(self, failure_threshold: int = 5, timeout: int = 60):
        self.failure_count = 0
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.last_failure_time = None
        self.state = "closed"  # closed, open, half_open
        
    async def call(self, func: Callable) -> Any:
        if self.state == "open":
            if time.time() - self.last_failure_time > self.timeout:
                self.state = "half_open"
            else:
                raise CircuitBreakerOpenError()
                
        try:
            result = await func()
            if self.state == "half_open":
                self.state = "closed"
                self.failure_count = 0
            return result
        except Exception as e:
            self.failure_count += 1
            self.last_failure_time = time.time()
            if self.failure_count >= self.failure_threshold:
                self.state = "open"
            raise
```

### Error Logging

All errors should be logged with:
- Error type and message
- Stack trace
- Context (session_id, agent_name, project_id, etc.)
- Timestamp
- Severity level

Errors should be sent to CloudWatch Logs with structured logging format for easy querying.

## Testing Strategy

### Unit Testing

Unit tests will cover individual components in isolation:

**Tool Function Tests:**
- Test each tool function with valid inputs
- Test error handling for invalid inputs
- Test database interactions with mocked DynamoDB
- Test external service calls with mocked SES

**Agent Configuration Tests:**
- Validate agent instruction prompts
- Verify tool registrations
- Test tool schema definitions

**Orchestrator Tests:**
- Test agent invocation logic
- Test context passing between agents
- Test coordination strategies (sequential/parallel)
- Test error handling and retries

**Example Unit Test:**
```python
def test_update_project_status_creates_audit_log():
    """Test that status updates create audit logs"""
    # Arrange
    project_id = "test-project-123"
    old_status = "active"
    new_status = "completed"
    reason = "End date passed"
    
    # Act
    result = update_project_status(project_id, new_status, reason)
    
    # Assert
    assert result is True
    audit_logs = get_audit_logs(project_id)
    assert len(audit_logs) == 1
    assert audit_logs[0].old_value == old_status
    assert audit_logs[0].new_value == new_status
    assert audit_logs[0].reasoning == reason
```

### Property-Based Testing

Property-based tests will verify universal properties across many generated inputs using the **Hypothesis** library for Python.

**Configuration:**
- Each property test should run a minimum of 100 iterations
- Use appropriate strategies for generating test data (dates, statuses, participant counts, etc.)
- Each test must be tagged with a comment referencing the design document property

**Test Tagging Format:**
```python
# Feature: ai-project-lifecycle-manager, Property 1: Expired projects are completed
@given(projects=st.lists(project_strategy(), min_size=1, max_size=20))
def test_expired_projects_are_completed(projects):
    ...
```

**Example Property Test:**
```python
from hypothesis import given, strategies as st
from datetime import date, timedelta

# Feature: ai-project-lifecycle-manager, Property 1: Expired projects are completed
@given(
    end_date=st.dates(max_value=date.today() - timedelta(days=1)),
    status=st.sampled_from(["pending", "active", "ongoing"])
)
def test_expired_projects_are_completed(end_date, status):
    """
    Property: For any project where current date > end_date and 
    status != "completed", the system should update to "completed"
    """
    # Arrange
    project = create_test_project(
        end_date=end_date,
        status=status
    )
    
    # Act
    run_status_manager_agent(current_date=date.today())
    
    # Assert
    updated_project = get_project(project.id)
    assert updated_project.status == "completed"
    
    # Verify audit log was created
    audit_logs = get_audit_logs(project.id)
    assert any(log.new_value == "completed" for log in audit_logs)
```

**Test Data Generators:**
```python
from hypothesis import strategies as st

@st.composite
def project_strategy(draw):
    """Generate random valid projects"""
    start_date = draw(st.dates())
    end_date = draw(st.dates(min_value=start_date))
    return Project(
        id=draw(st.uuids()).hex,
        name=draw(st.text(min_size=5, max_size=50)),
        status=draw(st.sampled_from(["pending", "active", "ongoing", "completed", "cancelled"])),
        start_date=start_date,
        end_date=end_date,
        registration_deadline=draw(st.dates(max_value=start_date)),
        current_participants=draw(st.integers(min_value=0, max_value=100)),
        max_participants=draw(st.integers(min_value=10, max_value=100)),
        project_type=draw(st.sampled_from(["workshop", "speaker_session", "hackathon"]))
    )

@st.composite
def anomaly_project_strategy(draw):
    """Generate projects likely to trigger anomalies"""
    start_date = draw(st.dates(min_value=date.today(), max_value=date.today() + timedelta(days=3)))
    return Project(
        id=draw(st.uuids()).hex,
        name=draw(st.text(min_size=5, max_size=50)),
        status="active",
        start_date=start_date,
        end_date=draw(st.dates(min_value=start_date)),
        registration_deadline=draw(st.dates(max_value=start_date)),
        current_participants=0,  # Zero participants to trigger anomaly
        max_participants=draw(st.integers(min_value=10, max_value=100)),
        project_type=draw(st.sampled_from(["workshop", "speaker_session", "hackathon"]))
    )
```

### Integration Testing

Integration tests will verify the complete system working together:

- Test full orchestrator workflow with all four agents
- Test Agent Core conversation memory persistence
- Test integration with DynamoDB, SES, CloudWatch
- Test EventBridge trigger to Lambda handler
- Test error scenarios and fallback mechanisms

**Example Integration Test:**
```python
async def test_complete_daily_workflow():
    """Test the complete daily project check workflow"""
    # Arrange: Create test projects in various states
    expired_project = create_project(end_date=date.today() - timedelta(days=1), status="active")
    low_participation_project = create_project(current_participants=5, max_participants=50)
    
    # Act: Run the complete workflow
    session_id = f"test-{datetime.now().isoformat()}"
    result = await daily_project_check(session_id)
    
    # Assert: Verify all agents ran
    assert "status_updates" in result
    assert "anomalies" in result
    assert "analytics" in result
    assert "notifications" in result
    
    # Verify status was updated
    updated_project = get_project(expired_project.id)
    assert updated_project.status == "completed"
    
    # Verify anomaly was detected
    assert any(a["project_id"] == low_participation_project.id for a in result["anomalies"]["issues"])
    
    # Verify conversation memory was stored
    history = orchestrator.get_conversation_history(session_id)
    assert len(history) >= 4  # One entry per agent
```

### Testing AWS Strands Agents

Since AWS Strands Agents and Agent Core are AWS-managed services, testing focuses on:

1. **Tool Function Testing:** Verify all registered tools work correctly
2. **Agent Instruction Testing:** Validate agent prompts produce expected behavior
3. **Integration Testing:** Test the complete system with real Agent Core
4. **Mock Testing:** Use mocked Bedrock responses for unit tests

**Mocking Agent Core:**
```python
class MockAgentCore:
    """Mock Agent Core for unit testing"""
    
    async def invoke_agent(self, agent_name, session_id, input_text, context=None):
        # Return predefined responses based on agent_name
        if agent_name == "StatusManager":
            return {
                "updated_projects": [{"id": "proj_123", "status": "completed"}],
                "reasoning": "End date passed"
            }
        # ... other agents
```

## Technology Stack

### Core Technologies

- **AWS Strands Agents:** Multi-agent framework for specialized agents
- **Amazon Agent Core:** Orchestration, memory, and lifecycle management
- **Amazon Bedrock Runtime:** Claude 3.5 Sonnet model execution
- **AWS Lambda:** Serverless compute for orchestrator handler
- **Amazon DynamoDB:** Conversation memory and data storage
- **Amazon EventBridge:** Scheduled triggers (hourly/daily)
- **Amazon SES:** Email notifications
- **AWS CloudWatch:** Metrics and logging
- **AWS X-Ray:** Distributed tracing

### Development Technologies

- **Python 3.11+:** Primary programming language
- **boto3:** AWS SDK for Python
- **amazon-agent-core:** Agent Core SDK (when available)
- **Hypothesis:** Property-based testing library
- **pytest:** Unit and integration testing framework
- **pytest-asyncio:** Async test support
- **moto:** AWS service mocking for tests

### Infrastructure as Code

- **AWS CDK (Python):** Infrastructure definition and deployment
- **AWS SAM:** Lambda function packaging and deployment

## Deployment Architecture

### Lambda Function Structure

```
lambda/
├── orchestrator/
│   ├── handler.py              # Lambda entry point
│   ├── orchestrator.py         # Agent Core orchestrator
│   ├── agents/
│   │   ├── status_manager.py   # StatusManager agent config
│   │   ├── anomaly_detector.py # AnomalyDetector agent config
│   │   ├── analytics_agent.py  # AnalyticsAgent agent config
│   │   └── notification_agent.py # NotificationAgent agent config
│   ├── tools/
│   │   ├── project_tools.py    # Project management tools
│   │   ├── analytics_tools.py  # Analytics tools
│   │   └── notification_tools.py # Notification tools
│   └── requirements.txt
```

### Environment Variables

```python
# Lambda environment variables
ENVIRONMENT = "production"  # or "development", "staging"
PROJECTS_TABLE = "projects-table"
AUDIT_LOGS_TABLE = "audit-logs-table"
CONVERSATION_MEMORY_TABLE = "agent-conversations"
ADMIN_EMAIL_ADDRESSES = "admin1@example.com,admin2@example.com"
BEDROCK_MODEL_ID = "anthropic.claude-3-5-sonnet-20241022-v2:0"
BEDROCK_REGION = "us-east-1"
TOKEN_USAGE_THRESHOLD = "100000"
RETENTION_DAYS = "30"
MAX_RETRIES = "3"
COORDINATION_STRATEGY = "sequential"  # or "parallel"
```

### IAM Permissions

The Lambda execution role requires:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream"
      ],
      "Resource": "arn:aws:bedrock:*::foundation-model/anthropic.claude-3-5-sonnet-20241022-v2:0"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:Query",
        "dynamodb:UpdateItem",
        "dynamodb:BatchWriteItem"
      ],
      "Resource": [
        "arn:aws:dynamodb:*:*:table/projects-table",
        "arn:aws:dynamodb:*:*:table/audit-logs-table",
        "arn:aws:dynamodb:*:*:table/agent-conversations"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricData"
      ],
      "Resource": "*"
    }
  ]
}
```

### EventBridge Schedule

```python
# CDK definition for EventBridge schedule
schedule = events.Rule(
    self, "DailyProjectCheck",
    schedule=events.Schedule.cron(
        minute="0",
        hour="10",  # 10 AM UTC daily
        month="*",
        week_day="*",
        year="*"
    ),
    targets=[targets.LambdaFunction(orchestrator_lambda)]
)
```

## Monitoring and Alerting

### CloudWatch Metrics

Custom metrics to track:

- `AgentInvocations` (by agent_name)
- `AgentDuration` (by agent_name)
- `AgentSuccessRate` (by agent_name)
- `TokenUsage` (by agent_name)
- `ToolCallSuccessRate` (by tool_name)
- `ProjectsUpdated`
- `AnomaliesDetected` (by severity)
- `NotificationsSent` (by type)
- `ErrorCount` (by error_type)

### CloudWatch Alarms

```python
# High error rate alarm
error_alarm = cloudwatch.Alarm(
    self, "HighErrorRate",
    metric=error_metric,
    threshold=5,
    evaluation_periods=1,
    alarm_description="Agent execution error rate exceeded threshold",
    actions=[sns_topic]
)

# High token usage alarm
token_alarm = cloudwatch.Alarm(
    self, "HighTokenUsage",
    metric=token_metric,
    threshold=100000,
    evaluation_periods=1,
    alarm_description="Token usage exceeded cost control threshold",
    actions=[sns_topic]
)
```

### CloudWatch Dashboard

A dashboard should display:

- Agent invocation counts (last 24 hours)
- Average agent duration
- Success rates by agent
- Token usage trends
- Projects updated per day
- Anomalies detected (by severity)
- Error rates and types

### X-Ray Tracing

Enable X-Ray tracing to visualize:

- Complete workflow execution
- Agent invocation timing
- Tool call latencies
- External service calls (DynamoDB, SES, Bedrock)
- Error locations and frequencies

## Security Considerations

### Data Protection

- All data at rest encrypted using AWS KMS
- All data in transit encrypted using TLS 1.2+
- Conversation memory contains no PII
- Audit logs sanitized before storage

### Access Control

- Lambda execution role follows least privilege principle
- Agent Core conversation memory isolated by session_id
- Admin dashboard requires authentication and authorization
- API endpoints protected by IAM or Cognito

### Secrets Management

- API keys stored in AWS Secrets Manager
- Database credentials rotated automatically
- Environment variables for non-sensitive configuration only

### Compliance

- GDPR: Conversation memory retention policy (30 days)
- Audit trail for all automated actions
- Admin approval workflow for critical actions
- Data deletion capabilities

## Cost Estimation

### Monthly Costs (Daily Execution)

**Bedrock API Calls:**
- 4 agents × 30 days = 120 invocations/month
- ~5K tokens per agent = 600K tokens/month
- Claude 3.5 Sonnet: $3/million input tokens, $15/million output tokens
- Input cost: $1.80/month
- Output cost (assuming 2K output tokens per agent): $3.60/month
- **Total Bedrock: $5.40/month**

**Agent Core:**
- Pricing TBD (currently in preview)
- Estimated: $0.10 per agent invocation or included in Bedrock pricing
- **Estimated: $0-12/month**

**DynamoDB:**
- Storage: ~1GB = $0.25/month
- Read/Write: ~1000 operations/day = $0.50/month
- **Total DynamoDB: $0.75/month**

**Lambda:**
- Execution time: ~30 seconds per run
- Memory: 1024 MB
- Cost: ~$0.10/month
- **Total Lambda: $0.10/month**

**Other Services:**
- SES: $0.10/month (1000 emails)
- CloudWatch Logs: $0.50/month
- X-Ray: $0.50/month
- **Total Other: $1.10/month**

**Total Estimated Monthly Cost: $7.35 - $19.35**

This is extremely cost-effective for the value provided (automated project management, intelligent anomaly detection, and proactive recommendations).

## Future Enhancements

### Phase 2: Interactive Agent Interface (Month 2)

Add natural language query interface for admins:

```python
# Admin can ask questions via Slack/Teams integration
admin: "Why wasn't the AWS Workshop project completed?"

orchestrator:
  → Routes to StatusManager agent
  → Agent checks project history and conversation memory
  → Responds with reasoning and context
```

### Phase 3: Predictive Analytics (Month 3)

Add predictive capabilities to AnalyticsAgent:

- Predict project success probability based on early metrics
- Recommend optimal registration periods
- Forecast participation rates
- Identify best times to schedule projects

### Phase 4: Autonomous Actions with Learning (Month 4)

Enable agents to learn from admin feedback:

- Track approval/rejection patterns
- Adjust decision thresholds based on feedback
- Improve anomaly detection accuracy
- Personalize recommendations per admin preferences

### Phase 5: Multi-Tenant Support (Month 5)

Extend to support multiple organizations:

- Tenant-specific agent configurations
- Isolated conversation memory per tenant
- Custom business rules per tenant
- Tenant-specific analytics and reporting
