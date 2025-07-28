# People Registry Documentation

This repository contains all documentation for the People Registry project, a comprehensive system for managing people, projects, and subscriptions.

## 📁 Documentation Structure

### 🏗️ [Architecture](./architecture/)
System architecture, design decisions, and database schema documentation.

- [Architecture Review and Cleanup](./architecture/ARCHITECTURE_REVIEW_AND_CLEANUP.md)
- [Deprecated Resources Review](./architecture/ARCHITECTURE_REVIEW_AND_DEPRECATED_RESOURCES.md)
- [Frontend Architecture Decisions](./architecture/frontend-architecture-decisions.md)
- [Database Schema Design](./architecture/database-schema-design.md)

### 🔌 [API Documentation](./api/)
API endpoints, workflows, and compatibility information.

- [API Documentation](./api/API_DOCUMENTATION.md)
- [API Endpoints Review](./api/API_ENDPOINTS_REVIEW.md)
- [API Workflow Improvements](./api/API_WORKFLOW_IMPROVEMENTS.md)
- [Frontend API Compatibility Report](./api/FRONTEND_API_COMPATIBILITY_REPORT.md)
- [API Documentation README](./api/api-docs-readme.md)

### 🎨 [Frontend Documentation](./frontend/)
Frontend-specific documentation, deployment status, and analysis.

- [Frontend Update Guide](./frontend/FRONTEND_UPDATE_GUIDE.md)
- [Deployment Status](./frontend/DEPLOYMENT_STATUS.md)
- [Static Analysis](./frontend/STATIC_ANALYSIS.md)
- [Verification Report](./frontend/VERIFICATION_REPORT.md)
- [Frontend Documentation README](./frontend/frontend-docs-readme.md)

### 🏗️ [Infrastructure](./infrastructure/)
Infrastructure setup, deployment, and AWS CDK documentation.

- [API Consolidation Progress](./infrastructure/API_CONSOLIDATION_PROGRESS.md) 🎯 **Key Document**
- [Deployment Compatibility Summary](./infrastructure/DEPLOYMENT_COMPATIBILITY_SUMMARY.md)
- [Deployment Coordination](./infrastructure/DEPLOYMENT_COORDINATION.md)
- [Execution Mode Implementation](./infrastructure/EXECUTION_MODE_IMPLEMENTATION.md)
- [Lambda Handler Updates](./infrastructure/LAMBDA_HANDLER_UPDATE.md)
- [Performance Optimization Summary](./infrastructure/PERFORMANCE_OPTIMIZATION_SUMMARY.md)
- [Infrastructure Documentation README](./infrastructure/infrastructure-docs-readme.md)

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
1. **[API Consolidation Progress](./infrastructure/API_CONSOLIDATION_PROGRESS.md)** - Current project status and achievements
2. **[Architecture Review](./architecture/ARCHITECTURE_REVIEW_AND_CLEANUP.md)** - System overview and design
3. **[API Documentation](./api/API_DOCUMENTATION.md)** - API endpoints and usage

### For Developers
1. **[Frontend Update Guide](./frontend/FRONTEND_UPDATE_GUIDE.md)** - Frontend development guide
2. **[API Workflow Improvements](./api/API_WORKFLOW_IMPROVEMENTS.md)** - API development best practices
3. **[PR Templates](./templates/)** - Standardized PR templates

### For DevOps/Infrastructure
1. **[Infrastructure Documentation](./infrastructure/)** - Complete infrastructure setup
2. **[Deployment Compatibility](./infrastructure/DEPLOYMENT_COMPATIBILITY_SUMMARY.md)** - Deployment guidelines
3. **[Performance Optimization](./infrastructure/PERFORMANCE_OPTIMIZATION_SUMMARY.md)** - Performance best practices

## 🚀 Project Status

**Current Status**: ✅ **Container-based serverless architecture successfully implemented**

### Recent Achievements
- ✅ Complete container migration for all Lambda functions
- ✅ Fixed async/await bugs in subscription creation
- ✅ Routing infrastructure working perfectly
- ✅ Modern serverless architecture with Docker containers
- ✅ Centralized documentation repository established

## 📚 Documentation Maintenance

This repository maintains synchronized copies of documentation from across the project. Key principles:

- **Single Source of Truth**: All project documentation centralized here
- **Logical Organization**: Documents organized by domain and purpose
- **Role-Based Access**: Quick navigation for different team roles
- **Maintenance Guidelines**: See [MAINTENANCE.md](./MAINTENANCE.md) for standards

## 📞 Support

For questions about this documentation or the People Registry project, please refer to the relevant section above or check the troubleshooting guides.

---

**Last Updated**: July 28, 2025  
**Documentation Version**: 2.0  
**Project**: People Registry - AWS User Group Cochabamba