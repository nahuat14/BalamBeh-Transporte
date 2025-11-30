import pymysql
import pymysql.cursors
from flask import Flask, request, jsonify
import bcrypt

app = Flask(__name__)

# --- CONFIGURACIÓN DE LA BASE DE DATOS ---
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': '1234', # <--- TU CONTRASEÑA ACTUAL
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
            # Traemos NOMBRE y CONTRASEÑA
            cur.execute("SELECT NOMBRE, CONTRASEÑA FROM CONDUCTORES WHERE USERNAME = %s", [username])
            user_record = cur.fetchone()

        if user_record:
            stored_hash = user_record['CONTRASEÑA']
            if isinstance(stored_hash, str): stored_hash = stored_hash.encode('utf-8')

            try:
                if bcrypt.checkpw(password.encode('utf-8'), stored_hash):
                    return jsonify({
                        "message": "Login exitoso", 
                        "user_type": "conductor",
                        "nombre": user_record['NOMBRE'] # Enviamos el nombre
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

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)