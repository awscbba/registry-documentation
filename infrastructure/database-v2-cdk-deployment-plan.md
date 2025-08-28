# Database V2 Standardization - Proper CDK Deployment Plan

## 🎯 **Current Situation**

✅ **API Code**: Already using consistent camelCase fields  
✅ **CDK Stack**: V2 tables already defined in infrastructure  
✅ **Environment Variables**: V2 table names configured  
❓ **Deployment Status**: Need to verify V2 tables are actually deployed  

## 🚀 **Proper CDK Deployment Workflow**

### **Step 1: Create Feature Branch**

```bash
# Create feature branch for V2 deployment
git checkout -b feature/deploy-v2-standardized-tables

# Work only in registry-infrastructure/ directory
cd registry-infrastructure/
```

### **Step 2: Verify CDK Stack Configuration**

The CDK stack already has V2 tables defined:

```python
# Standardized People Table with consistent camelCase schema
people_table_v2 = dynamodb.Table(
    self, "PeopleTableV2",
    table_name="PeopleTableV2",
    partition_key=dynamodb.Attribute(name="id", type=dynamodb.AttributeType.STRING),
    billing_mode=dynamodb.BillingMode.PAY_PER_REQUEST,
    point_in_time_recovery_specification=dynamodb.PointInTimeRecoverySpecification(
        point_in_time_recovery_enabled=True
    ),
)
```

### **Step 3: Deploy Through Proper CI/CD Pipeline**

```bash
# Check CDK diff to see what will be deployed
npx cdk diff

# Deploy through proper pipeline (NOT locally)
git add .
git commit -m "feat: deploy V2 standardized database tables

- Deploy PeopleTableV2 with camelCase schema
- Deploy ProjectsTableV2 with standardized fields  
- Deploy SubscriptionsTableV2 with consistent naming
- Update Lambda environment variables to use V2 tables
- Maintain backward compatibility during migration"

git push origin feature/deploy-v2-standardized-tables
```

### **Step 4: Create Pull Request**

Create PR with:
- **Title**: "Deploy V2 Standardized Database Tables"
- **Description**: Link to this deployment plan
- **Reviewers**: Infrastructure team
- **Labels**: `infrastructure`, `database`, `v2-standardization`

### **Step 5: Pipeline Deployment**

The CodeCatalyst pipeline will:
1. **Validate CDK**: Check syntax and dependencies
2. **Deploy Infrastructure**: Create V2 tables in AWS
3. **Update Lambda Functions**: Set environment variables
4. **Run Health Checks**: Verify deployment success

## 📋 **What Gets Deployed**

### **New DynamoDB Tables**
- `PeopleTableV2` - Standardized people/users table
- `ProjectsTableV2` - Standardized projects table  
- `SubscriptionsTableV2` - Standardized subscriptions table

### **Global Secondary Indexes**
- `EmailIndex` on PeopleTableV2 for email lookups
- `StatusIndex` on ProjectsTableV2 for status filtering
- `CategoryIndex` on ProjectsTableV2 for category filtering
- `ProjectIndex` on SubscriptionsTableV2 for project subscriptions
- `PersonIndex` on SubscriptionsTableV2 for user subscriptions
- `StatusIndex` on SubscriptionsTableV2 for status filtering

### **Lambda Environment Variables**
```python
environment={
    # V2 Standardized Tables (Primary)
    "PEOPLE_TABLE_V2_NAME": "PeopleTableV2",
    "PROJECTS_TABLE_V2_NAME": "ProjectsTableV2", 
    "SUBSCRIPTIONS_TABLE_V2_NAME": "SubscriptionsTableV2",
    
    # Legacy Tables (Backward Compatibility)
    "PEOPLE_TABLE_NAME": "PeopleTable",
    "PROJECTS_TABLE_NAME": "ProjectsTable",
    "SUBSCRIPTIONS_TABLE_NAME": "SubscriptionsTable",
}
```

## ✅ **Verification Steps**

After deployment, verify through AWS Console:

### **1. Check Tables Exist**
- Navigate to DynamoDB in AWS Console
- Verify `PeopleTableV2`, `ProjectsTableV2`, `SubscriptionsTableV2` exist
- Check GSI indexes are created

### **2. Check Lambda Configuration**  
- Navigate to Lambda functions
- Check environment variables include `*_TABLE_V2_NAME` variables
- Verify IAM permissions for V2 tables

### **3. Test API Endpoints**
- Test `/v2/people` endpoint
- Test `/v2/projects` endpoint  
- Test `/v2/subscriptions` endpoint
- Verify responses use camelCase fields

## 🔄 **Data Migration Strategy**

Since the API is already using camelCase fields, the migration approach is:

### **Option 1: Blue-Green (Recommended)**
1. **Deploy V2 tables** (empty initially)
2. **API continues using legacy tables** 
3. **Background migration** copies data to V2 tables
4. **Switch API** to use V2 tables after migration complete
5. **Decommission legacy tables** after verification

### **Option 2: Direct Switch**
1. **Deploy V2 tables** 
2. **API immediately switches** to V2 tables (empty)
3. **Users start with fresh data** (if acceptable)

## 🚨 **Risk Mitigation**

### **Rollback Plan**
If issues occur:
1. **Revert Lambda environment variables** to use legacy tables
2. **Redeploy CDK stack** with reverted configuration  
3. **V2 tables remain** but unused (can be deleted later)

### **Monitoring**
- **CloudWatch Alarms** on Lambda errors
- **API Response Time** monitoring
- **Database Read/Write Capacity** monitoring
- **Error Rate** tracking

## 📊 **Success Criteria**

✅ **Infrastructure**: V2 tables deployed successfully  
✅ **API Compatibility**: All endpoints work with V2 tables  
✅ **Performance**: Response times maintained or improved  
✅ **Data Integrity**: All data accessible and consistent  
✅ **Monitoring**: No increase in error rates  

## 🔗 **Related Documentation**

- [AI Assistant Guidelines](./workflows/ai-assistant-guidelines.md) - CDK deployment rules
- [API Rewrite Plan](./api-rewrite-plan.md) - Overall architecture strategy
- [Clean Architecture Progress](./clean-architecture-progress.md) - Implementation status

---

**Next Action**: Create feature branch and deploy through proper CI/CD pipeline  
**Timeline**: 1-2 hours for deployment + verification  
**Risk Level**: Low (backward compatibility maintained)