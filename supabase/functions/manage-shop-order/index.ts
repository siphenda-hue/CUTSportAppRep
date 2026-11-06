import { createClient } from "npm:@supabase/supabase-js@2.119.0";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });
const isUuid = (value: unknown): value is string =>
  typeof value === "string" && /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value);

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);
  const url = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const authorization = req.headers.get("Authorization");
  if (!url || !anonKey || !serviceKey) return json({ error: "Shop order management is not configured" }, 503);
  if (!authorization?.startsWith("Bearer ")) return json({ error: "Sign in required" }, 401);

  const userClient = createClient(url, anonKey, {
    global: { headers: { Authorization: authorization } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data: authData, error: authError } = await userClient.auth.getUser();
  if (authError || !authData.user) return json({ error: "Your session is invalid or expired" }, 401);

  const admin = createClient(url, serviceKey, { auth: { persistSession: false, autoRefreshToken: false } });
  const userId = authData.user.id;
  const { data: roles, error: roleError } = await admin.from("user_roles")
    .select("role").eq("user_id", userId).in("role", ["shop_admin", "super_admin"]);
  if (roleError) return json({ error: "Unable to verify your shop-management access" }, 500);
  if (!(roles || []).length) return json({ error: "You are not authorised to manage shop orders" }, 403);

  let body: { orderId?: unknown; newStatus?: unknown; note?: unknown };
  try { body = await req.json(); } catch { return json({ error: "Invalid request body" }, 400); }
  const orderId = body?.orderId;
  const newStatus = body?.newStatus;
  const note = body?.note;
  if (!isUuid(orderId)) return json({ error: "Invalid order reference" }, 400);
  if (newStatus !== "processing" && newStatus !== "fulfilled") {
    return json({ error: "Only processing and fulfilled updates are supported" }, 400);
  }
  if (note !== undefined && note !== null && (typeof note !== "string" || note.length > 500)) {
    return json({ error: "Internal note must be 500 characters or fewer" }, 400);
  }

  const { data: order, error: orderError } = await admin.from("orders")
    .select("id,order_kind,status,payment_status,order_number")
    .eq("id", orderId).maybeSingle();
  if (orderError) return json({ error: "Unable to load this order" }, 500);
  if (!order || order.order_kind !== "shop") return json({ error: "Shop order not found" }, 404);
  if (order.payment_status !== "succeeded") return json({ error: "Only successfully paid orders can enter fulfilment" }, 409);
  const expected = newStatus === "processing" ? "paid" : "processing";
  if (order.status !== expected) {
    return json({ error: `This order is currently "${order.status}". Refresh the list before trying again.` }, 409);
  }

  const { data: changed, error: changeError } = await admin.rpc("transition_shop_order", {
    p_order_id: orderId,
    p_expected_status: expected,
    p_new_status: newStatus,
    p_actor_id: userId,
    p_note: typeof note === "string" ? note.trim() || null : null,
  }).maybeSingle();
  if (changeError || !changed) {
    return json({ error: changeError?.message || "The order status could not be updated. Refresh and try again." }, 409);
  }
  return json({
    orderId,
    orderNumber: order.order_number,
    status: changed.new_status,
    changedAt: changed.changed_at,
  });
});
