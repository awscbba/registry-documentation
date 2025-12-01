# Subscription Workflow Documentation

## Overview

This document describes the complete subscription workflow for the People Registry application, including all user states, business rules, and technical implementation details.

**Last Updated:** November 30, 2025  
**Version:** 2.0

---

## Table of Contents

1. [User States & UI Behavior](#user-states--ui-behavior)
2. [Backend Business Rules](#backend-business-rules)
3. [API Endpoints](#api-endpoints)
4. [Frontend State Management](#frontend-state-management)
5. [Field Mappings](#field-mappings)
6. [Error Handling](#error-handling)
7. [Visual Design](#visual-design)
8. [Edge Cases](#edge-cases)
9. [Known Issues](#known-issues)

---

## User States & UI Behavior

### 1. Not Logged In (Anonymous User)

**UI Display:**
- Full subscription form with fields: First Name, Last Name, Email, Notes
- "¿Ya tienes una cuenta? Inicia sesión aquí" link
- "Enviar Solicitud de Suscripción" button

**User Action:**
- User fills out form and submits

**Backend Processing:**
- Creates new person record if email doesn't exist
- Creates subscription with status: `pending`
- Sends welcome email with credentials (if person was created)

**Outcome:**
- Subscription pending admin approval
- User receives email notification

---

### 2. Logged In - Not Subscribed

**UI Display:**
- Blue box with 📝 icon
- Message: "Suscríbete a este proyecto"
- Single button: "Suscribirse al Proyecto"
- "Ver Mi Panel" button

**Hidden Elements:**
- Form fields (name, email, etc.)
- Login link

**User Action:**
- User clicks "Suscribirse al Proyecto"

**Backend Processing:**
- Creates subscription with authenticated user's `personId`
- Applies auto-approval logic:
  - Super admins → status: `active`
  - Regular users → status: `pending`

**Outcome:**
- Super admins: Immediately subscribed (active)
- Regular users: Pending admin approval

---

### 3. Logged In - Subscription Pending

**UI Display:**
- Yellow box with ⏳ icon
- Message: "Tu solicitud está pendiente de aprobación"
- Details:
  - "Solicitud enviada el [date]"
  - Status badge: "Pendiente de Aprobación" (yellow)
  - Helper text: "Un administrador revisará tu solicitud pronto. Te notificaremos por email cuando sea aprobada."

**Hidden Elements:**
- Subscribe button
- Form fields
- Login link

**User Action:**
- None available (waiting for admin approval)
- Can view "Mi Panel" to see all subscriptions

**Admin Action Required:**
- Admin must approve subscription in admin panel

---

### 4. Logged In - Subscription Active

**UI Display:**
- Green box with ✅ icon
- Message: "Ya estás suscrito a este proyecto"
- Details:
  - "Te suscribiste el [date]"
  - Status badge: "Activo" (green)

**Hidden Elements:**
- Subscribe button
- Form fields
- Login link

**User Action:**
- Can view "Mi Panel" to manage subscriptions
- Can access project resources (if applicable)

---

### 5. Logged In - Subscription Cancelled

**UI Display:**
- Gray box with ❌ icon
- Message: "Tu suscripción fue cancelada"
- Details:
  - Date information
  - Status badge: "Cancelado" (gray)

**Hidden Elements:**
- Subscribe button
- Form fields
- Login link

**User Action:**
- Currently no action available
- Future: Could implement re-subscription flow

---

## Backend Business Rules

### Auto-Approval Logic

```python
# In src/routers/projects_router.py

if person.roles and ('super_admin' in person.roles or 'SUPER_ADMIN' in person.roles):
    subscription_data["status"] = "active"  # Auto-approve
else:
    subscription_data["status"] = "pending"  # Requires admin approval
```

**Business Rationale:**
- Super admins are trusted users who don't need approval
- Regular users require vetting to prevent spam/abuse
- Maintains data quality and security

### Subscription Validation

**Duplicate Prevention:**
- System checks if subscription already exists for person + project combination
- Returns error if duplicate found
- Frontend handles by showing existing subscription status

**Required Fields:**
- `personId`: UUID of the person subscribing
- `projectId`: UUID of the project
- `status`: "pending" or "active"

**Optional Fields:**
- `notes`: Additional information from user

---

## API Endpoints

### Create Subscription (Authenticated Users)

```http
POST /v2/projects/{projectId}/subscriptions
Authorization: Bearer {token}
Content-Type: application/json

{
  "personId": "uuid",
  "projectId": "uuid",
  "status": "pending",
  "notes": "optional notes"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "subscription-uuid",
    "personId": "person-uuid",
    "projectId": "project-uuid",
    "status": "active",
    "subscriptionDate": "2025-11-30T19:02:30.775362",
    "isActive": true,
    "createdAt": "2025-11-30T19:02:30.775362",
    "updatedAt": "2025-11-30T19:02:30.775362"
  },
  "version": "v2"
}
```

### Get User Subscriptions (Working Endpoint)

```http
GET /v2/subscriptions/person/{personId}
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "subscription-uuid",
      "personId": "person-uuid",
      "projectId": "project-uuid",
      "status": "active",
      "subscriptionDate": "2025-11-30T19:02:30.775362",
      "isActive": true,
      "createdAt": "2025-11-30T19:02:30.775362",
      "updatedAt": "2025-11-30T19:02:30.775362"
    }
  ],
  "version": "v2"
}
```

### Get User Subscriptions (Auth Endpoint - Has Bug)

```http
GET /auth/subscriptions
Authorization: Bearer {token}
```

**Status:** ❌ Known bug - returns empty array  
**Workaround:** Use `/v2/subscriptions/person/{personId}` instead

### Get Project Subscriptions

```http
GET /v2/projects/{projectId}/subscriptions
Authorization: Bearer {token}
```

**Response:** Returns all subscriptions for a project with person details

---

## Frontend State Management

### Component: EnhancedProjectShowcase

**Location:** `registry-frontend/src/components/EnhancedProjectShowcase.tsx`

### State Variables

```typescript
const [isLoggedIn, setIsLoggedIn] = useState(false);
const [existingSubscription, setExistingSubscription] = useState<any>(null);
const [checkingSubscription, setCheckingSubscription] = useState(false);
const [isSubmitting, setIsSubmitting] = useState(false);
```

### Subscription Check Flow

```
1. Component mounts
   ↓
2. Check if user is authenticated (authService.isAuthenticated())
   ↓
3. If authenticated → checkSubscriptionStatus()
   ↓
4. Call authService.checkProjectSubscription(projectId)
   ↓
5. Service calls GET /v2/subscriptions/person/{userId}
   ↓
6. Find subscription matching current projectId
   ↓
7. Update existingSubscription state
   ↓
8. UI renders appropriate view based on status
```

### Subscription Creation Flow

```
1. User clicks "Suscribirse al Proyecto"
   ↓
2. Call authService.subscribeToProject(projectId, notes)
   ↓
3. POST /v2/projects/{projectId}/subscriptions
   ↓
4. Backend creates subscription
   ↓
5. Backend applies auto-approval logic
   ↓
6. Wait 500ms for processing
   ↓
7. Refresh subscription status
   ↓
8. Show success message
   ↓
9. UI updates to show new status
```

### Real-Time Authentication Detection

The component monitors authentication state changes:

```typescript
// Check every 2 seconds
setInterval(checkUserLoginStatus, 2000);

// Check when window gains focus
window.addEventListener('focus', checkUserLoginStatus);

// Check when localStorage changes (login in another tab)
window.addEventListener('storage', handleStorageChange);
```

---

## Field Mappings

The API returns data in camelCase format. The frontend transforms certain fields for consistency:

```typescript
// In src/utils/fieldMapping.ts

const SUBSCRIPTION_FIELD_MAP = {
  'subscriptionDate': 'subscribedAt',  // For display
  'person_id': 'personId',
  'project_id': 'projectId',
  'project_name': 'projectName',
  'is_active': 'isActive',
  'created_at': 'createdAt',
  'updated_at': 'updatedAt'
};
```

**Why:** Maintains consistency across the frontend and matches TypeScript interfaces.

---

## Error Handling

### Duplicate Subscription

**Error Message:** "Subscription already exists"

**Frontend Handling:**
```typescript
if (errorMessage.includes('already subscribed') || errorMessage.includes('ya existe')) {
  await checkSubscriptionStatus();
  window.alert('Ya tienes una suscripción a este proyecto.');
}
```

**User Experience:** Shows existing subscription status instead of error

### User Already Has Account

**Error Message:** "account exists"

**Frontend Handling:**
```typescript
if (errorMessage.includes('account exists') || errorMessage.includes('cuenta existe')) {
  setLoginMessage('Ya tienes una cuenta registrada con este email. Inicia sesión para suscribirte al proyecto.');
  setShowLoginModal(true);
}
```

**User Experience:** Prompts user to log in instead

### Network/Server Errors

**Frontend Handling:**
```typescript
catch (error) {
  logger.error('Subscription error:', error);
  window.alert('Error al procesar la suscripción. Por favor intenta nuevamente.');
}
```

**User Experience:** Generic error message with retry option

---

## Visual Design

### Status Colors & Icons

| Status | Icon | Text Color | Background | Border |
|--------|------|------------|------------|--------|
| Active | ✅ | `text-green-800` | `bg-green-50` | `border-green-200` |
| Pending | ⏳ | `text-yellow-800` | `bg-yellow-50` | `border-yellow-200` |
| Cancelled | ❌ | `text-gray-800` | `bg-gray-50` | `border-gray-200` |
| Not Subscribed | 📝 | `text-blue-800` | `bg-blue-50` | `border-blue-200` |

### Status Badge Styles

```css
.status-badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  text-transform: uppercase;
}

.status-badge.status-active {
  background: rgba(34, 197, 94, 0.2);
  color: #15803d;
}

.status-badge.status-pending {
  background: rgba(234, 179, 8, 0.2);
  color: #a16207;
}
```

---

## Edge Cases

### ✅ Handled Edge Cases

1. **User logs in from subscription page**
   - Auto-checks subscription status after login
   - Seamlessly transitions to appropriate view

2. **User subscribes successfully**
   - Waits 500ms for backend processing
   - Immediately refreshes to show new status
   - No page reload required

3. **Super admin subscribes**
   - Auto-approved (status: active)
   - Skips pending state entirely
   - Immediate access

4. **User already subscribed tries to subscribe again**
   - API returns error
   - Frontend catches error
   - Shows existing subscription status

5. **Authentication state changes in another tab**
   - Detects via localStorage storage events
   - Updates UI automatically
   - No manual refresh needed

6. **Page regains focus**
   - Re-checks authentication status
   - Ensures UI is up-to-date
   - Handles session expiry

7. **Periodic authentication check**
   - Checks every 2 seconds
   - Catches token expiration
   - Updates UI proactively

### ⚠️ Unhandled Edge Cases

1. **Subscription approved while user is viewing page**
   - No real-time notification
   - User must refresh page to see status change
   - Future: Implement websockets or polling

2. **Cancelled subscription reactivation**
   - No UI flow to resubscribe
   - User would need admin intervention
   - Future: Add "Request Reactivation" button

3. **Network interruption during subscription**
   - Generic error shown
   - Unclear if subscription was created
   - Future: Add retry logic with idempotency

---

## Known Issues

### 1. `/auth/subscriptions` Endpoint Returns Empty Array

**Status:** 🐛 Bug in backend  
**Affected Endpoint:** `GET /auth/subscriptions`  
**Symptom:** Always returns `{success: true, data: {subscriptions: [], count: 0}}`

**Root Cause:** 
The endpoint was trying to use `.get("personId")` on Pydantic model objects instead of using the proper service method.

**Workaround:**
Frontend now uses `/v2/subscriptions/person/{userId}` which works correctly.

**Fix Status:** 
Backend fix implemented but needs testing and deployment.

**Code Location:**
- Backend: `registry-api/src/routers/auth_router.py` (line 348)
- Frontend workaround: `registry-frontend/src/services/authService.ts` (line 540)

### 2. Cancelled Subscriptions Cannot Be Reactivated

**Status:** ⚠️ Feature not implemented  
**Impact:** Users with cancelled subscriptions have no way to resubscribe

**Workaround:** 
Admin must manually change status in database or user must contact support.

**Future Enhancement:**
Add "Request Reactivation" button for cancelled subscriptions.

### 3. No Real-Time Approval Notifications

**Status:** ⚠️ Feature not implemented  
**Impact:** Users don't know when their subscription is approved without refreshing

**Workaround:**
Email notification sent when approved (user must check email).

**Future Enhancement:**
- Implement websockets for real-time updates
- Or add polling mechanism to check status periodically
- Or add browser push notifications

---

## Testing Checklist

### Manual Testing Scenarios

- [ ] Anonymous user can submit subscription form
- [ ] Logged-in user sees subscribe button (no form)
- [ ] Super admin subscription is auto-approved
- [ ] Regular user subscription is pending
- [ ] Pending subscription shows correct status
- [ ] Active subscription shows correct status
- [ ] Duplicate subscription attempt shows existing subscription
- [ ] Login from subscription page works correctly
- [ ] Subscription date displays correctly
- [ ] Status badge shows correct color
- [ ] Login link hidden when authenticated
- [ ] Form fields hidden when authenticated

### API Testing

```bash
# Test subscription creation
curl -X POST https://api.example.com/v2/projects/{projectId}/subscriptions \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"personId": "uuid", "projectId": "uuid", "status": "pending"}'

# Test get user subscriptions
curl -X GET https://api.example.com/v2/subscriptions/person/{personId} \
  -H "Authorization: Bearer {token}"

# Test get project subscriptions
curl -X GET https://api.example.com/v2/projects/{projectId}/subscriptions \
  -H "Authorization: Bearer {token}"
```

---

## Related Documentation

- [API Documentation](../api/API_DOCUMENTATION.md)
- [Authentication System](../api/AUTHENTICATION_SYSTEM.md)
- [Frontend Integration Guide](../architecture/FRONTEND_INTEGRATION_GUIDE.md)
- [Subscription Email Notifications](../api/SUBSCRIPTION_EMAIL_NOTIFICATIONS.md)

---

## Change Log

### November 30, 2025
- ✅ Implemented auto-approval for super admins
- ✅ Fixed subscription status detection
- ✅ Added real-time authentication monitoring
- ✅ Fixed date display issue
- ✅ Improved error handling
- ✅ Added visual status indicators
- 🐛 Identified `/auth/subscriptions` endpoint bug
- 📝 Created comprehensive documentation

---

## Support

For questions or issues related to the subscription workflow:
1. Check this documentation first
2. Review related API documentation
3. Check CloudWatch logs for backend errors
4. Check browser console for frontend errors
5. Contact the development team

**Maintainers:**
- Backend: Registry API Team
- Frontend: Registry Frontend Team
- Documentation: Updated by Kiro AI Assistant
