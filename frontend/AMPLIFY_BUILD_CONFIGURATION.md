# Amplify Build Configuration for Astro SSR

## Overview

This document outlines the **exact configuration** required for successful AWS Amplify deployment of the Astro SSR frontend.

## Critical Configuration

### astro.config.mjs

**✅ WORKING CONFIGURATION:**

```javascript
// @ts-check
import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import tailwind from '@astrojs/tailwind';
import awsAmplify from 'astro-aws-amplify';

// https://astro.build/config
export default defineConfig({
  integrations: [react(), tailwind()],
  adapter: awsAmplify(),
  output: 'server'
});
```

### amplify.yml

```yaml
version: 1
frontend:
  phases:
    preBuild:
      commands:
        - npm install
    build:
      commands:
        - npm run build
  artifacts:
    baseDirectory: .amplify-hosting
    files:
      - '**/*'
  cache:
    paths:
      - node_modules/**/*
```

## Environment Variables

### Required Variables

Configure these in **AWS Amplify Console** → **App Settings** → **Environment variables**:

| Variable | Description | Required | Default | Example |
|----------|-------------|----------|---------|---------|
| `PUBLIC_API_URL` | Backend API Gateway URL | ✅ Yes | None | `https://2t9blvt2c1.execute-api.us-east-1.amazonaws.com/prod` |
| `PUBLIC_SITE_URL` | Frontend base URL | ⚠️ Optional | `https://registry.cloud.org.bo` | `https://registry.cloud.org.bo` |

### Configuration Steps

1. Open [AWS Amplify Console](https://console.aws.amazon.com/amplify/)
2. Select your app (e.g., `d2df6u91uqaaay`)
3. Navigate to **App settings** → **Environment variables**
4. Click **Manage variables**
5. Add the required variables:
   - **Key**: `PUBLIC_API_URL`
   - **Value**: Your API Gateway URL
   - **Key**: `PUBLIC_SITE_URL` (optional)
   - **Value**: Your production domain

### How Environment Variables Work

During the Amplify build process:
- Environment variables are automatically injected into the build
- Astro reads them via `import.meta.env.PUBLIC_*`
- Variables prefixed with `PUBLIC_` are exposed to the client-side code
- The `getSiteUrl()` helper uses `PUBLIC_SITE_URL` for absolute URLs

### Branch-Specific Variables

Amplify supports **branch-specific overrides**:
- Set different values for `main`, `staging`, `dev` branches
- Useful for pointing to different API environments
- Preview branches automatically use relative URLs (no configuration needed)

### Variable Usage in Code

```typescript
// src/config/api.ts
export const API_CONFIG = {
  BASE_URL: import.meta.env.PUBLIC_API_URL || 'https://default-api.com',
  SITE_URL: import.meta.env.PUBLIC_SITE_URL || 'https://registry.cloud.org.bo',
};

// Smart URL generation - works on any domain
export const getSiteUrl = (path: string): string => {
  if (typeof window !== 'undefined') {
    return path; // Relative path in browser
  }
  return `${API_CONFIG.SITE_URL}${path}`; // Absolute for SSR
};
```

### Why PUBLIC_SITE_URL is Optional

The `getSiteUrl()` helper uses **relative paths in the browser**, which means:
- ✅ Works on Amplify preview URLs: `https://branch-name.d2df6u91uqaaay.amplifyapp.com`
- ✅ Works on production domain: `https://registry.cloud.org.bo`
- ✅ Works on localhost: `http://localhost:4321`
- ✅ No per-branch configuration needed

The `PUBLIC_SITE_URL` is only used for:
- Server-side rendering (SSR) contexts
- Generating absolute URLs in emails
- Open Graph meta tags
- Sitemap generation

## Key Requirements

### 1. Adapter Configuration
- **MUST use**: `astro-aws-amplify` adapter
- **Import as**: `awsAmplify from 'astro-aws-amplify'`
- **Call as**: `awsAmplify()` (not `aws()`)

### 2. Output Mode
- **MUST be**: `output: 'server'` for SSR functionality
- **Required for**: Dynamic subscription pages, authentication, real-time features

### 3. Build Artifacts
- **Generated directory**: `.amplify-hosting/`
- **Contains**: `deploy-manifest.json`, `compute/`, `static/`
- **Amplify expects**: Files in `.amplify-hosting` directory, not `dist/`

## Build Process

### Local Build Verification
```bash
# Clean previous builds
rm -rf dist .amplify-hosting

# Build with Amplify adapter
npm run build

# Verify .amplify-hosting directory exists
ls -la .amplify-hosting/
# Should contain: deploy-manifest.json, compute/, static/
```

### Generated Structure
```
.amplify-hosting/
├── deploy-manifest.json     # Required by Amplify
├── compute/
│   └── default/
│       ├── entry.mjs       # SSR entry point
│       ├── manifest_*.mjs  # Build manifests
│       └── chunks/         # Server chunks
└── static/
    └── assets/             # Client assets
```

## Troubleshooting

### Common Issues

#### 1. "Failed to find deploy-manifest.json"
**Cause**: Wrong adapter or missing `.amplify-hosting` directory
**Solution**: Ensure `astro-aws-amplify` adapter is used correctly

#### 2. Build artifacts in wrong directory
**Cause**: Using `@astrojs/node` adapter instead of `astro-aws-amplify`
**Solution**: Switch to correct adapter configuration

#### 3. SSR functionality broken
**Cause**: Switched to `output: 'static'` mode
**Solution**: Keep `output: 'server'` for dynamic features

### Verification Steps

1. **Check adapter**: Must be `astro-aws-amplify`
2. **Check output**: Must be `'server'`
3. **Check build**: `.amplify-hosting/` directory generated
4. **Check manifest**: `deploy-manifest.json` exists

## Dependencies

### Required Package
```json
{
  "dependencies": {
    "astro-aws-amplify": "^0.2.3"
  }
}
```

### Installation
```bash
npm install astro-aws-amplify
```

## Branch References

### Working Branches
- `feature/fix-subscription-pages` - Proven working configuration
- `main` - Uses different adapter but works (legacy)

### Configuration History
- **Main branch**: Uses `@astrojs/node` adapter (legacy working)
- **Feature branches**: Use `astro-aws-amplify` adapter (current standard)

## Business Logic Requirements

### Why SSR is Critical
- **Dynamic subscription pages**: `/subscribe/[projectId]`
- **Server-side authentication**: Token validation with backend
- **Role-based access control**: Admin panel access
- **Real-time features**: Live user dashboards
- **SEO optimization**: Server-rendered project pages

### Never Switch to Static
❌ **NEVER** change to `output: 'static'` - breaks critical business functionality

## Deployment Flow

1. **Code push** → Feature branch
2. **Amplify detects** → Triggers build
3. **Build process** → Uses `astro-aws-amplify` adapter
4. **Generates** → `.amplify-hosting/` with `deploy-manifest.json`
5. **Amplify deploys** → SSR application with compute resources

## Monitoring

### Build Success Indicators
- ✅ `.amplify-hosting/deploy-manifest.json` generated
- ✅ `compute/default/entry.mjs` exists
- ✅ `static/assets/` contains client files
- ✅ No "deploy-manifest.json not found" errors

### Runtime Success Indicators
- ✅ Dynamic subscription pages work
- ✅ Authentication flows function
- ✅ Admin panels accessible
- ✅ SSR features operational

## Related Documentation

- [Frontend Environment Configuration](./environment-configuration.md) - Detailed environment variable setup
- [API Configuration](../api/configuration.md) - Backend API endpoints
- [Deployment Guide](../ci-cd/deployment-guide.md) - Full deployment process

---

**Last Updated**: November 29, 2025  
**Verified Working**: `feature/fix-subscription-pages`, `feature/fix-super-admin-roles`, `fix/login-link-subscription-form`
