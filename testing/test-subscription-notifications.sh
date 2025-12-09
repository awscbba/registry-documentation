#!/bin/bash
# Quick API test for subscription email notifications
# Usage: 
#   export TEST_EMAIL="your-email@example.com"
#   export TEST_PASSWORD="your-password"
#   ./test-subscription-notifications.sh

API_BASE_URL="https://2t9blvt2c1.execute-api.us-east-1.amazonaws.com/prod"

echo "=========================================="
echo "🧪 Subscription Email Notifications Test"
echo "=========================================="
echo ""

# Check for credentials
if [ -z "$TEST_EMAIL" ] || [ -z "$TEST_PASSWORD" ]; then
    echo "❌ Error: Credentials not provided"
    echo ""
    echo "Usage:"
    echo "  export TEST_EMAIL=\"your-email@example.com\""
    echo "  export TEST_PASSWORD=\"your-password\""
    echo "  ./test-subscription-notifications.sh"
    echo ""
    exit 1
fi

USER_EMAIL="$TEST_EMAIL"
USER_PASSWORD="$TEST_PASSWORD"

# Step 1: Login to get token
echo "📋 Step 1: Login to get authentication token"
echo "   Email: ${USER_EMAIL}"
echo ""

LOGIN_RESPONSE=$(curl -s -X POST "${API_BASE_URL}/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${USER_EMAIL}\",\"password\":\"${USER_PASSWORD}\"}")

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"accessToken":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "❌ Login failed. Response:"
    echo $LOGIN_RESPONSE
    exit 1
fi

echo "✅ Login successful"
echo ""

# Step 2: Create a test project with notifications
echo "📋 Step 2: Creating test project with email notifications"
echo ""

START_DATE=$(date +%Y-%m-%d)
END_DATE=$(date -d "+30 days" +%Y-%m-%d 2>/dev/null || date -v+30d +%Y-%m-%d 2>/dev/null || date +%Y-%m-%d)
TIMESTAMP=$(date +%s)

PROJECT_DATA=$(cat <<EOF
{
  "name": "Test Project - Email Notifications ${TIMESTAMP}",
  "description": "Testing subscription email notifications feature",
  "startDate": "${START_DATE}",
  "endDate": "${END_DATE}",
  "maxParticipants": 50,
  "status": "active",
  "category": "Testing",
  "location": "Virtual",
  "enableSubscriptionNotifications": true,
  "notificationEmails": ["test-admin@example.com"]
}
EOF
)

PROJECT_RESPONSE=$(curl -s -X POST "${API_BASE_URL}/v2/projects" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d "${PROJECT_DATA}")

PROJECT_ID=$(echo $PROJECT_RESPONSE | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$PROJECT_ID" ]; then
    echo "❌ Project creation failed. Response:"
    echo $PROJECT_RESPONSE
    exit 1
fi

PROJECT_NAME=$(echo $PROJECT_RESPONSE | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)

echo "✅ Project created successfully"
echo "   Project ID: ${PROJECT_ID}"
echo "   Project Name: ${PROJECT_NAME}"
echo "   Notifications enabled: true"
echo "   Additional emails: test-admin@example.com"
echo ""

# Step 3: Get current user ID
echo "📋 Step 3: Getting current user information"
echo ""

USER_RESPONSE=$(curl -s -X GET "${API_BASE_URL}/auth/me" \
  -H "Authorization: Bearer ${TOKEN}")

USER_ID=$(echo $USER_RESPONSE | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$USER_ID" ]; then
    echo "❌ Failed to get user info. Response:"
    echo $USER_RESPONSE
    exit 1
fi

echo "✅ User info retrieved"
echo "   User ID: ${USER_ID}"
echo ""

# Step 4: Create subscription (this should trigger email)
echo "📋 Step 4: Creating subscription (should trigger email notification)"
echo ""

SUBSCRIPTION_DATA=$(cat <<EOF
{
  "personId": "${USER_ID}",
  "projectId": "${PROJECT_ID}",
  "status": "pending"
}
EOF
)

SUBSCRIPTION_RESPONSE=$(curl -s -X POST "${API_BASE_URL}/v2/subscriptions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TOKEN}" \
  -d "${SUBSCRIPTION_DATA}")

SUBSCRIPTION_ID=$(echo $SUBSCRIPTION_RESPONSE | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$SUBSCRIPTION_ID" ]; then
    echo "❌ Subscription creation failed. Response:"
    echo $SUBSCRIPTION_RESPONSE
    
    # Cleanup project
    echo ""
    echo "🧹 Cleaning up test project..."
    curl -s -X DELETE "${API_BASE_URL}/v2/projects/${PROJECT_ID}" \
      -H "Authorization: Bearer ${TOKEN}" > /dev/null
    exit 1
fi

echo "✅ Subscription created successfully"
echo "   Subscription ID: ${SUBSCRIPTION_ID}"
echo ""

# Step 5: Verification instructions
echo "=========================================="
echo "📧 Email Notification Verification"
echo "=========================================="
echo ""
echo "✅ The subscription was created successfully!"
echo ""
echo "📬 An email notification should have been sent to:"
echo "   • Your email: ${USER_EMAIL}"
echo "   • Additional admin: test-admin@example.com"
echo ""
echo "📋 Please verify:"
echo "   1. Check your email inbox (${USER_EMAIL})"
echo "   2. Subject: 'Nueva suscripción al proyecto: ${PROJECT_NAME}'"
echo "   3. Email contains subscriber information"
echo "   4. Email has professional AWS UG Cochabamba branding"
echo "   5. Link to dashboard works"
echo ""
echo "🔍 To check CloudWatch logs:"
echo "   1. Go to AWS Console > CloudWatch > Log Groups"
echo "   2. Search for: /aws/lambda/PeopleRegisterInfrastruct-PeopleApiFunction*"
echo "   3. Search logs for: 'Subscription notification sent'"
echo "   4. Look for recipient: ${USER_EMAIL}"
echo ""

# Save IDs for cleanup
echo "PROJECT_ID=${PROJECT_ID}" > /tmp/test-subscription-ids.txt
echo "SUBSCRIPTION_ID=${SUBSCRIPTION_ID}" >> /tmp/test-subscription-ids.txt
echo "TOKEN=${TOKEN}" >> /tmp/test-subscription-ids.txt

echo "=========================================="
echo "🧹 Cleanup"
echo "=========================================="
echo ""
echo "Test data created:"
echo "   • Project ID: ${PROJECT_ID}"
echo "   • Subscription ID: ${SUBSCRIPTION_ID}"
echo ""
echo "To clean up later, run:"
echo "   ./cleanup-test-data.sh"
echo ""
echo "Or clean up now with:"
echo "   curl -X DELETE '${API_BASE_URL}/v2/subscriptions/${SUBSCRIPTION_ID}' -H 'Authorization: Bearer ${TOKEN}'"
echo "   curl -X DELETE '${API_BASE_URL}/v2/projects/${PROJECT_ID}' -H 'Authorization: Bearer ${TOKEN}'"
echo ""
echo "=========================================="
echo "✅ Test completed!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Check your email inbox"
echo "2. Review CloudWatch logs"
echo "3. Verify email content"
echo "4. Clean up test data when done"
echo ""
