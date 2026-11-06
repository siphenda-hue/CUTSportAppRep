# CUT Sport deployment readiness

Last reviewed: 6 November 2026

## Current verified state

- GitHub repository: `siphenda-hue/CUTSportAppRep`, branch `App`.
- GitHub Actions builds the React/Vite application successfully.
- `netlify.toml` configures the Vite build, SPA route fallback, caching and security headers.
- Netlify build now runs `npm run preflight:deploy && npm run build`.
- The preflight requires the exact CUT Sport Supabase project URL and an active modern `sb_publishable_` browser key. It rejects server-side secrets exposed through `VITE_` variables.
- An active Supabase publishable key exists for the CUT Sport project. Its value is not stored in GitHub and must be added directly to the hosting provider's protected build environment.
- Supabase security advisor returned no findings in the latest review.
- PWA manifest, app icon and production service worker are in the repository. Private Supabase endpoints are excluded from offline caching.

## Not yet completed

- No Netlify site has been connected or deployed. The GitHub repository and hosting account have not yet been linked.
- No temporary public HTTPS URL exists yet. Therefore Supabase Auth redirect allow-list entries and `APP_BASE_URL` cannot yet be finalised.
- Yoco merchant test credentials, registered webhook secret and ticket-signing secret have not been verified as configured. No sandbox purchase, webhook delivery, ticket issuance or redemption has been end-to-end tested.
- Yoco live checkout must remain disabled until the final custom domain is verified by Yoco and sandbox testing succeeds.
- Camera QR scanning, installability and offline-shell behavior still require real-device testing over the temporary HTTPS deployment.
- Authorised sport-admin, coach and shop-admin accounts/assignments still need to be assigned by the institution's approved administrator. No privileged user was created or promoted automatically.

## Deployment sequence

1. In Netlify, import `siphenda-hue/CUTSportAppRep` from GitHub and select branch `App`.
2. Set `VITE_SUPABASE_URL` to `https://tnkykdfxzwaqzbichxcl.supabase.co`.
3. Set `VITE_SUPABASE_PUBLISHABLE_KEY` to the active `sb_publishable_` key from Supabase Project Settings → API Keys. Do not paste it into source code or commit it.
4. Deploy. Netlify runs the preflight and stops if required values are missing or server secrets have been placed in frontend variables.
5. Add the exact temporary HTTPS site URL to Supabase Authentication → URL Configuration → Redirect URLs.
6. Test sign-in, public pages, account pages, admin permission boundaries and PWA behavior on desktop and mobile.
7. Set Supabase Edge Function secret `APP_BASE_URL` to the temporary HTTPS URL before attempting Yoco sandbox checkout. Keep `YOCO_SECRET_KEY`, `YOCO_WEBHOOK_SECRET` and `TICKET_SIGNING_SECRET` in Supabase Edge Function secrets only.
8. Register the Yoco test webhook at `https://tnkykdfxzwaqzbichxcl.supabase.co/functions/v1/yoco-webhook`, store its returned signing secret in Supabase, then run an end-to-end sandbox purchase and ticket redemption test.
9. After the custom domain is acquired, connect it to Netlify, configure DNS/HTTPS, update Supabase Auth redirect URLs and `APP_BASE_URL`, verify the domain in Yoco, and repeat the sandbox tests before enabling live payments.

## Security boundaries

- Never place Supabase service-role keys, Yoco secret keys, webhook signing secrets or ticket-signing secrets in Vite/Netlify `VITE_` variables.
- The browser receives only the Supabase publishable key.
- Do not make the site publicly accessible until CUT approves the audience and content for release.
- No test accounts, fake events, products, attendees or athlete statistics have been seeded.
