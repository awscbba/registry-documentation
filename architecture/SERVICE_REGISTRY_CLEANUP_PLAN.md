# Service Registry Pattern Implementation Plan

## Current Problems

### 1. Code Duplication & Inconsistency
- **3 different API handlers** (`api_handler.py`, `enhanced_api_handler.py`, `auth_handler.py`)
- **2 password services** (`enhanced_password_service_v2.py`, `password_management_service.py`)
- **Inconsistent patterns**: Some OOP, some functional, mixed error handling
- **No centralized configuration**: Each service manages its own config
- **Direct dependencies**: Services directly import each other

### 2. Missing Service Registry Architecture
- No service discovery mechanism
- No dependency injection container
- No unified service lifecycle management
- No centralized logging/monitoring
- No consistent error handling

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

### Phase 1: Core Service Registry (Week 1)
1. **Create Service Registry Container**
   - `services/registry.py` - Central service container
   - `services/base_service.py` - Base service interface
   - `config/service_config.py` - Unified configuration

2. **Standardize Service Interface**
   - Common error handling
   - Unified logging
   - Consistent response format
   - Health check endpoints

### Phase 2: Service Consolidation (Week 2)
1. **Merge Duplicate Services**
   - Consolidate 3 API handlers → 1 unified handler
   - Merge 2 password services → 1 password service
   - Create single auth service
   - Unified email service

2. **Create Domain Services**
   - `AuthService` - Authentication & authorization
   - `UserService` - User management
   - `ProjectService` - Project operations
   - `EmailService` - Email operations
   - `AuditService` - Audit logging
   - `SecurityService` - Security utilities

### Phase 3: Data Access Layer (Week 3)
1. **Repository Pattern**
   - `repositories/user_repository.py`
   - `repositories/project_repository.py`
   - `repositories/audit_repository.py`

2. **Database Abstraction**
   - Unified DynamoDB client
   - Query builders
   - Transaction management

### Phase 4: API Layer Cleanup (Week 4)
1. **Single API Handler**
   - Route-based service resolution
   - Middleware pipeline
   - Request/response transformation

2. **OpenAPI Specification**
   - Auto-generated documentation
   - Request validation
   - Response schemas

## File Structure After Cleanup

```
lambda/
├── main.py                     # Single entry point
├── config/
│   ├── __init__.py
│   ├── service_config.py       # Unified configuration
│   └── environment.py          # Environment variables
├── services/
│   ├── __init__.py
│   ├── registry.py             # Service registry container
│   ├── base_service.py         # Base service interface
│   ├── auth_service.py         # Authentication service
│   ├── user_service.py         # User management
│   ├── project_service.py      # Project operations
│   ├── email_service.py        # Email operations
│   ├── audit_service.py        # Audit logging
│   └── security_service.py     # Security utilities
├── repositories/
│   ├── __init__.py
│   ├── base_repository.py      # Base repository
│   ├── user_repository.py      # User data access
│   ├── project_repository.py   # Project data access
│   └── audit_repository.py     # Audit data access
├── middleware/
│   ├── __init__.py
│   ├── auth_middleware.py      # Authentication middleware
│   ├── rate_limit_middleware.py # Rate limiting
│   └── audit_middleware.py     # Audit logging
├── utils/
│   ├── __init__.py
│   ├── response_builder.py     # Unified responses
│   ├── validators.py           # Input validation
│   └── exceptions.py           # Custom exceptions
└── requirements.txt
```

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

- **Week 1**: Core service registry and base interfaces
- **Week 2**: Service consolidation and domain services
- **Week 3**: Data access layer and repositories
- **Week 4**: API layer cleanup and documentation
- **Week 5**: Testing and deployment

## Risk Mitigation

1. **Breaking Changes**: Maintain API compatibility during migration
2. **Performance Impact**: Benchmark before/after implementation
3. **Complexity**: Start with simple services, gradually add complexity
4. **Team Adoption**: Clear documentation and training sessions
