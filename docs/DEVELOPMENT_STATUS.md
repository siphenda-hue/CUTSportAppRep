# CUT Sport app development status

Last verified: 2026-11-06

## Repository
- Repository: https://github.com/siphenda-hue/CUTSportAppRep
- Working branch: `App`
- React/Vite source now committed: `src/App.jsx`, `src/main.jsx`, `src/styles.css`, `src/components/BottomNav.jsx`, `src/lib/api.js`, `src/lib/supabase.js`.
- Supporting project files: `package.json`, `index.html`, `.env.example`, `vercel.json`, README and feature/implementation docs.
- Source integration commits: `0167b7fa40e2bc9e42d18973e2434f9718cccf38` (application routes/screens), `900e6b4cf549ff8d7559027423e0890edc4555fa` (responsive styles). Earlier project-file commits are in branch history.
- The branch tree has been checked after the source commits.

## Backend
- Supabase project: `CUT Sport` (`tnkykdfxzwaqzbichxcl`), region `sa-east-1`.
- Existing schema reused; no new tables or migrations added in this run.
- Existing sports directory contains 11 sporting codes. Teams, fixtures, articles, products, events and sponsors have no published content at this stage.
- All inspected public tables have RLS enabled. Latest security advisor returned no findings.
- Performance advisor notices remain to be reviewed separately; no performance or security policy changes were made.

## Current frontend scope
- Home, sport-code directory and hubs, fixtures, news, sponsors, product catalogue/detail, local cart, checkout readiness, profile/auth, notifications, tickets and orders.
- A role-gated sponsor administration screen is now implemented. Its insert/update/archive operations rely on the existing `Sport admins manage sponsors` RLS policy; the database remains the authority.
- Other admin CRUD screens are not yet exposed: current public tables such as sports, teams, fixtures, articles, products and events have read-only client policies. These require a reviewed, role-scoped permission design before management forms are added.
- Payment and ticket issuance/redemption remain gated pending trusted server-side provider and validation workflows.
- Student/staff discount eligibility remains unconfigured pending institutional verification rules.

## Validation and blockers
- `npm install --no-audit --no-fund` was attempted again but timed out in this environment. A GitHub Actions workflow now runs dependency installation and `npm run build` on pushes/PRs to `App`. The first run failed before install because the npm cache expected a lockfile; the workflow was corrected to remove that cache dependency and is awaiting a fresh run.
- A Vite production build and browser test therefore remain unverified.
- No service-role key or secret was placed in frontend source. The browser uses only `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY`.
- No database schema, RLS policies or production data were changed.
