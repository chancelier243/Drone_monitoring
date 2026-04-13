@echo off
REM Script de lancement de l'application Flutter de monitoring de drone

cls
echo.
echo ========================================
echo   DRONE MONITORING - Application Flutter
echo ========================================
echo.

REM Vérifier si Flutter est installé
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Flutter n'est pas installé ou pas dans le PATH
    echo Veuillez installer Flutter depuis: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo ✓ Flutter détecté
echo.

REM Aller au répertoire du projet
cd /d "%~dp0"

echo 1. Installation des dépendances...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Impossible de télécharger les dépendances
    pause
    exit /b 1
)
echo ✓ Dépendances installées
echo.

echo 2. Lancement de l'application...
echo    NOTE: Assurez-vous que le serveur FastAPI s'exécute sur http://localhost:8000
echo    Vous pouvez configurer l'URL du serveur directement dans l'application
echo.

flutter run

pause
