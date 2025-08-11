# 🔄 RBAC Migration Guide: From Hardcoded to Database-Driven

> **Migration Type**: Security Enhancement  
> **Risk Level**: Medium  
> **Estimated Time**: 2-4 hours  
> **Rollback Available**: Yes

## 📋 Migration Overview

This guide provides step-by-step instructions for migrating from the hardcoded admin email system to the new database-driven Role-Based Access Control (RBAC) system.

### 🎯 Migration Goals

- ✅ Eliminate hardcoded admin emails from source code
- ✅ Implement flexible, database-driven role management
- ✅ Maintain existing admin access during transition
- ✅ Establish comprehensive audit trail
- ✅ Enable granular permission system

### ⚠️ Pre-Migration Checklist

- [ ] **Backup Current System**: Create full system backup
- [ ] **Document Current Admins**: List all current admin users
- [ ] **Test Environment Ready**: Staging environment available
- [ ] **Database Access**: DynamoDB permissions configured
- [ ] **Rollback Plan**: Rollback procedure documented
- [ ] **Team Notification**: Stakeholders informed of migration

## 🗂️ Current vs New System

### Current System (Hardcoded)
```python
# ❌ Hardcoded in admin_middleware.py
super_admin_emails = [
    "admin@cbba.cloud.org.bo",
    "admin@awsugcbba.org",
    "sergio.rodriguez.inclan@gmail.com",
]
```

### New System (Database-Driven)
```python
# ✅ Database lookup in admin_middleware_v2.py
is_super_admin = await roles_service.user_is_super_admin(user_id)
```

## 🚀 Migration Steps

### Phase 1: Infrastructure Setup

#### Step 1.1: Create DynamoDB Tables

```bash
cd registry-infrastructure/scripts
python create_roles_table.py
```

**Expected Output:**
```
✅ Table 'people-registry-roles' created successfully!
✅ Audit log table 'people-registry-audit-logs' created successfully!
```

**Verification:**
```bash
aws dynamodb describe-table --table-name people-registry-roles --region us-east-1
```

#### Step 1.2: Verify Table Structure

Check that tables have correct schema:

```bash
aws dynamodb describe-table --table-name people-registry-roles --query 'Table.{TableName:TableName,KeySchema:KeySchema,GlobalSecondaryIndexes:GlobalSecondaryIndexes[].IndexName}'
```

### Phase 2: Code Deployment

#### Step 2.1: Deploy New Code Components

Deploy the following new files to your API:

```bash
# Copy new role system files
cp src/models/roles.py registry-api/src/models/
cp src/services/roles_service.py registry-api/src/services/
cp src/middleware/admin_middleware_v2.py registry-api/src/middleware/
cp src/handlers/roles_handler.py registry-api/src/handlers/
```

#### Step 2.2: Update Application Imports

**⚠️ Critical**: Do NOT update imports yet. Keep both systems running in parallel.

### Phase 3: Data Migration

#### Step 3.1: Run Migration Script

```bash
cd registry-api/scripts
python migrate_admin_roles.py
```

**Expected Output:**
```
✅ admin@cbba.cloud.org.bo (super_admin) - ASSIGNED
✅ admin@awsugcbba.org (super_admin) - ASSIGNED  
✅ sergio.rodriguez.inclan@gmail.com (super_admin) - ASSIGNED

Migration completed successfully!
```

#### Step 3.2: Verify Migration

Check that roles were created correctly:

```bash
# Query roles table
aws dynamodb scan --table-name people-registry-roles --region us-east-1
```

#### Step 3.3: Test New System

Test the new role system without switching over:

```python
# Test script
from src.services.roles_service import RolesService

roles_service = RolesService()

# Test each migrated admin
test_emails = [
    "admin@cbba.cloud.org.bo",
    "admin@awsugcbba.org", 
    "sergio.rodriguez.inclan@gmail.com"
]

for email in test_emails:
    roles = await roles_service.get_user_roles_by_email(email)
    print(f"{email}: {[r.value for r in roles]}")
```

### Phase 4: System Switchover

#### Step 4.1: Update Application Imports

**⚠️ This is the critical switchover point**

Update your application to use the new middleware:

```python
# In your route handlers, replace:
from src.middleware.admin_middleware import require_admin_access

# With:
from src.middleware.admin_middleware_v2 import require_admin_access
```

#### Step 4.2: Update Route Registrations

If you have role management endpoints, register them:

```python
# In your main application file
from src.handlers.roles_handler import router as roles_router
app.include_router(roles_router)
```

#### Step 4.3: Deploy Updated Application

Deploy the application with updated imports:

```bash
# Deploy to staging first
./deploy-staging.sh

# Test staging thoroughly
./test-staging.sh

# Deploy to production
./deploy-production.sh
```

### Phase 5: Verification & Testing

#### Step 5.1: Functional Testing

Test all admin functions:

```bash
# Test admin login
curl -X POST /auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@cbba.cloud.org.bo","password":"admin123"}'

# Test admin endpoints
curl -X GET /api/v1/admin/users \
  -H "Authorization: Bearer <token>"

# Test role management
curl -X GET /api/v1/roles/my-roles \
  -H "Authorization: Bearer <token>"
```

#### Step 5.2: Permission Testing

Verify permission system works:

```bash
# Test different permission levels
curl -X GET /api/v1/roles/check-permission/read_all_users \
  -H "Authorization: Bearer <admin_token>"

curl -X GET /api/v1/roles/check-permission/manage_roles \
  -H "Authorization: Bearer <super_admin_token>"
```

#### Step 5.3: Audit Trail Verification

Check that audit logging works:

```bash
# Check audit logs
aws dynamodb scan --table-name people-registry-audit-logs --region us-east-1
```

### Phase 6: Cleanup

#### Step 6.1: Remove Hardcoded Emails

**⚠️ Only after successful verification**

Remove hardcoded emails from old middleware:

```python
# In admin_middleware.py, comment out or remove:
# super_admin_emails = [
#     "admin@cbba.cloud.org.bo",
#     "admin@awsugcbba.org",
#     "sergio.rodriguez.inclan@gmail.com",
# ]
```

#### Step 6.2: Update Documentation

Update any documentation that references hardcoded admins.

#### Step 6.3: Security Review

Conduct final security review:
- [ ] No hardcoded credentials in source code
- [ ] All admin access goes through database
- [ ] Audit trail is working
- [ ] Permission system is functional

## 🔄 Rollback Procedure

If issues occur during migration, follow this rollback procedure:

### Immediate Rollback (Code Level)

```python
# Revert imports back to old middleware
from src.middleware.admin_middleware import require_admin_access
```

### Database Rollback

```bash
# If needed, clear roles table
aws dynamodb delete-table --table-name people-registry-roles --region us-east-1
aws dynamodb delete-table --table-name people-registry-audit-logs --region us-east-1
```

### Application Rollback

```bash
# Deploy previous version
git checkout <previous_commit>
./deploy-production.sh
```

## 🧪 Testing Checklist

### Pre-Migration Tests
- [ ] Current admin system works
- [ ] All admin users can access admin functions
- [ ] Backup is complete and verified

### Post-Migration Tests
- [ ] All migrated admins can log in
- [ ] Admin functions work with new system
- [ ] Role management endpoints work
- [ ] Permission system functions correctly
- [ ] Audit logging is working
- [ ] No hardcoded credentials remain in code

### Performance Tests
- [ ] Authentication response time < 200ms
- [ ] Authorization check time < 100ms
- [ ] Database queries are optimized
- [ ] No performance degradation

## 📊 Migration Monitoring

### Key Metrics to Monitor

1. **Authentication Success Rate**
   - Target: > 99.5%
   - Monitor for 24 hours post-migration

2. **Authorization Errors**
   - Target: 0 false negatives
   - Monitor admin access patterns

3. **Database Performance**
   - Query response time < 100ms
   - Monitor DynamoDB metrics

4. **Audit Log Completeness**
   - All admin actions logged
   - No missing audit entries

### Monitoring Commands

```bash
# Check authentication metrics
aws logs filter-log-events --log-group-name /aws/lambda/auth-function

# Check authorization metrics  
aws logs filter-log-events --log-group-name /aws/lambda/api-function

# Check DynamoDB metrics
aws cloudwatch get-metric-statistics --namespace AWS/DynamoDB --metric-name ConsumedReadCapacityUnits
```

## 🚨 Troubleshooting

### Common Issues

#### Issue: Migration Script Fails
**Symptoms**: Script reports errors during role assignment
**Solutions**:
1. Check DynamoDB table exists and is accessible
2. Verify AWS credentials have proper permissions
3. Ensure user records exist in users table
4. Check network connectivity to DynamoDB

#### Issue: Admin Access Denied After Migration
**Symptoms**: Previously working admin users get 403 errors
**Solutions**:
1. Verify roles were migrated correctly in database
2. Check that new middleware is being used
3. Confirm user ID mapping is correct
4. Validate JWT token is valid

#### Issue: Permission Checks Failing
**Symptoms**: Users with correct roles get permission denied
**Solutions**:
1. Check role-permission mapping in code
2. Verify database role records are active
3. Confirm permission enum values match
4. Check for role expiration

### Debug Commands

```bash
# Check user roles in database
aws dynamodb query --table-name people-registry-roles \
  --key-condition-expression "user_id = :uid" \
  --expression-attribute-values '{":uid":{"S":"<user_id>"}}'

# Check audit logs for errors
aws dynamodb scan --table-name people-registry-audit-logs \
  --filter-expression "success = :false" \
  --expression-attribute-values '{":false":{"BOOL":false}}'

# Enable debug logging
export LOG_LEVEL=DEBUG
```

## 📞 Support Contacts

### Migration Support Team
- **Lead Developer**: [Contact Information]
- **Database Administrator**: [Contact Information]  
- **Security Team**: [Contact Information]

### Emergency Contacts
- **On-Call Engineer**: [Emergency Contact]
- **System Administrator**: [Emergency Contact]

## 📅 Post-Migration Tasks

### Immediate (24 hours)
- [ ] Monitor system metrics
- [ ] Verify all admin functions
- [ ] Check audit log completeness
- [ ] Confirm no security issues

### Short-term (1 week)
- [ ] Performance optimization
- [ ] User feedback collection
- [ ] Documentation updates
- [ ] Training for admin users

### Long-term (1 month)
- [ ] Security review and audit
- [ ] System optimization
- [ ] Feature enhancements
- [ ] Compliance verification

---

> **⚠️ Critical Reminder**: This migration affects system security. Ensure thorough testing in staging environment before production deployment. Have rollback plan ready and team standing by during migration window.

**Migration Prepared By**: Development Team  
**Reviewed By**: Security Team  
**Approved By**: Technical Lead
