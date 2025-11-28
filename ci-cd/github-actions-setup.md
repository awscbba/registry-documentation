# GitHub Actions Setup Guide

## Overview

GitHub Actions workflows have been created to replace CodeCatalyst CI/CD for the infrastructure repository.

## Current Status

✅ **Workflows Created:**
- `infrastructure-deployment.yml` - Main deployment workflow
- `pr-validation.yml` - Pull request validation workflow
- Comprehensive README with setup instructions

✅ **Branch:** `fix/api-gateway-cors-headers`
✅ **Repository:** `registry-infrastructure`

## Required Setup Steps

Before the workflows can run, you need to configure AWS authentication:

### 1. Create AWS OIDC Provider (One-time setup)

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

### 2. Create IAM Role for GitHub Actions

Create a role with this trust policy (replace `YOUR_ACCOUNT_ID`):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:awscbba/registry-infrastructure:*"
        }
      }
    }
  ]
}
```

Attach permissions policy (AdministratorAccess or custom CDK deployment policy).

### 3. Configure GitHub Repository Secret

1. Go to: https://github.com/awscbba/registry-infrastructure/settings/secrets/actions
2. Click "New repository secret"
3. Add:
   - **Name:** `AWS_ROLE_ARN`
   - **Value:** `arn:aws:iam::YOUR_ACCOUNT_ID:role/GitHubActionsRole`

### 4. Enable GitHub Actions

1. Go to: https://github.com/awscbba/registry-infrastructure/settings/actions
2. Under "Actions permissions", select "Allow all actions and reusable workflows"
3. Under "Workflow permissions", select "Read and write permissions"

## Testing the Workflows

### Option 1: Test with Current Branch

The workflows are already in the `fix/api-gateway-cors-headers` branch. Once AWS is configured:

1. Push any change to the branch
2. Check: https://github.com/awscbba/registry-infrastructure/actions
3. The PR validation workflow should run automatically

### Option 2: Create a Pull Request

1. Create a PR from `fix/api-gateway-cors-headers` to `main`
2. The PR validation workflow will run and post results as a comment
3. Review the CDK diff in the PR comment

### Option 3: Manual Trigger

1. Go to: https://github.com/awscbba/registry-infrastructure/actions
2. Select "Infrastructure Deployment" workflow
3. Click "Run workflow"
4. Select branch and run

## Monitoring Workflows

### View Workflow Runs

- URL: https://github.com/awscbba/registry-infrastructure/actions
- Click on any workflow run to see details
- Expand steps to see logs

### Workflow Status

You can add status badges to your README:

```markdown
[![Infrastructure Deployment](https://github.com/awscbba/registry-infrastructure/actions/workflows/infrastructure-deployment.yml/badge.svg)](https://github.com/awscbba/registry-infrastructure/actions/workflows/infrastructure-deployment.yml)
```

## Current CORS Fix Deployment

The CORS fix is ready to deploy once GitHub Actions is configured:

1. **Option A - Merge to Main:**
   - Create PR from `fix/api-gateway-cors-headers` to `main`
   - Merge PR
   - GitHub Actions will automatically deploy

2. **Option B - Manual Deployment:**
   ```bash
   cd registry-infrastructure/
   git checkout fix/api-gateway-cors-headers
   npx cdk deploy --hotswap-fallback
   ```

## Migration from CodeCatalyst

Once GitHub Actions is working:

1. Test thoroughly with a few deployments
2. Update documentation to reference GitHub Actions
3. Optionally remove `.codecatalyst/` directory
4. Update team workflows and runbooks

## Troubleshooting

### "Error: Credentials could not be loaded"

- Verify OIDC provider is created
- Check IAM role trust policy
- Ensure `AWS_ROLE_ARN` secret is set correctly

### "Error: User is not authorized to perform: sts:AssumeRoleWithWebIdentity"

- Check the IAM role trust policy condition
- Verify the repository name matches exactly: `awscbba/registry-infrastructure`

### Workflow doesn't trigger

- Check that GitHub Actions is enabled in repository settings
- Verify workflow files are in `.github/workflows/` directory
- Check branch protection rules aren't blocking workflows

## Next Steps

1. ✅ Complete AWS OIDC and IAM role setup
2. ✅ Configure GitHub repository secret
3. ✅ Test workflows with current branch
4. ✅ Deploy CORS fix
5. ✅ Create similar workflows for other repositories (api, frontend)

## Additional Resources

- GitHub Actions Documentation: https://docs.github.com/en/actions
- AWS OIDC Guide: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
- Workflow README: `registry-infrastructure/.github/workflows/README.md`
