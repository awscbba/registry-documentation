# Frontend Architecture Improvements

**Date**: December 3, 2025  
**Status**: Proposed Improvements  
**Priority**: High

## Executive Summary

This document outlines architectural issues in the current frontend implementation and provides concrete solutions following Clean Architecture principles, SOLID design patterns, and modern UI/UX best practices.

---

## Current Architecture Analysis

### ✅ **What's Good:**

1. **Folder Structure** - Proper separation with `domain/`, `infrastructure/`, `presentation/`
2. **Service Layer** - Centralized services for API calls (`authService`, `projectApi`)
3. **Component Organization** - Components separated from pages
4. **TypeScript** - Type safety throughout the application

### ❌ **Critical Issues:**

#### 1. **Ad-Hoc Event-Driven Communication**
**Problem:**
```typescript
// Current implementation in UserLoginModal.tsx
window.dispatchEvent(new Event('authStateChanged'));

// Current implementation in UserMenu.tsx
window.addEventListener('authStateChanged', handleAuthChange);
```

**Issues:**
- Tight coupling between components
- No type safety for events
- Hard to test
- No centralized state management
- Violates Dependency Inversion Principle

**Impact:** Components are tightly coupled, making testing and maintenance difficult.

---

#### 2. **Components Have Too Many Responsibilities**
**Problem:**
```typescript
// ProjectShowcase.tsx does everything:
export default function ProjectShowcase() {
  // 1. State management
  const [projects, setProjects] = useState<Project[]>([]);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  
  // 2. Routing logic
  const urlParams = new URLSearchParams(window.location.search);
  
  // 3. Data fetching
  const loadActiveProjects = async () => { /* ... */ };
  
  // 4. Authentication logic
  const handleLoginSuccess = () => { /* ... */ };
  
  // 5. UI rendering
  return <div>...</div>;
}
```

**Issues:**
- Violates Single Responsibility Principle
- Hard to test individual concerns
- Difficult to reuse logic
- Component becomes a "God Object"

**Impact:** Maintenance nightmare, difficult to test, hard to extend.

---

#### 3. **No Separation of Presentation and Business Logic**
**Problem:**
```typescript
// Components directly call services
const result = await authService.login(formData);
```

**Issues:**
- Business logic mixed with UI
- Hard to test UI without services
- Can't swap implementations easily
- Violates Clean Architecture boundaries

**Impact:** Tight coupling, difficult to test, hard to maintain.

---

#### 4. **No Centralized State Management**
**Problem:**
- Each component manages its own auth state
- State duplication across components
- No single source of truth
- Race conditions possible

**Impact:** Inconsistent UI state, bugs, poor user experience.

---

#### 5. **Missing Error Boundaries**
**Problem:**
- No error boundaries implemented
- Component errors crash the entire app
- No graceful degradation

**Impact:** Poor user experience, entire app crashes on component errors.

---

#### 6. **Accessibility Issues**
**Problem:**
- Missing ARIA labels
- No keyboard navigation strategy
- Poor focus management after modal closes
- No screen reader support

**Impact:** Excludes users with disabilities, fails WCAG compliance.

---

## Proposed Solutions

### 1. **Implement React Context for Auth State**

**File:** `registry-frontend/src/contexts/AuthContext.tsx`

```typescript
import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { authService, type User } from '../services/authService';

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (credentials: { email: string; password: string }) => Promise<{ success: boolean; message?: string }>;
  logout: () => void;
  refreshUser: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const refreshUser = () => {
    const currentUser = authService.getCurrentUser();
    setUser(currentUser);
  };

  useEffect(() => {
    refreshUser();
    setIsLoading(false);
  }, []);

  const login = async (credentials: { email: string; password: string }) => {
    const result = await authService.login(credentials);
    if (result.success) {
      refreshUser();
    }
    return result;
  };

  const logout = () => {
    authService.logout();
    setUser(null);
  };

  const value = {
    user,
    isAuthenticated: !!user,
    isLoading,
    login,
    logout,
    refreshUser,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
```

**Benefits:**
- ✅ Single source of truth for auth state
- ✅ Type-safe API
- ✅ Easy to test
- ✅ No tight coupling
- ✅ Follows React best practices

**Usage:**
```typescript
// In components
const { user, isAuthenticated, login, logout } = useAuth();
```

---

### 2. **Create Custom Hooks (Separation of Concerns)**

**File:** `registry-frontend/src/hooks/useLoginModal.ts`

```typescript
import { useState, useEffect } from 'react';

/**
 * Custom hook to manage login modal state
 * Handles URL parameters and modal visibility
 */
export function useLoginModal() {
  const [isOpen, setIsOpen] = useState(false);

  useEffect(() => {
    // Check if we should auto-open login modal (from /login redirect)
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('login') === 'true') {
      setIsOpen(true);
      // Clean up URL parameter
      window.history.replaceState({}, '', window.location.pathname);
    }
  }, []);

  const open = () => setIsOpen(true);
  const close = () => setIsOpen(false);

  return { isOpen, open, close };
}
```

**Benefits:**
- ✅ Reusable logic
- ✅ Easy to test
- ✅ Single Responsibility
- ✅ Clean component code

---

### 3. **Implement Toast Notification System**

**File:** `registry-frontend/src/contexts/ToastContext.tsx`

```typescript
import { createContext, useContext, useState, ReactNode } from 'react';

type ToastType = 'success' | 'error' | 'info' | 'warning';

interface Toast {
  id: string;
  message: string;
  type: ToastType;
}

interface ToastContextType {
  toasts: Toast[];
  showToast: (message: string, type?: ToastType) => void;
  removeToast: (id: string) => void;
}

const ToastContext = createContext<ToastContextType | undefined>(undefined);

export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<Toast[]>([]);

  const showToast = (message: string, type: ToastType = 'info') => {
    const id = Math.random().toString(36).substr(2, 9);
    const toast: Toast = { id, message, type };
    
    setToasts((prev) => [...prev, toast]);

    // Auto-remove after 5 seconds
    setTimeout(() => {
      removeToast(id);
    }, 5000);
  };

  const removeToast = (id: string) => {
    setToasts((prev) => prev.filter((toast) => toast.id !== id));
  };

  return (
    <ToastContext.Provider value={{ toasts, showToast, removeToast }}>
      {children}
      <ToastContainer toasts={toasts} onRemove={removeToast} />
    </ToastContext.Provider>
  );
}

export function useToast() {
  const context = useContext(ToastContext);
  if (context === undefined) {
    throw new Error('useToast must be used within a ToastProvider');
  }
  return context;
}
```

**Benefits:**
- ✅ Consistent user feedback
- ✅ Better UX
- ✅ Centralized notification system
- ✅ Auto-dismiss functionality

---

### 4. **Add Error Boundaries**

**File:** `registry-frontend/src/components/ErrorBoundary.tsx`

```typescript
import { Component, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error?: Error;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: any) {
    console.error('Error caught by boundary:', error, errorInfo);
    // TODO: Send to error tracking service (Sentry, etc.)
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div style={{ padding: '2rem', textAlign: 'center' }}>
          <h2>Algo salió mal</h2>
          <p>Por favor, recarga la página o contacta al soporte.</p>
          <button onClick={() => window.location.reload()}>
            Recargar Página
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}
```

**Usage:**
```typescript
<ErrorBoundary>
  <App />
</ErrorBoundary>
```

---

### 5. **Improve Accessibility**

**Checklist:**

- [ ] Add ARIA labels to all interactive elements
- [ ] Implement keyboard navigation (Tab, Enter, Escape)
- [ ] Manage focus after modal opens/closes
- [ ] Add screen reader announcements
- [ ] Ensure color contrast meets WCAG AA standards
- [ ] Add skip navigation links
- [ ] Test with screen readers (NVDA, JAWS, VoiceOver)

**Example - Accessible Modal:**
```typescript
<div
  role="dialog"
  aria-modal="true"
  aria-labelledby="modal-title"
  aria-describedby="modal-description"
>
  <h2 id="modal-title">Iniciar Sesión</h2>
  <p id="modal-description">Ingresa tus credenciales para acceder</p>
  {/* Form content */}
</div>
```

---

## Implementation Roadmap

### Phase 1: Foundation (Week 1)
- [ ] Implement AuthContext
- [ ] Create custom hooks (useLoginModal, useAuth)
- [ ] Add Error Boundaries
- [ ] Update Layout to use providers

### Phase 2: Refactoring (Week 2)
- [ ] Refactor UserMenu to use AuthContext
- [ ] Refactor UserLoginModal to use AuthContext
- [ ] Refactor ProjectShowcase to use custom hooks
- [ ] Remove window event listeners

### Phase 3: UX Improvements (Week 3)
- [ ] Implement Toast notification system
- [ ] Add loading states
- [ ] Add skeleton screens
- [ ] Improve error messages

### Phase 4: Accessibility (Week 4)
- [ ] Add ARIA labels
- [ ] Implement keyboard navigation
- [ ] Add focus management
- [ ] Test with screen readers
- [ ] Fix color contrast issues

### Phase 5: Testing (Week 5)
- [ ] Write unit tests for hooks
- [ ] Write integration tests for auth flow
- [ ] Write E2E tests for critical paths
- [ ] Add accessibility tests

---

## Architecture Principles to Follow

### 1. **Clean Architecture Layers**

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│  (Components, Pages, Hooks)         │
├─────────────────────────────────────┤
│         Application Layer           │
│  (Contexts, State Management)       │
├─────────────────────────────────────┤
│         Domain Layer                │
│  (Business Logic, Entities)         │
├─────────────────────────────────────┤
│         Infrastructure Layer        │
│  (API Clients, Services)            │
└─────────────────────────────────────┘
```

**Rules:**
- Outer layers depend on inner layers
- Inner layers never depend on outer layers
- Business logic is independent of frameworks

---

### 2. **SOLID Principles**

#### **S - Single Responsibility**
Each component/hook/service should have ONE reason to change.

❌ **Bad:**
```typescript
// Component does auth, routing, data fetching, and UI
function ProjectShowcase() { /* ... */ }
```

✅ **Good:**
```typescript
// Separate concerns
function useProjects() { /* data fetching */ }
function useLoginModal() { /* modal state */ }
function ProjectShowcase() { /* UI only */ }
```

#### **O - Open/Closed**
Open for extension, closed for modification.

✅ **Good:**
```typescript
// Can add new toast types without modifying existing code
type ToastType = 'success' | 'error' | 'info' | 'warning';
```

#### **L - Liskov Substitution**
Subtypes must be substitutable for their base types.

#### **I - Interface Segregation**
Clients shouldn't depend on interfaces they don't use.

#### **D - Dependency Inversion**
Depend on abstractions, not concretions.

✅ **Good:**
```typescript
// Component depends on abstraction (useAuth hook)
const { user, login } = useAuth();
// Not on concrete implementation (authService)
```

---

### 3. **React Best Practices**

1. **Use Composition Over Inheritance**
2. **Keep Components Small** (< 200 lines)
3. **Extract Custom Hooks** for reusable logic
4. **Use Context Sparingly** (only for truly global state)
5. **Memoize Expensive Computations** (useMemo, useCallback)
6. **Avoid Prop Drilling** (use Context or composition)

---

## UI/UX Best Practices

### 1. **Loading States**
Always show feedback during async operations:
- Spinners for short operations (< 2s)
- Skeleton screens for longer operations
- Progress bars for multi-step processes

### 2. **Error Handling**
- Show user-friendly error messages
- Provide actionable next steps
- Log technical details for debugging
- Never show raw error messages to users

### 3. **Feedback**
- Immediate feedback for user actions
- Toast notifications for background operations
- Success confirmations for important actions
- Undo functionality where appropriate

### 4. **Accessibility**
- Keyboard navigation for all interactive elements
- Screen reader support
- High contrast mode support
- Focus indicators
- ARIA labels and descriptions

### 5. **Performance**
- Code splitting for large components
- Lazy loading for routes
- Image optimization
- Minimize bundle size
- Use React.memo for expensive components

---

## Metrics for Success

### Code Quality
- [ ] Test coverage > 80%
- [ ] No ESLint errors
- [ ] TypeScript strict mode enabled
- [ ] Bundle size < 500KB (gzipped)

### Performance
- [ ] First Contentful Paint < 1.5s
- [ ] Time to Interactive < 3s
- [ ] Lighthouse score > 90

### Accessibility
- [ ] WCAG 2.1 AA compliance
- [ ] Keyboard navigation works
- [ ] Screen reader compatible
- [ ] Color contrast ratio > 4.5:1

### User Experience
- [ ] All actions have feedback
- [ ] Error messages are helpful
- [ ] Loading states are clear
- [ ] No layout shifts (CLS < 0.1)

---

## References

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [React Context Best Practices](https://kentcdodds.com/blog/how-to-use-react-context-effectively)
- [SOLID Principles in React](https://konstantinlebedev.com/solid-in-react/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [React Hooks Best Practices](https://react.dev/reference/react)

---

## Conclusion

The current implementation works but has significant architectural debt. By following the proposed improvements, we can achieve:

1. **Better Maintainability** - Easier to understand and modify
2. **Improved Testability** - Isolated concerns are easier to test
3. **Enhanced UX** - Better feedback and error handling
4. **Accessibility** - Inclusive for all users
5. **Scalability** - Easier to add new features

**Next Steps:** Review this document with the team and prioritize implementation phases.

---

**Document Version:** 1.0  
**Last Updated:** December 3, 2025  
**Author:** Development Team  
**Status:** Awaiting Review
