import { createClient } from "npm:@supabase/supabase-js@2.119.0";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });
function safeEqual(a: string, b: string): boolean {
  const left = new TextEncoder().encode(a), right = new TextEncoder().encode(b);
  if (left.length !== right.length) return false;
  let diff = 0;
  for (let i = 0; i < left.length; i++) diff |= left[i] ^ right[i];
  return diff === 0;
}
async function digestHex(value: string): Promise<string> {
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(value));
  return [...new Uint8Array(digest)].map((b) => b.toString(16).padStart(2, "0")).join("");
}
async function expectedToken(id: string, secret: string): Promise<string> {
  const key = await crypto.subtle.importKey("raw", new TextEncoder().encode(secret), { name: "HMAC", hash: "SHA-256" }, false, ["sign"]);
  const bytes = new Uint8Array(await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(id)));
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return id + "." + btoa(binary).replaceAll("+", "-").replaceAll("/", "_").replace(/=+$/g, "");
}
Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);
  const url = Deno.env.get("SUPABASE_URL"), anon = Deno.env.get("SUPABASE_ANON_KEY");
  const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"), secret = Deno.env.get("TICKET_SIGNING_SECRET");
  const authorization = req.headers.get("Authorization");
  if (!url || !anon || !service || !secret) return json({ error: "Ticket redemption is not configured" }, 503);
  if (!authorization?.startsWith("Bearer ")) return json({ error: "Staff sign-in is required" }, 401);
  const userClient = createClient(url, anon, { global: { headers: { Authorization: authorization } }, auth: { persistSession: false, autoRefreshToken: false } });
  const { data: auth, error: authError } = await userClient.auth.getUser();
  if (authError || !auth.user) return json({ error: "Session expired" }, 401);
  let body: { ticketCode?: string };
  try { body = await req.json(); } catch { return json({ error: "Invalid request" }, 400); }
  const parts = (body.ticketCode || "").split(".");
  if (parts.length !== 2) return json({ error: "Invalid ticket code" }, 400);
  const [ticketId, signature] = parts;
  const expected = await expectedToken(ticketId, secret);
  if (!safeEqual(expected, body.ticketCode || "")) return json({ error: "Invalid ticket signature" }, 403);

  const admin = createClient(url, service, { auth: { persistSession: false, autoRefreshToken: false } });
  const { data: ticket, error: ticketError } = await admin.from("tickets")
    .select("id,event_id,ticket_code_hash,redeemed_at,events(id,title,sport_id)")
    .eq("id", ticketId).maybeSingle();
  if (ticketError || !ticket) return json({ error: "Ticket not found" }, 404);
  if (!safeEqual(await digestHex(body.ticketCode || ""), ticket.ticket_code_hash || "")) return json({ error: "Ticket code does not match" }, 403);
  if (ticket.redeemed_at) return json({ error: "Ticket has already been redeemed", redeemedAt: ticket.redeemed_at }, 409);

  const { data: roles, error: roleError } = await admin.from("user_roles")
    .select("role").eq("user_id", auth.user.id).in("role", ["super_admin", "sport_admin"]);
  if (roleError) return json({ error: "Unable to verify staff permissions" }, 500);
  const isSuper = (roles || []).some((r) => r.role === "super_admin");
  let allowed = isSuper;
  const sportId = ticket.events?.sport_id;
  if (!allowed && sportId && (roles || []).some((r) => r.role === "sport_admin")) {
    const { data: assignments, error: assignmentError } = await admin.from("sport_admin_assignments")
      .select("starts_on,ends_on,is_active").eq("admin_profile_id", auth.user.id)
      .eq("sport_id", sportId).eq("is_active", true);
    if (assignmentError) return json({ error: "Unable to verify sport assignment" }, 500);
    const today = new Date().toISOString().slice(0, 10);
    allowed = (assignments || []).some((a) =>
      (!a.starts_on || a.starts_on <= today) && (!a.ends_on || a.ends_on >= today)
    );
  }
  if (!allowed) return json({ error: "You are not authorised to redeem tickets for this event" }, 403);

  const { data: redeemed, error: redeemError } = await admin.from("tickets")
    .update({ redeemed_at: new Date().toISOString() }).eq("id", ticketId).is("redeemed_at", null).select("id").maybeSingle();
  if (redeemError) return json({ error: "Ticket redemption failed" }, 500);
  if (!redeemed) return json({ error: "Ticket has already been redeemed" }, 409);
  return json({ redeemed: true, event: ticket.events?.title || "CUT Sport event", ticketId });
});
