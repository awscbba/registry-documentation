# Service Registry Pattern Implementation Plan

## Current Problems

### 1. Code Duplication & Inconsistency
- **Multiple API handlers** (`versioned_api_handler.py` - 95KB monolithic file)
- **Existing services** not following Service Registry pattern
- **Inconsistent patterns**: Some OOP, some functional, mixed error handling
- **No centralized configuration**: Each service manages its own config
- **Direct dependencies**: Services directly import each other

### 2. Missing Service Registry Architecture
- No service discovery mechanism
- No dependency injection container
- No unified service lifecycle management
- No centralized logging/monitoring
- No consistent error handling

## Current Directory Structure (registry-api/src/)

```
registry-api/src/
├── core/                       # ✅ NEW - Service Registry Infrastructure
│   ├── __init__.py            # ✅ Service Registry exports
│   ├── base_service.py        # ✅ Base service interface
│   ├── registry.py            # ✅ Dependency injection container
│   └── config.py              # ✅ Unified configuration management
├── services/                   # 🔄 EXISTING - Need Service Registry integration
│   ├── auth_service.py        # 🔄 Needs Service Registry pattern
│   ├── roles_service.py       # 🔄 Needs Service Registry pattern
│   ├── email_service.py       # 🔄 Needs Service Registry pattern
│   ├── logging_service.py     # 🔄 Needs Service Registry pattern
│   ├── rate_limiting_service.py # 🔄 Needs Service Registry pattern
│   └── defensive_dynamodb_service.py # 🔄 Needs Service Registry pattern
├── handlers/                   # 🔄 EXISTING - Need consolidation
│   ├── versioned_api_handler.py # ❌ 95KB monolithic handler
│   └── roles_handler.py       # 🔄 Separate handler
├── middleware/                 # ✅ EXISTING - Good structure
│   ├── auth_middleware.py
│   ├── admin_middleware_v2.py
│   ├── error_handler_middleware.py
│   └── rate_limit_middleware.py
├── models/                     # ✅ EXISTING - Good structure
├── utils/                      # ✅ EXISTING - Good structure
└── __init__.py
```

## Target Architecture: Service Registry Pattern

```
┌─────────────────────────────────────────────────────────────┐
│                    API Gateway Handler                      │
│                   (Single Entry Point)                     │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                Service Registry                             │
│  ┌─────────────────┬─────────────────┬─────────────────┐   │
│  │   Auth Service  │  Email Service  │ Project Service │   │
│  └─────────────────┴─────────────────┴─────────────────┘   │
│  ┌─────────────────┬─────────────────┬─────────────────┐   │
│  │  User Service   │ Audit Service   │ Security Service│   │
│  └─────────────────┴─────────────────┴─────────────────┘   │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                 Data Access Layer                          │
│  ┌─────────────────┬─────────────────┬─────────────────┐   │
│  │ DynamoDB Client │   SES Client    │  S3 Client      │   │
│  └─────────────────┴─────────────────┴─────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Implementation Plan

### Phase 1: Core Service Registry ✅ COMPLETED
1. **✅ Create Service Registry Container**
   - `src/core/registry.py` - Central service container
   - `src/core/base_service.py` - Base service interface
   - `src/core/config.py` - Unified configuration

2. **✅ Standardize Service Interface**
   - Common error handling
   - Unified logging
   - Consistent response format
   - Health check endpoints

### Phase 2: Service Consolidation (CURRENT PHASE)
1. **Migrate Existing Services to Service Registry Pattern**
   - Update `auth_service.py` to inherit from BaseService
   - Update `email_service.py` to inherit from BaseService
   - Update `roles_service.py` to inherit from BaseService
   - Update `logging_service.py` to inherit from BaseService
   - Update `rate_limiting_service.py` to inherit from BaseService

2. **Create Missing Domain Services**
   - `UserService` - User management (extract from versioned_api_handler.py)
   - `ProjectService` - Project operations (extract from versioned_api_handler.py)
   - `SubscriptionService` - Subscription management (extract from versioned_api_handler.py)
   - `AuditService` - Audit logging (enhance logging_service.py)
   - `SecurityService` - Security utilities

3. **Consolidate Handlers**
   - Break down `versioned_api_handler.py` (95KB) into service calls
   - Merge `roles_handler.py` functionality into unified handler
   - Create single, clean API handler using Service Registry

### Phase 3: Data Access Layer (NEXT)
1. **Repository Pattern**
   - `src/repositories/user_repository.py`
   - `src/repositories/project_repository.py`
   - `src/repositories/audit_repository.py`

2. **Database Abstraction**
   - Enhance `defensive_dynamodb_service.py` as base repository
   - Unified DynamoDB client
   - Query builders
   - Transaction management

### Phase 4: API Layer Cleanup (FINAL)
1. **Single API Handler**
   - Route-based service resolution
   - Middleware pipeline
   - Request/response transformation

2. **OpenAPI Specification**
   - Auto-generated documentation
   - Request validation
   - Response schemas

## Target File Structure After Cleanup

```
registry-api/src/
├── core/                       # ✅ Service Registry Infrastructure
│   ├── __init__.py
│   ├── base_service.py         # ✅ Base service interface
│   ├── registry.py             # ✅ Service registry container
│   └── config.py               # ✅ Unified configuration
├── services/                   # 🔄 Domain Services (Service Registry pattern)
│   ├── __init__.py
│   ├── auth_service.py         # 🔄 Authentication service
│   ├── user_service.py         # 🆕 User management
│   ├── project_service.py      # 🆕 Project operations
│   ├── subscription_service.py # 🆕 Subscription management
│   ├── email_service.py        # 🔄 Email operations
│   ├── audit_service.py        # 🔄 Audit logging
│   ├── security_service.py     # 🆕 Security utilities
│   └── roles_service.py        # 🔄 Role management
├── repositories/               # 🆕 Data Access Layer
│   ├── __init__.py
│   ├── base_repository.py      # 🆕 Base repository
│   ├── user_repository.py      # 🆕 User data access
│   ├── project_repository.py   # 🆕 Project data access
│   └── audit_repository.py     # 🆕 Audit data access
├── handlers/                   # 🔄 Unified API Handler
│   ├── __init__.py
│   └── api_handler.py          # 🔄 Single, clean handler
├── middleware/                 # ✅ Cross-cutting Concerns
│   ├── __init__.py
│   ├── auth_middleware.py      # ✅ Authentication middleware
│   ├── admin_middleware_v2.py  # ✅ Admin access control
│   ├── rate_limit_middleware.py # ✅ Rate limiting
│   └── error_handler_middleware.py # ✅ Error handling
├── models/                     # ✅ Data Models
├── utils/                      # ✅ Utilities
└── main.py                     # 🔄 Application entry point
```

## Current Status: Phase 1 Complete ✅

### ✅ Completed
- Core Service Registry infrastructure
- Base service interface with health checks
- Unified configuration management
- Dependency injection container
- Service lifecycle management

### 🔄 In Progress: Phase 2
- Migrating existing services to Service Registry pattern
- Breaking down monolithic handler
- Creating missing domain services

## Benefits After Implementation

### 1. **Maintainability**
- Single responsibility principle
- Clear separation of concerns
- Easy to test individual services
- Consistent code patterns

### 2. **Scalability**
- Services can be extracted to separate Lambdas
- Independent scaling
- Easy to add new services

### 3. **Reliability**
- Centralized error handling
- Consistent logging
- Health checks
- Circuit breaker patterns

### 4. **Developer Experience**
- Clear service contracts
- Auto-generated documentation
- Easy to understand architecture
- Faster development

## Migration Strategy

### 1. **Backward Compatibility**
- Keep existing endpoints working
- Gradual migration of functionality
- Feature flags for new services

### 2. **Testing Strategy**
- Unit tests for each service
- Integration tests for service interactions
- End-to-end API tests

### 3. **Deployment Strategy**
- Blue-green deployment
- Canary releases
- Rollback capabilities

## Success Metrics

- **Code Reduction**: 50% reduction in total lines of code
- **Duplication Elimination**: 0% code duplication
- **Test Coverage**: 90%+ coverage
- **Performance**: <200ms API response times
- **Maintainability**: New features take 50% less time to implement

## Timeline

- **Phase 1**: Core service registry and base interfaces ✅ **COMPLETED**
- **Phase 2**: Service consolidation and domain services (2 weeks)
- **Phase 3**: Data access layer and repositories (1 week)
- **Phase 4**: API layer cleanup and documentation (1 week)

## Risk Mitigation

1. **Breaking Changes**: Maintain API compatibility during migration
2. **Performance Impact**: Benchmark before/after implementation
3. **Complexity**: Start with simple services, gradually add complexity
4. **Team Adoption**: Clear documentation and training sessions

## Next Immediate Steps

1. **Update existing services** to inherit from `BaseService`
2. **Register services** with the `ServiceRegistry`
3. **Extract domain logic** from `versioned_api_handler.py`
4. **Create missing services** (UserService, ProjectService, etc.)
5. **Implement repository pattern** for data access
