# Database Standardization Plan

## 🎯 **Executive Summary**

We have successfully implemented **clean architecture** for the People Registry API but discovered **42 critical database schema issues** that must be resolved before continuing development. This document outlines the complete standardization plan and execution steps.

## 📊 **Current Database Issues**

### **Audit Results Summary**
- **Total Items Analyzed**: 159 records
- **Total Issues Found**: 42 critical issues
- **Tables Affected**: All 3 main tables (People, Projects, Subscriptions)

### **Issue Breakdown**
| Table | Items | Issues | Primary Problems |
|-------|-------|--------|------------------|
| **People** | 9 | 24 | Mixed naming (14 snake_case, 12 camelCase), missing required fields |
| **Projects** | 138 | 3 | Minor optional field gaps |
| **Subscriptions** | 12 | 15 | High inconsistency (33-91% missing fields) |

## 🏗️ **Standardization Solution**

### **1. New Standardized Tables**
We will create new tables with consistent camelCase schema:

- `PeopleTable` → `PeopleTableV2`
- `ProjectsTable` → `ProjectsTableV2`  
- `SubscriptionsTable` → `SubscriptionsTableV2`

### **2. Standardized Schema Design**

#### **People Table Schema**
```json
{
  "required_fields": [
    "id", "email", "firstName", "lastName", "phone", 
    "dateOfBirth", "address", "isAdmin", "isActive", 
    "emailVerified", "requirePasswordChange", "createdAt", "updatedAt"
  ],
  "address_structure": {
    "street": "string",
    "city": "string", 
    "state": "string",
    "postalCode": "string",
    "country": "string"
  }
}
```

#### **Projects Table Schema**
```json
{
  "required_fields": [
    "id", "name", "description", "startDate", "endDate",
    "maxParticipants", "currentParticipants", "status",
    "createdBy", "createdAt", "updatedAt"
  ],
  "optional_fields": ["category", "location", "requirements"]
}
```

#### **Subscriptions Table Schema**
```json
{
  "required_fields": [
    "id", "personId", "projectId", "status", 
    "subscribedAt", "createdAt", "updatedAt"
  ],
  "optional_fields": [
    "subscribedBy", "personName", "personEmail", 
    "projectName", "emailSent", "version"
  ]
}
```

## 🛠️ **Implementation Tools**

### **Scripts Created**
1. **`audit_database_schema.py`** ✅
   - Analyzes current database inconsistencies
   - Generates comprehensive audit report
   - Identifies all 42 issues

2. **`create_standardized_tables.py`** ✅
   - Creates new DynamoDB tables with standardized schema
   - Includes proper indexes and configurations
   - Generates schema documentation

3. **`migrate_data_to_standardized_tables.py`** ✅
   - Migrates data from old to new tables
   - Handles field name conversions (snake_case → camelCase)
   - Fills missing required fields with defaults
   - Provides detailed migration reporting

4. **`execute_database_standardization.py`** ✅
   - Complete workflow automation
   - Runs all steps in correct order
   - Provides comprehensive status reporting

## 🚀 **Execution Plan**

### **Step 1: Execute Database Standardization**
```bash
cd registry-infrastructure
python scripts/execute_database_standardization.py
```

This will:
1. 🔍 Audit current database (optional)
2. 🏗️ Create standardized tables
3. 🔄 Migrate all data with field standardization

### **Step 2: Update API Configuration**
Update environment variables in the API:
```bash
# Old table names
PEOPLE_TABLE_NAME=PeopleTable
PROJECTS_TABLE_NAME=ProjectsTable
SUBSCRIPTIONS_TABLE_NAME=SubscriptionsTable

# New standardized table names
PEOPLE_TABLE_NAME=PeopleTableV2
PROJECTS_TABLE_NAME=ProjectsTableV2
SUBSCRIPTIONS_TABLE_NAME=SubscriptionsTableV2
```

### **Step 3: Test & Validate**
1. 🧪 Run API tests with new tables
2. 🔍 Verify data integrity
3. 🚀 Deploy to staging environment
4. ✅ Validate all functionality

### **Step 4: Production Deployment**
1. 🚀 Deploy API with new table configuration
2. 📊 Monitor performance and errors
3. 🗑️ Clean up old tables after successful validation

## 📋 **Migration Strategy**

### **Blue-Green Deployment**
- **Blue (Current)**: Old tables with mixed schema
- **Green (New)**: Standardized tables with camelCase schema
- **Rollback**: Keep old tables until new ones are validated

### **Data Migration Features**
- **Field Mapping**: Automatic snake_case → camelCase conversion
- **Missing Field Handling**: Default values for required fields
- **Duplicate Prevention**: Skip existing records in new tables
- **Error Reporting**: Detailed logs of any migration issues

### **Safety Measures**
- **No Data Loss**: Old tables remain untouched
- **Validation**: Comprehensive testing before cutover
- **Rollback Plan**: Instant rollback to old tables if needed
- **Monitoring**: Real-time migration progress tracking

## 🎯 **Expected Benefits**

### **Immediate Benefits**
- ✅ **Consistent Field Naming**: All camelCase, no more conversion overhead
- ✅ **Complete Data Integrity**: All required fields present
- ✅ **Clean Architecture Compatibility**: Perfect match with our API models
- ✅ **Improved Performance**: No field mapping overhead

### **Long-term Benefits**
- 🚀 **Faster Development**: No field mapping bugs
- 🔧 **Easier Maintenance**: Consistent schema across stack
- 📈 **Better Performance**: Direct field access
- 🛡️ **Improved Reliability**: No schema inconsistencies

## 📊 **Success Metrics**

### **Migration Success Criteria**
- ✅ All 159 records migrated successfully
- ✅ Zero data loss during migration
- ✅ All 42 schema issues resolved
- ✅ API tests pass with new tables

### **Performance Improvements**
- 🎯 **Response Time**: Eliminate field mapping overhead
- 🎯 **Error Rate**: Reduce schema-related errors to 0%
- 🎯 **Development Velocity**: 50% faster feature development
- 🎯 **Bug Rate**: 80% reduction in field mapping bugs

## 🚨 **Risk Mitigation**

### **Low Risk Approach**
- **Parallel Tables**: New tables alongside old ones
- **Gradual Migration**: Test thoroughly before switching
- **Instant Rollback**: Keep old tables as backup
- **Comprehensive Testing**: Full validation before production

### **Contingency Plans**
- **Migration Failure**: Detailed error reporting and retry mechanisms
- **Data Corruption**: Point-in-time recovery enabled on all tables
- **Performance Issues**: Rollback to old tables immediately
- **API Compatibility**: Maintain backward compatibility during transition

## 🎉 **Ready for Execution**

All tools are created and tested. The database standardization is ready to execute:

1. ✅ **Analysis Complete**: 42 issues identified and documented
2. ✅ **Solution Designed**: Standardized camelCase schema
3. ✅ **Tools Created**: Complete migration toolkit
4. ✅ **Safety Measures**: Blue-green deployment strategy
5. ✅ **Documentation**: Comprehensive execution plan

**Next Action**: Execute `python scripts/execute_database_standardization.py` to begin the standardization process.