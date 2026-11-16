-- Add covering indexes for public-schema foreign keys that currently lack one.
-- This is additive: it does not alter RLS, grants, constraints, or application data.
-- Existing valid indexes whose leading key columns already cover an FK are preserved.
DO $$
DECLARE
  fk RECORD;
  index_name TEXT;
  column_list TEXT;
BEGIN
  FOR fk IN
    SELECT
      c.conrelid,
      c.conname,
      c.conkey,
      n.nspname,
      t.relname,
      array_agg(a.attname ORDER BY k.ord) AS columns
    FROM pg_constraint c
    JOIN pg_class t ON t.oid = c.conrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
    CROSS JOIN LATERAL unnest(c.conkey) WITH ORDINALITY AS k(attnum, ord)
    JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = k.attnum
    WHERE c.contype = 'f'
      AND n.nspname = 'public'
      AND NOT EXISTS (
        SELECT 1
        FROM pg_index i
        WHERE i.indrelid = c.conrelid
          AND i.indisvalid
          AND i.indisready
          AND i.indnkeyatts >= cardinality(c.conkey)
          AND (i.indkey::smallint[])[0:cardinality(c.conkey)-1] = c.conkey
      )
    GROUP BY c.conrelid, c.conname, c.conkey, n.nspname, t.relname
  LOOP
    -- Keep names below PostgreSQL's 63-byte identifier limit and avoid collisions.
    index_name := left('idx_fk_' || fk.conname, 54) || '_' || substr(md5(fk.conname), 1, 8);
    SELECT string_agg(format('%I', column_name), ', ')
      INTO column_list
      FROM unnest(fk.columns) AS column_name;

    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON %I.%I (%s)',
      index_name,
      fk.nspname,
      fk.relname,
      column_list
    );
  END LOOP;
END
$$;
