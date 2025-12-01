# Release v1.4.0 - Authentication & Subscription Fixes

**Release Date**: December 1, 2025  
**Release Type**: Minor Version (Feature + Bug Fixes)

## 📦 Tagged Repositories

- **registry-api**: v1.4.0
- **registry-frontend**: v1.4.0
- **registry-infrastructure**: v1.4.0

## 🎯 Overview

This release focuses on authentication improvements and subscription workflow enhancements. Key highlights include support for initial password setup, improved subscription cards, and comprehensive CORS fixes.

---

## ✨ New Features

### 1. Initial Password Setup Support
**Component**: Backend (registry-api)  
**Impact**: High

Users can now set passwords even if their accounts don't have one (e.g., admin-created accounts, migrated accounts).

**Technical Details**:
- Modified `/auth/password/change` endpoint to detect accounts without passwords
- Skip current password verification for initial password setup
- Log security events for audit trail
- Maintains security by still requiring authentication token

**Files Changed**:
- `src/routers/auth_router.py`

### 2. Enhanced Subscription Cards
**Component**: Backend (registry-api)  
**Impact**: Medium

Subscription cards now properly display project names instead of just IDs.

**Technical Details**:
- Improved project name resolution in subscription service
- Better data enrichment for subscription responses
- Clean Architecture refactoring for maintainability

**Files Changed**:
- `src/services/subscriptions_service.py`
- `src/routers/subscriptions_router.py`
- `src/models/subscription.py`

---

## 🐛 Bug Fixes

### 1. Password Change Validation Context
**Component**: Backend (registry-api)  
**Severity**: High  
**Issue**: Password change requests were being validated with strict SQL injection patterns

**Root Cause**:
The `/auth/password/change` endpoint wasn't mapped to the `AUTHENTICATION` validation context, defaulting to `CONTENT_DATA` context which uses strict patterns that flag passwords with special characters.

**Solution**:
- Added `/auth/password/change` to `AUTHENTICATION` validation context
- Excludes password fields from strict pattern validation
- Allows passwords with special characters like `'`, `"`, `-`, `=`

**Files Changed**:
- `src/security/enterprise_input_validator.py`

### 2. CORS Headers on Error Responses
**Component**: Backend (registry-api)  
**Severity**: Medium  
**Issue**: Error responses missing CORS headers causing frontend failures

**Solution**:
- Added CORS headers to all error responses in error handler
- Ensures consistent CORS handling across all response types
- Prevents browser CORS errors on authentication failures

**Files Changed**:
- `src/exceptions/error_handler.py`
- `src/middleware/authentication_middleware.py`

### 3. Password Change Success Message
**Component**: Frontend (registry-frontend)  
**Severity**: Low  
**Issue**: Success message not displaying after password change

**Root Cause**:
Frontend was looking for `data.message` but API returns nested structure: `{ success, data: { message } }`

**Solution**:
- Updated response parsing to handle nested message structure
- Check both `data.data.message` and `data.message`
- Ensures success notification displays to user

**Files Changed**:
- `src/services/authService.ts`

---

## 🏗️ Technical Improvements

### Clean Architecture Refactoring
**Component**: Backend (registry-api)

- Improved subscription service following Clean Architecture patterns
- Better separation of concerns
- Enhanced testability and maintainability
- Consistent error handling patterns

### Enterprise Exception Handling
**Component**: Backend (registry-api)

- Consistent use of enterprise exception types
- Structured logging with correlation IDs
- User-safe error messages
- Comprehensive error context

---

## 📊 Testing

### Test Results
- **Total Tests**: 241 passing
- **Critical Tests**: 21 passing
- **Coverage**: All modified code paths tested

### Test Categories
- Authentication flow tests
- Subscription service tests
- Input validation tests
- CORS handling tests

---

## 🚀 Deployment

### Deployment Order
1. **registry-infrastructure** (if needed)
2. **registry-api** (automatic via pipeline)
3. **registry-frontend** (automatic via Amplify)

### Deployment Status
- ✅ All branches merged to main
- ✅ Tags created and pushed
- ✅ Pipelines triggered
- ⏳ Awaiting deployment completion

### Rollback Plan
If issues arise:
```bash
# Revert to v1.3.0
git checkout v1.3.0
git push origin main --force  # (requires approval)
```

---

## 📝 Migration Notes

### For Users
- **No action required** for existing users
- Users without passwords can now set one via "Change Password"
- Improved password change experience

### For Developers
- Review new validation context patterns
- Follow enterprise exception handling patterns
- Use structured logging for all operations

---

## 🔒 Security Considerations

### Password Handling
- Initial password setup still requires authentication token
- All password operations logged for audit
- Password validation rules unchanged
- Special characters now properly supported

### Validation Context
- Authentication endpoints use lenient validation
- Password fields excluded from SQL injection patterns
- Maintains security while improving UX

---

## 📚 Documentation Updates

### Updated Documents
- AI Assistant Guidelines (validation patterns)
- Coding Conventions (exception handling)
- System Map (subscription service architecture)

### New Documents
- This release notes document

---

## 🎯 Known Issues

None identified in this release.

---

## 🔮 Future Improvements

### Planned for v1.5.0
- Enhanced subscription filtering
- Bulk subscription management
- Advanced user profile features
- Performance optimizations

---

## 👥 Contributors

- Sergio Rodriguez (AI-assisted development)
- Kiro AI Assistant

---

## 📞 Support

For issues or questions:
- GitHub Issues: [registry-api](https://github.com/awscbba/registry-api/issues)
- Email: support@cbba.cloud.org.bo

---

## 🔗 Related Links

- [v1.3.0 Release Notes](./release-v1.3.0.md)
- [API Documentation](../api/API_DOCUMENTATION.md)
- [System Architecture](../architecture/SYSTEM_MAP_FOR_AI_ASSISTANT.md)

---

**Release Approved By**: Sergio Rodriguez  
**Release Date**: December 1, 2025  
**Next Release**: v1.5.0 (TBD)
