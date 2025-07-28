# Frontend Update Guide

## Quick Fixes for Immediate Compatibility

### 1. Update API Service (registry-frontend/src/services/api.ts)

```typescript
// Replace the getAllPeople method:
async getAllPeople(): Promise<Person[]> {
  const response = await fetch(`${API_BASE_URL}/people`);
  const data = await handleApiResponse(response);
  
  // Handle new response format
  if (Array.isArray(data)) {
    return data; // Old format (backward compatibility)
  } else if (data.people) {
    return data.people; // New format
  } else {
    throw new Error('Unexpected response format');
  }
}

// Update createPerson to handle 200 status:
async createPerson(person: PersonCreate): Promise<Person> {
  const response = await fetch(`${API_BASE_URL}/people`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(person),
  });
  
  // Accept both 200 and 201 status codes
  if (response.status !== 200 && response.status !== 201) {
    throw new ApiError(response.status, 'Error creating person');
  }
  
  return handleApiResponse(response);
}
```

### 2. Add Basic Error Handling for Authentication

```typescript
// Update handleApiResponse in registry-frontend/src/types/api.ts
export async function handleApiResponse(response: Response): Promise<any> {
  if (!response.ok) {
    let errorMessage: string;
    try {
      const errorData = await response.json();
      errorMessage = errorData.message || errorData.error || response.statusText;
    } catch {
      errorMessage = response.statusText;
    }
    
    // Handle authentication errors
    if (response.status === 401) {
      // Redirect to login or show auth error
      console.warn('Authentication required - implement login flow');
      errorMessage = 'Authentication required';
    }
    
    throw new ApiError(response.status, errorMessage);
  }

  try {
    return await response.json();
  } catch {
    throw new ApiError(500, 'Invalid JSON response');
  }
}
```

### 3. Temporary Authentication Bypass (Development Only)

For immediate testing, you can temporarily bypass authentication by:

1. Using the legacy endpoint (if implemented): `/people/legacy`
2. Or implementing a mock authentication token

```typescript
// Temporary mock auth (REMOVE IN PRODUCTION)
const MOCK_AUTH_TOKEN = 'mock-token-for-development';

export const peopleApi = {
  async getAllPeople(): Promise<Person[]> {
    const response = await fetch(`${API_BASE_URL}/people`, {
      headers: {
        'Authorization': `Bearer ${MOCK_AUTH_TOKEN}`,
        'Content-Type': 'application/json',
      }
    });
    // ... rest of the code
  }
}
```

## Next Steps

1. **Immediate**: Apply the quick fixes above
2. **Short-term**: Implement proper authentication system
3. **Long-term**: Update all components to handle new API features

## Testing

After applying fixes, test with:
```bash
node api-frontend-compatibility-test.js
```

The test should show improved compatibility scores.
