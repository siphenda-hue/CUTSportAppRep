const expectedUrl = "https://tnkykdfxzwaqzbichxcl.supabase.co";
const url = process.env.VITE_SUPABASE_URL;
const key = process.env.VITE_SUPABASE_PUBLISHABLE_KEY;
const errors = [];

if (!url) errors.push("VITE_SUPABASE_URL is missing");
else if (url !== expectedUrl) errors.push("VITE_SUPABASE_URL does not match the approved CUT Sport Supabase project");

if (!key) errors.push("VITE_SUPABASE_PUBLISHABLE_KEY is missing");
else if (!key.startsWith("sb_publishable_")) errors.push("Use the modern sb_publishable_ key, not a secret or service-role key");

const unsafeNames = Object.keys(process.env).filter((name) =>
  /^VITE_.*(SERVICE_ROLE|SECRET|YOCO|TICKET_SIGNING)/i.test(name)
);
if (unsafeNames.length) errors.push("Remove server-side secrets from VITE_ frontend variables: " + unsafeNames.join(", "));

if (errors.length) {
  console.error("\nCUT Sport deployment preflight failed:");
  for (const error of errors) console.error(" - " + error);
  console.error("\nConfigure the browser-safe Supabase URL and publishable key in the hosting provider, then redeploy.\n");
  process.exit(1);
}

console.log("CUT Sport deployment preflight passed. Supabase URL and publishable-key configuration are present.");
