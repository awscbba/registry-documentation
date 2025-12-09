# Email Notification Troubleshooting Guide

## Issue: Emails Not Being Received

### Possible Causes:

#### 1. **SES Sandbox Mode** (Most Likely)
AWS SES starts in sandbox mode which restricts email sending:
- ✅ Can only send TO verified email addresses
- ✅ Can only send FROM verified email addresses
- ❌ Cannot send to arbitrary email addresses

**Check:**
```bash
aws ses get-account-sending-enabled
```

**Solution:**
- Verify your email address in SES
- OR request production access for SES

**To verify an email:**
```bash
aws ses verify-email-identity --email-address sergio.rodriguez@cbba.cloud.org.bo
```

Then check your email for verification link.

---

#### 2. **Email Service Not Initialized**
The email service might not be properly initialized in the Lambda environment.

**Check CloudWatch Logs for:**
- "Cannot send notification - project not found"
- "Cannot send notification - person not found"
- "Failed to send notification"
- Any AttributeError or initialization errors

---

#### 3. **SES Configuration Issues**
- FROM email not verified
- SES region mismatch
- IAM permissions missing

**Check:**
```bash
# List verified email addresses
aws ses list-verified-email-addresses

# Check SES sending statistics
aws ses get-send-statistics
```

---

#### 4. **Email Service Implementation**
Check if the email service `send_email` method is working.

**Test directly:**
```python
from src.services.email_service import EmailService

email_service = EmailService()
email_service.send_email(
    to_email="sergio.rodriguez@cbba.cloud.org.bo",
    subject="Test Email",
    html_body="<p>Test</p>",
    text_body="Test"
)
```

---

## Diagnostic Steps:

### Step 1: Check SES Status
```bash
# Check if SES is in sandbox mode
aws sesv2 get-account

# List verified identities
aws ses list-identities
```

### Step 2: Check CloudWatch Logs
```bash
# Get recent logs
aws logs tail /aws/lambda/PeopleRegisterInfrastruct-PeopleApiFunction67A8223-xlC79QhrsKBe \
  --since 5m \
  --follow

# Search for email-related logs
aws logs filter-log-events \
  --log-group-name "/aws/lambda/PeopleRegisterInfrastruct-PeopleApiFunction67A8223-xlC79QhrsKBe" \
  --start-time $(($(date +%s) - 600))000 \
  --filter-pattern "email OR notification OR send_email"
```

### Step 3: Check Email Service Code
Look at `src/services/email_service.py` to verify:
- SES client initialization
- FROM email configuration
- Error handling

### Step 4: Test Email Sending Directly
Create a simple test:
```python
import boto3

ses = boto3.client('ses', region_name='us-east-1')

response = ses.send_email(
    Source='noreply@cbba.cloud.org.bo',
    Destination={'ToAddresses': ['sergio.rodriguez@cbba.cloud.org.bo']},
    Message={
        'Subject': {'Data': 'Test Email'},
        'Body': {'Text': {'Data': 'This is a test'}}
    }
)
print(response)
```

---

## Quick Fixes:

### Fix 1: Verify Email in SES
```bash
# Verify your email
aws ses verify-email-identity --email-address sergio.rodriguez@cbba.cloud.org.bo

# Check verification status
aws ses get-identity-verification-attributes \
  --identities sergio.rodriguez@cbba.cloud.org.bo
```

### Fix 2: Request Production Access
If in sandbox mode, request production access:
1. Go to AWS Console → SES
2. Click "Request production access"
3. Fill out the form
4. Wait for approval (usually 24 hours)

### Fix 3: Use Verified Test Email
For testing, use an email that's already verified in SES:
```python
# In test script, use verified email
notificationEmails=["verified-email@example.com"]
```

---

## Expected Behavior:

When working correctly, you should see in CloudWatch logs:
```json
{
  "level": "INFO",
  "category": "EMAIL_OPERATIONS",
  "message": "Subscription notification sent",
  "additional_data": {
    "recipient": "sergio.rodriguez@cbba.cloud.org.bo",
    "project_id": "...",
    "subscriber_id": "..."
  }
}
```

---

## Next Steps:

1. **Check SES sandbox status**
2. **Verify your email address in SES**
3. **Check CloudWatch logs for errors**
4. **Test email sending directly**
5. **Request production access if needed**

---

## Contact:

If issue persists:
- Check AWS SES console for bounce/complaint notifications
- Review IAM permissions for Lambda execution role
- Verify SES region matches Lambda region
- Check SES sending limits and quotas
