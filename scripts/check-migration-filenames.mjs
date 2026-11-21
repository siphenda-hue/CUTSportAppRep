import fs from "node:fs";
import path from "node:path";

const migrationDir = path.resolve("supabase/migrations");
const files = fs.readdirSync(migrationDir)
  .filter((name) => name.endsWith(".sql"))
  .sort();

const byVersion = new Map();
const malformed = [];

for (const name of files) {
  const match = name.match(/^(\\d{14})_(.+)\\.sql$/);
  if (!match) {
    malformed.push({ name, reason: "Expected YYYYMMDDHHMMSS_description.sql" });
    continue;
  }

  const version = match[1];
  const [, year, month, day, hour, minute, second] =
    version.match(/^(\\d{4})(\\d{2})(\\d{2})(\\d{2})(\\d{2})(\\d{2})$/);
  const date = new Date(Date.UTC(+year, +month - 1, +day, +hour, +minute, +second));
  const roundTrip = [
    date.getUTCFullYear(),
    String(date.getUTCMonth() + 1).padStart(2, "0"),
    String(date.getUTCDate()).padStart(2, "0"),
    String(date.getUTCHours()).padStart(2, "0"),
    String(date.getUTCMinutes()).padStart(2, "0"),
    String(date.getUTCSeconds()).padStart(2, "0"),
  ].join("");

  if (roundTrip !== version) {
    malformed.push({ name, reason: "Timestamp is not a valid calendar date/time" });
  }

  byVersion.set(version, [...(byVersion.get(version) ?? []), name]);
}

const duplicateGroups = [...byVersion.entries()].filter(([, names]) => names.length > 1);

console.log(`Migration filename audit: ${files.length} SQL files, ${byVersion.size} distinct timestamp prefixes.`);

if (malformed.length) {
  console.warn(`\\nWARNING: ${malformed.length} malformed migration filename(s):`);
  for (const item of malformed) console.warn(` - ${item.name}: ${item.reason}`);
}

if (duplicateGroups.length) {
  console.warn(`\\nWARNING: ${duplicateGroups.length} duplicate timestamp group(s):`);
  for (const [version, names] of duplicateGroups) {
    console.warn(` - ${version}: ${names.join(", ")}`);
  }
}

if (!malformed.length && !duplicateGroups.length) {
  console.log("Migration filename audit passed with no timestamp issues.");
} else {
  console.log("\\nAudit is informational only: no migration files were changed or reordered.");
}
