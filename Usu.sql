\c tienda_db

BEGIN;
CREATE ROLE Administrador WITH SUPERUSER;

CREATE ROLE Gestor WITH NOSUPERUSER;
GRANT USAGE ON SCHEMA tienda TO Gestor;
GRANT USAGE, SELECT ON SEQUENCE tienda.auditoria_id_seq TO Gestor;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA tienda TO Gestor;

CREATE ROLE Cliente WITH NOSUPERUSER;
GRANT USAGE ON SCHEMA tienda TO Cliente;
GRANT USAGE, SELECT ON SEQUENCE tienda.auditoria_id_seq TO Cliente;
GRANT INSERT ON TABLE tienda.UTieneE, tienda.UDeseaD, tienda.auditoria TO Cliente;
GRANT DELETE ON tienda.UDeseaD, tienda.UTieneE TO Cliente;
GRANT SELECT ON ALL TABLES IN SCHEMA tienda TO Cliente;
REVOKE SELECT ON tienda.Usuarios FROM Cliente;


CREATE ROLE Invitado WITH NOSUPERUSER;
GRANT USAGE ON SCHEMA tienda TO Invitado;
GRANT SELECT ON TABLE tienda.Grupos, tienda.Discos, tienda.Canciones, tienda.vista_usuarios_cliente TO Invitado;

CREATE USER suMajestad WITH PASSWORD '1234';
GRANT Administrador TO suMajestad;

CREATE USER virrey WITH PASSWORD 'ABCD';
GRANT Gestor TO virrey;

DO $$
DECLARE
    ent RECORD;
BEGIN
    FOR ent IN SELECT nombre_usuario, contrasena FROM tienda.Usuarios
    LOOP
        EXECUTE format('CREATE USER %I WITH PASSWORD %L', ent.nombre_usuario, ent.contrasena);
        EXECUTE format('GRANT Cliente TO %I', ent.nombre_usuario);
    END LOOP;
END $$;

CREATE USER forastero WITH PASSWORD 'XYZ';
GRANT Invitado TO forastero;

COMMIT;