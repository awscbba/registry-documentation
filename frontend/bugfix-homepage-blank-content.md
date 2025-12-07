# Bug Fix: Homepage Blank Content Issue

**Date**: 2025-12-06  
**Severity**: Critical  
**Status**: Fixed  
**Related Spec**: Frontend Architecture Refactor (Task 2.2)

## Problem Description

After the frontend architecture refactor, the homepage was displaying only the header with blank content below. The ProjectShowcase component was not rendering any projects for unauthenticated users.

### Symptoms

- Homepage showed only header, no project cards
- Console showed no React component errors
- Browser console showed:
  - `favicon.svg 500 error` (separate issue, also fixed)
  - `Unchecked runtime.lastError: Could not establish connection` (browser extension noise)
- Debug logs showed component was mounting but no projects were being loaded

## Root Cause

The `useProjects` hook was calling `projectApi.getAllProjects()` which requires authentication (`addRequiredAuthHeaders()`). Since visitors to the homepage are typically not logged in, the API call was failing silently or returning an empty array.

### Code Issue

**File**: `registry-frontend/src/hooks/useProjects.ts`

**Before** (incorrect):
```typescript
const allProjects = await projectApi.getAllProjects();
```

**After** (correct):
```typescript
// Use public projects endpoint for unauthenticated users
const allProjects = await projectApi.getPublicProjects();
```

## Solution

Changed the `useProjects` hook to use `projectApi.getPublicProjects()` instead of `getAllProjects()`. The public endpoint doesn't require authentication and is designed for displaying projects on the homepage.

### Why This Happened

During the refactor, when extracting the data fetching logic into the `useProjects` hook, the wrong API method was selected. The original component likely had different logic or the authentication requirement wasn't properly considered.

## Files Modified

- `registry-frontend/src/hooks/useProjects.ts` - Changed API call from `getAllProjects()` to `getPublicProjects()`

## Testing

1. **Build Test**: ✅ Passed
   ```bash
   npm run build
   # Exit Code: 0
   ```

2. **Manual Test Required**:
   - Deploy to Amplify
   - Visit homepage without logging in
   - Verify projects are displayed
   - Verify no console errors

## Related Issues

- **Favicon 500 Error**: Also fixed by creating `registry-frontend/public/favicon.svg`
- **Architecture Refactor**: Part of the larger frontend refactor initiative

## Prevention

To prevent similar issues in the future:

1. **Always consider authentication requirements** when choosing API endpoints
2. **Test with unauthenticated users** during development
3. **Add integration tests** that verify public pages work without authentication
4. **Document which endpoints require authentication** in API service files

## API Endpoint Reference

### Public Endpoints (No Auth Required)
- `projectApi.getPublicProjects()` - Get all projects for public display
- `projectApi.createSubscription()` - Public subscription endpoint

### Authenticated Endpoints (Auth Required)
- `projectApi.getAllProjects()` - Admin access to all projects
- `projectApi.createProject()` - Admin project creation
- `projectApi.updateProject()` - Admin project updates
- `projectApi.deleteProject()` - Admin project deletion

## Lessons Learned

1. **Public vs. Authenticated Endpoints**: Always verify which endpoint is appropriate for the use case
2. **Silent Failures**: API calls that fail silently can be hard to debug - consider adding better error logging
3. **Testing Coverage**: Need integration tests that verify public pages work without authentication
4. **Debug Logging**: The debug logs added during refactor were helpful in diagnosing this issue

## Next Steps

1. ✅ Fix implemented
2. ✅ Build verified
3. ⏳ Deploy to Amplify
4. ⏳ Manual testing on deployed site
5. ⏳ Add integration test for unauthenticated homepage access (Task 5.5)

---

**Fixed By**: Kiro AI Assistant  
**Reported By**: User (sergio.rodriguez)  
**Branch**: feature-user-registration-page (pending deployment)
