import requests
import json

# URL de tu servidor local
BASE_URL = "http://localhost:5000"

def crear_conductor():
    print("--- Creando Conductor de Prueba ---")
    url = f"{BASE_URL}/api/register/conductor"
    
    # Datos completos como los enviaría la App en el Paso 3
    payload = {
        "nombre": "Juan Pérez Chofer",
        "username": "chofer01",       # <--- USARÁS ESTE PARA EL LOGIN
        "contraseña": "password123",  # <--- USARÁS ESTA CONTRASEÑA
        "fecha_nacimiento": "1990-05-15",
        "localidad": "Mérida",
        "rfc": "XAXX010101000",
        "numero": "9991234567",
        "vehiculo": "Nissan Tsuru",
        "año_vehiculo": "2015",
        "tipo_vehiculo": "Taxi",
        "tarjeta_circulacion_url": None
    }
    
    try:
        response = requests.post(url, json=payload)
        
        print(f"Status: {response.status_code}")
        print(f"Respuesta: {response.json()}")
        
        if response.status_code == 201:
            print("\n✅ ÉXITO: Usuario 'chofer01' creado.")
            print("👉 Ahora ve a tu App e inicia sesión con:")
            print("   Usuario: chofer01")
            print("   Pass:    password123")
        elif response.status_code == 409:
            print("\n⚠️ El usuario ya existía. Intenta loguearte con esos datos.")
            
    except Exception as e:
        print(f"❌ Error al conectar: {e}")

if __name__ == "__main__":
    crear_conductor()