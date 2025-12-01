import pymysql
import pymysql.cursors
from flask import Flask, request, jsonify
import bcrypt

app = Flask(__name__)

# --- CONFIGURACIÓN DE LA BASE DE DATOS ---
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': '1234',
    'database': 'BALAMBEH',
    'cursorclass': pymysql.cursors.DictCursor
}

def get_db_connection():
    try:
        connection = pymysql.connect(**db_config)
        return connection
    except pymysql.MySQLError as e:
        print(f"Error connecting to Database: {e}")
        return None

# -----------------------------------------------------------
#                      ENDPOINT DE CLIENTES
# -----------------------------------------------------------

@app.route('/api/register/client', methods=['POST'])
def register_client():
    data = request.json
    nombre = data.get('nombre')
    nombre_user = data.get('nombreuser')
    password = data.get('contraseña')
    
    if not all([nombre, nombre_user, password]):
        return jsonify({"message": "Faltan campos obligatorios"}), 400

    salt = bcrypt.gensalt()
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), salt)
    
    conn = get_db_connection()
    if not conn: return jsonify({"message": "Fallo DB"}), 500

    try:
        with conn.cursor() as cur:
            cur.execute("INSERT INTO CLIENTES (NOMBRE, NOMBREUSER, CONTRASEÑA) VALUES (%s, %s, %s)", (nombre, nombre_user, hashed_password))
        conn.commit()
        return jsonify({"message": "Cliente registrado exitosamente"}), 201
    except Exception as e:
        return jsonify({"message": f"Registro fallido: {str(e)}"}), 409
    finally:
        conn.close()

@app.route('/api/login/client', methods=['POST'])
def login_client():
    data = request.json
    nombre_user = data.get('nombreuser')
    password = data.get('contraseña')

    if not all([nombre_user, password]):
        return jsonify({"message": "Falta usuario o contraseña"}), 400
        
    conn = get_db_connection()
    if not conn: return jsonify({"message": "Fallo DB"}), 500

    try:
        with conn.cursor() as cur:
            cur.execute("SELECT NOMBRE, CONTRASEÑA FROM CLIENTES WHERE NOMBREUSER = %s", [nombre_user])
            user_record = cur.fetchone()
        
        if user_record:
            stored_hash = user_record['CONTRASEÑA']
            if isinstance(stored_hash, str): stored_hash = stored_hash.encode('utf-8')

            if bcrypt.checkpw(password.encode('utf-8'), stored_hash):
                return jsonify({
                    "message": "Login exitoso", 
                    "user_type": "client",
                    "nombre": user_record['NOMBRE']
                }), 200
            else:
                return jsonify({"message": "Credenciales inválidas"}), 401
        else:
            return jsonify({"message": "Usuario no encontrado"}), 401
    finally:
        conn.close()

# -----------------------------------------------------------
#                      ENDPOINT DE CONDUCTORES
# -----------------------------------------------------------

@app.route('/api/register/conductor', methods=['POST'])
def register_conductor():
    data = request.json
    
    nombre = data.get('nombre')
    username = data.get('username')
    password = data.get('contraseña')
    fecha_nacimiento = data.get('fecha_nacimiento')
    localidad = data.get('localidad')
    rfc = data.get('rfc')
    numero = data.get('numero')
    vehiculo = data.get('vehiculo')
    anio_vehiculo = data.get('año_vehiculo')
    tipo_vehiculo = data.get('tipo_vehiculo')
    tarjeta_url = data.get('tarjeta_circulacion_url') 

    salt = bcrypt.gensalt()
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), salt)
    
    conn = get_db_connection()
    if not conn: return jsonify({"message": "Fallo DB"}), 500

    try:
        with conn.cursor() as cur:
            query = """INSERT INTO CONDUCTORES (NOMBRE, USERNAME, CONTRASEÑA, FECHA_NACIMIENTO, LOCALIDAD, RFC, NUMERO, VEHICULO, AÑO_VEHICULO, TIPO_VEHICULO, TARJETA_CIRCULACION_URL) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"""
            cur.execute(query, (nombre, username, hashed_password, fecha_nacimiento, localidad, rfc, numero, vehiculo, anio_vehiculo, tipo_vehiculo, tarjeta_url))
        conn.commit()
        return jsonify({"message": "Conductor registrado exitosamente"}), 201
    except Exception as e:
        return jsonify({"message": f"Error al registrar: {str(e)}"}), 409
    finally:
        conn.close()

@app.route('/api/login/conductor', methods=['POST'])
def login_conductor():
    data = request.json
    username = data.get('username')
    password = data.get('contraseña')

    if not all([username, password]):
        return jsonify({"message": "Falta usuario o contraseña"}), 400
        
    conn = get_db_connection()
    if not conn: return jsonify({"message": "Fallo DB"}), 500

    try:
        with conn.cursor() as cur:
            # --- MODIFICADO: AHORA TRAEMOS TAMBIÉN EL ID_CONDUCTOR ---
            cur.execute("SELECT ID_CONDUCTOR, NOMBRE, CONTRASEÑA FROM CONDUCTORES WHERE USERNAME = %s", [username])
            user_record = cur.fetchone()

        if user_record:
            stored_hash = user_record['CONTRASEÑA']
            if isinstance(stored_hash, str): stored_hash = stored_hash.encode('utf-8')

            try:
                if bcrypt.checkpw(password.encode('utf-8'), stored_hash):
                    return jsonify({
                        "message": "Login exitoso", 
                        "user_type": "conductor",
                        "id_conductor": user_record['ID_CONDUCTOR'], # --- NUEVO: ENVIAMOS EL ID ---
                        "nombre": user_record['NOMBRE']
                    }), 200
                else:
                    return jsonify({"message": "Credenciales inválidas"}), 401
            except ValueError:
                return jsonify({"message": "Error datos corruptos"}), 500
        else:
            return jsonify({"message": "Usuario no encontrado"}), 401
    finally:
        conn.close()

@app.route('/api/conductor/verification/<string:username>', methods=['GET'])
def get_verification_status(username):
    conn = get_db_connection()
    if not conn: return jsonify({"message": "Fallo DB"}), 500

    try:
        with conn.cursor() as cur:
            cur.execute("SELECT TARJETA_CIRCULACION_URL FROM CONDUCTORES WHERE USERNAME = %s", [username])
            result = cur.fetchone()

        if result:
            url = result['TARJETA_CIRCULACION_URL']
            is_uploaded = url is not None and len(url) > 0
            
            return jsonify({
                "username": username,
                "card_uploaded": is_uploaded
            }), 200
        else:
            return jsonify({"message": "Usuario no encontrado"}), 404
    finally:
        conn.close()

# -----------------------------------------------------------
#              ZONA NUEVA: RUTAS Y VIAJES
# -----------------------------------------------------------

# 1. OBTENER LISTA DE RUTAS (Para llenar el Dropdown en Flutter)
@app.route('/api/rutas', methods=['GET'])
def obtener_rutas():
    conn = get_db_connection()
    if not conn: return jsonify({"message": "Fallo DB"}), 500

    try:
        with conn.cursor() as cur:
            # Seleccionamos las rutas disponibles
            cur.execute("SELECT ID_RUTA, NOMBRE_RUTA, ORIGEN, DESTINO FROM RUTAS")
            rutas = cur.fetchall()
            
        return jsonify({
            "success": True,
            "data": rutas # Esto es lo que lee tu Flutter: _availableRoutes
        }), 200
    except Exception as e:
        return jsonify({"message": f"Error al obtener rutas: {str(e)}"}), 500
    finally:
        conn.close()

# 2. INICIAR TURNO (Crear registro en VIAJES_ACTIVOS)
@app.route('/api/viajes/iniciar', methods=['POST'])
def iniciar_viaje():
    data = request.json
    id_conductor = data.get('id_conductor')
    id_ruta = data.get('id_ruta')

    if not all([id_conductor, id_ruta]):
        return jsonify({"message": "Faltan datos"}), 400

    conn = get_db_connection()
    if not conn: return jsonify({"message": "Fallo DB"}), 500

    try:
        with conn.cursor() as cur:
            # --- PASO 1 (NUEVO): Borrar solicitudes viejas de este conductor ---
            # Buscamos si tiene un viaje activo y borramos sus solicitudes primero
            cur.execute("""
                DELETE FROM SOLICITUDES 
                WHERE ID_VIAJE IN (
                    SELECT ID_VIAJE FROM VIAJES_ACTIVOS WHERE ID_CONDUCTOR = %s
                )
            """, [id_conductor])

            # --- PASO 2: Borrar el viaje activo viejo (Ahora sí dejará) ---
            cur.execute("DELETE FROM VIAJES_ACTIVOS WHERE ID_CONDUCTOR = %s", [id_conductor])
            
            # --- PASO 3: Insertar nuevo viaje ---
            query = """
                INSERT INTO VIAJES_ACTIVOS (ID_CONDUCTOR, ID_RUTA, LATITUD, LONGITUD, ESTADO)
                VALUES (%s, %s, 0.0, 0.0, 'ESPERANDO')
            """
            cur.execute(query, (id_conductor, id_ruta))
        
        conn.commit()
        return jsonify({"success": True, "message": "Viaje iniciado correctamente"}), 201

    except Exception as e:
        conn.rollback()
        return jsonify({"message": f"Error al iniciar viaje: {str(e)}"}), 500
    finally:
        conn.close()
# 3. TERMINAR TURNO (Borrar de VIAJES_ACTIVOS)
@app.route('/api/viajes/terminar', methods=['POST'])
def terminar_viaje():
    data = request.json
    id_conductor = data.get('id_conductor')

    conn = get_db_connection()
    if not conn: return jsonify({"message": "Fallo DB"}), 500

    try:
        with conn.cursor() as cur:
            # --- PASO 1 (NUEVO): Borrar solicitudes pendientes de este viaje ---
            cur.execute("""
                DELETE FROM SOLICITUDES 
                WHERE ID_VIAJE IN (
                    SELECT ID_VIAJE FROM VIAJES_ACTIVOS WHERE ID_CONDUCTOR = %s
                )
            """, [id_conductor])

            # --- PASO 2: Borrar el viaje activo ---
            cur.execute("DELETE FROM VIAJES_ACTIVOS WHERE ID_CONDUCTOR = %s", [id_conductor])
        
        conn.commit()
        return jsonify({"success": True, "message": "Viaje finalizado"}), 200

    except Exception as e:
        conn.rollback() # Importante rollback si falla
        return jsonify({"message": f"Error: {str(e)}"}), 500
    finally:
        conn.close()

# -----------------------------------------------------------
#              ZONA PASAJEROS: BÚSQUEDA DE VIAJES
# -----------------------------------------------------------

@app.route('/api/viajes/buscar', methods=['POST'])
def buscar_vans():
    data = request.json
    pueblo = data.get('pueblo') # El usuario escribe: "Akil"

    if not pueblo:
        return jsonify({"message": "Escribe un pueblo"}), 400

    conn = get_db_connection()
    if not conn: return jsonify({"message": "Fallo DB"}), 500

    try:
        with conn.cursor() as cur:
            # ESTA ES LA MAGIA: Unimos tablas para encontrar la coincidencia
            query = """
                SELECT 
                    V.ID_VIAJE,
                    R.NOMBRE_RUTA,
                    C.NOMBRE AS CONDUCTOR,
                    C.VEHICULO,
                    C.NUMERO AS PLACA,
                    V.ESTADO
                FROM VIAJES_ACTIVOS V
                JOIN RUTAS R ON V.ID_RUTA = R.ID_RUTA
                JOIN PARADAS_RUTA P ON R.ID_RUTA = P.ID_RUTA
                JOIN CONDUCTORES C ON V.ID_CONDUCTOR = C.ID_CONDUCTOR
                WHERE P.NOMBRE_PUEBLO LIKE %s 
                AND V.ESTADO IN ('ESPERANDO', 'EN_CAMINO')
            """
            # Usamos %pueblo% para buscar coincidencias parciales (ej: "akil" encuentra "Akil")
            cur.execute(query, ("%" + pueblo + "%",))
            resultados = cur.fetchall()

        return jsonify({
            "success": True,
            "data": resultados
        }), 200

    except Exception as e:
        return jsonify({"message": f"Error busqueda: {str(e)}"}), 500
    finally:
        conn.close()

# -----------------------------------------------------------
#              ZONA SOLICITUDES (INTERACCIÓN REAL)
# -----------------------------------------------------------

# 1. PASAJERO: Crear solicitud
@app.route('/api/solicitudes/crear', methods=['POST'])
def crear_solicitud():
    data = request.json
    id_viaje = data.get('id_viaje')
    id_cliente = data.get('id_cliente') 
    nombre_cliente = data.get('nombre_cliente')

    conn = get_db_connection()
    if not conn: return jsonify({"message": "Fallo DB"}), 500

    try:
        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO SOLICITUDES (ID_VIAJE, ID_CLIENTE, NOMBRE_CLIENTE, ESTADO)
                VALUES (%s, %s, %s, 'PENDIENTE')
            """, (id_viaje, id_cliente, nombre_cliente))

            new_id = cur.lastrowid
        conn.commit()
        return jsonify({"success": True, "id_solicitud": new_id}), 201
        #return jsonify({"success": True, "message": "Solicitud enviada"}), 201
    except Exception as e:
        return jsonify({"success": False, "message": str(e)}), 500
    finally:
        conn.close()

@app.route('/api/solicitudes/estado/<int:id_solicitud>', methods=['GET'])
def verificar_estado(id_solicitud):
    conn = get_db_connection()
    if not conn: return jsonify({"message": "Fallo DB"}), 500

    try:
        with conn.cursor() as cur:
            cur.execute("SELECT ESTADO FROM SOLICITUDES WHERE ID_SOLICITUD = %s", [id_solicitud])
            result = cur.fetchone()
        
        if result:
            return jsonify({"success": True, "estado": result['ESTADO']}), 200
        else:
            return jsonify({"success": False, "message": "No encontrada"}), 404
    finally:
        conn.close()

# 2. CONDUCTOR: Revisar si tiene solicitudes pendientes (Polling)
@app.route('/api/conductor/checar_solicitudes/<int:id_conductor>', methods=['GET'])
def checar_solicitudes(id_conductor):
    conn = get_db_connection()
    if not conn: return jsonify({"message": "Fallo DB"}), 500

    try:
        with conn.cursor() as cur:
            # Buscamos solicitudes PENDIENTES para el viaje activo de ESTE conductor
            query = """
                SELECT S.ID_SOLICITUD, S.NOMBRE_CLIENTE, R.NOMBRE_RUTA
                FROM SOLICITUDES S
                JOIN VIAJES_ACTIVOS V ON S.ID_VIAJE = V.ID_VIAJE
                JOIN RUTAS R ON V.ID_RUTA = R.ID_RUTA
                WHERE V.ID_CONDUCTOR = %s AND S.ESTADO = 'PENDIENTE'
            """
            cur.execute(query, (id_conductor,))
            solicitudes = cur.fetchall()
        
        return jsonify({"success": True, "data": solicitudes}), 200
    finally:
        conn.close()

# 3. CONDUCTOR: Aceptar o Rechazar
@app.route('/api/conductor/responder_solicitud', methods=['POST'])
def responder_solicitud():
    data = request.json
    id_solicitud = data.get('id_solicitud')
    accion = data.get('accion') # 'ACEPTADO' o 'RECHAZADO'

    conn = get_db_connection()
    if not conn: return jsonify({"message": "Fallo DB"}), 500

    try:
        with conn.cursor() as cur:
            cur.execute("UPDATE SOLICITUDES SET ESTADO = %s WHERE ID_SOLICITUD = %s", (accion, id_solicitud))
        conn.commit()
        return jsonify({"success": True}), 200
    finally:
        conn.close()

# 5. OBTENER PUNTOS DE UNA RUTA (Para dibujar el mapa)
@app.route('/api/rutas/puntos/<int:id_ruta>', methods=['GET'])
def obtener_puntos_ruta(id_ruta):
    conn = get_db_connection()
    try:
        with conn.cursor() as cur:
            query = """
                SELECT LATITUD, LONGITUD, NOMBRE_PUEBLO 
                FROM PARADAS_RUTA 
                WHERE ID_RUTA = %s 
                ORDER BY ORDEN ASC
            """
            cur.execute(query, (id_ruta,))
            puntos = cur.fetchall()
        return jsonify({"success": True, "data": puntos}), 200
    finally:
        conn.close()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)