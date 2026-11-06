import { createClient } from "npm:@supabase/supabase-js@2.119.0";

// Authenticated, scope-checked event sales and attendee reporting.
// Returns attendee names only; never returns contact or student-number fields.
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
  if (!url || !anonKey || !serviceKey) return json({ error: "Event reporting is not configured" }, 503);
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
    .select("role").eq("user_id", userId).in("role", ["sport_admin", "super_admin"]);
  if (roleError) return json({ error: "Unable to verify your event-management access" }, 500);
  const superAdmin = (roles || []).some((x) => x.role === "super_admin");
  const sportAdmin = (roles || []).some((x) => x.role === "sport_admin");
  if (!superAdmin && !sportAdmin) return json({ error: "You are not authorised to view event reports" }, 403);

  let allowedSportIds: string[] = [];
  if (!superAdmin) {
    const { data: assignments, error: assignmentError } = await admin.from("sport_admin_assignments")
      .select("sport_id,starts_on,ends_on").eq("admin_profile_id", userId)
      .eq("assignment_role", "sport_admin").is("team_id", null).eq("is_active", true);
    if (assignmentError) return json({ error: "Unable to verify your sport assignment" }, 500);
    const today = new Date().toISOString().slice(0, 10);
    allowedSportIds = [...new Set((assignments || [])
      .filter((x) => (!x.starts_on || x.starts_on <= today) && (!x.ends_on || x.ends_on >= today))
      .map((x) => x.sport_id).filter(Boolean))];
    if (!allowedSportIds.length) return json({ events: [] });
  }

  let body: { eventId?: unknown };
  try { body = await req.json(); } catch { return json({ error: "Invalid request body" }, 400); }
  const eventId = body?.eventId;
  if (!eventId) {
    let query = admin.from("events")
      .select("id,title,sport_id,venue,starts_at,ends_at,published,ticketed")
      .order("starts_at", { ascending: false }).limit(200);
    if (!superAdmin) query = query.in("sport_id", allowedSportIds);
    const { data, error } = await query;
    if (error) return json({ error: "Unable to load events within your assigned scope" }, 500);
    return json({ events: data || [] });
  }
  if (!isUuid(eventId)) return json({ error: "Invalid event reference" }, 400);

  const { data: event, error: eventError } = await admin.from("events")
    .select("id,title,sport_id,venue,starts_at,ends_at,published,ticketed")
    .eq("id", eventId).maybeSingle();
  if (eventError) return json({ error: "Unable to load the selected event" }, 500);
  if (!event) return json({ error: "Event not found" }, 404);
  if (!superAdmin && (!event.sport_id || !allowedSportIds.includes(event.sport_id))) {
    return json({ error: "This event is outside your assigned sport scope" }, 403);
  }

  const [typesResult, ticketsResult, salesResult] = await Promise.all([
    admin.from("event_ticket_types")
      .select("id,name,description,price_cents,quantity_available,is_active,max_per_order")
      .eq("event_id", eventId).order("created_at", { ascending: true }),
    admin.from("tickets")
      .select("id,user_id,ticket_type_id,created_at,redeemed_at")
      .eq("event_id", eventId).order("created_at", { ascending: false }).limit(2000),
    admin.from("order_items")
      .select("id,order_id,ticket_type_id,quantity,unit_price_cents,orders!inner(payment_status)")
      .eq("event_id", eventId).eq("item_type", "event_ticket")
      .eq("orders.payment_status", "succeeded"),
  ]);
  const failed = typesResult.error || ticketsResult.error || salesResult.error;
  if (failed) return json({ error: "Unable to build the event report" }, 500);

  const tickets = ticketsResult.data || [];
  const userIds = [...new Set(tickets.map((x) => x.user_id).filter(Boolean))];
  let names = new Map<string, string>();
  if (userIds.length) {
    const { data: profiles, error: profileError } = await admin.from("profiles")
      .select("id,full_name").in("id", userIds);
    if (profileError) return json({ error: "Unable to load the attendee register" }, 500);
    names = new Map((profiles || []).map((p) => [p.id, p.full_name || "CUT Sport attendee"]));
  }

  const sales = salesResult.data || [];
  const byType = new Map<string, { sold: number; revenue: number; orders: Set<string> }>();
  for (const line of sales) {
    const key = line.ticket_type_id || "unknown";
    const current = byType.get(key) || { sold: 0, revenue: 0, orders: new Set<string>() };
    current.sold += Number(line.quantity || 0);
    current.revenue += Number(line.quantity || 0) * Number(line.unit_price_cents || 0);
    if (line.order_id) current.orders.add(line.order_id);
    byType.set(key, current);
  }
  const ticketTypes = (typesResult.data || []).map((type) => {
    const stats = byType.get(type.id) || { sold: 0, revenue: 0, orders: new Set<string>() };
    return { ...type, sold: stats.sold, revenue_cents: stats.revenue, paid_orders: stats.orders.size };
  });
  const attendees = tickets.map((ticket) => ({
    id: ticket.id,
    attendee_name: names.get(ticket.user_id) || "CUT Sport attendee",
    ticket_type: (typesResult.data || []).find((x) => x.id === ticket.ticket_type_id)?.name || "Ticket",
    issued_at: ticket.created_at,
    redeemed_at: ticket.redeemed_at,
  }));
  return json({
    event,
    summary: {
      tickets_sold: ticketTypes.reduce((sum, x) => sum + x.sold, 0),
      tickets_issued: attendees.length,
      checked_in: attendees.filter((x) => Boolean(x.redeemed_at)).length,
      remaining_capacity: ticketTypes.reduce((sum, x) => sum + Number(x.quantity_available || 0), 0),
      paid_revenue_cents: ticketTypes.reduce((sum, x) => sum + x.revenue_cents, 0),
      paid_orders: new Set(sales.map((x) => x.order_id).filter(Boolean)).size,
    },
    ticketTypes,
    attendees,
  });
});
