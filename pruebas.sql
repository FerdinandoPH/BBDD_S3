\c tienda_db



BEGIN;

-- Prueba de tg_tienes_lo_que_deseas, tg_restringir_edicion y tg_ultimo_id
SELECT * FROM tienda.UDeseaD WHERE usuario_nombre_usuario = 'juangomez' AND disco_titulo = 'Home To You';
INSERT INTO tienda.UTieneE VALUES ('juangomez', 'Home To You', 1970, 'UK', 2010, 'Vinyl', 'NM');

SELECT * FROM tienda.auditoria
ORDER BY fecha DESC
LIMIT 1;

SELECT * FROM tienda.UDeseaD WHERE usuario_nombre_usuario = 'juangomez' AND disco_titulo = 'Home To You';


-- Prueba de tg_restringir_edicion y tg_ultimo_id    Entrar con estos usuarios para que funcione y con otros para que no funcione
\echo 'Introduce un disco a la lista de deseados de juangomez'
INSERT INTO tienda.UDeseaD VALUES ('juangomez', 'The Cave', 2014);
SELECT * FROM tienda.UDeseaD WHERE usuario_nombre_usuario = 'juangomez' AND disco_titulo = 'The Cave';

\echo 'Introduce un disco a las pertenencias de lorenasaez'
INSERT INTO tienda.UTieneE VALUES ('lorenasaez', 'Thank You', 2001, 'UK', 2001, 'Vinyl', 'M');
SELECT * FROM tienda.UTieneE WHERE usuario_nombre_usuario = 'lorenasaez' AND disco_titulo = 'Thank You';


-- Prueba de tg_gestionar_usuarios    ¡ENTRAR COMO SUPERUSUARIO! (usuario suMajestad)
\echo 'Se añade "Nuevo Usu" a Usuarios'
INSERT INTO tienda.Usuarios VALUES ('Nuevo Usu', 'ejemplo@gmail.com', 'Pepito Pérez', 'contraseña');

\du

\echo 'Se borra "Nuevo Usu" de Usuarios'
DELETE FROM tienda.Usuarios WHERE (nombre_usuario = 'Nuevo Usu');

\du

ROLLBACK;
