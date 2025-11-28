# Preventing Async/Sync Issues - Developer Guide

**Purpose:** Prevent future async/sync architectural issues  
**Audience:** Development Team  
**Last Updated:** September 6, 2025  

## 🎯 **QUICK REFERENCE**

### **Golden Rules:**
1. **Services:** Always async methods
2. **Repositories:** Always sync methods  
3. **Tests:** Match the pattern you're testing
4. **Validation:** Pipeline-first, local-second

### **Common Patterns:**
```python
# ✅ Service (async)
class SomeService:
    async def method(self):
        return self.repository.sync_method()  # No await on sync

# ✅ Repository (sync)  
class SomeRepository:
    def method(self):
        return db.query()  # Always sync

# ✅ Test (match target)
def test_repository_method(self):  # Sync test for sync method
    result = repository.method()   # No await

async def test_service_method(self):  # Async test for async method
    result = await service.method()   # With await
```

---

## 🚨 **DANGER PATTERNS TO AVOID**

### **❌ Missing Await on Async Methods**
```python
# WRONG - Will create coroutine object
user_roles = self.get_user_roles(user_id)  # Missing await

# RIGHT - Properly awaited
user_roles = await self.get_user_roles(user_id)
```

### **❌ Await on Sync Methods**
```python
# WRONG - TypeError: object can't be used in 'await' expression  
result = await repository.create(data)  # Repository is sync

# RIGHT - No await for sync methods
result = repository.create(data)
```

### **❌ Mixed Patterns in Same Class**
```python
# WRONG - Inconsistent patterns
class BadService:
    async def method1(self):  # async
    def method2(self):        # sync - inconsistent!
```

### **❌ Test Pattern Mismatch**
```python
# WRONG - Async test for sync method
async def test_sync_method(self):
    await sync_method()  # Will fail

# RIGHT - Sync test for sync method  
def test_sync_method(self):
    sync_method()
```

---

## 🔍 **DETECTION CHECKLIST**

### **Before Committing:**
- [ ] All service methods are async
- [ ] All repository methods are sync
- [ ] Async methods called with `await`
- [ ] Sync methods called without `await`
- [ ] Test patterns match target code
- [ ] No "coroutine" objects in responses

### **Code Review Checklist:**
- [ ] Consistent async/sync patterns
- [ ] Proper await usage
- [ ] Test coverage for changes
- [ ] Cross-service impact assessed
- [ ] Pipeline validation passed

---

## 🛠️ **VALIDATION TOOLS**

### **1. Manual Validation**
```bash
# Check for missing awaits
grep -r "= self\." src/services/ | grep -v "await"

# Check for incorrect awaits  
grep -r "await.*\." tests/ | grep "repository\|repo"

# Find async methods
grep -r "async def" src/services/
```

### **2. Automated Validation**
```python
# Quick async/sync checker
def validate_file(file_path):
    with open(file_path) as f:
        content = f.read()
    
    # Find async methods
    async_methods = re.findall(r'async def (\w+)', content)
    
    # Check for missing awaits
    for method in async_methods:
        if f'self.{method}(' in content and f'await self.{method}(' not in content:
            print(f"⚠️  Missing await on {method}")
```

### **3. Pipeline Validation**
- Always run full test suite
- Check for "coroutine" errors in logs
- Validate cross-service interactions
- Monitor for async/sync warnings

---

## 📋 **STEP-BY-STEP FIX PROCESS**

### **When You Find Async/Sync Issues:**

**Step 1: Identify the Pattern**
```python
# Is it a service or repository?
# Services should be async, repositories should be sync
```

**Step 2: Check Method Definitions**
```python
# Service methods should be:
async def method_name(self):

# Repository methods should be:  
def method_name(self):
```

**Step 3: Fix Method Calls**
```python
# Service calling async method:
result = await self.other_async_method()

# Service calling sync repository:
result = self.repository.sync_method()  # No await
```

**Step 4: Update Tests**
```python
# Test async service method:
async def test_service_method(self):
    result = await service.method()

# Test sync repository method:
def test_repository_method(self):
    result = repository.method()
```

**Step 5: Validate**
```bash
# Run tests locally
pytest tests/

# Check for coroutine errors
pytest tests/ 2>&1 | grep -i coroutine

# Run pipeline validation
git push  # Let pipeline catch what local missed
```

---

## 🎯 **ARCHITECTURAL GUIDELINES**

### **Service Layer (Always Async)**
```python
class SomeService(BaseService):
    def __init__(self, repository):
        self.repository = repository  # Inject sync repository
    
    async def create_item(self, data):
        # Business logic (async)
        processed_data = await self.process_data(data)
        
        # Repository call (sync - no await)
        return self.repository.create(processed_data)
    
    async def process_data(self, data):
        # Internal async method
        return processed_data
```

### **Repository Layer (Always Sync)**
```python
class SomeRepository(BaseRepository):
    def __init__(self):
        self.db = get_database_client()  # Sync client
    
    def create(self, data):
        # Database operation (sync)
        return self.db.put_item(data)
    
    def get_by_id(self, item_id):
        # Database query (sync)
        return self.db.get_item(item_id)
```

### **Test Layer (Match Target)**
```python
class TestSomeService:
    async def test_create_item(self):  # Async test for async service
        service = SomeService(mock_repository)
        result = await service.create_item(data)  # Await async method
        assert result is not None

class TestSomeRepository:
    def test_create(self):  # Sync test for sync repository
        repository = SomeRepository()
        result = repository.create(data)  # No await for sync method
        assert result is not None
```

---

## 🚀 **BEST PRACTICES**

### **1. Consistency First**
- Pick a pattern and stick to it
- Services = async, Repositories = sync
- Don't mix patterns within same layer

### **2. Clear Boundaries**
- Service layer handles async operations
- Repository layer handles sync database operations
- Clear separation of concerns

### **3. Proper Testing**
- Test patterns match implementation patterns
- Include integration tests for cross-service calls
- Validate async/sync boundaries

### **4. Validation Early**
- Check locally before committing
- Use pipeline as authoritative validation
- Fix issues immediately when found

### **5. Documentation**
- Document async/sync decisions
- Update guides when patterns change
- Share lessons learned with team

---

## 💡 **TROUBLESHOOTING**

### **Common Error Messages:**

**"'coroutine' object is not iterable"**
- **Cause:** Async method called without `await`
- **Fix:** Add `await` to the method call

**"object can't be used in 'await' expression"**
- **Cause:** Sync method called with `await`
- **Fix:** Remove `await` from the method call

**"RuntimeWarning: coroutine was never awaited"**
- **Cause:** Async method called but result not awaited
- **Fix:** Add `await` or make method sync

### **Quick Fixes:**
```python
# Error: 'coroutine' object is not iterable
user_roles = self.get_user_roles(user_id)  # Missing await
# Fix:
user_roles = await self.get_user_roles(user_id)

# Error: object can't be used in 'await' expression  
result = await repository.create(data)  # Incorrect await
# Fix:
result = repository.create(data)
```

---

**Remember:** When in doubt, follow the pipeline validation - it catches what local testing misses!
