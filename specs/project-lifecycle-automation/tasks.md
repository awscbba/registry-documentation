# Tasks: Project Lifecycle Automation - Phase 1 (Deterministic)

## Task Breakdown

### Epic 1: Core Lambda Implementation

#### Task 1.1: Create Lambda Handler Structure
**Estimated Effort**: 2 hours
**Priority**: High
**Dependencies**: None

**Description**: Set up the basic Lambda function structure and configuration.

**Subtasks**:
- [ ] Create `registry-api/src/handlers/project_lifecycle_handler.py`
- [ ] Implement handler function signature
- [ ] Add environment variable configuration
- [ ] Set up structured logging with correlation IDs
- [ ] Add X-Ray tracing instrumentation

**Acceptance Criteria**:
- Handler can be invoked and returns success response
- Logs are structured and include correlation IDs
- X-Ray traces are captured

**Files to Create/Modify**:
- `registry-api/src/handlers/project_lifecycle_handler.py` (new)

---

#### Task 1.2: Implement Business Rules
**Estimated Effort**: 3 hours
**Priority**: High
**Dependencies**: Task 1.1

**Description**: Implement the lifecycle transition rules.

**Subtasks**:
- [ ] Create `LifecycleRules` class
- [ ] Implement `should_complete()` method
- [ ] Implement `should_activate()` method
- [ ] Implement `should_close_registration()` method
- [ ] Add date parsing and validation utilities

**Acceptance Criteria**:
- All rule methods return correct boolean values
- Date comparisons handle edge cases (same day, timezone)
- Rules are unit tested with 100% coverage

**Files to Create/Modify**:
- `registry-api/src/services/lifecycle_service.py` (new)
- `registry-api/src/utils/date_utils.py` (new)

---

#### Task 1.3: Implement DynamoDB Scanning
**Estimated Effort**: 4 hours
**Priority**: High
**Dependencies**: Task 1.2

**Description**: Implement efficient project scanning using DynamoDB queries.

**Subtasks**:
- [ ] Create GSI for status and date filtering (if not exists)
- [ ] Implement `scan_eligible_projects()` function
- [ ] Add pagination handling for large result sets
- [ ] Optimize query filters to minimize scanned items
- [ ] Add error handling for DynamoDB exceptions

**Acceptance Criteria**:
- Scans only projects that might need transitions
- Handles pagination correctly
- Completes within performance requirements (<30s for 1000 projects)
- Handles DynamoDB throttling gracefully

**Files to Create/Modify**:
- `registry-api/src/repositories/lifecycle_repository.py` (new)

---

#### Task 1.4: Implement Status Transitions
**Estimated Effort**: 4 hours
**Priority**: High
**Dependencies**: Task 1.3

**Description**: Implement conditional status updates with optimistic locking.

**Subtasks**:
- [ ] Implement `transition_status()` function
- [ ] Add conditional update expressions
- [ ] Handle ConditionalCheckFailedException
- [ ] Implement retry logic with exponential backoff
- [ ] Add transaction rollback on partial failures

**Acceptance Criteria**:
- Status updates use conditional writes
- Race conditions are prevented
- Failed updates are retried appropriately
- Partial failures don't corrupt data

**Files to Create/Modify**:
- `registry-api/src/services/lifecycle_service.py` (modify)

---

#### Task 1.5: Implement Audit Logging
**Estimated Effort**: 3 hours
**Priority**: High
**Dependencies**: Task 1.4

**Description**: Log all status transitions to audit table.

**Subtasks**:
- [ ] Create audit log data model
- [ ] Implement `log_transition()` function
- [ ] Add batch writing for multiple transitions
- [ ] Include metadata (reason, triggered_by, timestamp)
- [ ] Handle audit log write failures gracefully

**Acceptance Criteria**:
- Every transition creates audit log entry
- Audit logs include all required fields
- Audit log failures don't block transitions
- Logs are queryable by project_id and date

**Files to Create/Modify**:
- `registry-api/src/repositories/audit_repository.py` (modify or new)
- `registry-api/src/models/audit_log.py` (modify or new)

---

### Epic 2: Notification System

#### Task 2.1: Implement SQS Queue Integration
**Estimated Effort**: 2 hours
**Priority**: Medium
**Dependencies**: Task 1.4

**Description**: Queue notifications for status changes.

**Subtasks**:
- [ ] Create SQS queue in CDK stack
- [ ] Implement `queue_notification()` function
- [ ] Define notification message schema
- [ ] Add batch message sending
- [ ] Handle SQS send failures

**Acceptance Criteria**:
- Messages are queued successfully
- Message format is valid JSON
- Failed sends are logged and retried
- Queue has DLQ configured

**Files to Create/Modify**:
- `registry-api/src/services/notification_queue_service.py` (new)
- `registry-infrastructure/lib/stacks/lifecycle-stack.ts` (modify)

---

#### Task 2.2: Implement Notification Consumer
**Estimated Effort**: 3 hours
**Priority**: Medium
**Dependencies**: Task 2.1

**Description**: Process queued notifications and send emails.

**Subtasks**:
- [ ] Create notification consumer Lambda
- [ ] Implement email template rendering
- [ ] Integrate with existing email service
- [ ] Add notification preferences check
- [ ] Handle SES send failures

**Acceptance Criteria**:
- Emails are sent for status changes
- Templates are properly rendered
- User preferences are respected
- Failed sends go to DLQ

**Files to Create/Modify**:
- `registry-api/src/handlers/notification_consumer_handler.py` (new)
- `registry-api/src/templates/project_completed_email.html` (new)
- `registry-api/src/templates/project_activated_email.html` (new)

---

### Epic 3: Infrastructure & Deployment

#### Task 3.1: Create CDK Stack
**Estimated Effort**: 4 hours
**Priority**: High
**Dependencies**: Task 1.1

**Description**: Define infrastructure as code for lifecycle automation.

**Subtasks**:
- [ ] Create `ProjectLifecycleStack` in CDK
- [ ] Define Lambda function resource
- [ ] Create EventBridge scheduled rule
- [ ] Set up IAM roles and policies
- [ ] Configure CloudWatch alarms
- [ ] Add DLQ for failed executions

**Acceptance Criteria**:
- Stack deploys successfully
- All resources are created correctly
- IAM follows least privilege principle
- Alarms are configured and tested

**Files to Create/Modify**:
- `registry-infrastructure/lib/stacks/project-lifecycle-stack.ts` (new)
- `registry-infrastructure/bin/infrastructure.ts` (modify)

---

#### Task 3.2: Configure EventBridge Rule
**Estimated Effort**: 1 hour
**Priority**: High
**Dependencies**: Task 3.1

**Description**: Set up scheduled execution of lifecycle Lambda.

**Subtasks**:
- [ ] Define cron expression (daily at 00:00 UTC)
- [ ] Configure Lambda as target
- [ ] Set up retry policy
- [ ] Add DLQ for failed invocations
- [ ] Test schedule triggers correctly

**Acceptance Criteria**:
- Rule triggers Lambda at correct time
- Failed invocations go to DLQ
- Retry policy works as expected

**Files to Create/Modify**:
- `registry-infrastructure/lib/stacks/project-lifecycle-stack.ts` (modify)

---

#### Task 3.3: Set Up Monitoring & Alarms
**Estimated Effort**: 3 hours
**Priority**: High
**Dependencies**: Task 3.1

**Description**: Configure comprehensive monitoring and alerting.

**Subtasks**:
- [ ] Create custom CloudWatch metrics
- [ ] Set up error rate alarm
- [ ] Set up duration/timeout alarm
- [ ] Set up transition count metrics
- [ ] Configure SNS topics for alerts
- [ ] Create CloudWatch dashboard

**Acceptance Criteria**:
- All metrics are published correctly
- Alarms trigger on threshold breaches
- Dashboard shows key metrics
- Alerts are sent to correct channels

**Files to Create/Modify**:
- `registry-infrastructure/lib/stacks/project-lifecycle-stack.ts` (modify)
- `registry-infrastructure/lib/constructs/lifecycle-monitoring.ts` (new)

---

### Epic 4: Testing

#### Task 4.1: Write Property-Based Tests for Status Transitions
**Estimated Effort**: 3 hours
**Priority**: High
**Dependencies**: Tasks 1.2, 1.3, 1.4

**Description**: Implement property-based tests for date-based status transitions.

**Subtasks**:
- [ ] 4.1.1 Write property test for Property 1: Date-based status transitions
  - **Feature: project-lifecycle-automation, Property 1: Date-based status transitions**
  - **Validates: Requirements 1.1, 2.1**
  - Generate random projects with various dates and statuses
  - Verify ACTIVE projects past end date become COMPLETED
  - Verify PENDING projects at/past start date become ACTIVE
- [ ] 4.1.2 Write property test for Property 3: Registration closure
  - **Feature: project-lifecycle-automation, Property 3: Registration closure**
  - **Validates: Requirements 3.1**
  - Generate random projects with registration end dates
  - Verify registration closes when date passes

**Acceptance Criteria**:
- Property tests run at least 100 iterations each
- Tests use property-based testing library (Hypothesis for Python)
- All property tests pass
- Tests are tagged with property references

**Files to Create/Modify**:
- `registry-api/tests/property/test_lifecycle_properties.py` (new)

---

#### Task 4.2: Write Property-Based Tests for Audit Logging
**Estimated Effort**: 2 hours
**Priority**: High
**Dependencies**: Task 1.5

**Description**: Implement property-based tests for audit logging.

**Subtasks**:
- [ ] 4.2.1 Write property test for Property 2: Audit log completeness
  - **Feature: project-lifecycle-automation, Property 2: Audit log completeness**
  - **Validates: Requirements 1.2, 2.2, 4.1**
  - Generate random status transitions
  - Verify each transition creates exactly one audit log with all required fields
- [ ] 4.2.2 Write property test for Property 5: Audit log queryability
  - **Feature: project-lifecycle-automation, Property 5: Audit log queryability**
  - **Validates: Requirements 4.3**
  - Generate random audit logs
  - Verify all logs are retrievable by project ID and date
- [ ] 4.2.3 Write property test for Property 6: Error audit logging
  - **Feature: project-lifecycle-automation, Property 6: Error audit logging**
  - **Validates: Requirements 4.4**
  - Inject random failures
  - Verify error audit logs are created with error details

**Acceptance Criteria**:
- Property tests run at least 100 iterations each
- All property tests pass
- Tests are tagged with property references

**Files to Create/Modify**:
- `registry-api/tests/property/test_audit_properties.py` (new)

---

#### Task 4.3: Write Property-Based Tests for Error Handling
**Estimated Effort**: 2 hours
**Priority**: High
**Dependencies**: Task 1.4

**Description**: Implement property-based tests for error handling and resilience.

**Subtasks**:
- [ ] 4.3.1 Write property test for Property 7: Error isolation
  - **Feature: project-lifecycle-automation, Property 7: Error isolation**
  - **Validates: Requirements 5.4**
  - Generate random project sets with one failing project
  - Verify other projects are still processed successfully
- [ ] 4.3.2 Write property test for Property 8: Idempotent execution
  - **Feature: project-lifecycle-automation, Property 8: Idempotent execution**
  - **Validates: Requirements 6.3**
  - Generate random project sets
  - Run lifecycle system twice
  - Verify identical final states
- [ ] 4.3.3 Write property test for Property 9: Invalid transition rejection
  - **Feature: project-lifecycle-automation, Property 9: Invalid transition rejection**
  - **Validates: Requirements 8.2**
  - Generate projects in various invalid states for transitions
  - Verify transitions are rejected and state is preserved
- [ ] 4.3.4 Write property test for Property 10: State preservation on failure
  - **Feature: project-lifecycle-automation, Property 10: State preservation on failure**
  - **Validates: Requirements 8.3**
  - Inject random transition failures
  - Verify original project state is preserved

**Acceptance Criteria**:
- Property tests run at least 100 iterations each
- All property tests pass
- Tests are tagged with property references

**Files to Create/Modify**:
- `registry-api/tests/property/test_error_handling_properties.py` (new)

---

#### Task 4.4: Write Property-Based Test for Registration Enforcement
**Estimated Effort**: 1 hour
**Priority**: High
**Dependencies**: Task 1.3

**Description**: Implement property-based test for closed registration enforcement.

**Subtasks**:
- [ ] 4.4.1 Write property test for Property 4: Closed registration enforcement
  - **Feature: project-lifecycle-automation, Property 4: Closed registration enforcement**
  - **Validates: Requirements 3.2**
  - Generate random projects with closed registration
  - Verify subscription attempts are rejected with clear error messages

**Acceptance Criteria**:
- Property test runs at least 100 iterations
- All property tests pass
- Test is tagged with property reference

**Files to Create/Modify**:
- `registry-api/tests/property/test_registration_properties.py` (new)

---

#### Task 4.5: Write Unit Tests
**Estimated Effort**: 3 hours
**Priority**: High
**Dependencies**: Tasks 1.2, 1.3, 1.4, 1.5

**Description**: Write unit tests for specific examples and edge cases.

**Subtasks**:
- [ ]* 4.5.1 Test notification queuing for completed projects
- [ ]* 4.5.2 Test notification queuing for activated projects
- [ ]* 4.5.3 Test retry logic with exponential backoff
- [ ]* 4.5.4 Test DLQ behavior after retry exhaustion
- [ ]* 4.5.5 Test structured logging with correlation IDs

**Acceptance Criteria**:
- Unit tests cover specific examples
- Edge cases are tested
- All tests pass

**Files to Create/Modify**:
- `registry-api/tests/test_lifecycle_service.py` (new)
- `registry-api/tests/test_lifecycle_rules.py` (new)

---

#### Task 4.6: Write Integration Tests
**Estimated Effort**: 4 hours
**Priority**: High
**Dependencies**: Tasks 4.1, 4.2, 4.3, 4.4

**Description**: End-to-end integration tests with DynamoDB.

**Subtasks**:
- [ ]* 4.6.1 Set up test DynamoDB tables
- [ ]* 4.6.2 Test complete lifecycle flow end-to-end
- [ ]* 4.6.3 Test concurrent execution handling
- [ ]* 4.6.4 Test notification queuing integration

**Acceptance Criteria**:
- Integration tests cover happy path
- Error scenarios are tested
- Tests use real AWS services (localstack or test account)
- All tests pass consistently

**Files to Create/Modify**:
- `registry-api/tests/integration/test_lifecycle_integration.py` (new)
- `registry-api/tests/conftest.py` (modify)

---

#### Task 4.7: Performance Testing
**Estimated Effort**: 3 hours
**Priority**: Medium
**Dependencies**: Task 4.6

**Description**: Verify performance requirements are met.

**Subtasks**:
- [ ]* 4.7.1 Create load test with 1000 projects
- [ ]* 4.7.2 Create load test with 10,000 projects
- [ ]* 4.7.3 Measure execution time and memory usage
- [ ]* 4.7.4 Identify bottlenecks and optimize if needed

**Acceptance Criteria**:
- Processes 1000 projects in <30 seconds
- Processes 10,000 projects in <5 minutes
- Memory usage stays within limits
- No timeout errors

**Files to Create/Modify**:
- `registry-api/tests/performance/test_lifecycle_performance.py` (new)

---

### Epic 5: Documentation & Deployment

#### Task 5.1: Write Technical Documentation
**Estimated Effort**: 3 hours
**Priority**: Medium
**Dependencies**: All implementation tasks

**Description**: Document the lifecycle automation system.

**Subtasks**:
- [ ] Document Lambda handler API
- [ ] Document business rules
- [ ] Document monitoring and alerts
- [ ] Document troubleshooting procedures
- [ ] Create runbook for operations team
- [ ] Update architecture diagrams

**Acceptance Criteria**:
- All components are documented
- Runbook covers common scenarios
- Diagrams are up to date
- Documentation is reviewed and approved

**Files to Create/Modify**:
- `registry-documentation/features/project-lifecycle-automation.md` (update)
- `registry-documentation/operations/lifecycle-runbook.md` (new)

---

#### Task 5.2: Deploy to Development
**Estimated Effort**: 2 hours
**Priority**: High
**Dependencies**: All implementation and testing tasks

**Description**: Deploy to dev environment for initial testing.

**Subtasks**:
- [ ] Deploy CDK stack to dev
- [ ] Verify all resources created
- [ ] Run smoke tests
- [ ] Verify EventBridge triggers
- [ ] Check CloudWatch logs and metrics
- [ ] Test manual Lambda invocation

**Acceptance Criteria**:
- Stack deploys without errors
- Lambda executes successfully
- Metrics are published
- Logs are accessible

---

#### Task 5.3: Deploy to Staging
**Estimated Effort**: 2 hours
**Priority**: High
**Dependencies**: Task 5.2

**Description**: Deploy to staging for production-like testing.

**Subtasks**:
- [ ] Deploy CDK stack to staging
- [ ] Run full integration test suite
- [ ] Monitor for 1 week
- [ ] Verify no issues or errors
- [ ] Get approval from stakeholders

**Acceptance Criteria**:
- Staging deployment successful
- No errors during monitoring period
- Stakeholder approval obtained

---

#### Task 5.4: Deploy to Production
**Estimated Effort**: 3 hours
**Priority**: High
**Dependencies**: Task 5.3

**Description**: Production deployment with careful monitoring.

**Subtasks**:
- [ ] Create deployment plan
- [ ] Schedule deployment window
- [ ] Deploy CDK stack to production
- [ ] Monitor closely for 48 hours
- [ ] Verify correct operation
- [ ] Document any issues

**Acceptance Criteria**:
- Production deployment successful
- No critical issues in first 48 hours
- Metrics show expected behavior
- Stakeholders notified of completion

---

## Task Summary

| Epic | Tasks | Total Effort | Priority |
|------|-------|--------------|----------|
| Epic 1: Core Lambda | 5 | 16 hours | High |
| Epic 2: Notifications | 2 | 5 hours | Medium |
| Epic 3: Infrastructure | 3 | 8 hours | High |
| Epic 4: Testing | 7 | 18 hours | High |
| Epic 5: Documentation | 4 | 10 hours | Medium |
| **Total** | **21** | **57 hours** | - |

**Note**: Tasks marked with `*` are optional and can be skipped to focus on core functionality first.

## Critical Path

1. Task 1.1 → Task 1.2 → Task 1.3 → Task 1.4 → Task 1.5
2. Task 3.1 → Task 3.2 → Task 3.3
3. Task 4.1 → Task 4.2 → Task 4.3
4. Task 5.2 → Task 5.3 → Task 5.4

**Estimated Timeline**: 2-3 weeks (with 1 developer)

## Risk Mitigation

| Risk | Task | Mitigation |
|------|------|------------|
| DynamoDB throttling | 1.3 | Add exponential backoff, request capacity increase |
| Lambda timeout | 1.3, 1.4 | Optimize queries, increase timeout, add pagination |
| Race conditions | 1.4 | Use conditional updates, test concurrent execution |
| Notification failures | 2.1, 2.2 | Use SQS with DLQ, implement retry logic |
| Deployment issues | 5.2-5.4 | Gradual rollout, comprehensive testing, rollback plan |

---

**Status**: Draft
**Created**: 2025-11-29
**Last Updated**: 2025-11-29
