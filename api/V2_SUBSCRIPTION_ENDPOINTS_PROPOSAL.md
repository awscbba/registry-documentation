# V2 Subscription Management Endpoints Proposal

## Overview
Replace the legacy v1 project subscription endpoints with modern v2 equivalents that follow current API patterns.

## Current Legacy Endpoints (Dead Code)
- `GET /projects/{projectId}/subscribers` - Get subscribers for a project
- `POST /projects/{projectId}/subscribe/{personId}` - Subscribe person to project  
- `DELETE /projects/{projectId}/unsubscribe/{personId}` - Unsubscribe person from project

## Proposed V2 Endpoints

### 1. Get Project Subscribers
```
GET /v2/projects/{projectId}/subscribers
```

**Response Format:**
```json
{
  "success": true,
  "data": [
    {
      "id": "subscription-uuid",
      "personId": "person-uuid",
      "projectId": "project-uuid",
      "status": "active",
      "subscribedAt": "2025-08-03T10:00:00Z",
      "subscribedBy": "admin-uuid",
      "notes": "Registered via admin panel",
      "person": {
        "id": "person-uuid",
        "firstName": "John",
        "lastName": "Doe",
        "email": "john@example.com"
      }
    }
  ],
  "metadata": {
    "totalCount": 25,
    "activeCount": 20,
    "pendingCount": 5
  },
  "version": "v2"
}
```

### 2. Subscribe Person to Project
```
POST /v2/projects/{projectId}/subscribers
```

**Request Body:**
```json
{
  "personId": "person-uuid",
  "subscribedBy": "admin-uuid",
  "notes": "Optional notes",
  "status": "active"  // or "pending"
}
```

**Response Format:**
```json
{
  "success": true,
  "data": {
    "id": "subscription-uuid",
    "personId": "person-uuid",
    "projectId": "project-uuid",
    "status": "active",
    "subscribedAt": "2025-08-03T10:00:00Z",
    "subscribedBy": "admin-uuid",
    "notes": "Optional notes"
  },
  "version": "v2"
}
```

### 3. Update Subscription
```
PUT /v2/projects/{projectId}/subscribers/{subscriptionId}
```

**Request Body:**
```json
{
  "status": "inactive",
  "notes": "Updated notes"
}
```

### 4. Remove Subscription
```
DELETE /v2/projects/{projectId}/subscribers/{subscriptionId}
```

**Response:**
```json
{
  "success": true,
  "message": "Subscription removed successfully",
  "version": "v2"
}
```

## Key Differences from V1 (Legacy)

### 1. **Resource-Based URLs**
- **V1**: `/projects/{projectId}/subscribe/{personId}` (action-based)
- **V2**: `/projects/{projectId}/subscribers` (resource-based)

### 2. **Consistent Response Format**
- **V1**: Inconsistent response formats
- **V2**: Standardized `{success, data, version}` format

### 3. **Better Error Handling**
- **V1**: Generic error messages
- **V2**: Detailed error responses with proper HTTP status codes

### 4. **Enhanced Data**
- **V1**: Minimal subscription data
- **V2**: Includes person details, metadata, timestamps, audit info

### 5. **Proper HTTP Methods**
- **V1**: Mixed conventions
- **V2**: RESTful conventions (POST to create, PUT to update, DELETE to remove)

### 6. **Admin Context**
- **V1**: No audit trail
- **V2**: Tracks who performed the action (`subscribedBy`)

### 7. **Status Management**
- **V1**: Simple subscribe/unsubscribe
- **V2**: Status-based (active, pending, inactive) for better workflow

### 8. **Metadata**
- **V1**: No aggregate information
- **V2**: Includes counts and statistics

## Implementation Benefits

1. **Consistency**: Matches existing v2 API patterns
2. **Auditability**: Full audit trail of subscription changes
3. **Flexibility**: Status-based system allows for approval workflows
4. **Performance**: Optimized queries with metadata
5. **Maintainability**: Clean, RESTful design
6. **Future-Proof**: Extensible for additional features

## Migration Strategy

1. **Phase 1**: Implement v2 endpoints alongside existing (non-functional) v1 references
2. **Phase 2**: Update frontend to use v2 endpoints
3. **Phase 3**: Remove dead v1 code from frontend
4. **Phase 4**: Add deprecation warnings to any remaining v1 usage

## Frontend Changes Required

```typescript
// Replace dead code methods with:
async getProjectSubscribers(projectId: string): Promise<ProjectSubscriber[]> {
  const response = await fetch(getApiUrl(`/v2/projects/${projectId}/subscribers`), {
    headers: addAuthHeaders()
  });
  const data = await handleApiResponse(response);
  return data.data; // Extract from v2 response format
}

async subscribePersonToProject(projectId: string, personId: string, data: SubscribeRequest): Promise<Subscription> {
  const response = await fetch(getApiUrl(`/v2/projects/${projectId}/subscribers`), {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...addAuthHeaders()
    },
    body: JSON.stringify({ personId, ...data })
  });
  const result = await handleApiResponse(response);
  return result.data;
}

async unsubscribePersonFromProject(projectId: string, subscriptionId: string): Promise<void> {
  const response = await fetch(getApiUrl(`/v2/projects/${projectId}/subscribers/${subscriptionId}`), {
    method: 'DELETE',
    headers: addAuthHeaders()
  });
  await handleApiResponse(response);
}
```