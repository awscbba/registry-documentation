# Design Document

## Overview

This design implements a conditional workflow execution system for CodeCatalyst that runs validation stages on pull requests and full deployment stages on main branch pushes. The solution uses CodeCatalyst's trigger system and conditional logic to determine which stages to execute based on the event type and branch.

## Architecture

### Workflow Triggers

The workflow will be configured with multiple triggers:

1. **Pull Request Trigger**: Executes on pull request creation and updates
   - Runs validation stages only
   - Creates placeholder artifacts for skipped stages
   - Provides fast feedback to developers

2. **Main Branch Trigger**: Executes on pushes to main branch
   - Runs all stages including deployment
   - Performs actual infrastructure changes
   - Runs comprehensive testing

### Execution Modes

#### Validation Mode (Pull Requests)
- **Stages Executed**: CheckAPISync → PrepareAPIIntegration → ValidateInfrastructure
- **Stages Skipped**: DeployInfrastructure, PostDeploymentTests, NotifyDeploymentStatus
- **Artifacts**: Creates placeholder artifacts for compatibility
- **Duration**: ~5-10 minutes (fast feedback)

#### Deployment Mode (Main Branch)
- **Stages Executed**: All stages
- **Artifacts**: Creates real deployment artifacts
- **Duration**: ~15-30 minutes (full deployment cycle)

## Components and Interfaces

### Trigger Configuration

```yaml
Name: infrastructure-deployment
SchemaVersion: "1.0"

Triggers:
  - Type: PUSH
    Branches:
      - main
  - Type: PULLREQUEST
    Branches:
      - main
    Events:
      - PULLREQUEST_CREATED
      - PULLREQUEST_REVISION_CREATED
```

### Conditional Logic Implementation

Each action will implement conditional logic using environment variables:

```bash
# Determine execution mode
if [ "$CODECATALYST_TRIGGER_TYPE" = "PULLREQUEST" ]; then
    EXECUTION_MODE="validation"
else
    EXECUTION_MODE="deployment"
fi

# Branch-based logic (existing)
if [ "${CODECATALYST_SOURCE_BRANCH_NAME}" != "main" ]; then
    EXECUTION_MODE="validation"
fi
```

### Stage Modifications

#### CheckAPISync (Always Runs)
- No changes needed
- Runs in both validation and deployment modes

#### PrepareAPIIntegration (Always Runs)
- No changes needed
- Runs in both validation and deployment modes

#### ValidateInfrastructure (Always Runs)
- Enhanced to perform CDK synthesis validation
- Runs `cdk synth` to catch template errors
- Validates IAM permissions and resource configurations

#### DeployInfrastructure (Conditional)
- **Validation Mode**: Creates placeholder artifacts, skips actual deployment
- **Deployment Mode**: Performs actual CDK deployment

#### PostDeploymentTests (Conditional)
- **Validation Mode**: Creates placeholder test report
- **Deployment Mode**: Runs actual tests against deployed infrastructure

#### NotifyDeploymentStatus (Conditional)
- **Validation Mode**: Creates validation summary notification
- **Deployment Mode**: Creates deployment completion notification

## Data Models

### Execution Context

```json
{
  "execution_mode": "validation|deployment",
  "trigger_type": "PUSH|PULLREQUEST",
  "branch_name": "string",
  "is_main_branch": "boolean",
  "skip_deployment": "boolean",
  "skip_testing": "boolean"
}
```

### Validation Artifacts

```json
{
  "validation_summary": {
    "timestamp": "ISO8601",
    "execution_mode": "validation",
    "stages_executed": ["CheckAPISync", "PrepareAPIIntegration", "ValidateInfrastructure"],
    "stages_skipped": ["DeployInfrastructure", "PostDeploymentTests"],
    "validation_results": {
      "api_sync_status": "success|failed",
      "integration_status": "success|failed", 
      "infrastructure_status": "success|failed"
    }
  }
}
```

## Error Handling

### Validation Stage Failures
- Fail fast on validation errors
- Provide clear error messages for common issues
- Include suggestions for fixing configuration problems

### Artifact Compatibility
- Ensure placeholder artifacts maintain expected structure
- Handle missing real deployment data gracefully
- Provide clear indicators when using placeholder data

### Trigger Detection
- Robust detection of trigger type and branch
- Fallback to validation mode if trigger type is unclear
- Clear logging of execution mode decisions

## Testing Strategy

### Unit Testing
- Test conditional logic for different trigger types
- Validate artifact creation in both modes
- Test error handling for validation failures

### Integration Testing
- Test pull request workflow end-to-end
- Test main branch deployment workflow
- Verify artifact compatibility between modes

### Validation Testing
- Test CDK synthesis validation
- Test API integration validation
- Test infrastructure configuration validation

### Performance Testing
- Measure validation mode execution time
- Ensure fast feedback for pull requests
- Monitor resource usage in validation mode

## Implementation Phases

### Phase 1: Trigger Configuration
- Add pull request triggers to workflow
- Implement trigger type detection logic
- Test trigger activation for different events

### Phase 2: Conditional Stage Logic
- Modify each stage to support validation mode
- Implement placeholder artifact creation
- Add execution mode logging

### Phase 3: Enhanced Validation
- Improve ValidateInfrastructure stage
- Add CDK synthesis validation
- Enhance error reporting

### Phase 4: Testing and Refinement
- Test both execution modes thoroughly
- Optimize validation stage performance
- Refine error messages and logging

## Security Considerations

- Validation mode should not have access to production AWS credentials
- Pull request workflows should use limited permissions
- Sensitive information should not be exposed in validation logs
- Artifact storage should be properly secured

## Monitoring and Observability

- Track validation mode success/failure rates
- Monitor pull request feedback timing
- Alert on validation stage failures
- Dashboard for workflow execution metrics