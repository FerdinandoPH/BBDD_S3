--CREATE TABLE auditoria (
--  accion text,
--  fecha timestamp	 
--);

-- Se crea la función que se ejecutará 
\c tienda_db
BEGIN;

CREATE OR REPLACE FUNCTION fn_auditoria() RETURNS TRIGGER AS $fn_auditoria$
  DECLARE
  BEGIN
   INSERT INTO tienda.auditoria (tabla_afectada, accion, usuario, fecha)
   VALUES (TG_TABLE_NAME, TG_OP, session_user,current_timestamp); -- Cuando hay una inserción, modificación o borrado
   RETURN NULL;
  END;
$fn_auditoria$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_gestionar_usuarios() RETURNS TRIGGER AS $fn_gestionar_usuarios$ --Al añadir/borrar un usuario de la tabla Usuarios, se crea/elimina un usuario con el rol Cliente en la base de datos
  DECLARE
  BEGIN
    IF TG_OP='INSERT' THEN
      EXECUTE format('CREATE USER %I WITH PASSWORD %L', NEW.nombre_usuario, NEW.contrasena);
      EXECUTE format('GRANT Cliente TO %I', NEW.nombre_usuario);
    ELSIF TG_OP='DELETE' THEN
      EXECUTE format('DROP USER %I', OLD.nombre_usuario);
    ELSIF TG_OP='UPDATE' THEN
      IF OLD.nombre_usuario != NEW.nombre_usuario THEN
        EXECUTE format('ALTER USER %I RENAME TO %I', OLD.nombre_usuario, NEW.nombre_usuario);
      END IF;
      IF OLD.contrasena != NEW.contrasena THEN
        EXECUTE format('ALTER USER %I WITH PASSWORD %L', NEW.nombre_usuario, NEW.contrasena);
      END IF;
    END IF;
    RETURN NULL;
  END;
$fn_gestionar_usuarios$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_restringir_edicion() RETURNS TRIGGER AS $fn_restringir_edicion$ --Impide que un usuario modifique o borre tuplas de otros usuarios en UTieneE y UDeseaD
  DECLARE
  BEGIN
    IF NEW.usuario_nombre_usuario != session_user AND session_user IN (SELECT nombre_usuario FROM tienda.vista_usuarios_cliente) THEN
      RAISE NOTICE 'El usuario no puede insertar, modificar o borrar tuplas de otros usuarios';
      RETURN NULL;
    END IF;
    IF TG_OP='DELETE' THEN
      RETURN OLD;
    ELSE
      RETURN NEW;
    END IF;
  END;
$fn_restringir_edicion$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_tienes_lo_que_deseas() RETURNS TRIGGER AS $fn_tienes_lo_que_deseas$ -- Si un usuario añade un disco a UTieneE que ya tiene en UDeseaD, se elimina de UDeseaD
  DECLARE
  BEGIN
    IF TG_OP='INSERT' THEN
      IF EXISTS (SELECT * FROM tienda.UDeseaD WHERE usuario_nombre_usuario = NEW.usuario_nombre_usuario AND disco_titulo = NEW.disco_titulo AND disco_anno_publicacion = NEW.disco_anno_publicacion) THEN
        DELETE FROM tienda.UDeseaD WHERE usuario_nombre_usuario = NEW.usuario_nombre_usuario AND disco_titulo = NEW.disco_titulo AND disco_anno_publicacion = NEW.disco_anno_publicacion;
        RAISE NOTICE 'El disco % ha sido eliminado de UDeseaD', NEW.disco_titulo;
      END IF;
    END IF;
    RETURN NULL;
  END;
$fn_tienes_lo_que_deseas$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_ultimo_id() RETURNS TRIGGER AS $fn_ultimo_id$ -- Hace que al añadir una entrada a UTieneE se use el id de la última entrada de la tabla
  DECLARE
  BEGIN
    NEW.id = (SELECT MAX(id) FROM tienda.UTieneE) + 1;
    RETURN NEW;
  END;
$fn_ultimo_id$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tg_tienes_lo_que_deseas AFTER INSERT ON tienda.UTieneE FOR EACH ROW EXECUTE PROCEDURE fn_tienes_lo_que_deseas();
CREATE OR REPLACE TRIGGER tg_gestionar_usuarios AFTER INSERT OR UPDATE OR DELETE ON tienda.Usuarios FOR EACH ROW EXECUTE PROCEDURE fn_gestionar_usuarios();
CREATE OR REPLACE TRIGGER tg_restringir_edicion BEFORE INSERT OR UPDATE OR DELETE ON tienda.UTieneE FOR EACH ROW EXECUTE PROCEDURE fn_restringir_edicion();
CREATE OR REPLACE TRIGGER tg_restringir_edicion BEFORE INSERT OR UPDATE OR DELETE ON tienda.UDeseaD FOR EACH ROW EXECUTE PROCEDURE fn_restringir_edicion();
CREATE OR REPLACE TRIGGER tg_ultimo_id BEFORE INSERT ON tienda.UTieneE FOR EACH ROW EXECUTE PROCEDURE fn_ultimo_id();
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'tienda')
    LOOP
        IF r.tablename = 'auditoria' THEN
            CONTINUE;
        END IF;
        EXECUTE format('CREATE TRIGGER tg_auditoria_%I AFTER INSERT OR UPDATE OR DELETE ON tienda.%I FOR EACH ROW EXECUTE PROCEDURE fn_auditoria();', r.tablename, r.tablename);
    END LOOP;
END $$;
COMMIT;