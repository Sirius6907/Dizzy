# Cloudflare Pages Setup Guide

## Step 1: Create Cloudflare Account & Get API Token

1. Go to https://dash.cloudflare.com/sign-up (or login if you have an account)
2. Navigate to **My Profile** → **API Tokens**
3. Click **Create Token** → Use template **Edit Cloudflare Workers**
4. Or create **Custom token** with these permissions:
   - **Account** → **Cloudflare Pages** → **Edit**
5. Copy the API token (you'll need this for GitHub Secrets)

## Step 2: Get Account ID

1. In Cloudflare dashboard, click any zone (domain) or go to Workers & Pages
2. On the right sidebar, you'll see **Account ID**
3. Copy it (format: `1234567890abcdef1234567890abcdef`)

## Step 3: Create Cloudflare Pages Project

### Option A: Via Dashboard (Manual)
1. Go to **Workers & Pages** → **Create application**
2. Click **Pages** → **Connect to Git** (skip this, we'll use CLI)
3. Or click **Direct Upload** → name it `dizzy` → Create project

### Option B: Via Wrangler CLI (Recommended)
```bash
# Install wrangler globally
npm install -g wrangler

# Login to Cloudflare
wrangler login

# Create Pages project (first deploy creates it automatically)
# The GitHub Action will handle this on first push
```

## Step 4: Add Secrets to GitHub

1. Go to your GitHub repo: https://github.com/Sirius6907/Dizzy
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add these two secrets:

```
Name: CLOUDFLARE_API_TOKEN
Value: <your-api-token-from-step-1>

Name: CLOUDFLARE_ACCOUNT_ID
Value: <your-account-id-from-step-2>
```

## Step 5: Trigger Deployment

Push to `main` or create a tag:

```bash
git tag -a v1.0.1 -m "Dizzy v1.0.1 - Web deployment"
git push origin v1.0.1
```

GitHub Actions will:
1. Build Flutter web (release mode)
2. Upload artifact
3. Deploy to Cloudflare Pages → `https://dizzy.pages.dev`

## Step 6: Custom Domain (Optional)

1. In Cloudflare Pages dashboard → your `dizzy` project
2. Go to **Custom domains**
3. Click **Set up a custom domain**
4. Enter your domain (e.g., `dizzy.yourdomain.com`)
5. Cloudflare will auto-configure DNS

---

## Verification

After the GitHub Action runs:
1. Check **Actions** tab → your workflow run → Web job
2. See deployment logs
3. Visit `https://dizzy.pages.dev` (or your custom domain)

---

## Troubleshooting

### "Project not found"
- Go to Cloudflare Dashboard → Workers & Pages → Create a project named `dizzy` first

### "Authentication failed"
- Double-check your API token has **Cloudflare Pages Edit** permission
- Make sure Account ID is correct (no spaces)

### Web build fails
- Check if `dart:ffi` or platform-specific packages are used
- Flutter web doesn't support `libtorrent_flutter` (it's desktop/mobile only)
- May need conditional imports or web-specific implementations

---

## Cost

- **Free tier:** Unlimited bandwidth, unlimited requests
- **No credit card required**
- Perfect for 1000+ concurrent users

---

## Alternative: Manual Deploy (No CI/CD)

```bash
cd /c/Users/opcha/Downloads/dizzy
flutter build web --release
npx wrangler pages deploy build/web --project-name=dizzy
```
