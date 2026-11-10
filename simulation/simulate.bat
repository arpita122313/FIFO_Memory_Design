@echo off
REM =============================================================================
REM Project       : Synchronous FIFO Memory Design
REM File          : simulate.bat
REM Description   : Windows Batch launcher for Vivado XSIM simulation
REM =============================================================================

echo ==================================================================
echo   Launching Vivado Behavioral Simulation for FIFO Memory Design
echo ==================================================================

where vivado >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Vivado executable not found in PATH!
    echo Please launch from the Vivado Command Prompt, or add Vivado bin to PATH.
    echo Example: C:\Xilinx\Vivado\2023.2\bin\vivado.bat
    pause
    exit /b 1
)

vivado -mode batch -source run_sim.tcl -notrace
echo ==================================================================
echo   Simulation Execution Finished.
echo ==================================================================
pause
