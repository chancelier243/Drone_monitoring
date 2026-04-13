# Script PowerShell pour tester l'application Flutter avec des données de test
# Usage: .\test_with_mock_data.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DRONE MONITORING - Test avec données simulées" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Variables
$serverUrl = "http://localhost:8000"
$interval = 1  # secondes

# Vérifier si le serveur répond
Write-Host "1. Vérification de la connexion au serveur..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$serverUrl/health" -TimeoutSec 2 -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ Serveur connecté!" -ForegroundColor Green
        Write-Host "  URL: $serverUrl" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ Le serveur FastAPI n'est pas accessible à $serverUrl" -ForegroundColor Red
    Write-Host "  Assurez-vous que le serveur s'exécute avec: python your_server.py" -ForegroundColor Yellow
    Read-Host "Appuyez sur Entrée pour continuer..."
}

Write-Host ""
Write-Host "2. Génération des données de test..." -ForegroundColor Yellow
Write-Host "   Génération d'un vol simulé..." -ForegroundColor Cyan
Write-Host ""

# Générer les données
$flightDuration = 60  # 60 secondes de vol

for ($elapsed = 0; $elapsed -lt $flightDuration; $elapsed += $interval) {
    # Simulation d'un vol réaliste
    $t = $elapsed
    
    # Altitude: décollage -> montée -> atterrissage
    if ($t -lt 15) {
        $altitude = $t * 3
    } elseif ($t -lt 45) {
        $altitude = 45 + ($t - 15) * 1
    } else {
        $altitude = [Math]::Max(0, 75 - ($t - 45) * 2.5)
    }
    
    # Vitesse
    $speed = [Math]::Max(0, 8 * [Math]::Sin($t / 10) + 5)
    
    # Angles
    $pitch = 20 * [Math]::Sin($t / 12)
    $roll = 15 * [Math]::Cos($t / 10)
    $yaw = ($t * 6) % 360
    
    # Température
    $temperature = 35 + 15 * [Math]::Sin($t / 20)
    
    # Batterie
    $battery = 12 - ($elapsed / 60) * 3
    
    # Créer les données JSON
    $droneData = @{
        temperature = [Math]::Round($temperature, 2)
        altitude = [Math]::Round($altitude, 2)
        vitesse = [Math]::Round($speed, 2)
        batterie = [Math]::Round([Math]::Max(7, $battery), 2)
        roll = [Math]::Round($roll, 2)
        pitch = [Math]::Round($pitch, 2)
        yaw = [Math]::Round($yaw, 2)
    } | ConvertTo-Json
    
    # Envoyer les données
    try {
        $response = Invoke-WebRequest -Uri "$serverUrl/drone-data" `
            -Method POST `
            -ContentType "application/json" `
            -Body $droneData `
            -TimeoutSec 3 `
            -ErrorAction Stop
        
        Write-Host "✓ $($elapsed)s - Alt: $([Math]::Round($altitude, 1))m | Vit: $([Math]::Round($speed, 1))m/s | Bat: $([Math]::Round($battery, 1))V"
    } catch {
        Write-Host "✗ Erreur d'envoi À $($elapsed)s" -ForegroundColor Red
    }
    
    Start-Sleep -Seconds $interval
}

Write-Host ""
Write-Host "✓ Simulation terminée!" -ForegroundColor Green
Write-Host ""
Write-Host "Les données sont maintenant disponibles sur:" -ForegroundColor Cyan
Write-Host "  - Dashboard: http://localhost:8000/dashboard" -ForegroundColor Cyan
Write-Host "  - Données brutes: http://localhost:8000/all-data" -ForegroundColor Cyan
Write-Host ""
