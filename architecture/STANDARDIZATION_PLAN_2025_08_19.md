# Comprehensive Standardization Plan - August 19, 2025

**Status**: 🚨 **CRITICAL STANDARDIZATION NEEDED**  
**Priority**: HIGH - Multiple naming patterns causing maintenance complexity  
**Scope**: Database tables, environment variables, hardcoded values  

---

## 🔍 CURRENT STATE ANALYSIS

### **Actual AWS Tables (14 tables)**:
```
✅ PRODUCTION TABLES (PascalCase - STANDARD):
- AccountLockoutTable
- AuditLogsTable  
- CSRFTokenTable
- EmailTrackingTable
- PasswordHistoryTable
- PasswordResetTokensTable
- PeopleTable
- ProjectsTable
- RateLimitTable
- SessionTrackingTable
- SubscriptionsTable

❌ LEGACY TABLES (kebab-case - NON-STANDARD):
- people-registry-audit-logs
- people-registry-roles

⚠️  UNRELATED:
- AwsCbbaTerraformMainStateLock (Terraform state)
```

### **Critical Issues Identified**:

#### **1. Multiple Naming Patterns (4 different patterns!)**:
- **PascalCase**: 13 tables (✅ CORRECT - matches AWS standard)
- **kebab-case**: 4 references (❌ LEGACY - needs migration)
- **snake_case**: 1 reference (❌ INCORRECT)
- **mixed**: 6 references (❌ PARSING ERRORS)

#### **2. Hardcoded Table Names (15 instances)**:
```python
# CRITICAL: roles_service.py
"people-registry-users"    # ❌ Table doesn't exist!
"people-registry-roles"    # ✅ Exists but hardcoded

# CRITICAL: Scripts with hardcoded names
"PeopleTable" in check_admin_user.py
"PeopleTable" in create_admin_user.py
"PeopleTable" in delete_admin_user.py
```

#### **3. Missing Environment Variables**:
- **Tables without env vars**: 2 tables
- **Inconsistent env var usage**: Some services use env vars, others don't

#### **4. Table Name Mismatches**:
```
❌ REFERENCED BUT DON'T EXIST:
- people-registry-users  (should be: PeopleTable)
- SessionsTable         (should be: SessionTrackingTable)
- RolesTable           (should be: people-registry-roles)
```

---

## 🎯 STANDARDIZATION STRATEGY

### **ADOPTED STANDARD**: PascalCase with Environment Variables

**Rationale**:
1. **AWS Standard**: All production tables already use PascalCase
2. **Infrastructure Consistency**: CDK creates PascalCase tables
3. **Minimal Disruption**: Most tables already follow this pattern

### **Migration Approach**: Code-First (No Table Renames)

**Why**: Renaming production tables is risky and unnecessary since most tables already follow the standard.

---

## 🔧 IMPLEMENTATION PLAN

### **PHASE 1: Fix Critical Hardcoded References** (IMMEDIATE - 2 hours)

#### **Step 1.1: Fix roles_service.py** (30 minutes)
```python
# BEFORE (hardcoded):
class RolesService(BaseService):
    def __init__(self, table_name: str = "people-registry-roles"):
        self.table = self.dynamodb.Table(self.table_name)
        # Also references "people-registry-users" (WRONG!)

# AFTER (environment-based):
class RolesService(BaseService):
    def __init__(self):
        roles_table = os.getenv("ROLES_TABLE_NAME", "people-registry-roles")
        people_table = os.getenv("PEOPLE_TABLE_NAME", "PeopleTable")
        self.roles_table = self.dynamodb.Table(roles_table)
        self.people_table = self.dynamodb.Table(people_table)
```

#### **Step 1.2: Fix Repository Constructors** (30 minutes)
```python
# BEFORE (inconsistent defaults):
class SubscriptionRepository(BaseRepository[Subscription]):
    def __init__(self, table_name: str = "SubscriptionsTable"):

# AFTER (environment-based with fallback):
class SubscriptionRepository(BaseRepository[Subscription]):
    def __init__(self, table_name: str = None):
        if table_name is None:
            table_name = os.getenv("SUBSCRIPTIONS_TABLE_NAME", "SubscriptionsTable")
        super().__init__(table_name)
```

#### **Step 1.3: Fix Admin Scripts** (30 minutes)
```python
# BEFORE (hardcoded):
table = dynamodb.Table("PeopleTable")

# AFTER (environment-based):
table_name = os.getenv("PEOPLE_TABLE_NAME", "PeopleTable")
table = dynamodb.Table(table_name)
```

#### **Step 1.4: Update Infrastructure Environment Variables** (30 minutes)
```python
# Add missing environment variables to ALL Lambda functions:
environment={
    # Existing
    "PEOPLE_TABLE_NAME": people_table.table_name,
    "PROJECTS_TABLE_NAME": projects_table.table_name,
    "SUBSCRIPTIONS_TABLE_NAME": subscriptions_table.table_name,
    "PASSWORD_RESET_TOKENS_TABLE_NAME": password_reset_tokens_table.table_name,
    "AUDIT_LOGS_TABLE_NAME": audit_logs_table.table_name,
    
    # ADD MISSING:
    "ROLES_TABLE_NAME": "people-registry-roles",  # Legacy table
    "ACCOUNT_LOCKOUT_TABLE_NAME": account_lockout_table.table_name,
    "EMAIL_TRACKING_TABLE_NAME": email_tracking_table.table_name,
    "PASSWORD_HISTORY_TABLE_NAME": password_history_table.table_name,
    "SESSION_TRACKING_TABLE_NAME": session_tracking_table.table_name,
    "RATE_LIMIT_TABLE_NAME": rate_limit_table.table_name,
    "CSRF_TOKEN_TABLE_NAME": csrf_token_table.table_name,
}
```

### **PHASE 2: Standardize Service Initialization** (1-2 hours)

#### **Step 2.1: Update All Services to Use Environment Variables**
```python
# STANDARD PATTERN for all services:
class SomeService(BaseService):
    def __init__(self):
        super().__init__("service_name")
        # Get table names from environment
        table_name = os.getenv("SOME_TABLE_NAME", "DefaultTable")
        self.repository = SomeRepository(table_name=table_name)
```

#### **Step 2.2: Remove All Hardcoded Table References**
- Update `roles_service.py`
- Update all repository constructors
- Update admin scripts
- Update any remaining hardcoded references

### **PHASE 3: Legacy Table Migration** (OPTIONAL - Future)

#### **Option A: Migrate Legacy Tables to PascalCase**
```bash
# Rename legacy tables (RISKY - production impact):
people-registry-roles → RolesTable
people-registry-audit-logs → AuditLogsTable (duplicate?)
```

#### **Option B: Keep Legacy Tables, Standardize Code**
```python
# Use environment variables to map to legacy tables:
"ROLES_TABLE_NAME": "people-registry-roles"  # Keep legacy name
"AUDIT_LOGS_TABLE_NAME": "AuditLogsTable"   # Use standard name
```

**RECOMMENDATION**: Option B (keep legacy tables, standardize code)

---

## 📋 SPECIFIC FILE CHANGES

### **Files Requiring Immediate Updates**:

#### **Critical Services**:
```bash
src/services/roles_service.py              # Fix hardcoded table names
src/repositories/subscription_repository.py # Standardize constructor
src/repositories/user_repository.py         # Standardize constructor  
src/repositories/project_repository.py      # Standardize constructor
src/repositories/audit_repository.py        # Standardize constructor
```

#### **Admin Scripts**:
```bash
scripts/check_admin_user.py                # Remove hardcoded PeopleTable
scripts/create_admin_user.py               # Remove hardcoded PeopleTable
scripts/delete_admin_user.py               # Remove hardcoded PeopleTable
```

#### **Infrastructure**:
```bash
registry-infrastructure/people_register_infrastructure/people_register_infrastructure_stack.py
# Add missing environment variables
```

### **New Files to Create**:
```bash
registry-api/scripts/validate_table_standardization.py
registry-documentation/standards/TABLE_NAMING_STANDARDS.md
registry-documentation/guides/ENVIRONMENT_VARIABLES.md
```

---

## 🧪 TESTING STRATEGY

### **Pre-Deployment Testing**:
```bash
# 1. Validate environment variables are set
uv run python scripts/validate_table_standardization.py

# 2. Test service initialization
uv run python -c "
from src.services.roles_service import RolesService
from src.services.subscriptions_service import SubscriptionsService
rs = RolesService()
ss = SubscriptionsService()
print('✅ Services initialize correctly')
"

# 3. Test repository access
uv run python -c "
from src.repositories.user_repository import UserRepository
ur = UserRepository()
print('✅ Repository initializes correctly')
"
```

### **Post-Deployment Validation**:
```bash
# Test production endpoints
curl https://2t9blvt2c1.execute-api.us-east-1.amazonaws.com/prod/health/services

# Test specific functionality
curl https://2t9blvt2c1.execute-api.us-east-1.amazonaws.com/prod/v2/subscriptions
```

---

## 🎯 SUCCESS CRITERIA

### **Phase 1 Success**:
- ✅ No hardcoded table names in service code
- ✅ All repositories use environment variables
- ✅ All Lambda functions have required environment variables
- ✅ roles_service.py uses correct table references
- ✅ Admin scripts use environment variables

### **Phase 2 Success**:
- ✅ Consistent service initialization patterns
- ✅ All services pass health checks
- ✅ No table access errors in logs
- ✅ Standardization validation script passes

### **Long-term Success**:
- ✅ Single naming convention (PascalCase + env vars)
- ✅ No hardcoded values in codebase
- ✅ Clear documentation of standards
- ✅ Automated validation in CI/CD

---

## 🚨 RISK MITIGATION

### **Deployment Risks**:
- **Risk**: Services can't find tables after changes
- **Mitigation**: Use fallback defaults in environment variable calls
- **Rollback**: Revert environment variables to previous state

### **Data Access Risks**:
- **Risk**: Wrong table names break functionality
- **Mitigation**: Test thoroughly with actual AWS tables
- **Validation**: Create table access validation script

### **Legacy Table Risks**:
- **Risk**: Legacy tables (people-registry-*) might be used by other systems
- **Mitigation**: Keep legacy tables, update code to use env vars
- **Documentation**: Document legacy table mappings

---

## 📞 IMMEDIATE NEXT STEPS

### **Today (2-3 hours)**:
1. **Create feature branch**: `feature/standardize-table-access-2025-08-19`
2. **Fix roles_service.py**: Remove hardcoded "people-registry-users" reference
3. **Update repository constructors**: Add environment variable support
4. **Update infrastructure**: Add missing environment variables
5. **Test locally**: Ensure services still work

### **This Week**:
1. **Deploy infrastructure changes**: Update Lambda environment variables
2. **Deploy code changes**: Updated services and repositories
3. **Validate production**: Test all endpoints work correctly
4. **Create documentation**: Standards and validation guides

---

## 💡 LONG-TERM BENEFITS

### **Maintainability**:
- Single source of truth for table names
- Easy environment management
- Clear, consistent patterns

### **Reliability**:
- No more hardcoded table name mismatches
- Environment-specific table configuration
- Better error handling and debugging

### **Scalability**:
- Easy to add new tables following standards
- Simplified deployment across environments
- Clear onboarding for new developers

---

**PRIORITY**: Execute Phase 1 immediately to fix critical hardcoded references and prevent production issues.

**ESTIMATED TIME**: 
- Phase 1 (Critical Fixes): 2-3 hours
- Phase 2 (Standardization): 1-2 hours
- Phase 3 (Documentation): 1 hour

**IMPACT**: Eliminates 28 identified standardization issues and establishes consistent, maintainable patterns across the entire system.
