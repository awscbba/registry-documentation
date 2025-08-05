# Production Risk Analysis Report
==================================================

## Summary
- **Total Issues Found**: 343
- **High Risk**: 9
- **Medium Risk**: 94
- **Low Risk**: 240

## Dynamodb Parameter Issues
Found 4 potential issues:

### 🔴 dynamodb_expression_names - HIGH Risk
- **File**: `src/services/dynamodb_service.py`
- **Line**: 1646
- **Pattern**: `ExpressionAttributeNames=expression_names if expression_names else None`
- **Description**: ExpressionAttributeNames conditional may pass empty dict to DynamoDB

### 🔴 dynamodb_expression_names - HIGH Risk
- **File**: `src/services/dynamodb_service.py`
- **Line**: 1796
- **Pattern**: `ExpressionAttributeNames=expression_names if expression_names else None`
- **Description**: ExpressionAttributeNames conditional may pass empty dict to DynamoDB

### 🟡 dynamodb_conditional_param - MEDIUM Risk
- **File**: `src/services/dynamodb_service.py`
- **Line**: 1646
- **Pattern**: `ExpressionAttributeNames=expression_names if expression_names else`
- **Description**: DynamoDB parameter with conditional assignment - verify empty handling

### 🟡 dynamodb_conditional_param - MEDIUM Risk
- **File**: `src/services/dynamodb_service.py`
- **Line**: 1796
- **Pattern**: `ExpressionAttributeNames=expression_names if expression_names else`
- **Description**: DynamoDB parameter with conditional assignment - verify empty handling

## Async Await Mismatches
Found 7 potential issues:

### 🔴 missing_await - HIGH Risk
- **File**: `src/handlers/people_handler.py`
- **Line**: 1884
- **Pattern**: `projects = db_service.get_all_projects()`
- **Description**: Async method 'get_all_projects' called without await

### 🔴 missing_await - HIGH Risk
- **File**: `src/handlers/people_handler.py`
- **Line**: 1919
- **Pattern**: `project = db_service.create_project(project_create, created_by)`
- **Description**: Async method 'create_project' called without await

### 🔴 missing_await - HIGH Risk
- **File**: `src/handlers/people_handler.py`
- **Line**: 1943
- **Pattern**: `updated_project = db_service.update_project(project_id, project_update)`
- **Description**: Async method 'update_project' called without await

### 🔴 missing_await - HIGH Risk
- **File**: `src/handlers/people_handler.py`
- **Line**: 1986
- **Pattern**: `subscriptions = db_service.get_all_subscriptions()`
- **Description**: Async method 'get_all_subscriptions' called without await

### 🔴 missing_await - HIGH Risk
- **File**: `src/handlers/people_handler.py`
- **Line**: 2031
- **Pattern**: `subscription = db_service.create_subscription(subscription_create)`
- **Description**: Async method 'create_subscription' called without await

### 🔴 missing_await - HIGH Risk
- **File**: `src/handlers/people_handler.py`
- **Line**: 2055
- **Pattern**: `updated_subscription = db_service.update_subscription(`
- **Description**: Async method 'update_subscription' called without await

### 🔴 missing_await - HIGH Risk
- **File**: `src/handlers/people_handler.py`
- **Line**: 2139
- **Pattern**: `created_subscription = db_service.create_subscription(subscription_create)`
- **Description**: Async method 'create_subscription' called without await

## Status: ✅ RESOLVED
All high-risk async/await issues have been fixed. The missing await keywords have been added to all database method calls.

## Related Scripts

The following maintenance scripts in `registry-api/scripts/` can help with ongoing monitoring:

- `api-frontend-compatibility-test.js` - Tests API compatibility
- `debug-api-responses.js` - Debug API response formats
- `fix-critical-api-issues.py` - Apply critical fixes

## Additional Risk Categories

The full analysis identified several other risk categories that are lower priority:

- **None Attribute Access**: 4 medium-risk issues
- **Empty Parameter Issues**: 2 medium-risk issues  
- **Exception Handling Gaps**: 86 medium-risk issues
- **Type Conversion Issues**: 238 low-risk issues

These represent opportunities for future code quality improvements but are not blocking production functionality.

---
*This document was moved from registry-api to registry-documentation for centralized documentation management.*