# People Registry Documentation

This repository contains all documentation for the People Registry project, a comprehensive system for managing people, projects, and subscriptions with Service Registry architecture.

## 📁 Documentation Structure

### 🏗️ [Architecture](./architecture/)
System architecture, design decisions, and Service Registry implementation.

- **[Service Registry Cleanup Plan](./architecture/SERVICE_REGISTRY_CLEANUP_PLAN.md)** 🎯 **NEW - Key Implementation Plan**
- [Architecture Review and Cleanup](./architecture/ARCHITECTURE_REVIEW_AND_CLEANUP.md)
- [Deprecated Resources Review](./architecture/ARCHITECTURE_REVIEW_AND_DEPRECATED_RESOURCES.md)
- [Frontend Architecture Decisions](./architecture/frontend-architecture-decisions.md)
- [Database Schema Design](./architecture/database-schema-design.md)

### 🔌 [API Documentation](./api/)
API endpoints, workflows, and Service Registry integration.

- [API Documentation](./api/API_DOCUMENTATION.md)
- [API Endpoints Review](./api/API_ENDPOINTS_REVIEW.md)
- [API Workflow Improvements](./api/API_WORKFLOW_IMPROVEMENTS.md)
- [Frontend API Compatibility Report](./api/FRONTEND_API_COMPATIBILITY_REPORT.md)
- [Scripts Documentation](./api/scripts-readme.md)

### 🎨 [Frontend Documentation](./frontend/)
Frontend-specific documentation and integration with Service Registry.

- [Frontend README](./frontend/README.md)
- [Frontend Documentation](./frontend/DOCUMENTATION.md)
- [Frontend Update Guide](./frontend/FRONTEND_UPDATE_GUIDE.md)
- [Deployment Status](./frontend/DEPLOYMENT_STATUS.md)
- [Static Analysis](./frontend/STATIC_ANALYSIS.md)
- [Verification Report](./frontend/VERIFICATION_REPORT.md)

### 🏗️ [Infrastructure](./infrastructure/)
Infrastructure setup, deployment, and Service Registry deployment.

- **[CodeCatalyst Cleanup Strategy](./infrastructure/CODECATALYST_CLEANUP_STRATEGY.md)** 🎯 **Key Document**
- **[Cleanup Quick Reference](./infrastructure/CLEANUP_QUICK_REFERENCE.md)** 🎯 **Key Document**
- [API Consolidation Progress](./infrastructure/API_CONSOLIDATION_PROGRESS.md)
- [Deployment Compatibility Summary](./infrastructure/DEPLOYMENT_COMPATIBILITY_SUMMARY.md)
- [Deployment Coordination](./infrastructure/DEPLOYMENT_COORDINATION.md)
- [Execution Mode Implementation](./infrastructure/EXECUTION_MODE_IMPLEMENTATION.md)
- [Lambda Handler Updates](./infrastructure/LAMBDA_HANDLER_UPDATE.md)
- [Performance Optimization Summary](./infrastructure/PERFORMANCE_OPTIMIZATION_SUMMARY.md)

### 🧪 [Testing Documentation](./testing/)
Testing strategies for Service Registry architecture.

- [Infrastructure Tests](./testing/infrastructure-tests.md)
- [Infrastructure Task 18](./testing/infrastructure-task18.md)
- [API Versioned Tests](./testing/api-versioned-tests.md)
- [API Task 18](./testing/api-task18.md)

### 🔄 [CodeCatalyst Documentation](./codecatalyst/)
CI/CD workflows and Service Registry deployment.

- [Frontend CodeCatalyst](./codecatalyst/frontend-codecatalyst.md)
- [API CodeCatalyst](./codecatalyst/api-codecatalyst.md)
- [Workflow Reference](./codecatalyst/workflow-reference.md)
- [Pipeline Knowledge](./codecatalyst/pipeline-knowledge.md)

### ⚙️ [Workflows](./workflows/)
CI/CD workflows, PR validation, and automation documentation.

- [Workflow Issues Analysis](./workflows/WORKFLOW_ISSUES_ANALYSIS.md)
- [Flake8 Improvements](./workflows/FLAKE8_IMPROVEMENTS.md)
- [PR Validation Process](./workflows/pr-validation-process.md)
- [API Workflows README](./workflows/api-workflows-readme.md)
- [Workflows README](./workflows/workflows-readme.md)

### 📋 [Specifications](./specs/)
Detailed specifications and requirements for various features.

- [Person CRUD Completion](./specs/person-crud-completion/)
- [PR Validation Workflow](./specs/pr-validation-workflow/)
- [Registry API Pipeline Simplification](./specs/registry-api-pipeline-simplification/)

### 🔧 [Troubleshooting](./troubleshooting/)
Issue analysis, debugging guides, and compatibility reports.

- [Compatibility Status](./troubleshooting/COMPATIBILITY_STATUS.md)
- [Frontend Deployment Issues Analysis](./troubleshooting/FRONTEND_DEPLOYMENT_ISSUES_ANALYSIS.md)
- [Test Fixes Summary](./troubleshooting/TEST_FIXES_SUMMARY.md)

### 📝 [Templates](./templates/)
PR templates and other standardized templates.

- [API PR Template (Detailed)](./templates/api-pr-template-detailed.md)
- [Frontend PR Template (Detailed)](./templates/frontend-pr-template-detailed.md)
- [Infrastructure PR Template (Detailed)](./templates/infrastructure-pr-template-detailed.md)

### 📊 [Implementation Summaries](./implementation-summaries/)
Detailed summaries of completed tasks and implementations.

- [Overall Implementation Summary](./implementation-summaries/IMPLEMENTATION_SUMMARY.md)

## 🎯 Key Documents

### For New Contributors
1. **[Service Registry Cleanup Plan](./architecture/SERVICE_REGISTRY_CLEANUP_PLAN.md)** 🆕 - **CRITICAL: Complete refactoring roadmap**
2. **[API Consolidation Progress](./infrastructure/API_CONSOLIDATION_PROGRESS.md)** - Current project status and achievements
3. **[Architecture Review](./architecture/ARCHITECTURE_REVIEW_AND_CLEANUP.md)** - System overview and design
4. **[API Documentation](./api/API_DOCUMENTATION.md)** - API endpoints and usage

### For Developers
1. **[Service Registry Cleanup Plan](./architecture/SERVICE_REGISTRY_CLEANUP_PLAN.md)** 🆕 - **Implementation guide**
2. **[Frontend Update Guide](./frontend/FRONTEND_UPDATE_GUIDE.md)** - Frontend development guide
3. **[API Workflow Improvements](./api/API_WORKFLOW_IMPROVEMENTS.md)** - API development best practices
4. **[PR Templates](./templates/)** - Standardized PR templates

### For DevOps/Infrastructure
1. **[CodeCatalyst Cleanup Strategy](./infrastructure/CODECATALYST_CLEANUP_STRATEGY.md)** 🆕 - **Infrastructure cleanup**
2. **[Infrastructure Documentation](./infrastructure/)** - Complete infrastructure setup
3. **[Deployment Compatibility](./infrastructure/DEPLOYMENT_COMPATIBILITY_SUMMARY.md)** - Deployment guidelines
4. **[Performance Optimization](./infrastructure/PERFORMANCE_OPTIMIZATION_SUMMARY.md)** - Performance best practices

## 🚀 Project Status

**Current Status**: 🔄 **Implementing Service Registry Pattern**

### Current Phase: Service Registry Implementation
- ✅ **Phase 1**: Core Service Registry Infrastructure (IN PROGRESS)
  - ✅ Base service interfaces created
  - ✅ Service registry container implemented
  - ✅ Unified configuration management
  - 🔄 Domain services implementation
- 🔄 **Phase 2**: Service Consolidation (NEXT)
- 🔄 **Phase 3**: Data Access Layer (PLANNED)
- 🔄 **Phase 4**: API Layer Cleanup (PLANNED)

### Recent Achievements
- ✅ Complete container migration for all Lambda functions
- ✅ Fixed async/await bugs in subscription creation
- ✅ Routing infrastructure working perfectly
- ✅ Modern serverless architecture with Docker containers
- ✅ Centralized documentation repository established
- ✅ **Service Registry architecture planning completed**
- ✅ **Documentation consolidation completed**

### Architecture Migration
- **From**: Multiple duplicate handlers, inconsistent patterns
- **To**: Service Registry pattern with dependency injection
- **Benefits**: 50% code reduction, consistent patterns, easy testing

## 📚 Documentation Maintenance

This repository maintains synchronized copies of documentation from across the project. Key principles:

- **Single Source of Truth**: All project documentation centralized here
- **Logical Organization**: Documents organized by domain and purpose
- **Role-Based Access**: Quick navigation for different team roles
- **Service Registry Focus**: Architecture documentation prioritized
- **Maintenance Guidelines**: See [MAINTENANCE.md](./MAINTENANCE.md) for standards

## 🔗 Repository Links

- **API**: `registry-api/` - FastAPI backend with Service Registry pattern
- **Frontend**: `registry-frontend/` - Astro frontend application  
- **Infrastructure**: `registry-infrastructure/` - AWS CDK infrastructure
- **Documentation**: `registry-documentation/` - This repository (centralized docs)

## 📞 Support

For questions about this documentation or the People Registry project, please refer to the relevant section above or check the troubleshooting guides.

---

**Last Updated**: August 11, 2025  
**Documentation Version**: 3.0 - Service Registry Edition  
**Project**: People Registry - AWS User Group Cochabamba