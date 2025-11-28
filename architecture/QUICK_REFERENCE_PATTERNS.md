# Quick Reference Patterns - AI Assistant

**Purpose**: Fast reference for common patterns to prevent duplication and inconsistencies.

---

## 🚨 POSTAL CODE HANDLING (CRITICAL)

### **The Golden Rule**: 
- **Storage**: `postal_code` (snake_case)
- **Pydantic Creation**: `postalCode` (camelCase)
- **API Response**: `postalCode` (camelCase via alias)

### **Pattern for Repository `_to_entity()`**:
```python
# CORRECT Pattern (from DefensiveDynamoDBService)
address_data_copy = address_data.copy()

if "postal_code" in address_data_copy:
    address_data_copy["postalCode"] = address_data_copy.pop("postal_code")
elif "zip_code" in address_data_copy:
    address_data_copy["postalCode"] = address_data_copy.pop("zip_code")
elif "zipCode" in address_data_copy:
    address_data_copy["postalCode"] = address_data_copy.pop("zipCode")

if "postalCode" not in address_data_copy:
    address_data_copy["postalCode"] = ""

address = Address(**address_data_copy)
```

### **❌ NEVER DO**:
```python
# WRONG - Don't create new normalization logic
address = Address(postal_code=address_data.get("postal_code"))
```

---

## 🔧 SERVICE REGISTRY PATTERNS

### **Adding New Service**:
```python
# 1. Create service class
class NewService(BaseService):
    async def initialize(self) -> None:
        # Initialize service
        
    async def health_check(self) -> HealthCheck:
        return HealthCheck(status="healthy", details={})

# 2. Register in ServiceRegistryManager
self.services["new_service"] = NewService()

# 3. Add endpoints to modular_api_handler.py
@app.get("/new-service/endpoint")
async def new_service_endpoint():
    service = service_manager.get_service("new_service")
    return await service.some_method()
```

### **Service Health Check Pattern**:
```python
async def health_check(self) -> HealthCheck:
    try:
        # Test service functionality
        result = await self.test_operation()
        return HealthCheck(
            status="healthy",
            details={"last_check": datetime.utcnow().isoformat()}
        )
    except Exception as e:
        return HealthCheck(
            status="unhealthy", 
            details={"error": str(e)}
        )
```

---

## 🗄️ REPOSITORY PATTERNS

### **New Repository Class**:
```python
class NewRepository(BaseRepository[EntityType]):
    def _to_entity(self, item: Dict[str, Any]) -> EntityType:
        # Handle address if present (follow postal code pattern)
        address_data = item.get("address", {})
        if address_data:
            # Use the established postal code normalization
            # (Copy pattern from UserRepository)
        
        return EntityType(**entity_data)
    
    def _to_item(self, entity: EntityType) -> Dict[str, Any]:
        # Convert entity to DynamoDB item
        return entity.model_dump()
```

### **Repository Usage Pattern**:
```python
# In service class
async def get_entity_by_email(self, email: str):
    result = await self.repository.get_by_email(email)
    if result.success and result.data:
        return result.data
    return None
```

---

## 📋 PYDANTIC MODEL PATTERNS

### **Address Model Usage**:
```python
# Creating Address (use camelCase)
address = Address(
    street="123 Main St",
    city="City",
    state="State", 
    postalCode="12345",  # ← camelCase for creation
    country="Country"
)

# Accessing Address (use snake_case)
postal_code = address.postal_code  # ← snake_case for access

# API Response (use alias)
response_data = address.model_dump(by_alias=True)  # ← camelCase in response
```

### **Model Field Patterns**:
```python
class MyModel(BaseModel):
    internal_field: str = Field(alias="externalField")
    
    # Usage:
    # Creation: MyModel(externalField="value")
    # Access: model.internal_field
    # API: model.model_dump(by_alias=True) → {"externalField": "value"}
```

---

## 🧪 TESTING PATTERNS

### **Address Field Testing**:
```python
def test_address_handling():
    # Test all postal code variants
    test_cases = [
        {"postal_code": "12345"},
        {"postalCode": "12345"}, 
        {"zip_code": "12345"},
        {"zipCode": "12345"}
    ]
    
    for case in test_cases:
        # Test normalization
        result = normalize_address(case)
        assert result["postalCode"] == "12345"
```

### **Service Registry Testing**:
```python
def test_service_registration():
    manager = ServiceRegistryManager()
    assert "service_name" in manager.get_registered_services()
    
    service = manager.get_service("service_name")
    assert service is not None
    
    health = await service.health_check()
    assert health.status == "healthy"
```

---

## 🔍 DEBUGGING PATTERNS

### **Common Error Patterns**:

#### **Postal Code Validation Error**:
```
Error: 1 validation error for Address postalCode Field required
```
**Solution**: Check field name in Address creation - use `postalCode` not `postal_code`

#### **Service Not Found Error**:
```
Error: Service 'service_name' not found in registry
```
**Solution**: Check service registration in ServiceRegistryManager

#### **Health Check Error**:
```
Error: 'HealthCheck' object has no attribute 'get'
```
**Solution**: Use HealthCheckConverter.convert_health_check()

### **Debugging Steps**:
1. **Check CloudWatch Logs**: Look for specific error patterns
2. **Test Health Endpoints**: `/health/services` for service status
3. **Verify Environment Variables**: Ensure correct table names
4. **Check Repository Patterns**: Verify `_to_entity()` implementation

---

## 📁 FILE LOCATION PATTERNS

### **Where to Put New Code**:
- **Services**: `src/services/new_service.py`
- **Repositories**: `src/repositories/new_repository.py`
- **Models**: `src/models/new_model.py`
- **Utils**: `src/utils/new_utility.py`
- **Tests**: `tests/test_new_feature.py`
- **Handlers**: Add to `src/handlers/modular_api_handler.py` (NOT versioned)

### **Files to NEVER Modify**:
- `src/handlers/versioned_api_handler.py` (DEPRECATED)
- `src/services/defensive_dynamodb_service.py` (Don't duplicate logic)

---

## ⚡ QUICK CHECKLIST

### **Before Adding New Feature**:
- [ ] Search for existing similar functionality
- [ ] Check if it fits Service Registry pattern
- [ ] Verify postal code handling needs
- [ ] Review system map for patterns
- [ ] Ensure no logic duplication

### **Before Fixing Bug**:
- [ ] Check if it's address/postal code related
- [ ] Verify which repository/service is involved
- [ ] Check existing test coverage
- [ ] Follow established patterns
- [ ] Don't create duplicate fixes

### **Before Deployment**:
- [ ] All tests pass (especially address tests)
- [ ] Service registry health checks work
- [ ] No duplicate normalization logic
- [ ] Follows established architecture
- [ ] Documentation updated

---

**Remember**: When in doubt, follow the patterns in `DefensiveDynamoDBService` and `UserRepository` for data handling, and `ServiceRegistryManager` for service architecture.
