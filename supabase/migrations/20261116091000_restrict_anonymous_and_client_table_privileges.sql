-- Keep browser-facing table access least-privilege while preserving the existing RLS policies.
-- Anonymous visitors retain existing SELECT grants; all row writes remain authenticated and RLS-scoped.
-- TRUNCATE bypasses row-level security, so it must not be granted to browser roles.
REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER, MAINTAIN
ON ALL TABLES IN SCHEMA public FROM anon;

-- Authenticated users continue to use the existing RLS-scoped INSERT/UPDATE/DELETE flows.
-- Remove table-level administrative capabilities that are not needed by the application.
REVOKE TRUNCATE, REFERENCES, TRIGGER, MAINTAIN
ON ALL TABLES IN SCHEMA public FROM authenticated;

-- Apply the same restrictions to future public tables created by the migration role.
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER, MAINTAIN ON TABLES FROM anon;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
REVOKE TRUNCATE, REFERENCES, TRIGGER, MAINTAIN ON TABLES FROM authenticated;
