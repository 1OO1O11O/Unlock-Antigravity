@echo off
setlocal

:: --- 1. ASK USER FOR PICKER TYPE ---
echo ========================================
echo   Antigravity CDP Launcher
echo ========================================
echo [1] Pick a Folder
echo [2] Pick a .code-workspace File
echo.
set /p choice="Choose an option (1 or 2): "

if "%choice%"=="1" goto :PICK_FOLDER
if "%choice%"=="2" goto :PICK_FILE
goto :NOT_FOUND

:: --- 2. THE PICKERS (Using PowerShell via Batch) ---
:PICK_FOLDER
for /f "delims=" %%I in ('powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; if($f.ShowDialog() -eq 'OK'){ $f.SelectedPath } }"') do set "TARGET_PATH=%%I"
goto :FIND_EXE

:PICK_FILE
for /f "delims=" %%I in ('powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.OpenFileDialog; $f.Filter = 'Code Workspace (*.code-workspace)|*.code-workspace|All Files (*.*)|*.*'; if($f.ShowDialog() -eq 'OK'){ $f.FileName } }"') do set "TARGET_PATH=%%I"
goto :FIND_EXE

:: --- 3. FIND EXECUTABLE ---
:FIND_EXE
if "%TARGET_PATH%"=="" (
    echo No selection made. Exiting...
    pause
    exit /b 1
)

set "CANDIDATE1=%LOCALAPPDATA%\Programs\Antigravity\Antigravity.exe"
set "CANDIDATE2=%ProgramFiles%\Antigravity\Antigravity.exe"
set "CANDIDATE3=%ProgramFiles(x86)%\Antigravity\Antigravity.exe"

set "EXE_PATH="
for %%F in ("%CANDIDATE1%" "%CANDIDATE2%" "%CANDIDATE3%") do (
    if exist %%F (
        set "EXE_PATH=%%~F"
        goto :LAUNCH
    )
)

:NOT_FOUND
echo.
echo ERROR: Antigravity executable not found.
pause
exit /b 1

:: --- 4. LAUNCH ---
:LAUNCH
echo.
echo Target: "%TARGET_PATH%"
echo Launching in CDP mode on port 9000...

start "" "%EXE_PATH%" --remote-debugging-port=9000 "%TARGET_PATH%"

endlocal