# Frontend API Route Mapping

## ✅ Standardized Admin Endpoints

All admin endpoints use the `/v2/admin` prefix for consistency.

### **Dashboard & Analytics**
```
GET /v2/admin/dashboard          # Main dashboard data
GET /v2/admin/analytics          # Analytics data  
GET /v2/admin/stats              # Comprehensive statistics
```

### **Performance Monitoring**
```
GET /v2/admin/performance/health # System health status
GET /v2/admin/performance/stats  # Performance statistics
GET /v2/admin/performance/cache/stats # Cache performance
```

### **Database Performance**
```
GET /v2/admin/database/performance/metrics # Database metrics
GET /v2/admin/database/performance/optimization-history?range=24h # Optimization history
```

## 🔧 Frontend URL Fixes Required

### **Current Issues**
```javascript
// ❌ Wrong URLs (causing 404 errors)
'/admin/database/performance/metrics'
'/admin/database/performance/optimization-history'

// ✅ Correct URLs  
'/v2/admin/database/performance/metrics'
'/v2/admin/database/performance/optimization-history'
```

### **Project Creation Fix**
```javascript
// ❌ Missing trailing slash (causing 405 error)
'POST /v2/projects'

// ✅ Correct URL
'POST /v2/projects/'
```

## 📊 All Available Admin Endpoints

| Endpoint | Method | Purpose | Status |
|----------|--------|---------|---------|
| `/v2/admin/dashboard` | GET | Main dashboard | ✅ |
| `/v2/admin/analytics` | GET | Analytics data | ✅ |
| `/v2/admin/stats` | GET | Statistics | ✅ |
| `/v2/admin/performance/health` | GET | System health | ✅ |
| `/v2/admin/performance/stats` | GET | Performance stats | ✅ |
| `/v2/admin/performance/cache/stats` | GET | Cache stats | ✅ |
| `/v2/admin/database/performance/metrics` | GET | DB metrics | ✅ |
| `/v2/admin/database/performance/optimization-history` | GET | DB optimization | ✅ |

## 🔐 Authentication

All admin endpoints require:
- `Authorization: Bearer <token>` header
- User must have `isAdmin: true`
- Valid JWT token (24-hour expiration)

## 📝 Response Format

All endpoints return standardized responses:
```json
{
  "success": true,
  "data": { ... },
  "version": "v2"
}
```

## 🚀 Next Steps

1. Update frontend URLs to match standardized routes
2. Add trailing slash to project creation endpoint
3. Test all admin functionality
4. Verify authentication headers are sent correctly
