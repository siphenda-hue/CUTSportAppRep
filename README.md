# CUT Sport App

Mobile-first React + Vite application for Central University of Technology Sport. The frontend reuses the existing CUT Sport Supabase project and its Row Level Security policies.

## Stack
- React 18 and Vite 6
- React Router
- Supabase JS 2.119.0
- Lucide icons

## Run locally
1. Install Node.js 20 or newer.
2. Run `npm install`.
3. Copy `.env.example` to `.env.local`.
4. Set `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY` using the project's publishable key (never a service-role key).
5. Run `npm run dev`; run `npm run build` to produce a production bundle.

## Current app areas
- Home and sport-code directory / hubs
- Fixtures and results
- News and article detail
- Product catalogue, product detail, local cart and Yoco hosted checkout
- Sponsor directory
- Account sign-in, sign-up and profile
- Personal notifications, signed event tickets and order history
- Role-secured sport operations, athlete approvals, editorial publishing and staff ticket redemption

## Supabase integration
Project ref: `tnkykdfxzwaqzbichxcl`. Existing tables and RLS are reused. No sample fixture, athlete, sponsor, product, event or news records are inserted.

## Yoco checkout and ticketing
- Yoco Checkout is the selected provider. The authenticated checkout, signed webhook, ticket pass and staff redemption Edge Functions are deployed to Supabase.
- Database order creation is server-authoritative, idempotent and uses product/ticket prices from Supabase. Ticket issuance follows verified payment only.
- Before any sandbox payment, configure the required Supabase Edge Function secrets and register the Yoco webhook. Follow `docs/YOCO_INTEGRATION.md`.
- Live payments require Yoco domain verification and live merchant credentials. The app is not yet deployed to its final public domain.
- Camera-based QR scanning, scheduled release of abandoned checkout stock reservations, student/staff discounts and refunds remain future work.

Do not expose service-role, Yoco secret or ticket-signing keys in Vite environment variables.