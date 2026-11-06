# Yoco Checkout and Ticketing Integration

Last updated: 6 November 2026

## Status

Yoco is the selected payment provider. The database schema and four Supabase Edge Functions have been deployed, and the React checkout and ticket-purchase screens are connected to those functions. The integration is **not yet accepting payments** because merchant credentials, the deployed application URL, webhook signing secret and ticket-signing secret have not been configured.

No Yoco API key or secret has been committed to GitHub or added to Vite/browser environment variables. No live payment has been attempted.

## Architecture

- **yoco-checkout** — authenticated Edge Function. Validates the Supabase user, creates a server-priced order, reserves stock, creates a Yoco hosted checkout, and returns only the Yoco redirect URL.
- **yoco-webhook** — public Edge Function with JWT verification disabled because Yoco calls it. It validates Yoco's HMAC-SHA256 signature over the raw body, enforces a three-minute timestamp window, reconciles checkout ID/amount/currency, and only then marks an order paid.
- **my-tickets** — authenticated Edge Function. Returns signed ticket codes only to the ticket owner.
- **redeem-ticket** — authenticated staff Edge Function. Verifies the signed code, checks the staff member's super-admin or assigned sport-admin permission, and atomically redeems a ticket once.
- **event_ticket_types** — event-specific ticket prices, stock and per-order limits.
- **yoco_webhook_events** — private receipt table for webhook event idempotency.
- Existing orders, order_items and tickets tables are reused. Direct client order creation, order-item creation and ticket issuance are revoked. Only the trusted backend can create/complete orders and issue tickets.

Yoco Checkout is hosted by Yoco. Card details never pass through CUT Sport. The browser return URL is informational only; order fulfilment is driven by a verified webhook, never by a query string or success redirect.

## Required Supabase Edge Function secrets

Open Supabase Dashboard → Project CUT Sport → Edge Functions → Secrets. Add the following values there, not in .env, .env.example, Vite variables or GitHub.

| Secret | Value |
|---|---|
| YOCO_SECRET_KEY | Yoco **test** secret key for initial sandbox testing |
| YOCO_WEBHOOK_SECRET | whsec_... signing secret returned when the Yoco webhook is registered |
| APP_BASE_URL | The final public HTTPS URL of the deployed CUT Sport app, without a trailing slash |
| TICKET_SIGNING_SECRET | A strong random secret; generate locally with openssl rand -base64 32 |

Supabase supplies its own SUPABASE_URL, SUPABASE_ANON_KEY and SUPABASE_SERVICE_ROLE_KEY function environment variables. Do not add those to Vite. Never send Yoco or Supabase secrets in chat.

Keep TICKET_SIGNING_SECRET stable. Rotating it invalidates existing ticket codes unless a planned key-rotation process is implemented.

## Yoco merchant setup

1. Sign in to the Yoco App or Web Portal.
2. Open Sales → e-Commerce integrations → Checkout API → How to connect.
3. Add the final public CUT Sport application domain under Verified domains. Yoco requires domain review before live keys are unlocked. Test keys can be used while the domain review is pending.
4. Copy the Yoco **test secret key** into the Supabase Edge Function secret YOCO_SECRET_KEY.
5. Set APP_BASE_URL to the deployed CUT Sport HTTPS URL.
6. Generate and add TICKET_SIGNING_SECRET.

## Register the Yoco webhook

The deployed endpoint is:

https://tnkykdfxzwaqzbichxcl.supabase.co/functions/v1/yoco-webhook

Register it with Yoco using the test secret key. Yoco's Checkout API documentation describes POST https://payments.yoco.com/api/webhooks:

~~~bash
curl -X POST https://payments.yoco.com/api/webhooks \
  -H "Authorization: Bearer $YOCO_SECRET_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "CUT Sport Supabase webhook",
    "url": "https://tnkykdfxzwaqzbichxcl.supabase.co/functions/v1/yoco-webhook"
  }'
~~~

Copy the secret from Yoco's response immediately into YOCO_WEBHOOK_SECRET. Yoco only returns this signing secret once. Never commit it.

The webhook handler checks the webhook-id, webhook-timestamp and webhook-signature headers, uses the unmodified raw request body, compares HMAC-SHA256 signatures, and rejects stale/replayed timestamps. It reconciles the Yoco metadata.checkoutId against the order created by CUT Sport.

## Test sequence before live payments

1. Use Yoco test credentials only.
2. Create a low-value test product or event ticket through the authorised CUT Sport admin interface.
3. Sign in to CUT Sport and complete checkout using Yoco's test card details from the Yoco Portal.
4. Confirm the Yoco webhook reaches the Supabase endpoint and the order changes to payment_status = succeeded only after signature, amount and currency validation.
5. For an event ticket, confirm the ticket is issued once, visible only to its owner, and can be redeemed once by an authorised sport administrator.
6. Test declined/abandoned checkout, duplicate webhook delivery, mismatched amount/currency, invalid signature, stale timestamp, insufficient stock and already-redeemed tickets.
7. Confirm the Yoco test webhook and order records reconcile before enabling live payments.

## Live activation

After Yoco approves the verified domain, replace the test secret with the live secret in Supabase Edge Function secrets and register/configure the live webhook signing secret returned by Yoco. Make a controlled live payment and reconcile it in both Yoco and CUT Sport before announcing ticket sales.

Yoco Checkout currently supports ZAR. The current checkout flow enforces a minimum card payment of R2.00. Yoco transaction fees and merchant settlement are governed by the merchant's Yoco plan.

## Remaining limitations

- The React app is not yet deployed to a verified public domain, so APP_BASE_URL is not yet known.
- Yoco merchant credentials and webhook signing secret have not been configured.
- No real or sandbox checkout has been completed in this project yet.
- Ticket codes are securely signed and displayed in the user's ticket area. The staff gate accepts a code pasted or typed by a QR scanner; a camera-based QR scanner UI is a future enhancement.
- Stock is reserved transactionally when an order is created. Automated expiry/release of abandoned checkout reservations still needs a scheduled cleanup job before high-volume production sales.
- Student/staff discounts, refunds, delivery fulfilment and inventory reporting need separately approved business rules and workflows.


## Checkout reservation cleanup policy

Supabase Cron runs `private.release_unlinked_stale_yoco_orders()` every five minutes. It returns reserved stock only for Yoco orders that are older than 20 minutes and have **no persisted Yoco checkout ID**. These represent abandoned/incomplete server-side checkout creation, not a customer-facing hosted payment session. The function is private and not executable by client roles.

Orders with a persisted Yoco checkout ID are deliberately excluded from automatic cancellation. The application's current 30-minute `checkout_expires_at` value is an internal reservation timestamp, not authoritative proof that Yoco has expired the hosted checkout. Do not release those reservations automatically until Yoco's remote expiry and payment lookup behavior is verified using merchant test credentials. This avoids releasing stock while a customer may still be able to complete payment.

The scheduled job can be inspected in Supabase Dashboard → Integrations → Cron. Its name is `cut-sport-release-unlinked-yoco-orders` and it runs every five minutes.

## Event ticket QR scanning

The staff gate at `/admin/ticket-gate` now supports camera scanning and QR decoding from a locally selected image or screenshot using `html5-qrcode@2.3.8` (Apache-2.0). The browser loads the pinned scanner bundle only when the scanner is used. QR decoding occurs on-device; image files are not uploaded. Staff must still confirm the scanned code and invoke the protected redemption endpoint. Camera access requires HTTPS and user permission. Manual paste/keyboard-scanner entry remains available.
