# Project Lifecycle Automation - Hybrid Approach

## Overview

This document outlines the design for automatic project lifecycle management in the People Registry system, using a hybrid approach that combines deterministic logic with AI-powered insights.

## Problem Statement

Currently, projects in the system do not automatically transition to "completed" status when their end date is reached. This requires manual intervention and can lead to:
- Outdated project listings showing expired projects as active
- Confusion for users about project availability
- Administrative overhead for project managers

## Current State

### Project Status Model
- **Status Enum**: `PENDING`, `ACTIVE`, `COMPLETED`, `CANCELLED`
- **Default Status**: `PENDING` when created
- **Date Fields**: `startDate`, `endDate`, `registrationEndDate`
- **Validation**: Ensures `endDate` is after `startDate`
- **No Automation**: Status changes require manual API calls

### Missing Functionality
- No scheduled jobs to check project dates
- No automatic status transitions
- No notifications for project lifecycle events
- No intelligent decision-making for edge cases

## Proposed Solution: Hybrid Approach

### Phase 1: Deterministic Automation (Core Requirement)

**Implementation**: Scheduled Lambda Function

**Responsibilities**:
1. **Auto-Complete Projects**
   - Check all projects where `endDate < current_date`
   - Update status from `ACTIVE` → `COMPLETED`
   - Log all transitions for audit trail

2. **Close Registration**
   - Check projects where `registrationEndDate < current_date`
   - Mark registration as closed (if field exists)
   - Notify project owners

3. **Auto-Activate Projects**
   - Check projects where `startDate <= current_date` and status is `PENDING`
   - Update status to `ACTIVE`
   - Send activation notifications

**Technical Details**:
- **Trigger**: EventBridge scheduled rule (daily at 00:00 UTC)
- **Runtime**: Python 3.13 Lambda function
- **Execution Time**: ~30 seconds for 1000 projects
- **Cost**: Minimal (~$0.01/month)
- **Error Handling**: Retry logic with DLQ for failed updates

**Business Rules**:
```python
# Simple, predictable rules
if project.endDate < today and project.status == "ACTIVE":
    project.status = "COMPLETED"
    
if project.registrationEndDate < today:
    project.registrationOpen = False
    
if project.startDate <= today and project.status == "PENDING":
    project.status = "ACTIVE"
```

### Phase 2: AI Agent for Intelligent Insights (Enhancement)

**Implementation**: AI Agent with Strands Agents Framework

**Responsibilities**:
1. **Pre-Completion Analysis**
   - Analyze project 7 days before end date
   - Check participation levels vs. max participants
   - Suggest extensions if highly successful
   - Recommend cancellation if low participation

2. **Project Health Reports**
   - Weekly analysis of active projects
   - Identify at-risk projects (low engagement)
   - Suggest interventions or improvements
   - Generate insights for project organizers

3. **Smart Notifications**
   - Context-aware messages to project owners
   - Personalized recommendations based on project history
   - Follow-up suggestions for completed projects

4. **Pattern Recognition**
   - Identify successful project patterns
   - Recommend optimal dates/durations
   - Suggest similar projects based on past success

**Technical Details**:
- **Framework**: Strands Agents (AWS Bedrock integration)
- **Trigger**: EventBridge rules + manual invocations
- **Model**: Claude 3.5 Sonnet (balanced cost/performance)
- **Context**: Project data, historical metrics, user feedback
- **Output**: Recommendations, reports, notifications

**Example AI Agent Prompts**:
```
Analyze project "{project_name}" ending in 7 days:
- Current participants: {current}/{max}
- Registration trend: {trend}
- User feedback: {feedback_summary}

Should we:
1. Auto-complete as scheduled
2. Suggest extension to organizer
3. Recommend early closure
4. Create follow-up project

Provide reasoning and specific recommendations.
```

## Architecture

### Components

```
┌─────────────────────────────────────────────────────────────┐
│                     EventBridge Rules                        │
├─────────────────────────────────────────────────────────────┤
│  Daily 00:00 UTC  │  Weekly Reports  │  Pre-End Triggers   │
└────────┬────────────────────┬────────────────────┬──────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ Lifecycle Lambda │  │  AI Agent Lambda │  │  Notification    │
│  (Deterministic) │  │  (Intelligent)   │  │    Service       │
└────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘
         │                     │                      │
         ▼                     ▼                      ▼
┌─────────────────────────────────────────────────────────────┐
│                      DynamoDB Projects Table                 │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **Scheduled Trigger** → EventBridge fires at configured time
2. **Lifecycle Lambda** → Scans projects, applies deterministic rules
3. **Status Updates** → Updates DynamoDB with new statuses
4. **AI Agent Trigger** → For complex cases, invokes AI agent
5. **AI Analysis** → Agent analyzes context and generates recommendations
6. **Notifications** → Send emails/alerts to relevant stakeholders
7. **Audit Log** → Record all changes for compliance

## Implementation Phases

### Phase 1: Core Automation (Week 1)
- [ ] Create lifecycle Lambda function
- [ ] Implement date-based status transitions
- [ ] Add EventBridge scheduled rule
- [ ] Create audit logging
- [ ] Write unit and integration tests
- [ ] Deploy to staging environment
- [ ] Monitor for 1 week before production

### Phase 2: AI Integration (Week 2-3)
- [ ] Set up Strands Agents framework
- [ ] Create AI agent for project analysis
- [ ] Implement pre-completion checks
- [ ] Add recommendation engine
- [ ] Create notification templates
- [ ] Test AI agent responses
- [ ] Deploy to staging

### Phase 3: Reporting & Insights (Week 4)
- [ ] Build weekly health report generator
- [ ] Create dashboard for project metrics
- [ ] Implement pattern recognition
- [ ] Add historical analysis
- [ ] Create admin interface for overrides

## Benefits

### Deterministic Logic
✅ **Reliability**: Predictable, testable behavior
✅ **Performance**: Fast execution, low latency
✅ **Cost**: Minimal AWS costs
✅ **Simplicity**: Easy to understand and maintain

### AI Agent Enhancement
✅ **Intelligence**: Context-aware decision making
✅ **Flexibility**: Handles edge cases gracefully
✅ **Insights**: Provides actionable recommendations
✅ **Learning**: Improves over time with feedback

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Lambda fails to execute | Projects not auto-completed | CloudWatch alarms, DLQ, retry logic |
| Incorrect status transitions | Data integrity issues | Comprehensive testing, audit logs, rollback capability |
| AI agent makes wrong recommendations | User confusion | Human review required, confidence scores, override mechanism |
| High AI costs | Budget overrun | Rate limiting, caching, cost monitoring |
| Date timezone issues | Wrong completion times | Use UTC consistently, document clearly |

## Monitoring & Alerts

### Metrics to Track
- Number of projects auto-completed daily
- Lambda execution duration and errors
- AI agent invocation count and cost
- Notification delivery success rate
- User override frequency

### Alerts
- Lambda execution failures
- Unexpected status transitions
- AI agent errors or timeouts
- Cost threshold breaches
- Audit log anomalies

## Success Criteria

1. **Automation**: 100% of expired projects auto-completed within 24 hours
2. **Accuracy**: <0.1% incorrect status transitions
3. **Performance**: Lambda execution <5 seconds
4. **Cost**: <$10/month for automation
5. **User Satisfaction**: Positive feedback from project organizers

## Future Enhancements

- **Predictive Analytics**: Forecast project success before launch
- **Auto-Scheduling**: Suggest optimal project dates
- **Capacity Planning**: Recommend participant limits
- **Multi-Language**: AI-generated notifications in user's language
- **Integration**: Connect with external calendar systems

## References

- [Project Model](../api/models/project.md)
- [Projects Service](../api/services/projects-service.md)
- [Lambda Deployment Guide](../infrastructure/lambda-deployment.md)
- [Strands Agents Documentation](https://docs.strands.ai/)

---

**Document Status**: Draft
**Last Updated**: 2025-11-29
**Owner**: Development Team
**Reviewers**: Product, Engineering, Operations
