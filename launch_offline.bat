@echo off

set "SC_BIN=C:\Program Files\Roberts Space Industries\StarCitizen\LIVE\Bin64"
set "MOD_DLL=%~dp0dinput8.dll"
set "SC_OFFLINE_BOOT_MAP=PU"
set "SC_OFFLINE_MOD_LOG=%~dp0data\mod.log"
set "SC_OFFLINE_SPAWN_FILE=%~dp0data\spawn.txt"
set "SC_OFFLINE_SHIPS_FILE=%~dp0data\ships.txt"
set "SC_OFFLINE_START="
set "SC_OFFLINE_START_SHIP=DRAK_Cutlass_Black"
set "SC_USER=%SC_BIN%\..\user\client\0"

if not exist "%SC_BIN%\StarCitizen.exe" (
  echo [!] StarCitizen.exe not found at:
  echo     %SC_BIN%
  echo     Edit SC_BIN in this script if your install path differs.
  pause
  exit /b 1
)

if not exist "%MOD_DLL%" (
  echo [!] dinput8.dll is missing: %MOD_DLL%
  echo     Extract the whole zip into one folder and run this script from there.
  pause
  exit /b 1
)

tasklist /FI "IMAGENAME eq StarCitizen.exe" 2>nul | find /I "StarCitizen.exe" >nul
if not errorlevel 1 (
  echo [!] StarCitizen.exe is already running. Close it first.
  pause
  exit /b 1
)

echo Loading offline mod
copy /y "%MOD_DLL%" "%SC_BIN%\dinput8.dll" >nul
if errorlevel 1 (
  echo [!] Could not copy dinput8.dll into Bin64. Run this script as administrator.
  pause
  exit /b 1
)

if not exist "%SC_USER%" mkdir "%SC_USER%"
copy /y "%~dp0data\OfflineDB\default_1.xml" "%SC_USER%\default_1.xml" >nul
if errorlevel 1 echo [!] Could not copy data\OfflineDB\default_1.xml - you will start with no ships.

cd /d "%SC_BIN%"
start "" /wait "StarCitizen.exe"

:wait_exit
tasklist /FI "IMAGENAME eq StarCitizen.exe" 2>nul | find /I "StarCitizen.exe" >nul
if not errorlevel 1 (
  timeout /t 2 /nobreak >nul
  goto wait_exit
)

set tries=0
:del_retry
del /f /q "%SC_BIN%\dinput8.dll" 2>nul
if not exist "%SC_BIN%\dinput8.dll" goto removed
set /a tries+=1
if %tries% geq 30 goto remove_failed
timeout /t 1 /nobreak >nul
goto del_retry

:remove_failed
echo [!] Could not remove %SC_BIN%\dinput8.dll
echo     DELETE IT MANUALLY before launching through the RSI launcher.
pause
exit /b 1

:removed
exit /b 0
