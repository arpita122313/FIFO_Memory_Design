@echo off
setlocal enabledelayedexpansion
REM =============================================================================
REM Project       : Synchronous FIFO Memory Design
REM File          : push_to_github.bat
REM Description   : 1-Click push to https://github.com/arpita122313/FIFO_Memory_Design
REM =============================================================================

echo ==================================================================
echo   Pushing FIFO Memory Design to GitHub: arpita122313
echo ==================================================================

set "GIT_EXE=C:\Users\HP\AppData\Local\Programs\Git\cmd\git.exe"
if not exist "%GIT_EXE%" (
    where git >nul 2>nul
    if %ERRORLEVEL% equ 0 (
        set "GIT_EXE=git"
    ) else (
        echo [ERROR] Git executable not found!
        pause
        exit /b 1
    )
)

echo [*] Using Git: %GIT_EXE%

"%GIT_EXE%" status >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [*] Initializing Git repository...
    "%GIT_EXE%" init
    "%GIT_EXE%" branch -M main
)

echo [*] Staging all files...
"%GIT_EXE%" add .

echo [*] Committing changes...
"%GIT_EXE%" commit -m "feat: complete synthesizable synchronous FIFO design with testbench, synthesis reports, and documentation" >nul 2>nul

echo [*] Configuring remote origin...
"%GIT_EXE%" remote remove origin >nul 2>nul
"%GIT_EXE%" remote add origin https://github.com/arpita122313/FIFO_Memory_Design.git

echo.
echo [*] Pushing branch 'main' to https://github.com/arpita122313/FIFO_Memory_Design ...
echo (A GitHub login window or prompt will appear to authorize the push)
echo.
"%GIT_EXE%" push -u origin main

if %ERRORLEVEL% equ 0 (
    echo.
    echo ==================================================================
    echo   SUCCESS! Your project is now live on GitHub:
    echo   https://github.com/arpita122313/FIFO_Memory_Design
    echo ==================================================================
) else (
    echo.
    echo [NOTE] If you saw an authentication error, please sign in to GitHub
    echo in the popup window or provide a Personal Access Token (PAT).
)

echo.
pause
