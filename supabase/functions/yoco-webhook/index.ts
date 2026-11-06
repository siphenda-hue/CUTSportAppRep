import { createClient } from "npm:@supabase/supabase-js@2.119.0";

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { "Content-Type": "application/json" } });

function safeEqual(a: string, b: string): boolean {
  const left = new TextEncoder().encode(a);
  const right = new TextEncoder().encode(b);
  if (left.length !== right.length) return false;
  let diff = 0;
  for (let i = 0; i < left.length; i++) diff |= left[i] ^ right[i];
  return diff === 0;
}
function bytesToBase64Url(bytes: Uint8Array): string {
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replaceAll("+", "-").replaceAll("/", "_").replace(/=+$/g, "");
}
async function digestHex(value: string): Promise<string> {
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(value));
  return [...new Uint8Array(digest)].map((b) => b.toString(16).padStart(2, "0")).join("");
}
async function ticketToken(ticketId: string, secret: string): Promise<{ token: string; hash: string }> {
  const key = await crypto.subtle.importKey("raw", new TextEncoder().encode(secret), { name: "HMAC", hash: "SHA-256" }, false, ["sign"]);
  const signature = new Uint8Array(await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(ticketId)));
  const token = ticketId + "." + bytesToBase64Url(signature);
  return { token, hash: await digestHex(token) };
}
async function verifyYocoSignature(rawBody: string, req: Request, secret: string): Promise<boolean> {
  const id = req.headers.get("webhook-id");
  const timestamp = req.headers.get("webhook-timestamp");
  const signatures = req.headers.get("webhook-signature");
  if (!id || !timestamp || !signatures) return false;
  const timestampNumber = Number(timestamp);
  if (!Number.isFinite(timestampNumber) || Math.abs(Date.now() / 1000 - timestampNumber) > 180) return false;
  if (!secret.startsWith("whsec_")) return false;
  let secretBytes: Uint8Array;
  try {
    const binary = atob(secret.slice(6));
    secretBytes = Uint8Array.from(binary, (c) => c.charCodeAt(0));
  } catch { return false; }
  const key = await crypto.subtle.importKey("raw", secretBytes, { name: "HMAC", hash: "SHA-256" }, false, ["sign"]);
  const signedContent = id + "." + timestamp + "." + rawBody;
  const expected = bytesToBase64Url(new Uint8Array(await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(signedContent))))
    .replaceAll("-", "+").replaceAll("_", "/");
  const expectedPadded = expected + "=".repeat((4 - expected.length % 4) % 4);
  return signatures.split(" ").some((entry) => {
    const [version, value] = entry.split(",");
    return version === "v1" && !!value && safeEqual(value, expectedPadded);
  });
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const webhookSecret = Deno.env.get("YOCO_WEBHOOK_SECRET");
  const ticketSecret = Deno.env.get("TICKET_SIGNING_SECRET");
  if (!supabaseUrl || !serviceKey || !webhookSecret) return json({ error: "Webhook is not configured" }, 503);

  const rawBody = await req.text();
  if (!(await verifyYocoSignature(rawBody, req, webhookSecret))) {
    return json({ error: "Invalid webhook signature or timestamp" }, 401);
  }
  let event: any;
  try { event = JSON.parse(rawBody); } catch { return json({ error: "Invalid webhook JSON" }, 400); }
  if (event?.type !== "payment.succeeded") {
    return json({ received: true, ignored: event?.type || "unknown" });
  }

  const checkoutId = event?.payload?.metadata?.checkoutId;
  const paymentId = event?.payload?.id;
  const amount = Number(event?.payload?.amount);
  const currency = event?.payload?.currency;
  if (!checkoutId || !paymentId || !Number.isInteger(amount) || currency !== "ZAR" || !event?.id) {
    return json({ error: "Payment event is missing required reconciliation fields" }, 400);
  }

  const admin = createClient(supabaseUrl, serviceKey, { auth: { persistSession: false, autoRefreshToken: false } });
  const { data: order, error: findError } = await admin.from("orders")
    .select("id,order_kind,payment_status,total_cents,currency")
    .eq("yoco_checkout_id", checkoutId).maybeSingle();
  if (findError) return json({ error: "Unable to reconcile payment order" }, 500);
  if (!order) return json({ received: true, ignored: "checkout not owned by CUT Sport" });

  const { error: completeError } = await admin.rpc("complete_yoco_order", {
    p_checkout_id: checkoutId,
    p_payment_id: paymentId,
    p_amount: amount,
    p_currency: currency,
  });
  if (completeError) return json({ error: "Payment verification did not match the order" }, 409);

  if (order.order_kind === "event") {
    if (!ticketSecret) return json({ error: "Ticket signing is not configured" }, 503);
    const { data: pendingTickets, error: ticketError } = await admin.from("tickets")
      .select("id").eq("order_id", order.id).like("ticket_code_hash", "pending:%");
    if (ticketError) return json({ error: "Unable to prepare purchased tickets" }, 500);
    for (const ticket of pendingTickets || []) {
      const signed = await ticketToken(ticket.id, ticketSecret);
      const { error: updateError } = await admin.from("tickets")
        .update({ ticket_code_hash: signed.hash }).eq("id", ticket.id).like("ticket_code_hash", "pending:%");
      if (updateError) return json({ error: "Unable to secure an issued ticket" }, 500);
    }
  }

  const { error: eventError } = await admin.from("yoco_webhook_events").upsert({
    id: event.id,
    event_type: event.type,
    checkout_id: checkoutId,
  }, { onConflict: "id", ignoreDuplicates: true });
  if (eventError) return json({ error: "Payment was confirmed but webhook receipt could not be recorded" }, 500);

  return json({ received: true, orderId: order.id, paymentStatus: "succeeded" });
});
