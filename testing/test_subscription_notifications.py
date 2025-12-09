#!/usr/bin/env python3
"""
Test subscription email notifications via API.
Usage: python test_subscription_notifications.py
"""

import requests
import json
from datetime import datetime, timedelta
import sys

API_BASE_URL = "https://2t9blvt2c1.execute-api.us-east-1.amazonaws.com/prod"

# Credentials
USER_EMAIL = "sergio.rodriguez@cbba.cloud.org.bo"
USER_PASSWORD = "Kur0N3k0234$#@"

def print_header(text):
    print("\n" + "=" * 80)
    print(text)
    print("=" * 80 + "\n")

def print_step(step_num, text):
    print(f"📋 Step {step_num}: {text}")
    print()

def main():
    print_header("🧪 Subscription Email Notifications Test")
    
    # Step 1: Login
    print_step(1, "Login to get authentication token")
    print(f"   Email: {USER_EMAIL}")
    
    try:
        login_response = requests.post(
            f"{API_BASE_URL}/auth/login",
            json={"email": USER_EMAIL, "password": USER_PASSWORD},
            headers={"Content-Type": "application/json"}
        )
        
        if login_response.status_code != 200:
            print(f"❌ Login failed. Status: {login_response.status_code}")
            print(f"Response: {login_response.text}")
            return False
        
        login_data = login_response.json()
        token = login_data.get("data", {}).get("accessToken")
        
        if not token:
            print(f"❌ No token in response: {login_data}")
            return False
        
        print("✅ Login successful")
        print()
        
    except Exception as e:
        print(f"❌ Login error: {str(e)}")
        return False
    
    # Step 2: Create test project
    print_step(2, "Creating test project with email notifications")
    
    start_date = datetime.now().strftime("%Y-%m-%d")
    end_date = (datetime.now() + timedelta(days=30)).strftime("%Y-%m-%d")
    timestamp = int(datetime.now().timestamp())
    
    project_data = {
        "name": f"Test Project - Email Notifications {timestamp}",
        "description": "Testing subscription email notifications feature",
        "startDate": start_date,
        "endDate": end_date,
        "maxParticipants": 50,
        "status": "active",
        "category": "Testing",
        "location": "Virtual",
        "enableSubscriptionNotifications": True,
        "notificationEmails": ["test-admin@example.com"]
    }
    
    try:
        project_response = requests.post(
            f"{API_BASE_URL}/v2/projects",
            json=project_data,
            headers={
                "Content-Type": "application/json",
                "Authorization": f"Bearer {token}"
            }
        )
        
        if project_response.status_code not in [200, 201]:
            print(f"❌ Project creation failed. Status: {project_response.status_code}")
            print(f"Response: {project_response.text}")
            return False
        
        project_result = project_response.json()
        project = project_result.get("data", {})
        project_id = project.get("id")
        project_name = project.get("name")
        
        if not project_id:
            print(f"❌ No project ID in response: {project_result}")
            return False
        
        print("✅ Project created successfully")
        print(f"   Project ID: {project_id}")
        print(f"   Project Name: {project_name}")
        print(f"   Notifications enabled: True")
        print(f"   Additional emails: test-admin@example.com")
        print()
        
    except Exception as e:
        print(f"❌ Project creation error: {str(e)}")
        return False
    
    # Step 3: Get current user
    print_step(3, "Getting current user information")
    
    try:
        user_response = requests.get(
            f"{API_BASE_URL}/auth/me",
            headers={"Authorization": f"Bearer {token}"}
        )
        
        if user_response.status_code != 200:
            print(f"❌ Failed to get user info. Status: {user_response.status_code}")
            print(f"Response: {user_response.text}")
            return False
        
        user_result = user_response.json()
        user = user_result.get("data", {})
        user_id = user.get("id")
        
        if not user_id:
            print(f"❌ No user ID in response: {user_result}")
            return False
        
        print("✅ User info retrieved")
        print(f"   User ID: {user_id}")
        print()
        
    except Exception as e:
        print(f"❌ User info error: {str(e)}")
        return False
    
    # Step 4: Create subscription (triggers email)
    print_step(4, "Creating subscription (should trigger email notification)")
    
    subscription_data = {
        "personId": user_id,
        "projectId": project_id,
        "status": "pending"
    }
    
    try:
        subscription_response = requests.post(
            f"{API_BASE_URL}/v2/subscriptions",
            json=subscription_data,
            headers={
                "Content-Type": "application/json",
                "Authorization": f"Bearer {token}"
            }
        )
        
        if subscription_response.status_code not in [200, 201]:
            print(f"❌ Subscription creation failed. Status: {subscription_response.status_code}")
            print(f"Response: {subscription_response.text}")
            
            # Cleanup project
            print("\n🧹 Cleaning up test project...")
            requests.delete(
                f"{API_BASE_URL}/v2/projects/{project_id}",
                headers={"Authorization": f"Bearer {token}"}
            )
            return False
        
        subscription_result = subscription_response.json()
        subscription = subscription_result.get("data", {})
        subscription_id = subscription.get("id")
        
        if not subscription_id:
            print(f"❌ No subscription ID in response: {subscription_result}")
            return False
        
        print("✅ Subscription created successfully")
        print(f"   Subscription ID: {subscription_id}")
        print()
        
    except Exception as e:
        print(f"❌ Subscription creation error: {str(e)}")
        return False
    
    # Step 5: Verification instructions
    print_header("📧 Email Notification Verification")
    
    print("✅ The subscription was created successfully!")
    print()
    print("📬 An email notification should have been sent to:")
    print(f"   • Your email: {USER_EMAIL}")
    print(f"   • Additional admin: test-admin@example.com")
    print()
    print("📋 Please verify:")
    print(f"   1. Check your email inbox ({USER_EMAIL})")
    print(f"   2. Subject: 'Nueva suscripción al proyecto: {project_name}'")
    print("   3. Email contains subscriber information")
    print("   4. Email has professional AWS UG Cochabamba branding")
    print("   5. Link to dashboard works")
    print()
    print("🔍 To check CloudWatch logs:")
    print("   1. Go to AWS Console > CloudWatch > Log Groups")
    print("   2. Search for: /aws/lambda/PeopleRegisterInfrastruct-PeopleApiFunction*")
    print("   3. Search logs for: 'Subscription notification sent'")
    print(f"   4. Look for recipient: {USER_EMAIL}")
    print()
    
    # Cleanup prompt
    print_header("🧹 Cleanup")
    
    print("Test data created:")
    print(f"   • Project ID: {project_id}")
    print(f"   • Subscription ID: {subscription_id}")
    print()
    
    cleanup = input("Do you want to delete the test data? (y/n): ").strip().lower()
    
    if cleanup == 'y':
        print("\nDeleting subscription...")
        try:
            requests.delete(
                f"{API_BASE_URL}/v2/subscriptions/{subscription_id}",
                headers={"Authorization": f"Bearer {token}"}
            )
            print("✅ Subscription deleted")
        except Exception as e:
            print(f"⚠️  Error deleting subscription: {str(e)}")
        
        print("Deleting project...")
        try:
            requests.delete(
                f"{API_BASE_URL}/v2/projects/{project_id}",
                headers={"Authorization": f"Bearer {token}"}
            )
            print("✅ Project deleted")
        except Exception as e:
            print(f"⚠️  Error deleting project: {str(e)}")
    else:
        print("\n⚠️  Test data NOT deleted. Manual cleanup required:")
        print(f"   Project ID: {project_id}")
        print(f"   Subscription ID: {subscription_id}")
    
    print_header("✅ Test completed!")
    
    print("Next steps:")
    print("1. Check your email inbox")
    print("2. Review CloudWatch logs")
    print("3. Verify email content")
    print()
    
    return True

if __name__ == "__main__":
    try:
        success = main()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n\n⚠️  Test interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Unexpected error: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
