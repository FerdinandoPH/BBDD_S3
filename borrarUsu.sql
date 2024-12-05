\c tienda_db
BEGIN;
DROP USER suMajestad;
DROP USER virrey;

DO $$
DECLARE
    ent RECORD;
BEGIN   
    FOR ent IN SELECT nombre_usuario FROM tienda.Usuarios
    LOOP
        EXECUTE format('DROP USER %I', ent.nombre_usuario);
    END LOOP;
END $$;

DROP USER forastero;

REASSIGN OWNED BY Administrador TO postgres;
REASSIGN OWNED BY Gestor TO postgres;
REASSIGN OWNED BY Cliente TO postgres;
REASSIGN OWNED BY Invitado TO postgres;

DROP OWNED BY Administrador;
DROP OWNED BY Gestor;
DROP OWNED BY Cliente;
DROP OWNED BY Invitado;

DROP ROLE Administrador;
DROP ROLE Gestor;
DROP ROLE Cliente;
DROP ROLE Invitado;

COMMIT;