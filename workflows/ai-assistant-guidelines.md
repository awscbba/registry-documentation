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

## Code Quality and Standards

### ⚠️ CRITICAL: NO TEMPORARY FIXES OR WORKAROUNDS
**This is an enterprise-grade product. ALL implementations must be production-ready and maintainable.**

1. **NEVER implement temporary fixes, workarounds, or hardcoded solutions**
   - No hardcoded user IDs, emails, or specific values
   - No "TODO: fix this later" comments without immediate resolution
   - No shortcuts that compromise long-term maintainability
   
2. **Always implement proper, scalable solutions**
   - Use configuration files for environment-specific values
   - Implement proper database schemas and relationships
   - Follow established patterns and architecture
   - Write code that works for ALL users, not specific cases
   
3. **If a proper solution requires more time:**
   - Explain the situation to the user
   - Propose the correct implementation approach
   - Get approval before proceeding
   - Document any technical debt explicitly
   
4. **Rationale:**
   - Temporary fixes accumulate and become permanent
   - They make debugging and maintenance extremely difficult
   - They hide the real problems instead of solving them
   - They compromise product quality and reliability

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
9. **Verify no temporary fixes** - Ensure the solution is production-ready and scalable

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

### 🐳 CRITICAL DEPLOYMENT INFORMATION - UPDATED AUGUST 16, 2025

#### Lambda Function Architecture:
- **Deployment Method**: Container-based Lambda functions (NOT zip files)
- **Container Definitions**: Located in `registry-api/` repository
- **Base Images**: Python runtime containers with dependencies
- **Build Process**: Automated through CDK infrastructure deployment
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
└── requirements.txt             # Python dependencies
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

#### Deployment Process:
```bash
# Code changes in registry-api/ trigger container rebuild
cd registry-infrastructure/
source .venv/bin/activate
npx cdk deploy                     # Full stack deployment
```

#### Container Build Process:
1. **Code Changes**: Made in `registry-api/` repository
2. **Container Build**: CDK automatically builds new container image
3. **Lambda Update**: New container deployed to Lambda functions
4. **API Gateway**: Routes traffic to updated Lambda functions

#### 🚨 DEPLOYMENT CRITICAL NOTES:

##### Code Update Workflow:
1. **Make changes** in `registry-api/` repository
2. **Commit and push** changes to feature branch
3. **Container rebuild** happens automatically during CDK deployment
4. **Lambda functions** get updated with new container image

##### Deployment Dependencies:
- **Source Code**: `registry-api/` repository
- **Infrastructure**: `registry-infrastructure/` repository  
- **CDK Deployment**: Required to update Lambda functions
- **Container Registry**: ECR automatically managed by CDK

##### Common Issues:
- **Lambda function not updating**: Check CDK deployment status
- **Container build failures**: Check Dockerfile and dependencies
- **Permission issues**: Verify IAM roles and policies

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

##### If Lambda Functions Not Updating:
1. Check CDK deployment status in CloudFormation
2. Verify container build completed successfully
3. Check Lambda function "Last Modified" timestamp
4. Review CloudWatch logs for deployment errors
5. Ensure correct branch is being deployed

##### Container Build Issues:
1. Verify Dockerfile syntax and dependencies
2. Check requirements.txt for version conflicts
3. Ensure all source files are included in container
4. Review CDK logs for build failures

##### Performance Issues:
1. Monitor Lambda function duration and memory usage
2. Check for cold start impacts
3. Review database connection pooling
4. Analyze X-Ray traces for bottlenecks

This document should be referenced before ANY repository operation.
