@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Windows Integrity and Repair Utility

color 0F
chcp 65001 >nul

:: Check for administrator rights
net session >nul 2>&1
if %errorlevel%==0 (
  set "ISADMIN=1"
) else (
  set "ISADMIN=0"
)

:: Report folder
set "REPORTROOT=%USERPROFILE%\Desktop\IntegrityReports"
if not exist "%REPORTROOT%" md "%REPORTROOT%" >nul 2>&1

:MAIN
cls
echo ============================================================
echo Windows Integrity and Repair Utility by complicatiion
echo ============================================================
echo.
if "%ISADMIN%"=="1" (
  echo Admin status: YES
) else (
  echo Admin status: NO
)
echo Report folder: %REPORTROOT%
echo.
echo [1] Quick system integrity check
echo [2] SFC /scannow                          [Admin]
echo [3] SFC verify only                       [Admin]
echo [4] DISM CheckHealth                      [Admin]
echo [5] DISM ScanHealth                       [Admin]
echo [6] DISM RestoreHealth                    [Admin]
echo [7] Analyze component store               [Admin]
echo [8] Check Windows Update components
echo [9] Check drivers and device issues
echo [A] Disk and filesystem checks
echo [B] CBS / DISM / Windows Update events
echo [C] Generate full report
echo [D] Run recommended standard repair       [Admin]
echo [E] Open report folder
echo [0] Exit
echo.
set /p CHO="Selection: "

if "%CHO%"=="1" goto :QUICK
if "%CHO%"=="2" goto :SFCSCAN
if "%CHO%"=="3" goto :SFCVERIFY
if "%CHO%"=="4" goto :DISMCHECK
if "%CHO%"=="5" goto :DISMSCAN
if "%CHO%"=="6" goto :DISMRESTORE
if "%CHO%"=="7" goto :COMPSTORE
if "%CHO%"=="8" goto :WU
if "%CHO%"=="9" goto :DRIVERS
if /I "%CHO%"=="A" goto :DISK
if /I "%CHO%"=="B" goto :EVENTS
if /I "%CHO%"=="C" goto :REPORT
if /I "%CHO%"=="D" goto :STANDARDREPAIR
if /I "%CHO%"=="E" goto :OPENFOLDER
if "%CHO%"=="0" goto :END
goto :MAIN

:QUICK
cls
echo ============================================================
echo Quick system integrity check
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$os = Get-CimInstance Win32_OperatingSystem; " ^
"$cs = Get-CimInstance Win32_ComputerSystem; " ^
"Write-Host ('Computer           : ' + $env:COMPUTERNAME); " ^
"Write-Host ('OS                 : ' + $os.Caption + ' ' + $os.Version + ' Build ' + $os.BuildNumber); " ^
"Write-Host ('Architecture       : ' + $os.OSArchitecture); " ^
"Write-Host ('Last Boot          : ' + $os.LastBootUpTime); " ^
"Write-Host ('Manufacturer       : ' + $cs.Manufacturer); " ^
"Write-Host ('Model              : ' + $cs.Model); " ^
"Write-Host ''; " ^
"Write-Host '--- Windows Update Services ---'; " ^
"Get-Service wuauserv,bits,cryptsvc,trustedinstaller -ErrorAction SilentlyContinue | Select-Object Name, Status, StartType | Format-Table -AutoSize; " ^
"Write-Host ''; " ^
"Write-Host '--- Device Problems ---'; " ^
"$bad = Get-PnpDevice -PresentOnly -ErrorAction SilentlyContinue | Where-Object { $_.Status -ne 'OK' }; " ^
"if($bad){ $bad | Select-Object Class, FriendlyName, Status, ProblemCode | Format-Table -AutoSize } else { Write-Host 'No current PnP device errors detected.' }; " ^
"Write-Host ''; " ^
"Write-Host '--- Disk Space ---'; " ^
"Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object { $size=[math]::Round($_.Size/1GB,2); $free=[math]::Round($_.FreeSpace/1GB,2); $used=[math]::Round($size-$free,2); $pct=if($_.Size -gt 0){[math]::Round((($_.Size-$_.FreeSpace)/$_.Size)*100,1)}else{0}; [pscustomobject]@{Drive=$_.DeviceID; SizeGB=$size; UsedGB=$used; FreeGB=$free; UsedPercent=$pct} } | Format-Table -AutoSize"
echo.
pause
goto :MAIN

:SFCSCAN
if not "%ISADMIN%"=="1" goto :NEEDADMIN
cls
echo Running SFC scan...
sfc /scannow
pause
goto :MAIN

:SFCVERIFY
if not "%ISADMIN%"=="1" goto :NEEDADMIN
cls
echo Running SFC verify...
sfc /verifyonly
pause
goto :MAIN

:DISMCHECK
if not "%ISADMIN%"=="1" goto :NEEDADMIN
cls
DISM /Online /Cleanup-Image /CheckHealth
pause
goto :MAIN

:DISMSCAN
if not "%ISADMIN%"=="1" goto :NEEDADMIN
cls
DISM /Online /Cleanup-Image /ScanHealth
pause
goto :MAIN

:DISMRESTORE
if not "%ISADMIN%"=="1" goto :NEEDADMIN
cls
DISM /Online /Cleanup-Image /RestoreHealth
pause
goto :MAIN

:COMPSTORE
if not "%ISADMIN%"=="1" goto :NEEDADMIN
cls
DISM /Online /Cleanup-Image /AnalyzeComponentStore
pause
goto :MAIN

:WU
cls
echo Checking Windows Update components...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Service wuauserv,bits,cryptsvc,trustedinstaller | Format-Table -AutoSize"
pause
goto :MAIN

:DRIVERS
cls
echo Checking drivers...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-PnpDevice | Where-Object { $_.Status -ne 'OK' } | Format-Table -AutoSize"
driverquery
pause
goto :MAIN

:DISK
cls
echo Running disk checks...
chkdsk C: /scan
pause
goto :MAIN

:EVENTS
cls
echo Checking system events...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-WinEvent -LogName System -MaxEvents 200 | Where-Object { $_.LevelDisplayName -eq 'Error' } | Format-List"
pause
goto :MAIN

:STANDARDREPAIR
if not "%ISADMIN%"=="1" goto :NEEDADMIN
cls
echo Running full repair sequence...
DISM /Online /Cleanup-Image /RestoreHealth
sfc /scannow
pause
goto :MAIN

:REPORT
cls
echo Generating report...
systeminfo > "%REPORTROOT%\system_report.txt"
pause
goto :MAIN

:OPENFOLDER
start "" explorer.exe "%REPORTROOT%"
goto :MAIN

:NEEDADMIN
echo Administrator rights required.
pause
goto :MAIN

:END
endlocal
exit /b