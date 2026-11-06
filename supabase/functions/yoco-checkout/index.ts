import { createClient } from "npm:@supabase/supabase-js@2.119.0";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const yocoSecret = Deno.env.get("YOCO_SECRET_KEY");
  const appBaseUrl = Deno.env.get("APP_BASE_URL");
  if (!supabaseUrl || !anonKey || !serviceKey) return json({ error: "Payment service is not configured" }, 503);
  if (!yocoSecret || !appBaseUrl) return json({ error: "Yoco test credentials and the application URL must be configured before checkout can start" }, 503);

  const authorization = req.headers.get("Authorization");
  if (!authorization?.startsWith("Bearer ")) return json({ error: "Sign in before checkout" }, 401);
  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: userData, error: authError } = await userClient.auth.getUser();
  if (authError || !userData.user) return json({ error: "Your session is invalid or has expired" }, 401);

  let body: { orderKind?: string; requestId?: string; lines?: Array<Record<string, unknown>> };
  try { body = await req.json(); } catch { return json({ error: "Invalid request body" }, 400); }
  if (!["shop", "event"].includes(body.orderKind || "") ||
      !body.requestId || !/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(body.requestId) ||
      !Array.isArray(body.lines) || body.lines.length === 0 || body.lines.length > 20) {
    return json({ error: "Invalid checkout details" }, 400);
  }

  let base: URL;
  try {
    base = new URL(appBaseUrl);
    if (base.protocol !== "https:") throw new Error("HTTPS required");
  } catch {
    return json({ error: "APP_BASE_URL must be a valid HTTPS application URL" }, 503);
  }

  const admin = createClient(supabaseUrl, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: order, error: orderError } = await admin.rpc("create_yoco_order", {
    p_user_id: userData.user.id,
    p_order_kind: body.orderKind,
    p_lines: body.lines,
    p_request_id: body.requestId,
  });
  if (orderError || !order) {
    return json({ error: orderError?.message || "Unable to prepare your order" }, 400);
  }
  if (order.redirect_url && order.checkout_id) {
    return json({ orderId: order.order_id, orderNumber: order.order_number, redirectUrl: order.redirect_url });
  }

  const root = base.toString().replace(/\/+$/, "");
  const checkoutPayload = {
    amount: order.amount,
    currency: "ZAR",
    successUrl: root + "/payment/success?order=" + encodeURIComponent(order.order_number),
    cancelUrl: root + "/payment/cancelled?order=" + encodeURIComponent(order.order_number),
    failureUrl: root + "/payment/failed?order=" + encodeURIComponent(order.order_number),
    metadata: { orderId: order.order_id, orderNumber: order.order_number },
    externalId: order.order_id,
    clientReferenceId: order.order_id,
  };

  let yocoResponse: Response;
  try {
    yocoResponse = await fetch("https://payments.yoco.com/api/checkouts", {
      method: "POST",
      headers: {
        Authorization: "Bearer " + yocoSecret,
        "Content-Type": "application/json",
        "Idempotency-Key": order.order_id,
      },
      body: JSON.stringify(checkoutPayload),
    });
  } catch {
    await admin.rpc("cancel_yoco_order", { p_order_id: order.order_id });
    return json({ error: "Yoco could not be reached. Your stock reservation has been released; please try again." }, 502);
  }

  if (!yocoResponse.ok) {
    await admin.rpc("cancel_yoco_order", { p_order_id: order.order_id });
    return json({ error: "Yoco could not create a checkout session. Please check the Yoco test credentials and try again." }, 502);
  }

  const checkout = await yocoResponse.json().catch(() => null);
  let redirect: URL;
  try {
    if (typeof checkout?.id !== "string" || checkout.amount !== order.amount || checkout.currency !== "ZAR") {
      throw new Error("Yoco checkout amount or currency did not match");
    }
    redirect = new URL(checkout?.redirectUrl);
    if (redirect.protocol !== "https:" || redirect.hostname !== "c.yoco.com") throw new Error("Unexpected checkout host");
  } catch {
    await admin.rpc("cancel_yoco_order", { p_order_id: order.order_id });
    return json({ error: "Yoco returned an invalid checkout destination" }, 502);
  }

  const { error: saveError } = await admin.from("orders").update({
    yoco_checkout_id: checkout.id,
    yoco_redirect_url: redirect.toString(),
    payment_status: "pending",
    checkout_expires_at: new Date(Date.now() + 30 * 60 * 1000).toISOString(),
  }).eq("id", order.order_id);
  if (saveError) {
    await admin.rpc("cancel_yoco_order", { p_order_id: order.order_id });
    return json({ error: "The checkout session could not be linked to your order" }, 500);
  }

  return json({
    orderId: order.order_id,
    orderNumber: order.order_number,
    redirectUrl: redirect.toString(),
  });
});
