# Table Standardization Plan - Comprehensive System Fix

**Date**: August 17, 2025  
**Status**: 🚨 **CRITICAL - IMMEDIATE ACTION REQUIRED**  
**Priority**: HIGH - Resolves password reset failure and prevents future issues  

---

## 🚨 CRITICAL ISSUE SUMMARY

### **Root Cause Identified**:
**Table naming inconsistencies** across the system causing data access failures:

1. **Password Reset Failure**: Token stored in wrong table due to name mismatch
2. **Multiple Naming Patterns**: PascalCase, kebab-case, snake_case all in use
3. **Missing Environment Variables**: Lambda functions lack table name configuration
4. **Hardcoded Table Names**: Services using different naming conventions

### **Impact**:
- ❌ Password reset completely broken (HTTP 400 errors)
- ⚠️ Potential data access failures in other services
- 🔄 Code duplication and maintenance complexity
- 📈 Risk of future similar failures

---

## 🔍 DISCOVERED INCONSISTENCIES

### **1. Table Naming Patterns Found**:

#### **Config Defaults (PascalCase)**:
```python
# src/core/config.py
"PeopleTable"
"ProjectsTable" 
"PasswordResetTokensTable"
"AuditLogsTable"
"SubscriptionsTable"
"SessionsTable"
```

#### **Repository Defaults (kebab-case)**:
```python
# src/repositories/
"people-registry"           # user_repository.py
"people-registry-projects"  # project_repository.py
```

#### **Service Hardcoded (kebab-case)**:
```python
# src/services/
"people-registry-roles"     # roles_service.py
"people-registry-users"     # roles_service.py
```

### **2. Environment Variable Status**:
```bash
# ALL MISSING IN LAMBDA:
PEOPLE_TABLE_NAME: NOT SET
PROJECTS_TABLE_NAME: NOT SET
PASSWORD_RESET_TOKENS_TABLE_NAME: NOT SET  # ← CRITICAL FOR PASSWORD RESET
AUDIT_LOGS_TABLE_NAME: NOT SET
SUBSCRIPTIONS_TABLE_NAME: NOT SET
SESSIONS_TABLE_NAME: NOT SET
```

### **3. Service Access Patterns**:

#### **✅ Correct Pattern (Config-based)**:
```python
# password_reset_service.py
table_name = self.config.database.password_reset_tokens_table
```

#### **❌ Inconsistent Patterns (Hardcoded)**:
```python
# roles_service.py
users_table = self.dynamodb.Table("people-registry-users")

# repositories
def __init__(self, table_name: str = "people-registry-projects"):
```

---

## 🎯 STANDARDIZATION SOLUTION

### **PHASE 1: IMMEDIATE PASSWORD RESET FIX**

#### **Step 1: Identify Actual Table Names**
```bash
# Run after: aws sso login
aws dynamodb list-tables --region us-east-1 --query 'TableNames[?contains(@, `people`) || contains(@, `registry`)]'
```

#### **Step 2: Set Lambda Environment Variables**
```bash
# For each Lambda function:
aws lambda update-function-configuration \
  --function-name PeopleRegisterInfrastruct-PeopleApiFunction67A8223-xlC79QhrsKBe \
  --environment Variables='{
    "PEOPLE_TABLE_NAME":"<actual-people-table>",
    "PASSWORD_RESET_TOKENS_TABLE_NAME":"<actual-password-reset-table>",
    "PROJECTS_TABLE_NAME":"<actual-projects-table>",
    "AUDIT_LOGS_TABLE_NAME":"<actual-audit-table>",
    "SUBSCRIPTIONS_TABLE_NAME":"<actual-subscriptions-table>",
    "SESSIONS_TABLE_NAME":"<actual-sessions-table>"
  }'
```

#### **Step 3: Test Password Reset**
- Request new password reset
- Verify token generation and storage
- Test password reset completion

### **PHASE 2: SYSTEMATIC STANDARDIZATION**

#### **Standardized Naming Convention**:
```bash
# ADOPTED STANDARD: kebab-case for AWS resources
people-registry-users
people-registry-projects
people-registry-subscriptions
people-registry-audit-logs
people-registry-password-reset-tokens
people-registry-password-history
people-registry-sessions
people-registry-roles
```

#### **Code Changes Required**:

##### **1. Remove Hardcoded Table Names**:
```python
# BEFORE (hardcoded):
def __init__(self, table_name: str = "people-registry-projects"):

# AFTER (config-based):
def __init__(self, config: ServiceConfig = None):
    self.config = config or get_config()
    self.table_name = self.config.database.projects_table
```

##### **2. Standardize Service Access**:
```python
# BEFORE (inconsistent):
users_table = self.dynamodb.Table("people-registry-users")

# AFTER (config-based):
users_table = self.dynamodb.Table(self.config.database.people_table)
```

##### **3. Update Repository Constructors**:
```python
# BEFORE:
class ProjectRepository(BaseRepository[Project]):
    def __init__(self, table_name: str = "people-registry-projects"):

# AFTER:
class ProjectRepository(BaseRepository[Project]):
    def __init__(self, config: ServiceConfig = None):
        self.config = config or get_config()
        super().__init__(self.config.database.projects_table)
```

---

## 🔧 IMPLEMENTATION PLAN

### **IMMEDIATE ACTIONS (Today)**:

#### **1. AWS Investigation** (15 minutes):
```bash
# After aws sso login:
cd registry-api/
uv run python scripts/identify_actual_table_names.py
```

#### **2. Lambda Environment Variables** (30 minutes):
- Set all required environment variables in Lambda functions
- Use actual table names from AWS investigation
- Test password reset functionality

#### **3. Verify Fix** (15 minutes):
- Request new password reset
- Complete password reset process
- Confirm HTTP 200 response

### **SYSTEMATIC FIXES (This Week)**:

#### **1. Code Standardization** (2-3 hours):
- Remove hardcoded table names from repositories
- Update services to use config-based table access
- Standardize constructor patterns

#### **2. Infrastructure Updates** (1 hour):
- Update CDK to use consistent table naming
- Ensure environment variables are set in infrastructure code
- Document table naming standards

#### **3. Testing and Validation** (1 hour):
- Test all services with new table access patterns
- Verify no regressions in existing functionality
- Update integration tests

---

## 📋 SPECIFIC FILE CHANGES

### **Files Requiring Updates**:

#### **Repositories**:
```bash
src/repositories/project_repository.py    # Remove hardcoded table name
src/repositories/user_repository.py       # Remove hardcoded table name
```

#### **Services**:
```bash
src/services/roles_service.py            # Remove hardcoded table names
src/services/defensive_dynamodb_service.py # Verify config usage
```

#### **Configuration**:
```bash
src/core/config.py                       # Verify all table configs present
```

### **New Files to Create**:
```bash
registry-documentation/architecture/TABLE_NAMING_STANDARDS.md
registry-api/scripts/validate_table_consistency.py
```

---

## 🧪 TESTING STRATEGY

### **Unit Tests**:
- Test config-based table access in all repositories
- Verify environment variable fallbacks work correctly
- Test service initialization with missing config

### **Integration Tests**:
- Test password reset end-to-end with correct table names
- Verify all CRUD operations work with standardized table access
- Test service registry health checks

### **Production Validation**:
- Monitor CloudWatch logs for table access errors
- Verify all Lambda functions have required environment variables
- Test critical user flows (login, password reset, data access)

---

## 🎯 SUCCESS CRITERIA

### **Immediate Success (Password Reset)**:
- ✅ Password reset completes successfully (HTTP 200)
- ✅ Token generation and retrieval work correctly
- ✅ No "Invalid or expired reset token" errors

### **Systematic Success (Standardization)**:
- ✅ All services use config-based table access
- ✅ No hardcoded table names in code
- ✅ All Lambda functions have required environment variables
- ✅ Consistent naming convention across all tables
- ✅ Comprehensive documentation of table standards

---

## 🚨 RISK MITIGATION

### **Deployment Risks**:
- **Risk**: Breaking existing functionality
- **Mitigation**: Test thoroughly in development, deploy incrementally

### **Data Access Risks**:
- **Risk**: Services unable to access tables
- **Mitigation**: Verify environment variables before deployment

### **Rollback Plan**:
```bash
# If issues occur:
1. Revert Lambda environment variables to previous state
2. Revert code changes to previous commit
3. Investigate specific table access failures
4. Fix and redeploy incrementally
```

---

## 📞 NEXT STEPS

### **Immediate (Next 30 minutes)**:
1. **Run AWS SSO login**: `aws sso login`
2. **Identify actual table names**: Run table identification script
3. **Set Lambda environment variables**: Use actual table names

### **Short Term (Today)**:
1. **Test password reset**: Verify immediate fix works
2. **Plan code changes**: Review files requiring updates
3. **Create standardization branch**: Prepare for systematic fixes

### **Medium Term (This Week)**:
1. **Implement code standardization**: Remove hardcoded names
2. **Update infrastructure**: Ensure consistent naming
3. **Comprehensive testing**: Validate all functionality

---

## 💡 LONG-TERM BENEFITS

### **Maintainability**:
- Single source of truth for table names
- Easier environment management
- Reduced code duplication

### **Reliability**:
- Consistent data access patterns
- Fewer configuration-related failures
- Better error handling and debugging

### **Scalability**:
- Easy to add new tables following standards
- Simplified deployment across environments
- Clear documentation for new developers

---

**PRIORITY**: Execute Phase 1 immediately to restore password reset functionality, then implement Phase 2 for long-term system health and maintainability.

**ESTIMATED TIME**: 
- Phase 1 (Immediate Fix): 1 hour
- Phase 2 (Systematic Fix): 4-6 hours over 2-3 days

**IMPACT**: Resolves critical password reset issue and prevents future similar failures across the entire system.
