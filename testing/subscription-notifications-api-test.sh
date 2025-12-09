#!/bin/bash
# Quick API test for subscription email notifications
# Usage: ./subscription-notifications-api-test.sh

API_BASE_URL="https://2t9blvt2c1.execute-api.us-east-1.amazonaws.com/prod"

echo "=========================================="
echo "🧪 Subscription Email Notifications Test"
echo "=========================================="
echo ""

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "⚠️  Warning: jq is not installed. Output will not be formatted."
    echo "   Install with: sudo apt-get install jq (Ubuntu) or brew install jq (Mac)"
    echo ""
fi

# Step 1: Login to get token
echo "📋 Step 1: Login to get authentication token"
echo "Enter your email:"
read USER_EMAIL
echo "Enter your password:"
read -s USER_PASSWORD
echo ""

LOGIN_RESPONSE=$(curl -s -X POST "${API_BASE_URL}/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${USER_EMAIL}\",\"password\":\"${USER_PASSWORD}\"}")

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.accessToken // empty')

if [ -z "$TOKEN" ]; then
    echo "❌ Login failed. Response:"
    echo $LOGIN_RESPONSE | jq '.' 2>/dev/null || echo $LOGIN_RESPONSE
    exit 1
fi

echo "✅ Login successful"
echo ""

# Step 2: Create a test project with notifications
echo "📋 Step 2: Creating test project with email notifications"
echo ""

START_DATE=$(date +%Y-%m-%d)
END_DATE=$(date -d "+30 days" +%Y-%m-%d 2>/dev/null || date -v+30d +%Y-%m-%d)

PROJECT_DATA=$(cat <<EOF
{
  "name": "Test Project - Email Notifications $(date +%s)",
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

PROJECT_ID=$(echo $PROJECT_RESPONSE | jq -r '.data.id // empty')

if [ -z "$PROJECT_ID" ]; then
    echo "❌ Project creation failed. Response:"
    echo $PROJECT_RESPONSE | jq '.' 2>/dev/null || echo $PROJECT_RESPONSE
    exit 1
fi

echo "✅ Project created successfully"
echo "   Project ID: ${PROJECT_ID}"
echo "   Notifications enabled: true"
echo "   Additional emails: test-admin@example.com"
echo ""

# Step 3: Get current user ID
echo "📋 Step 3: Getting current user information"
echo ""

USER_RESPONSE=$(curl -s -X GET "${API_BASE_URL}/auth/me" \
  -H "Authorization: Bearer ${TOKEN}")

USER_ID=$(echo $USER_RESPONSE | jq -r '.data.id // empty')

if [ -z "$USER_ID" ]; then
    echo "❌ Failed to get user info. Response:"
    echo $USER_RESPONSE | jq '.' 2>/dev/null || echo $USER_RESPONSE
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

SUBSCRIPTION_ID=$(echo $SUBSCRIPTION_RESPONSE | jq -r '.data.id // empty')

if [ -z "$SUBSCRIPTION_ID" ]; then
    echo "❌ Subscription creation failed. Response:"
    echo $SUBSCRIPTION_RESPONSE | jq '.' 2>/dev/null || echo $SUBSCRIPTION_RESPONSE
    
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
echo "The subscription was created successfully!"
echo "An email notification should have been sent to:"
echo "  - Your email: ${USER_EMAIL}"
echo "  - Additional admin: test-admin@example.com"
echo ""
echo "Please verify:"
echo "  1. Check your email inbox (${USER_EMAIL})"
echo "  2. Subject should be: 'Nueva suscripción al proyecto: Test Project - Email Notifications...'"
echo "  3. Email should contain subscriber information"
echo "  4. Email should have professional AWS UG Cochabamba branding"
echo ""
echo "To check CloudWatch logs:"
echo "  1. Go to AWS Console > CloudWatch > Log Groups"
echo "  2. Search for: /aws/lambda/PeopleRegisterInfrastruct-PeopleApiFunction*"
echo "  3. Search logs for: 'Subscription notification sent'"
echo "  4. Look for recipient: ${USER_EMAIL}"
echo ""

# Step 6: Cleanup
echo "=========================================="
echo "🧹 Cleanup"
echo "=========================================="
echo ""
echo "Do you want to delete the test data? (y/n)"
read CLEANUP

if [ "$CLEANUP" = "y" ] || [ "$CLEANUP" = "Y" ]; then
    echo "Deleting subscription..."
    curl -s -X DELETE "${API_BASE_URL}/v2/subscriptions/${SUBSCRIPTION_ID}" \
      -H "Authorization: Bearer ${TOKEN}" > /dev/null
    echo "✅ Subscription deleted"
    
    echo "Deleting project..."
    curl -s -X DELETE "${API_BASE_URL}/v2/projects/${PROJECT_ID}" \
      -H "Authorization: Bearer ${TOKEN}" > /dev/null
    echo "✅ Project deleted"
else
    echo "⚠️  Test data NOT deleted. Manual cleanup required:"
    echo "   Project ID: ${PROJECT_ID}"
    echo "   Subscription ID: ${SUBSCRIPTION_ID}"
fi

echo ""
echo "=========================================="
echo "✅ Test completed!"
echo "=========================================="
echo ""
