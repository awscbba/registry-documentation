# Enterprise Architecture Patterns - People Registry

## Overview

This document defines the enterprise architecture patterns implemented in the People Registry system. These patterns ensure maintainability, scalability, testability, and clear separation of concerns across all components.

## Core Architecture Principles

### 1. Clean Architecture
- **Separation of Concerns**: Clear boundaries between layers
- **Dependency Inversion**: High-level modules don't depend on low-level modules
- **Single Responsibility**: Each component has one reason to change
- **Interface Segregation**: Small, focused interfaces

### 2. Domain-Driven Design
- **Domain Boundaries**: Clear separation between business contexts
- **Domain Expertise**: Components understand their domain deeply
- **Ubiquitous Language**: Consistent terminology within domains
- **Domain Services**: Business logic encapsulated in domain services

## Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    API Layer (Routers)                     │
│  Domain-driven routers with single responsibility          │
├─────────────────────────────────────────────────────────────┤
│                   Service Layer                            │
│  Business logic, orchestration, domain expertise           │
├─────────────────────────────────────────────────────────────┤
│                 Repository Layer                           │
│  Data access abstraction, database operations              │
├─────────────────────────────────────────────────────────────┤
│                Infrastructure Layer                        │
│  Database, external services, AWS resources                │
└─────────────────────────────────────────────────────────────┘
```

## Enterprise Patterns Implementation

Our system implements **6 core enterprise patterns** that work together to create a maintainable, scalable, and testable architecture:

### 1. Domain-driven Router Pattern

#### Purpose
Organize API endpoints by business domain rather than technical function, ensuring clear domain boundaries and single responsibility.

#### Implementation
```python
# Domain-specific routers
src/routers/
├── people_router.py        # Person/User domain
├── projects_router.py      # Project management domain
├── auth_router.py          # Authentication/Security domain
├── subscriptions_router.py # Subscription management domain
├── admin_router.py         # Administrative operations domain
└── public_router.py        # Public-facing operations domain
```

#### Standards
- **Single Domain Focus**: Each router handles ONE business domain
- **Domain-Specific Models**: Each domain has its own Pydantic models
- **Domain-Specific Services**: Inject only domain-specific services
- **Domain Boundaries**: No cross-domain logic mixing
- **Consistent Responses**: Use standardized response formatting

#### Example
```python
# people_router.py - Handles ONLY person domain
from ..services.people_service import PeopleService
from ..services.service_registry_manager import get_people_service
from ..models.person import PersonCreate, PersonUpdate, PersonResponse

router = APIRouter(prefix="/v2/people", tags=["People"])

@router.get("/", response_model=dict)
async def list_people(
    people_service: PeopleService = Depends(get_people_service)
) -> dict:
    people = await people_service.list_people()
    return create_list_response(people)
```

### 2. Service Registry Pattern

#### Purpose
Centralized dependency injection container that manages service lifecycles and dependencies, enabling testability and loose coupling.

#### Implementation
```python
# Service Registry Manager
class ServiceRegistryManager:
    def __init__(self):
        self._services = {}
        self._repositories = {}
        self._initialize_repositories()
        self._initialize_services()

    def get_people_service(self) -> PeopleService:
        return self._services["people"]

    def get_projects_service(self) -> ProjectsService:
        return self._services["projects"]
```

#### Standards
- **Centralized Registration**: All services registered in one place
- **Dependency Injection**: Services receive dependencies through constructor
- **Lifecycle Management**: Service registry manages service lifecycles
- **Interface Consistency**: All services follow same interface patterns
- **Testability**: Easy to mock services for testing

### 3. Repository Pattern

#### Purpose
Abstract data access layer that provides consistent interface for database operations while hiding implementation details.

#### Implementation
```python
# Base Repository Interface
class BaseRepository(ABC, Generic[T]):
    @abstractmethod
    async def create(self, item: T) -> T:
        pass

    @abstractmethod
    async def get_by_id(self, item_id: str) -> Optional[T]:
        pass

    @abstractmethod
    async def update(self, item_id: str, updates: dict) -> T:
        pass

    @abstractmethod
    async def delete(self, item_id: str) -> bool:
        pass

    @abstractmethod
    async def list_all(self, limit: Optional[int] = None) -> List[T]:
        pass
```

#### Standards
- **Consistent Interface**: All repositories implement same CRUD operations
- **Data Access Abstraction**: Hide database implementation details
- **Type Safety**: Use generics for type-safe operations
- **Error Handling**: Consistent error handling across repositories
- **Testability**: Easy to mock for unit testing

### 4. Intelligent Routing Pattern

#### Purpose
Route requests to appropriate Lambda functions based on domain context and business requirements, optimizing resource usage and permissions.

#### Implementation
```python
class RouterService:
    def _determine_target_function(self, path: str) -> str:
        """Route requests based on domain context."""
        # Password reset domain -> API Function (SES permissions)
        password_reset_endpoints = ["/forgot-password", "/reset-password", "/validate-reset-token"]
        if any(endpoint in path for endpoint in password_reset_endpoints):
            return self.api_function_name

        # Auth domain -> Auth Function
        if path.startswith("/auth") or path.startswith("/v2/auth"):
            return self.auth_function_name

        # Default domain -> API Function
        return self.api_function_name
```

#### Standards
- **Domain-Aware Routing**: Route based on business domain, not just path
- **Permission-Based Routing**: Consider required permissions for routing decisions
- **Performance Optimization**: Route to most appropriate function for the operation
- **Fallback Strategy**: Always have a default routing strategy

### 5. Main Application Factory Pattern

#### Purpose
Centralize application creation, configuration, and initialization to ensure consistent setup across environments and enable testability.

#### Implementation
```python
def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    app = FastAPI(
        title="People Registry API",
        description="Enterprise API with domain-driven architecture",
        version="2.0.0",
        docs_url="/docs",
        redoc_url="/redoc",
    )

    # Add enterprise middleware (order matters!)
    app.add_middleware(SecurityHeadersMiddleware)
    app.add_middleware(RateLimitingMiddleware, requests_per_minute=100)
    app.add_middleware(EnterpriseMiddleware)
    app.add_middleware(InputValidationMiddleware)
    app.add_middleware(AuthorizationMiddleware)
    app.add_middleware(AuthenticationMiddleware)
    app.add_middleware(CORSMiddleware, allow_origins=["*"])

    # Include domain routers
    app.include_router(people_router.router)
    app.include_router(projects_router.router)
    app.include_router(subscriptions_router.router)
    app.include_router(auth_router.router)
    app.include_router(admin_router.router)
    app.include_router(public_router.router)

    # Add enterprise exception handlers
    app.add_exception_handler(BaseApplicationException, error_handler.handle_application_exception)
    app.add_exception_handler(HTTPException, error_handler.handle_http_exception)
    app.add_exception_handler(Exception, error_handler.handle_generic_exception)

    return app

# Create the application instance
app = create_app()
```

#### Standards
- **Single Factory Function**: One `create_app()` function creates the entire application
- **Middleware Order**: Apply middleware in correct order for security and functionality
- **Router Registration**: Register all domain routers systematically
- **Exception Handling**: Centralized exception handlers for consistent error responses
- **Configuration**: Environment-based settings applied consistently
- **Documentation**: API metadata configured in factory
- **Health Endpoints**: Standard endpoints for monitoring and health checks

#### Benefits
- **Testability**: Easy to create test applications with different configurations
- **Environment Flexibility**: Different configurations for dev/staging/prod environments
- **Consistency**: Ensures all components are configured correctly
- **Maintainability**: Single place to manage application setup
- **Debugging**: Centralized configuration makes troubleshooting easier

### 6. Enterprise Middleware Pattern

#### Purpose
Provide cross-cutting concerns like authentication, authorization, logging, and error handling in a consistent, reusable manner.

#### Implementation
```python
# Enterprise Middleware Stack (order matters!)
app.add_middleware(SecurityHeadersMiddleware)
app.add_middleware(RateLimitingMiddleware, requests_per_minute=100)
app.add_middleware(EnterpriseMiddleware)
app.add_middleware(InputValidationMiddleware)
app.add_middleware(AuthorizationMiddleware)
app.add_middleware(AuthenticationMiddleware)
app.add_middleware(CORSMiddleware, allow_origins=["*"])
```

#### Standards
- **Cross-Cutting Concerns**: Handle authentication, logging, error handling
- **Consistent Application**: Apply middleware consistently across all endpoints
- **Correct Order**: Middleware order matters for security and functionality
- **Configurable**: Middleware should be configurable per environment
- **Performance**: Minimal performance impact
- **Observability**: Comprehensive logging and monitoring

#### Standards
- **Cross-Cutting Concerns**: Handle authentication, logging, error handling
- **Consistent Application**: Apply middleware consistently across all endpoints
- **Configurable**: Middleware should be configurable per environment
- **Performance**: Minimal performance impact
- **Observability**: Comprehensive logging and monitoring

## Domain Organization

### Business Domains

#### 1. People Domain
- **Responsibility**: Person/User management
- **Components**: PeopleService, PeopleRepository, people_router
- **Models**: Person, PersonCreate, PersonUpdate, PersonResponse
- **Boundaries**: User profiles, authentication data, personal information

#### 2. Projects Domain
- **Responsibility**: Project management and lifecycle
- **Components**: ProjectsService, ProjectsRepository, projects_router
- **Models**: Project, ProjectCreate, ProjectUpdate, ProjectResponse
- **Boundaries**: Project data, project status, project metadata

#### 3. Authentication Domain
- **Responsibility**: Authentication and session management
- **Components**: AuthService, auth_router
- **Models**: LoginRequest, LoginResponse, User, TokenData
- **Boundaries**: JWT tokens, password management, session handling

#### 4. Subscriptions Domain
- **Responsibility**: Project subscription management
- **Components**: SubscriptionsService, SubscriptionsRepository, subscriptions_router
- **Models**: Subscription, SubscriptionCreate, SubscriptionUpdate
- **Boundaries**: Person-project relationships, subscription status

#### 5. Administration Domain
- **Responsibility**: Administrative operations and monitoring
- **Components**: AdminService, admin_router
- **Models**: AdminDashboard, BulkAction, AdminUser
- **Boundaries**: System administration, user management, analytics

#### 6. Public Domain
- **Responsibility**: Public-facing operations (no authentication)
- **Components**: public_router
- **Models**: PublicSubscription
- **Boundaries**: Public forms, anonymous operations

## Quality Assurance Patterns

### 1. Comprehensive Testing Strategy

#### Test Organization
```
tests/
├── unit/                   # Unit tests for individual components
├── integration/            # Integration tests for component interaction
├── e2e/                   # End-to-end tests for complete workflows
└── fixtures/              # Test data and mocks
```

#### Testing Standards
- **AAA Pattern**: Arrange, Act, Assert structure
- **Mocking**: Mock external dependencies
- **Test Coverage**: Target 95%+ coverage
- **Descriptive Names**: Test names describe the scenario
- **Domain-Specific Tests**: Tests organized by domain

### 2. Error Handling Pattern

#### Structured Error Responses
```python
class ServiceRegistryError(Exception):
    def __init__(self, message: str, user_message: str = None, error_code: str = None):
        super().__init__(message)
        self.user_message = user_message or "An internal error occurred"
        self.error_code = error_code
```

#### Standards
- **User-Safe Messages**: Never expose internal details
- **Structured Logging**: Log errors with correlation IDs
- **Domain-Specific Errors**: Error types specific to business domain
- **HTTP Status Codes**: Appropriate status codes per error type

### 3. Observability Pattern

#### Structured Logging
```python
logger.info(
    "User action completed",
    extra={
        "user_id": user.id,
        "action": "profile_update",
        "duration_ms": 150,
        "correlation_id": request.correlation_id,
        "domain": "people"
    }
)
```

#### Standards
- **Correlation IDs**: Track requests across services
- **Structured Data**: JSON-formatted log entries
- **Domain Context**: Include domain information in logs
- **Performance Metrics**: Track response times and resource usage

## Deployment Architecture

### Lambda Function Organization

#### Function Separation
- **Router Function**: Routes requests to appropriate functions
- **API Function**: Handles main API operations
- **Auth Function**: Handles authentication operations

#### Container-Based Deployment
- **Docker Containers**: All functions deployed as containers
- **ECR Registry**: Container images stored in Amazon ECR
- **Automated Deployment**: CI/CD pipeline handles deployments

### Infrastructure as Code

#### CDK Implementation
```typescript
// Domain-specific infrastructure
const peopleTable = new dynamodb.Table(this, 'PeopleTable', {
  tableName: `${environment}-people-registry-people`,
  // configuration
});

const projectsTable = new dynamodb.Table(this, 'ProjectsTable', {
  tableName: `${environment}-people-registry-projects`,
  // configuration
});
```

## Enforcement and Compliance

### Automated Enforcement
- **Pre-commit Hooks**: Enforce coding standards before commit
- **CI/CD Pipeline**: Quality gates prevent deployment of non-compliant code
- **Linting Rules**: Automated detection of pattern violations
- **Test Requirements**: All patterns must be covered by tests

### Code Review Standards
- **Architecture Review**: Ensure patterns are followed correctly
- **Domain Boundary Review**: Verify domain boundaries are maintained
- **Performance Review**: Assess performance impact of implementations
- **Security Review**: Validate security implications of changes

### Monitoring and Metrics
- **Pattern Compliance**: Monitor adherence to architectural patterns
- **Performance Metrics**: Track performance impact of pattern implementations
- **Error Rates**: Monitor error rates by domain and pattern
- **Business Metrics**: Track business value delivered by each domain

## Evolution and Maintenance

### Pattern Updates
- **Team Discussion**: All pattern changes discussed with team
- **Documentation Updates**: Patterns documented and communicated
- **Migration Strategy**: Plan for migrating existing code to new patterns
- **Training**: Team education on pattern usage and benefits

### Continuous Improvement
- **Regular Reviews**: Periodic review of pattern effectiveness
- **Feedback Integration**: Incorporate team feedback on pattern usage
- **Industry Best Practices**: Stay current with industry developments
- **Performance Optimization**: Continuously optimize pattern implementations

---

## Summary

These enterprise architecture patterns provide:

- **Maintainability**: Clear structure and separation of concerns
- **Scalability**: Patterns that support system growth
- **Testability**: Easy to test and validate functionality
- **Reliability**: Consistent error handling and observability
- **Performance**: Optimized routing and resource usage
- **Security**: Built-in security considerations
- **Developer Experience**: Clear guidelines and consistent patterns

All development must follow these patterns to ensure system quality and long-term maintainability.

---

*Last Updated: August 29, 2025*
*Version: 1.0*