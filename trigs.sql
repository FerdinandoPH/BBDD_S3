--CREATE TABLE auditoria (
--  accion text,
--  fecha timestamp	 
--);

-- Se crea la función que se ejecutará 
\c tienda_db
BEGIN;

CREATE OR REPLACE FUNCTION fn_auditoria() RETURNS TRIGGER AS $fn_auditoria$
  DECLARE
  --  no declaro nada porque no me hace falta...de hecho DECLARE podría haberlo omitido en éste caso
  BEGIN
  -- Se determina que acción a activado el trigger e inserta un nuevo valor en la tabla dependiendo
  -- del dicha acción
  -- Junto con la acción se escribe fecha y hora en la que se ha producido la acción
  --  IF TG_OP='INSERT' THEN
  --    INSERT INTO auditoria VALUES ('alta',current_timestamp);  -- Cuando hay una inserción
  --  ELSIF TG_OP='UPDATE'	THEN
  --    INSERT INTO auditoria VALUES ('modificación',current_timestamp); -- Cuando hay una modificación
  --  ELSIF TG_OP='DELETE' THEN
  --    INSERT INTO auditoria VALUES ('borrado',current_timestamp); -- Cuando hay un borrado
  --  END IF;	 
   INSERT INTO tienda.auditoria (tabla_afectada, accion, usuario, fecha)
   VALUES (TG_TABLE_NAME, TG_OP, session_user,current_timestamp); -- Cuando hay una inserción, modificación o borrado
   RETURN NULL;
  END;
$fn_auditoria$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_gestionar_usuarios() RETURNS TRIGGER AS $fn_gestionar_usuarios$
  DECLARE
  BEGIN
    IF TG_OP='INSERT' THEN
      EXECUTE format('CREATE USER %I WITH PASSWORD %L', NEW.nombre_usuario, NEW.contrasena);
      EXECUTE format('GRANT Cliente TO %I', NEW.nombre_usuario);
    ELSIF TG_OP='DELETE' THEN
      EXECUTE format('DROP USER %I', OLD.nombre_usuario);
    END IF;
    RETURN NULL;
  END;
$fn_gestionar_usuarios$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_restringir_edicion() RETURNS TRIGGER AS $fn_restringir_edicion$
  DECLARE
  BEGIN
    IF NEW.usuario_nombre_usuario != session_user AND session_user IN (SELECT nombre_usuario FROM tienda.vista_usuarios_cliente) THEN
      RAISE EXCEPTION 'El usuario no puede insertar, modificar o borrar tuplas de otros usuarios';
    END IF;
    RETURN NEW;
  END;
$fn_restringir_edicion$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_tienes_lo_que_deseas() RETURNS TRIGGER AS $fn_tienes_lo_que_deseas$
  DECLARE
  BEGIN
    IF TG_OP='INSERT' THEN
      IF EXISTS (SELECT * FROM tienda.UDeseaD WHERE usuario_nombre_usuario = NEW.usuario_nombre_usuario AND disco_titulo = NEW.disco_titulo AND disco_anno_publicacion = NEW.disco_anno_publicacion) THEN
        DELETE FROM tienda.UDeseaD WHERE usuario_nombre_usuario = NEW.usuario_nombre_usuario AND disco_titulo = NEW.disco_titulo AND disco_anno_publicacion = NEW.disco_anno_publicacion;
      END IF;
    END IF;
    RETURN NULL;
  END;
$fn_tienes_lo_que_deseas$ LANGUAGE plpgsql;
CREATE OR REPLACE TRIGGER tg_tienes_lo_que_deseas AFTER INSERT ON tienda.UTieneE FOR EACH ROW EXECUTE PROCEDURE fn_tienes_lo_que_deseas();
CREATE OR REPLACE TRIGGER tg_gestionar_usuarios AFTER INSERT OR DELETE ON tienda.Usuarios FOR EACH ROW EXECUTE PROCEDURE fn_gestionar_usuarios();
CREATE OR REPLACE TRIGGER tg_restringir_edicion BEFORE INSERT OR UPDATE OR DELETE ON tienda.UTieneE FOR EACH ROW EXECUTE PROCEDURE fn_restringir_edicion();
CREATE OR REPLACE TRIGGER tg_restringir_edicion BEFORE INSERT OR UPDATE OR DELETE ON tienda.UDeseaD FOR EACH ROW EXECUTE PROCEDURE fn_restringir_edicion();
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