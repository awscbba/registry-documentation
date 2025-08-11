# AI Assistant Guidelines for Repository Operations

## 🚫 NEVER DO THESE ACTIONS

### Absolutely Forbidden:
1. **NEVER push directly to main branch**
2. **NEVER merge to main without explicit permission**
3. **NEVER create production deployments**
4. **NEVER modify CI/CD pipeline configurations**
5. **NEVER delete branches without confirmation**
6. **NEVER force push (git push --force)**

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

### Strict Directory Structure:
1. **Tests**: ALL test files must be created in the `tests/` directory
   - Unit tests, integration tests, end-to-end tests
   - Follow naming convention: `test_*.py`
   - Organize by feature/module when needed

2. **Scripts**: ALL utility scripts must be created in the `scripts/` directory
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
- tests/test_authentication.py
- scripts/diagnose_production.py  
- registry-documentation/api-guide.md

❌ INCORRECT:
- test_authentication.py (root level)
- diagnose_production.py (root level)
- README_detailed.md (in api/infrastructure repos)
```

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

This document should be referenced before ANY repository operation.
