# 🔐 IAM Permissions Fix Required - Admin Authentication Issue

**Issue Date**: August 15, 2025 16:05 UTC  
**Status**: 🚨 **CRITICAL - IAM PERMISSIONS MISSING**  
**Impact**: Admin authentication failing due to missing DynamoDB permissions  

## 🚨 **ROOT CAUSE IDENTIFIED**

### **Issue Summary**
The admin authentication is failing because the Auth Lambda function lacks IAM permissions to access the `people-registry-roles` DynamoDB table.

### **Error Evidence**
```
Error getting user roles for e3cb7dad-82e8-46d2-8927-1397e03f59a9: 
An error occurred (AccessDeniedException) when calling the Query operation: 
User: arn:aws:sts::142728997126:assumed-role/PeopleRegisterInfrastruct-AuthFunctionServiceRole87-YRr6GWjkModd/PeopleRegisterInfrastructureS-AuthFunctionA1CD5E0F-lujBJmLNxohb 
is not authorized to perform: dynamodb:Query on resource: 
arn:aws:dynamodb:us-east-1:142728997126:table/people-registry-roles
```

### **Current IAM Policy**
The Auth Lambda function (`PeopleRegisterInfrastructureS-AuthFunctionA1CD5E0F-lujBJmLNxohb`) currently has DynamoDB permissions for:
- ✅ `AuditLogsTable`
- ✅ `PeopleTable`
- ❌ `people-registry-roles` (MISSING)
- ❌ `AccountLockoutTable` (MISSING)

## 🔍 **TECHNICAL ANALYSIS**

### **Authentication Flow Breakdown**
1. ✅ **User logs in** - Auth service called
2. ✅ **RBAC system invoked** - `roles_service.user_is_admin()` called
3. ❌ **DynamoDB Query fails** - AccessDeniedException on `people-registry-roles` table
4. ✅ **Exception caught** - Roles service returns `[RoleType.USER]` as fallback
5. ❌ **Admin check fails** - `is_admin_role([RoleType.USER])` returns `False`
6. ❌ **JWT token created** - `is_admin: false` in token
7. ❌ **Frontend hides admin button** - No admin access granted

### **Why Our Database Fallback Didn't Trigger**
Our database fallback mechanism in the Auth service wasn't triggered because:
- The RBAC system didn't throw an exception to the Auth service level
- The roles service caught the DynamoDB exception internally
- The roles service returned the default `[RoleType.USER]` as designed
- The Auth service received a valid response (not an exception)

## 🛠️ **REQUIRED FIX**

### **Infrastructure Change Needed**
The CDK stack needs to be updated to grant the Auth Lambda function permissions to access:

1. **people-registry-roles table**
   ```json
   {
     "Action": [
       "dynamodb:Query",
       "dynamodb:GetItem",
       "dynamodb:Scan"
     ],
     "Resource": [
       "arn:aws:dynamodb:us-east-1:142728997126:table/people-registry-roles",
       "arn:aws:dynamodb:us-east-1:142728997126:table/people-registry-roles/index/*"
     ],
     "Effect": "Allow"
   }
   ```

2. **AccountLockoutTable** (for complete functionality)
   ```json
   {
     "Action": [
       "dynamodb:GetItem",
       "dynamodb:PutItem",
       "dynamodb:DeleteItem",
       "dynamodb:UpdateItem"
     ],
     "Resource": [
       "arn:aws:dynamodb:us-east-1:142728997126:table/AccountLockoutTable"
     ],
     "Effect": "Allow"
   }
   ```

### **CDK Stack Location**
The fix needs to be applied in:
```
registry-infrastructure/people_register_infrastructure/people_register_infrastructure_stack.py
```

Look for the Auth Lambda function IAM role configuration and add the missing table permissions.

## 🎯 **EXPECTED OUTCOME AFTER FIX**

### **✅ After IAM Permissions Added**
1. **RBAC Query Succeeds** - Auth function can query `people-registry-roles` table
2. **Admin Roles Retrieved** - User's ADMIN and SUPER_ADMIN roles found
3. **Admin Check Passes** - `is_admin_role([RoleType.ADMIN, RoleType.SUPER_ADMIN])` returns `True`
4. **JWT Token Correct** - `is_admin: true` in token
5. **Frontend Shows Admin Button** - Full admin access granted
6. **Performance Endpoints Accessible** - All admin features work

### **🧪 Testing After Fix**
```bash
# 1. Deploy CDK changes
cd registry-infrastructure
npx cdk deploy

# 2. Test login
curl -X POST "https://2t9blvt2c1.execute-api.us-east-1.amazonaws.com/prod/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "sergio.rodriguez@cbba.cloud.org.bo", "password": "AdminTest123!"}'

# 3. Verify JWT token shows is_admin: true
echo "<jwt-payload>" | base64 -d

# 4. Test admin endpoint
curl "https://2t9blvt2c1.execute-api.us-east-1.amazonaws.com/prod/admin/performance/dashboard" \
  -H "Authorization: Bearer <jwt-token>"
```

## 📊 **IMPACT ASSESSMENT**

### **Current State**
- ❌ Admin authentication failing
- ❌ Performance monitoring inaccessible
- ❌ Admin features unavailable
- ❌ Phase 4 completion blocked

### **After Fix**
- ✅ Admin authentication working
- ✅ Performance monitoring accessible
- ✅ All admin features available
- ✅ Phase 4 completion unblocked

## 🚀 **PRIORITY: CRITICAL**

This is a **critical infrastructure fix** required to:
- Enable admin authentication
- Unblock Phase 4 completion
- Provide access to performance monitoring
- Complete the RBAC system integration

**The fix is straightforward - just add the missing DynamoDB table permissions to the Auth Lambda function's IAM role in the CDK stack.**
