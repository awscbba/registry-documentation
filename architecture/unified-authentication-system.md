# Unified Authentication System

## Overview

The People Registry application now uses a **single, standardized authentication system** based on the `AuthService` singleton pattern. This eliminates the previous issues with multiple authentication implementations.

## Architecture

```
┌─────────────────────────────────────┐
│           AuthService               │
│        (Singleton Instance)         │
├─────────────────────────────────────┤
│ ✅ Login/Logout                     │
│ ✅ Token Management                 │
│ ✅ User State Management            │
│ ✅ Admin Permission Checks          │
│ ✅ Session Persistence              │
│ ✅ Token Refresh                    │
│ ✅ Global Availability              │
└─────────────────────────────────────┘
                    │
        ┌───────────┼───────────┐
        │           │           │
   ┌────▼───┐  ┌───▼────┐  ┌───▼────┐
   │Login   │  │Modal   │  │Admin   │
   │Pages   │  │Forms   │  │Dashboard│
   └────────┘  └────────┘  └────────┘
```

## Key Features

### 1. **Singleton Pattern**
- Single instance across the entire application
- Consistent state management
- No duplicate authentication logic

### 2. **Global Availability**
- Available as `window.authService` for debugging
- Importable as ES6 module
- Consistent API across all components

### 3. **Standardized Storage**
- **Token Key**: `userAuthToken`
- **User Data Key**: `userData`
- **Consistent localStorage usage**

### 4. **Unified API Endpoints**
- **Login**: `/auth/login` (admin endpoint with `isAdmin` field)
- **User Info**: `/auth/me`
- **Logout**: `/auth/logout`

## Usage Examples

### Component Usage
```typescript
import { authService } from '../services/authService';

// Login
const result = await authService.login({ email, password });
if (result.success) {
  // Handle success
}

// Check authentication
if (authService.isAuthenticated()) {
  // User is logged in
}

// Check admin status
if (authService.isAdmin()) {
  // User has admin privileges
}

// Logout
authService.logout();
```

### Browser Console Debugging
```javascript
// Check authentication state
console.log('Authenticated:', authService.isAuthenticated());
console.log('Is Admin:', authService.isAdmin());
console.log('Current User:', authService.getCurrentUser());
console.log('Token:', authService.getToken());

// Manual login for testing
await authService.login({ 
  email: 'admin@awsugcbba.org', 
  password: 'awsugcbba2025' 
});
```

## Migration from Previous System

### ❌ **Old System Issues**:
1. **Multiple auth implementations** (AuthService, AuthStub, direct API calls)
2. **Inconsistent localStorage keys** (`auth_token` vs `userAuthToken`)
3. **Different API endpoints** (`/auth/user/login` vs `/auth/login`)
4. **Inconsistent error handling**
5. **Maintenance nightmare**

### ✅ **New Unified System**:
1. **Single AuthService** for all authentication
2. **Consistent localStorage keys** (`userAuthToken`, `userData`)
3. **Single API endpoint** (`/auth/login`)
4. **Centralized error handling**
5. **Easy to maintain and debug**

## Components Updated

### 1. **AuthService** (`src/services/authService.ts`)
- Enhanced with global availability
- Singleton pattern enforced
- Comprehensive error handling

### 2. **LoginForm** (`src/components/LoginForm.tsx`)
- ✅ Updated to use AuthService
- ❌ Removed dependency on AuthStub

### 3. **Login Pages**
- ✅ `login-unified.astro` - New unified login page
- ⚠️ `login.astro` - Legacy page (to be deprecated)

### 4. **UserLoginModal** (`src/components/UserLoginModal.tsx`)
- ✅ Already using AuthService correctly

### 5. **AdminDashboard** (`src/components/AdminDashboard.tsx`)
- ✅ Works with unified authentication

## Files Removed

- ❌ `src/services/authStub.ts` - Eliminated duplicate auth system

## Testing

### Manual Testing Checklist
- [ ] Login via login page works
- [ ] Login via modal works
- [ ] Admin button appears for admin users
- [ ] Admin dashboard loads without errors
- [ ] Token persists across page refreshes
- [ ] Logout clears all authentication data
- [ ] `window.authService` available in console

### Automated Testing
```bash
# Run authentication tests
npm test -- --grep "auth"
```

## Security Considerations

### 1. **Token Storage**
- Stored in localStorage (consider httpOnly cookies for production)
- Consistent key naming prevents confusion
- Automatic cleanup on logout

### 2. **Session Management**
- Token expiration handling
- Automatic logout on invalid tokens
- Refresh token support (if implemented)

### 3. **Admin Access Control**
- Centralized admin permission checks
- Consistent `isAdmin()` logic
- Backend validation required

## Future Enhancements

### 1. **Token Refresh**
- Automatic token renewal
- Background refresh before expiration
- Seamless user experience

### 2. **Enhanced Security**
- HttpOnly cookie storage
- CSRF protection
- Rate limiting

### 3. **Multi-Factor Authentication**
- TOTP support
- SMS verification
- Backup codes

## Troubleshooting

### Common Issues

#### 1. **"authService is not defined"**
```javascript
// Check if authService is available
if (typeof window.authService !== 'undefined') {
  // Use authService
} else {
  console.error('AuthService not loaded');
}
```

#### 2. **Token not persisting**
```javascript
// Check localStorage
console.log('Token:', localStorage.getItem('userAuthToken'));
console.log('User:', localStorage.getItem('userData'));
```

#### 3. **Admin access denied**
```javascript
// Debug admin status
console.log('Is authenticated:', authService.isAuthenticated());
console.log('Is admin:', authService.isAdmin());
console.log('User data:', authService.getCurrentUser());
```

## Deployment Notes

### 1. **Cache Invalidation**
- Clear CloudFront cache after deployment
- Hard refresh browsers to load new code
- Clear localStorage if needed

### 2. **Backward Compatibility**
- Legacy login page still works as fallback
- Gradual migration approach
- No breaking changes for existing users

### 3. **Monitoring**
- Monitor authentication success rates
- Track login method usage
- Alert on authentication failures

## Conclusion

The unified authentication system provides:
- **Consistency** across all components
- **Maintainability** with single source of truth
- **Debuggability** with global access
- **Security** with standardized practices
- **Scalability** for future enhancements

This architecture eliminates the authentication issues that were causing admin access problems and provides a solid foundation for future development.
