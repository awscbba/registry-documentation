# Design Document

## Overview

Simple API pipeline with two workflows: validation for feature branches, deployment for main branch.

## Architecture

### Workflows

1. **Validation Workflow** - Feature branches + PRs
   - Test → Lint
   - ~3 minutes

2. **Deployment Workflow** - Main branch only  
   - Test → Lint → Deploy
   - ~5 minutes

### Branch Handling
Script-based filtering (no YAML patterns):
```bash
if [ "$CODECATALYST_SOURCE_BRANCH_NAME" = "main" ]; then
    exit 0  # Skip validation on main
fi
```

## Components

### Test Stage
- Run `pytest` with coverage
- Generate test report

### Lint Stage  
- Run `flake8` and `black`
- Generate lint report

### Deploy Stage (main only)
- Sync code to infrastructure repo
- Basic health check

## Error Handling

- **Test failures**: Show failed test details
- **Lint failures**: Show file/line issues  
- **Deploy failures**: Show sync/health errors
- **YAML errors**: Use simple, tested patterns

## Implementation

1. Fix current YAML syntax error
2. Create two simple workflows
3. Add script-based branch logic
4. Test and deploy