# Cascade Deletion Issue - User Subscriptions

## Issue Summary

**Problem**: When users are deleted from the system, their associated subscriptions remain in the database, creating orphaned subscription records. This leads to inconsistent subscription counts displayed in the smart card and other UI components.

**Impact**: 
- Smart cards show incorrect subscription counts
- Data integrity issues in the database
- Potential confusion for administrators monitoring subscription metrics

## Root Cause Analysis

The `delete_person` method in `src/services/defensive_dynamodb_service.py` only deletes the person record but does not implement cascade deletion for associated subscriptions.

### Current Implementation (Problematic)
```python
@database_operation("delete_person")
async def delete_person(
    self, person_id: str, context: Optional[ErrorContext] = None
) -> bool:
    """Delete a person with defensive programming"""
    try:
        # Check if person exists first
        existing_person = await self.get_person(person_id, context)
        if not existing_person:
            return False

        self.table.delete_item(Key={"id": person_id})  # Only deletes person
        return True

    except Exception as e:
        self.logger.error(f"Error deleting person {person_id}: {e}")
        raise
```

## Analysis Results

Using the analysis tools, we discovered:
- **Total People**: 4
- **Total Subscriptions**: 14
- **Valid Subscriptions**: 2
- **Orphaned Subscriptions**: 12

This explains why smart cards show 14 subscriptions when only 4 users exist.

## Solution

### Immediate Fix (Data Cleanup)
Use the provided just tasks to clean up existing orphaned subscriptions:

```bash
# Analyze the issue
just analyze-cascade-deletion

# Clean up orphaned subscriptions
just fix-cascade-deletion
```

### Long-term Fix (Code Implementation)

Replace the `delete_person` method with proper cascade deletion:

```python
@database_operation("delete_person")
async def delete_person(
    self, person_id: str, context: Optional[ErrorContext] = None
) -> bool:
    """Delete a person with cascade deletion of subscriptions"""
    try:
        # Check if person exists first
        existing_person = await self.get_person(person_id, context)
        if not existing_person:
            return False

        # Get all subscriptions for this person
        person_subscriptions = await self.get_subscriptions_by_person(person_id)
        
        # Delete all subscriptions first (cascade deletion)
        deleted_subscriptions = 0
        for subscription in person_subscriptions:
            subscription_id = subscription.get('id')
            if subscription_id:
                try:
                    success = await self.delete_subscription(subscription_id)
                    if success:
                        deleted_subscriptions += 1
                        self.logger.info(f"Deleted subscription {subscription_id} for person {person_id}")
                except Exception as e:
                    self.logger.error(f"Error deleting subscription {subscription_id}: {e}")
        
        self.logger.info(f"Deleted {deleted_subscriptions} subscriptions for person {person_id}")
        
        # Now delete the person
        self.table.delete_item(Key={"id": person_id})
        return True

    except Exception as e:
        self.logger.error(f"Error deleting person {person_id}: {e}")
        raise
```

## Implementation Steps

1. **Create Feature Branch**
   ```bash
   git checkout -b fix/cascade-deletion-subscriptions
   ```

2. **Update Code**
   - Modify `src/services/defensive_dynamodb_service.py`
   - Replace the `delete_person` method with the fixed version above

3. **Test Changes**
   - Create test user with subscriptions
   - Delete the user
   - Verify subscriptions are also deleted
   - Check subscription count accuracy

4. **Create PR**
   - Never push directly to main
   - Create PR for review
   - Include test results

5. **Deploy**
   - Use CodeCatalyst pipelines for deployment
   - Monitor deployment for any issues

## Available Tools

### Just Tasks
- `just analyze-cascade-deletion` - Analyze orphaned subscriptions (read-only)
- `just fix-cascade-deletion` - Clean up orphaned subscriptions + provide code fix
- `just check-subscription-integrity` - Monitor data consistency

### Scripts Location
- `registry-api/scripts/analyze_cascade_deletion_simple.py`
- `registry-api/scripts/fix_cascade_deletion_simple.py`

## Prevention

To prevent this issue in the future:

1. **Code Reviews**: Ensure all deletion operations consider cascade effects
2. **Testing**: Include cascade deletion tests in the test suite
3. **Monitoring**: Regular integrity checks using the provided tools
4. **Documentation**: Update API documentation to reflect cascade behavior

## Related Issues

This issue is part of a broader pattern of data integrity concerns. Consider reviewing other deletion operations for similar cascade requirements:

- Project deletion (should clean up subscriptions)
- Subscription status changes
- Bulk operations

## Testing Verification

After implementing the fix, verify with:

```bash
# Before fix - should show orphaned subscriptions
just analyze-cascade-deletion

# Apply the code fix and test
# Create test user with subscriptions
# Delete the user
# Verify subscriptions are gone

# After fix - should show clean data
just check-subscription-integrity
```

## Architecture Considerations

This fix aligns with the lambda architecture patterns:
- **API Lambda**: Handles the deletion requests
- **Routes Lambda**: Manages the routing to deletion endpoints
- **Database Service**: Implements the cascade deletion logic

The fix maintains the defensive programming approach used throughout the codebase while ensuring data consistency.
