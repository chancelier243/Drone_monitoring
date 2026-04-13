import clr
import System
import time

# URL de votre serveur Cloudflare (Remplacez par votre URL actuelle si elle a changé)
SERVER_URL = "http://10.201.7.231:5000/dashboard/telemetry"

def send_telemetry():
    # cs (CurrentState) est un objet global fourni par Mission Planner
    pitch = float(cs.pitch)
    roll = float(cs.roll)
    altitude = float(cs.alt)
    speed = float(cs.groundspeed) # ou cs.airspeed
    battery = float(cs.battery_voltage)

    # Création du JSON (format texte classique car les bibliothèques json ne sont pas toujours stables dans IronPython)
    json_data = '{"pitch": %f, "roll": %f, "altitude": %f, "speed": %f, "battery": %f}' % (pitch, roll, altitude, speed, battery)

    try:
        # Envoi de la requête POST
        request = System.Net.WebRequest.Create(SERVER_URL)
        request.Method = "POST"
        request.ContentType = "application/json"
        
        bytes_data = System.Text.Encoding.UTF8.GetBytes(json_data)
        request.ContentLength = bytes_data.Length
        
        reqStream = request.GetRequestStream()
        reqStream.Write(bytes_data, 0, bytes_data.Length)
        reqStream.Close()
        
        response = request.GetResponse()
        response.Close()
        
        print("Donnees envoyees: " + json_data)
    except Exception as e:
        print("Erreur d'envoi: " + str(e))

print("Demarrage du script de telemetrie vers le serveur...")

while True:
    send_telemetry()
    # Met le script en pause pendant 1000 millisecondes (1 seconde)
    Script.Sleep(1000)
