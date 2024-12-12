import sys
import psycopg2

class portException(Exception): pass

def obtener_datos_conexion():
    host = input('Host: ')
    usuario = input('Usuario: ')
    contrasenna = input('Contraseña: ')
    while 'ñ':
        try:
            puerto = int(input('Puerto: '))
            if (puerto < 1024) or (puerto > 65535):
                raise ValueError
            else:
                return (host, puerto, usuario, contrasenna, "tienda_db")
        except ValueError:
            print('Número de puerto inválido')
            continue

def main():
    try:
        (host, puerto, usuario, contrasenna, base_datos) = obtener_datos_conexion()
        cadena_conexion = f'host={host} port={puerto} user={usuario} password={contrasenna} dbname={base_datos}'
        conexion = psycopg2.connect(cadena_conexion)
        cur = conexion.cursor()
        
    except KeyboardInterrupt:
        print('Programa interrumpido por el usuario.')
    finally:
        print('Programa finalizado.')