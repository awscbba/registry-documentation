# AI Assistant Guidelines for Repository Operations

## 🚫 NEVER DO THESE ACTIONS

### Absolutely Forbidden:
1. **NEVER push directly to main branch**
2. **NEVER merge to main without explicit permission**
3. **NEVER create production deployments**
4. **NEVER modify CI/CD pipeline configurations**
5. **NEVER delete branches without confirmation**
6. **NEVER force push (git push --force)**
7. **NEVER touch the root folder** - Do not create, update, or modify any files or directories in the project root. Only work within repository directories: `registry-api/`, `registry-frontend/`, `registry-infrastructure/`, `registry-documentation/`

## ✅ ALWAYS DO THESE ACTIONS

### Required Workflow:
1. **Always work on feature branches**
2. **Always ask before creating new branches**
3. **Always explain what changes will be made**
4. **Always confirm before pushing any code**
5. **Always follow the established naming conventions**

### Implementation Principles:
6. **Check for existing implementations first** - Before implementing any feature, search the codebase to identify if similar functionality already exists. Integrate with or enhance existing systems rather than creating duplicates.
7. **Test-Driven Development approach** - Create tests to identify potential issues with features. When possible, write tests first, then implement the logic that satisfies the test requirements.

## Branch Naming Convention

```
feature/description-of-feature
fix/description-of-fix
hotfix/critical-issue-description
docs/documentation-update
refactor/code-improvement
```

## Required Confirmation Process

### Before Any Git Operation:
```
🔍 CONFIRMATION REQUIRED:
- Action: [describe what will be done]
- Branch: [target branch name]
- Impact: [what this affects]
- Reversible: [yes/no and how]

Proceed? (explicit yes required)
```

### Before Any AWS Operations:
```
🔍 AWS OPERATION CONFIRMATION:
- Service: [AWS service being modified]
- Environment: [dev/staging/prod]
- Resources: [what will be created/modified/deleted]
- Cost Impact: [estimated cost change]
- Rollback Plan: [how to undo if needed]

Proceed? (explicit yes required)
```

## Emergency Procedures

### If Mistake is Made:
1. **STOP immediately**
2. **Assess the damage**
3. **Document what happened**
4. **Create rollback plan**
5. **Execute rollback if safe**
6. **Report to user immediately**

### Rollback Commands:
```bash
# If pushed to main accidentally
git revert <commit-hash>
git push origin main

# If branch was created accidentally
git push origin --delete <branch-name>
git branch -d <branch-name>

# If merge was done locally but not pushed
git reset --hard HEAD~1
```

## Communication Protocol

### Always Use This Format:
```
🎯 PROPOSED ACTION:
What: [clear description]
Where: [repository/branch/service]
Why: [reason for the action]
Risk: [low/medium/high and explanation]
Alternatives: [other options considered]

⚠️ CONFIRMATION NEEDED: Please explicitly approve before I proceed.
```

## File Organization Principles

### 🚫 CRITICAL RULE - ROOT FOLDER RESTRICTION:
**NEVER touch the root folder** - Do not create, update, or modify any files or directories in the project root directory. Only work within the specific repository directories:
- ✅ `registry-api/` - API backend code, tests, and scripts
- ✅ `registry-frontend/` - Frontend code, tests, and scripts  
- ✅ `registry-infrastructure/` - Infrastructure code, tests, and scripts
- ✅ `registry-documentation/` - All project documentation

**Root folder is OFF-LIMITS** - This maintains clean separation between repositories and prevents organizational issues.

### Strict Directory Structure:
1. **Tests**: ALL test files must be created in the `tests/` directory **within each repository**
   - Unit tests, integration tests, end-to-end tests
   - Follow naming convention: `test_*.py`
   - Organize by feature/module when needed

2. **Scripts**: ALL utility scripts must be created in the `scripts/` directory **within each repository**
   - Deployment scripts, debugging tools, maintenance scripts
   - Make scripts executable with proper shebang
   - Include clear documentation in script headers

3. **Documentation**: ALL documentation must be generated in the `registry-documentation/` repository
   - Architecture docs, API docs, deployment guides, cleanup strategies
   - Never create documentation in other repositories
   - Use proper markdown formatting and organization
   - **CENTRALIZED DOCUMENTATION PRINCIPLE**: All project documentation, including cleanup strategies, migration guides, and architectural decisions, must be stored in the registry-documentation repository to maintain a single source of truth

### File Placement Rules:
```
✅ CORRECT:
- registry-api/tests/test_authentication.py
- registry-api/scripts/diagnose_production.py  
- registry-infrastructure/scripts/deploy_infrastructure.py
- registry-frontend/tests/test_components.py
- registry-documentation/api-guide.md

❌ INCORRECT:
- test_authentication.py (root level)
- scripts/diagnose_production.py (root level)
- tests/test_authentication.py (root level)
- README_detailed.md (in api/infrastructure repos)
- any_file.py (root level)
- any_directory/ (root level)
```

### Repository-Specific Guidelines:
- **registry-api/**: Backend API code, tests, scripts, and configurations
- **registry-frontend/**: Frontend code, tests, scripts, and configurations  
- **registry-infrastructure/**: Infrastructure as Code, deployment scripts, configurations
- **registry-documentation/**: All project documentation, guides, and architectural decisions

**Remember**: The root directory should only contain repository directories and essential project files (like devbox.json, .gitignore). Never add new files or directories to the root level.

## Code Review Requirements

### Before Any Code Changes:
1. **Search for existing implementations** - Use `grep`, `find`, or IDE search to check if similar functionality exists
2. Show the diff of what will be changed
3. Explain the purpose and impact
4. Identify any potential risks
5. Wait for explicit approval
6. Use proper commit messages
7. **Verify correct directory placement**
8. **Consider test coverage** - Identify what tests are needed and whether to write tests first

### Implementation Strategy:
```
🔍 IMPLEMENTATION CHECKLIST:
- Search: [describe search performed for existing implementations]
- Integration: [how this integrates with existing systems]
- Tests: [what tests will be created/updated]
- Duplication: [confirmation no duplicate functionality is being created]

Proceed? (explicit yes required)
```

### Commit Message Format:
```
type(scope): description

- feat: new feature
- fix: bug fix
- docs: documentation
- style: formatting
- refactor: code restructuring
- test: adding tests
- chore: maintenance
```

## Monitoring and Alerts

### Set Up Alerts For:
- Direct pushes to main
- Failed CI/CD pipelines
- Unauthorized deployments
- Resource creation/deletion
- Cost threshold breaches

## Lambda Functions and Container Deployment

### 🐳 CRITICAL DEPLOYMENT ARCHITECTURE - UPDATED AUGUST 17, 2025

#### 🚨 DUAL PIPELINE ARCHITECTURE - CRITICAL UNDERSTANDING:

The project uses **TWO SEPARATE DEPLOYMENT PIPELINES** with distinct responsibilities:

##### 1. **REGISTRY-INFRASTRUCTURE PIPELINE** (Infrastructure Provisioning):
- **Location**: `registry-infrastructure/` repository
- **Purpose**: Provisions AWS resources (DynamoDB, API Gateway, Lambda functions, IAM roles, etc.)
- **Technology**: AWS CDK (Python)
- **Workflow**: `.codecatalyst/workflows/infrastructure-deployment-main.yml`
- **Triggers**: Main branch pushes to `registry-infrastructure/`
- **Deploys**: AWS infrastructure resources with placeholder Lambda code

##### 2. **REGISTRY-API PIPELINE** (Application Deployment):
- **Location**: `registry-api/` repository  
- **Purpose**: Builds and deploys Lambda container images with Service Registry application
- **Technology**: Docker containers deployed to Lambda via ECR
- **Triggers**: Main branch pushes to `registry-api/`
- **Deploys**: Application code, Service Registry services, health check fixes

#### Lambda Function Architecture:
- **Deployment Method**: Container-based Lambda functions (NOT zip files)
- **Container Definitions**: Located in `registry-api/` repository
- **Base Images**: Python runtime containers with dependencies
- **🚨 CURRENT ARCHITECTURE**: **SERVICE REGISTRY PATTERN DEPLOYED** ✅

#### Lambda Function Structure - SERVICE REGISTRY (CURRENT):
```
registry-api/
├── Dockerfile.lambda               # Container definition for Lambda
├── main.py                        # ✅ PRIMARY Lambda entry point (SERVICE REGISTRY)
├── main_versioned.py              # ❌ LEGACY - No longer used in production
├── router_main.py                 # Router Lambda entry point  
├── src/
│   ├── handlers/
│   │   ├── modular_api_handler.py # ✅ ACTIVE - Service Registry (366 lines)
│   │   └── versioned_api_handler.py # ❌ LEGACY - Monolithic (2,797 lines)
│   ├── services/                  # 15 Service Registry services
│   ├── models/                    # Data models
│   └── utils/                     # Utility functions
└── requirements.txt               # Python dependencies
```

#### Current Lambda Functions:
1. **PeopleRegisterInfrastruct-PeopleApiFunction67A8223-xlC79QhrsKBe**
   - Main API function handling all endpoints
   - Container-based deployment
   - Entry point: `main.py` → `modular_api_handler.py`

2. **PeopleRegisterInfrastructureS-AuthFunctionA1CD5E0F-lujBJmLNxohb**
   - Authentication-specific function
   - Container-based deployment
   - Entry point: Authentication handlers

3. **PeopleRegisterInfrastructur-RouterFunction6AC6EF3B-cFuTZOTV5Cjd**
   - Request routing function
   - Container-based deployment
   - Entry point: `router_main.py`

#### 🚨 DEPLOYMENT CRITICAL NOTES - DUAL PIPELINE SYSTEM:

##### Infrastructure Changes (registry-infrastructure/):
```bash
# For AWS resource changes (DynamoDB, API Gateway, IAM, etc.)
cd registry-infrastructure/
source .venv/bin/activate
npx cdk deploy --hotswap-fallback  # Infrastructure updates
```

##### Application Code Changes (registry-api/):
```bash
# For Service Registry code, health checks, business logic
# Changes in registry-api/ trigger SEPARATE pipeline
# Container rebuild and Lambda update handled by registry-api pipeline
# NO manual deployment needed from registry-infrastructure/
```

##### 🔄 DEPLOYMENT WORKFLOW SEPARATION:

**Infrastructure Pipeline** (registry-infrastructure):
1. **Provisions**: AWS resources, Lambda functions (with placeholder code)
2. **Creates**: DynamoDB tables, API Gateway, CloudFront, IAM roles
3. **Sets up**: Container-based Lambda functions ready for application deployment
4. **Triggers**: Changes to infrastructure code, CDK configurations

**API Pipeline** (registry-api):
1. **Builds**: Docker containers with Service Registry application
2. **Pushes**: Container images to Amazon ECR
3. **Updates**: Lambda functions with new application container images
4. **Deploys**: Health check fixes, service improvements, business logic changes
5. **Triggers**: Changes to application code, Service Registry services

##### Deployment Dependencies:
- **Infrastructure First**: `registry-infrastructure/` must deploy AWS resources
- **Application Second**: `registry-api/` deploys application code to existing infrastructure
- **Independent Updates**: Application can deploy without infrastructure changes
- **Container Registry**: ECR managed by infrastructure, used by API pipeline

##### 🚨 COMMON DEPLOYMENT CONFUSION:

**❌ INCORRECT ASSUMPTION**: 
"Code changes in registry-api/ require CDK deployment from registry-infrastructure/"

**✅ CORRECT UNDERSTANDING**:
"Code changes in registry-api/ are deployed by the SEPARATE registry-api pipeline"

**❌ INCORRECT WORKFLOW**:
1. Change code in registry-api/
2. Run CDK deploy from registry-infrastructure/
3. Expect application updates

**✅ CORRECT WORKFLOW**:
1. Change code in registry-api/
2. Push to registry-api repository
3. Registry-api pipeline automatically builds and deploys containers
4. Lambda functions updated with new application code

#### Environment Variables:
Lambda functions use environment variables for configuration:
```
PEOPLE_TABLE_NAME=PeopleTable
AUDIT_LOGS_TABLE_NAME=AuditLogsTable
FRONTEND_URL=https://d28z2il3z2vmpc.cloudfront.net
SES_FROM_EMAIL=noreply@cbba.cloud.org.bo
JWT_SECRET=your-jwt-secret-change-in-production-please
```

#### Monitoring and Debugging:
- **CloudWatch Logs**: Each Lambda function has dedicated log groups
- **X-Ray Tracing**: Enabled for performance monitoring
- **Health Endpoints**: `/health` for function status checks
- **Error Handling**: Comprehensive error logging and reporting

#### 🔧 TROUBLESHOOTING LAMBDA DEPLOYMENTS:

##### Infrastructure Issues (registry-infrastructure):
1. Check CDK deployment status in CloudFormation
2. Verify AWS resources are provisioned correctly
3. Check IAM roles and permissions
4. Review infrastructure CloudWatch logs

##### Application Issues (registry-api):
1. Check registry-api pipeline status
2. Verify container build completed successfully
3. Check Lambda function "Last Modified" timestamp
4. Review application CloudWatch logs for runtime errors
5. Verify health check endpoints are responding

##### Container Build Issues:
1. Verify Dockerfile syntax and dependencies in registry-api/
2. Check requirements.txt for version conflicts
3. Ensure all source files are included in container
4. Review registry-api pipeline logs for build failures

##### Performance Issues:
1. Monitor Lambda function duration and memory usage
2. Check for cold start impacts
3. Review database connection pooling
4. Analyze X-Ray traces for bottlenecks
5. Check Service Registry health check performance

This document should be referenced before ANY repository operation.
