@echo off
echo ===================================================
echo Starting LG9 R Plumber API Backend (Port 8000)...
echo ===================================================
cd /d "%~dp0backend"

if exist "C:\Program Files\R\R-4.6.1\bin\Rscript.exe" (
    "C:\Program Files\R\R-4.6.1\bin\Rscript.exe" run_plumber.R
) else (
    Rscript run_plumber.R
)

pause
