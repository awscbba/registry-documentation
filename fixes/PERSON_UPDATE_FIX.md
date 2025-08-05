# Person Update Fix - Missing Field Handlers

## Issue
The person update functionality was returning 500 Internal Server Error when trying to update people via the v2 API endpoint. The error was occurring because the `update_person` method in the DynamoDB service was missing handlers for several fields that are defined in the `PersonUpdate` model.

## Root Cause
The `update_person` method in `src/services/dynamodb_service.py` was only handling a subset of the fields defined in the `PersonUpdate` model:

**Missing field handlers:**
- `is_admin` (alias: `isAdmin`)
- `is_active` (alias: `isActive`) 
- `failed_login_attempts` (alias: `failedLoginAttempts`)
- `account_locked_until` (alias: `accountLockedUntil`)

When these fields were included in a person update request, they would be ignored by the database service, but the API would still try to process them, leading to inconsistent state and potential errors.

## Solution
Added the missing field handlers to the `update_person` method in `src/services/dynamodb_service.py`:

```python
elif field == "is_admin":
    update_expression += ", isAdmin = :is_admin"
    expression_attribute_values[":is_admin"] = value
elif field == "is_active":
    update_expression += ", isActive = :is_active"
    expression_attribute_values[":is_active"] = value
elif field == "failed_login_attempts":
    update_expression += ", failedLoginAttempts = :failed_login_attempts"
    expression_attribute_values[":failed_login_attempts"] = value
elif field == "account_locked_until":
    update_expression += ", accountLockedUntil = :account_locked_until"
    expression_attribute_values[":account_locked_until"] = value.isoformat() if value else None
```

## Files Modified
- `src/services/dynamodb_service.py` - Added missing field handlers in `update_person` method

## Tests Added
- `tests/test_person_update_fix.py` - Comprehensive tests for person update functionality
  - Tests API endpoint with all PersonUpdate fields
  - Tests PersonUpdate model validation
  - Tests partial updates
  - Added to critical test suite

## Verification
1. **Model Validation**: All PersonUpdate fields are properly validated and accessible
2. **API Integration**: The v2 person update endpoint now handles all fields correctly
3. **Database Integration**: The database service properly processes all PersonUpdate fields
4. **Critical Tests**: All critical tests pass, including the new person update tests

## Impact
- ✅ Person updates via v2 API now work correctly
- ✅ Admin fields (`isAdmin`, `isActive`, `failedLoginAttempts`) can be updated
- ✅ No breaking changes to existing functionality
- ✅ Comprehensive test coverage added

## API Endpoint
```
PUT /v2/people/{person_id}
```

**Supported fields:**
- `firstName` / `first_name`
- `lastName` / `last_name`
- `email`
- `phone`
- `dateOfBirth` / `date_of_birth`
- `address`
- `isAdmin` / `is_admin` ✅ **Now supported**
- `isActive` / `is_active` ✅ **Now supported**
- `failedLoginAttempts` / `failed_login_attempts` ✅ **Now supported**
- `accountLockedUntil` / `account_locked_until` ✅ **Now supported**

## Testing
Run the critical tests to verify the fix:
```bash
just test-critical-passing
```

Or run the specific person update tests:
```bash
uv run pytest tests/test_person_update_fix.py -v
```