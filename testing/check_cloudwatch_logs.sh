#!/bin/bash
# Check CloudWatch logs for subscription notification events
# Usage: ./check_cloudwatch_logs.sh

LOG_GROUP="/aws/lambda/PeopleRegisterInfrastruct-PeopleApiFunction67A8223-xlC79QhrsKBe"
SUBSCRIPTION_ID="438a7c7e-ed10-4365-987c-297faa43982f"
PROJECT_ID="a94cef69-db6c-4326-a3fb-e90e61361ff9"

echo "=========================================="
echo "🔍 Checking CloudWatch Logs"
echo "=========================================="
echo ""

# Get recent log streams
echo "📋 Getting recent log streams..."
LOG_STREAMS=$(aws logs describe-log-streams \
    --log-group-name "$LOG_GROUP" \
    --order-by LastEventTime \
    --descending \
    --max-items 5 \
    --query 'logStreams[*].logStreamName' \
    --output text)

if [ -z "$LOG_STREAMS" ]; then
    echo "❌ No log streams found"
    exit 1
fi

echo "✅ Found log streams"
echo ""

# Search for subscription notification events
echo "📋 Searching for subscription notification events..."
echo ""

# Search for the subscription ID
echo "1. Searching for subscription creation..."
aws logs filter-log-events \
    --log-group-name "$LOG_GROUP" \
    --filter-pattern "\"$SUBSCRIPTION_ID\"" \
    --start-time $(date -d '10 minutes ago' +%s)000 \
    --query 'events[*].message' \
    --output text | head -20

echo ""
echo "2. Searching for email notification events..."
aws logs filter-log-events \
    --log-group-name "$LOG_GROUP" \
    --filter-pattern "\"Subscription notification\"" \
    --start-time $(date -d '10 minutes ago' +%s)000 \
    --query 'events[*].message' \
    --output text | head -20

echo ""
echo "3. Searching for email sending events..."
aws logs filter-log-events \
    --log-group-name "$LOG_GROUP" \
    --filter-pattern "\"send_email\" OR \"EMAIL_OPERATIONS\"" \
    --start-time $(date -d '10 minutes ago' +%s)000 \
    --query 'events[*].message' \
    --output text | head -20

echo ""
echo "4. Searching for errors..."
aws logs filter-log-events \
    --log-group-name "$LOG_GROUP" \
    --filter-pattern "\"ERROR\" OR \"Failed\"" \
    --start-time $(date -d '10 minutes ago' +%s)000 \
    --query 'events[*].message' \
    --output text | head -20

echo ""
echo "=========================================="
echo "✅ Log search completed"
echo "=========================================="
