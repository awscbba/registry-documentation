# v2 API Endpoints Documentation

**Version**: 2.0  
**Base URL**: `https://2t9blvt2c1.execute-api.us-east-1.amazonaws.com/prod`  
**Last Updated**: August 1, 2025

## 🎯 Overview

The v2 API endpoints provide enhanced functionality, better error handling, and standardized response formats with metadata and versioning information.

## 📊 Response Format Standard

All v2 endpoints follow this consistent response format:

```json
{
  "success": true,
  "version": "v2",
  "timestamp": "2025-08-01T13:41:30.516910",
  "data": [...],
  "count": 3,
  "metadata": {
    "total_count": 3
  }
}
```

### Response Fields
- **success**: Boolean indicating operation success
- **version**: API version identifier ("v2")
- **timestamp**: ISO timestamp of the response
- **data**: The actual response data (array or object)
- **count**: Number of items in the current response
- **metadata**: Additional metadata (pagination, totals, etc.)

## 🔗 Available v2 Endpoints

### Projects

#### GET `/v2/projects`
Get all projects with enhanced metadata.

**Response Example**:
```json
{
  "success": true,
  "version": "v2",
  "timestamp": "2025-08-01T13:41:30.516910",
  "data": [
    {
      "id": "7097ef0d-e6d3-42ee-8092-f04371d1f46d",
      "name": "AWS Workshop Cochabamba 2025 - Updated",
      "description": "Taller práctico de AWS para desarrolladores en Cochabamba - Actualizado",
      "status": "active",
      "maxParticipants": 60,
      "startDate": "2025-07-15",
      "endDate": "2025-07-16",
      "createdBy": "admin",
      "createdAt": "2025-06-23T04:15:00.951912",
      "updatedAt": "2025-06-30T14:54:57.180835"
    }
  ],
  "count": 3,
  "metadata": {
    "total_count": 3
  }
}
```

**Features**:
- ✅ Enhanced metadata with timestamps
- ✅ Consistent response format
- ✅ Better error handling
- ✅ Version tracking

### Subscriptions

#### GET `/v2/subscriptions`
Get all subscriptions with enhanced details.

**Response Example**:
```json
{
  "success": true,
  "version": "v2",
  "timestamp": "2025-08-01T13:42:46.140758",
  "data": [
    {
      "id": "6dadbf94-6fd4-418d-8f03-0a9a7ddda784",
      "projectId": "cc195c15-8c51-4892-8ddb-a44b520934a3",
      "personId": "ee814990-1afb-4601-a809-4ea19c93543c",
      "status": "pending",
      "notes": "prueba",
      "createdAt": "2025-07-30T02:59:22.336807",
      "updatedAt": "2025-07-30T02:59:22.336807"
    }
  ],
  "count": 17,
  "metadata": {
    "total_count": 17
  }
}
```

**Features**:
- ✅ Complete subscription details
- ✅ Status tracking (active, pending, cancelled)
- ✅ Notes and metadata
- ✅ Audit timestamps

### Admin Endpoints

#### GET `/v2/admin/test`
Test endpoint to verify admin system functionality.

**Authentication**: Required (JWT Bearer token)

**Response Example**:
```json
{
  "message": "Admin system test successful",
  "admin_user": {
    "id": "70657ce8-78d4-4b4f-9394-48ce2b8649bc",
    "email": "admin@awsugcbba.org",
    "firstName": "Admin",
    "lastName": "User",
    "isAdmin": true
  },
  "version": "v2"
}
```

**Features**:
- ✅ Admin authentication verification
- ✅ User privilege validation
- ✅ System health check

## 🔄 Migration from v1 to v2

### Frontend Integration

#### Before (v1):
```javascript
// Old v1 approach
const response = await fetch(`${API_BASE_URL}/projects`);
const projects = await response.json(); // Direct array or {projects: [...]}
```

#### After (v2):
```javascript
// New v2 approach
const response = await fetch(`${API_BASE_URL}/v2/projects`);
const data = await response.json();
const projects = data.data; // Standardized format
```

### Response Handling

#### v2 Response Handler:
```javascript
function handleV2Response(data) {
  if (data && data.data && Array.isArray(data.data)) {
    return data.data; // v2 format
  } else if (Array.isArray(data)) {
    return data; // Legacy array format (backward compatibility)
  } else if (data && data.projects && Array.isArray(data.projects)) {
    return data.projects; // Legacy object format (backward compatibility)
  } else {
    console.error('Unexpected API response format:', data);
    return []; // Fallback
  }
}
```

## 🚀 Benefits of v2 API

### Enhanced Metadata
- **Timestamps**: Every response includes generation timestamp
- **Versioning**: Clear API version identification
- **Counts**: Item counts for pagination and UI feedback
- **Metadata**: Additional context and statistics

### Better Error Handling
- **Consistent Format**: All errors follow the same structure
- **Detailed Messages**: More informative error descriptions
- **Status Codes**: Proper HTTP status code usage
- **Logging**: Enhanced request/response logging

### Future-Proof Design
- **Extensible**: Easy to add new fields without breaking changes
- **Backward Compatible**: Legacy endpoints still supported
- **Scalable**: Designed for pagination and filtering
- **Maintainable**: Clear separation of concerns

## 🔐 Authentication

### JWT Token Usage
All admin endpoints require JWT authentication:

```javascript
const headers = {
  'Authorization': `Bearer ${accessToken}`,
  'Content-Type': 'application/json'
};
```

### Token Format
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "expires_in": 3600,
  "user": {
    "id": "70657ce8-78d4-4b4f-9394-48ce2b8649bc",
    "email": "admin@awsugcbba.org",
    "firstName": "Admin",
    "lastName": "User"
  }
}
```

## 📋 Planned v2 Endpoints

### Coming Soon
- `GET /v2/people` - Enhanced people management
- `GET /v2/admin/dashboard` - Admin dashboard data
- `GET /v2/admin/users` - User management
- `POST /v2/admin/projects` - Admin project creation
- `PUT /v2/admin/subscriptions/{id}` - Subscription management

### Future Enhancements
- Pagination support (`?page=1&limit=10`)
- Filtering capabilities (`?status=active&project=id`)
- Sorting options (`?sort=createdAt&order=desc`)
- Field selection (`?fields=id,name,status`)

## 🧪 Testing v2 Endpoints

### Example cURL Commands

#### Get Projects:
```bash
curl -X GET https://2t9blvt2c1.execute-api.us-east-1.amazonaws.com/prod/v2/projects
```

#### Get Subscriptions:
```bash
curl -X GET https://2t9blvt2c1.execute-api.us-east-1.amazonaws.com/prod/v2/subscriptions
```

#### Admin Test (with auth):
```bash
curl -X GET https://2t9blvt2c1.execute-api.us-east-1.amazonaws.com/prod/v2/admin/test \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 📚 Related Documentation

- [Authentication System Guide](./AUTHENTICATION_SYSTEM.md)
- [API Workflow Improvements](./API_WORKFLOW_IMPROVEMENTS.md)
- [Frontend-Backend Alignment Session](./FRONTEND_BACKEND_ALIGNMENT_SESSION.md)

---

**API Version**: v2.0  
**Status**: ✅ Active and Stable  
**Backward Compatibility**: ✅ Legacy v1 endpoints still supported