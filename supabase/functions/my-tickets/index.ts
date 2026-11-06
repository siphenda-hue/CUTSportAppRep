import { createClient } from "npm:@supabase/supabase-js@2.119.0";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });
function bytesToBase64Url(bytes: Uint8Array): string {
  let binary = "";
  for (const byte of bytes) binary += String.fromCharCode(byte);
  return btoa(binary).replaceAll("+", "-").replaceAll("/", "_").replace(/=+$/g, "");
}
async function digestHex(value: string): Promise<string> {
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(value));
  return [...new Uint8Array(digest)].map((b) => b.toString(16).padStart(2, "0")).join("");
}
async function tokenFor(id: string, secret: string): Promise<{ token: string; hash: string }> {
  const key = await crypto.subtle.importKey("raw", new TextEncoder().encode(secret), { name: "HMAC", hash: "SHA-256" }, false, ["sign"]);
  const signature = new Uint8Array(await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(id)));
  const token = id + "." + bytesToBase64Url(signature);
  return { token, hash: await digestHex(token) };
}
Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);
  const url = Deno.env.get("SUPABASE_URL"), anon = Deno.env.get("SUPABASE_ANON_KEY");
  const service = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"), secret = Deno.env.get("TICKET_SIGNING_SECRET");
  const authorization = req.headers.get("Authorization");
  if (!url || !anon || !service || !secret) return json({ error: "Ticket service is not configured" }, 503);
  if (!authorization?.startsWith("Bearer ")) return json({ error: "Sign in to view tickets" }, 401);
  const userClient = createClient(url, anon, { global: { headers: { Authorization: authorization } }, auth: { persistSession: false, autoRefreshToken: false } });
  const { data: auth, error: authError } = await userClient.auth.getUser();
  if (authError || !auth.user) return json({ error: "Session expired" }, 401);
  const admin = createClient(url, service, { auth: { persistSession: false, autoRefreshToken: false } });
  const { data, error } = await admin.from("tickets")
    .select("id,event_id,ticket_code_hash,redeemed_at,created_at,events(title,venue,starts_at)")
    .eq("user_id", auth.user.id).order("created_at", { ascending: false });
  if (error) return json({ error: "Unable to load your tickets" }, 500);
  const tickets = [];
  for (const ticket of data || []) {
    if (!ticket.ticket_code_hash || ticket.ticket_code_hash.startsWith("pending:")) continue;
    const signed = await tokenFor(ticket.id, secret);
    if (signed.hash !== ticket.ticket_code_hash) continue;
    tickets.push({
      id: ticket.id,
      event_id: ticket.event_id,
      event: ticket.events,
      redeemed_at: ticket.redeemed_at,
      created_at: ticket.created_at,
      ticket_code: signed.token,
    });
  }
  return json({ tickets });
});
