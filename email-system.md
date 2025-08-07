# Email System Documentation

## Overview

The People Registry system uses AWS SES (Simple Email Service) to send transactional emails to users during the subscription workflow.

## Email Types

### 1. Welcome Emails
- **Trigger**: New user subscription creation
- **Recipients**: New users with generated temporary passwords
- **Content**: Welcome message, temporary password, login instructions
- **Template**: HTML + Text versions with AWS User Group branding

### 2. Subscription Approval/Rejection Emails
- **Trigger**: Admin changes subscription status
- **Recipients**: Users whose subscriptions are approved/rejected
- **Content**: Status notification, project details, next steps
- **Template**: Professional HTML design with Spanish localization

## Configuration

### Environment Variables
```bash
SES_FROM_EMAIL=srinclan@gmail.com  # Verified sender address
AWS_REGION=us-east-1               # SES region
```

### SES Setup Requirements

#### 1. Email Address Verification
- **Production**: Requires SES production access (can send to any email)
- **Sandbox**: Can only send to verified email addresses
- **Current Status**: Sandbox mode - production access requested

#### 2. Verified Addresses
- `srinclan@gmail.com` ✅ Verified
- `srinclan@arcamo.org` ✅ Verified

### Lambda Configuration
The email functionality is integrated into the API Lambda function with the following environment variables:
- `SES_FROM_EMAIL`: Sender email address
- All other standard Lambda environment variables

## Email Service Architecture

### Components
1. **EmailService** (`src/services/email_service.py`)
   - Handles SES integration
   - Template rendering
   - Error handling and logging

2. **Email Models** (`src/models/email.py`)
   - EmailType enum (WELCOME, SUBSCRIPTION_APPROVED, SUBSCRIPTION_REJECTED)
   - EmailRequest/EmailResponse models
   - Validation schemas

3. **Templates**
   - HTML templates with responsive design
   - Spanish localization
   - AWS User Group branding

### Integration Points
- **Subscription Creation**: Sends welcome email with temporary password
- **Subscription Status Updates**: Sends approval/rejection notifications
- **Error Handling**: Graceful degradation if email fails

## Testing

### Test Files Location
- `tests/test_email.py` - Comprehensive email service tests
- `tests/test_email_simple.py` - Basic SES configuration tests
- `tests/test_subscription_email.py` - Integration tests
- `tests/test_subscription_creation.py` - End-to-end workflow tests

### Test Coverage
- ✅ Email service initialization
- ✅ Template rendering
- ✅ SES integration
- ✅ Error handling
- ✅ Subscription workflow integration
- ✅ Email verification status

### Running Tests
```bash
# Using devbox and uv
devbox shell
just test-email

# Direct execution
uv run python -m pytest tests/test_email*.py -v
```

## Troubleshooting

### Common Issues

#### 1. Email Not Received
**Symptoms**: API returns success but user doesn't receive email
**Causes**:
- SES in sandbox mode (recipient not verified)
- Invalid sender email address
- Email in spam folder

**Solutions**:
- Check SES verification status
- Request production access
- Verify sender email address

#### 2. SES Sandbox Limitations
**Symptoms**: "Email address is not verified" error
**Cause**: SES sandbox mode restricts recipients
**Solution**: Request production access via AWS Console

#### 3. Lambda Environment Issues
**Symptoms**: Import errors or configuration issues
**Cause**: Missing environment variables
**Solution**: Update Lambda environment variables

### Monitoring

#### CloudWatch Logs
- Log group: `/aws/lambda/PeopleRegisterInfrastruct-PeopleApiFunction67A8223-xlC79QhrsKBe`
- Search patterns:
  - `"email"` - All email-related logs
  - `"Email sent successfully"` - Successful sends
  - `"Failed to send email"` - Email failures

#### SES Metrics
- Sending quota: 200 emails/24 hours (sandbox)
- Send rate: 1 email/second (sandbox)
- Bounce/complaint rates: Monitor via SES console

## Production Deployment

### SES Production Access
1. **Request via AWS Console**:
   - Go to SES Console → Account dashboard
   - Click "Request production access"
   - Fill form with use case details

2. **Use Case Description**:
   ```
   AWS User Group Cochabamba - People Registry System
   
   Community event management system sending transactional emails:
   - Welcome emails with temporary passwords
   - Subscription approval/rejection notifications
   - Password reset emails
   
   Expected volume: 50-100 emails/month
   Proper opt-in processes and bounce handling implemented
   ```

3. **Approval Timeline**: 24-48 hours
4. **Post-Approval**: Can send to any email address

### Deployment Checklist
- [ ] SES production access approved
- [ ] Sender email verified
- [ ] Lambda environment variables updated
- [ ] Email templates tested
- [ ] Monitoring configured
- [ ] Error handling verified

## Security Considerations

### Email Content
- No sensitive data in email content
- Temporary passwords are time-limited
- Login links include proper authentication

### SES Security
- Sender email verification required
- Bounce and complaint handling implemented
- Rate limiting enforced by AWS

### Data Privacy
- Email addresses stored securely
- Opt-out mechanisms available
- GDPR compliance considerations

## Future Enhancements

### Planned Features
- [ ] Email templates customization
- [ ] Multi-language support
- [ ] Email scheduling
- [ ] Advanced analytics
- [ ] Custom domain setup (noreply@awsugcbba.org)

### Technical Improvements
- [ ] Email queue for high volume
- [ ] Template versioning
- [ ] A/B testing capabilities
- [ ] Enhanced error recovery

## Related Documentation
- [API Documentation](./api-documentation.md)
- [Lambda Architecture](./lambda-architecture.md)
- [Testing Guide](./testing-guide.md)
- [Deployment Guide](./deployment-guide.md)
