with open('lasConsultas.txt', 'r') as fo:
    with open('lasConsultasBien.txt','w') as ff:
        lineas = fo.readlines()
        lineas_validas = []
        for linea in lineas:
            if not(linea.startswith('\\') or linea.startswith('--') or linea.startswith('\n')):
                lineas_validas.append(linea)
        megastring = '[\"'
        for linea in lineas_validas:
            linea.replace('\n','\\n')
            linea.replace(';', '\",\"')
            megastring += linea
        megastring += '\"]'
        ff.write(megastring)