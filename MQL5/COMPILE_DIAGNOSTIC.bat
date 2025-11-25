@echo off
echo ====================================
echo COMPILATION HERMES DIAGNOSTIC
echo ====================================
echo.

cd /d "C:\Users\lbye3\Desktop\Hermes\MQL5"

echo Fichiers presents:
dir *.mqh /b
echo.

echo Tentative compilation avec MetaEditor CLI...
echo.

REM Si tu as MetaEditor CLI, remplace le chemin ci-dessous
REM "C:\Program Files\MetaTrader 5\metaeditor64.exe" /compile:Hermes_Diagnostic.mq5 /log

echo.
echo ====================================
echo INSTRUCTIONS:
echo ====================================
echo 1. Ouvre MetaEditor
echo 2. Ferme TOUS les fichiers ouverts (Ctrl+W)
echo 3. File ^> Open ^> Hermes_Diagnostic.mq5
echo 4. Appuie sur F7 pour compiler
echo 5. Copie-colle les erreurs ici
echo.

pause
