# Branch Protection Rules Implementation

## Critical: Protect Main Branch

### GitHub/CodeCatalyst Branch Protection Settings:

1. **Require pull request reviews before merging**
   - Require at least 1 review
   - Dismiss stale reviews when new commits are pushed
   - Require review from code owners

2. **Require status checks to pass before merging**
   - Require branches to be up to date before merging
   - Require CI/CD pipeline to pass

3. **Restrict pushes to matching branches**
   - Only allow merge commits (no direct pushes)
   - Include administrators in restrictions

4. **Require linear history**
   - Prevent merge commits that create complex history

### Implementation Steps:

#### For GitHub:
```bash
# Repository Settings > Branches > Add rule
Branch name pattern: main
☑️ Restrict pushes that create files larger than 100 MB
☑️ Require a pull request before merging
  ☑️ Require approvals: 1
  ☑️ Dismiss stale pull request approvals when new commits are pushed
  ☑️ Require review from code owners
☑️ Require status checks to pass before merging
  ☑️ Require branches to be up to date before merging
☑️ Restrict pushes that create files larger than 100 MB
☑️ Include administrators
```

#### For AWS CodeCatalyst:
```yaml
# .codecatalyst/workflows/branch-protection.yml
Name: BranchProtection
SchemaVersion: "1.0"

Triggers:
  - Type: PUSH
    Branches:
      - main

Actions:
  ProtectMain:
    Identifier: aws/managed-test@v1
    Configuration:
      Steps:
        - Run: echo "Direct pushes to main are not allowed"
        - Run: exit 1
```

## Git Hooks for Local Protection

### Pre-push Hook:
```bash
#!/bin/sh
# .git/hooks/pre-push

protected_branch='main'
current_branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

if [ $protected_branch = $current_branch ]; then
    echo "🚫 BLOCKED: Direct push to main branch is not allowed!"
    echo "Please create a feature branch and submit a pull request."
    echo "Current branch: $current_branch"
    exit 1
fi
```

### Pre-commit Hook:
```bash
#!/bin/sh
# .git/hooks/pre-commit

if git symbolic-ref HEAD | grep -q "main"; then
    echo "🚫 BLOCKED: Direct commits to main branch are not allowed!"
    echo "Please switch to a feature branch first."
    exit 1
fi
```
