\c tienda_db



BEGIN;

SELECT * FROM tienda.UDeseaD WHERE usuario_nombre_usuario = 'juangomez' AND disco_titulo = 'Home To You';
INSERT INTO tienda.UTieneE VALUES ('juangomez', 'Home To You', 1970, 'UK', 2010, 'Vinyl', 'NM');

SELECT * FROM tienda.auditoria
ORDER BY fecha DESC
LIMIT 1;

SELECT * FROM tienda.UDeseaD WHERE usuario_nombre_usuario = 'juangomez' AND disco_titulo = 'Home To You';
\q
--
ROLLBACK;
