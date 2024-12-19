import psycopg2, getpass
from psycopg2 import OperationalError
consultas = ["SELECT d.titulo, d.anno_publicacion, COUNT(*) AS num_canciones\nFROM tienda.Discos d JOIN tienda.Canciones c ON d.titulo = c.disco_titulo AND d.anno_publicacion = c.disco_anno_publicacion\nGROUP BY d.titulo, d.anno_publicacion\nHAVING COUNT(*) > 5\nORDER BY num_canciones","\nSELECT u.nombre_usuario, u.nombre, e.disco_titulo, e.disco_anno_publicacion, e.edicion_pais, e.edicion_anno_edicion, e.edicion_formato, e.estado\nFROM tienda.UTieneE e\nJOIN tienda.Usuarios u ON e.usuario_nombre_usuario = u.nombre_usuario\nWHERE u.nombre LIKE 'Juan García Gómez' AND e.edicion_formato = 'Vinyl'","\nWITH DuracionesDisco AS (\n    SELECT d.titulo, d.anno_publicacion, SUM(c.duracion) AS duracion_total\n    FROM tienda.Discos d JOIN tienda.Canciones c ON d.titulo = c.disco_titulo AND d.anno_publicacion = c.disco_anno_publicacion\n    GROUP BY d.titulo, d.anno_publicacion\n    HAVING SUM(c.duracion) IS NOT NULL\n)\nSELECT d.titulo, d.anno_publicacion, SUM(c.duracion) AS duracion_total\nFROM tienda.Discos d JOIN tienda.Canciones c ON d.titulo = c.disco_titulo AND d.anno_publicacion = c.disco_anno_publicacion\nGROUP BY d.titulo, d.anno_publicacion\nHAVING SUM(c.duracion) >= ALL(SELECT duracion_total FROM DuracionesDisco)","\nSELECT u.nombre_usuario, u.nombre, udd.disco_titulo, udd.disco_anno_publicacion, d.grupo_nombre\nFROM tienda.Usuarios u JOIN tienda.UDeseaD udd ON u.nombre_usuario = udd.usuario_nombre_usuario\nJOIN tienda.Discos d ON udd.disco_titulo = d.titulo AND udd.disco_anno_publicacion = d.anno_publicacion\nWHERE u.nombre LIKE 'Juan García Gómez'","\nSELECT disco_titulo, disco_anno_publicacion, anno_edicion, pais, formato\nFROM tienda.Ediciones\nWHERE disco_anno_publicacion BETWEEN 1970 AND 1972\nORDER BY disco_anno_publicacion, disco_titulo","\nSELECT DISTINCT d.grupo_nombre\nFROM tienda.Discos d JOIN tienda.GenerosDisco gd ON d.titulo = gd.disco_titulo AND d.anno_publicacion = gd.disco_anno_publicacion\nWHERE gd.genero = 'Electronic'","\nSELECT DISTINCT d.titulo, d.anno_publicacion, SUM(c.duracion) AS duracion_total\nFROM tienda.Discos d\nJOIN tienda.Canciones c ON d.titulo = c.disco_titulo AND d.anno_publicacion = c.disco_anno_publicacion\nJOIN tienda.Ediciones e ON d.titulo = e.disco_titulo AND d.anno_publicacion = e.disco_anno_publicacion\nWHERE e.anno_edicion < 2000\nGROUP BY d.titulo, d.anno_publicacion","\nSELECT ut.nombre AS lo_tiene, ud.nombre AS lo_desea, ute.disco_titulo, ute.disco_anno_publicacion, ute.edicion_pais, ute.edicion_anno_edicion, ute.edicion_formato, ute.estado\nFROM tienda.UTieneE ute JOIN tienda.UDeseaD udd ON ute.disco_titulo = udd.disco_titulo AND ute.disco_anno_publicacion = udd.disco_anno_publicacion JOIN tienda.Usuarios ud ON udd.usuario_nombre_usuario = ud.nombre_usuario JOIN tienda.Usuarios ut ON ute.usuario_nombre_usuario = ut.nombre_usuario\nWHERE ut.nombre LIKE 'Juan García Gómez' AND ud.nombre LIKE 'Lorena Sáez Pérez'","\nSELECT u.nombre AS nombre_del_usuario, ute.disco_titulo, ute.disco_anno_publicacion, ute.edicion_pais, ute.edicion_anno_edicion, ute.edicion_formato, ute.estado, ute.id\nFROM tienda.UTieneE ute JOIN tienda.Usuarios u ON ute.usuario_nombre_usuario = u.nombre_usuario\nWHERE u.nombre LIKE '%%Gómez García%%' AND (ute.estado = 'NM' OR ute.estado = 'M')","\nSELECT u.nombre_usuario, COUNT(ute.id),MIN(ute.disco_anno_publicacion)::INTEGER, MAX(ute.disco_anno_publicacion)::INTEGER, AVG(ute.disco_anno_publicacion)::INTEGER\nFROM tienda.Usuarios u JOIN tienda.UTieneE ute ON u.nombre_usuario = ute.usuario_nombre_usuario\nGROUP BY u.nombre_usuario","\nSELECT d.grupo_nombre, COUNT(*)\nFROM tienda.Discos d JOIN tienda.Ediciones e ON d.titulo = e.disco_titulo AND d.anno_publicacion = e.disco_anno_publicacion\nGROUP BY d.grupo_nombre\nHAVING COUNT(*) > 5","\nWITH discos_por_usuario AS (\n    SELECT usuario_nombre_usuario, COUNT(id) AS num_discos\n    FROM tienda.UTieneE\n    GROUP BY usuario_nombre_usuario\n)\nSELECT usuario_nombre_usuario, COUNT(id)\nFROM tienda.UTieneE\nGROUP BY usuario_nombre_usuario\nHAVING COUNT(id) >= ALL(SELECT num_discos FROM discos_por_usuario)"]
opciones = ["Salir", "Ver consultas", "Crear nuevo disco"]

class portException(Exception): pass

def obtener_datos_conexion():
    host = input('Host: ')
    while 'ñ':
        try:
            puerto = input('Puerto: ')
            puerto = 5432 if puerto == '' else int(puerto)
            if (puerto < 1024) or (puerto > 65535):
                raise ValueError
            else:
                break
        except ValueError:
            print('Número de puerto inválido')
            continue
    if host == '': host = 'localhost'
    usuario = input('Usuario: ').lower()
    contrasenna = getpass.getpass('Contraseña: ') 
    return (host, puerto, usuario, contrasenna, "tienda_db")
def hacer_consulta(cur):
    consulta = -1
    while True:
        print(f"¿Qué consulta quieres hacer (1-{len(consultas)})?")
        try:
            consulta = int(input())
            if consulta < 1 or consulta > len(consultas):
                raise ValueError
            break
        except ValueError:
            print('Número de consulta inválido')
            continue
    cur.execute(consultas[consulta-1])
    nombres_columnas = [desc[0] for desc in cur.description]
    print("\t".join(nombres_columnas))
    for fila in cur.fetchall():
        print("\t".join(map(str, fila)))
    print()
def crear_disco(cur):
    titulo = ""
    anno = 0
    while True:
        try:
            titulo = input('Título: ')
            while True:
                try:
                    anno = int(input('Año de publicación: '))
                    break
                except ValueError:
                    print('Año inválido')
                    continue
            enlace_disco = input('Enlace de la portada: ')
            if enlace_disco == '': enlace_disco = None
            while True:
                grupo = input('Grupo: ')
                cur.execute(f"SELECT * FROM tienda.Grupos WHERE nombre = '{grupo}'")
                if cur.fetchone() is None:
                    print("Se va a añadir un nuevo grupo")
                    enlace_grupo = input('URL: ')
                    if enlace_grupo == '': enlace_grupo = None
                    try:
                        cur.execute("INSERT INTO tienda.Grupos VALUES (%s, %s)", (grupo, enlace_grupo))
                        print("Grupo añadido correctamente")
                        break
                    except Exception as e:
                        print(e)
                        otravez = input('¿Quieres intentarlo de nuevo? (s/n) ')
                        if otravez.lower() not in 'sisíyes':
                            return
                        cur.execute("ROLLBACK")
                        continue
                else:
                    break
            cur.execute("INSERT INTO tienda.Discos VALUES (%s, %s, %s, %s)", (titulo, anno, grupo, enlace_disco))
            print("Disco añadido correctamente")
            break
        except Exception as e:
            print(e)
            otravez = input('¿Quieres intentarlo de nuevo? (s/n) ')
            if otravez.lower() not in 'sisíyes':
                return
            continue
    if input("¿Añadir tienda.Canciones al disco? (s/n) ").lower() not in 'sisíyes':
        return
    while True:
        try:
            cancion_titulo = input('Título de la canción: ')
            while True:
                try:
                    duracion = int(input('Duración: '))
                    break
                except ValueError:
                    print('Duración inválida')
                    continue
            cur.execute("INSERT INTO tienda.Canciones VALUES (%s, %s, %s, %s)", (titulo, anno, cancion_titulo, duracion))
            print("Canción añadida correctamente")
            if input("¿Añadir otra canción? (s/n) ").lower() not in 'sisíyes':
                break
        except OperationalError as e:
            print(e)
            otravez = input('¿Quieres intentarlo de nuevo? (s/n) ')
            if otravez.lower() not in 'sisíyes':
                return
        continue


def main():
    try:
        while True:
            try:
                (host, puerto, usuario, contrasenna, base_datos) = obtener_datos_conexion()
                cadena_conexion = f'host={host} port={puerto} user={usuario} password={contrasenna} dbname={base_datos}'
                conexion = psycopg2.connect(cadena_conexion)
                cur = conexion.cursor()
                cur.execute('SET search_path TO tienda')
                break
            except OperationalError as e:
                print(e)
                if input('¿Quieres intentarlo de nuevo? (s/n) ').lower() not in 'sisíyes':
                    return
        salir_bucle_principal = False
        while not salir_bucle_principal:
            print("¿Qué quieres hacer?")
            for i,opt in enumerate(opciones):
                print(f'{i+1}. {opt}')
            print("> ", end="")
            try:
                opcion = int(input())
                if opcion < 1 or opcion > len(opciones):
                    raise ValueError
                opcion -= 1
                match opcion:
                    case 0:
                        salir_bucle_principal = True
                    case 1:
                        hacer_consulta(cur)
                    case 2:
                        crear_disco(cur)
            except ValueError:
                print('Opción inválida')
                continue
            except OperationalError as e:
                print(e)
                continue
    except KeyboardInterrupt:
        print('Programa interrumpido por el usuario.')
    except portException:
        print('Número de puerto inválido')
    except OperationalError as e:
        print(e)
    
if __name__ == '__main__':
    main()