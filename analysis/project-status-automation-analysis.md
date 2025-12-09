# Project Status Automation Analysis

**Date:** December 8, 2025  
**Issue:** "Speakers Session final 2025" project is past due (ended Dec 5th) but still showing as active on the frontend

## Investigation Summary

### Current State
The project "Speakers Session final 2025" has an `endDate` of December 5, 2025, but its status has not been automatically updated to `completed`. The project is still being displayed on the frontend as an active/ongoing project.

### Root Cause
**There is NO automated job or scheduled task to update project statuses based on their end dates.**

#### What We Found:

1. **No Scheduled Lambda Functions**
   - Searched infrastructure code - no EventBridge rules or CloudWatch Events
   - No cron jobs or scheduled tasks configured
   - No Lambda functions with schedule triggers

2. **Manual Status Updates Only**
   - Project status updates only happen when:
     - An admin manually updates the project via the API
     - The `update_project` endpoint is called with a status change
   
3. **Existing Logic (But Not Automated)**
   - In `projects_service.py`, there IS logic to update subscription statuses when a project is marked as completed:
   ```python
   # If project status changed to completed or cancelled, update subscription statuses
   if updates.status and updates.status in [
       ProjectStatus.COMPLETED,
       ProjectStatus.CANCELLED,
   ]:
       await self._update_subscription_statuses(project_id, updates.status.value)
   ```
   - However, this only runs when someone manually changes the status

4. **No Background Jobs**
   - No scheduled tasks in the codebase
   - No workers or background job processors
   - No database triggers or stored procedures

## Impact

### Current Issues:
1. **Stale Data on Frontend** - Past-due projects show as active
2. **Manual Overhead** - Admins must manually update each project status
3. **User Confusion** - Users see projects they can't actually join
4. **Data Integrity** - Project status doesn't reflect reality

### Affected Projects:
- "Speakers Session final 2025" (ended Dec 5, 2025)
- Any other projects past their `endDate`

## Proposed Solutions

### Option 1: EventBridge Scheduled Rule (Recommended)
**Create a daily scheduled Lambda function to check and update project statuses**

**Pros:**
- Fully automated
- Runs independently of API traffic
- Can handle bulk updates efficiently
- Easy to monitor and debug

**Implementation:**
1. Create a new Lambda function: `update-project-statuses`
2. Schedule it to run daily at midnight UTC via EventBridge
3. Logic:
   ```python
   # Pseudo-code
   today = datetime.now().date()
   
   # Find projects that should be completed
   projects = get_projects_where(
       status IN ['pending', 'active', 'ongoing'],
       endDate < today
   )
   
   for project in projects:
       update_project_status(project.id, 'completed')
       update_subscription_statuses(project.id, 'completed')
   ```

**Estimated Effort:** 4-6 hours
- 2 hours: Lambda function development
- 1 hour: Infrastructure (CDK/Terraform)
- 1 hour: Testing
- 1 hour: Deployment and monitoring setup

### Option 2: API Middleware Check
**Check and update status on every project read**

**Pros:**
- No new infrastructure needed
- Immediate updates when projects are viewed

**Cons:**
- Performance overhead on every API call
- Doesn't update projects that aren't viewed
- Can cause race conditions with concurrent requests

**Not Recommended** - Too much overhead

### Option 3: Frontend-Triggered Update
**Frontend checks dates and triggers updates**

**Pros:**
- Simple to implement
- No backend changes needed initially

**Cons:**
- Unreliable (depends on frontend traffic)
- Security concerns (frontend shouldn't control backend state)
- Inconsistent data

**Not Recommended** - Poor architecture

## Recommended Implementation Plan

### Phase 1: Immediate Fix (Manual)
**Action:** Manually update "Speakers Session final 2025" status to `completed`

```bash
# Using API or database directly
UPDATE projects 
SET status = 'completed' 
WHERE name = 'Speakers Session final 2025';
```

### Phase 2: Automated Solution (1-2 days)
**Implement Option 1: EventBridge Scheduled Lambda**

#### Step 1: Create Lambda Function
File: `registry-infrastructure/lambda/update-project-statuses/index.py`

```python
import boto3
import os
from datetime import datetime, timezone
from typing import List, Dict

dynamodb = boto3.resource('dynamodb')
projects_table = dynamodb.Table(os.environ['PROJECTS_TABLE_NAME'])

def lambda_handler(event, context):
    """
    Scheduled Lambda to update project statuses based on end dates.
    Runs daily at midnight UTC.
    """
    today = datetime.now(timezone.utc).date().isoformat()
    
    # Scan for projects that should be completed
    response = projects_table.scan(
        FilterExpression='endDate < :today AND #status IN (:pending, :active, :ongoing)',
        ExpressionAttributeNames={
            '#status': 'status'
        },
        ExpressionAttributeValues={
            ':today': today,
            ':pending': 'pending',
            ':active': 'active',
            ':ongoing': 'ongoing'
        }
    )
    
    projects_to_update = response.get('Items', [])
    updated_count = 0
    
    for project in projects_to_update:
        try:
            # Update project status
            projects_table.update_item(
                Key={'id': project['id']},
                UpdateExpression='SET #status = :completed, updatedAt = :now',
                ExpressionAttributeNames={'#status': 'status'},
                ExpressionAttributeValues={
                    ':completed': 'completed',
                    ':now': datetime.now(timezone.utc).isoformat()
                }
            )
            
            # TODO: Also update related subscriptions
            # update_subscription_statuses(project['id'], 'completed')
            
            updated_count += 1
            print(f"Updated project {project['id']} ({project.get('name')}) to completed")
            
        except Exception as e:
            print(f"Error updating project {project['id']}: {str(e)}")
    
    return {
        'statusCode': 200,
        'body': {
            'message': f'Updated {updated_count} projects to completed status',
            'projectsChecked': len(projects_to_update)
        }
    }
```

#### Step 2: Add Infrastructure (CDK)
File: `registry-infrastructure/lib/scheduled-tasks-stack.ts`

```typescript
import * as cdk from 'aws-cdk-lib';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as events from 'aws-cdk-lib/aws-events';
import * as targets from 'aws-cdk-lib/aws-events-targets';
import * as iam from 'aws-cdk-lib/aws-iam';

export class ScheduledTasksStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Lambda function to update project statuses
    const updateProjectStatusesLambda = new lambda.Function(this, 'UpdateProjectStatuses', {
      runtime: lambda.Runtime.PYTHON_3_11,
      handler: 'index.lambda_handler',
      code: lambda.Code.fromAsset('lambda/update-project-statuses'),
      timeout: cdk.Duration.minutes(5),
      environment: {
        PROJECTS_TABLE_NAME: process.env.PROJECTS_TABLE_NAME!,
        SUBSCRIPTIONS_TABLE_NAME: process.env.SUBSCRIPTIONS_TABLE_NAME!,
      },
    });

    // Grant DynamoDB permissions
    updateProjectStatusesLambda.addToRolePolicy(new iam.PolicyStatement({
      actions: [
        'dynamodb:Scan',
        'dynamodb:UpdateItem',
        'dynamodb:Query',
      ],
      resources: [
        `arn:aws:dynamodb:${this.region}:${this.account}:table/${process.env.PROJECTS_TABLE_NAME}`,
        `arn:aws:dynamodb:${this.region}:${this.account}:table/${process.env.SUBSCRIPTIONS_TABLE_NAME}`,
      ],
    }));

    // EventBridge rule to run daily at midnight UTC
    const rule = new events.Rule(this, 'DailyProjectStatusUpdate', {
      schedule: events.Schedule.cron({
        minute: '0',
        hour: '0',
        day: '*',
        month: '*',
        year: '*',
      }),
      description: 'Daily check to update project statuses based on end dates',
    });

    // Add Lambda as target
    rule.addTarget(new targets.LambdaFunction(updateProjectStatusesLambda));
  }
}
```

#### Step 3: Testing
1. **Unit Tests** - Test Lambda logic with mock data
2. **Integration Tests** - Test with actual DynamoDB table (dev environment)
3. **Manual Trigger** - Invoke Lambda manually to verify it works
4. **Monitor First Run** - Watch CloudWatch logs for the first scheduled run

#### Step 4: Monitoring
- CloudWatch Logs for Lambda execution
- CloudWatch Metrics for success/failure rates
- SNS alerts for failures
- Dashboard showing:
  - Number of projects updated daily
  - Execution duration
  - Error rates

## Additional Considerations

### Future Enhancements:
1. **Registration End Date** - Also check `registrationEndDate` to close registrations
2. **Status Transitions** - Automatically move from `pending` → `active` on `startDate`
3. **Notifications** - Email admins when projects are auto-completed
4. **Audit Log** - Track all automated status changes

### Database Indexes:
Add indexes to improve query performance:
```python
# DynamoDB GSI
GSI: status-endDate-index
  - Partition Key: status
  - Sort Key: endDate
```

## Timeline

| Phase | Task | Duration | Owner |
|-------|------|----------|-------|
| 1 | Manual fix for current project | 15 min | Admin |
| 2 | Lambda function development | 2 hours | Backend Dev |
| 3 | Infrastructure code (CDK) | 1 hour | DevOps |
| 4 | Testing (unit + integration) | 2 hours | QA/Dev |
| 5 | Deployment to dev | 30 min | DevOps |
| 6 | Verification in dev | 1 hour | QA |
| 7 | Deployment to prod | 30 min | DevOps |
| 8 | Monitoring setup | 1 hour | DevOps |
| **Total** | | **8 hours** | |

## Conclusion

The root cause is clear: **no automated job exists to update project statuses**. The recommended solution is to implement a daily EventBridge-triggered Lambda function that checks project end dates and updates statuses accordingly.

This is a common pattern in production systems and should be straightforward to implement. The immediate fix is to manually update the "Speakers Session final 2025" project, followed by implementing the automated solution to prevent this issue in the future.
