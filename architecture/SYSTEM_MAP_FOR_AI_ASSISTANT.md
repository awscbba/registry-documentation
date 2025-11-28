# People Registry System Map - AI Assistant Reference

**Purpose**: Comprehensive system map to prevent code duplication and architectural inconsistencies when implementing features or fixing issues.

**Last Updated**: August 17, 2025 15:45 UTC  
**Status**: ✅ **PRODUCTION SYSTEM - FULLY OPERATIONAL**  
**Critical Issues**: ✅ **ALL RESOLVED**

---

## 🎯 CURRENT SYSTEM STATUS

### **✅ RECENT FIXES COMPLETED (August 17, 2025)**

#### **1. Auth-Roles Service Connectivity** ✅ **RESOLVED**
- **Issue**: Auth service health checks failing due to uninitialized roles service dependency
- **Solution**: Implemented proper dependency injection in Service Registry
- **Status**: ✅ **FIXED** - Auth service now reports HEALTHY
- **Branch**: `fix/project-repository-field-mapping` (commit `362381b`)

#### **2. Lambda Dependencies** ✅ **IMPROVED**
- **Issue**: Missing dependencies (PyJWT, mangum, email-validator) in Lambda deployment  
- **Solution**: Updated Dockerfile.lambda to use requirements-lambda.txt
- **Status**: ✅ **RESOLVED** - Consistent dependency management

#### **3. ProjectRepository Field Mapping** ✅ **CONFIRMED WORKING**
- **Issue**: Field name mismatches between repository and storage
- **Status**: ✅ **ALREADY FIXED** - camelCase field mapping with comprehensive tests

---

## 🏗️ SYSTEM ARCHITECTURE OVERVIEW

### **Deployment Architecture: DUAL PIPELINE SYSTEM**
- **Infrastructure Pipeline**: `registry-infrastructure/` → AWS CDK → Provisions resources
- **Application Pipeline**: `registry-api/` → Docker containers → Lambda deployment
- **⚠️ CRITICAL**: Never deploy application code from infrastructure pipeline!

### **Current Architecture**: Service Registry Pattern (87% code reduction achieved)
- **Active Handler**: `src/handlers/modular_api_handler.py` (366 lines)
- **Legacy Handler**: `src/handlers/versioned_api_handler.py` (2,797 lines) - DEPRECATED
- **Entry Point**: `main.py` → Service Registry Manager → 15 Services

### **Service Health Status** (All ✅ HEALTHY):
| Service | Status | Dependencies | Health Check Type |
|---------|--------|--------------|-------------------|
| people | ✅ HEALTHY | user_repository | Dict (by design) |
| projects | ✅ HEALTHY | project_repository | Dict (by design) |
| subscriptions | ✅ HEALTHY | defensive_dynamodb | Dict (by design) |
| **auth** | ✅ **HEALTHY** | **roles_service** | **HealthCheck (FIXED)** |
| roles | ✅ HEALTHY | dynamodb | HealthCheck |
| email | ✅ HEALTHY | ses_client | HealthCheck |
| password_reset | ✅ HEALTHY | email_service, people_service | HealthCheck |
| audit | ✅ HEALTHY | audit_repository | Dict (by design) |
| logging | ✅ HEALTHY | cloudwatch | HealthCheck |
| rate_limiting | ✅ HEALTHY | - | HealthCheck |
| metrics | ✅ HEALTHY | - | Dict (by design) |
| cache | ✅ HEALTHY | - | Dict (by design) |
| performance_metrics | ✅ HEALTHY | - | Dict (by design) |
| database_optimization | ✅ HEALTHY | - | Dict (by design) |
| project_administration | ✅ HEALTHY | - | Dict (by design) |

---

## 📊 DATA FLOW ARCHITECTURE

### **Postal Code/Address Handling (CRITICAL SYSTEM)**

```
Frontend (postalCode) → API Gateway → Lambda → Service Registry → Repository → DynamoDB (postal_code)
```

#### **Field Name Transformations**:
1. **Frontend**: `postalCode` (camelCase)
2. **API Layer**: `postalCode` (camelCase) 
3. **Pydantic Model Creation**: `postalCode` (camelCase) - REQUIRED for Address(**data)
4. **Pydantic Model Internal**: `postal_code` (snake_case) with `postalCode` alias
5. **DynamoDB Storage**: `postal_code` (snake_case)

#### **Normalization Points**:
- **DefensiveDynamoDBService**: Handles ALL variants → `postalCode` for Pydantic
- **UserRepository**: Follows same pattern as DefensiveDynamoDBService
- **Validation**: `src/utils/validation_utils.py` - ZIP/postal code validation

#### **Supported Variants**:
- `postal_code` (snake_case) - DynamoDB storage format
- `postalCode` (camelCase) - Frontend/API format  
- `zip_code` (snake_case) - Legacy format
- `zipCode` (camelCase) - Legacy format

---

## 🔧 SERVICE REGISTRY ARCHITECTURE

### **Service Registry Manager**: `src/services/service_registry_manager.py`
**Registered Services** (15 total):
1. `people` - User management (UserRepository)
2. `projects` - Project operations  
3. `subscriptions` - Event subscriptions
4. `auth` - Authentication & JWT
5. `roles` - Role-based access control
6. `email` - Email operations (SES)
7. `password_reset` - Password reset workflow
8. `audit` - Audit logging
9. `logging` - Centralized logging
10. `rate_limiting` - API protection
11. `metrics` - Performance metrics
12. `cache` - Caching service
13. `performance_metrics` - Real-time metrics
14. `database_optimization` - Query optimization
15. `project_administration` - Admin operations

### **Service Pattern**:
```python
class ServiceName(BaseService):
    async def initialize(self) -> None:
        # Service initialization
    
    async def health_check(self) -> HealthCheck:
        # Health check implementation
```

---

## 🗄️ REPOSITORY LAYER ARCHITECTURE

### **Base Repository**: `src/repositories/base_repository.py`
- **Pattern**: Generic repository with type safety
- **Operations**: CRUD, list_all, batch operations
- **Query System**: QueryFilter, QueryOperator, QueryOptions

### **User Repository**: `src/repositories/user_repository.py`
- **Inherits**: BaseRepository[Person]
- **Key Method**: `_to_entity()` - DynamoDB item → Person conversion
- **⚠️ CRITICAL**: Follows DefensiveDynamoDBService postal code pattern

### **Repository Pattern**:
```python
class UserRepository(BaseRepository[Person]):
    def _to_entity(self, item: Dict[str, Any]) -> Person:
        # Handle address postal code normalization
        # Convert postal_code → postalCode for Pydantic
```

---

## 📋 DATA MODELS ARCHITECTURE

### **Person Model**: `src/models/person.py`
```python
class Address(BaseModel):
    street: str
    city: str  
    state: str
    postal_code: str = Field(alias="postalCode")  # CRITICAL: Internal snake_case, API camelCase
    country: str

class Person(PersonBase):
    # Person fields with address: Address
```

### **Model Usage Patterns**:
- **Creation**: Use `postalCode` → `Address(postalCode="12345")`
- **Internal Access**: Use `postal_code` → `person.address.postal_code`
- **API Response**: Use alias → `person.address.model_dump(by_alias=True)`

---

## 🔄 DATA SERVICES LAYER

### **DefensiveDynamoDBService**: `src/services/defensive_dynamodb_service.py`
**Purpose**: Robust DynamoDB operations with data normalization

#### **Address Normalization Logic**:
```python
# Reading from DynamoDB (normalize TO postalCode for Pydantic)
if "postal_code" in address_data:
    address_data["postalCode"] = address_data.pop("postal_code")
elif "zip_code" in address_data:
    address_data["postalCode"] = address_data.pop("zip_code")
# ... handle all variants

# Writing to DynamoDB (normalize TO postal_code for storage)  
if "postalCode" in normalized:
    normalized["postal_code"] = normalized.pop("postalCode")
# ... handle all variants
```

#### **Key Methods**:
- `_item_to_person()` - DynamoDB → Person (with postal code normalization)
- `_normalize_address_for_storage()` - Address → DynamoDB format
- `_person_to_item()` - Person → DynamoDB item

---

## 🚨 CRITICAL PATTERNS TO FOLLOW

### **When Adding New Repository Classes**:
1. **Inherit from BaseRepository[T]**
2. **Implement `_to_entity()` method**
3. **Follow postal code normalization pattern from DefensiveDynamoDBService**
4. **Handle address data conversion: `postal_code` → `postalCode` for Pydantic**

### **When Adding New Services**:
1. **Inherit from BaseService**
2. **Implement `initialize()` and `health_check()` methods**
3. **Register in ServiceRegistryManager**
4. **Add endpoints to modular_api_handler.py**
5. **Write comprehensive tests**

### **When Handling Address Data**:
1. **Storage**: Always use `postal_code` (snake_case)
2. **Pydantic Creation**: Always use `postalCode` (camelCase)
3. **API Responses**: Use `by_alias=True` for camelCase
4. **Never create duplicate normalization logic**

---

## 🧪 TESTING ARCHITECTURE

### **Test Categories**:
- **Address Field Standardization**: `tests/test_address_field_standardization.py`
- **Service Registry**: `tests/test_service_registry_*.py`
- **Critical Integration**: `tests/test_critical_integration.py`
- **Repository Tests**: Individual repository testing

### **Test Coverage Requirements**:
- **Address handling**: All postal code variants
- **Service registration**: All 15 services
- **Repository patterns**: CRUD operations
- **API endpoints**: All service endpoints

---

## 🔍 DEBUGGING PATTERNS

### **Common Issues and Solutions**:

#### **"HealthCheck object has no attribute 'get'"**:
- **Cause**: Health check response format mismatch
- **Solution**: Use HealthCheckConverter in service_registry_manager.py

#### **"Password reset requested for non-existent email"**:
- **Cause**: Repository `_to_entity()` failing due to postal code validation
- **Solution**: Check address field normalization in repository

#### **"Pydantic validation error for Address"**:
- **Cause**: Wrong field name when creating Address objects
- **Solution**: Use `postalCode` (camelCase) when creating Address(**data)

### **Debugging Tools**:
- **CloudWatch Logs**: `/aws/lambda/PeopleRegisterInfrastruct-PeopleApiFunction67A8223-xlC79QhrsKBe`
- **Health Endpoints**: `/health`, `/health/services`
- **Service Registry**: `/registry/services`, `/registry/config`

---

## 📁 FILE ORGANIZATION

### **Core Files (DO NOT DUPLICATE LOGIC)**:
- **Postal Code Normalization**: `src/services/defensive_dynamodb_service.py`
- **Address Validation**: `src/utils/validation_utils.py`
- **Service Registry**: `src/services/service_registry_manager.py`
- **Base Repository**: `src/repositories/base_repository.py`

### **Handler Files**:
- **Active**: `src/handlers/modular_api_handler.py` (Service Registry)
- **Legacy**: `src/handlers/versioned_api_handler.py` (DEPRECATED)

### **Model Files**:
- **Person/Address**: `src/models/person.py`
- **Response Models**: `src/utils/response_models.py`

---

## 🚀 DEPLOYMENT INFORMATION

### **Lambda Functions** (Container-based):
1. **PeopleRegisterInfrastruct-PeopleApiFunction67A8223-xlC79QhrsKBe**
   - Main API function (Service Registry)
   - Entry: `main.py` → `modular_api_handler.py`

2. **AuthFunction** - Authentication handling
3. **RouterFunction** - Request routing

### **Environment Variables**:
```
PEOPLE_TABLE_NAME=PeopleTable
PROJECTS_TABLE_NAME=ProjectsTable  
SES_FROM_EMAIL=noreply@cbba.cloud.org.bo
FRONTEND_URL=https://d28z2il3z2vmpc.cloudfront.net
```

### **DynamoDB Tables**:
- **PeopleTable**: User data (postal_code field)
- **ProjectsTable**: Project data
- **AuditLogsTable**: Audit trail
- **PasswordResetTokensTable**: Reset tokens

---

## ⚠️ CRITICAL RULES FOR AI ASSISTANT

### **NEVER DO**:
1. **Create duplicate postal code normalization logic**
2. **Use different field name patterns for address data**
3. **Deploy application code from infrastructure pipeline**
4. **Modify legacy versioned_api_handler.py**
5. **Create new address handling without following established patterns**

### **ALWAYS DO**:
1. **Check existing implementations before creating new ones**
2. **Follow the postal code normalization patterns**
3. **Use Service Registry architecture for new features**
4. **Write tests for address field handling**
5. **Reference this system map before making changes**

### **BEFORE IMPLEMENTING ANY FEATURE**:
1. **Search codebase for existing similar functionality**
2. **Check if it fits into existing service architecture**
3. **Verify postal code handling requirements**
4. **Review this system map for architectural patterns**
5. **Ensure no duplication of existing logic**

---

## 📈 PERFORMANCE METRICS

### **Current System Performance**:
- **Code Reduction**: 87% (2,797 → 366 lines in main handler)
- **Response Times**: <200ms target maintained
- **Service Health Checks**: <50ms
- **Test Coverage**: 551 tests passing
- **Services Registered**: 15 independent services

### **Monitoring Endpoints**:
- **System Health**: `GET /health`
- **Service Health**: `GET /health/services`
- **Service Discovery**: `GET /registry/services`
- **Configuration**: `GET /registry/config`

---

**END OF SYSTEM MAP**

*This document should be referenced before ANY code changes to prevent architectural inconsistencies and code duplication.*
