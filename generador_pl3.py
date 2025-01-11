import os
if __name__ == "__main__":
    ruta = os.path.dirname(os.path.realpath(__file__))
    ruta = ruta.replace("\\", "/")
    with open(f"{ruta}/pl3.sql", "w") as f:
        f.write(f"\\i \'{ruta}/crear_db.sql\'\n")
        f.write(f"\\i \'{ruta}/Usu.sql\'\n")
        f.write(f"\\i \'{ruta}/trigs.sql\'\n")
    
