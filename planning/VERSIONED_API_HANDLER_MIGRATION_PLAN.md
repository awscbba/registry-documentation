# Migration Plan: Remove versioned_api_handler.py

## Current Status
- ✅ **Production**: Uses `modular_api_handler.py` (Service Registry pattern)
- ✅ **Main entry point**: `main.py` imports from `modular_api_handler`
- ⚠️ **Tests**: Still reference `versioned_api_handler.py`
- ⚠️ **Infrastructure scripts**: Still reference `versioned_api_handler.py`

## Migration Phases

### Phase 1: Update Test Files
**Files to update:**
- `tests/test_forgot_password_integration.py`
- `tests/test_person_update_fix.py`
- `tests/test_auth_endpoints.py`
- `tests/test_project_new_fields_integration.py`
- `tests/test_async_correctness.py`
- `tests/test_service_registry_validation.py`
- `tests/test_service_registry_integration.py`

**Changes needed:**
```python
# Change from:
from src.handlers.versioned_api_handler import app

# Change to:
from src.handlers.modular_api_handler import app
```

### Phase 2: Update Infrastructure Scripts
**Files to update:**
- `registry-infrastructure/scripts/validate_architecture_e2e.py`
- `registry-infrastructure/scripts/validate_phase5b_advanced_features.py`
- `registry-infrastructure/scripts/role_based_access_control_summary.py`
- `registry-infrastructure/scripts/validate_monitoring.py`
- `registry-infrastructure/scripts/test_end_to_end.py`
- `registry-infrastructure/scripts/validate_monitoring_code.py`
- `registry-infrastructure/scripts/debug_password_hash_issue.py`

**Changes needed:**
- Update file path references
- Update validation logic to check modular handler

### Phase 3: Remove Deprecated File
**Actions:**
1. Delete `src/handlers/versioned_api_handler.py`
2. Update any remaining documentation
3. Clean up migration scripts

## Benefits of Removal
- ✅ **Cleaner codebase** - Remove deprecated code
- ✅ **Avoid confusion** - Single source of truth for API handling
- ✅ **Reduced maintenance** - No need to maintain two handlers
- ✅ **Better architecture** - Full commitment to Service Registry pattern

## Risks
- ⚠️ **Test failures** - Tests need to be updated first
- ⚠️ **Infrastructure validation** - Scripts need updates
- ⚠️ **Documentation** - References need updating

## Recommendation
**Start with Phase 1** - Update test files to use modular handler, then proceed with other phases once tests are passing.