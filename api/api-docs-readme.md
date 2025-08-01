# Registry API Documentation

This directory contains comprehensive documentation for the registry-api repository, including deployment workflows, testing strategies, and implementation guides.

## 📁 Documentation Structure

```
api/
├── api-docs-readme.md                  # This file - Documentation overview
├── API_DOCUMENTATION.md               # Complete API reference
├── AUTHENTICATION_SYSTEM.md           # 🔐 JWT authentication guide
├── API_WORKFLOW_IMPROVEMENTS.md       # Deployment workflow improvements
├── API_ENDPOINTS_REVIEW.md            # Endpoint analysis and review
├── ENHANCED_SUBSCRIPTION_WORKFLOW.md  # Subscription system documentation
└── FRONTEND_API_COMPATIBILITY_REPORT.md # Frontend integration guide
```

### 🔐 Authentication Documentation

The API now includes a complete JWT-based authentication system:

- **[AUTHENTICATION_SYSTEM.md](./AUTHENTICATION_SYSTEM.md)** - Complete authentication guide
  - Authentication endpoints (`/auth/login`, `/auth/me`, `/auth/logout`)
  - Admin user setup and management
  - JWT token handling and security
  - Frontend integration examples
  - Troubleshooting guide

- **[API_DOCUMENTATION.md](./API_DOCUMENTATION.md)** - Updated with auth endpoints
  - Authentication flow documentation
  - Admin credentials and setup
  - Protected endpoint usage

## 🎯 Quick Start

1. **New to the project?** Start with [API_DOCUMENTATION.md](./API_DOCUMENTATION.md)
2. **Setting up authentication?** See [AUTHENTICATION_SYSTEM.md](./AUTHENTICATION_SYSTEM.md)
3. **Implementing features?** Check [API_ENDPOINTS_REVIEW.md](./API_ENDPOINTS_REVIEW.md)
4. **Deploying changes?** See [API_WORKFLOW_IMPROVEMENTS.md](./API_WORKFLOW_IMPROVEMENTS.md)
5. **Frontend integration?** Use [FRONTEND_API_COMPATIBILITY_REPORT.md](./FRONTEND_API_COMPATIBILITY_REPORT.md)

### 🔐 Authentication Quick Start

To get started with the authentication system:

1. **Admin Login**: Use `admin@awsugcbba.org` / `admin123`
2. **Get Token**: POST to `/auth/login` with credentials
3. **Use Token**: Include `Authorization: Bearer <token>` in requests
4. **Test Access**: Try `/auth/me` to verify authentication

See [AUTHENTICATION_SYSTEM.md](./AUTHENTICATION_SYSTEM.md) for complete details.

## 🔗 Related Documentation

- **Registry-Infrastructure**: `../registry-infrastructure/docs/` - Infrastructure and coordination
- **Registry-Frontend**: `../registry-frontend/docs/` - Frontend integration
- **Specifications**: `../.kiro/specs/person-crud-completion/` - Feature specifications

## 📊 Documentation Maintenance

This documentation is maintained alongside the codebase. When making changes:

1. Update relevant documentation files
2. Verify all links and references
3. Update the last modified date
4. Test any code examples or procedures

**Last Updated**: August 1, 2025 - Added comprehensive authentication system documentation