DO $$
DECLARE
    r RECORD;
BEGIN
    -- Borrar todos los triggers en el esquema 'tienda'
    SET SCHEMA 'tienda';
    FOR r IN (SELECT tgname, relname FROM pg_trigger JOIN pg_class ON pg_trigger.tgrelid = pg_class.oid WHERE relnamespace = 'tienda'::regnamespace) LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON %I;', r.tgname, r.relname);
    END LOOP;

    -- Borrar la función 'fn_auditoria' si existe
    DROP FUNCTION IF EXISTS fn_auditoria();
END $$;

\i PruebaTriggers.sql