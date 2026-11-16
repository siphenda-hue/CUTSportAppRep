# Flash Payment Integration Plan

Last updated: 16 November 2026

## Decision

Prepare CUT Sport for two Flash-related payment routes while retaining the existing Yoco checkout as a fallback:

1. **Flash direct API integration** — integrate only the transaction products and payment capabilities that Flash has enabled for the CUT Sport merchant account. Flash's public platform guide describes API access to Flash brands and services, sandbox testing, production onboarding and integration-team support. It does not publish enough of the merchant-specific checkout contract to safely implement a generic online card-payment gateway.
2. **1Voucher online acceptance** — implement the official partner redemption flow once Flash/1Voucher supplies the merchant integration pack, sandbox credentials, API contract and settlement/reconciliation rules. This is distinct from selling a 1Voucher or accepting it on a physical Flash terminal.

## Current repository architecture

- React + Vite frontend.
- Supabase project: `tnkykdfxzwaqzbichxcl`.
- Existing server-authoritative Yoco checkout Edge Function: `supabase/functions/yoco-checkout`.
- Existing signed Yoco webhook: `supabase/functions/yoco-webhook`.
- Existing order, order-item, ticket and payment-completion database workflows are already used by shop and event-ticket checkout.
- Yoco must remain available until Flash passes sandbox and end-to-end acceptance tests. Do not remove or disable Yoco as part of the Flash rollout.

## Target architecture

Keep the browser provider-agnostic. The browser submits the order intent to a trusted Supabase Edge Function; it never receives Flash secrets, Yoco secrets, or service-role credentials.

Introduce a provider selection layer on the server:

- `yoco`: current hosted checkout and signed webhook.
- `flash_1voucher`: online voucher validation/redemption via the official partner API.
- `flash_api`: only the specific Flash API product(s) approved for the merchant account.

Use a common internal payment record/order lifecycle so the application can reconcile:
- internal order ID and idempotency key;
- provider and provider transaction/reference ID;
- amount in integer ZAR cents and currency;
- pending, succeeded, failed, cancelled and refunded states (only where the provider supports the transition);
- raw provider event receipt stored privately with duplicate-event protection;
- settlement/reconciliation reference and timestamps.

Provider callbacks must be authenticated according to Flash's official specification. Never trust a browser redirect or client-submitted success status as proof of payment. Ticket issuance and stock fulfilment must occur only after the trusted server confirms the provider transaction and reconciles order, amount and currency.

## Delivery phases

### Phase 0 — Merchant enablement and API discovery (blocking)
Obtain from Flash:
- written confirmation of which Flash API products are enabled for the CUT Sport business account;
- the online 1Voucher partner integration guide and exact validation/redemption endpoints;
- the direct API product guide and whether it supports online customer checkout or only Flash value-added services;
- sandbox base URL, credentials and test PINs/test cases;
- authentication, request signing, idempotency, callback/webhook and retry rules;
- transaction status lookup, reversal/refund and duplicate transaction behavior;
- settlement schedule, fees, reconciliation reports and merchant support contact;
- production go-live approval process.

Do not send API secrets in chat or commit them to GitHub. Configure them only as Supabase Edge Function secrets after the contract is reviewed.

### Phase 1 — Safe application foundation
- Add provider-neutral server interfaces and provider configuration/feature flags.
- Keep provider-specific secrets exclusively in Supabase Edge Function secrets.
- Keep Yoco as the enabled fallback.
- Add private, idempotent provider-event receipts and auditable transaction references using a versioned migration only after the schema is reviewed against the existing database.
- Do not change existing RLS policies or grant client-side write access to payment/order tables.

### Phase 2 — Flash sandbox
- Implement the exact Flash API contract supplied for this merchant account.
- Implement 1Voucher online validation and redemption as a separate provider method.
- Reconcile the Flash response against the server-priced CUT Sport order.
- Test success, invalid PIN, already-used PIN, insufficient value, timeout, duplicate requests, callback replay, mismatched amount/currency, abandoned checkout, provider outage and status lookup.
- Confirm refund/reversal behavior; do not promise refunds if the product does not support them.

### Phase 3 — Controlled pilot and production
- Obtain Flash production approval and configure production secrets in Supabase.
- Run a controlled low-value transaction and reconcile it against Flash's merchant portal/report.
- Enable Flash methods for a small pilot while retaining Yoco.
- Monitor failure rates and settlement discrepancies before broader rollout.

## Important 1Voucher constraints to expose in the UI

Flash/1Voucher's public support information says physical Flash-machine acceptance has a 2.5% payment-acceptance fee and does not support partial redemption on Flash machines. Those rules must not be assumed to apply identically to the online partner API; confirm online fees, partial-redemption support and refund rules in the merchant contract before presenting them to CUT Sport customers.

## Current blocker / required handoff

The public Flash pages establish that Flash has API integrations and 1Voucher online partners, but the detailed merchant API documentation is not publicly exposed. The 1Voucher support page directs businesses to request the integration documentation from hello@1voucher.co.za. Flash's platform guide also offers direct contact with its integrations team.

Request the merchant-specific integration pack and share the **documentation only** with the development team. Do not share passwords, API keys, PINs, private signing keys or production credentials in chat.

## Official references

- Flash API & Platform Guide: https://flash.co.za/platform/platform-guide
- Flash Platform: https://flash.co.za/platform
- 1Voucher technical/business support: https://www.1voucher.co.za/support
- Flash business solutions: https://flash.co.za/business

## Activation rule

No Flash payment method is customer-visible or production-enabled until the relevant official API contract is implemented, sandbox-tested, webhook/callback verification is complete, and a real settlement reconciliation is confirmed.