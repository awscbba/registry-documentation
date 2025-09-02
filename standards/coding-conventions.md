# Coding Conventions - People Registry Project

## Overview

This document establishes coding standards and conventions for the People Registry project to ensure consistency, maintainability, and code quality across all components.

## General Principles

### Code Quality

- **Readability First**: Code should be self-documenting and easy to understand
- **Consistency**: Follow established patterns within the codebase
- **Simplicity**: Prefer simple, clear solutions over complex ones
- **DRY Principle**: Don't Repeat Yourself - extract common functionality
- **ZERO CODE DUPLICATION**: Always verify that logic to be implemented doesn't exist already or similar behavior already exists in the codebase
- **Enterprise Exception Handling**: Always use established enterprise exception handling and logging patterns
- **SOLID Principles**: Follow SOLID design principles for maintainable code

### Architecture Patterns

- **Clean Architecture**: Separate concerns with clear boundaries
- **Service Layer Pattern**: Business logic in dedicated service classes
- **Repository Pattern**: Data access abstraction
- **Dependency Injection**: Use dependency injection for testability
- **Domain-driven Router Pattern**: API endpoints organized by business domain
- **Domain Boundaries**: Clear separation between business contexts
- **Intelligent Routing**: Route requests based on domain context and business requirements
- **Main Application Factory Pattern**: Centralized application creation and configuration

## Domain-driven Router Architecture

### Router Organization

Organize API endpoints by business domain, not by technical function:

```
src/routers/
├── people_router.py        # Person/User domain
├── projects_router.py      # Project management domain
├── auth_router.py          # Authentication/Security domain
├── subscriptions_router.py # Subscription management domain
├── admin_router.py         # Administrative operations domain
└── public_router.py        # Public-facing operations domain
```

### Domain Router Standards

#### File Structure

```python
# Each router file follows this pattern:
from fastapi import APIRouter, Depends, HTTPException
from ..services.{domain}_service import {Domain}Service
from ..services.service_registry_manager import get_{domain}_service
from ..models.{domain} import {Domain}Create, {Domain}Update, {Domain}Response
from ..utils.responses import create_success_response, create_list_response

router = APIRouter(prefix="/v2/{domain}", tags=["{Domain}"])

@router.get("/", response_model=dict)
async def list_{domain}(
    {domain}_service: {Domain}Service = Depends(get_{domain}_service)
) -> dict:
    # Implementation
```

#### Domain Boundaries

- **Single Domain Focus**: Each router handles ONE business domain only
- **No Cross-Domain Logic**: Never mix domain logic between routers
- **Domain-Specific Models**: Each domain has its own Pydantic models
- **Domain-Specific Validation**: Business rules specific to the domain
- **Domain-Specific Error Handling**: Appropriate HTTP status codes per domain

#### Service Injection

```python
# CORRECT: Domain-specific service injection
people_service: PeopleService = Depends(get_people_service)
projects_service: ProjectsService = Depends(get_projects_service)

# INCORRECT: Cross-domain service injection
people_service: PeopleService = Depends(get_people_service)
projects_service: ProjectsService = Depends(get_projects_service)  # Wrong in people_router
```

#### Intelligent Routing

The RouterService implements domain-aware request routing:

```python
def _determine_target_function(self, path: str) -> str:
    """Route requests based on domain context and business requirements."""
    # Password reset domain -> API Function (requires SES permissions)
    if any(endpoint in path for endpoint in ["/forgot-password", "/reset-password"]):
        return self.api_function_name

    # Auth domain -> Auth Function
    if path.startswith("/auth") or path.startswith("/v2/auth"):
        return self.auth_function_name

    # Default domain -> API Function
    return self.api_function_name
```

### Domain Router Enforcement Rules

#### ❌ NEVER DO:

- Mix domain logic between routers
- Create generic "catch-all" routers
- Inject cross-domain services into routers
- Handle cross-domain operations in routers
- Use generic models across domains

#### ✅ ALWAYS DO:

- Create domain-specific routers with clear boundaries
- Use domain-specific models and validation
- Inject only domain-specific services
- Handle cross-domain operations at service layer
- Follow consistent response formatting
- Implement domain-appropriate error handling

## Main Application Factory Pattern

### Application Factory Standards

Create a single factory function that initializes the entire FastAPI application:

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

    # Add middleware in correct order (security first)
    app.add_middleware(SecurityHeadersMiddleware)
    app.add_middleware(RateLimitingMiddleware, requests_per_minute=100)
    app.add_middleware(EnterpriseMiddleware)
    app.add_middleware(InputValidationMiddleware)
    app.add_middleware(AuthorizationMiddleware)
    app.add_middleware(AuthenticationMiddleware)
    app.add_middleware(CORSMiddleware, allow_origins=["*"])

    # Register all domain routers
    app.include_router(people_router.router)
    app.include_router(projects_router.router)
    app.include_router(subscriptions_router.router)
    app.include_router(auth_router.router)
    app.include_router(admin_router.router)
    app.include_router(public_router.router)

    # Add centralized exception handlers
    app.add_exception_handler(BaseApplicationException, error_handler.handle_application_exception)
    app.add_exception_handler(HTTPException, error_handler.handle_http_exception)
    app.add_exception_handler(Exception, error_handler.handle_generic_exception)

    return app

# Create the application instance
app = create_app()
```

### Factory Pattern Requirements

#### ✅ ALWAYS DO:

- **Single Factory Function**: One `create_app()` function creates entire application
- **Middleware Order**: Apply middleware in correct order (security → rate limiting → enterprise → auth → CORS)
- **Router Registration**: Register all domain routers systematically
- **Exception Handling**: Add centralized exception handlers
- **Configuration**: Load environment-based settings
- **Documentation**: Configure API metadata (title, description, version)
- **Health Endpoints**: Include standard health check endpoints

#### ❌ NEVER DO:

- Create multiple application instances
- Configure middleware outside the factory
- Register routers outside the factory
- Skip exception handler registration
- Hardcode configuration values

### Factory Pattern Benefits

- **Testability**: Easy to create test applications with different configurations
- **Environment Flexibility**: Different configurations for dev/staging/prod
- **Consistency**: Ensures all components are configured correctly
- **Maintainability**: Single place to manage application setup
- **Debugging**: Centralized configuration makes troubleshooting easier

## Python Conventions (Registry API)

### Code Formatting

- **Black**: Use Black formatter with default settings (88 character line length)
- **Import Organization**: Use isort for consistent import ordering
- **Linting**: Use Flake8 for code quality checks

### Naming Conventions

```python
# Classes: PascalCase
class UserService:
    pass

# Functions/Methods: snake_case
def get_user_by_id(user_id: str) -> User:
    pass

# Variables: snake_case
user_count = 10
is_active = True

# Constants: UPPER_SNAKE_CASE
MAX_RETRY_ATTEMPTS = 3
DEFAULT_TIMEOUT = 30

# Private methods: leading underscore
def _validate_input(self, data: dict) -> bool:
    pass
```

### Type Hints

- **Always use type hints** for function parameters and return values
- **Use Union types** for optional parameters
- **Import types** from `typing` module when needed

```python
from typing import Optional, List, Dict, Union
from datetime import datetime

def create_user(
    name: str,
    email: str,
    age: Optional[int] = None
) -> Dict[str, Union[str, int]]:
    pass
```

### Enterprise Exception Handling and Logging

#### **Mandatory Enterprise Logging**

Always use the EnterpriseLoggingService for all logging operations:

```python
from src.services.logging_service import EnterpriseLoggingService, LogLevel, LogCategory, RequestContext

# Structured logging with correlation IDs
logging_service = EnterpriseLoggingService()
logging_service.log_structured(
    level=LogLevel.INFO,
    category=LogCategory.API_ACCESS,
    message="User action completed",
    context=RequestContext(
        request_id=request.correlation_id,
        user_id=current_user.id,
        path=request.path,
        method=request.method
    ),
    additional_data={
        "action": "profile_update",
        "duration_ms": 150
    }
)
```

#### **Enterprise Exception Handling**

Use established enterprise exception types with proper logging:

```python
from src.exceptions.base_exceptions import ValidationException, ResourceNotFoundException
from src.exceptions.error_handler import error_handler

try:
    result = risky_operation()
except Exception as e:
    # Log with full context
    logging_service.log_structured(
        level=LogLevel.ERROR,
        category=LogCategory.ERROR_HANDLING,
        message=f"Operation failed: {str(e)}",
        context=request_context,
        additional_data={
            "operation": "risky_operation",
            "error_type": type(e).__name__
        }
    )

    # Raise enterprise exception
    raise ValidationException(
        message=f"Database operation failed: {str(e)}",
        user_message="Unable to process request at this time",
        error_code="DB_ERROR",
        additional_data={"original_error": str(e)}
    )
```

#### **Enterprise Standards**

- **Structured Logging**: Use JSON logging with correlation IDs
- **User-Safe Messages**: Never expose internal details in error responses
- **Exception Categories**: Use appropriate enterprise exception types
- **Context Preservation**: Always include request context in logs
- **Performance Tracking**: Log operation duration and resource usage

### Documentation

- **Docstrings**: Use Google-style docstrings for all public functions/classes
- **Inline Comments**: Explain complex business logic, not obvious code
- **README Files**: Each component should have comprehensive README

```python
def calculate_user_score(user_data: Dict[str, Any], weights: Dict[str, float]) -> float:
    """Calculate a weighted score for a user based on various metrics.

    Args:
        user_data: Dictionary containing user metrics and attributes
        weights: Dictionary mapping metric names to their weights

    Returns:
        Calculated weighted score as a float between 0.0 and 100.0

    Raises:
        ValidationError: If required metrics are missing from user_data
        ValueError: If weights don't sum to 1.0
    """
    pass
```

## TypeScript/JavaScript Conventions (Frontend)

### Code Formatting

- **Prettier**: Use Prettier with 2-space indentation
- **ESLint**: Use ESLint with TypeScript rules
- **Semicolons**: Always use semicolons

### Naming Conventions

```typescript
// Interfaces: PascalCase with 'I' prefix
interface IUser {
  id: string;
  name: string;
}

// Types: PascalCase
type UserRole = "admin" | "user" | "viewer";

// Functions: camelCase
const getUserById = (id: string): Promise<IUser> => {
  // implementation
};

// Components: PascalCase
const UserProfile: React.FC<IUserProfileProps> = ({ user }) => {
  return <div>{user.name}</div>;
};

// Constants: UPPER_SNAKE_CASE
const API_BASE_URL = "https://api.example.com";
const MAX_RETRY_COUNT = 3;
```

### React Conventions

- **Functional Components**: Prefer functional components with hooks
- **Props Interface**: Always define props interface for components
- **Custom Hooks**: Extract reusable logic into custom hooks
- **Error Boundaries**: Implement error boundaries for robust UX

```typescript
interface IUserProfileProps {
  user: IUser;
  onEdit?: (user: IUser) => void;
}

const UserProfile: React.FC<IUserProfileProps> = ({ user, onEdit }) => {
  const [isEditing, setIsEditing] = useState(false);

  const handleEdit = useCallback(() => {
    setIsEditing(true);
    onEdit?.(user);
  }, [user, onEdit]);

  return (
    <div className="user-profile">
      <h2>{user.name}</h2>
      <button onClick={handleEdit}>Edit</button>
    </div>
  );
};
```

## Infrastructure as Code (CDK/CloudFormation)

### Naming Conventions

- **Resources**: Use descriptive, hierarchical names
- **Stacks**: Include environment and purpose in stack names
- **Tags**: Consistent tagging strategy for all resources

```typescript
// CDK Construct naming
const userTable = new dynamodb.Table(this, "UserTable", {
  tableName: `${props.environment}-people-registry-users`,
  // configuration
});

// Stack naming
class PeopleRegistryApiStack extends Stack {
  constructor(
    scope: Construct,
    id: string,
    props: IPeopleRegistryApiStackProps
  ) {
    super(scope, `${props.environment}-people-registry-api`, props);
  }
}
```

## Database Conventions

### Table Naming

- **Snake Case**: Use snake_case for table and column names
- **Descriptive**: Use clear, descriptive names
- **Prefixes**: Consider prefixes for related tables

```sql
-- Table names
users
user_profiles
user_sessions
admin_audit_logs

-- Column names
user_id
created_at
updated_at
is_active
```

### Indexes

- **Naming**: Include table name and indexed columns
- **Performance**: Index frequently queried columns
- **Composite**: Use composite indexes for multi-column queries

## Git Conventions

### Commit Messages

Follow Conventional Commits specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types**:

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples**:

```
feat(auth): add JWT token validation middleware
fix(api): resolve psutil dependency issue in Docker container
docs(readme): update installation instructions
refactor(services): extract common validation logic
```

### Branch Naming

```
<type>/<short-description>
feature/user-authentication
hotfix/critical-router-implementation
bugfix/admin-panel-loading
docs/api-documentation-update
```

## Testing Conventions

### Test Organization

- **File Naming**: `test_<module_name>.py` or `<module_name>.test.ts`
- **Test Classes**: Group related tests in classes
- **Descriptive Names**: Test names should describe the scenario

```python
class TestUserService:
    def test_create_user_with_valid_data_returns_user_id(self):
        # Arrange
        user_data = {"name": "John Doe", "email": "john@example.com"}

        # Act
        result = user_service.create_user(user_data)

        # Assert
        assert result["user_id"] is not None
        assert result["status"] == "created"
```

### Test Structure

- **AAA Pattern**: Arrange, Act, Assert
- **Mocking**: Mock external dependencies
- **Test Data**: Use factories or fixtures for test data

## Documentation Standards

### README Structure

Each component should have:

1. **Purpose**: What the component does
2. **Installation**: How to set up locally
3. **Usage**: Basic usage examples
4. **API Documentation**: For services
5. **Contributing**: How to contribute
6. **Testing**: How to run tests

### API Documentation

- **OpenAPI/Swagger**: Document all API endpoints
- **Examples**: Include request/response examples
- **Error Codes**: Document all possible error responses

## Security Guidelines

### Sensitive Data

- **No Hardcoded Secrets**: Use environment variables or secret management
- **Input Validation**: Validate all user inputs
- **SQL Injection**: Use parameterized queries
- **XSS Prevention**: Sanitize user-generated content

### Authentication & Authorization

- **JWT Tokens**: Use secure JWT implementation
- **Role-Based Access**: Implement proper RBAC
- **Session Management**: Secure session handling

## Performance Guidelines

### Database

- **Query Optimization**: Use appropriate indexes
- **Connection Pooling**: Implement connection pooling
- **Caching**: Cache frequently accessed data

### API

- **Response Times**: Target < 200ms for most endpoints
- **Pagination**: Implement pagination for large datasets
- **Rate Limiting**: Implement rate limiting for public APIs

## Monitoring and Logging

### Structured Logging

```python
logger.info(
    "User action completed",
    extra={
        "user_id": user.id,
        "action": "profile_update",
        "duration_ms": 150,
        "correlation_id": request.correlation_id
    }
)
```

### Metrics

- **Business Metrics**: Track user actions and business KPIs
- **Technical Metrics**: Monitor performance and errors
- **Alerting**: Set up alerts for critical issues

## Code Review Guidelines

### Review Checklist

- [ ] Code follows established conventions
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] Security considerations addressed
- [ ] Performance impact considered
- [ ] Error handling implemented

### Review Process

1. **Self Review**: Author reviews their own code first
2. **Peer Review**: At least one team member reviews
3. **Automated Checks**: All CI/CD checks must pass
4. **Approval**: Explicit approval required before merge

## Tools and Automation

### Pre-commit Hooks

- **Formatting**: Auto-format code with Black/Prettier
- **Linting**: Run linters on staged files
- **Tests**: Run relevant tests before commit

### CI/CD Pipeline

- **Quality Gates**: Code must pass all quality checks
- **Automated Testing**: Full test suite on every PR
- **Security Scanning**: Automated security vulnerability scanning
- **Deployment**: Automated deployment to staging/production

---

## Enforcement

These conventions are enforced through:

- **Automated tooling** (linters, formatters, pre-commit hooks)
- **Code review process**
- **CI/CD pipeline checks**
- **Team education and documentation**

## Updates

This document should be updated as the project evolves. All changes should be:

- **Discussed with the team**
- **Documented in git history**
- **Communicated to all team members**

---

_Last Updated: August 28, 2025_
_Version: 1.0_
