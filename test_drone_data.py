#!/usr/bin/env python3
"""
Simulateur de données drone pour tests.
Usage: python test_drone_data.py [--url http://localhost:5000] [--interval 1.0]
"""
import requests
import time
import math
import argparse

START_TIME = time.time()

def generate_drone_data(t):
    # Altitude: decollage, croisiere, atterrissage
    if t < 30:
        altitude = t * 3
    elif t < 90:
        altitude = 90 - (t - 30) * 0.5
    else:
        altitude = max(0.0, 60 - (t - 90) * 2)

    speed        = max(0.0, 10 * math.sin(t / 20) + 8)
    pitch        = 15 * math.sin(t / 15)
    roll         = 10 * math.cos(t / 12)
    yaw          = (t * 3) % 360
    temperature  = 35 + 20 * math.sin(t / 40) + (5 if altitude > 0 else 0)
    battery      = max(8.0, 12.0 - (t / 300) * 4)

    # Acceleration: pics au decollage et aux manoeuvres
    acceleration = abs(9.81 + 2 * math.sin(t / 5) + (altitude > 0) * 0.5)

    # Pression atmospherique: diminue avec l'altitude (~1 hPa / 8m)
    pressure     = 1013.25 - (altitude / 8.0)

    alerts = []
    if battery < 10.0:
        alerts.append("Batterie faible")
    if temperature > 55:
        alerts.append("Surchauffe moteur")
    if altitude > 80:
        alerts.append("Altitude maximale atteinte")

    return {
        "pitch":        round(pitch, 2),
        "roll":         round(roll, 2),
        "yaw":          round(yaw, 2),
        "altitude":     round(altitude, 2),
        "speed":        round(speed, 2),
        "battery":      round(battery, 2),
        "temperature":  round(temperature, 2),
        "acceleration": round(acceleration, 3),
        "pressure":     round(pressure, 2),
        "alerts":       alerts,
    }

def send_data(server_url, data):
    try:
        response = requests.post(f"{server_url}/drone-data", json=data, timeout=5)
        if response.status_code == 200:
            alerts_str = f" /!\\ {data['alerts']}" if data['alerts'] else ""
            print(
                f"[OK] Alt={data['altitude']:6.1f}m | "
                f"Vit={data['speed']:5.1f}m/s | "
                f"Bat={data['battery']:5.2f}V | "
                f"Accel={data['acceleration']:5.2f}m/s2 | "
                f"Press={data['pressure']:7.2f}hPa"
                f"{alerts_str}"
            )
            return True
        else:
            print(f"[ERR] {response.status_code}: {response.text}")
            return False
    except requests.exceptions.ConnectionError:
        print(f"[ERR] Impossible de se connecter a {server_url} -- le serveur est-il demarre?")
        return False
    except Exception as e:
        print(f"[ERR] {e}")
        return False

def continuous_stream(server_url, interval=1.0):
    global START_TIME
    START_TIME = time.time()
    print(f"[SIMULATION] Demarrage du vol vers {server_url}")
    print(f"   Intervalle: {interval}s | Ctrl+C pour arreter")
    print(f"   Sequence: decollage (0-30s) -> croisiere (30-90s) -> atterrissage (90s+)")
    print("-" * 80)
    try:
        while True:
            t = time.time() - START_TIME
            data = generate_drone_data(t)
            send_data(server_url, data)
            time.sleep(interval)
    except KeyboardInterrupt:
        print("\n[STOP] Simulation arretee.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Simulateur de donnees drone")
    parser.add_argument("--url",      default="http://localhost:5000")
    parser.add_argument("--interval", type=float, default=1.0)
    args = parser.parse_args()
    continuous_stream(args.url, args.interval)
