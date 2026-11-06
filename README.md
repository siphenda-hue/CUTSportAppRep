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
- Product catalogue, product detail, local cart and checkout readiness
- Sponsor directory
- Account sign-in, sign-up and profile
- Personal notifications, tickets and order history

## Supabase integration
Project ref: `tnkykdfxzwaqzbichxcl`. Existing tables and RLS are reused. No sample fixture, athlete, sponsor, product, event or news records are inserted.

## Not yet live
- Admin management screens: require final mapping of scoped write permissions and CRUD workflows.
- Payments/order placement: require a real gateway, server-side verification and atomic order creation.
- Ticket QR issuance/redemption: require trusted server-side issue and verify endpoints.
- Student/staff discounts: require approved institutional eligibility rules.
- Production build/browser test: pending because dependency installation timed out in the current build environment.

Do not expose service-role or secret keys in Vite environment variables.