# Subscription Workflow Documentation

**Last Updated**: September 29, 2025  
**Version**: 2.0  
**Status**: Production Ready

## Overview

This document describes the complete subscription workflow for the People Registry system, including user registration, admin approval processes, and email notifications.

## Workflow Types

### 1. Public Subscription Workflow

**All public form submissions require admin approval regardless of user status.**

#### Process Flow:
1. **User Registration**
   - User fills public subscription form
   - System checks if user exists by email

2. **Subscription Creation**
   - **ALL public subscriptions** → Create with `status="pending"`
   - No immediate active subscriptions from public forms

3. **Email Notifications**
   - **User receives**: "Pending approval" email explaining next steps
   - **Admin receives**: Notification email with user details and approval link

4. **Admin Review**
   - Admin sees pending subscription in dashboard "Subscriptions" tab
   - Admin can approve or reject with dedicated buttons

5. **Final Status**
   - **If approved**: User gets welcome email, subscription becomes active
   - **If rejected**: Subscription removed, user notified

### 2. Admin Direct Management

#### Add User to Project:
- Admin checks project box in user edit interface
- Creates immediate `active` subscription
- No approval process needed

#### Remove User from Project:
- Admin unchecks project box in user edit interface
- Removes subscription only
- **User remains in database**

#### Delete User Completely:
- Admin clicks "Delete" button in user management
- System checks for active subscriptions
- **If no active subscriptions**: User deleted from database completely
- **If active subscriptions exist**: Deletion blocked with error message

## Email Templates

### User Emails

#### Pending Approval Email
- **Subject**: `Suscripción Pendiente - {project_name}`
- **Content**: Explains subscription is under review
- **Action**: Wait for admin approval

#### Welcome Email (After Approval)
- **Subject**: `¡Bienvenido al proyecto {project_name}!`
- **Content**: Confirms active subscription
- **Action**: Access to project updates

### Admin Emails

#### New Registration Notification
- **Subject**: `Nueva Suscripción Pendiente - {project_name}`
- **Content**: User details and project information
- **Action**: Link to admin approval interface

## Database Operations

### User Management
- **Create User**: New person record in database
- **Update User**: Modify existing person record
- **Delete User**: Complete removal from database (requires no active subscriptions)

### Subscription Management
- **Create Subscription**: New subscription record with status
- **Update Subscription**: Change status (pending → active/rejected)
- **Delete Subscription**: Remove subscription record (user remains)

## Status Values

### Subscription Status
- `pending`: Awaiting admin approval
- `active`: Approved and active
- `rejected`: Rejected by admin (typically deleted)

## Admin Interface

### Subscriptions Tab
- Shows all pending subscriptions
- Badge count indicates pending items
- Approve/Reject buttons for each subscription
- User and project details displayed

### User Management
- Edit user: Manage project subscriptions via checkboxes
- Delete user: Complete database removal (with validation)
- Create user: Direct user creation with optional project assignments

## Business Rules

### Subscription Rules
1. **Public forms always create pending subscriptions**
2. **Admin direct assignment creates active subscriptions**
3. **Users can only have one subscription per project**
4. **Duplicate subscription attempts are blocked**

### User Deletion Rules
1. **Cannot delete users with active subscriptions**
2. **Must remove all subscriptions before user deletion**
3. **Admin gets clear error message if deletion blocked**

### Email Rules
1. **All public registrations trigger admin notifications**
2. **Users get status-appropriate emails (pending vs welcome)**
3. **Email failures don't block subscription creation**

## Error Handling

### Common Scenarios
- **Duplicate subscription**: User-friendly error message
- **User deletion with active subscriptions**: Clear business rule violation message
- **Email delivery failure**: Logged but doesn't block process
- **Invalid project/user**: Appropriate 404 responses

### Frontend Error Messages
- Spanish language user-friendly messages
- No technical error objects shown to users
- Specific handling for common business rule violations

## API Endpoints

### Public Endpoints
- `POST /v2/public/subscribe` - Public subscription form submission

### Admin Endpoints
- `GET /v2/subscriptions` - List all subscriptions (with status filtering)
- `PUT /v2/subscriptions/{id}` - Update subscription status
- `DELETE /v2/admin/users/{id}` - Delete user completely
- `GET /v2/admin/stats` - Admin dashboard statistics

## Security Considerations

### Authentication
- Public subscription: No authentication required
- Admin operations: JWT token with admin role required
- User management: Admin permissions validated

### Authorization
- Subscription approval: Admin role required
- User deletion: Admin role + business rule validation
- Email notifications: System-level operations

## Monitoring and Logging

### Key Events Logged
- Public subscription attempts
- Admin approval/rejection actions
- User deletion attempts (successful and blocked)
- Email delivery status
- Business rule violations

### Metrics Tracked
- Pending subscription count
- Approval/rejection rates
- User registration trends
- Email delivery success rates

## Troubleshooting

### Common Issues
1. **User gets immediate approval**: Check if admin directly assigned vs public form
2. **Admin not receiving notifications**: Verify email configuration and admin email address
3. **User deletion blocked**: Check for active/pending subscriptions
4. **Duplicate subscription errors**: Verify user doesn't already have subscription to project

### Debug Steps
1. Check subscription status in database
2. Verify email logs for delivery status
3. Review admin dashboard for pending items
4. Validate user permissions and authentication

## Configuration

### Email Settings
- Admin notification email: `admin@cbba.cloud.org.bo`
- From email: Configured in EmailService
- Email templates: Embedded in service methods

### Frontend Settings
- API endpoints configured in `api.ts`
- Error messages in Spanish
- Admin interface integrated in dashboard

---

**Note**: This workflow ensures proper admin oversight while maintaining user-friendly experience and clear business rule enforcement.
