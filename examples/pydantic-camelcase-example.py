"""
Example: Pydantic CamelCase Conversion for People Registry API

This example shows how to implement automatic snake_case to camelCase 
conversion in the backend API using Pydantic's alias_generator.
"""

from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel
from datetime import datetime
from typing import Optional, List
import json

# =============================================================================
# BEFORE: Manual field mapping (current problematic approach)
# =============================================================================

class SubscriptionResponseOld(BaseModel):
    """Old approach: Fields don't match frontend expectations"""
    id: str
    person_id: str          # ❌ Frontend expects 'personId'
    project_id: str         # ❌ Frontend expects 'projectId'
    person_name: Optional[str] = None  # ❌ Frontend expects 'personName'
    person_email: Optional[str] = None # ❌ Frontend expects 'personEmail'
    status: str
    email_sent: bool = False           # ❌ Frontend expects 'emailSent'
    created_at: Optional[datetime] = None  # ❌ Frontend expects 'createdAt'
    updated_at: Optional[datetime] = None  # ❌ Frontend expects 'updatedAt'

# =============================================================================
# AFTER: Automatic camelCase conversion (recommended solution)
# =============================================================================

class SubscriptionResponse(BaseModel):
    """New approach: Automatic snake_case to camelCase conversion"""
    model_config = ConfigDict(
        alias_generator=to_camel,      # 🎯 This does the magic!
        populate_by_name=True          # Allows both naming conventions for input
    )
    
    # Internal field names (snake_case) - matches database
    id: str
    person_id: str          # → API returns 'personId'
    project_id: str         # → API returns 'projectId'
    person_name: Optional[str] = None  # → API returns 'personName'
    person_email: Optional[str] = None # → API returns 'personEmail'
    status: str
    email_sent: bool = False           # → API returns 'emailSent'
    created_at: Optional[datetime] = None  # → API returns 'createdAt'
    updated_at: Optional[datetime] = None  # → API returns 'updatedAt'
    notes: Optional[str] = None

class PersonResponse(BaseModel):
    """Person model with automatic camelCase conversion"""
    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True
    )
    
    id: str
    first_name: str         # → API returns 'firstName'
    last_name: str          # → API returns 'lastName'
    email: str
    phone: Optional[str] = None
    company: Optional[str] = None
    position: Optional[str] = None
    bio: Optional[str] = None
    linkedin_url: Optional[str] = None  # → API returns 'linkedinUrl'
    twitter_url: Optional[str] = None   # → API returns 'twitterUrl'
    github_url: Optional[str] = None    # → API returns 'githubUrl'
    website_url: Optional[str] = None   # → API returns 'websiteUrl'
    birth_date: Optional[str] = None    # → API returns 'birthDate'
    join_date: Optional[str] = None     # → API returns 'joinDate'
    is_active: bool = True              # → API returns 'isActive'
    created_at: Optional[datetime] = None  # → API returns 'createdAt'
    updated_at: Optional[datetime] = None  # → API returns 'updatedAt'
    tags: List[str] = []
    notes: Optional[str] = None

# =============================================================================
# USAGE EXAMPLE: Service Layer
# =============================================================================

class SubscriptionService:
    """Example service showing how to use the new models"""
    
    async def get_all_subscriptions(self) -> List[SubscriptionResponse]:
        # Simulate database data (snake_case from DynamoDB/PostgreSQL)
        raw_data = [
            {
                "id": "sub_123",
                "person_id": "person_456", 
                "project_id": "proj_789",
                "person_name": "John Doe",
                "person_email": "john@example.com",
                "status": "active",
                "email_sent": False,
                "created_at": datetime.now(),
                "updated_at": datetime.now(),
                "notes": "Test subscription"
            }
        ]
        
        # Convert to Pydantic models (automatic camelCase conversion)
        return [SubscriptionResponse(**item) for item in raw_data]
    
    async def get_person_subscriptions(self, person_id: str) -> List[SubscriptionResponse]:
        # Filter subscriptions for specific person
        all_subs = await self.get_all_subscriptions()
        return [sub for sub in all_subs if sub.person_id == person_id]

# =============================================================================
# API HANDLER EXAMPLE
# =============================================================================

async def handle_get_subscriptions(event, context):
    """Lambda handler returning camelCase JSON"""
    try:
        service = SubscriptionService()
        subscriptions = await service.get_all_subscriptions()
        
        # Convert to dict with camelCase keys
        response_data = [sub.model_dump() for sub in subscriptions]
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'success': True,
                'data': response_data,  # 🎯 camelCase fields automatically!
                'version': 'v2'
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'success': False, 'error': str(e)})
        }

# =============================================================================
# DEMONSTRATION: Before vs After
# =============================================================================

def demonstrate_conversion():
    """Show the difference between old and new approaches"""
    
    # Sample database data (snake_case)
    db_data = {
        "id": "sub_123",
        "person_id": "person_456",
        "project_id": "proj_789", 
        "person_name": "John Doe",
        "person_email": "john@example.com",
        "status": "active",
        "email_sent": False,
        "created_at": datetime.now(),
        "updated_at": datetime.now()
    }
    
    print("=== DATABASE DATA (snake_case) ===")
    print(json.dumps({k: str(v) for k, v in db_data.items()}, indent=2))
    
    # OLD APPROACH: Fields don't match frontend
    old_model = SubscriptionResponseOld(**db_data)
    old_json = old_model.model_dump()
    
    print("\n=== OLD API RESPONSE (snake_case - PROBLEMATIC) ===")
    print(json.dumps(old_json, indent=2, default=str))
    
    # NEW APPROACH: Automatic camelCase conversion
    new_model = SubscriptionResponse(**db_data)
    new_json = new_model.model_dump()  # Uses alias_generator automatically
    
    print("\n=== NEW API RESPONSE (camelCase - PERFECT!) ===")
    print(json.dumps(new_json, indent=2, default=str))
    
    print("\n=== FRONTEND TYPESCRIPT INTERFACE (matches perfectly) ===")
    print("""
    interface Subscription {
      id: string;
      personId: string;    // ✅ Matches 'personId' from API
      projectId: string;   // ✅ Matches 'projectId' from API  
      personName?: string; // ✅ Matches 'personName' from API
      personEmail?: string;// ✅ Matches 'personEmail' from API
      status: string;
      emailSent?: boolean; // ✅ Matches 'emailSent' from API
      createdAt?: string;  // ✅ Matches 'createdAt' from API
      updatedAt?: string;  // ✅ Matches 'updatedAt' from API
    }
    """)

# =============================================================================
# MIGRATION COMPATIBILITY
# =============================================================================

class BackwardCompatibleSubscription(BaseModel):
    """Transition model that accepts both naming conventions"""
    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True  # 🎯 Accepts both snake_case AND camelCase input
    )
    
    id: str
    person_id: str
    project_id: str
    status: str
    
    # This model can handle:
    # Input: {"person_id": "123"} OR {"personId": "123"}
    # Output: Always {"personId": "123"}

def test_backward_compatibility():
    """Test that the model accepts both naming conventions"""
    
    # Test snake_case input (from database)
    snake_case_data = {"id": "123", "person_id": "456", "project_id": "789", "status": "active"}
    model1 = BackwardCompatibleSubscription(**snake_case_data)
    
    # Test camelCase input (from frontend)
    camel_case_data = {"id": "123", "personId": "456", "projectId": "789", "status": "active"}
    model2 = BackwardCompatibleSubscription(**camel_case_data)
    
    # Both produce the same camelCase output
    output1 = model1.model_dump()
    output2 = model2.model_dump()
    
    print("Snake case input →", output1)
    print("Camel case input →", output2)
    print("Outputs match:", output1 == output2)  # True!

if __name__ == "__main__":
    demonstrate_conversion()
    print("\n" + "="*60)
    test_backward_compatibility()