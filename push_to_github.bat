@echo off
setlocal enabledelayedexpansion
REM =============================================================================
REM Project       : Synchronous FIFO Memory Design
REM File          : push_to_github.bat
REM Description   : Automated script to initialize git and push project to GitHub
REM =============================================================================

echo ==================================================================
echo       SYNCHRONOUS FIFO DESIGN - PUSH TO GITHUB AUTOMATION
echo ==================================================================

REM 1. Check if Git is installed
where git >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Git is not installed or not found in your system PATH!
    echo.
    echo To install Git on Windows, open PowerShell and run:
    echo     winget install --id Git.Git -e --source winget
    echo or download directly from: https://git-scm.com/download/win
    echo.
    echo After installing, restart your terminal and run this script again.
    pause
    exit /b 1
)

REM 2. Initialize Git Repository if not already initialized
if not exist ".git" (
    echo [*] Initializing local Git repository...
    git init
    git branch -M main
) else (
    echo [*] Existing Git repository detected.
)

REM 3. Prompt user for GitHub repository URL
echo.
echo Please create a new empty repository on GitHub: https://github.com/new
echo (Do NOT initialize with README, .gitignore, or license as we already have them)
echo.
set /p REPO_URL="Enter your GitHub Repository URL (e.g. https://github.com/username/FIFO_Memory_Design.git): "

if "%REPO_URL%"=="" (
    echo [ERROR] No repository URL provided! Exiting.
    pause
    exit /b 1
)

REM 4. Stage and commit files
echo.
echo [*] Staging project files...
git add .

echo [*] Creating initial commit...
git commit -m "feat: complete synthesizable synchronous FIFO design with testbench, Vivado synthesis reports, and documentation"

REM 5. Configure remote origin
git remote remove origin >nul 2>nul
echo [*] Adding remote origin: %REPO_URL%
git remote add origin %REPO_URL%

REM 6. Push to GitHub
echo.
echo [*] Pushing branch 'main' to GitHub...
echo (A browser window or login prompt may appear for GitHub authentication)
echo.
git push -u origin main

if %ERRORLEVEL% equ 0 (
    echo.
    echo ==================================================================
    echo   SUCCESS! Your FIFO project is now live on GitHub:
    echo   %REPO_URL%
    echo ==================================================================
) else (
    echo.
    echo [ERROR] Push failed. Please check your GitHub permissions or URL.
)

pause
