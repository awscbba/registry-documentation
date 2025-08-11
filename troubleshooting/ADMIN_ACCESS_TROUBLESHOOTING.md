# Admin Access Troubleshooting Guide

**Last Updated**: 2025-08-11  
**Status**: ✅ Active Guide  

## 🚨 Common Admin Access Issues

### Issue 1: Admin Login Returns `"isAdmin": false`

**Symptoms**:
```json
{
  "success": true,
  "user": {
    "isAdmin": false  // ← Should be true for admin users
  }
}
```

**Root Cause**: Role format case sensitivity mismatch (Fixed 2025-08-11)

**Verification Steps**:
```bash
# 1. Check user roles in database
aws dynamodb query --table-name people-registry-roles \
  --key-condition-expression "user_id = :uid" \
  --expression-attribute-values '{":uid":{"S":"e3cb7dad-82e8-46d2-8927-1397e03f59a9"}}'

# 2. Test login endpoint
curl -X POST "https://api.awsugcbba.org/auth/user/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@awsugcbba.org", "password": "awsugcbba2025"}'
```

**Expected Database Response**:
```json
{
  "Items": [
    {
      "user_id": {"S": "e3cb7dad-82e8-46d2-8927-1397e03f59a9"},
      "role_type": {"S": "ADMIN"},
      "is_active": {"BOOL": true}
    },
    {
      "user_id": {"S": "e3cb7dad-82e8-46d2-8927-1397e03f59a9"},
      "role_type": {"S": "SUPER_ADMIN"},
      "is_active": {"BOOL": true}
    }
  ]
}
```

**Fix Status**: ✅ Resolved in `fix/rbac-case-insensitive-roles`

---

### Issue 2: `/auth/me` Endpoint Returns `"isAdmin": false`

**Symptoms**:
```bash
curl -X GET "https://api.awsugcbba.org/auth/me" \
  -H "Authorization: Bearer TOKEN"

# Returns:
{
  "user": {
    "isAdmin": false,  // ← Should be true
    "email": "admin@awsugcbba.org"
  }
}
```

**Root Cause**: Same as Issue 1 - RolesService not recognizing uppercase role formats

**Fix Status**: ✅ Resolved in `fix/rbac-case-insensitive-roles`

---

### Issue 3: Admin Dashboard Returns 403 Forbidden

**Symptoms**:
```bash
curl -X GET "https://api.awsugcbba.org/v2/admin/dashboard" \
  -H "Authorization: Bearer TOKEN"

# Returns:
{
  "detail": "Insufficient privileges. Admin access required."
}
```

**Root Cause**: Admin middleware using RolesService that fails to recognize admin roles

**Fix Status**: ✅ Resolved in `fix/rbac-case-insensitive-roles`

---

## 🔍 Diagnostic Commands

### Check User Roles in Database
```bash
# Replace USER_ID with actual user ID
aws dynamodb query --table-name people-registry-roles \
  --key-condition-expression "user_id = :uid" \
  --expression-attribute-values '{":uid":{"S":"USER_ID_HERE"}}'
```

### Check Roles by Email
```bash
# Replace EMAIL with actual email
aws dynamodb query --table-name people-registry-roles \
  --index-name email-index \
  --key-condition-expression "email = :email" \
  --expression-attribute-values '{":email":{"S":"admin@awsugcbba.org"}}'
```

### Test Authentication Flow
```bash
# 1. Login and capture token
TOKEN=$(curl -s -X POST "https://api.awsugcbba.org/auth/user/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@awsugcbba.org", "password": "awsugcbba2025"}' \
  | jq -r '.token')

# 2. Test /me endpoint
curl -X GET "https://api.awsugcbba.org/auth/me" \
  -H "Authorization: Bearer $TOKEN"

# 3. Test admin dashboard
curl -X GET "https://api.awsugcbba.org/v2/admin/dashboard" \
  -H "Authorization: Bearer $TOKEN"
```

### Verify Role Normalization (Local Testing)
```python
# Test the role normalization function
from src.services.roles_service import RolesService

rs = RolesService()

# Test cases that should work after fix
test_roles = ["ADMIN", "SUPER_ADMIN", "admin", "super_admin"]
for role in test_roles:
    normalized = rs._normalize_role_type(role)
    print(f"'{role}' -> '{normalized.value}'")
```

## 🛠️ Fix Implementation Details

### What Was Fixed (2025-08-11)

**File**: `src/services/roles_service.py`

**Problem**: 
```python
# This failed when database had "ADMIN" but enum expected "admin"
roles.append(RoleType(item["role_type"]))
```

**Solution**:
```python
# Added normalization to handle case variations
role_type_str = item["role_type"]
normalized_role = self._normalize_role_type(role_type_str)
if normalized_role:
    roles.append(normalized_role)
```

**Normalization Logic**:
- `"ADMIN"` → `RoleType.ADMIN` ("admin")
- `"SUPER_ADMIN"` → `RoleType.SUPER_ADMIN` ("super_admin")
- `"admin"` → `RoleType.ADMIN` ("admin")
- `"super_admin"` → `RoleType.SUPER_ADMIN` ("super_admin")
- Unknown roles → `RoleType.USER` ("user") with warning

## 📋 Verification Checklist

After deployment, verify these work correctly:

### ✅ Admin Login
- [ ] Login returns `"isAdmin": true`
- [ ] Token contains admin information
- [ ] No authentication errors

### ✅ /auth/me Endpoint
- [ ] Returns `"isAdmin": true` for admin users
- [ ] User information is complete
- [ ] No 401/403 errors

### ✅ Admin Dashboard
- [ ] Returns 200 status code
- [ ] Dashboard data is present
- [ ] No "Insufficient privileges" errors

### ✅ Admin Endpoints
- [ ] `/v2/admin/people` accessible
- [ ] `/v2/admin/projects` accessible
- [ ] `/v2/admin/subscriptions` accessible

## 🚨 Emergency Procedures

### If Admin Access Still Fails After Fix

1. **Check Deployment Status**:
   ```bash
   # Verify API is running latest version
   curl -X GET "https://api.awsugcbba.org/health"
   ```

2. **Verify Database Roles**:
   ```bash
   # Ensure roles exist and are active
   aws dynamodb scan --table-name people-registry-roles \
     --filter-expression "email = :email AND is_active = :active" \
     --expression-attribute-values '{
       ":email":{"S":"admin@awsugcbba.org"},
       ":active":{"BOOL":true}
     }'
   ```

3. **Manual Role Assignment** (if needed):
   ```bash
   # Add admin role manually
   aws dynamodb put-item --table-name people-registry-roles --item '{
     "user_id":{"S":"e3cb7dad-82e8-46d2-8927-1397e03f59a9"},
     "role_type":{"S":"ADMIN"},
     "email":{"S":"admin@awsugcbba.org"},
     "assigned_by":{"S":"emergency-fix"},
     "assigned_at":{"S":"2025-08-11T03:00:00.000Z"},
     "is_active":{"BOOL":true}
   }'
   ```

4. **Rollback Plan**:
   ```bash
   # If fix causes issues, revert the commit
   git revert 156d923
   git push origin main
   ```

## 📞 Escalation

If issues persist after following this guide:

1. **Check Logs**: Review CloudWatch logs for errors
2. **Verify Database**: Ensure DynamoDB table is accessible
3. **Test Locally**: Run local tests to isolate the issue
4. **Contact Team**: Escalate to development team with:
   - Error messages
   - User ID affected
   - Steps already attempted
   - Current system status

## 📚 Related Documentation

- [RBAC Case Sensitivity Fix](../fixes/RBAC_CASE_SENSITIVITY_FIX.md) - Detailed fix documentation
- [Role-Based Access Control](../security/ROLE_BASED_ACCESS_CONTROL.md) - RBAC system overview
- [RBAC Migration Guide](../security/RBAC_MIGRATION_GUIDE.md) - Migration documentation
- [Authentication System](../api/AUTHENTICATION_SYSTEM.md) - JWT authentication details
