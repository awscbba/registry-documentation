# Backend Field Naming Migration Guide

## Overview

This guide provides step-by-step instructions for migrating the backend API to consistently return camelCase field names, eliminating the need for frontend field transformations.

## Current State Analysis

Based on our debug analysis:

### ✅ Already Correct (camelCase):
- **Projects API**: Returns `createdAt`, `updatedAt`, `startDate`, `endDate`
- **Admin Dashboard**: Mostly consistent

### ❌ Needs Migration (snake_case):
- **Subscriptions API**: Returns `person_id`, `project_id`, `created_at`, `updated_at`
- **People API**: Likely returns `first_name`, `last_name`, `created_at`, `updated_at`

## Implementation Strategy

### Option 1: Pydantic Alias Generator (Recommended)

#### Step 1: Update Pydantic Models

```python
# registry-api/src/models/subscription_model.py
from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel
from datetime import datetime
from typing import Optional

class SubscriptionResponse(BaseModel):
    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True  # Allow both snake_case and camelCase input
    )
    
    id: str
    person_id: str          # Internal: snake_case
    project_id: str         # Internal: snake_case  
    person_name: Optional[str] = None
    person_email: Optional[str] = None
    status: str
    notes: Optional[str] = None
    email_sent: bool = False
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    
    # API will return:
    # {
    #   "id": "...",
    #   "personId": "...",      # Converted from person_id
    #   "projectId": "...",     # Converted from project_id
    #   "personName": "...",    # Converted from person_name
    #   "personEmail": "...",   # Converted from person_email
    #   "emailSent": false,     # Converted from email_sent
    #   "createdAt": "...",     # Converted from created_at
    #   "updatedAt": "..."      # Converted from updated_at
    # }
```

#### Step 2: Update Person Model

```python
# registry-api/src/models/person_model.py
from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel
from datetime import datetime
from typing import Optional

class PersonResponse(BaseModel):
    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True
    )
    
    id: str
    first_name: str         # → firstName
    last_name: str          # → lastName
    email: str
    phone: Optional[str] = None
    company: Optional[str] = None
    position: Optional[str] = None
    bio: Optional[str] = None
    linkedin_url: Optional[str] = None  # → linkedinUrl
    twitter_url: Optional[str] = None   # → twitterUrl
    github_url: Optional[str] = None    # → githubUrl
    website_url: Optional[str] = None   # → websiteUrl
    birth_date: Optional[str] = None    # → birthDate
    join_date: Optional[str] = None     # → joinDate
    is_active: bool = True              # → isActive
    created_at: Optional[datetime] = None  # → createdAt
    updated_at: Optional[datetime] = None  # → updatedAt
```

#### Step 3: Update Service Layer

```python
# registry-api/src/services/subscription_service.py
from typing import List
from src.models.subscription_model import SubscriptionResponse
from src.repositories.subscription_repository import SubscriptionRepository

class SubscriptionService:
    def __init__(self, repository: SubscriptionRepository):
        self.repository = repository
    
    async def get_all_subscriptions(self) -> List[SubscriptionResponse]:
        # Get data from repository (snake_case from DB)
        raw_subscriptions = await self.repository.get_all()
        
        # Convert to Pydantic models (automatic camelCase conversion)
        return [
            SubscriptionResponse(**subscription) 
            for subscription in raw_subscriptions
        ]
    
    async def get_person_subscriptions(self, person_id: str) -> List[SubscriptionResponse]:
        raw_subscriptions = await self.repository.get_by_person_id(person_id)
        return [
            SubscriptionResponse(**subscription) 
            for subscription in raw_subscriptions
        ]
```

#### Step 4: Update API Handlers

```python
# registry-api/src/handlers/modular_api_handler.py
from src.services.subscription_service import SubscriptionService
from src.models.subscription_model import SubscriptionResponse

class ModularApiHandler:
    def __init__(self):
        self.subscription_service = SubscriptionService()
    
    async def handle_get_subscriptions(self, event, context):
        try:
            subscriptions = await self.subscription_service.get_all_subscriptions()
            
            # Pydantic automatically converts to camelCase
            return {
                'statusCode': 200,
                'headers': self._get_cors_headers(),
                'body': json.dumps({
                    'success': True,
                    'data': [sub.model_dump() for sub in subscriptions],  # camelCase output
                    'version': 'v2'
                })
            }
        except Exception as e:
            return self._handle_error(e)
```

### Option 2: Manual Field Mapping (Alternative)

If Pydantic alias generator is not available:

```python
# registry-api/src/utils/field_mapper.py
def snake_to_camel(snake_str: str) -> str:
    """Convert snake_case to camelCase"""
    components = snake_str.split('_')
    return components[0] + ''.join(word.capitalize() for word in components[1:])

def transform_dict_keys(data: dict) -> dict:
    """Transform all keys in a dictionary from snake_case to camelCase"""
    if not isinstance(data, dict):
        return data
    
    return {
        snake_to_camel(key): transform_dict_keys(value) if isinstance(value, dict) else value
        for key, value in data.items()
    }

def transform_subscription_response(subscription: dict) -> dict:
    """Transform subscription data to camelCase"""
    field_mapping = {
        'person_id': 'personId',
        'project_id': 'projectId',
        'person_name': 'personName',
        'person_email': 'personEmail',
        'email_sent': 'emailSent',
        'created_at': 'createdAt',
        'updated_at': 'updatedAt'
    }
    
    transformed = {}
    for key, value in subscription.items():
        new_key = field_mapping.get(key, key)
        transformed[new_key] = value
    
    return transformed
```

## Migration Steps

### Phase 1: Backend Updates (Week 1)

1. **Install/Update Pydantic** (if needed):
   ```bash
   cd registry-api
   uv add "pydantic>=2.0"
   ```

2. **Create Response Models**:
   - Update `SubscriptionResponse` with `alias_generator=to_camel`
   - Update `PersonResponse` with `alias_generator=to_camel`
   - Keep existing models for backward compatibility

3. **Update Service Layer**:
   - Modify services to return Pydantic response models
   - Ensure all API endpoints use new models

4. **Test API Responses**:
   ```bash
   # Test subscription endpoint
   curl -X GET "https://api-url/v2/subscriptions" | jq .
   
   # Should return camelCase fields:
   # {
   #   "success": true,
   #   "data": [
   #     {
   #       "id": "123",
   #       "personId": "456",     # ✅ camelCase
   #       "projectId": "789",    # ✅ camelCase
   #       "createdAt": "2024..." # ✅ camelCase
   #     }
   #   ]
   # }
   ```

### Phase 2: Frontend Cleanup (Week 2)

1. **Remove Field Mapping Utilities**:
   ```bash
   # Remove the transformation utilities we created
   rm registry-frontend/src/utils/fieldMapping.ts
   ```

2. **Update API Service Layer**:
   ```typescript
   // registry-frontend/src/services/projectApi.ts
   async getAllSubscriptions(): Promise<Subscription[]> {
     const response = await fetch(getApiUrl(API_CONFIG.ENDPOINTS.SUBSCRIPTIONS), {
       headers: addAuthHeaders()
     });
     const data = await handleApiResponse(response);

     // No transformation needed - backend returns camelCase
     if (data && data.data && Array.isArray(data.data)) {
       return data.data; // Direct return, no transformSubscriptions()
     } else if (Array.isArray(data)) {
       return data;
     } else {
       return [];
     }
   }
   ```

3. **Verify TypeScript Interfaces**:
   ```typescript
   // registry-frontend/src/types/project.ts
   export interface Subscription {
     id: string;
     personId: string;    // ✅ Matches backend camelCase
     projectId: string;   // ✅ Matches backend camelCase
     status: 'active' | 'cancelled' | 'pending';
     personEmail?: string;
     personName?: string;
     emailSent?: boolean;
     createdAt?: string | null;
     updatedAt?: string | null;
     notes?: string | null;
   }
   ```

### Phase 3: Testing and Validation (Week 3)

1. **Integration Testing**:
   - Test all API endpoints return camelCase
   - Verify frontend consumes data correctly
   - Check admin dashboard functionality

2. **Remove Debug Logging**:
   ```typescript
   // Remove debug console.log statements we added
   // registry-frontend/src/services/projectApi.ts
   ```

3. **Update Documentation**:
   - API documentation with camelCase examples
   - Update TypeScript interface documentation

## Rollback Plan

If issues arise during migration:

1. **Backend Rollback**:
   ```python
   # Temporarily disable alias_generator
   class SubscriptionResponse(BaseModel):
       model_config = ConfigDict(
           # alias_generator=to_camel,  # Comment out
           populate_by_name=True
       )
   ```

2. **Frontend Rollback**:
   ```typescript
   // Re-enable field transformations
   import { transformSubscriptions } from '../utils/fieldMapping';
   return transformSubscriptions(subscriptions);
   ```

## Benefits After Migration

1. **✅ Simplified Frontend Code**: No field transformation utilities needed
2. **✅ Consistent API Responses**: All endpoints return camelCase
3. **✅ Better Developer Experience**: TypeScript interfaces match API exactly
4. **✅ Reduced Bugs**: No field name mismatches
5. **✅ Easier Maintenance**: Single source of truth for field naming

## Testing Checklist

- [ ] Subscription API returns camelCase fields
- [ ] Person API returns camelCase fields  
- [ ] Admin dashboard loads correctly
- [ ] Project subscription management works
- [ ] No console errors in frontend
- [ ] All TypeScript interfaces match API responses
- [ ] API documentation updated

---

**Implementation Timeline**: 3 weeks  
**Risk Level**: Low (gradual migration with rollback plan)  
**Dependencies**: Pydantic 2.0+ for alias_generator support