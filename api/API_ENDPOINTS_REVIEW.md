# API Endpoints Review - Current State Analysis

**Date:** July 27, 2025  
**Current Handler:** `enhanced_api_handler.lambda_handler`  
**Issue:** Missing POST /people endpoint causing subscription form failures

## 🔍 Current Endpoint Analysis

### ✅ Working Endpoints (enhanced_api_handler.py)

#### Projects
- `GET /projects` - ✅ Returns `{projects: [...], count: N}` format
- `POST /projects` - ✅ Creates project, returns project data + message
- `PUT /projects/{id}` - ✅ Updates project
- `DELETE /projects/{id}` - ❓ Not verified

#### People (Limited)
- `GET /people` - ⚠️ **SECURITY ISSUE**: Returns raw DynamoDB data with sensitive fields:
  - `passwordHash`
  - `passwordSalt`
  - `passwordHistory`
  - `requirePasswordChange`
  - `lastLoginAt`
  - `failedLoginAttempts`

#### Subscriptions
- `GET /subscriptions` - ✅ Available
- `POST /subscriptions` - ✅ Available with CSRF protection
- `PUT /subscriptions/{id}` - ✅ Available
- `DELETE /subscriptions/{id}` - ✅ Available
- `GET /people/{id}/subscriptions` - ✅ Available
- `GET /projects/{id}/subscriptions` - ✅ Available

#### Authentication & Security
- `POST /auth/validate-password` - ✅ Available with rate limiting
- `POST /auth/password/validate` - ✅ Available
- `POST /auth/password/check-history` - ✅ Available
- `POST /auth/refresh-token` - ✅ Available (if enhanced service available)
- `POST /auth/logout` - ✅ Available (if enhanced service available)
- `POST /auth/logout-all` - ✅ Available (if enhanced service available)
- `POST /auth/cleanup-sessions` - ✅ Available (if enhanced service available)
- `POST /auth/password-reset` - ✅ Available with rate limiting
- `PUT /auth/password` - ✅ Available with rate limiting

#### Admin Functions
- `POST /admin/password/force-change` - ✅ Available
- `POST /admin/password/generate-temporary` - ✅ Available

### ❌ Missing Critical Endpoints

#### People Management (CRITICAL)
- `POST /people` - **MISSING** - This is causing subscription form failures
- `GET /people/{id}` - **MISSING**
- `PUT /people/{id}` - **MISSING**
- `DELETE /people/{id}` - **MISSING**

### 📋 Available in api_handler.py (Not Deployed)

The `api_handler.py` file contains complete people management endpoints:
- `POST /people` - ✅ Returns created person object with 201 status
- `GET /people/{id}` - ✅ Available
- `PUT /people/{id}` - ✅ Available
- `DELETE /people/{id}` - ✅ Available

## 🚨 Critical Issues Identified

### 1. **Missing POST /people Endpoint**
- **Impact**: Subscription forms fail with "API did not return created person data"
- **Root Cause**: `enhanced_api_handler.py` doesn't have person creation endpoint
- **Frontend Error**: `peopleApi.createPerson()` calls fail

### 2. **Data Leakage in GET /people**
- **Impact**: Sensitive password data exposed to frontend
- **Security Risk**: HIGH
- **Fields Exposed**: `passwordHash`, `passwordSalt`, `passwordHistory`, etc.

### 3. **Handler Mismatch**
- **Issue**: Deployment uses `enhanced_api_handler.py` but complete people endpoints are in `api_handler.py`
- **Impact**: Feature incompleteness

## 🛠️ Required Fixes

### Priority 1: Add Missing People Endpoints
Add to `enhanced_api_handler.py`:
```python
# POST /people - Create person
if path == '/people' and http_method == 'POST':
    # Implementation needed

# GET /people/{id} - Get specific person  
if path.startswith('/people/') and not path.endswith('/subscriptions') and http_method == 'GET':
    # Implementation needed

# PUT /people/{id} - Update person
if path.startswith('/people/') and http_method == 'PUT':
    # Implementation needed

# DELETE /people/{id} - Delete person
if path.startswith('/people/') and http_method == 'DELETE':
    # Implementation needed
```

### Priority 2: Fix Data Leakage
Update GET `/people` endpoint to filter sensitive fields:
```python
# Filter sensitive fields before returning
safe_people = []
for person in people:
    safe_person = {
        'id': person.get('id'),
        'firstName': person.get('firstName'),
        'lastName': person.get('lastName'),
        'email': person.get('email'),
        'phone': person.get('phone'),
        'dateOfBirth': person.get('dateOfBirth'),
        'address': person.get('address'),
        'createdAt': person.get('createdAt'),
        'updatedAt': person.get('updatedAt'),
        'isActive': person.get('isActive', True)
    }
    safe_people.append(safe_person)
```

## 📊 Implementation Plan

### Step 1: Copy People Endpoints
Copy the working people endpoint implementations from `api_handler.py` to `enhanced_api_handler.py`

### Step 2: Add Security Filtering
Implement proper response filtering to exclude sensitive fields

### Step 3: Test Subscription Flow
1. Test person creation via POST /people
2. Test subscription creation with created person ID
3. Verify no sensitive data in responses

### Step 4: Deploy and Validate
1. Deploy updated handler
2. Test subscription form end-to-end
3. Verify security fixes

## 🎯 Success Criteria

- ✅ POST /people endpoint returns created person object
- ✅ Subscription forms work end-to-end
- ✅ No sensitive data in API responses
- ✅ All CRUD operations for people work
- ✅ Existing functionality remains intact

## 📝 Next Actions

1. **Immediate**: Add POST /people endpoint to fix subscription forms
2. **Security**: Filter sensitive data from GET /people response
3. **Complete**: Add remaining people CRUD endpoints
4. **Test**: Comprehensive endpoint testing
5. **Deploy**: Update production with fixes

---

**Current Status**: Ready to implement fixes in `enhanced_api_handler.py`