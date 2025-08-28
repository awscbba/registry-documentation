# Development Code Conventions Standard

## Overview

This document establishes consistent coding conventions across the People Registry project to ensure maintainability, readability, and prevent integration issues between frontend and backend systems.

## Field Naming Conventions

### **STANDARD: Use camelCase for all API responses and frontend code**

#### ✅ Correct (camelCase):
```javascript
{
  "id": "123",
  "firstName": "John",
  "lastName": "Doe", 
  "createdAt": "2024-08-26T10:00:00Z",
  "updatedAt": "2024-08-26T10:00:00Z",
  "projectId": "456",
  "personId": "789",
  "startDate": "2024-01-01",
  "endDate": "2024-12-31"
}
```

#### ❌ Incorrect (snake_case):
```javascript
{
  "id": "123",
  "first_name": "John",        // Should be firstName
  "last_name": "Doe",          // Should be lastName
  "created_at": "2024...",     // Should be createdAt
  "updated_at": "2024...",     // Should be updatedAt
  "project_id": "456",         // Should be projectId
  "person_id": "789"           // Should be personId
}
```

### Backend Implementation

#### Python/FastAPI (Backend):
```python
# Use Pydantic models with alias_generator for automatic conversion
from pydantic import BaseModel, Field
from pydantic.alias_generators import to_camel

class PersonResponse(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel)
    
    id: str
    first_name: str  # Internal: snake_case
    last_name: str   # Internal: snake_case
    created_at: datetime  # Internal: snake_case
    # API returns: {"firstName": "...", "lastName": "...", "createdAt": "..."}
```

#### TypeScript (Frontend):
```typescript
// All interfaces use camelCase
interface Person {
  id: string;
  firstName: string;    // Matches API response
  lastName: string;     // Matches API response
  createdAt: string;    // Matches API response
  updatedAt: string;    // Matches API response
}
```

## Database Conventions

### **STANDARD: Use snake_case for database columns**

```sql
-- Database schema uses snake_case (PostgreSQL/DynamoDB standard)
CREATE TABLE people (
    id UUID PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
```

### **Conversion Layer Responsibility:**

- **Database → Backend**: ORM handles snake_case to camelCase conversion
- **Backend → API**: Pydantic models with `alias_generator=to_camel`
- **API → Frontend**: Direct consumption (no transformation needed)

## File and Directory Naming

### Frontend (TypeScript/React):
```
✅ Correct:
- components/PersonForm.tsx
- services/projectApi.ts
- utils/fieldMapping.ts
- types/person.ts

❌ Incorrect:
- components/person_form.tsx
- services/project_api.ts
- utils/field_mapping.ts
```

### Backend (Python):
```
✅ Correct:
- services/person_service.py
- repositories/project_repository.py
- models/subscription_model.py
- utils/field_mapper.py

❌ Incorrect:
- services/PersonService.py
- repositories/ProjectRepository.py
```

### Infrastructure (CDK/CloudFormation):
```
✅ Correct:
- PeopleApiFunction
- ProjectSubscriptionTable
- AdminDashboardStack

❌ Incorrect:
- people_api_function
- project-subscription-table
```

## API Endpoint Conventions

### **STANDARD: Use kebab-case for URLs, camelCase for JSON**

```
✅ Correct:
GET /api/v2/people
GET /api/v2/project-subscriptions
POST /api/v2/admin/user-management

Response body (camelCase):
{
  "success": true,
  "data": {
    "firstName": "John",
    "projectId": "123"
  }
}

❌ Incorrect:
GET /api/v2/people_management
GET /api/v2/projectSubscriptions
Response with snake_case fields
```

## Variable and Function Naming

### TypeScript/JavaScript:
```typescript
✅ Correct:
const getUserSubscriptions = async (personId: string) => { ... }
const projectSubscriptionManager = new ProjectSubscriptionManager();
const isActiveSubscription = subscription.status === 'active';

❌ Incorrect:
const get_user_subscriptions = async (person_id: string) => { ... }
const project_subscription_manager = new ProjectSubscriptionManager();
```

### Python:
```python
✅ Correct:
def get_user_subscriptions(person_id: str) -> List[Subscription]:
    pass

class ProjectSubscriptionService:
    def create_subscription(self, project_id: str, person_id: str):
        pass

❌ Incorrect:
def getUserSubscriptions(personId: str) -> List[Subscription]:
    pass
```

## Error Handling Conventions

### API Error Responses (camelCase):
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": {
      "fieldErrors": {
        "firstName": "First name is required",
        "projectId": "Invalid project ID format"
      }
    }
  }
}
```

## Logging Conventions

### Structured Logging (camelCase for consistency):
```typescript
// Frontend
logger.info('User subscription created', {
  personId: '123',
  projectId: '456',
  subscriptionId: '789',
  eventType: 'subscription_created'
});
```

```python
# Backend
logger.info(
    "User subscription created",
    extra={
        "person_id": "123",      # Internal snake_case
        "project_id": "456",     # Internal snake_case
        "subscription_id": "789", # Internal snake_case
        "event_type": "subscription_created"
    }
)
```

## Migration Strategy

### Phase 1: Backend API Standardization
1. **Update Pydantic models** to use `alias_generator=to_camel`
2. **Ensure all API responses** return camelCase fields
3. **Maintain database** snake_case (no changes needed)

### Phase 2: Frontend Cleanup
1. **Remove field mapping utilities** (no longer needed)
2. **Update TypeScript interfaces** to match API responses
3. **Clean up transformation code** in services

### Phase 3: Documentation and Tooling
1. **ESLint rules** for naming conventions
2. **API documentation** with consistent examples
3. **Code review checklists** for naming standards

## Enforcement Tools

### Frontend (ESLint):
```json
{
  "rules": {
    "@typescript-eslint/naming-convention": [
      "error",
      {
        "selector": "variableLike",
        "format": ["camelCase"]
      },
      {
        "selector": "typeLike",
        "format": ["PascalCase"]
      }
    ]
  }
}
```

### Backend (Python):
```python
# Use pylint or black with naming conventions
# pyproject.toml
[tool.pylint.basic]
good-names = ["id", "db", "pk"]
function-naming-style = "snake_case"
class-naming-style = "PascalCase"
```

## Benefits of Standardization

1. **Eliminates field mapping complexity**
2. **Reduces integration bugs**
3. **Improves developer experience**
4. **Easier code reviews and maintenance**
5. **Consistent API documentation**
6. **Better IDE support and autocomplete**

## Implementation Priority

### High Priority (Fix Now):
- [ ] Subscription API responses (already fixed in frontend)
- [ ] Person API responses
- [ ] Project API responses (already correct)

### Medium Priority (Next Sprint):
- [ ] Admin dashboard APIs
- [ ] Authentication APIs
- [ ] Error response formats

### Low Priority (Future):
- [ ] Legacy endpoint cleanup
- [ ] Database migration (if needed)
- [ ] Historical data transformation

## Code Review Checklist

### For API Changes:
- [ ] All JSON responses use camelCase
- [ ] URL endpoints use kebab-case
- [ ] TypeScript interfaces match API responses
- [ ] No field transformation needed in frontend

### For Frontend Changes:
- [ ] Variables and functions use camelCase
- [ ] Component names use PascalCase
- [ ] File names follow established patterns
- [ ] No snake_case in TypeScript code

### For Backend Changes:
- [ ] Python functions use snake_case
- [ ] Class names use PascalCase
- [ ] Pydantic models have proper alias configuration
- [ ] API responses tested for camelCase output

---

**Last Updated**: August 26, 2024  
**Version**: 1.0  
**Status**: Active Standard