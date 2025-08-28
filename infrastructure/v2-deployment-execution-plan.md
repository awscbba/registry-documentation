# V2 Database Standardization - Execution Plan

## 📊 **Assessment Results (August 27, 2025)**

**Status**: NOT_DEPLOYED  
**Action Required**: DEPLOY_V2_TABLES  

### **Current State**
- ✅ **Legacy Tables**: PeopleTable (9 items), ProjectsTable (138 items), SubscriptionsTable (12 items)
- ❌ **V2 Tables**: Not deployed (PeopleTableV2, ProjectsTableV2, SubscriptionsTableV2)
- ❌ **Lambda Config**: Using legacy table environment variables only
- ✅ **CDK Code**: V2 tables already defined in infrastructure stack
- ✅ **API Code**: Already using camelCase fields consistently

### **Data Migration Scope**
- **Total Records**: 159 items across all tables
- **People**: 9 records with EmailIndex GSI
- **Projects**: 138 records (largest table)
- **Subscriptions**: 12 records with ProjectIndex and PersonIndex GSI

## 🎯 **Execution Plan**

### **Phase 1: Deploy V2 Tables (CDK Pipeline)**

#### **Step 1: Create Feature Branch**
```bash
# Create feature branch following naming convention
git checkout -b feature/deploy-v2-standardized-database-tables

# Work in infrastructure directory only
cd registry-infrastructure/
```

#### **Step 2: Verify CDK Configuration**
The CDK stack already has V2 tables defined with:
- ✅ Consistent camelCase schema
- ✅ Proper GSI indexes (EmailIndex, StatusIndex, CategoryIndex, etc.)
- ✅ Point-in-time recovery enabled
- ✅ Pay-per-request billing
- ✅ Lambda environment variables configured

#### **Step 3: Deploy Through Pipeline**
```bash
# Check what will be deployed
npx cdk diff

# Commit and push to trigger pipeline
git add .
git commit -m "feat: deploy V2 standardized database tables

- Deploy PeopleTableV2 with camelCase schema and EmailIndex GSI
- Deploy ProjectsTableV2 with StatusIndex and CategoryIndex GSI  
- Deploy SubscriptionsTableV2 with ProjectIndex, PersonIndex, and StatusIndex GSI
- Update Lambda environment variables to include V2 table names
- Maintain backward compatibility with legacy tables during migration
- Enable point-in-time recovery on all V2 tables

Resolves database schema standardization requirements.
Addresses 42 identified schema inconsistencies.
Prepares for data migration from legacy tables."

git push origin feature/deploy-v2-standardized-database-tables
```

#### **Step 4: Create Pull Request**
- **Title**: "Deploy V2 Standardized Database Tables"
- **Description**: Reference this execution plan and assessment results
- **Reviewers**: Infrastructure team
- **Labels**: `infrastructure`, `database`, `v2-standardization`

### **Phase 2: Data Migration (Post-Deployment)**

#### **Step 1: Verify V2 Tables Deployed**
```bash
# Run assessment again to confirm deployment
python3 scripts/assess_v2_deployment_status.py --region us-east-1
```

#### **Step 2: Create Data Migration Script**
```python
# registry-infrastructure/scripts/migrate_legacy_to_v2.py
# - Read from legacy tables
# - Transform to camelCase format
# - Write to V2 tables
# - Verify data integrity
```

#### **Step 3: Execute Migration**
```bash
# Run migration for all tables
python3 scripts/migrate_legacy_to_v2.py --source-tables all --target-tables v2
```

#### **Step 4: Verify Migration**
```bash
# Check record counts match
aws dynamodb scan --table-name PeopleTableV2 --select COUNT
aws dynamodb scan --table-name ProjectsTableV2 --select COUNT  
aws dynamodb scan --table-name SubscriptionsTableV2 --select COUNT
```

### **Phase 3: API Cutover**

#### **Step 1: Update API Configuration**
The API configuration is already set to use V2 tables:
```python
people_table: str = Field(default_factory=lambda: os.getenv("PEOPLE_TABLE_V2_NAME", "PeopleTableV2"))
```

#### **Step 2: Deploy API Changes**
```bash
# API will automatically use V2 tables once Lambda environment variables are updated
cd registry-api/
# No code changes needed - configuration already points to V2 tables
```

#### **Step 3: Test API Endpoints**
```bash
# Test all V2 endpoints
curl -X GET "https://your-api-url/v2/people"
curl -X GET "https://your-api-url/v2/projects"
curl -X GET "https://your-api-url/v2/subscriptions"
```

## ⏱️ **Timeline**

- **Phase 1 (CDK Deployment)**: 30-60 minutes
- **Phase 2 (Data Migration)**: 15-30 minutes  
- **Phase 3 (API Cutover)**: 15-30 minutes
- **Total**: 1-2 hours

## 🔒 **Risk Mitigation**

### **Blue-Green Deployment**
- V2 tables deployed alongside legacy tables
- API can be quickly reverted to legacy tables if issues occur
- No data loss risk (legacy tables remain untouched)

### **Rollback Plan**
```bash
# If issues occur, revert Lambda environment variables
# CDK stack update to use legacy table names
# API automatically falls back to legacy tables
```

### **Monitoring**
- CloudWatch alarms on Lambda errors
- API response time monitoring
- Database read/write capacity monitoring

## ✅ **Success Criteria**

- ✅ V2 tables deployed and active
- ✅ All 159 records migrated successfully
- ✅ API endpoints return camelCase fields
- ✅ No increase in error rates
- ✅ Response times maintained or improved

## 📋 **Next Actions**

1. **Create feature branch** for V2 table deployment
2. **Deploy CDK stack** through proper pipeline
3. **Verify deployment** using assessment script
4. **Execute data migration** from legacy to V2 tables
5. **Test API functionality** with V2 tables
6. **Monitor system health** post-deployment

---

**Ready to proceed with Phase 1: CDK Deployment**