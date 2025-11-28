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

---

**Last Updated**: October 5, 2025  
**Verified Working**: `feature/fix-subscription-pages`, `feature/fix-super-admin-roles`
