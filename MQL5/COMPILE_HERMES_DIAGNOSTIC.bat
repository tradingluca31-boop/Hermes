@echo off
echo ====================================
echo HERMES DIAGNOSTIC - AUTO COMPILE
echo ====================================
echo.

REM 1. Fermer tous les MetaEditor en cours
echo [1/4] Fermeture MetaEditor...
taskkill /F /IM metaeditor64.exe 2>nul
taskkill /F /IM metaeditor.exe 2>nul
timeout /t 3 /nobreak >nul

REM 2. Supprimer cache .ex5
echo [2/4] Suppression cache...
del "C:\Users\lbye3\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\Hermes_*.ex5" 2>nul
del "C:\Users\lbye3\Desktop\Hermes\MQL5\Hermes_*.ex5" 2>nul

REM 3. Ouvrir MetaEditor avec le bon fichier
echo [3/4] Ouverture MetaEditor...
echo.

REM Trouver MetaEditor
set "METAEDITOR=C:\Program Files\MetaTrader 5\metaeditor64.exe"
if not exist "%METAEDITOR%" (
    set "METAEDITOR=C:\Program Files (x86)\MetaTrader 5\metaeditor64.exe"
)
if not exist "%METAEDITOR%" (
    set "METAEDITOR=C:\Users\lbye3\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\metaeditor64.exe"
)

echo MetaEditor path: %METAEDITOR%
echo.

if exist "%METAEDITOR%" (
    start "" "%METAEDITOR%" "C:\Users\lbye3\Desktop\Hermes\MQL5\Hermes_Diagnostic.mq5"
    timeout /t 5 /nobreak >nul

    echo [4/4] INSTRUCTIONS FINALES:
    echo ====================================
    echo.
    echo 1. MetaEditor est ouvert avec Hermes_Diagnostic.mq5
    echo 2. Appuie sur F7 pour compiler
    echo 3. Tu devrais voir 0 ERREURS
    echo.
    echo Si tu vois encore des erreurs:
    echo - Copie-colle les erreurs ici
    echo - Ou fais une capture d'ecran
    echo.
) else (
    echo ERREUR: MetaEditor introuvable!
    echo.
    echo Ouvre manuellement:
    echo 1. Lance MetaEditor
    echo 2. File ^> Open ^> C:\Users\lbye3\Desktop\Hermes\MQL5\Hermes_Diagnostic.mq5
    echo 3. Appuie sur F7
    echo.
)

echo ====================================
pause
