@echo off
REM =============================================================================
REM Project       : Synchronous FIFO Memory Design
REM File          : synthesize.bat
REM Description   : Windows Batch launcher for Vivado RTL synthesis
REM =============================================================================

echo ==================================================================
echo   Launching Vivado RTL Synthesis for FIFO Memory Design
echo   Target Device: Xilinx Artix-7 (xc7a35tcpg236-1)
echo ==================================================================

where vivado >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Vivado executable not found in PATH!
    echo Please launch from the Vivado Command Prompt, or add Vivado bin to PATH.
    echo Example: C:\Xilinx\Vivado\2023.2\bin\vivado.bat
    pause
    exit /b 1
)

vivado -mode batch -source run_synth.tcl -notrace
echo ==================================================================
echo   Synthesis Execution Finished. Check synthesis\reports\ for output.
echo ==================================================================
pause
