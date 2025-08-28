# Database Field Standardization Migration Plan

## Overview

This document outlines a comprehensive plan for standardizing field naming conventions across the People Registry system. Currently, the system uses a hybrid approach with both camelCase and snake_case field names in DynamoDB storage, which creates maintenance complexity and potential for errors.

## Current State Analysis

### Field Naming Inconsistencies

**Fields stored as camelCase in DynamoDB:**
- `firstName`, `lastName`, `dateOfBirth`
- `isAdmin`, `failedLoginAttempts`, `accountLockedUntil`
- `lastLoginAt`, `requirePasswordChange`

**Fields stored as snake_case in DynamoDB:**
- `is_active`, `email_verified`, `password_hash`, `password_salt`
- `last_password_change`, `created_at`, `updated_at`

**Fields with consistent naming:**
- `email`, `phone` (simple fields)

### Impact Assessment

**Systems Affected:**
- DynamoDB People table (primary concern)
- API responses (currently use camelCase)
- Frontend applications (expect camelCase)
- Authentication tokens (contain camelCase fields)
- Password reset service (uses camelCase)
- Admin interfaces (read/write mixed formats)

**Risk Level: HIGH**
- 25+ existing users with data in mixed formats
- Authentication system dependencies
- Zero-downtime requirement for production

## Migration Strategy

### Phase 1: Preparation and Safety Measures (Weeks 1-2)

#### 1.1 Complete Field Mapping Implementation ✅
- [x] Update field mappings in `DefensiveDynamoDBService`
- [x] Refactor methods to use `safe_update_expression_builder`
- [x] Add comprehensive tests for field mapping consistency

#### 1.2 Data Backup and Analysis
```bash
# Create full backup of People table
aws dynamodb create-backup \
    --table-name PeopleTable \
    --backup-name "pre-field-standardization-backup-$(date +%Y%m%d)"

# Export current data for analysis
aws dynamodb scan \
    --table-name PeopleTable \
    --output json > people_table_current_state.json
```

#### 1.3 Field Usage Analysis Script
```python
# Create script to analyze field usage patterns
def analyze_field_usage(data_export):
    """Analyze which fields use camelCase vs snake_case"""
    camel_case_fields = set()
    snake_case_fields = set()
    
    for item in data_export['Items']:
        for field_name in item.keys():
            if '_' in field_name:
                snake_case_fields.add(field_name)
            elif field_name[0].islower() and any(c.isupper() for c in field_name):
                camel_case_fields.add(field_name)
    
    return camel_case_fields, snake_case_fields
```

#### 1.4 Migration Testing Environment
- Set up isolated test environment with production data copy
- Test all migration scripts with real data
- Validate API compatibility during transition

### Phase 2: Dual-Field Support Implementation (Weeks 3-4)

#### 2.1 Implement Dual-Field Reading
```python
class DualFieldDynamoDBService(DefensiveDynamoDBService):
    """Service that can read both old and new field formats"""
    
    def _normalize_person_item(self, item: Dict[str, Any]) -> Dict[str, Any]:
        """Normalize item to use consistent field names"""
        normalized = {}
        
        # Handle dual field support
        field_mappings = {
            'firstName': 'first_name',
            'lastName': 'last_name',
            'dateOfBirth': 'date_of_birth',
            'isAdmin': 'is_admin',
            'failedLoginAttempts': 'failed_login_attempts',
            'accountLockedUntil': 'account_locked_until',
            'lastLoginAt': 'last_login_at',
            'requirePasswordChange': 'require_password_change',
        }
        
        for old_field, new_field in field_mappings.items():
            # Prefer new format, fall back to old format
            if new_field in item:
                normalized[new_field] = item[new_field]
            elif old_field in item:
                normalized[new_field] = item[old_field]
        
        return normalized
```

#### 2.2 Implement Dual-Field Writing
```python
def safe_dual_field_update(update_data: Dict[str, Any]) -> Dict[str, Any]:
    """Write to both old and new field formats during transition"""
    dual_update = {}
    
    field_mappings = {
        'first_name': 'firstName',
        'last_name': 'lastName',
        # ... other mappings
    }
    
    for snake_field, camel_field in field_mappings.items():
        if snake_field in update_data:
            # Write to both formats
            dual_update[snake_field] = update_data[snake_field]
            dual_update[camel_field] = update_data[snake_field]
    
    return dual_update
```

#### 2.3 Update API Layer
- Modify API responses to use consistent camelCase (maintain compatibility)
- Update request parsing to handle both formats
- Add deprecation warnings for old field usage

### Phase 3: Data Migration Execution (Weeks 5-6)

#### 3.1 Migration Script Development
```python
import boto3
from typing import Dict, Any, List
import time

class FieldStandardizationMigrator:
    def __init__(self, table_name: str, dry_run: bool = True):
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table(table_name)
        self.dry_run = dry_run
        
    def migrate_person_fields(self, batch_size: int = 25):
        """Migrate person records to standardized field names"""
        
        # Field migration mappings
        migrations = {
            'firstName': 'first_name',
            'lastName': 'last_name',
            'dateOfBirth': 'date_of_birth',
            'isAdmin': 'is_admin',
            'failedLoginAttempts': 'failed_login_attempts',
            'accountLockedUntil': 'account_locked_until',
            'lastLoginAt': 'last_login_at',
            'requirePasswordChange': 'require_password_change',
        }
        
        # Scan all items
        paginator = self.table.scan()
        
        for page in paginator:
            items_to_update = []
            
            for item in page.get('Items', []):
                update_needed = False
                update_expression_parts = []
                expression_values = {}
                
                for old_field, new_field in migrations.items():
                    if old_field in item and new_field not in item:
                        update_needed = True
                        update_expression_parts.append(f"{new_field} = :{new_field}")
                        expression_values[f":{new_field}"] = item[old_field]
                
                if update_needed:
                    items_to_update.append({
                        'id': item['id'],
                        'update_expression': "SET " + ", ".join(update_expression_parts),
                        'expression_values': expression_values
                    })
            
            # Execute batch updates
            if items_to_update and not self.dry_run:
                self._execute_batch_updates(items_to_update)
            
            # Rate limiting
            time.sleep(0.1)
    
    def _execute_batch_updates(self, updates: List[Dict[str, Any]]):
        """Execute batch updates with error handling"""
        for update in updates:
            try:
                self.table.update_item(
                    Key={'id': update['id']},
                    UpdateExpression=update['update_expression'],
                    ExpressionAttributeValues=update['expression_values']
                )
            except Exception as e:
                print(f"Error updating item {update['id']}: {e}")
```

#### 3.2 Migration Execution Plan
```bash
# 1. Run migration in dry-run mode
python migrate_fields.py --dry-run --table PeopleTable

# 2. Execute migration in small batches
python migrate_fields.py --batch-size 10 --table PeopleTable

# 3. Verify migration results
python verify_migration.py --table PeopleTable

# 4. Update field mappings to use new format
# (Deploy updated DefensiveDynamoDBService)
```

#### 3.3 Rollback Plan
```python
def rollback_field_migration():
    """Rollback migration if issues are detected"""
    
    # Restore from backup
    aws_cli_command = """
    aws dynamodb restore-table-from-backup \
        --target-table-name PeopleTable-rollback \
        --backup-arn {backup_arn}
    """
    
    # Or selective rollback using dual-field data
    rollback_mappings = {
        'first_name': 'firstName',
        'last_name': 'lastName',
        # ... reverse mappings
    }
```

### Phase 4: Cleanup and Optimization (Weeks 7-8)

#### 4.1 Remove Dual-Field Support
- Update services to use only standardized field names
- Remove old field reading logic
- Clean up deprecated API endpoints

#### 4.2 Data Cleanup
```python
def cleanup_old_fields():
    """Remove old camelCase fields after migration is complete"""
    
    old_fields_to_remove = [
        'firstName', 'lastName', 'dateOfBirth', 'isAdmin',
        'failedLoginAttempts', 'accountLockedUntil', 'lastLoginAt',
        'requirePasswordChange'
    ]
    
    # Remove old fields from all records
    for field in old_fields_to_remove:
        update_expression = f"REMOVE {field}"
        # Execute batch removal
```

#### 4.3 Performance Optimization
- Update indexes if needed for new field names
- Optimize queries for standardized fields
- Update monitoring and alerting for new field names

### Phase 5: Validation and Documentation (Week 9)

#### 5.1 Comprehensive Testing
- Run full test suite with standardized fields
- Performance testing with new field structure
- Integration testing with frontend applications

#### 5.2 Documentation Updates
- Update API documentation with new field names
- Update developer guides and examples
- Create migration completion report

## Risk Mitigation Strategies

### 1. Zero-Downtime Deployment
- Use blue-green deployment strategy
- Implement feature flags for field format switching
- Gradual rollout with canary deployments

### 2. Data Integrity Protection
- Comprehensive backups before each phase
- Validation scripts to verify data consistency
- Automated rollback triggers for critical errors

### 3. Monitoring and Alerting
```python
# Add monitoring for field access patterns
def monitor_field_access():
    """Monitor which field formats are being accessed"""
    
    metrics = {
        'camelCase_field_reads': 0,
        'snake_case_field_reads': 0,
        'migration_errors': 0
    }
    
    # CloudWatch metrics integration
```

### 4. Communication Plan
- Notify all stakeholders before each phase
- Provide migration timeline and expected impacts
- Create rollback communication procedures

## Success Criteria

### Technical Success Metrics
- [ ] 100% of records use standardized snake_case field names
- [ ] Zero data loss during migration
- [ ] API response times remain within 5% of baseline
- [ ] All tests pass with new field format

### Business Success Metrics
- [ ] No user-facing service interruptions
- [ ] Authentication system remains fully functional
- [ ] Admin interfaces work correctly with new format
- [ ] Frontend applications display data correctly

## Timeline Summary

| Phase | Duration | Key Deliverables |
|-------|----------|------------------|
| 1. Preparation | 2 weeks | Backups, analysis, test environment |
| 2. Dual-Field Support | 2 weeks | Backward-compatible reading/writing |
| 3. Data Migration | 2 weeks | Field standardization execution |
| 4. Cleanup | 2 weeks | Remove old fields, optimization |
| 5. Validation | 1 week | Testing, documentation |

**Total Duration: 9 weeks**

## Post-Migration Benefits

1. **Consistency**: All fields use snake_case convention
2. **Maintainability**: Simplified field mapping logic
3. **Developer Experience**: Consistent naming reduces confusion
4. **Performance**: Optimized queries with standardized fields
5. **Future-Proofing**: Easier to add new fields with consistent naming

## Conclusion

This migration plan provides a safe, systematic approach to standardizing field naming conventions while minimizing risk to production systems. The phased approach allows for validation at each step and provides multiple rollback opportunities if issues arise.

The key to success is thorough testing, comprehensive monitoring, and maintaining backward compatibility during the transition period.