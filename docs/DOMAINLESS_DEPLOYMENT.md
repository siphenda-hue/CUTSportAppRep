# CUT Sport temporary hosting and deployment guide

Last updated: 6 November 2026

## Why this can be deployed before buying a domain

CUT Sport can be published to a temporary HTTPS address such as a Netlify-provided `*.netlify.app` subdomain. This is suitable for internal review, mobile testing, installability checks and non-payment feature testing. It does not require buying a domain first.

The custom domain can be connected later without changing the Supabase project or rebuilding the application architecture.

## Repository deployment settings

- Repository: `siphenda-hue/CUTSportAppRep`
- Branch: `App`
- Build command: `npm run preflight:deploy && npm run build` (enforced by `netlify.toml`)
- Node runtime: 22
- Deployment preflight: verifies the CUT Sport Supabase URL, modern browser-safe publishable key, and blocks server-side secrets from `VITE_` variables
- Publish directory: `dist`
- SPA routing: configured in `netlify.toml`
- Build environment variables:
  - `VITE_SUPABASE_URL` = `https://tnkykdfxzwaqzbichxcl.supabase.co`
  - `VITE_SUPABASE_PUBLISHABLE_KEY` = the project's browser-safe publishable key from Supabase Project Settings → API Keys

Only the publishable key belongs in the frontend. Never add the Supabase service-role key, Yoco secret key, webhook secret or ticket-signing secret to Netlify build variables.

## Netlify setup

1. Sign in to Netlify and choose **Add new site → Import an existing project**.
2. Connect the GitHub account and select `siphenda-hue/CUTSportAppRep`.
3. Choose branch `App`.
4. Confirm Netlify has detected the repository build command `npm run preflight:deploy && npm run build` and publish directory `dist`.
5. Add the two `VITE_...` variables above under Site configuration → Environment variables. The deployment preflight will stop the build if they are missing or if a secret key is used.
6. Deploy. Netlify will assign a temporary HTTPS subdomain.
7. Open the deployed URL on a phone and test navigation, sign-in, sports, news and the admin routes with authorised accounts.
8. Keep the temporary address private to the intended reviewers until institutional approval for public launch.

The repository includes a Netlify configuration with history fallback for React Router, immutable caching for Vite assets, and safe no-cache handling for the service worker.

## Supabase URL configuration

The current Supabase Auth redirect allow-list may need the temporary Netlify URL added before sign-in email links or OAuth redirects can return to the app. Add only the exact deployed URL and any required callback paths under Authentication → URL Configuration. Keep the final custom domain entry for when it is purchased.

## Yoco remains gated

Do not switch on live payments using a temporary hosting address. Yoco live checkout requires the merchant's verified domain. After temporary deployment, sandbox checkout may be prepared with Yoco test credentials, but only after the exact temporary HTTPS URL is set as `APP_BASE_URL` in Supabase Edge Function secrets and the Yoco test webhook has been registered.

When the custom domain is purchased:
1. Add it to Netlify and complete the DNS instructions shown by Netlify.
2. Wait for HTTPS certificate provisioning.
3. Add the final domain to Supabase Auth redirect URLs.
4. Update `APP_BASE_URL` in Supabase Edge Function secrets.
5. Add the domain in Yoco's Verified domains and wait for approval.
6. Run the full Yoco sandbox purchase, webhook, ticket issuance and redemption test before changing to live credentials.

## Progressive Web App

The repository now includes:
- A CUT Sport web app manifest and installable app identity.
- A CUT Sport app icon.
- A production-only service worker.
- An offline app-shell fallback for previously loaded navigation.
- Cache exclusion for Supabase Auth, REST, Functions and Storage endpoints. User records, sessions, orders and tickets are not cached by this service worker.

The PWA can be installed from a supported mobile browser after deployment over HTTPS. Offline mode preserves the application shell only; it does not promise live scores, account data, checkout or ticket validation without a network connection.
