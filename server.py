from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

latest_telemetry = {
    "pitch": 0.0,
    "roll": 0.0,
    "yaw": 0.0,
    "altitude": 0.0,
    "speed": 0.0,
    "battery": 12.0,
    "temperature": 25.0,
    "acceleration": 0.0,
    "pressure": 1013.25,
    "alerts": []
}

@app.route('/latest-data', methods=['GET'])
def get_latest_data():
    return jsonify(latest_telemetry), 200

@app.route('/drone-data', methods=['POST'])
def receive_drone_data():
    global latest_telemetry
    data = request.get_json(force=True)
    if data:
        for key in ["pitch", "roll", "yaw", "altitude", "speed", "battery",
                    "temperature", "acceleration", "pressure", "alerts"]:
            if key in data:
                latest_telemetry[key] = data[key]
        print(f"[RECU] Alt={latest_telemetry['altitude']}m | "
              f"Vit={latest_telemetry['speed']}m/s | "
              f"Bat={latest_telemetry['battery']}V | "
              f"Accel={latest_telemetry['acceleration']}m/s2 | "
              f"Press={latest_telemetry['pressure']}hPa")
        return jsonify({"status": "success"}), 200
    return jsonify({"error": "No data provided"}), 400

@app.route('/dashboard/telemetry', methods=['GET', 'POST'])
def manage_telemetry():
    global latest_telemetry
    if request.method == 'POST':
        data = request.get_json(force=True)
        if data:
            for key in latest_telemetry:
                if key in data:
                    latest_telemetry[key] = data[key]
            return jsonify({"status": "success"}), 200
        return jsonify({"error": "No data provided"}), 400
    return jsonify(latest_telemetry), 200

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok", "drone_connected": latest_telemetry["altitude"] > 0}), 200

if __name__ == '__main__':
    print("=========================================================")
    print("  [OK] Serveur Drone Monitoring - demarre!")
    print("=========================================================")
    print("  Flutter lit les donnees sur  : http://localhost:5000/latest-data")
    print("  Script de test envoie vers   : http://localhost:5000/drone-data")
    print("  Mission Planner envoie vers  : http://localhost:5000/dashboard/telemetry")
    print("=========================================================")
    app.run(host='0.0.0.0', port=5000, debug=False)
