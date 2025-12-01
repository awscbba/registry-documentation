# Subscription Email Notifications - Testing Guide

**Feature**: Email notifications when users subscribe to projects  
**Status**: Deployed and ready for testing  
**Date**: December 1, 2025

---

## 🎯 What to Test

1. Email sent to project creator when someone subscribes
2. Email sent to additional configured admin emails
3. Notifications can be disabled per project
4. Email content is correct and professional
5. Subscription succeeds even if email fails

---

## 🧪 Test Scenarios

### Test 1: Basic Notification (Enabled by Default)

**Steps**:
1. Log in to the admin dashboard
2. Create a new project (notifications enabled by default)
3. Have another user subscribe to the project
4. Check your email inbox

**Expected Result**:
- ✅ Email received with subject: "Nueva suscripción al proyecto: [Project Name]"
- ✅ Email contains subscriber name and email
- ✅ Email contains project information
- ✅ Email has professional AWS UG Cochabamba branding
- ✅ Link to admin dashboard works

---

### Test 2: Multiple Admin Recipients

**Steps**:
1. Create a project with additional notification emails:
   ```json
   {
     "name": "Test Project",
     "enableSubscriptionNotifications": true,
     "notificationEmails": [
       "admin1@example.com",
       "admin2@example.com"
     ],
     ...other fields...
   }
   ```
2. Have a user subscribe to the project
3. Check all email inboxes

**Expected Result**:
- ✅ Project creator receives email
- ✅ admin1@example.com receives email
- ✅ admin2@example.com receives email
- ✅ All emails have identical content

---

### Test 3: Notifications Disabled

**Steps**:
1. Create a project with notifications disabled:
   ```json
   {
     "name": "Test Project",
     "enableSubscriptionNotifications": false,
     ...other fields...
   }
   ```
2. Have a user subscribe to the project
3. Check email inbox

**Expected Result**:
- ✅ NO email received
- ✅ Subscription still created successfully
- ✅ CloudWatch logs show: "Subscription notifications disabled for project"

---

### Test 4: Email Failure Doesn't Block Subscription

**Steps**:
1. Create a project with invalid notification email:
   ```json
   {
     "name": "Test Project",
     "notificationEmails": ["invalid-email@nonexistent-domain-12345.com"]
   }
   ```
2. Have a user subscribe to the project
3. Check subscription was created

**Expected Result**:
- ✅ Subscription created successfully
- ✅ Error logged in CloudWatch but subscription not affected
- ✅ Valid emails (project creator) still receive notification

---

## 📧 Email Content Verification

### Subject Line
```
Nueva suscripción al proyecto: [Project Name]
```

### Email Body Should Include:
- ✅ Greeting
- ✅ Project name
- ✅ Current participants / Max participants
- ✅ Subscriber name
- ✅ Subscriber email
- ✅ Link to admin dashboard
- ✅ AWS UG Cochabamba branding
- ✅ Footer with "no reply" notice

### Email Format:
- ✅ HTML version (styled, professional)
- ✅ Text version (plain text fallback)
- ✅ Responsive design
- ✅ Proper encoding (UTF-8)

---

## 🔍 Monitoring & Debugging

### CloudWatch Logs

**Log Group**: `/aws/lambda/PeopleRegisterInfrastruct-PeopleApiFunction*`

**Search Queries**:

1. **Successful email sending**:
   ```
   "Subscription notification sent"
   ```

2. **Notifications disabled**:
   ```
   "Subscription notifications disabled for project"
   ```

3. **Email failures**:
   ```
   "Failed to send notification"
   ```

4. **Missing data**:
   ```
   "Cannot send notification"
   ```

### Log Fields to Check:
- `recipient`: Email address
- `project_id`: Project identifier
- `subscriber_id`: Subscriber identifier
- `error`: Error message (if failed)

---

## 🐛 Troubleshooting

### Problem: No email received

**Check**:
1. Is `enableSubscriptionNotifications` set to `true`?
2. Check CloudWatch logs for "Subscription notification sent"
3. Check spam/junk folder
4. Verify SES is configured correctly
5. Check SES sending limits

**Solution**:
- Review project settings
- Check CloudWatch logs for errors
- Verify email addresses are correct

---

### Problem: Email sent but content is wrong

**Check**:
1. CloudWatch logs for email content
2. Project and subscriber data in database
3. Email template in code

**Solution**:
- Verify data is correct in database
- Check email template formatting
- Review HTML rendering in email client

---

### Problem: Subscription fails

**Check**:
1. This should NEVER happen due to email
2. If it does, there's a bug in the code

**Solution**:
- Check CloudWatch logs for errors
- Verify email sending is non-blocking
- Report bug if subscription fails due to email

---

## 🧪 Automated Test Script

Run the automated test script:

```bash
cd registry-api
uv run python scripts/test_subscription_notifications.py
```

This script will:
1. Create a test project with notifications
2. Create a test subscription
3. Verify logs show email was sent
4. Clean up test data

---

## ✅ Test Checklist

- [ ] Email received when subscription created
- [ ] Email sent to project creator
- [ ] Email sent to additional admins
- [ ] Email content is correct
- [ ] Email formatting is professional
- [ ] HTML version displays correctly
- [ ] Text version is readable
- [ ] Link to dashboard works
- [ ] Notifications can be disabled
- [ ] Subscription succeeds even if email fails
- [ ] CloudWatch logs show correct events
- [ ] No errors in production logs

---

## 📊 Test Results Template

```markdown
## Test Results - [Date]

**Tester**: [Your Name]
**Environment**: Production / Staging
**Browser**: [Browser Name & Version]

### Test 1: Basic Notification
- Status: ✅ Pass / ❌ Fail
- Notes: 

### Test 2: Multiple Recipients
- Status: ✅ Pass / ❌ Fail
- Notes: 

### Test 3: Notifications Disabled
- Status: ✅ Pass / ❌ Fail
- Notes: 

### Test 4: Email Failure Handling
- Status: ✅ Pass / ❌ Fail
- Notes: 

### Overall Result
- Status: ✅ All Pass / ⚠️ Some Issues / ❌ Failed
- Issues Found: 
- Recommendations: 
```

---

## 🚀 Production Verification

After deployment, verify:

1. **Create a real project** with your email
2. **Have a colleague subscribe** to test
3. **Check email received** within 2 seconds
4. **Verify email content** is correct
5. **Click dashboard link** to verify it works
6. **Check CloudWatch logs** for any errors

---

## 📞 Support

If you encounter issues:

1. Check CloudWatch logs first
2. Review this testing guide
3. Check feature documentation: `features/SUBSCRIPTION_EMAIL_NOTIFICATIONS.md`
4. Report issues on GitHub with:
   - Steps to reproduce
   - Expected vs actual behavior
   - CloudWatch log excerpts
   - Screenshots of email (if applicable)

---

**Last Updated**: December 1, 2025  
**Version**: 1.0  
**Status**: Ready for Testing
