# 🚀 Production Deployment Guide - People Registry API

## 📋 Overview
This guide provides step-by-step instructions for deploying the complete People Registry API to AWS production environment with all implemented features:

- ✅ **Phase 4**: Service-Repository Integration Layer
- ✅ **Phase 5A**: Comprehensive Monitoring Implementation  
- ✅ **Phase 5B**: Advanced Features (Caching, Rate Limiting, Bulk Operations)

## 🏗️ Architecture Overview

### **Production Infrastructure (Serverless)**
```
    Internet
        │
   ┌────▼────┐
   │CloudFront│ (CDN + Static Frontend)
   └────┬────┘
        │
   ┌────▼────┐
   │API Gateway│ (REST API + Authentication)
   └────┬────┘
        │
   ┌────▼────┐     ┌─────────────┐     ┌─────────────┐
   │ Lambda  │────▶│  DynamoDB   │────▶│    SES      │
   │Functions│     │   Tables    │     │(Email Svc)  │
   │(Container)│    │             │     └─────────────┘
   └─────────┘     └─────────────┘
        │
   ┌────▼────┐
   │CloudWatch│ (Logs + Metrics + Alarms)
   └─────────┘
```

### **Serverless Components**
- **CloudFront**: CDN distribution for frontend static files
- **API Gateway**: RESTful API endpoints with built-in authentication
- **Lambda Functions**: Container-based serverless compute (3 functions)
  - Main API Function: All business logic and endpoints
  - Auth Function: Authentication and authorization
  - Router Function: Request routing and load balancing
- **DynamoDB**: NoSQL database with multiple tables
  - PeopleTable, ProjectsTable, SubscriptionsTable
  - AuditLogsTable, PasswordResetTokensTable
  - RateLimitTable, SessionTrackingTable
- **SES**: Simple Email Service for notifications
- **CloudWatch**: Comprehensive monitoring and logging

### **Monitoring & Observability**
- **CloudWatch Metrics**: Lambda function metrics, API Gateway metrics, DynamoDB metrics
- **CloudWatch Logs**: Lambda function logs with structured logging
- **CloudWatch Dashboards**: Real-time serverless monitoring
- **CloudWatch Alarms**: Automated alerting for errors, latency, and throttling
- **X-Ray Tracing**: Distributed tracing for Lambda functions (enabled)

## 🔧 Prerequisites

### **1. AWS Account Setup**
- AWS Account with appropriate permissions
- AWS CLI installed and configured
- AWS CDK CLI installed (`npm install -g aws-cdk`)

### **2. Local Development Environment**
- Docker installed and running
- Node.js 18+ installed
- Python 3.11+ installed
- Git installed

### **3. Required Permissions**
Your AWS user/role needs the following permissions:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:*",
        "apigateway:*",
        "dynamodb:*",
        "cloudfront:*",
        "s3:*",
        "ses:*",
        "cloudformation:*",
        "cloudwatch:*",
        "logs:*",
        "iam:*",
        "ecr:*",
        "xray:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## 🚀 Deployment Steps

### **Step 1: Clone and Prepare Repository**
```bash
# Clone the repository
git clone <repository-url>
cd people-registry-03/registry-infrastructure

# Verify all files are present
ls -la
# Should see: app.py, cdk.json, requirements.txt, people_register_infrastructure/
```

### **Step 2: Configure Environment Variables**
```bash
# Set required environment variables
export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export CDK_DEFAULT_REGION=us-east-1
export CDK_DEFAULT_ACCOUNT=$AWS_ACCOUNT_ID

# Verify configuration
echo "AWS Region: $AWS_REGION"
echo "AWS Account: $AWS_ACCOUNT_ID"
```

### **Step 3: Install Dependencies**
```bash
# Install Python dependencies
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Install Node.js dependencies
npm install
```

### **Step 4: Deploy to Production**
```bash
# Bootstrap CDK (first time only)
npx cdk bootstrap

# Deploy the serverless infrastructure
npx cdk deploy PeopleRegisterInfrastructureStack

# The deployment will:
# 1. Create DynamoDB tables
# 2. Build and deploy Lambda functions (container-based)
# 3. Set up API Gateway with endpoints
# 4. Configure CloudFront distribution
# 5. Set up CloudWatch monitoring
# 6. Configure SES for email notifications
```

### **Step 5: Verify Deployment**
After deployment completes, verify the system:

```bash
# Get the API Gateway URL from the CDK output
API_URL="https://2t9blvt2c1.execute-api.us-east-1.amazonaws.com/prod"

# Test health endpoint
curl $API_URL/health

# Expected response:
{
  "status": "healthy",
  "service": "people-register-api-modular",
  "timestamp": "2025-08-15T15:00:00.000Z",
  "versions": ["v1", "v2"],
  "detailed_health": {
    "services": {
      "people": {"status": "healthy"},
      "auth": {"status": "healthy"},
      "roles": {"status": "healthy"}
    }
  }
}

# Test frontend URL
FRONTEND_URL="https://d28z2il3z2vmpc.cloudfront.net"
curl -I $FRONTEND_URL
```

## 📊 Post-Deployment Configuration

### **1. Configure Custom Domain (Optional)**
```bash
# If you have a custom domain, update the CDK stack
cd infrastructure
cdk deploy --context environment=production --context domainName=api.yourdomain.com
```

### **2. Set Up SSL Certificate**
```bash
# Request SSL certificate through AWS Certificate Manager
aws acm request-certificate \
  --domain-name api.yourdomain.com \
  --validation-method DNS \
  --region us-west-2
```

### **3. Configure Monitoring Alerts**
```bash
# Create SNS topic for alerts
aws sns create-topic --name people-registry-alerts

# Subscribe to alerts
aws sns subscribe \
  --topic-arn arn:aws:sns:us-west-2:ACCOUNT:people-registry-alerts \
  --protocol email \
  --notification-endpoint your-email@domain.com
```

## 🔍 Monitoring and Observability

### **CloudWatch Dashboard**
Access your dashboard at:
```
https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=people-registry-production
```

### **Key Metrics to Monitor**
- **Lambda Functions**: Duration, errors, throttles, concurrent executions
- **API Gateway**: Request count, latency, 4XX/5XX errors, cache hit ratio
- **DynamoDB**: Read/write capacity, throttled requests, user errors
- **CloudFront**: Cache hit ratio, origin latency, error rate

### **Log Analysis**
```bash
# View Lambda function logs
aws logs tail /aws/lambda/PeopleRegisterInfrastruct-PeopleApiFunction67A8223-xlC79QhrsKBe --follow

# Search for errors in API function
aws logs filter-log-events \
  --log-group-name /aws/lambda/PeopleRegisterInfrastruct-PeopleApiFunction67A8223-xlC79QhrsKBe \
  --filter-pattern "ERROR"

# View authentication function logs
aws logs tail /aws/lambda/PeopleRegisterInfrastructureS-AuthFunctionA1CD5E0F-lujBJmLNxohb --follow
```

## 🧪 Testing Production Deployment

### **1. Smoke Tests**
```bash
# Set API URL
API_URL="https://2t9blvt2c1.execute-api.us-east-1.amazonaws.com/prod"

# Test all major endpoints
curl $API_URL/health
curl $API_URL/v1/people
curl $API_URL/v2/people
curl $API_URL/admin/performance/dashboard  # Requires admin auth
curl $API_URL/admin/performance/cache/stats # Requires admin auth

# Test frontend
curl -I https://d28z2il3z2vmpc.cloudfront.net
```

### **2. Load Testing**
```bash
# Install Apache Bench or similar tool
sudo apt-get install apache2-utils

# Run load test on serverless API
ab -n 1000 -c 10 $API_URL/health

# Monitor Lambda metrics during load test
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Duration \
  --dimensions Name=FunctionName,Value=PeopleRegisterInfrastruct-PeopleApiFunction67A8223-xlC79QhrsKBe \
  --start-time $(date -u -d '5 minutes ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average
```

### **3. Feature Validation**
```bash
# Test authentication
curl -X POST $API_URL/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "password": "password"}'

# Test rate limiting (DynamoDB-based)
for i in {1..100}; do curl $API_URL/v1/people; done

# Test performance monitoring (requires admin auth)
curl $API_URL/admin/performance/dashboard \
  -H "Authorization: Bearer <admin-jwt-token>"
```

## 🔧 Troubleshooting

### **Common Issues**

#### **1. Lambda Functions Failing**
```bash
# Check Lambda function status
aws lambda get-function --function-name PeopleRegisterInfrastruct-PeopleApiFunction67A8223-xlC79QhrsKBe

# Check function logs
aws logs tail /aws/lambda/PeopleRegisterInfrastruct-PeopleApiFunction67A8223-xlC79QhrsKBe --follow

# Check function metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Errors \
  --dimensions Name=FunctionName,Value=PeopleRegisterInfrastruct-PeopleApiFunction67A8223-xlC79QhrsKBe \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum
```

#### **2. DynamoDB Connection Issues**
```bash
# Check DynamoDB table status
aws dynamodb describe-table --table-name PeopleTable

# Check for throttling
aws cloudwatch get-metric-statistics \
  --namespace AWS/DynamoDB \
  --metric-name ThrottledRequests \
  --dimensions Name=TableName,Value=PeopleTable \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum
```

#### **3. API Gateway Issues**
```bash
# Check API Gateway status
aws apigateway get-rest-apis

# Check API Gateway logs
aws logs tail /aws/apigateway/2t9blvt2c1 --follow

# Test specific endpoint
curl -v https://2t9blvt2c1.execute-api.us-east-1.amazonaws.com/prod/health
```

### **Rollback Procedure**
If deployment fails or issues arise:

```bash
# Rollback Lambda function to previous version
aws lambda update-function-code \
  --function-name PeopleRegisterInfrastruct-PeopleApiFunction67A8223-xlC79QhrsKBe \
  --image-uri <previous-image-uri>

# Or destroy and redeploy CDK stack
cd registry-infrastructure
npx cdk destroy PeopleRegisterInfrastructureStack
# Then redeploy with previous version
git checkout <previous-commit>
npx cdk deploy PeopleRegisterInfrastructureStack
```

## 📈 Performance Optimization

### **1. Lambda Function Optimization**
The deployment includes optimizations for:
- **Container-based deployment**: Faster cold starts with optimized images
- **Memory allocation**: Right-sized memory for optimal price/performance
- **Provisioned concurrency**: Available for high-traffic functions
- **Connection pooling**: Efficient database connections

### **2. DynamoDB Optimization**
- **On-demand billing**: Automatic scaling based on traffic
- **Global Secondary Indexes**: Optimized query patterns
- **DynamoDB Accelerator (DAX)**: Available for microsecond latency
- **Point-in-time recovery**: Enabled for data protection

### **3. API Gateway Optimization**
- **Caching**: Response caching for frequently accessed endpoints
- **Compression**: Automatic response compression
- **Throttling**: Request rate limiting to protect backend
- **Regional endpoints**: Optimized for low latency

## 🔒 Security Considerations

### **1. Network Security**
- **API Gateway**: Built-in DDoS protection and throttling
- **CloudFront**: AWS Shield Standard protection
- **Lambda**: No direct internet access, secure by default
- **DynamoDB**: VPC endpoints for secure access

### **2. Application Security**
- **JWT Authentication**: Secure token-based authentication
- **Role-based access control**: Admin and user role separation
- **Rate limiting**: DynamoDB-based request throttling
- **Input validation**: Comprehensive request validation
- **Audit logging**: All operations logged to DynamoDB

### **3. Data Security**
- **DynamoDB encryption**: Encryption at rest enabled
- **Lambda environment variables**: Encrypted sensitive configuration
- **SES**: Secure email delivery with DKIM/SPF
- **CloudWatch Logs**: Encrypted log storage
- **IAM roles**: Least privilege access principles

## 📋 Maintenance Tasks

### **Daily**
- Monitor CloudWatch dashboards
- Check application logs for errors
- Verify backup completion

### **Weekly**
- Review performance metrics
- Check for security updates
- Validate monitoring alerts

### **Monthly**
- Review and optimize costs
- Update dependencies
- Perform disaster recovery testing
- Review and update documentation

## 🎯 Success Criteria

Your deployment is successful when:

✅ **Health Check**: `/health` endpoint returns 200 OK  
✅ **API Functionality**: All v1 and v2 endpoints respond correctly  
✅ **Lambda Functions**: All 3 Lambda functions are healthy and responding  
✅ **DynamoDB**: All tables are active and accessible  
✅ **API Gateway**: REST API is deployed and routing correctly  
✅ **CloudFront**: Frontend distribution is serving static files  
✅ **Authentication**: JWT-based auth system working correctly  
✅ **Performance Monitoring**: Admin endpoints accessible with proper auth  
✅ **Monitoring**: CloudWatch dashboards showing green metrics  

## 🚀 Next Steps

After successful deployment:

1. **Set up CI/CD Pipeline**: Automate future deployments
2. **Configure Monitoring Alerts**: Set up notifications for critical issues
3. **Implement Backup Strategy**: Regular database and configuration backups
4. **Performance Testing**: Conduct thorough load testing
5. **Security Audit**: Perform security assessment and penetration testing
6. **Documentation**: Update API documentation and user guides
7. **Training**: Train team on production operations and troubleshooting

---

## 🎉 Congratulations!

You have successfully deployed a production-grade People Registry API with:

- **Enterprise-grade architecture** on AWS
- **Comprehensive monitoring** and observability
- **Advanced features** including caching, rate limiting, and bulk operations
- **High availability** and auto-scaling
- **Security best practices** and compliance
- **Performance optimization** for production workloads

Your API is now ready to handle production traffic and scale with your business needs! 🚀
